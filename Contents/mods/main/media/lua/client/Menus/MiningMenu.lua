local miningChucked = require('miningChucked')

local miningActionContextMenu = {}

local function predicatePickAxe(item) return item:hasTag("PickAxe") or item:getType() == "PickAxe" end
local function predicateNotBroken(item) return not item:isBroken() end

miningActionContextMenu.OnFillWorldObjectContextMenu = function(player, context, worldobjects, test)
  if getCore():getGameMode() == 'LastStand' then return end
  if test and ISWorldObjectContextMenu.Test then return true end

  local playerObj = getSpecificPlayer(player)
  if playerObj:getVehicle() then return end

  local ore = nil
  local oreData = nil
  for i, v in pairs(worldobjects) do
    local name = v:getName()
    if name then
      for index, currentOreData in pairs(miningChucked.resources) do
        if name == index then
          ore = v
          oreData = currentOreData
        end
      end
    end
  end

  if not ore or not oreData then return end

  miningActionContextMenu.TableMenuBuilder(context, worldobjects, player, ore, oreData)
end

miningActionContextMenu.getPickaxe = function(playerInv)
  if (playerInv:containsTypeRecurse("PickAxe") and playerInv:containsEvalRecurse(predicatePickAxe)) then return playerInv:getItemFromType("PickAxe", true, true) end
  return nil
end

miningActionContextMenu.TableMenuBuilder = function(context, worldobjects, player, ore, oreData)
  local playerObj = getPlayer(player)
  local playerInv = playerObj:getInventory()
  local showTooltop = false

  local toolTip = ISToolTip:new()
  toolTip:initialise()
  toolTip:setVisible(false)

  if not miningActionContextMenu.getPickaxe(playerInv) then
    toolTip.description = toolTip.description .. '<LINE> <RGB:1,0,0>' .. getText("Tooltip_Require_Pickaxe") .. ' <LINE>'
    playerObj:Say(getText("Tooltip_Require_Pickaxe"))
    showTooltop = true
    return
  end
  local optionName = getText("ContextMenu_Mine").." "..getText("ContextMenu_"..oreData.mineType)
  local menuOption = context:addOption(optionName, worldobjects, miningActionContextMenu.Mine, player, ore, oreData)
  if showTooltop then menuOption.toolTip = toolTip end
end


miningActionContextMenu.Mine = function(this, player, ore, oreData)
  local playerObj = getPlayer(player)
  local playerInv = playerObj:getInventory()
  local pickaxe = miningActionContextMenu.getPickaxe(playerInv)

  if not pickaxe:isEquipped() then ISInventoryPaneContextMenu.equipWeapon(pickaxe, false, true, player) end

  local adjacent = AdjacentFreeTileFinder.Find(ore:getSquare(), playerObj)
  ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, adjacent))

  local mineOre = ISMineOre:new(playerObj, ore, 475)
  mineOre.oreData = oreData
  ISTimedActionQueue.add(mineOre)

end


Events.OnFillWorldObjectContextMenu.Add(miningActionContextMenu.OnFillWorldObjectContextMenu)
