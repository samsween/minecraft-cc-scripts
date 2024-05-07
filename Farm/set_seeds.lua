


SeedManager = {}
SeedManager.__index = SeedManager

setmetatable(SeedManager, {
    __call = function(cls, filename)
        local instance = setmetatable({}, cls)
        instance.filename = filename
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

function SeedManager:writeSeeds(name, seed)
    if not self:isValid(name, seed) then
        print("Invalid seed")
        return
    end
    local file = io.open(fileName)
    if file == nil then
        print("File not found")
        return
    end
    local fileContent = self:GetFileLines()
    fileContent[#fileContent-1] = "allowedSeeds[\""..name.."\"]=\""..seed.."\"\n"
    self:writeFile(fileContent)
end
