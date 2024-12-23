const std = @import("std");
const dir = std.fs.cwd();
const Error = error{ FileNotFound, PermissionDenied, InvalidInput };
const FileReader = std.fs.File.Reader;
const BufferedReaderType = std.io.BufferedReader(1024, FileReader);

pub fn regmem_to_reg(stream: *BufferedReaderType, buf: [1]u8, write_file: *std.io.AnyWriter) !void {
    const d_mask: u8 = 0b000000_1_0;
    const w_mask: u8 = 0b000000_0_1;
    var d: bool = undefined;
    var w: bool = undefined;

    d = buf[0] & d_mask > 0;
    w = buf[0] & w_mask > 0;

    var buf_local: [1]u8 = undefined;
    _ = try stream.read(&buf_local);

    var reg = [_]u8{ 0, 0 };
    var rm = [_]u8{ 0, 0 };

    const mod_mask = 0b11_000000;
    const reg_mask = 0b00_111_000;
    const regbuf: u8 = (buf[0] >> 3) & 0b00000_111;
    const rm_mask = 0b00_000_111;

    try default_reg(regbuf, reg_mask, w, &reg);

    switch (buf[0] & mod_mask) {
        0b11_000000 => default_reg(buf[0], rm_mask, w, &rm),
        0b00_000000 => mem_no_disp(buf[0], rm_mask, &rm, stream),
        0b01_000000 => mem_8_disp(buf[0], rm_mask, &rm, stream),
        0b10_000000 => mem_16_disp(buf[0], rm_mask, &rm, stream),
    }

    if (d) {
        try write_file.writer().print("mov {},{}\n", .{ rm, reg });
    } else {
        try write_file.writer().print("mov {},{}\n", .{ reg, rm });
    }
}

pub fn direct_addressing(stream: *BufferedReaderType, disp_flag: bool) ![]u8 {
    const result: comptime_int = undefined;
    if (disp_flag) {
        var buf: [1]u8 = undefined;
        _ = try stream.read(&buf);
        @memcpy(result, buf);
    } else {
        var buf: [2]u8 = undefined;
        _ = try stream.read(&buf);
        @memcpy(result, buf);
    }
    return result;
}
pub fn mem_no_disp(bufval: u8, mask: u8, name: *[2]u8, stream: *BufferedReaderType) !void {
    var buffer: [64]u8 = undefined; // Allocate a temporary buffer for the formatted string
    const writer = std.fmt.makeBufferWriter(&buffer);
    const displacementfalse = try direct_addressing(stream, false);
    @memcpy(name, switch (bufval & mask) {
        0b00_000_000 => "[bx + si]",
        0b00_000_001 => "[bx + di]",
        0b00_000_010 => "[bp + si]",
        0b00_000_011 => "[bp + di]",
        0b00_000_100 => "[si]",
        0b00_000_101 => "[di]",
        0b00_000_111 => "[bx]",
        else => unreachable,
    });
    if (bufval & mask == 0b00_000_110) {
        writer.print("[{}]", .{displacementfalse});
    }

    const result = writer.toSlice();
    @memcpy(name, result[0..std.math.min(name.len, result.len)]);
}
pub fn mem_8_disp(bufval: u8, mask: u8, name: *[2]u8, stream: *BufferedReaderType) !void {
    var buffer: [64]u8 = undefined; // Allocate a temporary buffer for the formatted string

    const writer = std.fmt.makeBufferWriter(&buffer);
    const displacementtrue = try direct_addressing(stream, true);
    try switch (bufval & mask) {
        0b00_000_000 => writer.print("[bx + si + {}]", .{displacementtrue}),
        0b00_000_001 => writer.print("[bx + di + {}]", .{displacementtrue}),
        0b00_000_010 => writer.print("[bx + di + {}]", .{displacementtrue}),
        0b00_000_011 => writer.print("[bx + di + {}]", .{displacementtrue}),
        0b00_000_100 => writer.print("[si + {}]", .{displacementtrue}),
        0b00_000_101 => writer.print("[di + {}]", .{displacementtrue}),
        0b00_000_110 => writer.print("[bp + {}]", .{displacementtrue}),
        0b00_000_111 => writer.print("[bx + {}]", .{displacementtrue}),
        else => unreachable,
    };
    // Ensure the result fits into `name`, truncate or handle overflow appropriately
    const result = writer.toSlice();
    @memcpy(name, result[0..std.math.min(name.len, result.len)]);
}
pub fn mem_16_disp(bufval: u8, mask: u8, name: *[2]u8, stream: *BufferedReaderType) !void {
    var buffer: [64]u8 = undefined; // Allocate a temporary buffer for the formatted string
    const writer = std.fmt.makeBufferWriter(&buffer);
    const displacementfalse = try direct_addressing(stream, false);
    try switch (bufval & mask) {
        0b00_000_000 => writer.print("[bx + si + {}]", .{displacementfalse}),
        0b00_000_001 => writer.print("[bx + di + {}]", .{displacementfalse}),
        0b00_000_010 => writer.print("[bx + di + {}]", .{displacementfalse}),
        0b00_000_011 => writer.print("[bx + di + {}]", .{displacementfalse}),
        0b00_000_100 => writer.print("[si + {}]", .{displacementfalse}),
        0b00_000_101 => writer.print("[di + {}]", .{displacementfalse}),
        0b00_000_110 => writer.print("[bp + {}]", .{displacementfalse}),
        0b00_000_111 => writer.print("[bx + {}]", .{displacementfalse}),
        else => unreachable,
    }; // Ensure the result fits into `name`, truncate or handle overflow appropriately
    const result = writer.toSlice();
    @memcpy(name, result[0..std.math.min(name.len, result.len)]);
}
pub fn default_reg(bufval: u8, mask: u8, w: bool, name: *[2]u8) !void {
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
//pub fn imm_to_reg(stream:*BufferedReaderType, buf:[1]u8, write_file:*std.io.Writer) !void{

pub fn main() !void {
    const file_path = "Asm_files/listing_0039_more_mov";
    var file = try dir.openFile(file_path, .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var stream = buf_reader.reader();

    const write_file_path = "Asm_files/output_0039.asm";
    var write_file = try dir.createFile(write_file_path, .{ .truncate = true });

    try write_file.writer().print("bits 16\n\n", .{});
    defer write_file.close();

    var buf: [1]u8 = undefined;

    _ = try stream.read(&buf);
    std.debug.print("{b} \n", .{buf[0]});

    //       var opcode: [3]u8 = undefined;
    const opcode_bitmask: u8 = 0b111111_00;
    //       const imm_to_reg_bitmask:u8 = 0b1111_0000;

    // if(buf[0]&imm_to_reg_bitmask == 0b1011_0000){
    //     imm_to_reg(&stream,buf, &write_file);
    //}

    switch (buf[0] & opcode_bitmask) {
        0b100010_00 => regmem_to_reg(&stream, buf, &write_file),
        // 0b110001_00 => immediate_to_regmem(&stream,buf, &write_file),
        // 0b101000_00 => acc_to_mem(&stream, buf, &write_file),
        //0b100011_00 => regmem_to_segreg(&stream,buf,&write_file),
        else => unreachable,
    }
}
