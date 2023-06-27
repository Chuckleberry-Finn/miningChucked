require "ISUI/ISPanel"

zoneEditor = ISPanel:derive("zoneEditor")
zoneEditor.instance = nil
zoneEditor.dataListObj = {}
zoneEditor.dataListName = {}

function zoneEditor.OnOpenPanel(obj, name)
    if not isAdmin() and not isCoopHost() and not getDebug() then return end

    if zoneEditor.instance==nil then

        zoneEditor.instance = zoneEditor:new(100, 100, 650, 475, "Inspect")
        zoneEditor.instance:initialise()
        zoneEditor.instance:instantiate()
    end

    zoneEditor.instance:addToUIManager()
    zoneEditor.instance:setVisible(true)
    zoneEditor.instance:populateZoneList()

    return zoneEditor.instance
end


function zoneEditor:initialise()
    ISPanel.initialise(self)
    self.firstTableData = false
end


function zoneEditor:createChildren()
    ISPanel.createChildren(self)

    self.junk, self.inspectingTitleHeader = ISDebugUtils.addLabel(self, {}, 15, 8, "Zone Editor", UIFont.Large, true)
    self.inspectingTitleHeader:setColor(0.9,0.9,0.9)

    local zoneListWidth = self.width-400
    local zoneListHeight = self.width-zoneListWidth-20

    self.zoneList = ISScrollingListBox:new(10, 40, zoneListWidth, zoneListHeight)
    self.zoneList:initialise()
    self.zoneList:instantiate()
    self.zoneList.itemheight = 22
    self.zoneList.joypadParent = self
    self.zoneList.font = UIFont.NewSmall
    self.zoneList.doDrawItem = self.drawZoneList
    self.zoneList.drawBorder = true
    self.zoneList.onmousedown = zoneEditor.OnZoneListMouseDown
    self.zoneList.target = self
    self:addChild(self.zoneList)

    self.zoneEditPanel = ISScrollingListBox:new(self.zoneList.x+5, self.zoneList.y, zoneListWidth-10, 20)
    self.zoneEditPanel:initialise()
    self.zoneEditPanel:instantiate()
    self.zoneEditPanel.itemheight = 20
    self.zoneEditPanel.joypadParent = self
    self.zoneEditPanel.font = UIFont.NewSmall
    self.zoneEditPanel.doDrawItem = self.drawZoneEditPanel
    self.zoneEditPanel.drawBorder = false
    self.zoneEditPanel.onmousedown = zoneEditor.OnZoneEditPanelMouseDown
    self.zoneEditPanel.target = self
    self:addChild(self.zoneEditPanel)
    self.zoneEditPanel:setVisible(false)

    local w = self.zoneList.width
    local buttonH, buttonW, buttonPad = 20, 100, 10

    self:setHeight(self.zoneList.y+self.zoneList.height+buttonH+(buttonPad*2))

    local y, button = ISDebugUtils.addButton(self,"close",self.width-buttonW-buttonPad,self.height-buttonPad-buttonH, buttonW,buttonH, "Close", zoneEditor.onClickClose)
    self.closeButton = button

    y, button = ISDebugUtils.addButton(self,"addZone", buttonPad,self.height-buttonPad-buttonH, buttonW,buttonH, "Add Zone", zoneEditor.onClickAddZone)
    self.addZoneButton = button

    y, button = ISDebugUtils.addButton(self,"addZone", self.zoneList.x+self.zoneList.width-20,0, 20,20, "X", zoneEditor.onClickRemoveZone)
    self.removeZoneButton = button
    self.removeZoneButton:setVisible(false)

    self.scrollingZoom = 100
end


function zoneEditor:onClickClose() self:close() end

function zoneEditor:onClickAddZone()
    sendClientCommand("nodeManager", "addZone", {x1=0, y1=0, x2=0, y2=0, minerals={}, maxNodes=0})
    self.refresh = 2
end

function zoneEditor:onClickRemoveZone()
    if not self.zones then return end
    for i, zone in pairs(self.zones) do
        if self.zoneList.items[self.zoneList.selected].item == zone then
            self.zones[i] = nil
            ModData.transmit("miningChucked_zones")
        end
    end
    self:populateZoneList()
end


function zoneEditor:OnZoneListMouseDown(item)
    --print("OnZoneListMouseDown: "..tostring(item))
end

function zoneEditor:OnZoneEditPanelMouseDown(item)
    if zoneEditor.instance.zoneEditPanel.clickSelected == item then
        zoneEditor.instance.zoneEditPanel.clickSelected = nil
    else
        zoneEditor.instance.zoneEditPanel.clickSelected = item
    end
    zoneEditor.instance:populateZoneEditPanel(zoneEditor.instance.zoneList.items[zoneEditor.instance.zoneList.selected].item)
end


function zoneEditor:populateZoneList()
    self.zoneList:clear()
    self.refresh = 0
    self.removeZoneButton:setVisible(false)
    self.zoneEditPanel:setVisible(false)

    self.zones = ModData.exists("miningChucked_zones") and ModData.get("miningChucked_zones") or nil
    if self.zones then
        for i, zone in pairs(self.zones) do
            local label = "damaged zone"
            if zone and zone.coordinates and zone.coordinates.x1 then
                label = "x1:"..zone.coordinates.x1..", y1:"..zone.coordinates.y1..", x2:"..zone.coordinates.x2..", y2:"..zone.coordinates.y2
            end
            self.zoneList:addItem(label, zone)
            self:populateZoneEditPanel(zone)
        end
    end
end

zoneEditor.ignore = {["currentNodes"]=true,["weightedMineralsList"]=true}

function zoneEditor:populateZoneEditPanel(zone)
    if self.zoneList.items[self.zoneList.selected].item == zone then
        local backup = self.zoneEditPanel.selected
        self.zoneEditPanel:clear()

        for param, value in pairs(zone) do
            if not zoneEditor.ignore[param] then

                local labelValue = (type(value) == "table") and "   []" or " = "..value

                if self.zoneEditPanel.clickSelected == param and labelValue == "   []" then labelValue = "   [  ]" end
                self.zoneEditPanel:addItem(param..labelValue, param)

                if self.zoneEditPanel.clickSelected == param and type(value) == "table" then
                    self.zoneEditPanel.clickSelectedCount = 0
                    for key,val in pairs(value) do
                        self.zoneEditPanel.clickSelectedCount = self.zoneEditPanel.clickSelectedCount+1
                        self.zoneEditPanel:addItem("     "..key.."="..val, key)
                    end
                end
            end
        end

        self.zoneEditPanel.selected = backup
    end
end


function zoneEditor:drawZoneEditPanel(y, item, alt)
    local a = 0.9
    local itemHeight = self.itemheight
    if self.selected == item.index then

        local visualHeight = itemHeight
        if zoneEditor.instance.zoneEditPanel.clickSelected then
            visualHeight = itemHeight + (self.itemheight*zoneEditor.instance.zoneEditPanel.clickSelectedCount)
        end
        self:drawRect(0, (y), self:getWidth(), visualHeight - 1, 0.3, 1.4, 0.7, 0.3)
    end
    self:drawRectBorder(0, (y), self:getWidth(), itemHeight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font)
    return y + itemHeight
end


function zoneEditor:drawZoneList(y, item, alt)
    local a = 0.9

    local itemHeight = self.itemheight

    if self.selected == item.index then

        itemHeight = ((self.fontHgt + (self.itemPadY or 0) * 2)*3)

        local zoneEditPanelH = itemHeight-30
        if self.parent.zoneEditPanel.clickSelected then
            zoneEditPanelH = self.parent.zoneEditPanel.itemheight*self.parent.zoneEditPanel.count
        end

        self:drawRect(0, (y), self:getWidth(), itemHeight - 1, 0.3, 0.7, 0.35, 0.15)

        self.parent.zoneEditPanel:setY(self.parent.zoneList.y+y+25)
        self.parent.zoneEditPanel:setHeight(zoneEditPanelH)
        self.parent.zoneEditPanel:setVisible(true)

        self.parent.removeZoneButton:setY(self.parent.zoneList.y+y)
        self.parent.removeZoneButton:setVisible(true)
    end

    self:drawRectBorder(0, (y), self:getWidth(), itemHeight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font)
    return y + itemHeight
end


function zoneEditor:onMouseWheel(del)
    local scale = self.width-self.zoneList.width-20
    local zoneMapX, zoneMapY = self.zoneList.x+self.zoneList.width+5, self.zoneList.y
    local mouseX, mouseY = self:getMouseX(), self:getMouseY()

    self.scrollingZoom = self.scrollingZoom-(del)
    self.scrollingZoom = math.max(1,math.min(100,self.scrollingZoom))

    if mouseX > zoneMapX and mouseX < zoneMapX+scale and mouseY > zoneMapY and mouseY < zoneMapY+scale then return true end
    return false
end


function zoneEditor:prerender()
    ISPanel.prerender(self)

    local scale = self.width-self.zoneList.width-20
    local zoneMapX, zoneMapY = self.zoneList.x+self.zoneList.width+5, self.zoneList.y

    local metaGrid = getWorld():getMetaGrid()
    local cellsX, cellsY = metaGrid:getWidth(), metaGrid:getHeight()
    local mapSizeX, mapSizeY = cellsX*300, cellsY*300

    for i=0, cellsY do
        local yPos = (zoneMapY+((scale/cellsY)*i))
        --if yPos < zoneMapY+scale then
        self:drawTextureScaledStatic(nil, zoneMapX, yPos, scale, 1, 0.1, 1, 0, 1)
    end

    for i=0, cellsX do
        local xPos = (zoneMapX+((scale/cellsX)*i))
        --if xPos < zoneMapX+scale then
        self:drawTextureScaledStatic(nil, xPos, zoneMapY, 1, scale, 0.1, 1, 1, 0)
    end

    if self.refresh > 0 then
        self.refresh = self.refresh-1
        if self.refresh <= 0 then
            self:populateZoneList()
            self.zoneList.selected = #self.zones
        end
    end

    if self.zones then
        for i, zone in pairs(self.zones) do
            if zone and zone.coordinates and zone.coordinates.x1 then
                local zoneW, zoneH = scale*(math.abs(zone.coordinates.x2-zone.coordinates.x1)/mapSizeX), scale*(math.abs(zone.coordinates.y2-zone.coordinates.y1)/mapSizeY)
                local zoneX, zoneY = zoneMapX+scale*(zone.coordinates.x1/mapSizeX), zoneMapY+scale*(zone.coordinates.y1/mapSizeY)

                self:drawRect(zoneX, zoneY, math.max(1,zoneW), math.max(1,zoneH), 0.5, 1, 0, 0)

                if self.zoneList.items and self.zoneList.items[self.zoneList.selected] and self.zoneList.items[self.zoneList.selected].item == zone then
                    self:drawRectBorder(zoneX, zoneY, math.max(1,zoneW), math.max(1,zoneH), 0.5, 1, 1, 1)
                end
            end
        end
    end

    local player = getPlayer()
    local playerX, playerY = zoneMapX+scale*(player:getX()/mapSizeX), zoneMapY+scale*(player:getY()/mapSizeY)
    self:drawRect(playerX, playerY, math.max(1,1), math.max(1,1), 0.7, 0, 1, 0)

    self:drawRectBorder(zoneMapX, zoneMapY, scale, scale, 0.7, 0.7, 0.7, 0.7)
end


function zoneEditor:render()
    ISPanel.render(self)
end

function zoneEditor:update()
    ISPanel.update(self)
end


function zoneEditor:close()
    self:setVisible(false)
    self:removeFromUIManager()
end


function zoneEditor:new(x, y, width, height, title)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.variableColor={r=0.9, g=0.55, b=0.1, a=1}
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.buttonBorderColor = {r=0.7, g=0.7, b=0.7, a=0.5}
    o.zOffsetSmallFont = 25
    o.moveWithMouse = true
    o.panelTitle = title
    ISDebugMenu.RegisterClass(self)
    return o
end


require "DebugUIs/DebugMenu/ISDebugMenu"
local ISDebugMenu_setupButtons = ISDebugMenu.setupButtons
function ISDebugMenu:setupButtons()
    self:addButtonInfo("Zone Editor", function() zoneEditor.OnOpenPanel() end, "MAIN")
    ISDebugMenu_setupButtons(self)
end