local nodeManager = require "nodeManager"
if nodeManager then

    Events.OnInitGlobalModData.Add(nodeManager.init)
    -- OnTick EveryOneMinute EveryTenMinutes EveryDays EveryHours

    local miningChucked = require('miningChucked')
    for mineralType, mineralData in pairs(miningChucked.resources) do
        miningChucked.Zone.minerals[mineralType] = 0
    end

    Events.EveryTenMinutes.Add(nodeManager.cycle)
end

