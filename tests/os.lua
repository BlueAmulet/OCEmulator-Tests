local test = require("test")

-- os.time tests

-- isdst is not supported
test.evaluate(os.time({day=1,month=1,year=1970,isdst=true}), os.time, {day=1,month=1,year=1970,isdst=false})

-- os.date tests

-- Invalid format options don't error
test.shouldNotError(os.date, "%i")

-- Verify valid options format correctly
local tzoffset = os.time({year=1970,day=1,wday=5,sec=0,yday=1,month=1,min=0,hour=0})
local testtime = 826405092 + tzoffset
test.evaluate("%", os.date, "%%")
test.evaluate("Saturday", os.date, "%A", testtime)
test.evaluate("March", os.date, "%B", testtime)
test.evaluate("19", os.date, "%C", testtime)
test.evaluate("03/09/96", os.date, "%D", testtime)
test.evaluate("1996-03-09", os.date, "%F", testtime)
test.evaluate("20", os.date, "%H", testtime)
test.evaluate("08", os.date, "%I", testtime)
test.evaluate("58", os.date, "%M", testtime)
test.evaluate("20:58", os.date, "%R", testtime)
test.evaluate("12", os.date, "%S", testtime)
test.evaluate("20:58:12", os.date, "%T", testtime)
test.evaluate("20:58:12", os.date, "%X", testtime)
test.evaluate("1996", os.date, "%Y", testtime)
test.evaluate("Sat", os.date, "%a", testtime)
test.evaluate("Mar", os.date, "%b", testtime)
test.evaluate("Sat Mar  9 20:58:12 1996", os.date, "%c", testtime)
test.evaluate("09", os.date, "%d", testtime)
test.evaluate(" 9", os.date, "%e", testtime)
test.evaluate("Mar", os.date, "%h", testtime)
test.evaluate("069", os.date, "%j", testtime)
test.evaluate("03", os.date, "%m", testtime)
test.evaluate("\n", os.date, "%n", testtime)
test.evaluate("PM", os.date, "%p", testtime)
test.evaluate("08:58:12 PM", os.date, "%r", testtime)
test.evaluate("\t", os.date, "%t", testtime)
test.evaluate("6", os.date, "%w", testtime)
test.evaluate("03/09/96", os.date, "%x", testtime)
test.evaluate("96", os.date, "%y", testtime)

-- Garbage arguments do not error
test.shouldNotError(os.date, nil, testtime)
test.shouldNotError(os.date, {}, testtime)
test.shouldNotError(os.date, true, testtime)
test.shouldNotError(os.date, print, testtime)

test.shouldNotError(os.date, "%c", "asdf")
test.shouldNotError(os.date, "%c", nil)
test.shouldNotError(os.date, "%c", {})
test.shouldNotError(os.date, "%c", true)
test.shouldNotError(os.date, "%c", print)

-- Verify default formatting
test.evaluate("09/03/96 20:58:12", os.date, nil, testtime)

-- Numbers are accepted as formatting strings
test.evaluate("1234", os.date, 1234)

-- Strings are accepted as time
test.evaluate("1996-03-09 20:58:12", os.date, "%Y-%m-%d %H:%M:%S", tostring(testtime))

-- Non valid options should all replace with empty strings
local nonvalid = "EGJKLNOPQUVWZfgikloqsuvz"
for i=1, #nonvalid do
	test.evaluate("ab", os.date, "a%"..nonvalid:sub(i,i).."b")
end

-- Timezone modifier does not work
test.evaluate(os.date("!%c", testtime), os.date, "%c", testtime)

-- Check that isdst is not returned
test.compare(nil, os.date("*t").isdst)

-- Check for no truncation at NUL
test.evaluate("abc\0def", os.date, "abc\0def")
