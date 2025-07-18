const std = @import("std");
const heap = std.heap;
const mem = std.mem;
const testing = std.testing;

const ariadne = @import("ariadne");


test "String.init; ArenaAllocator" {
	var arena = heap.ArenaAllocator.init(heap.page_allocator);
	defer arena.deinit();

	const s: ariadne.String = try ariadne.String.init(arena.allocator(), "test");
	defer s.deinit();

	try testing.expect(mem.eql(u8, s.text, "test"));
}

test "String.init; DebugAllocator" {
	var da = heap.DebugAllocator(.{}){};
	defer _ = da.deinit();

	const s = try ariadne.String.init(da.allocator(), "test");
	defer s.deinit();

	try testing.expect(mem.eql(u8, s.text, "test"));
}

test "String constructors" {
	var da = heap.DebugAllocator(.{}){};
	defer _ = da.deinit();

	var s1 = try ariadne.String.init(da.allocator(), "test");
	defer s1.deinit();
	try testing.expect(mem.eql(u8, s1.text, "test"));

	const s2 = try ariadne.String.char(da.allocator(), 'z');
	defer s2.deinit();
	try testing.expect(mem.eql(u8, s2.text, "z"));

	const s3 = try ariadne.String.file(da.allocator(), "test/STRING.txt");
	defer s3.deinit();
	try testing.expect(mem.eql(u8, s3.text, "abcdefg\r\nhijklmn\r\nopqrstu\r\nvwxyz"));

	const s4 = try s1.dup();
	defer s4.deinit();
	try testing.expect(mem.eql(u8, s4.text, "test"));

    try s1.append(s4);
	try testing.expect(mem.eql(u8, s1.text, "testtest"));

	const s6 = try s1.substring(1, 4);
	defer s6.deinit();
	try testing.expect(mem.eql(u8, s6.text, "est"));
}

test "String functions" {
	var da = heap.DebugAllocator(.{}){};
	defer _ = da.deinit();

	const s1 = try ariadne.String.init(da.allocator(), "test");
	defer s1.deinit();

	try testing.expect(s1.length() == 4);
	try testing.expect(try s1.charAt(2) == 's');
	try testing.expect(try s1.firstIndex('t') == 0);
	try testing.expect(try s1.lastIndex('t') == 3);
}

test "String predicates" {
	var da = heap.DebugAllocator(.{}){};
	defer _ = da.deinit();

	const s1 = try ariadne.String.init(da.allocator(), "test");
	defer s1.deinit();
	const s2 = try ariadne.String.init(da.allocator(), "test");
	defer s2.deinit();
	try testing.expect(s1.eql(s2));

	const s3 = try ariadne.String.init(da.allocator(), "");
	defer s3.deinit();
	try testing.expect(s3.empty());

	const s4 = try ariadne.String.init(da.allocator(), "te");
	defer s4.deinit();
	try testing.expect(s1.starts(s4));
	try testing.expect(s1.startsChar('t'));
}
