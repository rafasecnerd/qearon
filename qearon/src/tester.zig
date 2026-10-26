const std = @import("std");
const sys = @import("sys.zig");
const i18n = @import("i18n.zig");
const ui = @import("ui.zig");

fn getTestMicFile(allocator: std.mem.Allocator) []const u8 {
    if (std.posix.getenv("XDG_RUNTIME_DIR")) |runtime_dir| {
        return std.fs.path.join(allocator, &[_][]const u8{ runtime_dir, "qearon_mic_test.wav" }) catch "/tmp/qearon_mic_test.wav";
    }
    return "/tmp/qearon_mic_test.wav";
}

pub fn testSoundEmbed(allocator: std.mem.Allocator) bool {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    stdout.print("  {s}<<< [ ((( {s} ))) ]{s}\n", .{ ui.bold_cyan, tr.test_stereo_left, ui.reset }) catch {};
    const ok1 = sys.runSilent(allocator, &[_][]const u8{
        "speaker-test",
        "-c",
        "2",
        "-s",
        "1",
        "-t",
        "sine",
        "-f",
        "440",
        "-l",
        "1",
    });

    stdout.print("  {s}[ ((( {s} ))) ] >>>{s}\n", .{ ui.bold_magenta, tr.test_stereo_right, ui.reset }) catch {};
    const ok2 = sys.runSilent(allocator, &[_][]const u8{
        "speaker-test",
        "-c",
        "2",
        "-s",
        "2",
        "-t",
        "sine",
        "-f",
        "440",
        "-l",
        "1",
    });

    stdout.print("\n", .{}) catch {};

    if (ok1 or ok2) {
        ui.printOk(stdout, tr.test_stereo_done);
        stdout.print("  {s}{s}{s}\n", .{ ui.dim, tr.test_stereo_tip, ui.reset }) catch {};
        return true;
    } else {
        ui.printWarn(stdout, tr.test_stereo_fail);
        return false;
    }
}

pub fn testSound(allocator: std.mem.Allocator) bool {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    ui.printBanner(stdout, tr.test_stereo_title);
    return testSoundEmbed(allocator);
}

pub fn testMic(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);
    const test_mic_file = getTestMicFile(allocator);

    ui.printSection(stdout, tr.test_mic_recording);
    stdout.print("  {s}→{s} {s}{s}{s}\n", .{ ui.bold_cyan, ui.reset, ui.bold_yellow, tr.test_mic_speak, ui.reset }) catch {};

    const argv = [_][]const u8{
        "pw-record",
        test_mic_file,
    };


    var child = std.process.Child.init(&argv, allocator);
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;

    child.spawn() catch {
        ui.printErr(stdout, tr.test_mic_fail);
        return;
    };

    ui.playSpinner(stdout, tr.test_mic_spinner, 28);
    _ = child.kill() catch {};
    _ = child.wait() catch {};

    ui.printSection(stdout, tr.test_mic_playing);

    const ok = sys.runSilent(allocator, &[_][]const u8{
        "pw-play",
        test_mic_file,
    });

    if (ok) {
        ui.printOk(stdout, tr.test_mic_done);
    } else {
        ui.printErr(stdout, tr.test_mic_fail);
    }
}
