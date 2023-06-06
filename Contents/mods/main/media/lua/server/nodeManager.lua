local nodeManager = {}

nodeManager.zones = {}

---nodeZone template
nodeManager.nodeZone = { x1=-1, y1=-1, x2=-1, y2=-1, maxNodes=0, respawnTimer=0, minerals = {}, }
-- minerals = {}:  `["mineralID"]=chance` to appear

function nodeManager.addZone(x1, y1, x2, y2, minerals)
    local newZone = copyTable(nodeManager.nodeZone)
    newZone.x1, newZone.y1, newZone.x2, newZone.y2, newZone.minerals = x1, y1, x2, y2, minerals
end


function nodeManager.init(isNewGame)
    print("nodeManager:init")
    nodeManager.zones = ModData.getOrCreate("miningChucked_zones")
end


return nodeManager

