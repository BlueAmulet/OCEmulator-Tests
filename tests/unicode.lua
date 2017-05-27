local test = require("test")
local unicode = require("unicode")

local wide = unicode.char(0x3000) -- Nothing special about this character
local zwidth = unicode.char(0xFFFF) -- Character with zero width

-- Character tests
test.evaluate("", unicode.char)
test.evaluate("abc", unicode.char, 97,98,99)
test.evaluate("a", unicode.char, 97 + 0x10000)
test.compare("\xE3\x80\x80", wide)

-- Test that JNI Modified UTF-8 is avoided
test.evaluate("\0", unicode.char, 0)
test.evaluate("\0", unicode.char, 0/0)
test.evaluate("\0", unicode.char, math.huge)
test.evaluate("\0", unicode.char, -math.huge)

-- Character Width tests
test.evaluate(1, unicode.charWidth, "x")
test.evaluate(2, unicode.charWidth, wide)
test.evaluate(1, unicode.charWidth, "x" .. wide)
test.evaluate(2, unicode.charWidth, wide .. "x")
test.evaluate(1, unicode.charWidth, "\0")
test.evaluate(0, unicode.charWidth, zwidth)

test.evaluate(false, unicode.isWide, "x")
test.evaluate(true, unicode.isWide, wide)
test.evaluate(false, unicode.isWide, "x" .. wide)
test.evaluate(true, unicode.isWide, wide .. "x")
test.evaluate(false, unicode.isWide, "\0")
test.evaluate(false, unicode.isWide, zwidth)

-- Unicode length tests
test.evaluate(3, unicode.len, string.rep("X",3))
test.evaluate(3, unicode.len, string.rep(wide,3))
test.evaluate(6, unicode.len, string.rep("X" .. wide,3))
test.evaluate(7, unicode.len, "RATED\0X")

-- Unicode length tests
test.evaluate(3, unicode.wlen, string.rep("X",3))
test.evaluate(6, unicode.wlen, string.rep(wide,3))
test.evaluate(9, unicode.wlen, string.rep("X" .. wide,3))
test.evaluate(7, unicode.wlen, "RATED\0X")
test.evaluate(1, unicode.wlen, zwidth)

-- Unicode truncation tests
test.evaluate("", unicode.wtrunc, "ABCDEFG",-7)
test.evaluate("", unicode.wtrunc, "ABCDEFG",0)
test.evaluate("", unicode.wtrunc, "ABCDEFG",1)
test.evaluate("AB", unicode.wtrunc, "ABCDEFG",3)
test.evaluate("ABCDEF", unicode.wtrunc, "ABCDEFG",7)
test.shouldError(unicode.wtrunc, "ABCDEFG", 8)
test.evaluate("", unicode.wtrunc, "ABCDEFG", 0/0)
test.evaluate("", unicode.wtrunc, "ABCDEFG", math.huge)
test.evaluate("", unicode.wtrunc, "ABCDEFG", -math.huge)
test.evaluate("ABCD\0", unicode.wtrunc, "ABCD\0EFG", 6)

local widestr = string.rep(wide,3)
test.evaluate(string.rep(wide,1), unicode.wtrunc, widestr,3)
test.evaluate(string.rep(wide,1), unicode.wtrunc, widestr,4)
test.evaluate(string.rep(wide,2), unicode.wtrunc, widestr,5)
test.evaluate(string.rep(wide,2), unicode.wtrunc, widestr,6)
test.shouldError(unicode.wtrunc, widestr, 7)

local zwidthstr = string.rep(zwidth, 5)
test.evaluate("", unicode.wtrunc, zwidthstr, 0)
test.shouldError(unicode.wtrunc, zwidthstr, 1)
test.evaluate("", unicode.wtrunc, "a" .. zwidthstr, 1)
test.shouldError(unicode.wtrunc, "a" .. zwidthstr, 2)
test.evaluate(zwidthstr, unicode.wtrunc, zwidthstr .. "b", 1)
test.shouldError(unicode.wtrunc, zwidthstr .. "b", 2)
test.evaluate("a" .. zwidthstr, unicode.wtrunc, "a" .. zwidthstr .. "b", 2)
test.shouldError(unicode.wtrunc, "a" .. zwidthstr .. "b", 3)

-- Unicode operation tests
test.evaluate("abcγγγabcγγγ", unicode.lower, "ABCΓΓΓabcγγγ")
test.evaluate("abcγγγ\0abcγγγ", unicode.lower, "ABCΓΓΓ\0abcγγγ")
test.evaluate("ABCΓΓΓABCΓΓΓ", unicode.upper, "ABCΓΓΓabcγγγ")
test.evaluate("ABCΓΓΓ\0ABCΓΓΓ", unicode.upper, "abcγγγ\0abcγγγ")
test.evaluate("tüälmÜ", unicode.reverse, "Ümläüt")
test.evaluate("tüä\0lmÜ", unicode.reverse, "Üml\0äüt")
test.evaluate("CΓΓ", unicode.sub, "ABCΓΓΓabcγγγ",3,5)
test.evaluate("CΓΓΓabcγ", unicode.sub, "ABCΓΓΓabcγγγ",3,-3)
test.evaluate("Γabcγγ", unicode.sub, "ABCΓΓΓabcγγγ",-7,-2)
test.evaluate("CΓ", unicode.sub, "CΓ", 0/0)
test.evaluate("CΓ", unicode.sub, "CΓ", math.huge)
test.evaluate("CΓ", unicode.sub, "CΓ", -math.huge)
test.evaluate("", unicode.sub, "CΓ", 0/0, math.huge)
test.evaluate("Üml\0äüt", unicode.sub, "Üml\0äüt",1)
