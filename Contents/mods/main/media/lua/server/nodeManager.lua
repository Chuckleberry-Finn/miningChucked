local miningMod = require('miningMod')

local nodeManager = {}

nodeManager.zones = {}


---nodeZone template
-- minerals = {}:  `["mineralID"]=chance` to appear
nodeManager.nodeZone = {
    x1=-1, y1=-1, x2=-1, y2=-1,
    maxNodes=0, respawnTimer=0,
    minerals = {},
    currentNodes = {},-- {{x=0, y=0,}},
    weightedMineralsList = {},
}


function nodeManager.addZone(x1, y1, x2, y2, minerals, maxNodes)
    local newZone = copyTable(nodeManager.nodeZone)
    newZone.x1, newZone.y1, newZone.x2, newZone.y2, newZone.minerals, newZone.maxNodes = x1, y1, x2, y2, minerals, maxNodes
    table.insert(nodeManager.zones, newZone)
end


function nodeManager.init(isNewGame)
    print("nodeManager:init")
    nodeManager.zones = ModData.getOrCreate("miningChucked_zones")

    nodeManager.zones = {}
    nodeManager.addZone(12040, 7375, 12050, 7390, { ["Coal"]=3, ["Iron"]=1 }, 10)
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
        if not cell then return print("NO CELL") end

        ---@type IsoGridSquare
        local sq = cell:getGridSquare(nodeCoords[1], nodeCoords[2], 0)
        if not sq then return print("NO SQUARE") end

        local objects = sq:getSpecialObjects()

        local nodeFound = false

        for i=0, objects:size()-1 do
            ---@type IsoThumpable|IsoObject
            local node = objects:get(i)
            if instanceof(node, "IsoThumpable") then
                print("NODE?: ",node:getObjectName(), node:getSpriteName(), node:getTextureName())
            end
        end

        if not nodeFound then nodeZone.currentNodes[i] = nil end
    end
end


function nodeManager.spawnNode(nodeZone)
    --spawnNode

    nodeManager.scanValidNodes(nodeZone)

    print("SPAWN NODE:")

    local x1, y1, x2, y2 = nodeZone.x1, nodeZone.y1, nodeZone.x2, nodeZone.y2

    local nodeX = ZombRand(x1,x2+1)
    local nodeY = ZombRand(y1,y2+1)

    --create a weighted list
    if (not nodeZone.weightedMineralsList) or (#nodeZone.weightedMineralsList <= 0) then nodeManager.createWeightedMineralsList(nodeZone) end

    local mineralSelection = ZombRand(#nodeZone.weightedMineralsList)+1
    local mineral = nodeZone.weightedMineralsList[mineralSelection]
    print("mineral check: "..tostring(mineral).."   : "..mineralSelection.."/"..#nodeZone.weightedMineralsList)
    miningMod.spawnNode(nodeX, nodeY, mineral)
    table.insert(nodeZone.currentNodes, {nodeX, nodeY} )
end


function nodeManager.cycle()
    for i,zone in pairs(nodeManager.zones) do
        if #zone.currentNodes < zone.maxNodes then
            nodeManager.spawnNode(zone)
        end
    end
end


return nodeManager

