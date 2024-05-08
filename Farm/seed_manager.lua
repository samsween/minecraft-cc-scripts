SeedManager = {}
SeedManager.__index = SeedManager

setmetatable(SeedManager, {
    __call = function(cls, filename)
        local instance = setmetatable({}, cls)
        instance.filename = filename
        instance.chest = peripheral.find("inventory")
        return instance
    end
})

function SeedManager:isValid(name, seed)
    if name == nil or seed == nil then
        return false
    end
    return true
end

function SeedManager:getFileLines()
    local file = io.open(self.filename, "r")
    local fileContent = {}
    for line in file:lines() do
        table.insert(fileContent, line)
    end
    file:close()
    return fileContent
end

function SeedManager:writeFile(fileContent)
    local file = io.open(self.filename, "w")
    for _, line in ipairs(fileContent) do
        file:write(line .. "\n")
    end
    file:close()
end

function SeedManager:printSeeds()
    local fileContent = self:getFileLines()
    for _, line in ipairs(fileContent) do
        print(line)
    end
end

function SeedManager:doesExist(name, seed)
    local fileContent = self:getFileLines()
    local exists = false
    for i = 2, #fileContent - 1 do
        local nameE, seedE = fileContent[i]:match('allowedSeeds%["(.*)"%]%s*=%s*"(.*)"')
        if nameE == name then
            print("Seed name " .. name .. " already exists")
            exists = true
            break
        end
        if seedE == seed then
            print("Seed " .. seed .. " already exists")
            exists = true
            break
        end
    end
    return exists
end

function SeedManager:checkSeedTable(seedTable)
    for name, seed in pairs(seedTable) do
        if self:doesExist(name, seed) then
            return false
        end
    end
    return true
end

function SeedManager:writeSeeds(seeds)
    if not self:checkSeedTable(seeds) then
        return
    end
    local fileContent = self:getFileLines()
    local exportLine = fileContent[#fileContent]
    fileContent[#fileContent] = nil
    for name, seed in pairs(seeds) do
        table.insert(fileContent, "allowedSeeds[\"" .. name .. "\"]=\"" .. seed .. "\"\n")
    end
    fileContent[#fileContent] = exportLine
    self:writeFile(fileContent)
end

function SeedManager:setSeedsFromChest()
    if self.chest == nil then
        print("Chest not found")
        return
    end
    local seeds = {}
    local itemsInChest = self.chest.list()
    for _, item in ipairs(itemsInChest) do
        print("Enter seed name for " .. item.name .. ": ")
        local localSeedName = read()
        if localSeedName == "" then
            goto continue
        end
        seeds[localSeedName] = item.name
        ::continue::
    end
    self:writeSeeds(seeds)
end

function SeedManager:setSeedsFromFile(args)
    local fileName = args[3]
    if fileName == nil then
        print("File name not provided")
        return
    end
    if fs.exists(fileName) == false then
        print("File does not exist")
        return
    end
    local file = io.open(fileName, "r")
    local seeds = {}
    for line in file:lines() do
        local name, seed = line:match("(.*)=(.*)")
        if self:isValid(name, seed) then
            seeds[name] = seed
        end
    end
    self:writeSeeds(seeds)
    file:close()
end

function SeedManager:setSeedsFromCommand(args)
    local seeds = {}
    for i = 3, #args, 2 do
        if args[i + 1] == nil then
            print("Seed not provided for " .. args[i])
            return
        end
        seeds[args[i]] = args[i + 1]
    end
    self:writeSeeds(seeds)
end

return SeedManager
