const std = @import("std");
const sys = @import("sys.zig");
const i18n = @import("i18n.zig");
const ui = @import("ui.zig");

pub fn setDefaultSink(allocator: std.mem.Allocator, sink_id_or_name: []const u8) bool {
    return sys.runSilent(allocator, &[_][]const u8{ "wpctl", "set-default", sink_id_or_name });
}

pub fn setDefaultSource(allocator: std.mem.Allocator, source_id_or_name: []const u8) bool {
    return sys.runSilent(allocator, &[_][]const u8{ "wpctl", "set-default", source_id_or_name });
}

pub fn setSinkVolume(allocator: std.mem.Allocator, sink_id_or_name: []const u8, volume: []const u8) bool {
    return sys.runSilent(allocator, &[_][]const u8{ "wpctl", "set-volume", sink_id_or_name, volume });
}

pub fn setSourceVolume(allocator: std.mem.Allocator, source_id_or_name: []const u8, volume: []const u8) bool {
    return sys.runSilent(allocator, &[_][]const u8{ "wpctl", "set-volume", source_id_or_name, volume });
}

pub fn setSinkRoute(allocator: std.mem.Allocator, card_device_id: []const u8, route_index: []const u8) bool {
    return sys.runSilent(allocator, &[_][]const u8{ "wpctl", "set-route", card_device_id, route_index });
}

pub fn findAnalogSinkId(allocator: std.mem.Allocator) ?[]const u8 {
    return findNodeIdByCriteria(allocator, "Sinks:", "Analog Stereo");
}

pub fn findAnalogSourceId(allocator: std.mem.Allocator) ?[]const u8 {
    return findNodeIdByCriteria(allocator, "Sources:", "Analog Stereo");
}

pub fn findHdmiSinkId(allocator: std.mem.Allocator) ?[]const u8 {
    if (findNodeIdByCriteria(allocator, "Sinks:", "HDMI")) |id| return id;
    return findNodeIdByCriteria(allocator, "Sinks:", "Digital Stereo");
}

pub fn findAudioCardDeviceId(allocator: std.mem.Allocator) ?[]const u8 {
    const res = sys.runCapture(allocator, &[_][]const u8{ "wpctl", "status" }) catch return null;
    defer allocator.free(res.stderr);

    var lines = std.mem.splitScalar(u8, res.stdout, '\n');
    var in_devices = false;

    while (lines.next()) |line| {
        if (std.mem.indexOf(u8, line, "Devices:") != null) {
            in_devices = true;
            continue;
        }

        if (std.mem.indexOf(u8, line, "Sinks:") != null or
            std.mem.indexOf(u8, line, "Sources:") != null or
            std.mem.indexOf(u8, line, "Video") != null)
        {
            in_devices = false;
            continue;
        }

        if (in_devices and (std.mem.indexOf(u8, line, "[alsa]") != null or std.mem.indexOf(u8, line, "Áudio") != null or std.mem.indexOf(u8, line, "Audio") != null)) {
            const trimmed = std.mem.trim(u8, line, " │* \t\r");
            var parts = std.mem.splitScalar(u8, trimmed, '.');
            if (parts.next()) |id_str| {
                const clean_id = std.mem.trim(u8, id_str, " ");
                const allocated = allocator.dupe(u8, clean_id) catch return null;
                allocator.free(res.stdout);
                return allocated;
            }
        }
    }

    allocator.free(res.stdout);
    return null;
}

pub fn findRouteIndex(allocator: std.mem.Allocator, card_device_id: []const u8, route_name: []const u8) ?[]const u8 {
    const res = sys.runCapture(allocator, &[_][]const u8{ "pw-dump", card_device_id }) catch return null;
    defer allocator.free(res.stdout);
    defer allocator.free(res.stderr);

    const match_str = route_name;
    const pos = std.mem.indexOf(u8, res.stdout, match_str) orelse return null;

    const start: usize = if (pos > 250) pos - 250 else 0;
    const window = res.stdout[start..pos];

    if (std.mem.lastIndexOf(u8, window, "\"index\":")) |idx_pos| {
        const after = window[idx_pos + 8 ..];
        const trimmed = std.mem.trim(u8, after, " \t\r\n:,");
        var num_len: usize = 0;
        while (num_len < trimmed.len and std.ascii.isDigit(trimmed[num_len])) : (num_len += 1) {}
        if (num_len > 0) {
            return allocator.dupe(u8, trimmed[0..num_len]) catch null;
        }
    }

    return null;
}

fn findNodeIdByCriteria(allocator: std.mem.Allocator, section_name: []const u8, keyword: []const u8) ?[]const u8 {
    const res = sys.runCapture(allocator, &[_][]const u8{ "wpctl", "status" }) catch return null;
    defer allocator.free(res.stderr);

    var lines = std.mem.splitScalar(u8, res.stdout, '\n');
    var in_audio = false;
    var in_section = false;

    while (lines.next()) |line| {
        if (std.mem.indexOf(u8, line, "Audio") != null) {
            in_audio = true;
            continue;
        }

        if (std.mem.indexOf(u8, line, "Video") != null or std.mem.indexOf(u8, line, "Settings") != null) {
            break;
        }

        if (!in_audio) continue;

        if (std.mem.indexOf(u8, line, section_name) != null) {
            in_section = true;
            continue;
        }

        if (in_section and (std.mem.indexOf(u8, line, "Sinks:") != null or
            std.mem.indexOf(u8, line, "Sources:") != null or
            std.mem.indexOf(u8, line, "Filters:") != null or
            std.mem.indexOf(u8, line, "Streams:") != null))
        {
            in_section = false;
            continue;
        }

        if (in_section and std.mem.indexOf(u8, line, keyword) != null) {
            const trimmed = std.mem.trim(u8, line, " │* \t\r");
            var parts = std.mem.splitScalar(u8, trimmed, '.');
            if (parts.next()) |id_str| {
                const clean_id = std.mem.trim(u8, id_str, " ");
                const allocated = allocator.dupe(u8, clean_id) catch return null;
                allocator.free(res.stdout);
                return allocated;
            }
        }
    }

    allocator.free(res.stdout);
    return null;
}

pub fn printPipeWireStatus(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    stdout.print("\n", .{}) catch {};
    ui.printSection(stdout, tr.pw_title);

    const res = sys.runCapture(allocator, &[_][]const u8{ "wpctl", "status" }) catch {
        ui.printErr(stdout, tr.pw_err);
        return;
    };
    defer allocator.free(res.stdout);
    defer allocator.free(res.stderr);

    var lines = std.mem.splitScalar(u8, res.stdout, '\n');
    var in_audio = false;
    var section_sinks = false;
    var section_sources = false;

    while (lines.next()) |line| {
        if (std.mem.indexOf(u8, line, "Audio") != null) {
            in_audio = true;
            continue;
        }

        if (std.mem.indexOf(u8, line, "Video") != null or std.mem.indexOf(u8, line, "Settings") != null) {
            break;
        }

        if (!in_audio) continue;

        if (std.mem.indexOf(u8, line, "Sinks:") != null) {
            section_sinks = true;
            section_sources = false;
            stdout.print("{s}{s}{s}\n", .{ ui.bold_yellow, tr.pw_outputs, ui.reset }) catch {};
            continue;
        }

        if (std.mem.indexOf(u8, line, "Sources:") != null) {
            section_sinks = false;
            section_sources = true;
            stdout.print("{s}{s}{s}\n", .{ ui.bold_yellow, tr.pw_inputs, ui.reset }) catch {};
            continue;
        }

        if (std.mem.indexOf(u8, line, "Filters:") != null or std.mem.indexOf(u8, line, "Streams:") != null) {
            section_sinks = false;
            section_sources = false;
            continue;
        }

        if (section_sinks or section_sources) {
            const trimmed = std.mem.trim(u8, line, " │\t\r");
            if (trimmed.len > 0) {
                const is_active = std.mem.indexOf(u8, trimmed, "*") != null;
                if (is_active) {
                    stdout.print("    {s}{s}{s}\n", .{ ui.bold_green, trimmed, ui.reset }) catch {};
                } else {
                    stdout.print("    {s}{s}{s}\n", .{ ui.dim, trimmed, ui.reset }) catch {};
                }
            }
        }
    }
}
