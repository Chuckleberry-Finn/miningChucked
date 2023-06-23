local nodeManager = require "nodeManager"

Events.OnInitGlobalModData.Add(nodeManager.init)

-- OnTick
-- EveryOneMinute
-- EveryTenMinutes
-- EveryDays
-- EveryHours

Events.EveryTenMinutes.Add(nodeManager.cycle)

