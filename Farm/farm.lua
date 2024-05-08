local allowedSeeds = require("allowed_seeds")
local SeedManager = require("seed_manager")
Farm = {}
Farm.__index = Farm

setmetatable(Farm, {
    __call = function(cls)
        local instance = setmetatable({}, cls)
        instance.refinedPeripheral = peripheral.find("rsBridge")
        instance.allowedSeeds = allowedSeeds
        instance.seedManager = SeedManager("Farm/allowed_seeds.lua")
        return instance
    end
})

function Farm:clearFarm()
    redstone.setOutput("left", true)
    sleep(2)
    redstone.setOutput("left", false)
end

function Farm:plantFarm()
    redstone.setOutput("right", true)
    sleep(2)
    redstone.setOutput("right", false)
end

function Farm:getSeedAmount(seed)
    local item = self.refinedPeripheral.getItem({ name = seed })
    return item["amount"]
end

function Farm:printSeeds()
    for name, seed in pairs(self.allowedSeeds) do
        local s = self.refinedPeripheral.getItem({ name = seed })
        if (s == nil) then
            print("Seed not found: " .. name)
            return
        end
        print(name .. " : " .. s["amount"])
    end
end

function Farm:isSeedAvailable(seed)
    local amount = self.getSeedAmount(seed)
    if amount <= 0 then
        print(seed .. " is not available")
        return false
    end
    return true
end

function Farm:exportSeeds(seeds)
    local farmArea = 80 -- Total farm area
    local maxSeeds = #seeds
    local numPerSeed = math.floor(farmArea / maxSeeds)
    local valid = true
    for _, seed in ipairs(seeds) do
        if not self:isSeedAvailable(seed) then
            valid = false
            break -- Exit early if a seed is not available
        end
    end
    -- Proceed with export if all seeds are available
    if valid then
        for _, seed in ipairs(seeds) do
            self.refinedPeripheral.exportItem({ name = seed, count = numPerSeed }, "right")
        end
    else
        print("One or more seeds are not available. Export aborted.")
    end
end

function Farm:SetSeeds(args)
    local validArgs = {}
    validArgs["chest"] = true
    validArgs["command"] = true
    validArgs["file"] = true
    local givenArg = args[1]
    if not validArgs[givenArg] then
        print("Invalid argument. Please provide a valid argument")
        print("Valid arguments are: chest, command, file")
        return
    end
    if givenArg == "chest" then
        self.seedManager:setSeedsFromChest()
    elseif givenArg == "command" then
        self.seedManager:setSeedsFromCommand(args)
    elseif givenArg == "file" then
        self.seedManager:setSeedsFromFile(args)
    end
end

function Farm:start(args)
    local validArgs = {}
    validArgs["clear"] = true
    validArgs["plant"] = true
    validArgs["print"] = true
    validArgs["export"] = true
    local givenArg = args[1]
    if not validArgs[givenArg] then
        print("Invalid argument. Please provide a valid argument.")
        return
    end
    if givenArg == "clear" then
        self:clearFarm()
    elseif givenArg == "plant" then
        self:plantFarm()
    elseif givenArg == "print" then
        self:printSeeds()
    elseif givenArg == "export" then
        local seeds = {}
        for i = 2, #args do
            table.insert(seeds, args[i])
        end
        self:exportSeeds(seeds)
    elseif givenArg == "set" then
        self:SetSeeds(args)
    end
end

return Farm
