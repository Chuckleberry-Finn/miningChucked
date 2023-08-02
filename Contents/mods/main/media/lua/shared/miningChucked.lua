local miningChucked = {}

miningChucked.resources = {}

---nodeZone template
-- minerals = {}:  `["mineralID"]=chance` to appear
miningChucked.Zone = {
    maxNodes=0,
    respawnTimer=0,
    coordinates={x1=-1, y1=-1, x2=-1, y2=-1},
    minerals = {},
    currentNodes = {},-- {{x=0, y=0,}},
    weightedMineralsList = {},
}

miningChucked.ignore = {["currentNodes"]=true,["weightedMineralsList"]=true}

function miningChucked.setMinerals()
    print("populating minerals to default zone")
    for mineralType, mineralData in pairs(miningChucked.resources) do
        print(" --"..mineralType)
        miningChucked.Zone.minerals[mineralType] = 0
    end
end

return miningChucked