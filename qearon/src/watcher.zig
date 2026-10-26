const std = @import("std");
const detector = @import("detector.zig");
const autofix = @import("autofix.zig");
const i18n = @import("i18n.zig");
const ui = @import("ui.zig");

const sleep_duration_ns: u64 = 1 * std.time.ns_per_s;

pub fn startWatcher(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    ui.printBanner(stdout, tr.watch_title);
    stdout.print("{s}{s}{s}\n", .{ ui.dim, tr.watch_line1, ui.reset }) catch {};
    stdout.print("{s}{s}{s}\n", .{ ui.dim, tr.watch_line2, ui.reset }) catch {};
    stdout.print("{s}{s}{s}\n\n", .{ ui.dim, tr.watch_line3, ui.reset }) catch {};

    var last_state = detector.detectJacks(allocator);

    while (true) {
        std.time.sleep(sleep_duration_ns);

        const current_state = detector.detectJacks(allocator);

        const rear_plugged_now = current_state.rear_out_plugged and !last_state.rear_out_plugged;
        const front_hp_plugged_now = current_state.front_hp_plugged and !last_state.front_hp_plugged;
        const mic_plugged_now = (current_state.rear_mic_plugged and !last_state.rear_mic_plugged) or
            (current_state.front_mic_plugged and !last_state.front_mic_plugged);

        if (rear_plugged_now or front_hp_plugged_now or mic_plugged_now) {
            stdout.print("{s}{s}{s}", .{ ui.bold_yellow, tr.watch_trigger, ui.reset }) catch {};
            _ = autofix.runAutofixEx(allocator, true);
            stdout.print("{s}{s}{s}", .{ ui.dim, tr.watch_resume, ui.reset }) catch {};
        }

        last_state = current_state;
    }
}
