const std = @import("std");
const fs = std.fs;
const mem = std.mem;


pub const String = struct {

    allocator: mem.Allocator,
    text: []u8,

    pub const Error = error {
        OutOfIndex,
        InvalidIndex,
        CharacterNotFound,
    };

    pub fn deinit(self: String) void {
        self.allocator.free(self.text);
    }

    pub fn init(allocator: mem.Allocator, s: []const u8) mem.Allocator.Error!String {
        const self = String {
            .allocator = allocator,
            .text = try allocator.alloc(u8, s.len),
        };
        mem.copyForwards(u8, self.text, s);

        return self;
    }

    pub fn char(allocator: mem.Allocator, c: u8) mem.Allocator.Error!String {
        return try String.init(allocator, &[_]u8 { c });
    }

    pub fn file(allocator: mem.Allocator, path: []const u8) (fs.File.OpenError || fs.File.GetSeekPosError || mem.Allocator.Error || fs.File.ReadError)!String {
        const f = try fs.cwd().openFile(path, .{ .mode = .read_only });
        defer f.close();

        const text: []u8 = try allocator.alloc(u8, try f.getEndPos());

        return String {
            .allocator = allocator,
            .text = text[0..(try f.readAll(text))],
        };
    }

    pub fn dup(self: String) mem.Allocator.Error!String {
        return try String.init(self.allocator, self.text);
    }

    pub fn append(self: *String, string: String) mem.Allocator.Error!void {
        const len = self.length();
        self.text = try self.allocator.realloc(self.text, len + string.length());
        mem.copyForwards(u8, self.text[len..], string.text);
    }

    pub fn substring(self: String, beginIndex: usize, endIndex: usize) (Error || mem.Allocator.Error)!String {
        if (!(beginIndex <= endIndex))
            return Error.InvalidIndex;

        if (!(beginIndex <= self.length() and endIndex <= self.length()))
            return Error.OutOfIndex;
        return try String.init(self.allocator, self.text[beginIndex..endIndex]);
    }

    pub fn length(self: String) usize {
        return self.text.len;
    }

    pub fn charAt(self: String, index: usize) Error!u8 {
        if (self.text.len <= index)
            return Error.OutOfIndex;

        return self.text[index];
    }

    pub fn firstIndex(self: String, c: u8) Error!usize {
        for (0..self.length()) |i| {
            if ((try self.charAt(i)) == c)
                return i;
        }
        return Error.CharacterNotFound;
    }

    pub fn lastIndex(self: String, c: u8) Error!usize {
        for (0..self.length()) |i| {
            const j = (self.length() - 1) - i;
            if ((try self.charAt(j)) == c)
                return j;
        }
        return Error.CharacterNotFound;
    }

    pub fn eql(self: String, string: String) bool {
        return mem.eql(u8, self.text, string.text);
    }

    pub fn empty(self: String) bool {
        return self.length() == 0;
    }

    pub fn starts(self: String, string: String) bool {
        return mem.startsWith(u8, self.text, string.text);
    }

    pub fn startsChar(self: String, c: u8) bool {
        return (self.charAt(0) catch return false) == c;
    }

};
