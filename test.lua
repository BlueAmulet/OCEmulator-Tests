local event = require("event")

local test = {}

local total = 0
local pass = 0

local log, err = io.open("log.txt","wb")
if not log then
	error(err)
end

local function passed()
	pass = pass + 1
	local _, err = pcall(error, "Test Passed", 5)
	log:write(err .. "\n")
	log:flush()
end

local function failed()
	local _, err = pcall(error, "Test Failed", 5)
	log:write(err .. "\n")
	log:flush()
end

function test.evaluate(something)
	total = total + 1
	(something and passed or failed)()
end

function test.shouldError(...)
	total = total + 1
	((not pcall(...)) and passed or failed)()
end

function test.shouldNotError(...)
	total = total + 1
	((pcall(...)) and passed or failed)()
end

function test.typeMatch(types, ...)
	total = total + 1
	local good = true
	if select("#",...) == #types then
		for i = 1,#types do
			if type(select(i,...)) ~= types[i] then
				good = false
			end
		end
	else
		good = false
	end
	(good and passed or failed)()
end

function test.valueMatch(values, ...)
	total = total + 1
	local good = true
	if select("#",...) == values.n then
		for i = 1,values.n do
			if select(i,...) ~= values[i] then
				good = false
			end
		end
	else
		good = false
	end
	(good and passed or failed)()
end

function test.pause()
	while select(3,event.pull("key_down")) ~= 13 do	end
end

function test.getTotal()
	if log then
		log:write(string.format("%d tests, %d passed, %d failed\n", total, pass, total - pass))
		log:close()
		log = nil
	end
	return total
end

function test.getPassed()
	return pass
end

function test.getFailed()
	return total - pass
end

function test.log(message)
	if log then
		log:write(message .. "\n")
		log:flush()
	end
end

return test
