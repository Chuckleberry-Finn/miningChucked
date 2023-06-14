ISIndesctructibleBuild = ISBuildingObject:derive("ISIndesctructibleBuild");

function ISIndesctructibleBuild.onDestroy(thump, player)
    return
end

function ISIndesctructibleBuild:create(x, y, z, north, sprite)
    local cell = getWorld():getCell();
    self.sq = cell:getGridSquare(x, y, z);
    self.javaObject = IsoThumpable.new(cell, self.sq, sprite, north, self);
    buildUtil.setInfo(self.javaObject, self);
    buildUtil.consumeMaterial(self);
    self.javaObject:setIsThumpable(false);
    -- the sound that will be played when our door frame will be broken
    self.javaObject:setBreakSound("BreakObject");
    -- add the item to the ground
    self.sq:AddSpecialObject(self.javaObject);

    self.javaObject:transmitCompleteItemToServer();
end

function ISIndesctructibleBuild:removeFromGround(square)
    for i = 0, square:getSpecialObjects():size() do
        local thump = square:getSpecialObjects():get(i);
        if instanceof(thump, "IsoThumpable") then
            square:transmitRemoveItemFromSquare(thump);
        end
    end
end

function ISIndesctructibleBuild:new(name, sprite, northSprite)
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o:init();
    o:setSprite(sprite);
    o:setNorthSprite(northSprite);
    o.name = name;
    o.canBarricade = false;
    o.dismantable = true;
    o.blockAllTheSquare = true;
    o.canBeAlwaysPlaced = true;
    o.buildLow = true;
    return o;
end

function ISIndesctructibleBuild:isValid(square)
    if not ISBuildingObject.isValid(self, square) then return false; end
    if not buildUtil.canBePlace(self, square) then return false end
    if self.needToBeAgainstWall then
        for i = 0, square:getObjects():size() - 1 do
            local obj = square:getObjects():get(i);
            if (self.north and obj:getProperties():Is("WallN")) or (not self.north and obj:getProperties():Is("WallW")) then
                return true;
            end
        end
        return false;
    else
        if buildUtil.stairIsBlockingPlacement(square, true) then return false; end
    end
    return true;
end

function ISIndesctructibleBuild:render(x, y, z, square)
    ISBuildingObject.render(self, x, y, z, square)
end
