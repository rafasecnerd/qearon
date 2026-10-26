const std = @import("std");
const sys = @import("sys.zig");
const alsa = @import("alsa.zig");
const i18n = @import("i18n.zig");
const ui = @import("ui.zig");

pub const JackInfo = struct {
    rear_out_plugged: bool,
    rear_mic_plugged: bool,
    front_hp_plugged: bool,
    front_mic_plugged: bool,
};

fn checkAlsaJack(allocator: std.mem.Allocator, card: []const u8, jack_name: []const u8) ?bool {
    const query = std.fmt.allocPrint(allocator, "iface=CARD,name='{s}'", .{jack_name}) catch return null;
    defer allocator.free(query);

    const res = sys.runCapture(allocator, &[_][]const u8{ "amixer", "-c", card, "cget", query }) catch return null;
    defer allocator.free(res.stdout);
    defer allocator.free(res.stderr);

    if (res.exit_code != 0) return null;

    if (std.mem.indexOf(u8, res.stdout, "values=on") != null) {
        return true;
    } else if (std.mem.indexOf(u8, res.stdout, "values=off") != null) {
        return false;
    }
    return null;
}

fn detectJacksFromAlsa(allocator: std.mem.Allocator, card: []const u8, info: *JackInfo) bool {
    var detected_any = false;

    if (checkAlsaJack(allocator, card, "Line Out Jack")) |val| {
        info.rear_out_plugged = val;
        detected_any = true;
    }

    if (checkAlsaJack(allocator, card, "Rear Mic Jack")) |val| {
        info.rear_mic_plugged = val;
        detected_any = true;
    }

    if (checkAlsaJack(allocator, card, "Front Headphone Jack") orelse checkAlsaJack(allocator, card, "Headphone Jack")) |val| {
        info.front_hp_plugged = val;
        detected_any = true;
    }

    if (checkAlsaJack(allocator, card, "Front Mic Jack") orelse checkAlsaJack(allocator, card, "Mic Jack")) |val| {
        info.front_mic_plugged = val;
        detected_any = true;
    }

    return detected_any;
}

fn detectJacksFromProcfs(allocator: std.mem.Allocator, card: []const u8, info: *JackInfo) bool {
    const path = std.fmt.allocPrint(allocator, "/proc/asound/card{s}/codec#0", .{card}) catch return false;
    defer allocator.free(path);

    const file = std.fs.cwd().openFile(path, .{}) catch return false;
    defer file.close();

    var buf: [32768]u8 = undefined;
    const bytes_read = file.readAll(&buf) catch 0;
    const content = buf[0..bytes_read];
    if (content.len == 0) return false;

    var detected = false;
    var lines = std.mem.splitScalar(u8, content, '\n');
    var current_node_is_jack = false;
    var jack_desc: [64]u8 = undefined;
    var jack_desc_len: usize = 0;

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");

        if (std.mem.startsWith(u8, trimmed, "Pin Default")) {
            current_node_is_jack = std.mem.indexOf(u8, trimmed, "[Jack]") != null;
            if (current_node_is_jack) {
                const len = @min(trimmed.len, jack_desc.len);
                @memcpy(jack_desc[0..len], trimmed[0..len]);
                jack_desc_len = len;
            }
            continue;
        }

        if (current_node_is_jack and std.mem.startsWith(u8, trimmed, "Pin-ctls:")) {
            const desc = jack_desc[0..jack_desc_len];
            const is_active = std.mem.indexOf(u8, trimmed, "0x00") == null;

            if (std.mem.indexOf(u8, desc, "Line Out") != null or std.mem.indexOf(u8, desc, "Ext Rear") != null) {
                if (std.mem.indexOf(u8, desc, "Mic") == null) {
                    info.rear_out_plugged = is_active;
                    detected = true;
                }
            }
            if (std.mem.indexOf(u8, desc, "HP Out") != null or std.mem.indexOf(u8, desc, "Ext Front") != null) {
                if (std.mem.indexOf(u8, desc, "Mic") == null) {
                    info.front_hp_plugged = is_active;
                    detected = true;
                }
            }
            if (std.mem.indexOf(u8, desc, "Mic") != null and std.mem.indexOf(u8, desc, "Ext Rear") != null) {
                info.rear_mic_plugged = is_active;
                detected = true;
            }
            if (std.mem.indexOf(u8, desc, "Mic") != null and std.mem.indexOf(u8, desc, "Ext Front") != null) {
                info.front_mic_plugged = is_active;
                detected = true;
            }
            current_node_is_jack = false;
        }
    }

    return detected;
}

fn detectJacksFromPipeWire(allocator: std.mem.Allocator, info: *JackInfo) void {
    const res = sys.runCapture(allocator, &[_][]const u8{"pw-dump"}) catch return;
    defer allocator.free(res.stdout);
    defer allocator.free(res.stderr);

    if (std.mem.indexOf(u8, res.stdout, "\"analog-output-lineout\"")) |idx| {
        const slice_end = @min(idx + 500, res.stdout.len);
        if (std.mem.indexOf(u8, res.stdout[idx..slice_end], "\"available\": \"yes\"") != null) {
            info.rear_out_plugged = true;
        }
    }

    if (std.mem.indexOf(u8, res.stdout, "\"analog-input-rear-mic\"")) |idx| {
        const slice_end = @min(idx + 500, res.stdout.len);
        if (std.mem.indexOf(u8, res.stdout[idx..slice_end], "\"available\": \"yes\"") != null) {
            info.rear_mic_plugged = true;
        }
    }

    if (std.mem.indexOf(u8, res.stdout, "\"analog-output-headphones\"")) |idx| {
        const slice_end = @min(idx + 500, res.stdout.len);
        if (std.mem.indexOf(u8, res.stdout[idx..slice_end], "\"available\": \"yes\"") != null) {
            info.front_hp_plugged = true;
        }
    }

    if (std.mem.indexOf(u8, res.stdout, "\"analog-input-front-mic\"")) |idx| {
        const slice_end = @min(idx + 500, res.stdout.len);
        if (std.mem.indexOf(u8, res.stdout[idx..slice_end], "\"available\": \"yes\"") != null) {
            info.front_mic_plugged = true;
        }
    }
}

pub fn detectJacks(allocator: std.mem.Allocator) JackInfo {
    var info = JackInfo{
        .rear_out_plugged = false,
        .rear_mic_plugged = false,
        .front_hp_plugged = false,
        .front_mic_plugged = false,
    };

    var card_buf: [8]u8 = undefined;
    const card = alsa.detectPrimaryCard(&card_buf);

    if (detectJacksFromAlsa(allocator, card, &info)) {
        return info;
    }

    if (detectJacksFromProcfs(allocator, card, &info)) {
        return info;
    }

    detectJacksFromPipeWire(allocator, &info);
    return info;
}

pub fn printJackStatus(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);
    const jacks = detectJacks(allocator);

    ui.printSection(stdout, tr.jacks_title);

    const rear_color = if (jacks.rear_out_plugged) ui.bold_green else ui.dim;
    stdout.print("{s}{s}{s}{s}\n", .{ tr.jack_lineout, rear_color, if (jacks.rear_out_plugged) tr.jack_plugged else tr.jack_unplugged, ui.reset }) catch {};

    const rear_mic_color = if (jacks.rear_mic_plugged) ui.bold_green else ui.dim;
    stdout.print("{s}{s}{s}{s}\n", .{ tr.jack_rearmic, rear_mic_color, if (jacks.rear_mic_plugged) tr.jack_plugged else tr.jack_unplugged, ui.reset }) catch {};

    const front_hp_color = if (jacks.front_hp_plugged) ui.bold_green else ui.dim;
    stdout.print("{s}{s}{s}{s}\n", .{ tr.jack_frontheadphone, front_hp_color, if (jacks.front_hp_plugged) tr.jack_plugged else tr.jack_unplugged, ui.reset }) catch {};

    const front_mic_color = if (jacks.front_mic_plugged) ui.bold_green else ui.dim;
    stdout.print("{s}{s}{s}{s}\n", .{ tr.jack_frontmic, front_mic_color, if (jacks.front_mic_plugged) tr.jack_plugged else tr.jack_unplugged, ui.reset }) catch {};
}

