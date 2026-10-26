const std = @import("std");
const sys = @import("sys.zig");
const i18n = @import("i18n.zig");
const ui = @import("ui.zig");

const pid_file_name = "qearon_loopback.pid";

pub fn enableLoopback(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    disableLoopbackSilent(allocator);

    _ = sys.runSilent(allocator, &[_][]const u8{ "wpctl", "set-volume", "@DEFAULT_SOURCE@", "1.0" });

    const pid_path = sys.getRuntimePath(allocator, pid_file_name);
    defer allocator.free(pid_path);

    const cmd = std.fmt.allocPrint(allocator, "nohup pw-loopback -l 1 >/dev/null 2>&1 & echo $! > {s}", .{pid_path}) catch return;
    defer allocator.free(cmd);

    const ok = sys.runSilent(allocator, &[_][]const u8{
        "sh",
        "-c",
        cmd,
    });

    if (ok) {
        ui.printOk(stdout, tr.loopback_on_ok);
        stdout.print("  {s}{s}{s}\n", .{ ui.dim, tr.loopback_on_tip, ui.reset }) catch {};
        stdout.print("  {s}{s}{s}\n", .{ ui.dim, tr.loopback_off_tip, ui.reset }) catch {};
    } else {
        ui.printErr(stdout, tr.loopback_on_err);
    }
}

pub fn disableLoopbackSilent(allocator: std.mem.Allocator) void {
    const pid_path = sys.getRuntimePath(allocator, pid_file_name);
    defer allocator.free(pid_path);

    const file = std.fs.openFileAbsolute(pid_path, .{}) catch std.fs.cwd().openFile(pid_path, .{}) catch null;
    if (file) |f| {
        defer f.close();
        var buf: [32]u8 = undefined;
        const bytes = f.readAll(&buf) catch 0;
        const pid_str = std.mem.trim(u8, buf[0..bytes], " \t\r\n");
        if (pid_str.len > 0) {
            _ = sys.killPid(allocator, pid_str);
        }
    }
    std.fs.deleteFileAbsolute(pid_path) catch std.fs.cwd().deleteFile(pid_path) catch {};
    std.fs.cwd().deleteFile("/tmp/" ++ pid_file_name) catch {};

    _ = sys.runSilent(allocator, &[_][]const u8{ "pactl", "unload-module", "module-loopback" });
}

pub fn disableLoopback(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    disableLoopbackSilent(allocator);

    ui.printOk(stdout, tr.loopback_off_ok);
}

