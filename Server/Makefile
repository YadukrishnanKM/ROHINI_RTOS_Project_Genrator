# Makefile for building the Go TCP Streaming Server as a shared library

TARGET = ../build/Server/libgostreamserver.so
SRC = ./src/main.go
LDFLAGS = -s -w
BUILDMODE = c-shared

.PHONY: all build debug clean

all: build

# Release build
build:
	go build -buildmode=$(BUILDMODE) -ldflags="$(LDFLAGS)" -o $(TARGET) $(SRC)

# Debug build with escape analysis
debug:
	go build -buildmode=$(BUILDMODE) -gcflags="-m=2" -o $(TARGET) $(SRC)

# Clean artifacts
clean:
	rm -f $(TARGET) ../build/libgostreamserver.h
