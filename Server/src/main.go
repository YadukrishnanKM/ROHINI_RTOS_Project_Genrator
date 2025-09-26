package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"context"
	"errors"
	"fmt"
	"net"
	"sync"
	"time"
	"unsafe"
)

// Error codes (C-visible numeric enums)
const (
	ERR_SUCCESS          = 0
	ERR_ALREADY_RUNNING  = 1
	ERR_NOT_RUNNING      = 2
	ERR_ADDR_IN_USE      = 3
	ERR_INVALID_PORT     = 4
	ERR_INTERNAL         = 5
	ERR_INVALID_ARGUMENT = 6
)

// Status enums
const (
	STATUS_STOPPED = 0
	STATUS_RUNNING = 1
)

//-----------------------------------------------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------------------------------------------//

/*
// C-visible error codes
// These are used to return error codes to C callers.
// They map to the constants defined above.
// The C code can use these codes to check for errors after calling exported functions.
*/
type tcpServer struct {
	mu          sync.Mutex
	listener    net.Listener
	port        int
	message     string
	running     bool
	ctx         context.Context
	cancel      context.CancelFunc
	wg          sync.WaitGroup
	lastErr     error
	connections map[net.Conn]struct{}
}

/*
// C-visible struct to hold server state
// This struct is not exported to C, but its fields are used in the exported functions.
// It holds the server's state, including the listener, port, message, and connection map.
*/
var srv = &tcpServer{
	port:        8080,
	message:     "hello from go-stream-server",
	connections: make(map[net.Conn]struct{}),
}

//-----------------------------------------------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------------------------------------------//

// helpers to set last error and map to code
func (s *tcpServer) setLastErr(err error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.lastErr = err
}

// mapErrorToCode converts an error to a C-visible error code.
func mapErrorToCode(err error) C.int {
	if err == nil {
		return ERR_SUCCESS
	}
	switch {
	case errors.Is(err, ErrAlreadyRunning):
		return ERR_ALREADY_RUNNING
	case errors.Is(err, ErrNotRunning):
		return ERR_NOT_RUNNING
	case errors.Is(err, ErrAddrInUse):
		return ERR_ADDR_IN_USE
	case errors.Is(err, ErrInvalidPort):
		return ERR_INVALID_PORT
	default:
		return ERR_INTERNAL
	}
}

var (
	ErrAlreadyRunning  = errors.New("server already running")
	ErrNotRunning      = errors.New("server not running")
	ErrAddrInUse       = errors.New("address in use")
	ErrInvalidPort     = errors.New("invalid port")
	ErrInvalidArgument = errors.New("invalid argument")
)

// start the TCP listener and accept loop (non-blocking)
func (s *tcpServer) start() error {
	s.mu.Lock()
	if s.running {
		s.mu.Unlock()
		return ErrAlreadyRunning
	}
	if s.port <= 0 || s.port > 65535 {
		s.mu.Unlock()
		return ErrInvalidPort
	}

	addr := fmt.Sprintf("127.0.0.1:%d", s.port)
	ln, err := net.Listen("tcp", addr)
	if err != nil {
		s.mu.Unlock()
		if opErr, ok := err.(*net.OpError); ok && opErr.Err != nil {
			_ = opErr
		}
		return ErrAddrInUse
	}
	s.listener = ln
	s.running = true
	s.ctx, s.cancel = context.WithCancel(context.Background())
	s.wg = sync.WaitGroup{}
	s.mu.Unlock()

	// accept loop
	s.wg.Add(1)
	go func() {
		defer s.wg.Done()
		for {
			conn, err := s.listener.Accept()
			if err != nil {
				select {
				case <-s.ctx.Done():
					// normal shutdown
					return
				default:
					// fatal accept error
					s.setLastErr(err)
					return
				}
			}
			// handle connection
			s.mu.Lock()
			s.connections[conn] = struct{}{}
			s.mu.Unlock()
			s.wg.Add(1)
			go s.handleConn(conn)
		}
	}()

	return nil
}

func (s *tcpServer) handleConn(conn net.Conn) {
	defer s.wg.Done()
	defer func() {
		conn.Close()
		s.mu.Lock()
		delete(s.connections, conn)
		s.mu.Unlock()
	}()

	// stream message once per second until context cancelled or connection closes
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-s.ctx.Done():
			return
		case <-ticker.C:
			msg := s.getMessage() + "\n"
			_, err := conn.Write([]byte(msg))
			if err != nil {
				// connection probably closed
				return
			}
		}
	}
}

func (s *tcpServer) stop() error {
	s.mu.Lock()
	if !s.running {
		s.mu.Unlock()
		return ErrNotRunning
	}
	// cancel accept loop and active connections
	s.cancel()
	// close listener
	_ = s.listener.Close()
	// close open connections
	for c := range s.connections {
		_ = c.Close()
	}
	s.mu.Unlock()

	// wait for goroutines
	s.wg.Wait()

	s.mu.Lock()
	s.running = false
	s.listener = nil
	s.connections = make(map[net.Conn]struct{})
	s.mu.Unlock()
	return nil
}

func (s *tcpServer) setMessage(msg string) {
	s.mu.Lock()
	s.message = msg
	s.mu.Unlock()
}

func (s *tcpServer) getMessage() string {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.message
}

func (s *tcpServer) setPort(p int) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.running {
		return ErrAlreadyRunning
	}
	if p <= 0 || p > 65535 {
		return ErrInvalidPort
	}
	s.port = p
	return nil
}

func (s *tcpServer) status() int {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.running {
		return STATUS_RUNNING
	}
	return STATUS_STOPPED
}

func (s *tcpServer) lastError() error {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.lastErr
}

//-----------------------------------------------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------------------------------------------//

/*
Exported functions for C interface
These functions are exported to C and can be called from C code.
They handle the server lifecycle, message setting, and error reporting.
*/
func StartServer(port C.int, cmsg *C.char) C.int {
	// validate port
	p := int(port)
	if p <= 0 || p > 65535 {
		srv.setLastErr(ErrInvalidPort)
		return ERR_INVALID_PORT
	}

	// set message if provided
	if cmsg != nil {
		msg := C.GoString(cmsg)
		srv.setMessage(msg)
	}

	// set port
	if err := srv.setPort(p); err != nil {
		srv.setLastErr(err)
		return mapErrorToCode(err)
	}

	err := srv.start()
	if err != nil {
		srv.setLastErr(err)
		return mapErrorToCode(err)
	}
	srv.setLastErr(nil)
	return ERR_SUCCESS
}

/*
StopServer stops the TCP server if it is running.
It closes the listener and all active connections.
Returns ERR_SUCCESS on success, or an error code if it was not running.
This function is non-blocking and will return immediately.
It can be called at any time, even if the server is not running.
*/
func StopServer() C.int {
	err := srv.stop()
	if err != nil {
		srv.setLastErr(err)
		return mapErrorToCode(err)
	}
	srv.setLastErr(nil)
	return ERR_SUCCESS
}

/*
SetMessage sets the message to be sent to clients.
This function can be called at any time, even while the server is running.
If the server is stopped, it will set the message for the next time it starts.
Returns ERR_SUCCESS on success, or ERR_INVALID_ARGUMENT if the message is nil.
This function is non-blocking and will return immediately.
It can be called at any time, even if the server is not running.
It is safe to call this function concurrently with StartServer or StopServer
*/
func SetMessage(cmsg *C.char) C.int {
	if cmsg == nil {
		err := ErrInvalidArgument
		srv.setLastErr(err)
		return ERR_INVALID_ARGUMENT
	}
	msg := C.GoString(cmsg)
	srv.setMessage(msg)
	return ERR_SUCCESS
}

// Only allowed when server is stopped.
//
//export SetPort
func SetPort(port C.int) C.int {
	p := int(port)
	err := srv.setPort(p)
	if err != nil {
		srv.setLastErr(err)
		return mapErrorToCode(err)
	}
	return ERR_SUCCESS
}

/*
export GetStatus
GetStatus returns the current status of the server.
It returns STATUS_RUNNING if the server is running, or STATUS_STOPPED if it is not.
This function is non-blocking and will return immediately.
It can be called at any time, even if the server is not running.
*/
func GetStatus() C.int {
	return C.int(srv.status())
}

//export LastErrorCode
func LastErrorCode() C.int {
	return mapErrorToCode(srv.lastError())
}

//export LastErrorMessage
func LastErrorMessage() *C.char {
	err := srv.lastError()
	if err == nil {
		return nil
	}
	// Caller must call FreeCString on returned pointer
	return C.CString(err.Error())
}

//export FreeCString
func FreeCString(ptr *C.char) {
	if ptr == nil {
		return
	}
	C.free(unsafe.Pointer(ptr))
}

//-----------------------------------------------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------------------------------------------//

func main() {}
