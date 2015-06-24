package.loaded["test"] = dofile(package.searchpath("test","./?.lua"))
local test = require("test")
local fs = require("filesystem")
local shell = require("shell")

require("term").clear()
local tests = {}
for entry in fs.list(shell.resolve("./tests/")) do
	tests[#tests + 1] = "tests/" .. entry
end
table.sort(tests)
for i = 1,#tests do
	print("Running " .. tests[i])
	local fn, err = loadfile(tests[i])
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
