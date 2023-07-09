local miningMod = {}

miningMod.resources = {}

---nodeZone template
-- minerals = {}:  `["mineralID"]=chance` to appear
miningMod.Zone = {
    maxNodes=0,
    respawnTimer=0,
    coordinates={x1=-1, y1=-1, x2=-1, y2=-1},
    minerals = {},
    currentNodes = {},-- {{x=0, y=0,}},
    weightedMineralsList = {},
}

miningMod.ignore = {["currentNodes"]=true,["weightedMineralsList"]=true}
miningMod.addKeys = {["minerals"]= {"New",1}}

return miningMod