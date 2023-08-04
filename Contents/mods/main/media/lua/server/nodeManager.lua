if isClient() then return end

local miningChucked = require('miningChucked')

local targetSquareOnLoad = require "!_TargetSquare_OnLoad"

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



function nodeManager.spawnNode(square, zoneID, sprite, mineral)

    if not square then print("ERROR: nodeManager.spawnNode: no square reached, aborting node spawn.") end
    local cell = square:getCell()

    ---@type IsoThumpable|IsoObject
    local node = IsoThumpable.new(cell, square, sprite, false, nil)
    node:setName(mineral)
    node:setIsThumpable(false)
    square:AddSpecialObject(node)
    node:transmitCompleteItemToServer()

    local nodeZone
    for i,zone in pairs(nodeManager.zones) do
        if zone and zone.ID and zone.ID == zoneID then
            nodeZone = zone
        end
    end

    local nodeX, nodeY = square:getX(), square:getY()

    if nodeZone then
        table.insert(nodeZone.currentNodes, {nodeX, nodeY} )
        print(" -- SPAWNING NODE: "..nodeX..", "..nodeY.."  ("..mineral..")")
    else
        print("ERROR: spawnNode: zone is not found, unable to spawn node")
    end
end


function nodeManager.addCommand()
    targetSquareOnLoad.instance.OnLoadCommands.spawnNode = function(square, myCommand)
        nodeManager.spawnNode(square, myCommand.zoneID, myCommand.sprite, myCommand.mineral)
    end
end
Events.OnSGlobalObjectSystemInit.Add(nodeManager.addCommand)


function nodeManager.tryToSpawnNode(nodeZone)
    local x1, y1, x2, y2 = nodeZone.coordinates.x1, nodeZone.coordinates.y1, nodeZone.coordinates.x2, nodeZone.coordinates.y2

    local nodeX = ZombRand(x1,x2+1)
    local nodeY = ZombRand(y1,y2+1)

    --create a weighted list
    if (not nodeZone.weightedMineralsList) or (#nodeZone.weightedMineralsList <= 0) then nodeManager.createWeightedMineralsList(nodeZone) end

    local mineralSelection = ZombRand(#nodeZone.weightedMineralsList)+1
    local mineral = nodeZone.weightedMineralsList[mineralSelection]
    local mineData = miningChucked.resources[mineral]

    if not mineData then print("ERROR: mineral:"..mineral.." is not valid, unable to spawn node") return end

    local sprite = mineData.textures[ZombRand(2)+1]

    if not nodeZone.ID then nodeZone.ID = getRandomUUID() end
    local zoneID = nodeZone.ID

    local sq = getSquare(nodeX, nodeY, 0)
    if not sq then
        print(" -- targetSquareOnLoad: no square reached, storing spawn event.")
        targetSquareOnLoad.instance.addCommand(nodeX, nodeY, 0, { command="spawnNode", zoneID=zoneID, sprite=sprite, mineral=mineral })
        return
    end

    nodeManager.spawnNode(sq, zoneID, sprite, mineral)
end


function nodeManager.cycle()
    local zoneCount, spawning = 0, 0
    for i,zone in pairs(nodeManager.zones) do
        zoneCount = zoneCount+1
        zone.currentTimer = (zone.currentTimer or zone.respawnTimer) - 1
        if zone.currentTimer <= 0 then
            zone.currentTimer = zone.respawnTimer
            nodeManager.scanValidNodes(zone)
            if #zone.currentNodes < zone.maxNodes then
                spawning = spawning+1
                nodeManager.tryToSpawnNode(zone)
            end
        end
    end

    if spawning>0 then print("nodeManager.cycle: "..spawning.."/"..zoneCount.." spawning nodes.") end
end


return nodeManager