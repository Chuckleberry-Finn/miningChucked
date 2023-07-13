local miningChucked = require('miningChucked')


ISMineOre = ISBaseTimedAction:derive("ISMineIron")


local function predicateNotBroken(item)
    return not item:isBroken()
end


function ISMineOre:isValid()
    return true
end


function ISMineOre:waitToStart()
    self.character:faceThisObjectAlt(self.item)
    return self.character:shouldBeTurning()
end


function ISMineOre:start()
    self:setActionAnim("Mining")
    self.character:faceThisObject(self.thumpable)
    self.sound = self.character:playSound("Mining_Pickaxe")
end


function ISMineOre:update()
    self.character:faceThisObjectAlt(self.item)
end


function ISMineOre:stop()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
        self.sound = nil
    end
    ISBaseTimedAction.stop(self)
end


function ISMineOre:perform()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
        self.sound = nil
    end

    ISBaseTimedAction.perform(self)

    self.character:getStats():setEndurance(self.character:getStats():getEndurance() - 0.15)

    local oreType = self.oreData.mineType
    if miningChucked.resources[oreType] then
        for _, v in pairs(miningChucked.resources[oreType].lootTables) do
            self:processLoot(v)
        end
    end
end

function ISMineOre:new(character, item, time)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.item = item
    o.stopOnWalk = true
    o.stopOnRun = true
    o.maxTime = time - (character:getPerkLevel(Perks.Strength) * 10)
    if character:isTimedActionInstant() then o.maxTime = 1 end
    o.caloriesModifier = 8
    return o
end


function ISMineOre:processLoot(loot)
    if loot.fixedAmount and loot.fixedAmount>0 then
        self:addItems(loot.item, loot.fixedAmount)
        return
    end

    local miningLevel = self.character:getPerkLevel(Perks.Mining)

    if loot.requireLevel then
        for _, v in pairs(loot.amountPerLevel) do
            for _, level in pairs(v.levels) do
                if miningLevel == level then
                    local extra = ZombRand(v.amounts.max - v.amounts.min + 1)
                    local finalAmount = v.amounts.min + extra
                    self:addItems(loot.item, finalAmount)
                    return
                end
            end
        end
    end
end


function ISMineOre:addItems(item, amount)
    if amount <= 0 then return end
    self.character:getInventory():AddItems(item, amount)
end
