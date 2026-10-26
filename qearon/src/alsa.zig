const std = @import("std");
const sys = @import("sys.zig");
const i18n = @import("i18n.zig");
const ui = @import("ui.zig");

pub fn detectPrimaryCard(buf: *[8]u8) []const u8 {
    const file = std.fs.cwd().openFile("/proc/asound/cards", .{}) catch return "0";
    defer file.close();

    var read_buf: [2048]u8 = undefined;
    const bytes_read = file.readAll(&read_buf) catch 0;
    const content = read_buf[0..bytes_read];

    var lines = std.mem.splitScalar(u8, content, '\n');
    var fallback_len: usize = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;

        if (std.ascii.isDigit(trimmed[0])) {
            var parts = std.mem.splitScalar(u8, trimmed, '[');
            const card_num = std.mem.trim(u8, parts.next() orelse continue, " ");
            const rest = parts.rest();

            if (fallback_len == 0 and card_num.len <= buf.len) {
                @memcpy(buf[0..card_num.len], card_num);
                fallback_len = card_num.len;
            }

            const is_hdmi = std.mem.indexOf(u8, rest, "NVidia") != null or
                std.mem.indexOf(u8, rest, "HDMI") != null or
                std.mem.indexOf(u8, rest, "DisplayPort") != null;

            if (!is_hdmi and card_num.len <= buf.len) {
                @memcpy(buf[0..card_num.len], card_num);
                return buf[0..card_num.len];
            }
        }
    }

    if (fallback_len > 0) return buf[0..fallback_len];
    return "0";
}


pub fn unmuteOutputs(allocator: std.mem.Allocator, card: []const u8) bool {
    const ok1 = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Master", "85%", "unmute" });
    const ok2 = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Front", "100%", "unmute" });
    const ok3 = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Headphone", "100%", "unmute" });
    const ok4 = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Speaker", "100%", "unmute" });

    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Rear Mic", "mute" });
    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Front Mic", "mute" });
    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Line", "mute" });
    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Mic", "mute" });

    return ok1 or ok2 or ok3 or ok4;
}

pub fn unmuteInputs(allocator: std.mem.Allocator, card: []const u8, prefer_front: bool) bool {
    const ok1 = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Capture", "80%", "unmute" });
    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Capture", "1", "80%", "unmute" });

    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Rear Mic Boost", "2" });
    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Front Mic Boost", "2" });
    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Mic Boost", "2" });
    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Internal Mic Boost", "2" });

    if (prefer_front) {
        _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Input Source", "Front Mic" });
    } else {
        _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Input Source", "Rear Mic" });
    }

    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Rear Mic", "mute" });
    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Front Mic", "mute" });
    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Line", "mute" });
    _ = sys.runSilent(allocator, &[_][]const u8{ "amixer", "-c", card, "set", "Mic", "mute" });

    return ok1;
}

pub fn saveAlsaState(allocator: std.mem.Allocator, card: []const u8) bool {
    if (sys.runSilent(allocator, &[_][]const u8{ "alsactl", "store", card })) {
        return true;
    }
    return sys.runSilent(allocator, &[_][]const u8{ "sudo", "alsactl", "store", card });
}

pub fn printAlsaStatus(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);
    var card_buf: [8]u8 = undefined;
    const card = detectPrimaryCard(&card_buf);

    stdout.print("\n", .{}) catch {};
    ui.printSection(stdout, tr.alsa_title);

    const res_master = sys.runCapture(allocator, &[_][]const u8{ "amixer", "-c", card, "sget", "Master" }) catch return;
    defer allocator.free(res_master.stdout);
    defer allocator.free(res_master.stderr);

    var it_master = std.mem.splitScalar(u8, res_master.stdout, '\n');
    while (it_master.next()) |line| {
        if (std.mem.indexOf(u8, line, "Playback") != null and std.mem.indexOf(u8, line, "[") != null) {
            stdout.print("{s}{s}{s}{s}\n", .{ tr.alsa_master_label, ui.bold_white, std.mem.trim(u8, line, " \t"), ui.reset }) catch {};
            break;
        }
    }

    const res_front = sys.runCapture(allocator, &[_][]const u8{ "amixer", "-c", card, "sget", "Front" }) catch return;
    defer allocator.free(res_front.stdout);
    defer allocator.free(res_front.stderr);

    const front_is_on = std.mem.indexOf(u8, res_front.stdout, "[on]") != null;
    const front_color = if (front_is_on) ui.bold_green else ui.red;
    const front_state = if (front_is_on) tr.alsa_on else tr.alsa_off;
    stdout.print("{s}{s}{s}{s}\n", .{ tr.alsa_front_label, front_color, front_state, ui.reset }) catch {};

    const res_hp = sys.runCapture(allocator, &[_][]const u8{ "amixer", "-c", card, "sget", "Headphone" }) catch return;
    defer allocator.free(res_hp.stdout);
    defer allocator.free(res_hp.stderr);

    const hp_is_on = std.mem.indexOf(u8, res_hp.stdout, "[on]") != null;
    const hp_color = if (hp_is_on) ui.bold_green else ui.red;
    const hp_state = if (hp_is_on) tr.alsa_on else tr.alsa_off;
    stdout.print("{s}{s}{s}{s}\n", .{ tr.alsa_hp_label, hp_color, hp_state, ui.reset }) catch {};
}

