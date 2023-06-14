if not getMiningModInstance then
  require('MiningMod')
end

MiningMod = getMiningModInstance()

MiningMenu = {}

local function predicatePickAxe(item)
  return item:hasTag("PickAxe") or item:getType() == "PickAxe"
end

local function predicateNotBroken(item)
  return not item:isBroken()
end

MiningMenu.OnFillWorldObjectContextMenu = function(player, context, worldobjects, test)
  if getCore():getGameMode() == 'LastStand' then
    return
  end

  if test and ISWorldObjectContextMenu.Test then
    return true
  end

  local playerObj = getSpecificPlayer(player)
  if playerObj:getVehicle() then
    return
  end

  local ore = nil
  local oreData = nil
  for i, v in pairs(worldobjects) do
    local name = v:getName()
    if name then
      for index, currentOreData in pairs(MiningMod.resources) do
        if name == index then
          ore = v
          oreData = currentOreData
        end
      end
    end
  end

  if not ore or not oreData then return end

  MiningMenu.TableMenuBuilder(context, worldobjects, player, ore, oreData)
end

MiningMenu.getPickaxe = function(playerInv)
  if (playerInv:containsTypeRecurse("PickAxe") and playerInv:containsEvalRecurse(predicatePickAxe)) then
    return playerInv:getItemFromType("PickAxe", true, true)
  end

  return nil
end

MiningMenu.TableMenuBuilder = function(context, worldobjects, player, ore, oreData)
  local playerObj = getPlayer(player)
  local playerInv = playerObj:getInventory()
  local showTooltop = false

  local toolTip = ISToolTip:new()
  toolTip:initialise();
  toolTip:setVisible(false);

  if not MiningMenu.getPickaxe(playerInv) then
    toolTip.description = toolTip.description ..
        '<LINE> <RGB:1,0,0>' ..
        getText("Tooltip_Require_Pickaxe") .. ' <LINE>'
    playerObj:Say(getText("Tooltip_Require_Pickaxe"))
    showTooltop = true

    return
  end

  if playerObj:getPerkLevel(Perks.MineEndurance) < 2 then
    toolTip.description = toolTip.description ..
        '<LINE> <RGB:1,0,0>' ..
        getText("Tooltip_Require_Endurance") .. ' <LINE>'
    playerObj:Say(getText("Tooltip_Require_Endurance"))
    showTooltop = true

    return
  end

  local menuOption = context:addOption(oreData.menuAction, worldobjects,
    MiningMenu.Mine, player, ore, oreData)

  if showTooltop then
    menuOption.toolTip = toolTip
  end
end


MiningMenu.Mine = function(this, player, ore, oreData)
  local playerObj = getPlayer(player)
  local playerInv = playerObj:getInventory()
  local pickaxe = MiningMenu.getPickaxe(playerInv)

  if not pickaxe:isEquipped() then
    ISInventoryPaneContextMenu.equipWeapon(pickaxe, false, true, player)
  end

  local adjacent = AdjacentFreeTileFinder.Find(ore:getSquare(), playerObj)
  ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, adjacent))

  local mineOre = ISMineOre:new(playerObj, ore, 475)
  print(oreData.menuName)
  mineOre.oreData = oreData
  ISTimedActionQueue.add(mineOre);

  local pickaxe = playerObj:getInventory():getFirstTagEvalRecurse("Pickaxe", predicateNotBroken)
  if not pickaxe then return end
  ISWorldObjectContextMenu.equip(playerObj, playerObj:getPrimaryHandItem(), pickaxe, true, true)
end

Events.OnFillWorldObjectContextMenu.Add(MiningMenu.OnFillWorldObjectContextMenu)
