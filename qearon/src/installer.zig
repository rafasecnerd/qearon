const std = @import("std");
const sys = @import("sys.zig");
const i18n = @import("i18n.zig");
const ui = @import("ui.zig");

const target_path = "/usr/local/bin/qearon";

pub fn installGlobal(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    ui.printBanner(stdout, tr.install_title);

    ui.printStep(stdout, 1, 2, tr.install_step1);
    ui.playSpinner(stdout, tr.install_spinner, 15);
    const build_ok = sys.runSilent(allocator, &[_][]const u8{
        "zig",
        "build",
        "-Doptimize=ReleaseFast",
    });

    if (!build_ok) {
        ui.printErr(stdout, tr.install_build_fail);
        return;
    }

    stdout.print("\n", .{}) catch {};
    ui.printStep(stdout, 2, 2, tr.install_step2);
    stdout.print("  {s}{s}{s}\n", .{ ui.bold_cyan, target_path, ui.reset }) catch {};

    var copied = sys.runSilent(allocator, &[_][]const u8{
        "install",
        "-m",
        "755",
        "zig-out/bin/qearon",
        target_path,
    });

    if (!copied) {
        copied = sys.runSilent(allocator, &[_][]const u8{
            "sudo",
            "install",
            "-m",
            "755",
            "zig-out/bin/qearon",
            target_path,
        });
    }

    if (copied) {
        _ = sys.runSilent(allocator, &[_][]const u8{ "sudo", "ln", "-sf", target_path, "/usr/local/bin/mic-fix" });

        stdout.print("\n", .{}) catch {};
        ui.printOk(stdout, tr.install_ok);
        stdout.print("{s}{s}{s}\n", .{ ui.bold_white, tr.install_tip, ui.reset }) catch {};
    } else {
        stdout.print("\n", .{}) catch {};
        ui.printErr(stdout, tr.install_fail);
    }
}
