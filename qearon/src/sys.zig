const std = @import("std");

pub const ExecResult = struct {
    stdout: []u8,
    stderr: []u8,
    exit_code: u8,
};

pub fn runSilent(allocator: std.mem.Allocator, argv: []const []const u8) bool {
    const res = std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv,
        .max_output_bytes = 4 * 1024 * 1024,
    }) catch {
        return false;
    };
    defer allocator.free(res.stdout);
    defer allocator.free(res.stderr);

    return res.term.Exited == 0;
}

pub fn runCapture(allocator: std.mem.Allocator, argv: []const []const u8) !ExecResult {
    const res = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv,
        .max_output_bytes = 4 * 1024 * 1024,
    });

    const code: u8 = if (res.term == .Exited) res.term.Exited else 1;

    return ExecResult{
        .stdout = res.stdout,
        .stderr = res.stderr,
        .exit_code = code,
    };
}

pub fn runPassThrough(allocator: std.mem.Allocator, argv: []const []const u8) bool {
    var child = std.process.Child.init(argv, allocator);
    child.spawn() catch {
        return false;
    };
    const term = child.wait() catch {
        return false;
    };
    return term.Exited == 0;
}

pub fn killPid(allocator: std.mem.Allocator, pid_str: []const u8) bool {
    const trimmed = std.mem.trim(u8, pid_str, " \t\r\n");
    if (trimmed.len == 0) return false;
    return runSilent(allocator, &[_][]const u8{ "kill", "-15", trimmed });
}

pub fn getRuntimePath(allocator: std.mem.Allocator, filename: []const u8) []const u8 {
    if (std.posix.getenv("XDG_RUNTIME_DIR")) |runtime_dir| {
        return std.fs.path.join(allocator, &[_][]const u8{ runtime_dir, filename }) catch std.fmt.allocPrint(allocator, "/tmp/{s}", .{filename}) catch "/tmp/fallback";
    }
    return std.fmt.allocPrint(allocator, "/tmp/{s}", .{filename}) catch "/tmp/fallback";
}
