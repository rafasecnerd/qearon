const std = @import("std");
const i18n = @import("i18n.zig");
const ui = @import("ui.zig");

const buffer_samples: usize = 800;
const wing_blocks: usize = 12;

pub fn runVuMeter(allocator: std.mem.Allocator) void {
    const stdout = std.io.getStdOut().writer();
    const tr = i18n.getStrings(allocator);

    ui.printBanner(stdout, tr.vu_title);
    stdout.print("{s}{s}{s}\n", .{ ui.dim, tr.vu_speak, ui.reset }) catch {};
    stdout.print("{s}{s}{s}\n\n", .{ ui.dim, tr.vu_stop, ui.reset }) catch {};

    const argv = [_][]const u8{
        "pw-record",
        "--format=s16",
        "--channels=1",
        "--rate=16000",
        "-",
    };

    var child = std.process.Child.init(&argv, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Ignore;

    child.spawn() catch {
        ui.printErr(stdout, tr.vu_err);
        return;
    };

    const stdout_pipe = child.stdout orelse {
        ui.printErr(stdout, tr.vu_pipe_err);
        _ = child.kill() catch {};
        return;
    };

    var raw_buf: [buffer_samples * 2]u8 = undefined;

    while (true) {
        var bytes_read: usize = 0;
        while (bytes_read < raw_buf.len) {
            const n = stdout_pipe.read(raw_buf[bytes_read..]) catch 0;
            if (n == 0) {
                break;
            }
            bytes_read += n;
        }

        if (bytes_read == 0) {
            break;
        }

        const total_samples = bytes_read / 2;
        if (total_samples == 0) continue;

        var sum_sq: u64 = 0;
        var peak: u32 = 0;
        var i: usize = 0;

        while (i < total_samples) : (i += 1) {
            const b0: u16 = raw_buf[i * 2];
            const b1: u16 = raw_buf[i * 2 + 1];
            const sample_u: u16 = b0 | (b1 << 8);
            const sample: i16 = @bitCast(sample_u);
            const sample_i32: i32 = sample;
            const abs_sample: u32 = @intCast(if (sample_i32 < 0) -sample_i32 else sample_i32);

            if (abs_sample > peak) {
                peak = abs_sample;
            }

            const s_u64: u64 = abs_sample;
            sum_sq += s_u64 * s_u64;
        }

        const mean_sq = sum_sq / total_samples;
        const rms_u64: u64 = std.math.sqrt(mean_sq);
        const rms: u32 = @min(@as(u32, @truncate(rms_u64)), 32767);
        const peak_u32: u32 = @min(peak, 32767);

        const filled_blocks: usize = @intCast((rms * wing_blocks) / 32767);
        const percentage: u32 = (rms * 100) / 32767;
        const peak_pct: u32 = (peak_u32 * 100) / 32767;

        stdout.print("\r\x1b[K{s}{s}{s} <[ ", .{ ui.bold_cyan, tr.vu_mic_label, ui.reset }) catch {};

        var lb: usize = 0;
        while (lb < wing_blocks) : (lb += 1) {
            const dist_from_center = wing_blocks - 1 - lb;
            if (dist_from_center < filled_blocks) {
                if (dist_from_center > 9) {
                    stdout.print("{s}|{s}", .{ ui.red, ui.reset }) catch {};
                } else if (dist_from_center > 6) {
                    stdout.print("{s}|{s}", .{ ui.yellow, ui.reset }) catch {};
                } else {
                    stdout.print("{s}|{s}", .{ ui.green, ui.reset }) catch {};
                }
            } else {
                stdout.print("{s}.{s}", .{ ui.dim, ui.reset }) catch {};
            }
        }

        stdout.print(" {s}▲{s} ", .{ ui.bold_cyan, ui.reset }) catch {};

        var rb: usize = 0;
        while (rb < wing_blocks) : (rb += 1) {
            if (rb < filled_blocks) {
                if (rb > 9) {
                    stdout.print("{s}|{s}", .{ ui.red, ui.reset }) catch {};
                } else if (rb > 6) {
                    stdout.print("{s}|{s}", .{ ui.yellow, ui.reset }) catch {};
                } else {
                    stdout.print("{s}|{s}", .{ ui.green, ui.reset }) catch {};
                }
            } else {
                stdout.print("{s}.{s}", .{ ui.dim, ui.reset }) catch {};
            }
        }

        stdout.print(" ]> RMS: {s}{d:2}%{s} (Pk:{s}{d:2}%{s}) ", .{
            ui.bold_white,
            percentage,
            ui.reset,
            ui.dim,
            peak_pct,
            ui.reset,
        }) catch {};

        if (percentage > 70 or peak_pct > 90) {
            stdout.print("{s}{s}{s}", .{ ui.red, tr.vu_status_loud, ui.reset }) catch {};
        } else if (percentage > 5 or peak_pct > 12) {
            stdout.print("{s}{s}{s}", .{ ui.green, tr.vu_status_ok, ui.reset }) catch {};
        } else {
            stdout.print("{s}{s}{s}", .{ ui.dim, tr.vu_status_silence, ui.reset }) catch {};
        }
    }

    _ = child.wait() catch {};
    stdout.print("\n", .{}) catch {};
}

