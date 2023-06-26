require "ISUI/ISPanel"

zoneEditor = ISPanel:derive("zoneEditor")
zoneEditor.instance = nil
zoneEditor.dataListObj = {}
zoneEditor.dataListName = {}

function zoneEditor.OnOpenPanel(obj, name)

    if zoneEditor.instance==nil then
        zoneEditor.instance = zoneEditor:new(100, 100, 650, 500, "Inspect")
        zoneEditor.instance:initialise()
        zoneEditor.instance:instantiate()
    end

    zoneEditor.instance:addToUIManager()
    zoneEditor.instance:setVisible(true)
    zoneEditor.instance:populateNameList()

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

    self.zoneList = ISScrollingListBox:new(10, 40, self.width-20, self.height-75)
    self.zoneList:initialise()
    self.zoneList:instantiate()
    self.zoneList.itemheight = 22
    self.zoneList.selected = 0
    self.zoneList.joypadParent = self
    self.zoneList.font = UIFont.NewSmall
    self.zoneList.doDrawItem = self.drawTableNameList
    self.zoneList.drawBorder = true
    self.zoneList.onmousedown = zoneEditor.OnZoneListMouseDown
    self.zoneList.target = self
    self:addChild(self.zoneList)

    local w = 100

    local y, button = ISDebugUtils.addButton(self,"close",self.width-w-10,self.height-30, w,20, "Close", zoneEditor.onClickClose)
    self.closeButton = button
end


function zoneEditor:onClickClose() self:close() end
function zoneEditor:OnZoneListMouseDown(item)
    print("OnZoneListMouseDown: "..tostring(item))

    if self.zones then
        for i, zone in pairs(self.zones) do
            if item == zone then
                self.zones[i] = nil
                ModData.transmit("miningChucked_zones")
            end
        end
    end
    
    self:populateNameList()
end


function zoneEditor:populateNameList()
    self.zoneList:clear()

    self.zones = ModData.exists("miningChucked_zones") and ModData.get("miningChucked_zones")
    if self.zones then
        for i, zone in pairs(self.zones) do

            local minerals = "minerals: "
            for mineral,chance in pairs(zone.minerals) do minerals = minerals..mineral.." ("..chance..") " end

            local label = "x1:"..zone.x1..", y1:"..zone.y1..", x2:"..zone.x2..", y2:"..zone.y2.." nodes:"..#zone.currentNodes.."/"..zone.maxNodes.." respawnTimer:"..zone.respawnTimer
            label = minerals..label

            self.zoneList:addItem(label, zone)
        end
    end
end


function zoneEditor:drawTableNameList(y, item, alt)
    local a = 0.9
    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
    if self.selected == item.index then self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15) end
    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font)
    return y + self.itemheight
end


function zoneEditor:drawInfoList(y, item, alt)
    local a = 0.9

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    end

    self:drawText( item.text, 10, y + 2, 1, 1, 1, a, self.font)

    return y + self.itemheight
end


function zoneEditor:prerender()
    ISPanel.prerender(self)


end


function zoneEditor:update()
    ISPanel.update(self)
end


function zoneEditor:close()
    self:setVisible(false)
    self:removeFromUIManager()
    --zoneEditor.instance = nil
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