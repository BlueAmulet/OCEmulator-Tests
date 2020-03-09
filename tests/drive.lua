local component=require("component")
if not component.isAvailable("drive") then
	test.logp("Skipping drive tests")
	return
end
local test=require("test")
local drive=component.drive

local capacity=drive.getCapacity()
local sectorsize=drive.getSectorSize()

-- Ensure capacity is a multiple of sector size
local sectors=capacity/sectorsize
test.compare(sectors, math.floor(sectors))

-- Read tests
test.shouldError(drive.readByte) -- No argument should error
test.valueMatch(table.pack(nil, "-1"), drive.readByte, 0) -- Early read should return {nil, "address-1"}
test.shouldError(drive.readByte, capacity+1) -- Late reads will error
test.typeMatch({"number"}, drive.readByte, 1) -- In bounds reads return a number
test.shouldError(drive.readSector) -- No argument should error
test.shouldError(drive.readSector, 0) -- Early sector read will error
test.shouldError(drive.readSector, sectors+1) -- Late reads will error
test.typeMatch({"string"}, drive.readSector, 1) -- In bounds reads return many bytes
if test.getLast() then
	local sector=drive.readSector(1)
	test.compare(sectorsize, #sector) -- Sector read returns correct amount of bytes
end

-- Put disclaimer and Y/N
print("Warning, performing drive write tests, the test will attempt to back up overwritten data but I take no responsibilities if you lose data.")
print("Continue? [Y/N]")
if not test.input() then
	test.log("User skipped drive write tests")
	return
end

-- Backup first two sectors
local ok1, backup1=pcall(drive.readSector, 1)
local ok2, backup2=pcall(drive.readSector, 2)
if not ok1 or not ok2 then
	test.logp("Failed to backup first two sectors, skipping drive write tests")
	return
end

-- Write byte tests
test.shouldError(drive.writeByte) -- No arguments should error
test.shouldError(drive.writeByte, 1) -- No value should error
test.shouldError(drive.writeByte, 1, " ") -- Incorrect value type should error
test.valueMatch(table.pack(nil, "-1"), drive.writeByte, 0, 0) -- Early write should return {nil, "address-1"}
test.shouldError(drive.writeByte, capacity+1, 0) -- Late write will error
test.shouldNotError(drive.writeByte, 1, 42.5) -- Write byte to address
test.evaluate(42, drive.readByte, 1) -- Verify write
test.shouldNotError(drive.writeByte, 1, -84) -- Value is a signed byte
test.evaluate(-84, drive.readByte, 1) -- Verify signed byte
test.shouldNotError(drive.writeByte, 1, 447) -- Value will wrap around
test.evaluate(-65, drive.readByte, 1) -- Verify wrap around
test.shouldNotError(drive.writeByte, 1, -403) -- Negative value wrap around
test.evaluate(109, drive.readByte, 1) -- Verify negative wrap

-- Write sector tests
test.shouldError(drive.writeSector) -- No arguments should error
test.shouldError(drive.writeSector, 1) -- No value should error
test.shouldError(drive.writeSector, 1, 0) -- Incorrect value type should error
test.shouldError(drive.writeSector, 0, "") -- Early write will error for once
test.shouldError(drive.writeSector, sectors+1, "") -- Late write will error
local nullsector = string.rep("\0", sectorsize)
test.shouldNotError(drive.writeSector, 1, nullsector) -- Clear sectors for tests
test.shouldNotError(drive.writeSector, 2, nullsector)
local halfsize = math.floor(sectorsize/2)
test.shouldNotError(drive.writeSector, 1, string.rep(" ", sectorsize+8))
test.shouldNotError(drive.writeSector, 1, string.rep("b", halfsize))
test.shouldNotError(drive.writeSector, 1, "")
test.evaluate(98, drive.readByte, 1) -- Beginning of partial write
test.evaluate(98, drive.readByte, halfsize) -- End of partial write
test.evaluate(32, drive.readByte, halfsize+1) -- Beginning of excessive write
test.evaluate(32, drive.readByte, sectorsize) -- End of excessive write
test.evaluate(0, drive.readByte, sectorsize+1) -- Excessive write should not overflow sectors

if not pcall(drive.writeSector, 1, backup1) or not pcall(drive.writeSector, 2, backup2) then
	test.logp("Warning, failed to restore sector backups")
end
