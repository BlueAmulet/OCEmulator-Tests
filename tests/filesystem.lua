local test = require("test")
local event = require("event")

-- Put disclaimer and Y/N
print("Warning, these filesystem tests could potentially destroy your entire computer if your filesystem implementation is garbage, I take no responsibilities if you lose data.")
print("Continue? [Y/N]")
while true do
	local code = select(4,event.pull("key_down"))
	if code == 49 then -- N
		test.log("User skipped filesystem tests")
		return
	elseif code == 21 then -- Y
		break
	end
end

local computer = require("computer")
local component = require("component")

-- We put the tests into a function to be able to test multiple filesystems
-- It's possible that tmpfs is bugged but the disk isn't, or vice versa.
local function fstest(fs)
	local label=fs.getLabel()
	if label then label=" - "..label else label="" end
	test.logp("Testing filesystem component @"..fs.address..label)
	local testname
	while true do
		local str=""
		for i=1,8 do
			str=str..string.char(math.random(97,122))
		end
		if not fs.exists(str) then
			testname=str
			break
		end
	end
	local rw=not fs.isReadOnly()
	if rw then
		print("Skipping Read-Only tests")
		test.log("Filesystem is read-write")
		local errgeneric = table.pack(nil, testname)
		-- Test makeDirectory's ability to make multiple directories at once
		test.evaluate(fs.makeDirectory(testname.."/a/b/c") == true)
		test.evaluate(fs.exists(testname.."/a/b/c") == true)
		-- Test makeDirectory's refusal to create the same thing
		test.evaluate(fs.makeDirectory(testname.."/a/b/c") == false)
		-- Test renaming something to an existing thing
		fs.makeDirectory(testname.."/b")
		test.evaluate(fs.rename(testname.."/a", testname.."/b") == false)
		-- Test remove's recursive removal ability
		test.evaluate(fs.remove(testname) == true)
		test.evaluate(fs.exists(testname.."/a/b/c") == false)
		test.evaluate(fs.exists(testname) == false)
		-- Test renaming a non existent thing
		test.valueMatch(errgeneric, fs.rename(testname, testname))
		-- Test reading a non existent thing
		test.valueMatch(errgeneric, fs.open(testname, "rb"))
		-- Various tests on file handles
		local testfile, err = fs.open(testname, "w")
		if testfile then
			-- Handles are wrapped userdata
			test.evaluate(type(testfile) == "table")
			if type(testfile) == "table" then
				test.evaluate(testfile.type == "userdata")
				test.evaluate(getmetatable(testfile) == "userdata")
			elseif type(testfile) == "number" then
				local msg="Warning: filesystem implementation uses numbers as handles, this is depreciated behaviour."
				test.logp(msg)
			end
			-- Cannot read a write handle
			local baddesc = table.pack(nil, "bad file descriptor")
			test.valueMatch(baddesc, fs.read(testfile, 0))
			-- Cannot seek before 0
			local testtbl = table.pack(nil, "invalid offset")
			test.valueMatch(testtbl, fs.seek(testfile, "set", -1))
			test.valueMatch(testtbl, fs.seek(testfile, "cur", -1))
			test.valueMatch(testtbl, fs.seek(testfile, "end", -1))
			-- Test write increments seek
			test.evaluate(fs.write(testfile, "test") == true)
			test.evaluate(fs.seek(testfile, "cur", 0) == 4)
			-- Test seek boundaries
			test.evaluate(fs.seek(testfile, "set", 0) == 0)
			test.evaluate(fs.seek(testfile, "set", 4) == 4)
			test.evaluate(fs.seek(testfile, "cur", -4) == 0)
			test.evaluate(fs.seek(testfile, "cur", 4) == 4)
			test.evaluate(fs.seek(testfile, "end", 0) == 4)
			test.evaluate(fs.seek(testfile, "end", -4) == 0)
			-- Test seeking past
			test.evaluate(fs.seek(testfile, "set", 5) == 5)
			fs.seek(testfile, "set", 3)
			test.evaluate(fs.seek(testfile, "cur", 2) == 5)
			test.evaluate(fs.seek(testfile, "end", 1) == 5)
			-- Test what gets wrote in seeked over data
			-- Also test that no conversions take place.
			fs.write(testfile, "bear\r\n\n\r")
			fs.close(testfile)
			-- Test using a closed file handle.
			test.valueMatch(baddesc, fs.close(testfile))
			test.valueMatch(baddesc, fs.read(testfile, 0))
			test.valueMatch(baddesc, fs.write(testfile, ""))
			test.valueMatch(baddesc, fs.seek(testfile, "set", 0))
			testfile, err = fs.open(testname, "rb")
			if testfile then
				-- Cannot write a read handle
				test.valueMatch(baddesc, fs.write(testfile, ""))
				-- Actually test what gets wrote in seeked over data
				-- Also test that no conversions happen
				local data=fs.read(testfile, math.huge)
				test.evaluate(data == "test\0bear\r\n\n\r")
				-- Test read increments seek
				test.evaluate(fs.seek(testfile, "cur", 0) == 13)
				-- Check for nil at EOF
				test.evaluate(fs.read(testfile, math.huge) == nil)
				-- Unlike writing, can seek before 0
				test.evaluate(fs.seek(testfile, "set", -1) == -1)
				test.evaluate(fs.seek(testfile, "cur", -1) == -2)
				test.evaluate(fs.seek(testfile, "end", -14) == -1)
				-- Seek position is a signed integer
				test.evaluate(fs.seek(testfile, "cur", -math.huge) == 2147483647)
				test.evaluate(fs.seek(testfile, "cur", -math.huge) == -1)
				-- Negative seeks produce extra \0's
				data=fs.read(testfile, math.huge)
				test.evaluate(data == "test\0bear\r\n\n\r\0")
				test.evaluate(fs.seek(testfile, "cur", 0) == 13)
			else
				test.evaluate(false)
				print("Failed to open file for reading: "..err)
				test.log("Failed to open file for reading: "..err)
			end
			fs.close(testfile)
			fs.remove(testname)
		else
			test.evaluate(false)
			print("Failed to open file for writing: "..err)
			test.log("Failed to open file for writing: "..err)
		end
		-- Test broken rename behaviour
		fs.makeDirectory(testname)
		test.evaluate(fs.rename(testname, testname.."/d") == true)
		test.evaluate(fs.exists(testname) == false)
		-- Test for incorrect broken rename behaviour
		fs.makeDirectory(testname)
		test.evaluate(fs.rename(testname, testname.."/e/f") == false)
		test.evaluate(fs.exists(testname) == true)
		test.evaluate(fs.exists(testname.."/e/f") == false)
		-- Test opening a directory for writing
		test.valueMatch(errgeneric, fs.open(testname, "wb"))
	else
		print("Skipping Read-Write tests")
		test.log("Filesystem is read-only")
		-- Find a file and a directory to test with
		local list=fs.list("/")
		local testfile, testdir
		for i = 1,list.n do
			if not testfile and list[i]:sub(-1) ~= "/" then
				testfile = list[i]
			end
			if not testdir and list[i]:sub(-1) == "/" then
				testdir = list[i]:sub(1,-2)
			end
			if testfile and testdir then
				break
			end
		end
		list={testname}
		if testfile then
			list[#list+1]=testname
		else
			print("No files found on filesystem, related tests skipped")
			test.log("No files found on filesystem")
		end
		if testdir then
			list[#list+1]=testdir
		else
			print("No directories found on filesystem, related tests skipped")
			test.log("No directories found on filesystem")
		end
		-- All makeDirectory calls should fail
		for i = 1, #list do
			test.evaluate(fs.makeDirectory(list[i]) == false)
		end
		-- All rename calls should fail
		for i = 1, #list do
			for j = 1, #list do
				test.evaluate(fs.rename(list[i], list[j]) == false)
			end
		end
		-- All remove calls should fail
		for i = 1, #list do
			test.evaluate(fs.remove(list[i]) == false)
		end
		-- All attemps to open for writing should fail
		for i = 1, #list do
			test.valueMatch(table.pack(nil, list[i]), fs.open(list[i], "wb"))
		end
	end
	-- Root and beyond
	test.evaluate(fs.exists("") == true)
	test.evaluate(fs.exists(".") == true)
	test.evaluate(fs.exists("..") == false)
	test.evaluate(fs.isDirectory("") == true)
	test.evaluate(fs.isDirectory(".") == true)
	test.evaluate(fs.isDirectory("..") == false)
end

local tmpfs=component.proxy(computer.tmpAddress())
test.evaluate(tmpfs.getLabel() == "tmpfs")
test.shouldError(tmpfs.setLabel, "tmpfs")
fstest(tmpfs)

-- TODO: The tests require a writable drive for the logging, test it too
-- TODO: Tests could be ran from /tmp I suppose, make sure the writable drive isn't /tmp

-- Test a read only device too.
local roaddr
for addr in component.list("filesystem", true) do
	if component.proxy(addr).isReadOnly() then
		roaddr = addr
		break
	end
end
if not roaddr then
	print("No read-only filesystems available, skipping ro tests")
	test.log("No read-only filesystems available")
else
	local rofs=component.proxy(roaddr)
	test.shouldError(rofs.setLabel, rofs.getLabel())
	fstest(rofs)
end
