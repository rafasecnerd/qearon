const std = @import("std");
const sys = @import("sys.zig");
const ui = @import("ui.zig");
const i18n = @import("i18n.zig");

pub fn migrateAllStreams(allocator: std.mem.Allocator, target_sink: []const u8, tr: *const i18n.Strings) void {
    const stdout = std.io.getStdOut().writer();

    const res = sys.runCapture(allocator, &[_][]const u8{ "pactl", "list", "sink-inputs", "short" }) catch {
        return;
    };
    defer allocator.free(res.stdout);
    defer allocator.free(res.stderr);

    var count: usize = 0;
    var lines = std.mem.splitScalar(u8, res.stdout, '\n');

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) {
            continue;
        }

        var parts = std.mem.splitScalar(u8, trimmed, '\t');
        const stream_id = parts.next() orelse continue;

        const moved = sys.runSilent(allocator, &[_][]const u8{ "pactl", "move-sink-input", stream_id, target_sink });
        if (moved) {
            count += 1;
        }
    }

    if (count > 0) {
        stdout.print("  {s}→{s} {s}{d}{s} {s} {s}{s}{s}\n", .{ ui.bold_cyan, ui.reset, ui.bold_yellow, count, ui.reset, tr.streams_migrated, ui.cyan, target_sink, ui.reset }) catch {};
    }
}

