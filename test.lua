local event=require("event")

local test={}

local total=0
local pass=0
local errors=0
local lastTest

local log, err=io.open("log.txt", "wb")
if not log then
	error(err)
end

local function passed()
	pass=pass + 1
	lastTest=true
	local _, err=pcall(error, "Test Passed", 5)
	log:write(err .. "\n")
	log:flush()
end

local function failed()
	lastTest=false
	local _, err=pcall(error, "Test Failed", 5)
	log:write(err .. "\n")
	log:flush()
end

local function errored()
	errors=errors + 1
	lastTest=false
	local _, err=pcall(error, "Test Errored", 5)
	log:write(err .. "\n")
	log:flush()
end

function test.evaluate(something, ...)
	total=total + 1
	local ok, val=pcall(...);
	if ok then
		((val == something) and passed or failed)()
	else
		errored()
	end
end

function test.compare(something, another)
	total=total + 1
	((something == another) and passed or failed)()
end

function test.shouldError(...)
	total=total + 1
	((not pcall(...)) and passed or failed)()
end

function test.shouldNotError(...)
	total=total + 1
	((pcall(...)) and passed or failed)()
end

function test.typeMatch(types, ...)
	total=total + 1
	local good=true
	local results=table.pack(pcall(...))
	if not results[1] then
		errored()
	else
		if results.n - 1 == #types then
			for i=1, #types do
				if type(results[i + 1]) ~= types[i] then
					good=false
					break
				end
			end
		else
			good=false
		end
		(good and passed or failed)()
	end
end

function test.valueMatch(values, ...)
	total=total + 1
	local good=true
	local results=table.pack(pcall(...))
	if not results[1] then
		errored()
	else
		if results.n - 1 == values.n then
			for i=1, values.n do
				if results[i + 1] ~= values[i] then
					good=false
					break
				end
			end
		else
			good=false
		end
		(good and passed or failed)()
	end
end

function test.pause()
	while select(3, event.pull("key_down")) ~= 13 do end
end

function test.getTotal()
	if log then
		log:write(string.format("%d tests, %d passed, %d failed, %d errors\n", total, pass, total - pass - errors, errors))
		log:close()
		log=nil
	end
	return total
end

function test.getPassed()
	return pass
end

function test.getFailed()
	return total - pass - errors
end

function test.getErrors()
	return errors
end

function test.getLast()
	return lastTest
end

function test.log(message)
	if log then
		log:write(message .. "\n")
		log:flush()
	end
end

function test.logp(message)
	print(message)
	if log then
		log:write(message .. "\n")
		log:flush()
	end
end

return test
