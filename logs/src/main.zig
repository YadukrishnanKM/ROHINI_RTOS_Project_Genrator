const std = @import("std");
const print = std.debug.print;
const file = std.fs;

//--------------------------------------------------------------------------------------//
//                             Read Write CSV log file                                  //
//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//
//  created on 26-sept-2025 19:09                                                       //
//  Last edited by : kmy_126_                                                           //
//--------------------------------------------------------------------------------------//

/// This module provides functions to create, check existence, append to, and empty files.
const FileError = enum { Sucess, UnableToOpen, EmptyFile, CreateFileError, FileNotExist, CSVFileExists };

/// Struct to hold file path and its length
/// This struct is used to pass file path information to the functions.
/// It contains a pointer to the file path and its length.
/// ## Fields
/// - `Path`: A pointer to a null-terminated string representing the file path.
/// - `PathLenght`: A 16-bit unsigned integer representing the length of the file path string.
const FileData = extern struct { Path: [*]const u8, PathLenght: u16 };

/// Struct to hold data to be written to a file
/// This struct is used to pass data to be appended to a file.
/// It contains a pointer to the data and its length.
/// ## Fields
/// - `data`: A pointer to a byte array containing the data to be written.
/// - `DataLenght`: A 16-bit unsigned integer representing the length of the data array.
const Data = extern struct { data: [*]const u8, DataLenght: u16 };

/// Initializes a CSV file for logging.
/// This function checks if the file exists, and if not, creates it and appends a CSV header.
/// Returns a status code indicating success or failure.
/// ## Parameters
/// - `Fd`: A `FileData` struct containing the file path and its length.
/// ## Returns
/// - `u32`: A status code indicating the result of the operation.
pub export fn initFirstTime(Fd: FileData) callconv(.C) u32 {
    if (CheckFileExists(Fd) == @intFromEnum(FileError.FileNotExist)) {
        const status = CreateCSVFile(Fd);
        if (status != @intFromEnum(FileError.Sucess)) return status; // Return error if file creation fails

        const csvHeader: Data = .{
            .data = "Time,day,month,year,log_data\n", // CSV header for logging
            .DataLenght = 30, // Length of the CSV header
        };

        const appendStatus = AppendToFile(Fd, csvHeader);
        if (appendStatus != @intFromEnum(FileError.Sucess)) return appendStatus; // Return error if appending header fails
    }

    return @intFromEnum(FileError.Sucess); // Return success if file created

}

/// Creates a CSV file at the specified path.
/// Returns a status code indicating success or failure.
/// ## Parameters
/// - `Fd`: A `FileData` struct containing the file path and its length.
/// ## Returns
/// - `u32`: A status code indicating the result of the operation.
pub export fn CreateCSVFile(Fd: FileData) callconv(.C) u32 {
    const FilePath = Fd.Path[0 .. Fd.PathLenght - 1];

    const File = file.createFileAbsolute(FilePath, .{ .mode = .EmptyFile }) catch |err| {
        _ = err;
        return @intFromEnum(FileError.CreateFileError);
    };

    defer File.close();
    return @intFromEnum(FileError.Sucess);
}

/// Checks if a file exists at the specified path.
/// Returns a status code indicating success or failure.
/// ## Parameters
/// - `Fd`: A `FileData` struct containing the file path and its length.
/// ## Returns
/// - `u32`: A status code indicating whether the file exists or not.
pub export fn CheckFileExists(Fd: FileData) callconv(.C) u32 {
    const FilePath = Fd.Path[0 .. Fd.PathLenght - 1];

    const File = file.openFileAbsolute(FilePath, .{ .mode = .read_only }) catch |err| {
        _ = err;
        return @intFromEnum(FileError.FileNotExist);
    };
    defer File.close();
    return @intFromEnum(FileError.Sucess);
}

/// Appends data to a file at the specified path.
/// Returns a status code indicating success or failure.
/// ## Parameters
/// - `Fd`: A `FileData` struct containing the file path and its length.
/// - `data`: A `Data` struct containing the data to be appended and its length
/// ## Returns
/// - `u32`: A status code indicating the result of the operation.
inline fn AppendToFile(Fd: FileData, data: Data) u32 {
    const FilePath = Fd.Path[0 .. Fd.PathLenght - 1];

    const File = file.openFileAbsolute(FilePath, .{ .mode = .write_only }) catch |err| {
        _ = err;
        return @intFromEnum(FileError.FileNotExist);
    };
    defer File.close();

    File.writer().writeAll(data.data[0 .. data.DataLenght - 1]) catch |err| {
        _ = err;
        return @intFromEnum(FileError.UnableToOpen);
    };

    return @intFromEnum(FileError.Sucess);
}

pub export fn AppendToCSV(Fd: FileData, data: Data) callconv(.C) u32 {
    const AppendToCSVStatus = AppendToFile(Fd, data);
    if (AppendToCSVStatus != @intFromEnum(FileError.Sucess)) return AppendToCSVStatus; // Return error if appending fails

    return @intFromEnum(FileError.Sucess); // Return success if appending is successful
}

/// Empties a file at the specified path.
/// Returns a status code indicating success or failure.
/// ## Parameters
/// - `Fd`: A `FileData` struct containing the file path and its length.
/// ## Returns
/// - `u32`: A status code indicating the result of the operation.
pub export fn EmptyFile(Fd: FileData) callconv(.C) u32 {
    const FilePath = Fd.Path[0 .. Fd.PathLenght - 1];

    const File = file.openFileAbsolute(FilePath, .{ .mode = .write_only }) catch |err| {
        _ = err;
        return @intFromEnum(FileError.FileNotExist);
    };
    defer File.close();

    File.writer().truncate(0) catch |err| {
        _ = err;
        return @intFromEnum(FileError.UnableToOpen);
    };

    return @intFromEnum(FileError.Sucess);
}
