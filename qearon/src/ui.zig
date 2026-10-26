const std = @import("std");
const i18n = @import("i18n.zig");

pub const reset = "\x1b[0m";
pub const bold = "\x1b[1m";
pub const dim = "\x1b[2m";

pub const red = "\x1b[31m";
pub const green = "\x1b[32m";
pub const yellow = "\x1b[33m";
pub const blue = "\x1b[34m";
pub const magenta = "\x1b[35m";
pub const cyan = "\x1b[36m";
pub const white = "\x1b[37m";

pub const bold_red = "\x1b[1;31m";
pub const bold_green = "\x1b[1;32m";
pub const bold_yellow = "\x1b[1;33m";
pub const bold_blue = "\x1b[1;34m";
pub const bold_magenta = "\x1b[1;35m";
pub const bold_cyan = "\x1b[1;36m";
pub const bold_white = "\x1b[1;37m";

const wave_symbol = "ıllıllııllıllı";

const spectrum_colors = [_][]const u8{
    "\x1b[36m",
    "\x1b[1;36m",
    "\x1b[34m",
    "\x1b[1;34m",
    "\x1b[35m",
    "\x1b[1;35m",
    "\x1b[31m",
    "\x1b[1;31m",
    "\x1b[33m",
    "\x1b[1;33m",
    "\x1b[32m",
    "\x1b[1;32m",
};

const spinner_frames = [_][]const u8{
    "[ - ]",
    "[ \\ ]",
    "[ | ]",
    "[ / ]",
};

const ascii_logo =
    \\  ██████╗ ███████╗ █████╗ ██████╗  ██████╗ ███╗   ██╗
    \\ ██╔═══██╗██╔════╝██╔══██╗██╔══██╗██╔═══██╗████╗  ██║
    \\ ██║   ██║█████╗  ███████║██████╔╝██║   ██║██╔██╗ ██║
    \\ ██║▄▄ ██║██╔══╝  ██╔══██║██╔══██╗██║   ██║██║╚██╗██║
    \\ ╚██████╔╝███████╗██║  ██║██║  ██║╚██████╔╝██║ ╚████║
    \\  ╚══▀▀═╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
;

pub fn printColoredWave(writer: anytype) void {
    const view = std.unicode.Utf8View.init(wave_symbol) catch return;
    var it = view.iterator();
    var idx: usize = 0;

    while (it.nextCodepointSlice()) |slice| {
        const color = spectrum_colors[idx % spectrum_colors.len];
        writer.print("{s}{s}", .{ color, slice }) catch {};
        idx += 1;
    }

    writer.print("{s}", .{reset}) catch {};
}

pub fn printLogo(writer: anytype) void {
    writer.print("\n{s}{s}{s}\n", .{ cyan, ascii_logo, reset }) catch {};
    writer.print("                    ", .{}) catch {};
    printColoredWave(writer);
    writer.print("\n\n", .{}) catch {};
}

pub fn printBanner(writer: anytype, title: []const u8) void {
    writer.print("{s}┌────────────────────────────────────────────────────────┐{s}\n", .{ bold_cyan, reset }) catch {};
    writer.print("{s}│{s} {s}{s:^54}{s} {s}│{s}\n", .{ bold_cyan, reset, bold_white, title, reset, bold_cyan, reset }) catch {};
    writer.print("{s}└────────────────────────────────────────────────────────┘{s}\n", .{ bold_cyan, reset }) catch {};
    writer.print("                      ", .{}) catch {};
    printColoredWave(writer);
    writer.print("\n\n", .{}) catch {};
}

pub fn printSection(writer: anytype, title: []const u8) void {
    writer.print("{s}:: {s}{s}{s}\n", .{ bold_cyan, bold_white, title, reset }) catch {};
}

pub fn printStep(writer: anytype, current: usize, total: usize, desc: []const u8) void {
    writer.print("{s}[{d}/{d}]{s} {s}{s}{s}\n", .{ bold_cyan, current, total, reset, bold_white, desc, reset }) catch {};
}

pub fn printOk(writer: anytype, msg: []const u8) void {
    writer.print("{s}[OK]{s} {s}{s}{s}\n", .{ bold_green, reset, bold_white, msg, reset }) catch {};
}

pub fn printWarn(writer: anytype, msg: []const u8) void {
    writer.print("{s}[WARN]{s} {s}{s}{s}\n", .{ bold_yellow, reset, yellow, msg, reset }) catch {};
}

pub fn printErr(writer: anytype, msg: []const u8) void {
    writer.print("{s}[ERR]{s} {s}{s}{s}\n", .{ bold_red, reset, red, msg, reset }) catch {};
}

pub fn playSpinner(writer: anytype, label: []const u8, iterations: usize) void {
    var i: usize = 0;
    while (i < iterations) : (i += 1) {
        const frame = spinner_frames[i % spinner_frames.len];
        writer.print("\r{s}{s}{s} {s}{s}{s}", .{ bold_cyan, frame, reset, dim, label, reset }) catch {};
        std.time.sleep(70 * std.time.ns_per_ms);
    }
    writer.print("\r\x1b[K", .{}) catch {};
}

fn printCmd(writer: anytype, cmd: []const u8, desc: []const u8) void {
    writer.print("  {s}{s: <26}{s} {s}{s}{s}\n", .{ bold_white, cmd, reset, dim, desc, reset }) catch {};
}

fn printExample(writer: anytype, cmd: []const u8, desc: []const u8) void {
    writer.print("  {s}{s: <26}{s} {s}# {s}{s}\n", .{ bold_cyan, cmd, reset, dim, desc, reset }) catch {};
}

pub fn printUsage(writer: anytype, tr: *const i18n.Strings) void {
    writer.print("{s}{s}{s} {s}qearon{s} {s}{s}{s} {s}{s}{s}\n\n", .{ bold, tr.help_header_usage, reset, bold_cyan, reset, bold_yellow, tr.help_usage_cmd, reset, yellow, tr.help_usage_opt, reset }) catch {};

    printSection(writer, tr.help_sec_repair);
    printCmd(writer, tr.help_cmd_autofix, tr.help_desc_autofix);
    printCmd(writer, tr.help_cmd_headset, tr.help_desc_headset);
    printCmd(writer, tr.help_cmd_hdmi, tr.help_desc_hdmi);

    writer.print("\n", .{}) catch {};
    printSection(writer, tr.help_sec_mic);
    printCmd(writer, tr.help_cmd_vu, tr.help_desc_vu);
    printCmd(writer, tr.help_cmd_loopback, tr.help_desc_loopback);
    printCmd(writer, tr.help_cmd_denoise, tr.help_desc_denoise);

    writer.print("\n", .{}) catch {};
    printSection(writer, tr.help_sec_diag);
    printCmd(writer, tr.help_cmd_test_sound, tr.help_desc_test_sound);
    printCmd(writer, tr.help_cmd_test_mic, tr.help_desc_test_mic);
    printCmd(writer, tr.help_cmd_status, tr.help_desc_status);

    writer.print("\n", .{}) catch {};
    printSection(writer, tr.help_sec_system);
    printCmd(writer, tr.help_cmd_watch, tr.help_desc_watch);
    printCmd(writer, tr.help_cmd_install, tr.help_desc_install);
    printCmd(writer, tr.help_cmd_lang, tr.help_desc_lang);
    printCmd(writer, tr.help_cmd_help, tr.help_desc_help);

    writer.print("\n", .{}) catch {};
    printSection(writer, tr.help_sec_examples);
    printExample(writer, tr.help_ex1_cmd, tr.help_ex1_desc);
    printExample(writer, tr.help_ex2_cmd, tr.help_ex2_desc);
    printExample(writer, tr.help_ex3_cmd, tr.help_ex3_desc);
    writer.print("\n", .{}) catch {};
}
