if isClient() then return end

local miningChucked = require('miningChucked')

local nodeManager = {}
nodeManager.zones = {}

function nodeManager.receiveGlobalModData(name, data)
    if name == "miningChucked_zones" then
        ModData.remove("miningChucked_zones")
        ModData.add("miningChucked_zones",data)
    end
end
Events.OnReceiveGlobalModData.Add(nodeManager.receiveGlobalModData)


function nodeManager.addZone(x1, y1, x2, y2, minerals, maxNodes)
    local newZone = copyTable(miningChucked.Zone)
    newZone.coordinates.x1, newZone.coordinates.y1, newZone.coordinates.x2, newZone.coordinates.y2, newZone.minerals, newZone.maxNodes = x1, y1, x2, y2, minerals, maxNodes
    table.insert(nodeManager.zones, newZone)
    ModData.transmit("miningChucked_zones")
end


function nodeManager.init(isNewGame)
    nodeManager.zones = ModData.getOrCreate("miningChucked_zones")
    ---test---
    --[[
    if #nodeManager.zones < 3 then
        nodeManager.addZone(12040, 7375, 12050, 7390, { ["Coal"]=3, ["Iron"]=1 }, 10)
        nodeManager.addZone(1000, 1000, 2000, 2000, { ["Coal"]=3, ["Iron"]=1 }, 10)
        nodeManager.addZone(5000, 5000, 6000, 6000, { ["Coal"]=3, ["Iron"]=1 }, 10)
    end--]]
end


function nodeManager.createWeightedMineralsList(nodeZone)
    local mineralChoices = {}
    for mineral,weightedChance in pairs(nodeZone.minerals) do
        for iteration=1, weightedChance do
            table.insert(mineralChoices, mineral)
        end
    end
    nodeZone.weightedMineralsList = mineralChoices
end


function nodeManager.scanValidNodes(nodeZone)
    for i,nodeCoords in pairs(nodeZone.currentNodes) do

        local cell = getWorld():getCell()
        if not cell then return end

        ---@type IsoGridSquare
        local sq = cell:getGridSquare(nodeCoords[1], nodeCoords[2], 0)
        if not sq then return end

        local objects = sq:getSpecialObjects()
        local nodeFound = false
        for i=0, objects:size()-1 do
            ---@type IsoThumpable|IsoObject
            local node = objects:get(i)
            if instanceof(node, "IsoThumpable") and node:getTextureName() and (string.find(node:getTextureName(), "mines_")) then
                nodeFound = true
            end
        end

        if not nodeFound then nodeZone.currentNodes[i] = nil end
    end
end


function nodeManager.spawnNode(nodeZone)
    --spawnNode
    local x1, y1, x2, y2 = nodeZone.coordinates.x1, nodeZone.coordinates.y1, nodeZone.coordinates.x2, nodeZone.coordinates.y2

    local nodeX = ZombRand(x1,x2+1)
    local nodeY = ZombRand(y1,y2+1)

    --create a weighted list
    if (not nodeZone.weightedMineralsList) or (#nodeZone.weightedMineralsList <= 0) then nodeManager.createWeightedMineralsList(nodeZone) end

    local mineralSelection = ZombRand(#nodeZone.weightedMineralsList)+1
    local mineral = nodeZone.weightedMineralsList[mineralSelection]
    local mineData = miningChucked.resources[mineral]

    if not mineData then
        print("ERROR: mineral:"..mineral.." is not valid.")
        return
    end

    local cell = getWorld():getCell()
    if not cell then return end

    local sq = cell:getGridSquare(nodeX, nodeY, 0)
    if not sq then return end

    ---@type IsoThumpable|IsoObject
    local node = IsoThumpable.new(cell, sq, mineData.textures[ZombRand(2)+1], false, nil)
    node:setName(mineral)
    node:setIsThumpable(false)
    sq:AddSpecialObject(node)
    node:transmitCompleteItemToServer()

    --getCell():setDrag(node, getPlayer():getPlayerNum())
    
    table.insert(nodeZone.currentNodes, {nodeX, nodeY} )
    print(" -- SPAWNING NODE: "..nodeX..", "..nodeY.."  ("..mineral..")")
end


function nodeManager.cycle()
    local zoneCount = 0
    for i,zone in pairs(nodeManager.zones) do
        zoneCount = zoneCount+1
        nodeManager.scanValidNodes(zone)
        if #zone.currentNodes < zone.maxNodes then
            nodeManager.spawnNode(zone)
        end
    end
    print("nodeManager.cycle: # of zones: "..zoneCount)
end


return nodeManager

