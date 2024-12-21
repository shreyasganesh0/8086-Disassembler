const std = @import("std");
const dir = std.fs.cwd();
const Error = error{ FileNotFound, PermissionDenied, InvalidInput };

// Generic function to handle register-memory to register operations
pub fn regmem_to_reg(comptime Stream: type, comptime Writer: type) (
    stream: Stream,
    buf: [1]u8,
    writer: Writer
) !void {
    const d_mask: u8 = 0b00000010;
    const w_mask: u8 = 0b00000001;
    const mod_mask: u8 = 0b11000000;
    const reg_mask: u8 = 0b00111000;
    const rm_mask: u8 = 0b00000111;

    const d = (buf[0] & d_mask) != 0;
    const w = (buf[0] & w_mask) != 0;

    var buf_local: [1]u8 = undefined;
    _ = try stream.read(&buf_local);

    var reg: [16]u8 = undefined;
    var rm: [16]u8 = undefined;

    try default_reg(buf[0], reg_mask, w, &reg);

    _ = switch (buf[0] & mod_mask) {
        0b11000000 => try default_reg(buf[0], rm_mask, w, &rm),
        0b00000000 => try mem_no_disp(stream, buf[0], rm_mask, &rm),
        0b01000000 => try mem_8_disp(stream, buf[0], rm_mask, &rm),
        0b10000000 => try mem_16_disp(stream, buf[0], rm_mask, &rm),
        else => unreachable,
    };

    if (d) {
        try writer.print("mov {},{}\n", .{ rm, reg });
    } else {
        try writer.print("mov {},{}\n", .{ reg, rm });
    }
}

// Generic function for direct addressing
pub fn direct_addressing(comptime Stream: type) (
    stream: Stream,
    disp_flag: bool
) !i16 {
    if (disp_flag) {
        var buf: [1]u8 = undefined;
        try stream.read(&buf);
        return @intCast(i16, buf[0]);
    } else {
        var buf: [2]u8 = undefined;
        try stream.read(&buf);
        return @intCast(i16, buf[0] | (buf[1] << 8));
    }
}

// Generic function for memory addressing without displacement
pub inline fn mem_no_disp(comptime Stream: type) (
    stream: Stream,
    bufval: u8,
    mask: u8,
    name: *[16]u8
) !void {
    var buffer: [64]u8 = undefined;
    var stream_writer = std.io.FixedBufferStream.init(&buffer).writer();
    const displacement = try direct_addressing(Stream)(stream, false);

    switch (bufval & mask) {
        0b000 => try stream_writer.print("[bx + si]"),
        0b001 => try stream_writer.print("[bx + di]"),
        0b010 => try stream_writer.print("[bp + si]"),
        0b011 => try stream_writer.print("[bp + di]"),
        0b100 => try stream_writer.print("[si]"),
        0b101 => try stream_writer.print("[di]"),
        0b111 => try stream_writer.print("[bx]"),
        else => unreachable,
    }

    if ((bufval & mask) == 0b110) {
        try stream_writer.print(" + {}", .{ displacement });
    }

    const result = buffer[0..@min(name.len, stream_writer.writer.offset)];
    @copy(u8, name[0..@min(name.len, result.len)], result);
}

// Generic function for memory addressing with 8-bit displacement
pub inline fn mem_8_disp(comptime Stream: type) (
    stream: Stream,
    bufval: u8,
    mask: u8,
    name: *[16]u8
) !void {
    var buffer: [64]u8 = undefined;
    var stream_writer = std.io.FixedBufferStream.init(&buffer).writer();
    const displacement = try direct_addressing(Stream)(stream, true);

    switch (bufval & mask) {
        0b000 => try stream_writer.print("[bx + si + {}]", .{ displacement }),
        0b001 => try stream_writer.print("[bx + di + {}]", .{ displacement }),
        0b010 => try stream_writer.print("[bp + si + {}]", .{ displacement }),
        0b011 => try stream_writer.print("[bp + di + {}]", .{ displacement }),
        0b100 => try stream_writer.print("[si + {}]", .{ displacement }),
        0b101 => try stream_writer.print("[di + {}]", .{ displacement }),
        0b110 => try stream_writer.print("[bp + {}]", .{ displacement }),
        0b111 => try stream_writer.print("[bx + {}]", .{ displacement }),
        else => unreachable,
    }

    const result = buffer[0..@min(name.len, stream_writer.writer.offset)];
    @copy(u8, name[0..@min(name.len, result.len)], result);
}

// Generic function for memory addressing with 16-bit displacement
pub inline fn mem_16_disp(comptime Stream: type) (
    stream: Stream,
    bufval: u8,
    mask: u8,
    name: *[16]u8
) !void {
    var buffer: [64]u8 = undefined;
    var stream_writer = std.io.FixedBufferStream.init(&buffer).writer();
    const displacement = try direct_addressing(Stream)(stream, false);

    switch (bufval & mask) {
        0b000 => try stream_writer.print("[bx + si + {}]", .{ displacement }),
        0b001 => try stream_writer.print("[bx + di + {}]", .{ displacement }),
        0b010 => try stream_writer.print("[bp + si + {}]", .{ displacement }),
        0b011 => try stream_writer.print("[bp + di + {}]", .{ displacement }),
        0b100 => try stream_writer.print("[si + {}]", .{ displacement }),
        0b101 => try stream_writer.print("[di + {}]", .{ displacement }),
        0b110 => try stream_writer.print("[bp + {}]", .{ displacement }),
        0b111 => try stream_writer.print("[bx + {}]", .{ displacement }),
        else => unreachable,
    }

    const result = buffer[0..@min(name.len, stream_writer.writer.offset)];
    @copy(u8, name[0..@min(name.len, result.len)], result);
}

// Function to set default register based on mode and width
pub fn default_reg(
    bufval: u8,
    mask: u8,
    w: bool,
    name: *[16]u8
) !void {
    const reg_str: []const u8 = if (w) {
        switch (bufval & mask) {
            0b000 => "ax",
            0b001 => "cx",
            0b010 => "dx",
            0b011 => "bx",
            0b100 => "sp",
            0b101 => "bp",
            0b110 => "si",
            0b111 => "di",
            else => unreachable,
        }
    } else {
        switch (bufval & mask) {
            0b000 => "al",
            0b001 => "cl",
            0b010 => "dl",
            0b011 => "bl",
            0b100 => "ah",
            0b101 => "ch",
            0b110 => "dh",
            0b111 => "bh",
            else => unreachable,
        }
    };

    const reg_str_len = reg_str.len;
    @copy(u8, name[0..@min(name.len, reg_str_len)], reg_str);
}

// Main function to handle file operations and processing
pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file_path = "Asm_files/listing_0039_more_mov";
    // Open the input file with read permissions
    const file = try dir.openFile(file_path, .{ .read = true });
    defer file.close();

    // Initialize a buffered reader
    var buf_reader = std.io.BufferedReader.init(&file.reader());
    var stream = buf_reader.reader();

    const write_file_path = "Asm_files/output_0039.asm";
    // Create the output file with write and truncate permissions
    const write_file = try dir.createFile(write_file_path, .{ .truncate = true, .write = true });
    defer write_file.close();

    var writer = write_file.writer();

    try writer.print("bits 16\n\n", .{});

    var buf: [1]u8 = undefined;

    _ = try stream.read(&buf);
    std.debug.print("{b} \n", .{buf[0]});

    const opcode_bitmask: u8 = 0b11111100;

    switch (buf[0] & opcode_bitmask) {
        0b10001000 => try regmem_to_reg(stream, buf, writer),
        else => unreachable,
    }
}

