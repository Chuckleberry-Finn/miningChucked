local miningMod = require('miningMod')

local function onServerCommand(_module, _command, _data)
    if _module ~= "miningChucked" then return end
    _data = _data or {}

    if _command == "spawnNode" then
        miningMod.spawnNode(_data.nodeX, _data.nodeY, _data.mineral)
    end
end
Events.OnServerCommand.Add(onServerCommand)