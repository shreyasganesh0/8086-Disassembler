const std = @import("std");
const dir = std.fs.cwd();
const Error = error{ FileNotFound, PermissionDenied, InvalidInput };

pub fn regmem_to_reg(stream, buf) !void{
        const d_mask: u8 = 0b000000_1_0;
        const w_mask: u8 = 0b000000_0_1;
        var d: bool = undefined;
        var w: bool = undefined;

        d = buf[0] & d_mask > 0;
        w = buf[0] & w_mask > 0;
        
        var buf:[1]u8 = undefined;
        try stream.read(&buf);

        var reg = [_]u8{ 0, 0 };
        var rm = [_]u8{ 0, 0 };
        
        const mod_mask = 0b11_000000;
        const reg_mask = 0b00_111_000;
        const regbuf: u8 = (buf[0] >> 3) & 0b00000_111;
        const rm_mask = 0b00_000_111;

        try default_reg(regbuf, reg_mask, w, &reg);

        switch(buf[0]&mod_mask){
        0b11_000000 => default_reg(buf[0], rm_mask, w, &rm),
        0b00_000000 => mem_no_disp(buf[0], rm_mask, &rm, stream),
        0b01_000000 => mem_8_disp(buf[0], rm_mask, &rm, stream),
        0b10_000000 => mem_16_disp(buf[0], rm_mask, &rm, stream),

}
        if (d) {
            try write_file.writer().print("{s} {},{}\n", .{ opcode, rm, reg });
        } else {
            try write_file.writer().print("{s} {},{}\n", .{ opcode, reg, rm });
        }
}

pub fn direct_addressing(stream: [_]u8, disp_flag:bool) ![_]u8{
        if(disp_flag){
        var result:u8 = undefined;
        var buf:[1]u8 = undefined;
}

        else{
        var result:u16 = undefined;
        var buf:[2]u8 = undefined;
}
        try stream.read(&buf);
        @memcpy(result, buf);
        return result;
}
pub fn mem_no_disp(bufval: u8, mask: u8, name: *[2]u8, stream) !void {
        @memcpy(name, switch (bufval & mask) {
            0b00_000_000 => "[bx + si]",
            0b00_000_001 => "[bx + di]",
            0b00_000_010 => "[bp + si]",
            0b00_000_011 => "[bp + di]",
            0b00_000_100 => "[si]",
            0b00_000_101 => "[di]",
            0b00_000_110 => direct_addressing(stream),
            0b00_000_111 => "[bx]",
            else => unreachable,
        });
}
pub fn mem_8_disp(bufval: u8, mask: u8, name: *[2]u8) !void {
        @memcpy(name, switch (bufval & mask) {
            0b00_000_000 => "[bx + si",
            0b00_000_001 => "[bx + di",
            0b00_000_010 => "[bp + si",
            0b00_000_011 => "[bp + di",
            0b00_000_100 => "[si",
            0b00_000_101 => "[di",
            0b00_000_110 => "[bp",
            0b00_000_111 => "[bx",
            else => unreachable,
        });
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

    try stream.read(&buf) 
        std.debug.print("{b} \n", .{buf[0]});

        var opcode: [3]u8 = undefined;
        const opcode_bitmask:u8 = 0b111111_00;
        const imm_to_reg_bitmask:u8 = 0b1111_0000;

        if(buf[0]&imm_to_reg_bitmask == 0b1011_0000){
            imm_to_reg(stream,buf);
        }

    switch(buf[0]){
        0b100010_00 => regmem_to_reg(stream,buf),
        0b110001_00 => immediate_to_regmem(stream,buf),
        0b101000_00 => acc_to_mem(stream, buf),
        0b100011_00 => regmem_to_segreg(stream,buf),
        

        if ((buf[0] & bitmask) == mov) {
            opcode = "mov".*;
        }

    }
}
