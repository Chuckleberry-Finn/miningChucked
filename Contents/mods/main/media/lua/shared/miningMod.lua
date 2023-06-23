local miningMod = {}

miningMod.resources = {}

function miningMod.spawnNode(nodeX, nodeY, mineral)
    print("SPAWNING NODE ACTUAL")
    if isServer() then
        sendServerCommand("miningChucked", "spawnNode", {mineral=mineral, nodeX=nodeX, nodeY=nodeY})
    else
        local mineData = miningMod.resources[mineral]

        local cell = getWorld():getCell()
        if not cell then return print("NO CELL") end

        local sq = cell:getGridSquare(nodeX, nodeY, 0)
        if not sq then return print("NO SQUARE") end

        local node = IsoThumpable.new(cell, sq, mineData.textures[ZombRand(2)+1], false, nil)
        node:setIsThumpable(false)
        sq:AddSpecialObject(node)
        node:transmitCompleteItemToServer()

        print("node:"..tostring(node))
        --getCell():setDrag(node, getPlayer():getPlayerNum())
    end
end

return miningMod