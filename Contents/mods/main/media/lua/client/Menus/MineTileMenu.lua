local miningMod = require('miningMod')

local placeNodesContextMenu = {}

placeNodesContextMenu.OnFillWorldObjectContextMenu = function(player, context, worldObjects, test)
    if not isDebugEnabled() and not isAdmin() then return end
    if getCore():getGameMode() == 'LastStand' then return end
    if test and ISWorldObjectContextMenu.Test then return true end

    local playerObj = getSpecificPlayer(player)
    if playerObj:getVehicle() then return end

    local newOptionMenu = context:addOption(getText('ContextMenu_PlaceNodes'))
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(newOptionMenu, subMenu)

    local mines = miningMod.resources
    for i, mine in pairs(mines) do
        local menuOption = subMenu:addOption(mine.menuName, worldObjects, placeNodesContextMenu.onBuildIndesctructibleBuild, player,
            mine.mineType, mine.textures[1], mine.textures[2])
        placeNodesContextMenu.AddTooltip(menuOption, player, mine.menuName, mine.textures[2])
    end
end


placeNodesContextMenu.onBuildIndesctructibleBuild = function(ignoreThisArgument, player, name, sprite, sprite2)
    local _table = ISIndesctructibleBuild:new(name, sprite, sprite2)

    _table.player = player
    _table.name = name

    getCell():setDrag(_table, player)
end


placeNodesContextMenu.AddTooltip = function(option, player, name, texture)
    local tooltip = ISBuildMenu.canBuild(0, 0, 0, 0, 0, 0, option, player)
    tooltip:setName(name)
    tooltip:setTexture(texture)
end


Events.OnFillWorldObjectContextMenu.Add(placeNodesContextMenu.OnFillWorldObjectContextMenu)
