


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
        file:write(line)
    end
    file:close()
    
end

function SeedManager:printSeeds()
    local fileContent = self:getFileLines()
    for _, line in ipairs(fileContent) do
        print(line)
    end
end

function SeedManager:writeSeeds(seeds)
    local fileContent = self:getFileLines()
    local exportLine = fileContent[#fileContent]
    fileContent[#fileContent] = nil
    for name, seed in pairs(seeds) do 
        table.insert(fileContent, "allowedSeeds[\""..name.."\"]=\""..seed.."\"\n")
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
        print("Enter seed name for "..item.name .. ": ")
        local localSeedName = read()
        if localSeedName == "" then
            goto continue
        end
        seeds[localSeedName] = item.name
        ::continue::
    end
    self:writeSeeds(seeds)
end

