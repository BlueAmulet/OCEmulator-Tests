package.loaded["test"] = dofile(package.searchpath("test","./?.lua"))
local test = require("test")
local fs = require("filesystem")
local shell = require("shell")

local args = {...}

require("term").clear()
local tests = {}
local testdir = shell.resolve("./tests/")
if #args > 0 then
	for i=1,#args do
		local name=fs.name(args[i]) .. ".lua"
		if not fs.exists(testdir .. "/" .. name) then
			error("No such test: " .. name,0)
		end
		tests[#tests + 1] = "tests/" .. name
	end
else
	for entry in fs.list(testdir) do
		tests[#tests + 1] = "tests/" .. entry
	end
end
table.sort(tests)
for i = 1,#tests do
	print("Running " .. tests[i])
	local fn, err = loadfile(os.getenv("PWD") .. "/" .. tests[i])
	if fn then
		local ok, err = pcall(fn)
		if not ok then
			print("Test " .. tests[i] .. " crashed!\n" .. err)
			test.log("Test " .. tests[i] .. " crashed!\n" .. err)
		end
	else
		print("Could not run " .. tests[i] .. "\n" .. err)
		test.log("Could not run " .. tests[i] .. "\n" .. err)
	end
end
print(string.format("%d tests, %d passed, %d failed", test.getTotal(), test.getPassed(), test.getFailed()))
print("Check log.txt for more information")
