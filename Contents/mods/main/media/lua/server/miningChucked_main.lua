local nodeManager = require "nodeManager"
if nodeManager then
    Events.OnInitGlobalModData.Add(nodeManager.init)
    -- OnTick EveryOneMinute EveryTenMinutes EveryDays EveryHours
    Events.EveryTenMinutes.Add(nodeManager.cycle)
end

