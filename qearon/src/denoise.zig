const std = @import("std");
const sys = @import("sys.zig");
const pipewire = @import("pipewire.zig");
const i18n = @import("i18n.zig");
const ui = @import("ui.zig");

const state_file_name = "qearon_denoise.id";
const pw_state_file_name = "qearon_denoise.pw_id";

pub fn enableDenoise(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    disableDenoiseSilent(allocator);

    const res_pw = sys.runCapture(allocator, &[_][]const u8{
        "sh",
        "-c",
        "printf 'load-module libpipewire-module-echo-cancel\\nquit\\n' | pw-cli",
    }) catch null;

    var ok_native = false;
    if (res_pw) |res| {
        defer allocator.free(res.stdout);
        defer allocator.free(res.stderr);

        if (std.mem.indexOf(u8, res.stdout, "@module:") != null) {
            ok_native = true;
            if (std.mem.indexOf(u8, res.stdout, "@module:")) |idx| {
                const after = res.stdout[idx + 8 ..];
                const trimmed = std.mem.trim(u8, after, " \t\r\n");
                var len: usize = 0;
                while (len < trimmed.len and std.ascii.isDigit(trimmed[len])) : (len += 1) {}
                if (len > 0) {
                    const pw_path = sys.getRuntimePath(allocator, pw_state_file_name);
                    defer allocator.free(pw_path);

                    const f = std.fs.createFileAbsolute(pw_path, .{}) catch std.fs.cwd().createFile(pw_path, .{}) catch null;
                    if (f) |file| {
                        defer file.close();
                        file.writeAll(trimmed[0..len]) catch {};
                    }
                }
            }
        }
    }

    if (ok_native) {
        ui.printOk(stdout, tr.denoise_on_ok);
        stdout.print("  {s}{s}{s}\n", .{ ui.dim, tr.denoise_on_tip, ui.reset }) catch {};
        stdout.print("  {s}{s}{s}\n", .{ ui.dim, tr.denoise_off_tip, ui.reset }) catch {};
        return;
    }

    const res = sys.runCapture(allocator, &[_][]const u8{
        "pactl",
        "load-module",
        "module-echo-cancel",
        "aec_method=webrtc",
    }) catch {
        ui.printErr(stdout, tr.denoise_on_err);
        return;
    };
    defer allocator.free(res.stdout);
    defer allocator.free(res.stderr);

    const trimmed_id = std.mem.trim(u8, res.stdout, " \t\r\n");

    if (trimmed_id.len > 0 and std.ascii.isDigit(trimmed_id[0])) {
        const state_path = sys.getRuntimePath(allocator, state_file_name);
        defer allocator.free(state_path);

        const file = std.fs.createFileAbsolute(state_path, .{}) catch std.fs.cwd().createFile(state_path, .{}) catch null;
        if (file) |f| {
            defer f.close();
            f.writeAll(trimmed_id) catch {};
        }

        ui.printOk(stdout, tr.denoise_on_ok);
        stdout.print("  {s}{s}{s}\n", .{ ui.dim, tr.denoise_on_tip, ui.reset }) catch {};
        stdout.print("  {s}{s}{s}\n", .{ ui.dim, tr.denoise_off_tip, ui.reset }) catch {};
    } else {
        ui.printErr(stdout, tr.denoise_on_err);
    }
}

pub fn disableDenoiseSilent(allocator: std.mem.Allocator) void {
    const pw_path = sys.getRuntimePath(allocator, pw_state_file_name);
    defer allocator.free(pw_path);

    const pw_file = std.fs.openFileAbsolute(pw_path, .{}) catch std.fs.cwd().openFile(pw_path, .{}) catch null;
    if (pw_file) |f| {
        defer f.close();
        var buf: [32]u8 = undefined;
        const bytes = f.readAll(&buf) catch 0;
        const mod_id = std.mem.trim(u8, buf[0..bytes], " \t\r\n");
        if (mod_id.len > 0) {
            const cmd = std.fmt.allocPrint(allocator, "printf 'destroy {s}\\nquit\\n' | pw-cli", .{mod_id}) catch null;
            if (cmd) |c| {
                defer allocator.free(c);
                _ = sys.runSilent(allocator, &[_][]const u8{ "sh", "-c", c });
            }
        }
    }
    std.fs.deleteFileAbsolute(pw_path) catch std.fs.cwd().deleteFile(pw_path) catch {};
    std.fs.cwd().deleteFile("/tmp/" ++ pw_state_file_name) catch {};

    const state_path = sys.getRuntimePath(allocator, state_file_name);
    defer allocator.free(state_path);

    const file = std.fs.openFileAbsolute(state_path, .{}) catch std.fs.cwd().openFile(state_path, .{}) catch null;
    if (file) |f| {
        defer f.close();
        var buf: [64]u8 = undefined;
        const bytes_read = f.readAll(&buf) catch 0;
        const module_id = std.mem.trim(u8, buf[0..bytes_read], " \t\r\n");

        if (module_id.len > 0) {
            _ = sys.runSilent(allocator, &[_][]const u8{ "pactl", "unload-module", module_id });
        }
    }
    std.fs.deleteFileAbsolute(state_path) catch std.fs.cwd().deleteFile(state_path) catch {};
    std.fs.cwd().deleteFile("/tmp/" ++ state_file_name) catch {};

    _ = sys.runSilent(allocator, &[_][]const u8{ "pactl", "unload-module", "module-echo-cancel" });
}

pub fn disableDenoise(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    disableDenoiseSilent(allocator);

    ui.printOk(stdout, tr.denoise_off_ok);
}

