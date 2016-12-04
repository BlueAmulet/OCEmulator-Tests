local test = require("test")
local unicode = require("unicode")

local wide = unicode.char(0x3000) -- Nothing special about this character

-- Character tests
test.evaluate(unicode.char() == "")
test.evaluate(unicode.char(97,98,99) == "abc")
test.evaluate(unicode.char(97 + 0x10000) == "a")
test.evaluate(wide == "\xE3\x80\x80")
local unizero = "\xC0\x80"
test.evaluate(unicode.char(0) == unizero)
test.evaluate(unicode.char(0/0) == unizero)
test.evaluate(unicode.char(math.huge) == unizero)
test.evaluate(unicode.char(-math.huge) == unizero)

-- Character Width tests
test.evaluate(unicode.charWidth("x") == 1)
test.evaluate(unicode.charWidth(wide) == 2)
test.evaluate(unicode.charWidth("x" .. wide) == 1)
test.evaluate(unicode.charWidth(wide .. "x") == 2)
test.shouldError(unicode.charWidth, "\0")

test.evaluate(unicode.isWide("x") == false)
test.evaluate(unicode.isWide(wide) == true)
test.evaluate(unicode.isWide("x" .. wide) == false)
test.evaluate(unicode.isWide(wide .. "x") == true)
test.shouldError(unicode.isWide, "\0")

-- Unicode length tests
test.evaluate(unicode.len(string.rep("X",3)) == 3)
test.evaluate(unicode.len(string.rep(wide,3)) == 3)
test.evaluate(unicode.len(string.rep("X" .. wide,3)) == 6)
test.evaluate(unicode.len("RATED\0X") == 5)

-- Unifont length tests
test.evaluate(unicode.wlen(string.rep("X",3)) == 3)
test.evaluate(unicode.wlen(string.rep(wide,3)) == 6)
test.evaluate(unicode.wlen(string.rep("X" .. wide,3)) == 9)
test.evaluate(unicode.wlen("RATED\0X") == 5)

-- Unifont truncation tests
test.evaluate(unicode.wtrunc("ABCDEFG",-7) == "")
test.evaluate(unicode.wtrunc("ABCDEFG",0) == "")
test.evaluate(unicode.wtrunc("ABCDEFG",1) == "")
test.evaluate(unicode.wtrunc("ABCDEFG",3) == "AB")
test.evaluate(unicode.wtrunc("ABCDEFG",7) == "ABCDEF")
test.shouldError(unicode.wtrunc, "ABCDEFG", 8)
test.evaluate(unicode.wtrunc("ABCDEFG", 0/0) == "")
test.evaluate(unicode.wtrunc("ABCDEFG", math.huge) == "")
test.evaluate(unicode.wtrunc("ABCDEFG", -math.huge) == "")
test.shouldError(unicode.wtrunc, "ABCD\0EFG", 5)

local widestr = string.rep(wide,3)
test.evaluate(unicode.wtrunc(widestr,3) == string.rep(wide,1))
test.evaluate(unicode.wtrunc(widestr,4) == string.rep(wide,1))
test.evaluate(unicode.wtrunc(widestr,5) == string.rep(wide,2))
test.evaluate(unicode.wtrunc(widestr,6) == string.rep(wide,2))
test.shouldError(unicode.wtrunc, widestr, 7)

-- Unicode operation tests
test.evaluate(unicode.lower("ABCΓΓΓabcγγγ") == "abcγγγabcγγγ")
test.evaluate(unicode.lower("ABCΓΓΓ\0abcγγγ") == "abcγγγ")
test.evaluate(unicode.upper("ABCΓΓΓabcγγγ") == "ABCΓΓΓABCΓΓΓ")
test.evaluate(unicode.upper("abcγγγ\0abcγγγ") == "ABCΓΓΓ")
test.evaluate(unicode.reverse("Ümläüt") == "tüälmÜ")
test.evaluate(unicode.reverse("Üml\0äüt") == "lmÜ")
test.evaluate(unicode.sub("ABCΓΓΓabcγγγ",3,5) == "CΓΓ")
test.evaluate(unicode.sub("ABCΓΓΓabcγγγ",3,-3) == "CΓΓΓabcγ")
test.evaluate(unicode.sub("ABCΓΓΓabcγγγ",-7,-2) == "Γabcγγ")
test.evaluate(unicode.sub("CΓ", 0/0) == "CΓ")
test.evaluate(unicode.sub("CΓ", math.huge) == "CΓ")
test.evaluate(unicode.sub("CΓ", -math.huge) == "CΓ")
test.evaluate(unicode.sub("CΓ", 0/0, math.huge) == "")
test.evaluate(unicode.sub("Üml\0äüt",1) == "Üml")
