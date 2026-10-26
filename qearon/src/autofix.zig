const std = @import("std");
const alsa = @import("alsa.zig");
const pipewire = @import("pipewire.zig");
const detector = @import("detector.zig");
const streams = @import("streams.zig");
const tester = @import("tester.zig");
const i18n = @import("i18n.zig");
const ui = @import("ui.zig");

pub fn runAutofixEx(allocator: std.mem.Allocator, skip_sound_test: bool) bool {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);
    var has_warnings = false;

    ui.printBanner(stdout, tr.autofix_title);

    ui.printStep(stdout, 1, 6, tr.autofix_step1);
    ui.playSpinner(stdout, tr.autofix_spinner_scan, 6);
    const jacks = detector.detectJacks(allocator);

    if (jacks.rear_out_plugged) {
        stdout.print("  {s}→{s} {s}{s}{s}\n", .{ ui.bold_cyan, ui.reset, ui.green, tr.autofix_jack_rear, ui.reset }) catch {};
    } else if (jacks.front_hp_plugged) {
        stdout.print("  {s}→{s} {s}{s}{s}\n", .{ ui.bold_cyan, ui.reset, ui.green, tr.autofix_jack_front, ui.reset }) catch {};
    } else {
        stdout.print("  {s}→{s} {s}{s}{s}\n", .{ ui.bold_cyan, ui.reset, ui.yellow, tr.autofix_jack_hybrid, ui.reset }) catch {};
    }

    stdout.print("\n", .{}) catch {};
    ui.printStep(stdout, 2, 6, tr.autofix_step2);
    ui.playSpinner(stdout, tr.autofix_spinner_alsa, 6);

    var card_buf: [8]u8 = undefined;
    const card = alsa.detectPrimaryCard(&card_buf);
    const prefer_front_mic = jacks.front_mic_plugged and !jacks.rear_mic_plugged;
    const out_ok = alsa.unmuteOutputs(allocator, card);
    const in_ok = alsa.unmuteInputs(allocator, card, prefer_front_mic);

    if (out_ok and in_ok) {
        stdout.print("  {s}→{s} {s}{s}{s}\n", .{ ui.bold_cyan, ui.reset, ui.green, tr.autofix_alsa_unmuted, ui.reset }) catch {};
    } else {
        stdout.print("  ", .{}) catch {};
        ui.printWarn(stdout, tr.autofix_alsa_warn);
        has_warnings = true;
    }

    stdout.print("\n", .{}) catch {};
    ui.printStep(stdout, 3, 6, tr.autofix_step3);
    ui.playSpinner(stdout, tr.autofix_spinner_route, 6);

    const maybe_sink_id = pipewire.findAnalogSinkId(allocator);
    const maybe_source_id = pipewire.findAnalogSourceId(allocator);
    const maybe_card_dev_id = pipewire.findAudioCardDeviceId(allocator);

    if (maybe_sink_id) |sink_id| {
        defer allocator.free(sink_id);
        _ = pipewire.setDefaultSink(allocator, sink_id);
        _ = pipewire.setSinkVolume(allocator, sink_id, "0.80");

        if (maybe_card_dev_id) |card_dev_id| {
            defer allocator.free(card_dev_id);

            if (jacks.front_hp_plugged and !jacks.rear_out_plugged) {
                const rt = pipewire.findRouteIndex(allocator, card_dev_id, "analog-output-headphones") orelse "4";
                _ = pipewire.setSinkRoute(allocator, card_dev_id, rt);
                stdout.print("  {s}→{s} {s}{s}{s}\n", .{ ui.bold_cyan, ui.reset, ui.green, tr.autofix_route_front, ui.reset }) catch {};
            } else {
                const rt = pipewire.findRouteIndex(allocator, card_dev_id, "analog-output-lineout") orelse "3";
                _ = pipewire.setSinkRoute(allocator, card_dev_id, rt);
                stdout.print("  {s}→{s} {s}{s}{s}\n", .{ ui.bold_cyan, ui.reset, ui.green, tr.autofix_route_rear, ui.reset }) catch {};
            }
        } else {
            stdout.print("  {s}→{s} {s}{s}{s}\n", .{ ui.bold_cyan, ui.reset, ui.green, tr.autofix_route_rear, ui.reset }) catch {};
        }
    } else {
        _ = pipewire.setSinkVolume(allocator, "@DEFAULT_AUDIO_SINK@", "0.80");
        stdout.print("  ", .{}) catch {};
        ui.printWarn(stdout, tr.autofix_pw_warn);
        has_warnings = true;
    }

    if (maybe_source_id) |source_id| {
        defer allocator.free(source_id);
        _ = pipewire.setDefaultSource(allocator, source_id);
        _ = pipewire.setSourceVolume(allocator, source_id, "0.80");
    } else {
        _ = pipewire.setSourceVolume(allocator, "@DEFAULT_AUDIO_SOURCE@", "0.80");
    }

    stdout.print("\n", .{}) catch {};
    ui.printStep(stdout, 4, 6, tr.autofix_step4);
    ui.playSpinner(stdout, tr.autofix_spinner_streams, 8);

    if (maybe_sink_id) |sink_id| {
        streams.migrateAllStreams(allocator, sink_id, tr);
    } else {
        streams.migrateAllStreams(allocator, "@DEFAULT_AUDIO_SINK@", tr);
    }

    stdout.print("\n", .{}) catch {};
    ui.printStep(stdout, 5, 6, tr.autofix_step5);
    const store_ok = alsa.saveAlsaState(allocator, card);
    if (!store_ok) {
        stdout.print("  ", .{}) catch {};
        ui.printWarn(stdout, tr.autofix_alsa_store_warn);
        has_warnings = true;
    }

    stdout.print("\n", .{}) catch {};
    ui.printStep(stdout, 6, 6, tr.autofix_step6);

    if (!skip_sound_test) {
        const sound_ok = tester.testSoundEmbed(allocator);
        if (!sound_ok) {
            has_warnings = true;
        }
    } else {
        ui.printOk(stdout, tr.test_stereo_done);
    }

    stdout.print("\n", .{}) catch {};
    if (!has_warnings) {
        ui.printOk(stdout, tr.autofix_success);
        stdout.print("     {s}{s}{s}\n", .{ ui.bold_cyan, tr.autofix_configured, ui.reset }) catch {};
        return true;
    } else {
        ui.printWarn(stdout, tr.autofix_partial);
        stdout.print("       {s}{s}{s}\n", .{ ui.bold_cyan, tr.autofix_configured, ui.reset }) catch {};
        return true;
    }
}

pub fn runAutofix(allocator: std.mem.Allocator) void {
    _ = runAutofixEx(allocator, false);
}

pub fn setHeadsetMode(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    ui.printSection(stdout, tr.headset_activating);

    var card_buf: [8]u8 = undefined;
    const card = alsa.detectPrimaryCard(&card_buf);
    _ = alsa.unmuteOutputs(allocator, card);
    _ = alsa.unmuteInputs(allocator, card, true);

    if (pipewire.findAnalogSinkId(allocator)) |sink_id| {
        defer allocator.free(sink_id);
        _ = pipewire.setDefaultSink(allocator, sink_id);
        _ = pipewire.setSinkVolume(allocator, sink_id, "0.80");
        streams.migrateAllStreams(allocator, sink_id, tr);
    } else {
        _ = pipewire.setSinkVolume(allocator, "@DEFAULT_AUDIO_SINK@", "0.80");
    }

    if (pipewire.findAnalogSourceId(allocator)) |source_id| {
        defer allocator.free(source_id);
        _ = pipewire.setDefaultSource(allocator, source_id);
        _ = pipewire.setSourceVolume(allocator, source_id, "0.80");
    }

    if (pipewire.findAudioCardDeviceId(allocator)) |card_dev_id| {
        defer allocator.free(card_dev_id);
        const rt = pipewire.findRouteIndex(allocator, card_dev_id, "analog-output-headphones") orelse "4";
        _ = pipewire.setSinkRoute(allocator, card_dev_id, rt);
    }

    _ = alsa.saveAlsaState(allocator, card);
    ui.printOk(stdout, tr.headset_ok);
}

pub fn setHdmiMode(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    ui.printSection(stdout, tr.hdmi_activating);

    if (pipewire.findHdmiSinkId(allocator)) |hdmi_id| {
        defer allocator.free(hdmi_id);
        _ = pipewire.setDefaultSink(allocator, hdmi_id);
        streams.migrateAllStreams(allocator, hdmi_id, tr);
        ui.printOk(stdout, tr.hdmi_ok);
    } else {
        ui.printWarn(stdout, tr.autofix_pw_warn);
    }
}

