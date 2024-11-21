const std = @import("std");
const dir = std.fs.cwd();
const Error = error{ FileNotFound, PermissionDenied, InvalidInput };

pub fn getRegName(bufval: u8, mask: u8, w: bool, name: *[2]u8) !void {
    if (w) {
        @memcpy(name, switch (bufval & mask) {
            0b00_000_000 => "ax",
            0b00_000_001 => "cx",
            0b00_000_010 => "dx",
            0b00_000_011 => "bx",
            0b00_000_100 => "sp",
            0b00_000_101 => "bp",
            0b00_000_110 => "si",
            0b00_000_111 => "di",
            else => unreachable,
        });
    } else {
        @memcpy(name, switch (bufval & mask) {
            0b00_000_000 => "al",
            0b00_000_001 => "cl",
            0b00_000_010 => "dl",
            0b00_000_011 => "bl",
            0b00_000_100 => "ah",
            0b00_000_101 => "ch",
            0b00_000_110 => "dh",
            0b00_000_111 => "bh",
            else => unreachable,
        });
    }
}

pub fn main() !void {
    const file_path = "Asm_files/listing_0038_many_register_mov";
    var file = try dir.openFile(file_path, .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();

    const write_file_path = "Asm_files/output_0038.asm";
    var write_file = try dir.createFile(write_file_path, .{ .truncate = true });

    try write_file.writer().print("bits 16\n\n", .{});
    defer write_file.close();

    var buf: [1]u8 = undefined;

    while (try stream.read(&buf) > 0) {
        std.debug.print("{b} {b}\n", .{ buf[0], buf[1] });

        var opcode: [3]u8 = undefined;
        const bitmask = 0b111111_0_0;
        const mov = 0b100010_00;

        if ((buf[0] & bitmask) == mov) {
            opcode = "mov".*;
        }

        const d_mask: u8 = 0b000000_1_0;
        const w_mask: u8 = 0b000000_0_1;
        var d: bool = undefined;
        var w: bool = undefined;

        d = buf[0] & d_mask > 0;
        w = buf[0] & w_mask > 0;

        var reg = [_]u8{ 0, 0 };
        var rm = [_]u8{ 0, 0 };

        const reg_mask = 0b00_111_000;
        const regbuf: u8 = (buf[1] >> 3) & 0b00000_111;
        const rm_mask = 0b00_000_111;
        std.debug.print("{b}\n", .{regbuf});

        try getRegName(regbuf, reg_mask, w, &reg);

        try getRegName(buf[1], rm_mask, w, &rm);

        if (d) {
            try write_file.writer().print("{s} {s},{s}\n", .{ opcode, rm, reg });
        } else {
            try write_file.writer().print("{s} {s},{s}\n", .{ opcode, rm, reg });
        }
    }
}
