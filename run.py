from utils.RPG_ABI import *
import socket

def main():
    # 1. Initialize repo paths
    user_input = UserInputStruct(
        GitRepoUrl=b"https://github.com/YadukrishnanKM/Rohini_RTOS-RP2040.git",
        GitRepoUrlLen=len(b"https://github.com/YadukrishnanKM/Rohini_RTOS-RP2040.git"),
        CloneDestinationPath=b"/My_Programs/Zig_lang/ROS_Project_Generator/Python_ABI/ROHINI_RTOS_Project_Genrator",
        CloneDestinationPathLen=len(b"/My_Programs/Zig_lang/ROS_Project_Generator/Python_ABI/ROHINI_RTOS_Project_Genrator")
    )
    res = init(user_input)
    print("init:", res)

    # 2. Check network connectivity
    res = CheckConnection()
    print("CheckConnection:", res)

    # 3. Validate GitHub URL
    url_check = RepoUrlCheckStruct(
        Url=b"https://github.com/YadukrishnanKM/Rohini_RTOS-RP2040.git",
        length=len(b"https://github.com/YadukrishnanKM/Rohini_RTOS-RP2040.git")
    )
    res = ValidateURL(url_check)
    print("ValidateURL:", res)

    # 4. Directory check
    path_dir = PathDirStruct(Path=b"/tmp", length=len(b"/tmp"))
    res = DirExists(path_dir)
    print("DirExists:", res)

    # 5. Make directory
    path_dir2 = PathDirStruct(Path=b"/tmp/test_dir", length=len(b"/tmp/test_dir"))
    res = MakeDir(path_dir2)
    print("MakeDir:", res)

    # 6. Initialize log server
    server = InitLogServer(8080)
    print("InitLogServer:", server.port, "Error:", server.err_val)

    # 7. Check if server is accepting connections
    is_up = check_server(port=server.port)
    print(f"Server running on port {server.port}:", is_up)

    # 8. Example log stream
    stream_log_example(server, "Test log message")

if __name__ == "__main__":
    main()
