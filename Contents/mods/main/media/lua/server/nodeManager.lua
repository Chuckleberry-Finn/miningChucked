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


function nodeManager.addZone(x1, y1, x2, y2, minerals)
    local newZone = copyTable(nodeManager.nodeZone)
    newZone.x1, newZone.y1, newZone.x2, newZone.y2, newZone.minerals = x1, y1, x2, y2, minerals
end


function nodeManager.init(isNewGame)
    print("nodeManager:init")
    nodeManager.zones = ModData.getOrCreate("miningChucked_zones")
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


function nodeManager.spawnNode(nodeZone)
    --spawnNode
    local x1, y1, x2, y2 = nodeZone.x1, nodeZone.y1, nodeZone.y1, nodeZone.y2

    local nodeX = ZombRand(x1,x2+1)
    local nodeY = ZombRand(y1,y2+1)
    
    --create a weighted list
    if not nodeZone.weightedMineralsList then nodeManager.createWeightedMineralsList(nodeZone) end
    local mineral = nodeZone.weightedMineralsList[ZombRand(#nodeZone.weightedMineralsList)+1]

    local mineData = miningMod.resources[mineral]

    local cell = getWorld():getCell()
    local sq = cell:getGridSquare(nodeX, nodeY, 0)

    local node = IsoThumpable.new(cell, sq, mineData.textures[ZombRand(2)+1], false, nil)
    node:setIsThumpable(false)
    sq:AddSpecialObject(node)
    node:transmitCompleteItemToServer()

    --getCell():setDrag(_table, player)

    table.insert(nodeZone.currentNodes, {nodeX, nodeY} )
end


return nodeManager

