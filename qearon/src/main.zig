const std = @import("std");
const alsa = @import("alsa.zig");
const pipewire = @import("pipewire.zig");
const detector = @import("detector.zig");
const tester = @import("tester.zig");
const autofix = @import("autofix.zig");
const vumeter = @import("vumeter.zig");
const loopback = @import("loopback.zig");
const denoise = @import("denoise.zig");
const watcher = @import("watcher.zig");
const installer = @import("installer.zig");
const i18n = @import("i18n.zig");
const ui = @import("ui.zig");

fn isCmd(arg: []const u8, canonical: []const u8, localized: []const u8, pt_cmd: []const u8) bool {
    return std.mem.eql(u8, arg, canonical) or std.mem.eql(u8, arg, localized) or std.mem.eql(u8, arg, pt_cmd);
}

fn isOptOff(arg: []const u8, localized_off: []const u8) bool {
    return std.mem.eql(u8, arg, "off") or std.mem.eql(u8, arg, localized_off) or std.mem.eql(u8, arg, "desligar");
}

fn run(allocator: std.mem.Allocator) !u8 {
    const stdout = std.io.getStdOut().writer();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const tr = i18n.getStrings(allocator);
    const c = tr.commands;
    const pt_c = i18n.pt_strings.commands;

    if (args.len < 2) {
        ui.printLogo(stdout);
        ui.printUsage(stdout, tr);
        return 0;
    }

    const command = args[1];

    if (isCmd(command, "autofix", c.autofix, pt_c.autofix)) {
        const ok = autofix.runAutofixEx(allocator, false);
        return if (ok) 0 else 2;
    } else if (isCmd(command, "status", c.status, pt_c.status)) {
        ui.printBanner(stdout, tr.diag_title);
        detector.printJackStatus(allocator);
        alsa.printAlsaStatus(allocator);
        pipewire.printPipeWireStatus(allocator);
        return 0;
    } else if (isCmd(command, "headset", c.headset, pt_c.headset)) {
        autofix.setHeadsetMode(allocator);
        return 0;
    } else if (isCmd(command, "hdmi", c.hdmi, pt_c.hdmi)) {
        autofix.setHdmiMode(allocator);
        return 0;
    } else if (isCmd(command, "vu", c.vu, pt_c.vu)) {
        vumeter.runVuMeter(allocator);
        return 0;
    } else if (isCmd(command, "loopback", c.loopback, pt_c.loopback)) {
        if (args.len >= 3 and isOptOff(args[2], c.opt_off)) {
            loopback.disableLoopback(allocator);
        } else {
            loopback.enableLoopback(allocator);
        }
        return 0;
    } else if (isCmd(command, "denoise", c.denoise, pt_c.denoise)) {
        if (args.len >= 3 and isOptOff(args[2], c.opt_off)) {
            denoise.disableDenoise(allocator);
        } else {
            denoise.enableDenoise(allocator);
        }
        return 0;
    } else if (isCmd(command, "watch", c.watch, pt_c.watch)) {
        watcher.startWatcher(allocator);
        return 0;
    } else if (isCmd(command, "install", c.install, pt_c.install)) {
        installer.installGlobal(allocator);
        return 0;
    } else if (isCmd(command, "lang", c.lang, pt_c.lang)) {
        if (args.len >= 3) {
            const ok = i18n.setLanguage(args[2]);
            if (ok) {
                const updated_tr = i18n.getStrings(allocator);
                if (std.mem.startsWith(u8, args[2], "pt")) {
                    ui.printOk(stdout, updated_tr.lang_set_pt);
                } else {
                    ui.printOk(stdout, updated_tr.lang_set_en);
                }
                return 0;
            } else {
                ui.printErr(stdout, tr.lang_invalid);
                return 1;
            }
        } else {
            ui.printOk(stdout, tr.lang_current);
            return 0;
        }
    } else if (isCmd(command, "test-sound", c.test_sound, pt_c.test_sound)) {
        const ok = tester.testSound(allocator);
        return if (ok) 0 else 2;
    } else if (isCmd(command, "test-mic", c.test_mic, pt_c.test_mic)) {
        tester.testMic(allocator);
        return 0;
    } else if (isCmd(command, "help", c.help, pt_c.help) or std.mem.eql(u8, command, "--help") or std.mem.eql(u8, command, "-h")) {
        ui.printLogo(stdout);
        ui.printUsage(stdout, tr);
        return 0;
    } else {
        ui.printErr(stdout, tr.cmd_unknown);
        ui.printUsage(stdout, tr);
        return 1;
    }
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const exit_code = run(allocator) catch 1;
    _ = gpa.deinit();
    if (exit_code != 0) {
        std.process.exit(exit_code);
    }
}

