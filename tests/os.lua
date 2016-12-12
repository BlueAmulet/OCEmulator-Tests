local test = require("test")

-- os.time tests

-- isdst is not supported
test.evaluate(os.time({day=1,month=1,year=1970,isdst=false}) == os.time({day=1,month=1,year=1970,isdst=true}))

-- os.date tests

-- Invalid format options don't error
test.shouldNotError(os.date, "%i")

-- Verify valid options format correctly
local tzoffset = os.time({year=1970,day=1,wday=5,sec=0,yday=1,month=1,min=0,hour=0})
local testtime = 826405092 + tzoffset
test.evaluate(os.date("%%") == "%")
test.evaluate(os.date("%A", testtime) == "Saturday")
test.evaluate(os.date("%B", testtime) == "March")
test.evaluate(os.date("%C", testtime) == "19")
test.evaluate(os.date("%D", testtime) == "03/09/96")
test.evaluate(os.date("%F", testtime) == "1996-03-09")
test.evaluate(os.date("%H", testtime) == "20")
test.evaluate(os.date("%I", testtime) == "08")
test.evaluate(os.date("%M", testtime) == "58")
test.evaluate(os.date("%R", testtime) == "20:58")
test.evaluate(os.date("%S", testtime) == "12")
test.evaluate(os.date("%T", testtime) == "20:58:12")
test.evaluate(os.date("%X", testtime) == "20:58:12")
test.evaluate(os.date("%Y", testtime) == "1996")
test.evaluate(os.date("%a", testtime) == "Sat")
test.evaluate(os.date("%b", testtime) == "Mar")
test.evaluate(os.date("%c", testtime) == "Sat Mar  9 20:58:12 1996")
test.evaluate(os.date("%d", testtime) == "09")
test.evaluate(os.date("%e", testtime) == " 9")
test.evaluate(os.date("%h", testtime) == "Mar")
test.evaluate(os.date("%j", testtime) == "069")
test.evaluate(os.date("%m", testtime) == "03")
test.evaluate(os.date("%n", testtime) == "\n")
test.evaluate(os.date("%p", testtime) == "PM")
test.evaluate(os.date("%r", testtime) == "08:58:12 PM")
test.evaluate(os.date("%t", testtime) == "\t")
test.evaluate(os.date("%w", testtime) == "6")
test.evaluate(os.date("%x", testtime) == "03/09/96")
test.evaluate(os.date("%y", testtime) == "96")

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
test.evaluate(os.date(nil, testtime) == "09/03/96 20:58:12")

-- Numbers are accepted as formatting strings
test.evaluate(os.date(1234) == "1234")

-- Strings are accepted as time
test.evaluate(os.date("%Y-%m-%d %H:%M:%S", tostring(testtime)) == "1996-03-09 20:58:12")

-- Non valid options should all replace with empty strings
local nonvalid = "EGJKLNOPQUVWZfgikloqsuvz"
for i=1, #nonvalid do
	test.evaluate(os.date("a%"..nonvalid:sub(i,i).."b") == "ab")
end

-- Timezone modifier does not work
test.evaluate(os.date("%c", testtime) == os.date("!%c", testtime))

-- Check that isdst is not returned
test.evaluate(os.date("*t").isdst == nil)

-- Check for truncation at NUL
test.evaluate(os.date("abc\0def") == "abc")
