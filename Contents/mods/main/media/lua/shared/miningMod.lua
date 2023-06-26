local miningMod = {}

miningMod.resources = {}

function miningMod.copyAgainst(tableA,tableB)
    if not tableA or not tableB then return end
    for key,value in pairs(tableB) do tableA[key] = value end
    for key,_ in pairs(tableA) do if not tableB[key] then tableA[key] = nil end end
end

return miningMod