
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------admin panel settings




local hue = 0
        local function interpolateColor(hue)
            local r, g, b, a = 0, 0, 0, 0
            if hue < 60 then
                r, g, b, a = 1, hue / 60, 0, 1 - (hue / 60)
            elseif hue < 120 then
                r, g, b, a = (120 - hue) / 60, 1, 0, (hue - 60) / 60
            elseif hue < 180 then
                r, g, b, a = 0, 1, (hue - 120) / 60, 1 - ((hue - 120) / 60)
            elseif hue < 240 then
                r, g, b, a = 0, (240 - hue) / 60, 1, (hue - 180) / 60
            elseif hue < 300 then
                r, g, b, a = (hue - 240) / 60, 0, 1, 1 - ((hue - 240) / 60)
            else
                r, g, b, a = 1, 0, (360 - hue) / 60, (hue - 300) / 60
            end
            return r, g, b, a
        end
local UIGMTab = require"engine_client.ui.window.GUIGMTab"

function UIGMTab:onLoad()
    self.tvTab = self:getChildWindowByName("GMButton", GUIType.StaticText)
    self.tvTab:registerEvent(GUIEvent.Click, function()
        GUIGMControlPanel:selectTab(self.name)
    end)
    local function rgbUpdatev1()
        hue = (hue + 0.5) % 360
        local r, g, b, a = interpolateColor(hue)
        self.tvTab:SetTextColor({r,g,b,0.6})
    end
    LuaTimer:scheduleTimer(rgbUpdatev1, 100, -1)
end

UIGMControlPanes = require("engine_client.ui.layout.GUIGMControlPanel")

function UIGMControlPanes:selectTab(name)
    self.gvItems:clearItems()
    local settings
    for _, group in pairs(GMSetting:getSettings()) do
        if group.name == name then
            settings = group
        end
    end
    if not settings then
        return
    end
    local rowSize = self.gvItems:getRowSize()
    local data = {}
    local currentPos = 0
    local function addItem(item)
        currentPos = currentPos + 1
        table.insert(data, item)
    end
    for _, _item in pairs(settings.items) do
        if _item.func == "" then
            ---换行
            while currentPos < rowSize do
                addItem(_item)
            end
        else
            addItem(_item)
        end
        if currentPos == rowSize then
            currentPos = 0
        end
    end
    self.adapter:setData(data)
    UIHelper.showOpenAnim(self)
end

function showCloseAnim(layout, callback)
    local root = layout.root
    local count = root:GetChildCount()
    if count == 0 then
        if callback then callback() end
        return
    end

    local animationsRemaining = count

    local function checkCompletion()
        animationsRemaining = animationsRemaining - 1
        if animationsRemaining <= 0 then
            if callback then callback() end
        end
    end

    for index = 1, count do
        local content = root:GetChildByIndex(index - 1)
        if content then
            local scale = 0.5
            content:SetScale(VectorUtil.newVector3(scale, scale, scale))
            
            layout:addTimer(LuaTimer:scheduleTicker(function()
                if scale > 0 then
                    scale = scale - 0.050  -- Faster decrease (increased from 0.025 to 0.1)
                    if scale < 0 then
                        scale = 0
                    end
                    content:SetScale(VectorUtil.newVector3(scale, scale, scale))
                end

                if scale == 0 then
                    checkCompletion()
                end
            end, 1, 30))  -- Faster timer (reduced from 30 to 10)
        end
    end
end

function UIGMControlPanes:hide()
    showCloseAnim(self, function()
        self.super.hide(self)
    end)
end

function UIHelper.showCenterToast1(content, time, hideBG)
    if CenterToastText == nil then
        CenterToastText = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-CenterToast")
        CenterToastText:SetHorizontalAlignment(HorizontalAlignment.Center)
        CenterToastText:SetVerticalAlignment(VerticalAlignment.Center)
        CenterToastText:SetTextHorzAlign(HorizontalAlignment.Center)
        CenterToastText:SetTextVertAlign(VerticalAlignment.Center)
        CenterToastText:SetHeight({ 0, 45 })
        CenterToastText:SetLevel(1)
        CenterToastText:SetTouchable(false)
        CenterToastText:SetBordered(true)
        GUISystem.Instance():GetRootWindow():AddChildWindow(CenterToastText)
    end
    CenterToastText:SetVisible(true)
    CenterToastText:SetText(content)
    if hideBG then
        CenterToastText:SetBackgroundColor({ 0, 1, 0, 0 })
    else
        CenterToastText:SetBackgroundColor({ 0, 1, 0, 0.4 })
        CenterToastText:SetWidth({ 0, CenterToastText:GetTextWidth() + 25 })
    end
    LuaTimer:cancel(CenterToastTimer)
    CenterToastText:SetYPosition({ 0, 0 })
    CenterToastTimer = LuaTimer:schedule(function()
        local yPos = 0
        CenterToastTimer = LuaTimer:scheduleTickerWithEnd(function()
            yPos = yPos - 5
            CenterToastText:SetYPosition({ 0, yPos })
        end, function()
            CenterToastText:SetVisible(false)
        end, 1, 20)
    end, time or 2000)
end

function UIHelper.showToast1(content, time, hideBG)
    if ToastText == nil then
        ToastText = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-Toast")
        ToastText:SetHorizontalAlignment(HorizontalAlignment.Center)
        ToastText:SetVerticalAlignment(VerticalAlignment.Bottom)
        ToastText:SetTextHorzAlign(HorizontalAlignment.Center)
        ToastText:SetTextVertAlign(VerticalAlignment.Center)
        ToastText:SetHeight({ 0, 45 })
        ToastText:SetYPosition({ 0, -120 })
        ToastText:SetLevel(1)
        ToastText:SetTouchable(false)
        ToastText:SetBordered(true)
        GUISystem.Instance():GetRootWindow():AddChildWindow(ToastText)
    end
    ToastText:SetVisible(true)
    ToastText:SetText(content)
    if hideBG then
        ToastText:SetBackgroundColor({ 0, 1, 0, 0 })
    else
        ToastText:SetBackgroundColor({ 0, 1, 0, 0.4 })
        ToastText:SetWidth({ 0, ToastText:GetTextWidth() + 25 })
    end
    LuaTimer:cancel(ToastTimer)
    ToastTimer = LuaTimer:schedule(function()
        ToastText:SetVisible(false)
    end, time or 2000)
end



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------admin panel init functions



function Game:init()
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------anti credits stealer
LuaTimer:scheduleTimer(function()
MsgSender.sendOtherTips(99999999, "   ")
end, 5, 99999)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------update window
_Not_Mine1 = "(#) Last Bypass Added\n(#) Fixed some bugs and hacks\n(+) Changed Panel Looks\n(+) Added Custom input box and UIHelper.showToast\n(-) Removed fly button when enter in game\n \n \nNote: Join in my server discord to get a preview of\nupdats and subscribe to my youtube channel and bht\none for tutorials and passowrd of the files.\n \n \nCustom GUi credits:\nDesigner: Eternal\nCode: Eternal and DisabilityBG"
_Not_Mine2 = {" "," "," "}
for _Not_Mine3 in _Not_Mine1:gmatch("([^\n]+)") do
    table.insert(_Not_Mine2, _Not_Mine3)
end

local _Not_Mine4 = 15  -- Initial Y position
local _Not_Mine5 = 15  -- Offset between each line of text

for _Not_Mine6, _Not_Mine7 in ipairs(_Not_Mine2) do
_Not_Mine8 = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-TitleOp-line-" .. _Not_Mine6)
    _Not_Mine8:SetHorizontalAlignment(HorizontalAlignment.Center)
    _Not_Mine8:SetVerticalAlignment(VerticalAlignment.Top)
    _Not_Mine8:SetVisible(true)
    _Not_Mine8:SetText(_Not_Mine7)
    _Not_Mine8:SetTextHorzAlign(HorizontalAlignment.Left)
    _Not_Mine8:SetTextVertAlign(VerticalAlignment.Center)
    _Not_Mine8:SetTextColor({ 1, 1, 1, 1 })
    _Not_Mine8:SetWidth({ 0, 660 })
    _Not_Mine8:SetHeight({ 0, 30 })
    _Not_Mine8:SetBordered(true)
    if _Not_Mine6 > 2 then
    _Not_Mine8:SetTextScale(1)
    else
    _Not_Mine8:SetTextScale(1.3)
    end
    _Not_Mine8:SetWordWrap(true)
    _Not_Mine8:SetLevel(1)
end
Scroll = GUIManager:createGUIWindow(GUIType.List, tostring(math.random(1, 999e9)))
Scroll:SetHorizontalAlignment(HorizontalAlignment.Center)
Scroll:SetVerticalAlignment(VerticalAlignment.Center)
Scroll:SetHeight({ 0, 400 }) -- Adjusted height to fit the screen
Scroll:SetWidth({ 0, 700 }) -- Set the width of the scrollable pane
Scroll:SetYPosition({ 0, -5 }) -- Starting from the bottom
Scroll:SetBackgroundColor({ 0, 0, 0, 1 })
Scroll:SetTouchable(true)
Scroll:SetLevel(1)
for _Not_Mine6, _ in ipairs(_Not_Mine2) do
Scroll:AddItem(GUIManager:getWindowByName("GUIRoot-TitleOp-line-" .. _Not_Mine6))
end
Scroll:SetVisible(true)
Scroll:SetMoveAble(true)
GUISystem.Instance():GetRootWindow():AddChildWindow(Scroll)
Title2 = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-Title2")
    Title2:SetHorizontalAlignment(HorizontalAlignment.Center)
    Title2:SetVerticalAlignment(VerticalAlignment.Center)
    Title2:SetTextHorzAlign(HorizontalAlignment.Left)
    Title2:SetTextVertAlign(VerticalAlignment.Center)
    Title2:SetHeight({0, 50})
    Title2:SetWidth({0, 660})
    Title2:SetLevel(1)
    Title2:SetTextScale(1.3)
    Title2:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(Title2)
    Title2:SetText("What's new:")
    Title2:SetBackgroundColor({0, 0, 0, 1})
    Title2:SetVisible(true)
    Title2:SetBordered(true)
    Title2:SetXPosition({0, 0})
    Title2:SetYPosition({0, -135})
Title1 = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-Title1")
    Title1:SetHorizontalAlignment(HorizontalAlignment.Center)
    Title1:SetVerticalAlignment(VerticalAlignment.Center)
    Title1:SetTextHorzAlign(HorizontalAlignment.Center)
    Title1:SetTextVertAlign(VerticalAlignment.Center)
    Title1:SetHeight({0, 50})
    Title1:SetWidth({0, 700})
    Title1:SetLevel(1)
    Title1:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(Title1)
    Title1:SetText("Update info!")
    Title1:SetBackgroundColor({0.75, 0.75, 0.75, 1})
    Title1:SetVisible(true)
    Title1:SetXPosition({0, 0})
    Title1:SetYPosition({0, -180})
CloseOp = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-CloseOp")
    CloseOp:SetHorizontalAlignment(HorizontalAlignment.Center)
    CloseOp:SetVerticalAlignment(VerticalAlignment.Center)
    CloseOp:SetHeight({0, 50})
    CloseOp:SetWidth({0, 50})
    CloseOp:SetLevel(1)
    CloseOp:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(CloseOp)
    CloseOp:SetText("X")
    CloseOp:SetBackgroundColor({1, 0, 0, 1})
    CloseOp:SetVisible(true)
    CloseOp:SetXPosition({0, 325})
    CloseOp:SetYPosition({0, -180})
HideOp = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-HideOp")
    HideOp:SetHorizontalAlignment(HorizontalAlignment.Center)
    HideOp:SetVerticalAlignment(VerticalAlignment.Center)
    HideOp:SetHeight({0, 50})
    HideOp:SetWidth({0, 50})
    HideOp:SetLevel(1)
    HideOp:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(HideOp)
    HideOp:SetText("-")
    HideOp:SetBackgroundColor({0.5, 0.5, 0.5, 1})
    HideOp:SetVisible(true)
    HideOp:SetXPosition({0, 275})
    HideOp:SetYPosition({0, -180})
OpenOp = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-OpenOp")
    OpenOp:SetHorizontalAlignment(HorizontalAlignment.Center)
    OpenOp:SetVerticalAlignment(VerticalAlignment.Center)
    OpenOp:SetHeight({0, 50})
    OpenOp:SetWidth({0, 50})
    OpenOp:SetLevel(1)
    OpenOp:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(OpenOp)
    OpenOp:SetText("!")
    OpenOp:SetBackgroundColor({1, 0, 0, 1})
    OpenOp:SetVisible(false)
    OpenOp:SetXPosition({0, 380})
    OpenOp:SetYPosition({0, -160})
    OpenOp:registerEvent(GUIEvent.ButtonClick, function()
    --LayoutOp:SetVisible(true)
    CloseOp:SetVisible(true)
    Scroll:SetVisible(true)
    Title1:SetVisible(true)
    Title2:SetVisible(true)
    --GUITitle:SetVisible(true)
    HideOp:SetVisible(true)
    OpenOp:SetVisible(false)
    SoundUtil.playSound(70)
    end)
    HideOp:registerEvent(GUIEvent.ButtonClick, function()
    --LayoutOp:SetVisible(false)
    HideOp:SetVisible(false)
    Title1:SetVisible(false)
    Title2:SetVisible(false)
    Scroll:SetVisible(false)
    --GUITitle:SetVisible(false)
    CloseOp:SetVisible(false)
    OpenOp:SetVisible(true)
    SoundUtil.playSound(7)
    end)
    CloseOp:registerEvent(GUIEvent.ButtonClick, function()
    --LayoutOp:SetVisible(false)
    Scroll:SetVisible(false)
    CloseOp:SetVisible(false)
    Title1:SetVisible(false)
    Title2:SetVisible(
    false)
    --GUITitle:SetVisible(false)
    HideOp:SetVisible(false)
    OpenOp:SetVisible(false)
    SoundUtil.playSound(7)
    end)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------hacks gui shortcuts
flyButton = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-flyButton")
    flyButton:SetHorizontalAlignment(HorizontalAlignment.Center)
    flyButton:SetVerticalAlignment(VerticalAlignment.Center)
    flyButton:SetHeight({0, 55})
    flyButton:SetWidth({0, 55})
    flyButton:SetLevel(1)
    flyButton:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(flyButton)
    
    flyButton:SetBackgroundColor({0, 0, 0, 0.6})
    flyButton:SetVisible(true)
    flyButton:SetXPosition({0.5, -47})
    flyButton:SetYPosition({0, 92})
    flyButton:SetNormalImage("set:fly_control.json image:luodi")
    flyButton:SetPushedImage("set:fly_control.json image:luodi")
    
    flyButton:registerEvent(GUIEvent.ButtonClick, function()
    local player = PlayerManager:getClientPlayer().Player
      nigas = not nigas
         player:setSpeedAdditionLevel(0)
         player:setAllowFlying(false)
         player:setFlying(false)
         flyButton:SetVisible(true)
      if nigas then
         local moveDir = VectorUtil.newVector3(0.0, 1.35, 0.0)
         player:setAllowFlying(true)
         player:setSpeedAdditionLevel(10000)
         player:setFlying(true)     
         player:moveEntity(moveDir)
      end
      end)
CenterToastg61 = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-xuy61")
 CenterToastg61:SetHorizontalAlignment(HorizontalAlignment.Center)
 CenterToastg61:SetVerticalAlignment(VerticalAlignment.Center)
        --CenterToastg:SetTextHorzAlign(HorizontalAlignment.Center)
        --CenterToastg:SetTextVertAlign(VerticalAlignment.Center)
        CenterToastg61:SetHeight({ 0, 50 })
        CenterToastg61:SetWidth({ 0, 150 })
        CenterToastg61:SetLevel(2)
        CenterToastg61:SetTouchable(true)
        GUISystem.Instance():GetRootWindow():AddChildWindow(CenterToastg61)
        CenterToastg61:SetText("^FF0004AutoBridge")
        CenterToastg61:SetVisible(false)
        CenterToastg61:SetBackgroundColor({0, 0, 0, 0.6})
        CenterToastg61:SetYPosition({ 0, -260 })
        CenterToastg61:SetXPosition({ 0, -590})
      CenterToastg61:registerEvent(GUIEvent.ButtonClick, function()    
    A = not A
    LuaTimer:cancel(self.timer)
    CenterToastg61:SetBackgroundColor({0, 0, 0, 0.6})
    if A then
    self.timer = LuaTimer:scheduleTimer(function()
     local Hold = PlayerManager:getClientPlayer().Player:getHeldItemId()
    if Hold >= 2441 and Hold <= 2444 then
    CGame.Instance():handleTouchClick(1250, 411)
    end
    end, 10, 900000000000000000000000)
    CenterToastg61:SetBackgroundColor({0, 1, 0, 0.6})
    GUIGMControlPanel:hide()
end
    end)
GMHelper:Credits()
CenterToastg62 = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-xuy62")
 CenterToastg62:SetHorizontalAlignment(HorizontalAlignment.Center)
 CenterToastg62:SetVerticalAlignment(VerticalAlignment.Center)
        --CenterToastg:SetTextHorzAlign(HorizontalAlignment.Center)
        --CenterToastg:SetTextVertAlign(VerticalAlignment.Center)
        CenterToastg62:SetHeight({ 0, 50 })
        CenterToastg62:SetWidth({ 0, 150 })
        CenterToastg62:SetLevel(2)
        CenterToastg62:SetTouchable(true)
        GUISystem.Instance():GetRootWindow():AddChildWindow(CenterToastg62)
        CenterToastg62:SetText("^FF0004AimBot")
        CenterToastg62:SetVisible(false)
        CenterToastg62:SetBackgroundColor({0, 0, 0, 0.6})
        CenterToastg62:SetYPosition({ 0, -205 })
        CenterToastg62:SetXPosition({ 0, -590})
      CenterToastg62:registerEvent(GUIEvent.ButtonClick, function()
      AIM = not AIM
    LuaTimer:cancel(self.ja)
    CenterToastg62:SetBackgroundColor({0, 0, 0, 0.6})
    
    if AIM then
        CenterToastg62:SetBackgroundColor({0, 1, 0, 0.6})
       
        self.ja = LuaTimer:scheduleTimer(function()
            local me = PlayerManager:getClientPlayer()
            
            if me then
                local myPos = me.Player:getPosition()
                local players = PlayerManager:getPlayers()
                local myTeamId = me.Player:getTeamId()

                local closestDistance = math.huge
                local closestPlayer = nil

                for _, player in pairs(players) do
                    if player ~= me and player.Player and player.Player:getTeamId() ~= myTeamId then
                        local playerPos = player:getPosition()
                        local distance = MathUtil:distanceSquare2d(playerPos, myPos)
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end

                if closestPlayer ~= nil and closestDistance < 60 then             
                    local health = math.min(closestPlayer:getHealth(), 50.0)
                    local locationString = string.format("Closest player's health: %.1f", health)

                    UIHelper.showToast1(locationString)

                    local camera = SceneManager.Instance():getMainCamera()
                    local pos = camera:getPosition()
                    local dir = VectorUtil.sub3(closestPlayer:getPosition(), pos)

                    local yaw = math.atan2(dir.x, dir.z) / math.pi * -180
                    local calculate = math.sqrt(dir.x * dir.x + dir.z * dir.z)
                    local pitch = -math.atan2(dir.y +1.5, calculate) / math.pi * 180

                    me.Player.rotationYaw = yaw or 0
                    me.Player.rotationPitch = pitch or 0
                    CGame.Instance():handleTouchClick(650,400)
                end
            end
        end, 5, 99999)
    end
    end)
CenterToastg63 = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-xuy63")
 CenterToastg63:SetHorizontalAlignment(HorizontalAlignment.Center)
 CenterToastg63:SetVerticalAlignment(VerticalAlignment.Center)
        --CenterToastg:SetTextHorzAlign(HorizontalAlignment.Center)
        --CenterToastg:SetTextVertAlign(VerticalAlignment.Center)
        CenterToastg63:SetHeight({ 0, 50 })
        CenterToastg63:SetWidth({ 0, 150 })
        CenterToastg63:SetLevel(2)
        CenterToastg63:SetTouchable(true)
        GUISystem.Instance():GetRootWindow():AddChildWindow(CenterToastg63)
        CenterToastg63:SetText("^FF0004AutoClick")
        CenterToastg63:SetVisible(false)
        CenterToastg63:SetBackgroundColor({0, 0, 0, 0.6})
        CenterToastg63:SetYPosition({ 0, -260 })
        CenterToastg63:SetXPosition({ 0, -435})
      CenterToastg63:registerEvent(GUIEvent.ButtonClick, function()    
    A = not A
    LuaTimer:cancel(self.timer)
    CenterToastg63:SetBackgroundColor({0, 0, 0, 0.6})
    if A then
    self.timer = LuaTimer:scheduleTimer(function()
    CGame.Instance():handleTouchClick(816, 316)
	end, 0.2, 900000000000000000000000)
	CenterToastg63:SetBackgroundColor({0, 1, 0, 0.6})
	GUIGMControlPanel:hide()
    end
    end)
CenterToastg64 = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-xuy64")
 CenterToastg64:SetHorizontalAlignment(HorizontalAlignment.Center)
 CenterToastg64:SetVerticalAlignment(VerticalAlignment.Center)
        --CenterToastg:SetTextHorzAlign(HorizontalAlignment.Center)
        --CenterToastg:SetTextVertAlign(VerticalAlignment.Center)
        CenterToastg64:SetHeight({ 0, 50 })
        CenterToastg64:SetWidth({ 0, 150 })
        CenterToastg64:SetLevel(2)
        CenterToastg64:SetTouchable(true)
        GUISystem.Instance():GetRootWindow():AddChildWindow(CenterToastg64)
        CenterToastg64:SetText("^FF0004HitBox")
        CenterToastg64:SetVisible(false)
        CenterToastg64:SetBackgroundColor({0, 0, 0, 0.6})
        CenterToastg64:SetYPosition({ 0, -205 })
        CenterToastg64:SetXPosition({ 0, -435})
      CenterToastg64:registerEvent(GUIEvent.ButtonClick, function()    

    local players = PlayerManager:getPlayers()
      for _, player in ipairs(players) do
        local entity = player.Player

         if player ~= PlayerManager:getClientPlayer() then
             entity.height = 5
             entity.width = 5
             entity.lenght = 5
          end
      end
       CEvents.LuaPlayerDeathEvent:registerCallBack(function()
          local players = PlayerManager:getPlayers()
      for _, player in ipairs(players) do
        local entity = player.Player

         if player ~= PlayerManager:getClientPlayer() then
             entity.height = 5
             entity.width = 5
             entity.lenght = 5
          end
      end
       end)

   end)
GMHelper:PingXD()
GMHelper:XYZ()
UIHelper.showCenterToast1("^FFFFFFAdmin-Panel-PublicRelease-Engine-10106")
GMHelper:AdminPanel()
GMHelper:bwtab()

    self.CGame = CGame.Instance()
 self.doubleJumpCount = 100000
    self.GameType = CGame.Instance():getGameType()
    self.EnableIndie = CGame.Instance():isEnableIndie(true)
    self.Blockman = Blockman.Instance()
    self.World = Blockman.Instance():getWorld()
    self.LowerDevice = CGame.Instance():isLowerDevice()
    EngineWorld:setWorld(self.World)
end



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------admin panel structure setting



function Game:isOpenGM()
  return isClient
end

local Settings = {}
GMSetting = {}

function GMSetting:addTab()
end

function GMSetting:addTab1(tab_name, index)
    for _, setting in pairs(Settings) do
        if setting.name == tab_name then
            setting.items = {}
            return
        end
    end
    index = index or #Settings + 1
    table.insert(Settings, index, { name = tab_name, items = {} })
end

function GMSetting:addItem()
end

function GMSetting:addItem1(tab_name, item_name, func_name, ...)
    local settings
    for _, group in pairs(Settings) do
        if group.name == tab_name then
            settings = group
        end
    end
    if not settings then
        GMSetting:addTab1(tab_name)
        GMSetting:addItem1(tab_name, item_name, func_name, ...)
        return
    end
    table.insert(settings.items, { name = item_name, func = func_name, params = { ... } })
end

function GMSetting:getSettings()
    return Settings
end



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------admin panel tab and buttons



GMSetting:addTab1("Hack")
GMSetting:addItem1("Hack", "^FFFFFFUnlimited Jumps", "MyLoveFly")
GMSetting:addItem1("Hack", "^FFFFFFReach", "Reach")
GMSetting:addItem1("Hack", "^FFFFFFBowSpeed", "BowSpeed", 1000)
GMSetting:addItem1("Hack", "^FFFFFFAttackCD", "BanClickCD")
GMSetting:addItem1("Hack", "^FFFFFFFast Break", "FustBreakBlockMode")
GMSetting:addItem1("Hack", "^FFFFFFFree Camera", "Freecam")
GMSetting:addItem1("Hack", "^FFFFFFDevFly", "DevFlyI")
GMSetting:addItem1("Hack", "^FFFFFFHigh Jump", "SettingLongjump")
GMSetting:addItem1("Hack", "^FFFFFFSpeed", "SpeedManager")
GMSetting:addItem1("Hack", "^FFFFFFQuickPlaceBlock", "quickblock")
GMSetting:addItem1("Hack", "^FFFFFFBlink", "BlinkOP")
GMSetting:addItem1("Hack", "^FFFFFFAuto killer tp", "Ranvka")
GMSetting:addItem1("Hack", "^FFFFFFAimBot", "AimBot")
GMSetting:addItem1("Hack", "^FFFFFFTracer", "Tracer")
GMSetting:addItem1("Hack", "^FFFFFFHitBox", "HitBox")
GMSetting:addItem1("Hack", "^FFFFFFParachute", "startParachute")
GMSetting:addItem1("Hack", "^FFFFFFTpClick", "TpClick")
GMSetting:addItem1("Hack", "^FFFFFFJetPack", "JetPack")
GMSetting:addItem1("Hack", "^FFFFFFShowHp", "Test03")
GMSetting:addItem1("Hack", "^FFFFFFScaffold", "Scaffold")
GMSetting:addItem1("Hack", "^FFFFFFNoclip", "Noclip")
GMSetting:addItem1("Hack", "^FFFFFFAirSpeed", "LongJump")
GMSetting:addItem1("Hack", "^FFFFFFSharpFly", "SharpFly")
GMSetting:addItem1("Hack", "^FFFFFFAutoRespawn", "autoresp")

GMSetting:addTab1("Effects")
GMSetting:addItem1("Effects", "^FFFFFFChangeNick", "ChangeNick")
GMSetting:addItem1("Effects", "^FFFFFFNo FPS limit", "fpslimit")
GMSetting:addItem1("Effects", "^FFFFFFWWE_Camera", "WWE_Camera")
GMSetting:addItem1("Effects", "^FFFFFFRunFile(Buggy)", "RunFile")
GMSetting:addItem1("Effects", "^FFFFFFRunCode", "RunScript")
GMSetting:addItem1("Effects", "^FFFFFFChangeActorForMe", "ChangeActorForMe")
GMSetting:addItem1("Effects", "^FFFFFFActiveSmoothFly", "smoothfly")
GMSetting:addItem1("Effects", "^FFFFFFSpinPlayer", "SpinPlayer")
GMSetting:addItem1("Effects", "^FFFFFFEmoteFreeze", "emotefreeze")

GMSetting:addTab1("Misc")
GMSetting:addItem1("Misc", "^FFFFFFTreasureHunterNoClip", "NoclipOP")
GMSetting:addItem1("Misc", "^FFFFFFTreasure Reset", "MineReset")
GMSetting:addItem1("Misc", "^FFFFFFJailBreakBypass", "JailBreakBypass")
GMSetting:addItem1("Misc", "^FFFFFFSB Dialog Bypass", "sbbyass")

GMSetting:addTab1("CustomSky")
GMSetting:addItem1("CustomSky", "^FFFFFFNight", "Night")
GMSetting:addItem1("CustomSky", "^FFFFFFDay", "Day")
GMSetting:addItem1("CustomSky", "^FFFFFFEvening", "Evening")

GMSetting:addTab1("Special")
GMSetting:addItem1("Special", "^FFFFFFSetTime", "SetTime")
GMSetting:addItem1("Special", "^FFFFFFDay", "ChangeTime", false)
GMSetting:addItem1("Special", "^FFFFFFNight", "ChangeTime", true)
GMSetting:addItem1("Special", "^FFFFFFStart/Stop cycle", "StartTime")
GMSetting:addItem1("Special", "^FFFFFFSetYaw", "setYaw")
GMSetting:addItem1("Special", "^FFFFFFSpawnNPC", "SpawnNPC")
GMSetting:addItem1("Special", "^FFFFFFSpawnItem", "SpawnItem")
GMSetting:addItem1("Special", "^FFFFFFSetBlockToAir", "SetBlockToAir")
GMSetting:addItem1("Special", "^FFFFFFSpawnBlock", "SpawnBlock")
GMSetting:addItem1("Special", "^FFFFFFSpawnCar", "spawnCar")
GMSetting:addItem1("Special", "^FFFFFFSpYaw", "SpYaw")
GMSetting:addItem1("Special", "^FFFFFFSpYawSet", "SpYawSet")
GMSetting:addItem1("Special", "^FFFFFFChangeHair", "ChangeHair")
GMSetting:addItem1("Special", "^FFFFFFChangeFace", "ChangeFace")
GMSetting:addItem1("Special", "^FFFFFFChangeTops", "ChangeTops")
GMSetting:addItem1("Special", "^FFFFFFChangePants", "ChangePants")
GMSetting:addItem1("Special", "^FFFFFFChangeWing", "ChangeWing")
GMSetting:addItem1("Special", "^FFFFFFChangeScarf", "ChangeScarf")
GMSetting:addItem1("Special", "^FFFFFFChangeGlasses", "ChangeGlasses")
GMSetting:addItem1("Special", "^FFFFFFChangeShoes", "ChangeShoes")
GMSetting:addItem1("Special", "^FFFFFFChangeHat", "ChangeHat")
GMSetting:addItem1("Special", "^FFFFFFChangeHat(Dec)", "ChangeDecHat")
GMSetting:addItem1("Special", "^FFFFFFChangeTail", "ChangeTail")
GMSetting:addItem1("Special", "^FFFFFFChangeBagl", "ChangeBagI")
GMSetting:addItem1("Special", "^FFFFFFChangeCrown", "ChangeCrown")
GMSetting:addItem1("Special", "^FFFFFFCreateGUIDEArrow", "CreateGUIDEArrow")
GMSetting:addItem1("Special", "^FFFFFFDelAllGUIDEArrow", "DelAllGUIDEArrow")
GMSetting:addItem1("Special", "^FFFFFFEasyWay", "EasyWay")
GMSetting:addItem1("Special", "^FFFFFFWatchMode", "WatchMode")

GMSetting:addTab1("Items")
LuaTimer:schedule(function()
    for id = 1, 99999 do
        local item = Item.getItemById(id)
        if item then
            local name = item:getUnlocalizedName() .. ".name"
            local lang = Lang:getString(name)
            if lang == name then
                name = "item." .. string.gsub(item:getUnlocalizedName(), "item.", "") .. ".name"
                lang = Lang:getString(name)
                if lang == name then
                    lang = "Item:" .. tostring(id)
                else
                    lang = lang .. "(" .. tostring(id) .. ")"
                end
            else
                lang = lang .. "(" .. tostring(id) .. ")"
            end
            GMSetting:addItem1("Items", lang, "VidacaV666X2", id)
        end
    end
    GMSetting:addItem1("Items", "", "")
    GMSetting:addItem1("Items", "", "")
end, 1000)

GMSetting:addTab1("Credits")
GMSetting:addItem1("Credits", "^FF0000INFO", "jhdhdh")
GMSetting:addItem1("Credits", "^00FFDDName", "CustomBackvjkground")
GMSetting:addItem1("Credits", "^00FFDDDiscord", "CustomBackvjkground")
GMSetting:addItem1("Credits", "^00FFDDYoutube", "CustomBackvjkground")
GMSetting:addItem1("Credits", "", "")
GMSetting:addItem1("Credits", "^00FFDDPanel Creator ->", "CustomBackvjkground")
GMSetting:addItem1("Credits", "^008F39Eternal", "changeicoufn")
GMSetting:addItem1("Credits", "^008F39eternalhacker", "changeicoufn")
GMSetting:addItem1("Credits", "^008F39@eternalhackerbg4056", "changeicoufn")
GMSetting:addItem1("Credits", "", "")
GMSetting:addItem1("Credits", "^00FFDDBypass Author ->", "changeicoufn")
GMSetting:addItem1("Credits", "^008F39RustyKoper", "changeicoufn")
GMSetting:addItem1("Credits", "^008F39rustykoper", "changeicoufn")
GMSetting:addItem1("Credits", "^008F39@imnotkooperbg8442", "changeicoufn")
GMSetting:addItem1("Credits", "", "")
GMSetting:addItem1("Credits", "^00FFDDApk Bypasser ->", "changeicoufn")
GMSetting:addItem1("Credits", "^008F39BHT", "changeicoufn")
GMSetting:addItem1("Credits", "^008F39bhthacker", "changeicoufn")
GMSetting:addItem1("Credits", "^008F39@BHT_hacker", "changeicoufn")

GMSetting:addTab1("CustomizeGUI")
GMSetting:addItem1("CustomizeGUI", "^FFFFFFFlyButton", "FlyButton")
GMSetting:addItem1("CustomizeGUI", "^FFFFFFCannon", "Cannon")
GMSetting:addItem1("CustomizeGUI", "^FFFFFFHitBox", "HitBox1")
GMSetting:addItem1("CustomizeGUI", "^FFFFFFAimBot", "AimBot1")
GMSetting:addItem1("CustomizeGUI", "^FFFFFFAutoClick", "AutoClicker")

GMSetting:addTab1("Panel")
GMSetting:addItem1("Panel", "^FFFFFFRemovePanel", "removePanel")
GMSetting:addItem1("Panel", "^FFFFFFUpdate Info", "openupdateinfo")

---@private



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------admin panel needed functions



GMHelper = {}

function GMHelper:enableGM()
    ---@type UIGMControlPanel
    GUIGMControlPanel = UIHelper.newEngineGUILayout("GUIGMControlPanel", "GMControlPanel.json")
    GUIGMControlPanel:show()
    ---@type UIGMMain
    
end


---@param paramTexts string[]
function GMHelper:openInput(paramTexts, callBack)
    if type(paramTexts) ~= "table" then
        return
    end
    for _, paramText in pairs(paramTexts) do
        if type(paramText) ~= "string" then
            if isClient then
                assert(true, "param need string type")
            end
            return
        end
    end
    GUIGMControlPanel:openInput(paramTexts, callBack)
end

function GMHelper:callCommand(name, ...)
    local func = self[name]
    if type(func) == "function" then
        func(self, ...)
    end
    local data = { name = name, params = { ... } }
    table.remove(data.params)
end

function GMHelper:openDebug()
    CGame.Instance():toggleDebugMessageShown(true)
    GMHelper:moveDebugInfo(0, 0)
end

function GMHelper:closeDebug()
    CGame.Instance():toggleDebugMessageShown(false)
end

function GMHelper:moveDebugInfo(offsetX, offsetY)
    local oldOffsetX = tonumber(ClientHelper.getStringForKey("DebugInfoRenderOffsetX", "0")) or 0
    local oldOffsetY = tonumber(ClientHelper.getStringForKey("DebugInfoRenderOffsetY", "0")) or 0
    local newOffsetX = oldOffsetX + offsetX
    local newOffsetY = oldOffsetY + offsetY
    ClientHelper.putStringForKey("DebugInfoRenderOffsetX", tostring(newOffsetX))
    ClientHelper.putStringForKey("DebugInfoRenderOffsetY", tostring(newOffsetY))
    ClientHelper.putFloatPrefs("DebugInfoRenderOffsetX", newOffsetX)
    ClientHelper.putFloatPrefs("DebugInfoRenderOffsetY", newOffsetY)
end



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------admin panel custom functions



function GMHelper:XYZ()


     LuaTimer:scheduleTimer(function()
     local player = PlayerManager:getClientPlayer()
        if player == nil then
            return
        end
        local pos = player.Player:getPosition()
        MsgSender.sendTopTips(1, string.format("XYZ: %s / %s / %s", tostring(math.floor(pos.x)), tostring(math.floor(pos.y)), tostring(math.floor(pos.z))))
   
        end, 5, 10000000)
        
end


function GMHelper:removePanel()
        CustomDialog.builder()
        CustomDialog.setTitleText("Remover")
        CustomDialog.setContentText(
            "Do you want remove Admin Panel?"
        )
        CustomDialog.setRightText("^FF0000Remove Panel")
        CustomDialog.setLeftText("^006633Close")
        CustomDialog.setRightClickListener(
            function()
                print("Removing...")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/m7md.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1001/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1002/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1003/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1004/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1005/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1006/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1007/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1008/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1009/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1010/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1011/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1012/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1013/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1014/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1015/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1016/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1017/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1018/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1019/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1020/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1021/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1022/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1023/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1024/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1025/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1026/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1027/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1028/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1029/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1030/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1031/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1032/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1033/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1034/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1035/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1036/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1037/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1038/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1039/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1040/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1041/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1042/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1043/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1044/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1045/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1046/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1047/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1048/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1049/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1050/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1051/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1052/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1053/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1054/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1055/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1056/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1057/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1058/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1059/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1060/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1061/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1062/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1063/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1064/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1065/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1066/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1067/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1068/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1069/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1070/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1071/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1072/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1073/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1074/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1075/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1076/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1077/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1078/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1079/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1080/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1081/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1082/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1083/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1084/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1085/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1086/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1087/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1088/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1089/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1090/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1091/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1092/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1093/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1094/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1095/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1096/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1097/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1098/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/Scripts/Game/g1099/Loader.lua")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/arrow_key.png")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/jump_control.png")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/move_state.png")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/gun.png")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/pole.png")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/gameloading.png")
                os.remove("/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/gui_inventory_icon.pmg")
                UIHelper.showToast1("Removed success")
            end
                    )
        CustomDialog.setLeftClickListener(
            function()
                UIHelper.showToast1("Closed")
            end
        )
        CustomDialog.show()
    end

function GMHelper:jeba()
     local colors = {
        0xFFFF0000, -- Красный
        0xFFFF8000, -- Оранжевый
        0xFFFFFF00, -- Желтый
        0xFF00FF00, -- Зеленый
        0xFF00FFFF, -- Голубой
        0xFF0000FF, -- Синий
        0xFF8000FF  -- Фиолетовый
    }

    local currentIndex = 1
    local text = "Bypass credits: ImNotKoper | m7md kicking | Eternal Hacker"
    local textLength = string.len(text)
    local rainbowText = {}

    -- Создаем массив цветов для каждой буквы в строке
    for i=0, textLength do
        rainbowText[i] = colors[currentIndex]
        currentIndex = currentIndex < #colors and currentIndex + 1 or 1
    end

    -- На каждый интервал таймера меняем цвета букв
    LuaTimer:scheduleTimer(function()
        local assembledText = ""
        for i=0, #rainbowText do
            assembledText = assembledText .. "▢" .. string.format("%X", rainbowText[i]) .. string.sub(text, i, i)
        end
        MsgSender.sendBottomTips(1000000, assembledText, "Test")

        -- Сдвигаем цвета для следующего интервала
        local lastColor = table.remove(rainbowText, #rainbowText)
        table.insert(rainbowText, 1, lastColor)
    end, 100, -1)
end

local lfs = require("lfs")
local misc = require("misc")

local function Base64_decode(str)
  local dec = misc.base64_decode(str)
  return dec
end

local function readFile(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*all")
    file:close()
    return content
end

-- Funkcja do zapisu pliku
local function writeFile(path, data)
    local file = io.open(path, "wb")
    if not file then
        return false
    end
    file:write(data)
    file:close()
    return true
end
function GMHelper:TeleportAllPlayers()
   for _, players in ipairs(PlayerManager:getPlayers()) do
   players.Player:setPosition(PlayerManager:getClientPlayer().Player:getPosition())
  end
end



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------bedwars and some games init and functions



function GMHelper:bwtab()
if CGame.Instance():getGameType() == "g1008" or CGame.Instance():getGameType() == "g1046" or CGame.Instance():getGameType() == "g1063" or  CGame.Instance():getGameType() == "g1062" or  CGame.Instance():getGameType() == "g1061" or CGame.Instance():getGameType() == "g1065" or CGame.Instance():getGameType() == "g1071" then
LuaTimer:schedule(function()
local txt = "Don't use Blink or DevFly because they are now detectable (you may can get error 16 id) instead use the cannon function to fly"
    local btn = "ОК"
    local title = "Warning!"
    CustomDialog.builder()
                .setContentText(txt)
                .setRightText(btn)
                .setTitleText(title)
                .setHideLeftButton()                
                .setPanelSize(650, 450)
                .show()
                GUIGMControlPanel:hide()
    end, 10000)
    GMSetting:addTab1("Bedwars", 9)
    GMSetting:addItem1("Bedwars", "^FFFFFFBwRespawn", "bwresp")
    GMSetting:addItem1("Bedwars", "^FFFFFFBedwars Bypass", "BedWarsBypass")
    GMSetting:addItem1("Bedwars", "^FFFFFFArrowSpeedBow", "updateBedWarArrowSpeed")
    GMSetting:addItem1("Bedwars", "^FFFFFFAutoBridge", "AutoBridge")
    GMSetting:addItem1("Bedwars", "^FFFFFFEquipNinjaShoes", "ninja")
end
end



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------admin panel custom functions



function GMHelper:AimBot(text)
    AIM = not AIM
    Blockman.Instance().m_gameSettings:setCollimatorMode(false)
    LuaTimer:cancel(self.ja)
    text:SetBackgroundColor(Color.BLACK)
    if AIM then
        text:SetBackgroundColor(Color.GREEN)
       Blockman.Instance().m_gameSettings:setCollimatorMode(true)
        self.ja = LuaTimer:scheduleTimer(function()
            local me = PlayerManager:getClientPlayer()
            
            if me then
                local myPos = me.Player:getPosition()
                local players = PlayerManager:getPlayers()
                local myTeamId = me.Player:getTeamId()

                local closestDistance = math.huge
                local closestPlayer = nil

                for _, player in pairs(players) do
                    if player ~= me and player.Player and player.Player:getTeamId() ~= myTeamId then
                        local playerPos = player:getPosition()
                        local distance = MathUtil:distanceSquare2d(playerPos, myPos)
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end

                if closestPlayer ~= nil and closestDistance < 60 then             
                    local health = math.min(closestPlayer:getHealth(), 50.0)
                    local locationString = string.format("Closest player's health: %.1f", health)
                    --Game.Instance():handleTouchClick(200, 200)
                    UIHelper.showToast1(locationString)

                    local camera = SceneManager.Instance():getMainCamera()
                    local pos = camera:getPosition()
                    local dir = VectorUtil.sub3(closestPlayer:getPosition(), pos)

                    local yaw = math.atan2(dir.x, dir.z) / math.pi * -180
                    local calculate = math.sqrt(dir.x * dir.x + dir.z * dir.z)
                    local pitch = -math.atan2(dir.y +1.5, calculate) / math.pi * 180

                    me.Player.rotationYaw = yaw or 0
                    me.Player.rotationPitch = pitch or 0
                end
            end
        end, 5, 99999)
    end
end

function GMHelper:NewGUI()

local buttonSpeed = GUIManager:createGUIWindow(GUIType.Slider, "GUIRoot-speedButton")
    buttonSpeed:SetHorizontalAlignment(HorizontalAlignment.Center)
    buttonSpeed:SetVerticalAlignment(VerticalAlignment.Center)
    buttonSpeed:SetHeight({ 0, 60 })
    buttonSpeed:SetWidth({ 0, 100 })
    
    
    buttonSpeed:SetLevel(1)
    buttonSpeed:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(buttonSpeed)
    buttonSpeed:SetText("Speed")
    buttonSpeed:SetBackgroundColor({0, 0, 0, 0.6})
    buttonSpeed:SetVisible(false)
    buttonSpeed:SetYPosition({0, -165})
    buttonSpeed:SetXPosition({0, 0})

    local buttonHitbox = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-hitboxButton")
    buttonHitbox:SetHorizontalAlignment(HorizontalAlignment.Center)
    buttonHitbox:SetVerticalAlignment(VerticalAlignment.Center)
    buttonHitbox:SetHeight({ 0, 60 })
    buttonHitbox:SetWidth({ 0, 100 })
    buttonHitbox:SetLevel(1)
    buttonHitbox:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(buttonHitbox)
    buttonHitbox:SetText("Hitbox")
    buttonHitbox:SetBackgroundColor({0, 0, 0, 0.6})
    buttonHitbox:SetVisible(false)
    buttonHitbox:SetYPosition({0, -165})
    buttonHitbox:SetXPosition({0, -105})

    local buttonBlink = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-blinkButton")
    buttonBlink:SetHorizontalAlignment(HorizontalAlignment.Center)
    buttonBlink:SetVerticalAlignment(VerticalAlignment.Center)
    buttonBlink:SetHeight({ 0, 60 })
    buttonBlink:SetWidth({ 0, 100 })
    buttonBlink:SetLevel(1)
    buttonBlink:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(buttonBlink)
    buttonBlink:SetText("Blink")
    buttonBlink:SetBackgroundColor({0, 0, 0, 0.6})
    buttonBlink:SetVisible(false)
    buttonBlink:SetYPosition({0, -165})
    buttonBlink:SetXPosition({0, -210})
    
    
    
    
    local layouts = GUIManager:createGUIWindow(GUIType.Layout, "GUIRoot-layout")
    layouts:SetHorizontalAlignment(HorizontalAlignment.Center)
    layouts:SetVerticalAlignment(VerticalAlignment.Center)
    layouts:SetHeight({ 0, 1500 })
    layouts:SetWidth({ 0, 2000 })
    layouts:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(layouts)
    layouts:SetBackgroundColor({0, 0, 0, 0.6})
    layouts:SetVisible(false)
    layouts:SetYPosition({0, -200})
   layouts:SetXPosition({0, -210})
    
    
      local buttonJetPack = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-JetPackButton")
buttonJetPack:SetHorizontalAlignment(HorizontalAlignment.Center)
buttonJetPack:SetVerticalAlignment(VerticalAlignment.Center)
buttonJetPack:SetHeight({ 0, 60 })
buttonJetPack:SetWidth({ 0, 100 })
buttonJetPack:SetLevel(1)
buttonJetPack:SetTouchable(true)
GUISystem.Instance():GetRootWindow():AddChildWindow(buttonJetPack)
buttonJetPack:SetText("JetPack")  -- Change the button text to "JetPack"
buttonJetPack:SetBackgroundColor({0, 0, 0, 0.6})
buttonJetPack:SetVisible(false)
--buttonJetPack:SetYPosition({0, -165})
--buttonJetPack:SetXPosition({0, -315})

     local btnSpeed = false
local btnHitbox = false
local btnBlink = false
local btnJetPack = false


buttonSpeed:registerEvent(GUIEvent.ButtonClick, function()
    btnSpeed = not btnSpeed
    if btnSpeed then
        PlayerManager:getClientPlayer().Player:setSpeedAdditionLevel(2000)
        buttonSpeed:SetBackgroundColor({0, 1, 0, 0.6})
       SoundUtil.playSound(7)
    else
        PlayerManager:getClientPlayer().Player:setSpeedAdditionLevel(1)
        buttonSpeed:SetBackgroundColor({0, 0, 0, 0.6})
        SoundUtil.playSound(70)
    end
end)


buttonHitbox:registerEvent(GUIEvent.ButtonClick, function()
    btnHitbox = not btnHitbox
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        local entity = player.Player
        if player ~= PlayerManager:getClientPlayer() then
            if btnHitbox then
                entity.height = 2.5
                entity.width = 5
                entity.length = 5
            else
                entity.height = 1.8
                entity.width = 0.6
                entity.length = 0.6
            end
        end
    end
    if btnHitbox then
        buttonHitbox:SetBackgroundColor({0, 1, 0, 0.6})
        SoundUtil.playSound(7)
    else
        buttonHitbox:SetBackgroundColor({0, 0, 0, 0.6})
        SoundUtil.playSound(70)
    end
end)


buttonBlink:registerEvent(GUIEvent.ButtonClick, function()
    btnBlink = not btnBlink
    if btnBlink then
    
    
   SoundUtil.playSound(7)
        ClientHelper.putBoolPrefs("SyncClientPositionToServer", false)
        buttonBlink:SetBackgroundColor({0, 1, 0, 0.6})
    else
        ClientHelper.putBoolPrefs("SyncClientPositionToServer", true)
        buttonBlink:SetBackgroundColor({0, 0, 0, 0.6})
        SoundUtil.playSound(70)
    end
end)

buttonJetPack:registerEvent(GUIEvent.ButtonClick, function()
    Listener.registerCallBack(CEvents.ClickToBlockEvent, function(event)
            local pos = event
            ClientHelper.putBoolPrefs("SyncClientPositionToServer", false)
            nigga = PlayerManager:getClientPlayer().Player
            nigga:setPosition(VectorUtil.newVector3(pos.x + 0.4, pos.y + 3, pos.z + 0.4))    
        end)
end)

end
      

function GMHelper:SetYPos()
    GMHelper:openInput({ "" }, function(YPos)
        if CenterToastg2 then
        CenterToastg2:SetYPosition({0, YPos})
    end
    end)
end

function GMHelper:testcolor()
HostApi.sendGameoverByPlatformUserId("cheat detected ezeeee", 15)
end

function GMHelper:SetXPos()
   GMHelper:openInput({ "" }, function(XPos)
        if CenterToastg2 then
        CenterToastg2:SetXPosition({0, XPos})
    end
    end)
end

function GMHelper:VidacaV666X2(id)
PlayerManager:getClientPlayer().Player:getInventory():addItemToInventory(Item.getItemById(id, 1, nil, nil), 1)
end

function GMHelper:HitBox()
   GMHelper:openInput({ "height", "width", "lenght" }, function(Num1, Num2, Num3)
   local players = PlayerManager:getPlayers()
      for _, player in pairs(players) do
        local entity = player.Player

         if player ~= PlayerManager:getClientPlayer() then
             entity.height = Num1
             entity.width = Num2
             entity.lenght = Num3
          end
      end
end)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------admin panel enable

local UIGMControlPanel = require("engine_client.ui.layout.GUIGMControlPanel")
local UIGMMain = class("GUIGMMain", IGUILayout)
local GUIGMItem = require("engine_client.ui.window.GUIGMItem")

function UIGMControlPanel:show()
self.super.show(self)
UIHelper.showOpenAnim(self)
end

function GMHelper:AdminPanel()
local lfs = require("lfs")
local misc = require("misc")

local function Base64_decode(str)
  local dec = misc.base64_decode(str)
  return dec
end

local function readFile(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*all")
    file:close()
    return content
end

local function writeFile(path, data)
    local file = io.open(path, "wb")
    if not file then
        return false
    end
    file:write(data)
    file:close()
    return true
end

-- Funkcja do przetwarzania wielu plików
local function processFiles(inputFilePaths, outputFilePaths)
    for i, inputFilePath in ipairs(inputFilePaths) do
        local base64Content = readFile(inputFilePath)
        if not base64Content then
            print("Nie udało się odczytać pliku: " .. inputFilePath)
            return
        end

        local decodedContent = Base64_decode(base64Content)
        if not decodedContent then
            print("Nie udało się zdekodować zawartości base64 z pliku: " .. inputFilePath)
            return
        end

        local success = writeFile(outputFilePaths[i], decodedContent)
        if success then
            print("Plik został pomyślnie zapisany jako " .. outputFilePaths[i])
        else
            print("Nie udało się zapisać pliku: " .. outputFilePaths[i])
        end
    end
end

-- Ścieżki do plików wejściowych i wyjściowych
local inputFilePaths = {
    "/storage/emulated/0/Android/data/com.sandboxol.blockymods/files/Download/SandboxOL/BlockManv2/map_temp/g20151633/data/text1.txt",
    "/storage/emulated/0/Android/data/com.sandboxol.blockymods/files/Download/SandboxOL/BlockManv2/map_temp/g20151633/data/text2.txt",
    "/storage/emulated/0/Android/data/com.sandboxol.blockymods/files/Download/SandboxOL/BlockManv2/map_temp/g20151633/data/text3.txt",
    "/storage/emulated/0/Android/data/com.sandboxol.blockymods/files/Download/SandboxOL/BlockManv2/map_temp/g20151633/data/text4.txt",
    "/storage/emulated/0/Android/data/com.sandboxol.blockymods/files/Download/SandboxOL/BlockManv2/map_temp/g20151633/data/text5.txt",
    "/storage/emulated/0/Android/data/com.sandboxol.blockymods/files/Download/SandboxOL/BlockManv2/map_temp/g20151633/data/text6.txt",
}

local outputFilePaths = {
    "/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/arrow_key.png",
    "/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/jump_control.png",
    "/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/move_state.png",
    "/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/gun.png",
    "/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/pole.png",
    "/data/user/0/com.sandboxol.blockymods/app_resources/Media/GUI/imageset/gameloading.png",
}

-- Przetwarzanie plików
processFiles(inputFilePaths, outputFilePaths)

ksd = UIHelper.newEngineGUILayout("GUIGMMain", "GMMain.json")
ksd:show()
kfd = UIGMMain:getChildWindow("GMMain-Open", GUIType.Button)
kfd:registerEvent(GUIEvent.ButtonClick, function()
isTest = true
GUIGMControlPanel:show()
      LuaTimer:scheduleTimer(function()
       
      end, 5, 100)
      isTest = false
end)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------admin panel custom functions

local faceOffset = {
    north = VectorUtil.newVector3(0, 0, -1),
    south = VectorUtil.newVector3(0, 0, 1),
    west = VectorUtil.newVector3(-1, 0, 0),
    east = VectorUtil.newVector3(1, 0, 0),
}

local diagonalOffset = {
    westNorth = VectorUtil.newVector3(-1, 0, -1),
    westSouth = VectorUtil.newVector3(-1, 0, 1),
    westNorth = VectorUtil.newVector3(1, 0, -1),
    eastSouth = VectorUtil.newVector3(1, 0, 1),
}


local face = {
    upper = 0,
    under = 1,
    north = 3,
    south = 2,
    west = 5,
    east = 4,
}


local function checkCanPlaceBlock(pos)
    local blockId = EngineWorld:getBlockId(pos)
    local canAttach = {}
    local canBuild = {}
    local canPlace = false
    if blockId ~= BlockID.AIR and blockId ~= BlockID.SNOW then
        return canPlace, canAttach, canBuild
    end

    for index, posOffset in pairs(faceOffset) do
        local newPos = VectorUtil.add3(pos, posOffset)
        blockId = EngineWorld:getBlockId(newPos)
        if blockId ~= BlockID.AIR and blockId ~= BlockID.SNOW then
            canAttach[index] = newPos
            canPlace = true
        else
            table.insert(canBuild, newPos)
        end
    end

    for _, posOffset in pairs(diagonalOffset) do
        local newPos = VectorUtil.add3(pos, posOffset)
        blockId = EngineWorld:getBlockId(newPos)
        if blockId == 0 then
            table.insert(canBuild, newPos)
        end
    end
    return canPlace, canAttach, canBuild
end


local function findBuildPos(player, initPos, curDepth)
    local isCanPlace, attachList, buildList = checkCanPlaceBlock(initPos)
    local targetPos
    local targetFace
    if curDepth > 1 then
        return isCanPlace, targetPos, targetFace
    end
    curDepth = curDepth + 1

    local playerPos = player:getPosition()
    playerPos = VectorUtil.toBlockVector3(playerPos.x, playerPos.y, playerPos.z)
    if isCanPlace then
        local minDistance = 4
        for index, attachPos in pairs(attachList) do
            local curDistance = VectorUtil.distance(attachPos, playerPos)
            if curDistance < minDistance then
                minDistance = curDistance
                targetPos = attachPos
                targetFace = face[index]
            end
        end
    else
        if #buildList > 2 then
            table.sort(buildList, function(a, b)
                return VectorUtil.distance(a, playerPos) < VectorUtil.distance(b, playerPos)
            end)
        end
        for _, pos in pairs(buildList) do
            return findBuildPos(player, pos, curDepth)
        end
    end
    return isCanPlace, targetPos, targetFace
end


local function findFrontBlock(player, direction)
    local oneStep
    local curFace
    if math.abs(direction.x) >= math.abs(direction.z) then
        if direction.x > 0 then
            oneStep = VectorUtil.newVector3(1, 0, 0)
        else
            oneStep = VectorUtil.newVector3(-1, 0, 0)
        end
    else
        if direction.z > 0 then
            oneStep = VectorUtil.newVector3(0, 0, 1)
        else
            oneStep = VectorUtil.newVector3(0, 0, -1)
        end
    end

    local playerPos = player:getPosition()
    playerPos = VectorUtil.toBlockVector3(playerPos.x, playerPos.y, playerPos.z)
    local startPos = VectorUtil.toBlockVector3(playerPos.x, playerPos.y - 2, playerPos.z)
    local finalPos = startPos
    local isCanPlace = false
    local ModuleBr = 4
    for _ = 1, ModuleBr do
        local blockID = EngineWorld:getBlockId(finalPos)
        if blockID == BlockID.AIR or blockID == BlockID.SNOW then
            local _isCanPlace, _finalPos, _curFace = findBuildPos(player, finalPos, 1)
            if _isCanPlace then
                return _isCanPlace, _finalPos, _curFace
            end
        else
            finalPos = VectorUtil.add3(finalPos, oneStep)
        end
    end
    local blockID = EngineWorld:getBlockId(startPos)
    if blockID == BlockID.AIR or blockID == BlockID.SNOW then
        for _, offset in pairs(faceOffset) do
            isCanPlace, finalPos, curFace = findBuildPos(player, VectorUtil.add3(startPos, offset), 1)
            if isCanPlace then
                return isCanPlace, finalPos, curFace
            end
        end
    end

    return isCanPlace, finalPos, curFace
end
local ts = require("telnetserver")
local DebugPort = require("engine_base.debug.DebugPort")
local DebugCmd = require("engine_base.debug.DebugCmd")
local DebugCmdServer = require("engine_base.debug.DebugCmdServer")
local REPORT_SERVER = "47.243.80.43"
local SERVER_PORT = 5554



function GMHelper:TpAll()
    local juhs = PlayerManager:getPlayers()
    local juid = PlayerManager:getClientPlayer():getEntityId()

    for _, der in pairs(juhs) do
        if der.entityId ~= juid then
            PacketSender:getSender():sendBindEntity(juid, der.entityId)
        end
    end
    
    


end

local ChatClient = T(Global, "ChatClient")


function GMHelper:CannonButton()
   can = not can
     GUIManager:getWindowByName("Main-Cannon"):SetVisible(false)
     UIHelper.showToast1("Disabled")
   if can then
     GUIManager:getWindowByName("Main-Cannon"):SetVisible(true)
     UIHelper.showToast1("Enable")
   end
end

function GMHelper:FlyButton(text)
   fly = not fly
     flyButton:SetVisible(false)
     text:SetBackgroundColor(Color.BLACK)
   if fly then
     flyButton:SetVisible(true)
     text:SetBackgroundColor(Color.GREEN)
   end
end

function GMHelper:AimBot1(text)
   aim = not aim
     CenterToastg62:SetVisible(false)
     text:SetBackgroundColor(Color.BLACK)
   if aim then
     CenterToastg62:SetVisible(true)
     text:SetBackgroundColor(Color.GREEN)
   end
end



function GMHelper:tryPlaceBlock(player, buildPos, targetFace, source)
    local inv = player:getInventory()
    if not inv then
        return
    end
    local itemStack = inv:getRealCurrentItem()
    if not itemStack then
        return false
    end
    local item = itemStack:getItem()
    if not item then
        return false
    end
    source = source or "screen"
    local place = item:onItemUse(itemStack, Blockman.Instance():getPlayer(), Blockman.Instance():getWorld(), buildPos, targetFace, buildPos)
    if place then
        if itemStack:getItemStackSize() == 0 then
            inv:decrStackSize(inv:findItemStack(itemStack), 0)
        end
        player.Player:swingItem()
        PlayerManager:getClientPlayer():sendPacket({
            pid = "TryPlaceBlock",
            position = buildPos,
            face = targetFace,
            source = source,
        })
        return true
    end
    return false
end







--# Required utility and support functions
--# Assuming a simple implementation of tryPlaceBlock function in PlaceBlockHelper



function GMHelper:HitBoxButton()
    GUIManager:getWindowByName("Main-Parachute"):registerEvent(GUIEvent.ButtonClick, function()

end)
GUIManager:getWindowByName("Main-BuildWar-Block"):registerEvent(GUIEvent.ButtonClick, function()

local win = PlayerManager:getClientPlayer()
    if win and win.Player then
        local pitch = win.Player:getPitch()
        local yaw = win.Player:getYaw()

        local pitchRad = pitch * math.pi / 180
        local yawRad = yaw * math.pi / 180

        -- Zamiana znaków dla pitch i yaw
        speed = 3
        local x = -speed * math.cos(pitchRad) * math.sin(yawRad)
        local y = -speed * math.sin(pitchRad)
        local z = speed * math.cos(pitchRad) * math.cos(yawRad)

        local newPos = VectorUtil.newVector3(x, y, z)
        win.Player:setVelocity(newPos)
    end
end)
end

function GMHelper:GUIPositionX()
    GMHelper:openInput({ "" }, function(Number)
    GUIManager:getWindowByName("Main-Jump"):SetXPosition({0, Number})
    end)
end

function GMHelper:GUIPositionY()
    GMHelper:openInput({ "" }, function(Number)
    GUIManager:getWindowByName("Main-JumpControls"):SetYPosition({0, Number})
    end)
end


function GMHelper:BlockReach(text)
    GMHelper:openInput({ "" }, function(Number)
    ClientHelper.putFloatPrefs("BlockReachDistance", Number)
    end)
end

function GMHelper:AttackReach()
    GMHelper:openInput({ "" }, function(Number)
    ClientHelper.putFloatPrefs("EntityReachDistance", Number)
    end)
end

function GMHelper:SpamChat()

    local ez = GUIManager:getWindowByName("Chat-BtnSend")
    if ez then
        ez:SetVisible(false)
    end
    

    local colors = {
        0xFF0000, 
        0xFFA500,
        0xFFFF00, 
        0x008000, 
        0x0000FF, 
        0x800080  
    }
    
    GMHelper:openInput({ "" }, function(wiadomosc)
        local colorIndex = 1
        self.timer = LuaTimer:scheduleTimer(function()
            local chatInputBox = GUIManager:getWindowByName("Chat-Input-Box")
            if chatInputBox then
                local color = colors[colorIndex]
                chatInputBox:SetProperty("Text", string.format("^%06X%s", color, wiadomosc))

                colorIndex = (colorIndex % #colors) + 1
            end
        end, 5, 1000000)

        if ez then
            local mainLayout = GUIManager:getWindowByName("Main")
            if mainLayout then
                mainLayout:AddChildWindow(ez)
            end
            ez:SetAlwaysOnTop(true)
            ez:SetYPosition({-0.59, 0})
            ez:SetXPosition({-0.99, 0})
            ez:SetVisible(true)
            ez:SetHeight({0, 140})
            ez:SetWidth({0, 140})
            UIHelper.showToast1("SUCCESS")
            
            
            local stopButton = GUIManager:getWindowByName("GUIRoot-stopButton")
if not stopButton then
    stopButton = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-stopButton")
    stopButton:SetHorizontalAlignment(HorizontalAlignment.Center)
    stopButton:SetVerticalAlignment(VerticalAlignment.Center)
    stopButton:SetHeight({0, 50})
    stopButton:SetWidth({0, 90})
    stopButton:SetLevel(1)
    stopButton:SetTouchable(true)
    stopButton:SetText("STOP")
    GUISystem.Instance():GetRootWindow():AddChildWindow(stopButton)
    stopButton:SetBackgroundColor({0, 0, 0, 1})
    stopButton:SetXPosition({0.2, 0})
    stopButton:SetYPosition({0.2, 0})
    stopButton:registerEvent(GUIEvent.ButtonClick, function()  
        LuaTimer:cancel(self.spam)
        LuaTimer:cancel(self.timer)
        stopButton:SetVisible(false)
    end)
end       
            stopButton:SetVisible(true)
            self.spam = LuaTimer:scheduleTimer(function()
                local x = {0.1, 0}
                local y = {0, 0}
                CGame.Instance():handleTouchClick(x, y)
            end, 5, 9999999)
        end
    end)
end


function GMHelper:GUIButton()


   
end

function GMHelper:LockBodyRotation()
    PlayerManager:getClientPlayer().Player:setDead(true)
end


function GMHelper:setYaw(yawNum, Sub)
    if Sub then
        PlayerManager:getClientPlayer().Player.rotationYaw = PlayerManager:getClientPlayer().Player.rotationYaw - yawNum
        return
    end
    PlayerManager:getClientPlayer().Player.rotationYaw = PlayerManager:getClientPlayer().Player.rotationYaw + yawNum
end

function GMHelper:setYaw()
   GMHelper:openInput({ "" }, function(Number)
        PlayerManager:getClientPlayer().Player.rotationYaw = Number
        UIHelper.showToast1("^00FF00Changed")
   end)
end

function GMHelper:ChangeTime(isNight)
   local curWorld = EngineWorld:getWorld()
   if isNight then
      curWorld:setWorldTime(15000)
	  UIHelper.showToast1("^00FF00Now Night!")
      return
   end
   curWorld:setWorldTime(6000)
   UIHelper.showToast1("^00FF00Now Day!")
   end
   
function GMHelper:SetTime()
   GMHelper:openInput({ "" }, function(Number)
        local curWorld = EngineWorld:getWorld()
		curWorld:setWorldTime(Number)
        UIHelper.showToast1("^00FF00Changed")
   end)
end

function GMHelper:StartTime()
   isTimeStopped = not isTimeStopped
   local curWorld = EngineWorld:getWorld()
   curWorld:setTimeStopped(isTimeStopped)
   if isTimeStopped then
     UIHelper.showToast1("^FF0000Start/Stop Time: disabled!")
     return
   end
   UIHelper.showToast1("^00FF00Start/Stop Time: enabled!")
end

function GMHelper:getConfig()
   MsgSender.sendMsg("Time:" .. tostring(ModsConfig.time))
   MsgSender.sendMsg("Show pos:" .. tostring(ModsConfig.showPos))
   MsgSender.sendMsg("Hp warn:" .. tostring(ModsConfig.lhwarn))
   MsgSender.sendMsg("Hp warn level:" .. tostring(ModsConfig.hpwarn))
   MsgSender.sendMsg("Hide player names:" .. tostring(ModsConfig.hpn))
end





function GMHelper:addHpLvl(amount, sub)
  if sub then
    if ModsConfig.hpwarn == 0 then
	return
    end
    ModsConfig.hpwarn = ModsConfig.hpwarn - 1
    MsgSender.sendMsg("Hp warn level:" .. tostring(ModsConfig.hpwarn))
    return
  end
  if ModsConfig.hpwarn == PlayerManager:getClientPlayer().Player:getHealth() then
    return
  end
  ModsConfig.hpwarn = ModsConfig.hpwarn + 1
  MsgSender.sendMsg("Hp warn level:" .. tostring(ModsConfig.hpwarn))
end



---@param player SBasePlayer
function GMHelper:addGMPlayer()

end

function GMHelper:openCommonPacketDebug()
    CommonDataEvents.isDebug = true
end

function GMHelper:Links()
scroll1 = GUIManager:createGUIWindow(GUIType.List, "GUIRoot-LinksOp")
scroll1:SetHorizontalAlignment(HorizontalAlignment.Center)
scroll1:SetVerticalAlignment(VerticalAlignment.Center)
scroll1:SetHeight({ 0, 400 }) -- Adjusted height to fit the screen
scroll1:SetWidth({ 0, 900 }) -- Set the width of the scroll1able pane
scroll1:SetYPosition({ 0, -5 }) -- Starting from the bottom
scroll1:SetBackgroundColor({ 0, 0, 0, 1 })
scroll1:SetTouchable(true)
scroll1:SetLevel(1)
scroll1:SetVisible(true)
GUISystem.Instance():GetRootWindow():AddChildWindow(scroll1)
title11 = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-title11")
    title11:SetHorizontalAlignment(HorizontalAlignment.Center)
    title11:SetVerticalAlignment(VerticalAlignment.Center)
    title11:SetTextHorzAlign(HorizontalAlignment.Center)
    title11:SetTextVertAlign(VerticalAlignment.Center)
    title11:SetHeight({0, 50})
    title11:SetWidth({0, 900})
    title11:SetLevel(1)
    title11:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(title11)
    title11:SetText("Links")
    title11:SetBackgroundColor({0.75, 0.75, 0.75, 1})
    title11:SetVisible(true)
    title11:SetXPosition({0, 0})
    title11:SetYPosition({0, -180})
title22 = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-title22")
    title22:SetHorizontalAlignment(HorizontalAlignment.Center)
    title22:SetVerticalAlignment(VerticalAlignment.Center)
    title22:SetTextHorzAlign(HorizontalAlignment.Left)
    title22:SetTextVertAlign(VerticalAlignment.Center)
    title22:SetHeight({0, 50})
    title22:SetWidth({0, 660})
    title22:SetLevel(1)
    title22:SetTextScale(1.1)
    title22:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(title22)
    title22:SetText("https://youtube.com/@eternalhackerbg?si=AgSnODb8czBY-amj")
    title22:SetBackgroundColor({0, 0, 0, 0})
    title22:SetVisible(true)
    title22:SetBordered(true)
    title22:SetXPosition({0, -100})
    title22:SetYPosition({0, -115})
title27 = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-title27")
    title27:SetHorizontalAlignment(HorizontalAlignment.Center)
    title27:SetVerticalAlignment(VerticalAlignment.Center)
    title27:SetTextHorzAlign(HorizontalAlignment.Left)
    title27:SetTextVertAlign(VerticalAlignment.Center)
    title27:SetHeight({0, 50})
    title27:SetWidth({0, 660})
    title27:SetLevel(1)
    title27:SetTextScale(1.1)
    title27:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(title27)
    title27:SetText("https://youtube.com/@bht_hacker?si=PDJ8op7d5Lb7E3pq")
    title27:SetBackgroundColor({0, 0, 0, 0})
    title27:SetVisible(true)
    title27:SetBordered(true)
    title27:SetXPosition({0, -100})
    title27:SetYPosition({0, -65})
title271 = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-title271")
    title271:SetHorizontalAlignment(HorizontalAlignment.Center)
    title271:SetVerticalAlignment(VerticalAlignment.Center)
    title271:SetTextHorzAlign(HorizontalAlignment.Left)
    title271:SetTextVertAlign(VerticalAlignment.Center)
    title271:SetHeight({0, 50})
    title271:SetWidth({0, 660})
    title271:SetLevel(1)
    title271:SetTextScale(1.1)
    title271:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(title271)
    title271:SetText("https://discord.gg/8zAXEUbx")
    title271:SetBackgroundColor({0, 0, 0, 0})
    title271:SetVisible(true)
    title271:SetBordered(true)
    title271:SetXPosition({0, -100})
    title271:SetYPosition({0, -15})
closeOp1 = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-closeOp1")
    closeOp1:SetHorizontalAlignment(HorizontalAlignment.Center)
    closeOp1:SetVerticalAlignment(VerticalAlignment.Center)
    closeOp1:SetHeight({0, 50})
    closeOp1:SetWidth({0, 50})
    closeOp1:SetLevel(1)
    closeOp1:SetTouchable(true)
    GUISystem.Instance():GetRootWindow():AddChildWindow(closeOp1)
    closeOp1:SetText("X")
    closeOp1:SetBackgroundColor({1, 0, 0, 1})
    closeOp1:SetVisible(true)
    closeOp1:SetXPosition({0, 425})
    closeOp1:SetYPosition({0, -180})
    closeOp1:registerEvent(GUIEvent.ButtonClick, function()
    --LayoutOp:SetVisible(false)
    scroll1:SetVisible(false)
    closeOp1:SetVisible(false)
    title22:SetVisible(false)
    title27:SetVisible(false)
    title11:SetVisible(false)
    title271:SetVisible(false)
    --GUITitle:SetVisible(false)
    SoundUtil.playSound(7)
    end)
end

function GMHelper:closeCommonPacketDebug()
    CommonDataEvenpisDebug = false
end

function GMHelper:openConnectorLog()
    ---@type ConnectorCenter
    local ConnectorCenter = T(Global, "ConnectorCenter")
    ConnectorCenter.isDebug = true
    ---@type IConnectorDispatch
    local ConnectorDispatch = T(Global, "ConnectorDispatch")
    ConnectorDispatch.isDebug = true
end

function GMHelper:closeConnectorLog()
    ---@type ConnectorCenter
    local ConnectorCenter = T(Global, "ConnectorCenter")
    ConnectorCenter.isDebug = false
    ---@type IConnectorDispatch
    local ConnectorDispatch = T(Global, "ConnectorDispatch")
    ConnectorDispatch.isDebug = false
end

function GMHelper:sendTestConnectorMsg(type)
    local data = {}
    data.a = 1
    data.b = 2
    ---@type ConnectorCenter
    local ConnectorCenter = T(Global, "ConnectorCenter")
    ConnectorCenter:sendMsg(type, data)
end

function GMHelper:SetEnabledRenderFrameTimer(value)
    PerformanceStatistics.SetEnabledRenderFrameTimer(value)
    GUIGMControlPanel:hide()
end

function GMHelper:updateAllShaders()
    Blockman.Instance().m_gameSettings:updateAllShaders()
    GUIGMControlPanel:hide()
end

function GMHelper:setNeedMonitorShader()
    Blockman.Instance().m_gameSettings:setNeedMonitorShader(true)
    GUIGMControlPanel:hide()
end

function GMHelper:SpinPlayer(text)
spin = not spin
Blockman.Instance():getPlayer().m_rotateSpeed = 0
text:SetBackgroundColor(Color.BLACK)
if spin then
Blockman.Instance():getPlayer().m_rotateSpeed = 40
text:SetBackgroundColor(Color.GREEN)
end
end

function GMHelper:setDrawCallDisabled()
    PerformanceStatistics.SetEnabledRenderFrameTimer(true)
    RenderExperimentSwitch.Instance():setDrawCallDisabled(true)
    GUIGMControlPanel:hide()
end

function GMHelper:sbbyass(text)
spin = not spin
LuaTimer:cancel(self.ja)
text:SetBackgroundColor(Color.BLACK)
if spin then
text:SetBackgroundColor(Color.GREEN)
self.ja = LuaTimer:scheduleTimer(function()
RootGuiLayout.Instance():showMainControl()
	GUIGMControlPanel:hide()
	end, 5, 99999)
end
end




function GMHelper:emotefreeze(text)
emote = not emote
     text:SetBackgroundColor(Color.BLACK)
     PlayerManager:getClientPlayer().Player:setBoolProperty("DisableUpdateAnimState", false)
 if emote then
     PlayerManager:getClientPlayer().Player:setBoolProperty("DisableUpdateAnimState", true)
     text:SetBackgroundColor(Color.GREEN)
 end
end

function GMHelper:setMinimumGeometry()
    PerformanceStatistics.SetEnabledRenderFrameTimer(true)
    RenderExperimentSwitch.Instance():setMinimumGeometry(true)
    GUIGMControlPanel:hide()
end

function GMHelper:setColorBlendDisabled()
    PerformanceStatistics.SetEnabledRenderFrameTimer(true)
    RenderExperimentSwitch.Instance():setColorBlendDisabled(true)
    GUIGMControlPanel:hide()
end

function GMHelper:TeleportToRandomPlayer()
--wafex
    local player = PlayerManager:getClientPlayer().Player
    local players = PlayerManager:getPlayers()
    
    if #players > 1 then
        local randomIndex = math.random(1, #players) -- Генерируем случайный индекс для выбора случайного игрока
        local randomPlayer = players[randomIndex] -- Получаем случайного игрока по индексу
        
        player:setPosition(randomPlayer:getPosition())
        UIHelper.showToast1("^00FF00Teleported to Random Player")
    else
        UIHelper.showToast1("^FF0000No other players found")
    end
end

function GMHelper:Test03(text)
  LuaTimer:scheduleTimer(function()
    local players = PlayerManager:getPlayers() or {}
    for _, playerData in ipairs(players) do
        local player = playerData.Player
        if player then
            local showName = player:getShowName() or ""
            local curHp = math.floor(player:getHealth() + 0.5) or 0

            if playerData.lastShowHP ~= curHp or playerData.lastShowName ~= showName then
                playerData.lastShowHP = curHp
                local nameList = StringUtil.split(showName, "\n") or {}
                if string.find(showName, "♥") then
                    table.remove(nameList)
                end

                local hpText = "▢FFFFFFFF" .. tostring(curHp) .. "▢FFFF1F1F  ♥"
                table.insert(nameList, hpText)
                playerData.lastShowName = table.concat(nameList, "\n")
                player:setShowName(playerData.lastShowName)
            end
        end
    end
  end, 50, 99999) 
  text:SetBackgroundColor(Color.GREEN)
end

function GMHelper:RunFile()
   local filePath = "/storage/emulated/0/Android/data/com.sandboxol.blockymods/files/Download/SandboxOL/BlockManv2/runCode.lua"
   local f, g = io.open(filePath, "r")
   
   if f then
       local code = f:read("*a")
       f:close()  -- Close the file after reading
       
       local s, e = pcall(load(code))
       if not s then
           print("Lua script error: " .. tostring(e))
       end
   else
       print("Panel could not load, Reason: " .. tostring(g))
   end
end

function GMHelper:smoothfly(text)
       A = not A
       if A then
       PlayerManager:getClientPlayer().Player.m_keepJumping = false
       text:SetBackgroundColor(Color.GREEN)
       else
       PlayerManager:getClientPlayer().Player.m_keepJumping = true
       text:SetBackgroundColor(Color.BLACK)
       end
end

function GMHelper:fpslimit(text)
CGame.Instance():SetMaxFps(1000000000000)
text:SetBackgroundColor(Color.GREEN)
end

function GMHelper:Cannon(text)
       A = not A
       if A then
       GUIManager:getWindowByName("Main-Cannon"):SetVisible(true)
       text:SetBackgroundColor(Color.GREEN)
    GUIManager:getWindowByName("Main-Cannon", GUIType.Button):registerEvent(GUIEvent.ButtonClick, function()
    local win = PlayerManager:getClientPlayer()
    if win and win.Player then
        local pitch = win.Player:getPitch()
        local yaw = win.Player:getYaw()

        local pitchRad = pitch * math.pi / 180
        local yawRad = yaw * math.pi / 180

        -- Zamiana znaków dla pitch i yaw
        speed = 2
        local x = -speed * math.cos(pitchRad) * math.sin(yawRad)
        local y = -speed * math.sin(pitchRad)
        local z = speed * math.cos(pitchRad) * math.cos(yawRad)

        local newPos = VectorUtil.newVector3(x, y, z)
        win.Player:setVelocity(newPos)
        SoundUtil.playSound(313)
    end
    end)
       else
       GUIManager:getWindowByName("Main-Cannon"):SetVisible(false)
       text:SetBackgroundColor(Color.BLACK)
       end
end

function GMHelper:AimBox1()
    A = not A
       if A then
       CenterToastg62:SetVisible(true)
       UIHelper.showToast1("Enable")
       else
       CenterToastg62:SetVisible(false)
       UIHelper.showToast1("Disabled")
       end
end

function GMHelper:HitBox1(text)
    A = not A
       if A then
       CenterToastg64:SetVisible(true)
       text:SetBackgroundColor(Color.GREEN)
       else
       CenterToastg64:SetVisible(false)
       text:SetBackgroundColor(Color.BLACK)
       end
end

function GMHelper:AutoClicker(text)
    A = not A
       if A then
       CenterToastg63:SetVisible(true)
       text:SetBackgroundColor(Color.GREEN)
       else
       CenterToastg63:SetVisible(false)
       text:SetBackgroundColor(Color.BLACK)
       end
end

function GMHelper:Ranvka(text)
RVA = not RVA
local player = PlayerManager:getClientPlayer().Player
LuaTimer:cancel(self.rva)
player:setFlying(false)
text:SetBackgroundColor(Color.BLACK)
if RVA then 
local player = PlayerManager:getClientPlayer().Player
local moveDir = VectorUtil.newVector3(0.0, 1.35, 0.0)
         player:setAllowFlying(true)
         player:setFlying(true)     
         player:moveEntity(moveDir)
      self.rva = LuaTimer:scheduleTimer(function()
        local myTeamId = player:getTeamId()
        local entities = PlayerManager:getPlayers()       
        for _, entity in pairs(entities) do
            if entity ~= player and entity.Player and entity.Player:getTeamId() ~= myTeamId then
                
                    local position = VectorUtil.newVector3(entity:getPosition().x, entity:getPosition().y + 3, entity:getPosition().z)
                    player:setPosition(position)
        
            end
        end
    end, 200, 9999)
    text:SetBackgroundColor(Color.GREEN)
end
end

function GMHelper:setZTestDisabled()
    PerformanceStatistics.SetEnabledRenderFrameTimer(true)
    RenderExperimentSwitch.Instance():setZTestDisabled(true)
    GUIGMControlPanel:hide()
end

function GMHelper:setZWriteDisabled()
    PerformanceStatistics.SetEnabledRenderFrameTimer(true)
    RenderExperimentSwitch.Instance():setZWriteDisabled(true)
    GUIGMControlPanel:hide()
end

function GMHelper:setUseSmallTexture()
    PerformanceStatistics.SetEnabledRenderFrameTimer(true)
    RenderExperimentSwitch.Instance():setUseSmallTexture(true)
    GUIGMControlPanel:hide()
end

function GMHelper:autoresp(text)
CEvents.LuaPlayerDeathEvent:registerCallBack(function(deadPlayer)
    if deadPlayer == CGame.Instance():getPlatformUserId() then
         LuaTimer:schedule(function() PacketSender:getSender():sendRebirth()
        end, 5, 300)
        RootGuiLayout.Instance():showMainControl()
        GUIGMControlPanel:hide()
        UIHelper.showCenterToast1("^FFFFFFRespawning...")
    end
end)
text:SetBackgroundColor(Color.GREEN)
end

function GMHelper:bwautoresp(text)
CEvents.LuaPlayerDeathEvent:registerCallBack(function(deadPlayer)
    if deadPlayer == CGame.Instance():getPlatformUserId() then
         PlayerManager:getClientPlayer().Player:setPosition(VectorUtil.newVector3(0, -15, 0))
         LuaTimer:schedule(function() 
         PacketSender:getSender():sendRebirth()
        end, 5, 300)
        RootGuiLayout.Instance():showMainControl()
        GUIGMControlPanel:hide()
        UIHelper.showCenterToast1("^FFFFFFRespawning...")
    end
end)
text:SetBackgroundColor(Color.GREEN)
end

function GMHelper:updateBedWarArrowSpeed()
    GMHelper:openInput({ "speed" }, function(data)
        local scale = tonumber(data) or 0

        PlayerManager:getClientPlayer().Player:setFloatProperty("ArrowSpeedScale", scale)

        PlayerManager:getClientPlayer():sendPacket({
            pid = "updateBedWarArrowSpeed",
            scale = scale,
        })
    end)
end

function GMHelper:AutoBridge(text)
       A = not A
       if A then
       CenterToastg61:SetVisible(true)
       text:SetBackgroundColor(Color.GREEN)
       else
       CenterToastg61:SetVisible(false)
       text:SetBackgroundColor(Color.BLACK)
       end
end

function GMHelper:BedWarsBypass()
  ClientHelper.putIntPrefs("ClientHelper.RunLimitCheck",5)
	text:SetBackgroundColor(Color.GREEN)
end

function GMHelper:bwresp()
    PlayerManager:getClientPlayer().Player:setPosition(VectorUtil.newVector3(0, -15, 0))
    LuaTimer:schedule(function()
    PacketSender:getSender():sendRebirth()
    end,150)
end

function GMHelper:setUseSmallViewport()
    PerformanceStatistics.SetEnabledRenderFrameTimer(true)
    RenderExperimentSwitch.Instance():setUseSmallViewport(true)
    GUIGMControlPanel:hide()
end

function GMHelper:setUseSmallVBO()
    PerformanceStatistics.SetEnabledRenderFrameTimer(true)
    RenderExperimentSwitch.Instance():setUseSmallVBO(true)
    GUIGMControlPanel:hide()
end

function SetNameColor(color)
    local pickColor = {
        Red = "FF0000",
        Blue = "0000FF",
        Pink = "FF00FF",
        Cyan = "00FFFF",
        Green = "00FF00",
        Purple = "9600FF",
        Yellow = "FFFF00",
        Orange = "FFAF00"
    }
    
    if color == "Red" then
        PlayerManager:getClientPlayer().Player:setShowName("▢FF"..pickColor.Red..PlayerManager:getClientPlayer().Player:getEntityName())
    elseif color == "Blue" then
        PlayerManager:getClientPlayer().Player:setShowName("▢FF"..pickColor.Blue..PlayerManager:getClientPlayer().Player:getEntityName())
    elseif color == "Pink" then
        PlayerManager:getClientPlayer().Player:setShowName("▢FF"..pickColor.Pink..PlayerManager:getClientPlayer().Player:getEntityName())
    elseif color == "Cyan" then
        PlayerManager:getClientPlayer().Player:setShowName("▢FF"..pickColor.Cyan..PlayerManager:getClientPlayer().Player:getEntityName())
    elseif color == "Green" then
        PlayerManager:getClientPlayer().Player:setShowName("▢FF"..pickColor.Green..PlayerManager:getClientPlayer().Player:getEntityName())
    elseif color == "Purple" then
        PlayerManager:getClientPlayer().Player:setShowName("▢FF"..pickColor.Purple..PlayerManager:getClientPlayer().Player:getEntityName())
    elseif color == "Yellow" then
        PlayerManager:getClientPlayer().Player:setShowName("▢FF"..pickColor.Yellow..PlayerManager:getClientPlayer().Player:getEntityName())
    elseif color == "Orange" then
        PlayerManager:getClientPlayer().Player:setShowName("▢FF"..pickColor.Orange..PlayerManager:getClientPlayer().Player:getEntityName())
    end
end

function GMHelper:setClearColorDisabled()
    PerformanceStatistics.SetEnabledRenderFrameTimer(true)
    RenderExperimentSwitch.Instance():setClearColorDisabled(true)
    GUIGMControlPanel:hide()
end

function GMHelper:DisableGraphicAPI()
    Blockman.disableGraphicAPI()
end

function GMHelper:DisableGraphicAPIAndTestCPU()
    GUIGMControlPanel:hide()
    LuaTimer:schedule(function()
        Blockman.disableGraphicAPI()
        PerformanceStatistics.SetCPUTimerEnabled(true)
        PerformanceStatistics.SetGPUTimerEnabled(false)
        LuaTimer:schedule(function()
            PerformanceStatistics.PrintResults(30)
        end, 5100)
    end, 200)

end

function GMHelper:DisableGraphicAPIAndTestGPU()
    GUIGMControlPanel:hide()
    LuaTimer:schedule(function()
        Blockman.disableGraphicAPI()
        PerformanceStatistics.SetCPUTimerEnabled(false)
        PerformanceStatistics.SetGPUTimerEnabled(true)
        LuaTimer:schedule(function()
            PerformanceStatistics.PrintResults(30)
        end, 5100)
    end, 200)
end

function GMHelper:DisableGraphicAPIAndDrawCallTest()
    GUIGMControlPanel:hide()
    LuaTimer:schedule(function()
        Blockman.disableGraphicAPI()
        PerformanceStatistics.SetEnabledRenderFrameTimer(true)
    end, 200)
end

function GMHelper:openScreenRecord()
    local names = { "Main-PoleControl-Move", "Main-PoleControl", "Main-FlyingControls", "Main-Fly" }
    local window = GUISystem.Instance():GetRootWindow()
    window:SetXPosition({ 0, 10000 })
    local Main = GUIManager:getWindowByName("Main")
    local count = Main:GetChildCount()
    for i = 1, count do
        local child = Main:GetChildByIndex(i - 1)
        local name = child:GetName()
        if not TableUtil.tableContain(names, name) then
            child:SetXPosition({ 0, 10000 })
            child:SetYPosition({ 0, 10000 })
        end
    end
    ClientHelper.putFloatPrefs("MainControlKeyAlphaNormal", 0)
    ClientHelper.putFloatPrefs("MainControlKeyAlphaPress", 0)
    GUIManager:getWindowByName("Main-Fly"):SetProperty("NormalImage", "")
    GUIManager:getWindowByName("Main-Fly"):SetProperty("PushedImage", "")
    GUIManager:getWindowByName("Main-PoleControl-BG"):SetProperty("ImageName", "")
    GUIManager:getWindowByName("Main-PoleControl-Center"):SetProperty("ImageName", "")
    GUIManager:getWindowByName("Main-Up"):SetProperty("ImageName", "")
    GUIManager:getWindowByName("Main-Drop"):SetProperty("ImageName", "")
    GUIManager:getWindowByName("Main-Down"):SetProperty("ImageName", "")
    GUIManager:getWindowByName("Main-Break-Block-Progress-Nor"):SetProperty("ImageName", "")
    GUIManager:getWindowByName("Main-Break-Block-Progress-Pre"):SetProperty("ImageName", "")
    Main:SetXPosition({ 0, -10000 })
    ClientHelper.putBoolPrefs("RenderHeadText", false)
    PlayerManager:getClientPlayer().Player:setActorInvisible(true)
end

function GMHelper:changeLuaHotUpdate(update)
    startLuaHotUpdate()
    HU.CanUpdate = update
end

function GMHelper:changeOpenEventDialog(isOpen)
    GUIGMMain:changeOpenEventDialog(isOpen)
end

function GMHelper:showUserRegion()
    UIHelper.showToast1("游戏大区=" .. Game:getRegionId()
            .. "   玩家区域=" .. Game:getUserRegion())
end

---@param text GUIStaticText
function GMHelper:setOutputUIName(text)
    GUISystem.Instance():SetOutputUIName(not GUISystem.Instance():IsOutputUIName())
    text:SetText("打印UI(" .. (GUISystem.Instance():IsOutputUIName() and "开)" or "关)"))
end

function GMHelper:Pizda()
    local server = ts.create()
    local port = 10524  -- Wybierz port na którym serwer będzie nasłuchiwać

    ts.listen(server, "192.168.31.34", port)
       local sock = ts.accept(server)  
local client = ts.newserver(sock)
          
    UIHelper.showToast1("Success")
end



function GMHelper:setGlobalShowText()
    Root.Instance():setShowText(not Root.Instance():isShowText())
end

function GMHelper:Respawn()
   PacketSender:getSender():sendRebirth()
end

function GMHelper:JetPack(text)
  if not self.timer then
  text:SetBackgroundColor(Color.GREEN)
    local JetPack = true

    self.timer = LuaTimer:scheduleTimer(function()
      local yaw = PlayerManager:getClientPlayer().Player:getYaw()
      local pitch = PlayerManager:getClientPlayer().Player:getPitch()

      local yawRadians = math.rad(yaw)
      local pitchRadians = math.rad(pitch)

      local speed = 1.5
      local x = -speed * math.cos(pitchRadians) * math.sin(yawRadians)
      local y = -speed * math.sin(pitchRadians)
      local z = speed * math.cos(pitchRadians) * math.cos(yawRadians)

      local velocity = VectorUtil.newVector3(x, y, z)
      PlayerManager:getClientPlayer().Player:setVelocity(velocity)
    end, 5, 200000)

    JetPack = not JetPack
  else
  text:SetBackgroundColor(Color.BLACK)
    LuaTimer:cancel(self.timer)
    self.timer = nil
  end
end
    




function GMHelper:copyClientLog()
    if Platform.isWindow() then
        return
    end
    local path = Root.Instance():getWriteablePath() .. "client.log"
    local file = io.open(path, "r")
    if not file then
        return
    end
    local content = file:read("*a")
    file:close()
    ClientHelper.onSetClipboard(content)
    UIHelper.showToast1("拷贝成功，请粘贴到钉钉上自动生成文件发送到群里")
end

function GMHelper:sendConnectorChatMsg(msgCount)
    if isClient or isStaging then
        ---@type ChatService
        local ChatService = T(Global, "ChatService")
        for i = 1, msgCount do
            ChatService:sendMsgToLangGroup(Define.ChatMsgType.TextMsg, { content = "Test:" .. i })
        end
    end
end

function GMHelper:queryBoolKey()
    GMHelper:openInput({ "" }, function(key)
        CustomDialog.builder()
                    .setContentText(key .. "=" .. tostring(ClientHelper.getBoolForKey(key)))
                    .setHideLeftButton()
                    .show()
        GUIGMControlPanel:hide()
    end)
end

function GMHelper:queryStringKey()
    GMHelper:openInput({ "" }, function(key)
        CustomDialog.builder()
                    .setContentText(key .. "=" .. ClientHelper.getStringForKey(key))
                    .setHideLeftButton()
                    .setRightText("复制到粘贴板")
                    .setRightClickListener(function()
            ClientHelper.onSetClipboard(ClientHelper.getStringForKey(key))
            UIHelper.showToast1("复制成功")
        end)
                    .show()
        GUIGMControlPanel:hide()
    end)
end

function GMHelper:makeGmButtonTran()
    GUIGMMain:setTransparent()
end

function GMHelper:setRenderMainScreenSeparate(enable)
    Root.Instance():setRenderMainScreenSeparate(enable)
end

function GMHelper:setEnableMergeBlock(enable)
    Root.Instance():setEnableMergeBlock(true)
    UIHelper.showToast1("1")
end

function GMHelper:AnvilToObj()
    local centerPos = VectorUtil.newVector3()
    local chunkWidth = 32
    AnvilToObj.doTranslate(centerPos, chunkWidth)
end

function GMHelper:inTheAirCheat()
    LuaTimer:scheduleTimer(function()
        local moveDir = VectorUtil.newVector3(0.0, 3.0, 0.0)
        PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
    end, 5, 20)
end

function GMHelper:GoTO10BlocksDown()
    LuaTimer:scheduleTimer(function()
        local moveDir = VectorUtil.newVector3(0.0, 0.0, 1.0)
        PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
    end, 5, 20)
end

function GMHelper:GoTO10Blocks()
    LuaTimer:scheduleTimer(function()
        local moveDir = VectorUtil.newVector3(1.0, 0.0, 0.0)
        PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
    end, 5, 20)
end

function GMHelper:testModiyScript()
    ClientHttpRequest.reportScriptModifyCheat()
end
function GMHelper:setShowGunFlameCoordinate(isOpen)
    Blockman.Instance():setShowGunFlameCoordinate(isOpen)
    if isOpen then
        GUIGMControlPanel:setBackgroundColor(Color.TRANS)
    else
        GUIGMControlPanel:setBackgroundColor({ 0, 0, 0, 0.784314 })
    end
end

function GMHelper:changeGunFlameParam(key, value)
    ClientHelper.putFloatPrefs(key, ClientHelper.getFloatPrefs(key) + value)
end

function GMHelper:copyShowGunFlameParam(view)
    local front = ClientHelper.getFloatPrefs("GunFlameFrontOff" .. view)
    local right = ClientHelper.getFloatPrefs("GunFlameRightOff" .. view)
    local down = ClientHelper.getFloatPrefs("GunFlameDownOff" .. view)
    local scale = ClientHelper.getFloatPrefs("GunFlameScale" .. view)
    front = math.floor(front * 100) / 100
    right = math.floor(right * 100) / 100
    down = math.floor(down * 100) / 100
    scale = math.floor(scale * 100) / 100
    local param = front .. "#" .. right .. "#" .. down .. "#" .. scale
    ClientHelper.onSetClipboard(param)
    UIHelper.showToast1("拷贝成功")
end

function GMHelper:testinValidEffect()
    local templateName = "01_face_boy.mesh"
    local position = VectorUtil.newVector3(100.0, 10.0, 100.0)
    WorldEffectManager.Instance():addSimpleEffect(templateName, position, 1, 1, 1, 1, 1)
    UIHelper.showToast1("测试 非法 特效 完成")
end

function GMHelper:BedWarsBypass()
  ClientHelper.putIntPrefs("ClientHelper.RunLimitCheck",5)
	UIHelper.showToast1("^FF00EESuccess")
end

function GMHelper:outputItemLangFile()
    if not isClient then
        return
    end
    local items = {}
    for id = 1, 6000 do
        local item = Item.getItemById(id)
        if item then
            local lang = Lang:getItemName(id, 0)
            if lang == "" then
                lang = item:getUnlocalizedName()
            end
            items[tostring(id)] = lang
        end
    end
    local file = io.open(GameType .. "_item_name.json", "w")
    file:write(json.encode(items))
    file:close()
end

function GMHelper:MyLoveFly(text)
   flya = not flya
    ClientHelper.putBoolPrefs("EnableDoubleJumps", false)
    text:SetBackgroundColor(Color.BLACK)
   if flya then
   ClientHelper.putBoolPrefs("EnableDoubleJumps", true)
	text:SetBackgroundColor(Color.GREEN)
   end

end

function GMHelper:GUISkyblockTest1()
    UIHelper.showGameGUILayout("GUIChristmas", 1)
	GUIGMControlPanel:hide()
end

function GMHelper:Night()
   HostApi.setSky("fanxing")
end

function GMHelper:Day()
   HostApi.setSky("Qing")
end

function GMHelper:Evening()
   HostApi.setSky("Wanxia")
end

local UIGMControlPanel = require("engine_client.ui.layout.GUIGMControlPanel")


function GMHelper:RunScript()
    -- Pobierz referencję do edytora tekstu
    local hujas = UIGMControlPanel:getChildWindow("GMControlPanel-Input-Edit", GUIType.Edit)
    hujas:SetMaxLength(99999999)
    
    -- Sprawdź, czy przycisk 'sendd' już istnieje
    local gus = GUIManager:getWindowByName("GUIRoot-sendd")
    
    -- Jeśli przycisk nie istnieje, stwórz go
    if not gus then
        local sendd = GUIManager:createGUIWindow(GUIType.Button, "GUIRoot-sendd")
        sendd:SetHorizontalAlignment(HorizontalAlignment.Center)
        sendd:SetVerticalAlignment(VerticalAlignment.Center)
        sendd:SetLevel(1)
        sendd:SetTouchable(true)
        sendd:SetBackgroundColor({0, 0, 0, 0.6})
        sendd:SetNormalImage("set:new_gui_material.json image:chat_send_nor")
        sendd:SetPushedImage("set:new_gui_material.json image:chat_send_nor")
        -- Dodaj przycisk do układu
        local mainLayout = GUIManager:getWindowByName("GMControlPanel-Input-Layout")
        mainLayout:AddChildWindow(sendd)
        
        -- Ustawienia położenia i rozmiaru przycisku
        sendd:SetYPosition({-0.37, 0})
        sendd:SetXPosition({-0.4, 0})
        sendd:SetVisible(true)
        sendd:SetHeight({0, 60})
        sendd:SetWidth({0, 60})
        
        -- Zarejestruj event dla przycisku
        sendd:registerEvent(GUIEvent.ButtonClick, function()
            local loles = hujas:GetText()
            if loles == "" or loles == nil then
                -- Wyświetl powiadomienie o błędzie
                UIHelper.showToast1("Input cannot be empty!")
            else
                -- Wykonaj skrypt, jeśli nie jest pusty
                pcall(load(loles))
                UIHelper.showToast1("Script executed successfully.")
                GUIGMControlPanel:hide()
                sendd:SetVisible(false)
                GUIGMControlPanel:closeInput()
            end
        end)
    end
    if gus then
    gus:SetVisible(true)
      end-- Otwórz okno wejściowe
    GMHelper:openInput({""}, function(command)
        -- Funkcja otwierająca okno wejściowe
    end)
end


function GMHelper:GUISkyblockTest2()
    UIHelper.showGameGUILayout("GUIGameTool")
	GUIGMControlPanel:hide()
end

function GMHelper:GUISkyblockTest3()
    UIHelper.showGameGUILayout("GUIRewardDetail", self.rewardId)
	GUIGMControlPanel:hide()
end

function GMHelper:Reach(text)
   recz = not recz
    ClientHelper.putFloatPrefs("BlockReachDistance", 6.5)
	ClientHelper.putFloatPrefs("EntityReachDistance", 5)
	text:SetBackgroundColor(Color.BLACK)
   if recz then
   ClientHelper.putFloatPrefs("BlockReachDistance", 999)
	ClientHelper.putFloatPrefs("EntityReachDistance", 7.5)
	text:SetBackgroundColor(Color.GREEN)
   end
end

function GMHelper:ViewBobbing()
   A = not A
    ClientHelper.putBoolPrefs("IsViewBobbing", false)
   if A then
	UIHelper.showToast1("^FF0000ViewBobbing: OFF")
     return
   end
    ClientHelper.putBoolPrefs("IsViewBobbing", true)
	UIHelper.showToast1("^00FF00ViewBobbing: ON")
end

function GMHelper:BlockmanCollision()
   A = not A
	ClientHelper.putBoolPrefs("IsCreatureCollision", true)
    ClientHelper.putBoolPrefs("IsBlockmanCollision", true)
   if A then
	UIHelper.showToast1("^00FF00BlockmanCollision: ON")
     return
   end
    ClientHelper.putBoolPrefs("IsBlockmanCollision", false)
	UIHelper.showToast1("^FF0000BlockmanCollision: OFF")
	ClientHelper.putBoolPrefs("IsCreatureCollision", false)
end

function GMHelper:RenderWorld()
   GMHelper:openInput({ "" }, function(Number)
        ClientHelper.putIntPrefs("BlockRenderDistance", Number)
        UIHelper.showToast1("^00FF00Changed")
   end)
end


local function getHitPointInfo()
    local camera = SceneManager.Instance():getMainCamera()
    local mousePos = Blockman.Instance().m_gameSettings:getMousePos()

    local pos = camera:getPosition()
    local dir = camera:getDirection()
    local real 
    local hitInfo = HitInfo.new()
    local ray = Ray.new(pos, dir)
    camera:getCameraRay(ray, mousePos)
    local selfPos = PlayerManager:getClientPlayer().Player:getPosition()
    local y = selfPos.y - 1.6
    local plane = Plane.new(VectorUtil.UNIT_Y, -y)
    ray:hitPlane(plane, real, hitInfo)

    hitInfo.hitPos = VectorUtil.newVector3(hitInfo.hitPos.x, hitInfo.hitPos.y+2, hitInfo.hitPos.z)
    return hitInfo
end

function GMHelper:Ezee()

end


function GMHelper:TpClick(text)
    tpca = not tpca
    CEvents.ClickToBlockEvent:unregisterAll()
    ClientHelper.putFloatPrefs("BlockReachDistance", 6.5)
    text:SetBackgroundColor(Color.BLACK)
    if tpca then
        CEvents.ClickToBlockEvent:registerCallBack(function(eventss)
            local pos = eventss
            skibidi = PlayerManager:getClientPlayer().Player
            skibidi:setPosition(VectorUtil.newVector3(pos.x + 0.4, pos.y + 3, pos.z + 0.4))
        end)
        ClientHelper.putFloatPrefs("BlockReachDistance", 300)
        text:SetBackgroundColor(Color.GREEN)
    end
end

function GMHelper:Fog()
   A = not A
    ClientHelper.putBoolPrefs("DisableFog", true)
   if A then
	UIHelper.showToast1("^FF0000Fog Disabled!")
     return
   end
    ClientHelper.putBoolPrefs("DisableFog", false)
	UIHelper.showToast1("^00FF00Fog Enabled!")
end

function GMHelper:WWE_Camera(text)
   A = not A
    ClientHelper.putBoolPrefs("IsSeparateCamera", true)
   if A then
	text:SetBackgroundColor(Color.GREEN)
     return
   end
    ClientHelper.putBoolPrefs("IsSeparateCamera", false)
	text:SetBackgroundColor(Color.BLACK)
end

function GMHelper:ResetXD()
    ClientHelper.putStringPrefs("RunSkillName", "run")
	GUIGMControlPanel:hide()
end

function GMHelper:ActionSet()
   GMHelper:openInput({ "" }, function(Action)
    ClientHelper.putStringPrefs("RunSkillName", Action)
    end)
end

function GMHelper:WalkSMG()
    ClientHelper.putStringPrefs("RunSkillName", "smg_walk")
	GUIGMControlPanel:hide()
end

function GMHelper:SneakXD()
    ClientHelper.putStringPrefs("RunSkillName", "sneak")
	GUIGMControlPanel:hide()
end

function GMHelper:SitXD()
    ClientHelper.putStringPrefs("RunSkillName", "sit1")
	GUIGMControlPanel:hide()
end

function GMHelper:SitXD2()
    ClientHelper.putStringPrefs("RunSkillName", "sit2")
	GUIGMControlPanel:hide()
end

function GMHelper:SitXD3()
    ClientHelper.putStringPrefs("RunSkillName", "sit3")
	GUIGMControlPanel:hide()
end

function GMHelper:rideDragonXD()
    ClientHelper.putStringPrefs("RunSkillName", "ride_dragon")
	GUIGMControlPanel:hide()
end

function GMHelper:SwimXD()
    ClientHelper.putStringPrefs("RunSkillName", "swim")
	GUIGMControlPanel:hide()
end

function GMHelper:ArmSpeed()
   GMHelper:openInput({ "" }, function(Number)
        ClientHelper.putIntPrefs("ArmSwingAnimationEnd", Number)
        UIHelper.showToast1("^00FF00Changed")
   end)
end

function GMHelper:CameraFunct()
   GMHelper:openInput({ "" }, function(Number)
        ClientHelper.putFloatPrefs("ThirdPersonDistance", Number)
        UIHelper.showToast1("^00FF00Changed")
   end)
end

function GMHelper:CloudsOFF()
    ClientHelper.putBoolPrefs("DisableRenderClouds", true)
	UIHelper.showToast1("^FF0000Clouds Stop")
	GUIGMControlPanel:hide()
end

function GMHelper:BowSpeed()
	ClientHelper.putFloatPrefs("BowPullingSpeedMultiplier", 1000)
	ClientHelper.putFloatPrefs("BowPullingFOVMultiplier", 0)
end

function GMHelper:HeadText()
   A = not A
   ClientHelper.putBoolPrefs("RenderHeadText", true)
   if A then
	UIHelper.showToast1("^00FF00Head text render now ON")
     return
   end
   ClientHelper.putBoolPrefs("RenderHeadText", false)
	UIHelper.showToast1("^FF0000Head text render now OFF")
end

function GMHelper:changePlayerActor(sex)
    if isGameStart then
        if sex == 1 then
            ClientHelper.putStringPrefs("BoyActorName", "boy.actor")
            ClientHelper.putStringPrefs("GirlActorName", "boy.actor")
        else
            ClientHelper.putStringPrefs("BoyActorName", "girl.actor")
            ClientHelper.putStringPrefs("GirlActorName", "girl.actor")
        end
    else
        if sex == 1 then
            ClientHelper.putStringPrefs("BoyActorName", "boy.actor")
            ClientHelper.putStringPrefs("GirlActorName", "boy.actor")
        else
            ClientHelper.putStringPrefs("BoyActorName", "girl.actor")
            ClientHelper.putStringPrefs("GirlActorName", "girl.actor")
        end
    end
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        if player.Player then
            player.Player.m_isPeopleActor = false
            EngineWorld:restorePlayerActor(player)
        end
    end
	UIHelper.showToast1("^00FF00Success!")
	GUIGMControlPanel:hide()
end
--destroyAllEntityActor()
function GMHelper:BanClickCD(text)
   A = not A
    ClientHelper.putBoolPrefs("banClickCD", true)
    PlayerManager:getClientPlayer().Player:setIntProperty("bedWarAttackCD", 0)
   if A then
	text:SetBackgroundColor(Color.GREEN)
     return
   end
    ClientHelper.putBoolPrefs("banClickCD", false)
    PlayerManager:getClientPlayer().Player:setIntProperty("bedWarAttackCD", 5)
	text:SetBackgroundColor(Color.BLACK)
end

function GMHelper:ShowAllCobtrolXD()
    RootGuiLayout.Instance():showMainControl()
end

function GMHelper:PersonView()
   GMHelper:openInput({ "" }, function(Number)
        Blockman.Instance():setPersonView(Number)
        UIHelper.showToast1("^00FF00Changed")
   end)
end

function GMHelper:BreakParticles()
   GMHelper:openInput({ "" }, function(Number)
        ClientHelper.putIntPrefs("BlockDestroyEffectSize", Number)
        UIHelper.showToast1("^00FF00Changed")
   end)
end

function GMHelper:JailBreakBypass()
    RootGuiLayout.Instance():showMainControl()
	GUIGMControlPanel:hide()
end

function GMHelper:SpeedLineMode()
    local strength = 1
    local interval = 0.01
    Blockman.Instance().m_gameSettings:setPatternSpeedLine(strength, interval)
	UIHelper.showToast1("^00FF00Speed Line = Enable!")
	GUIGMControlPanel:hide()
end

function GMHelper:SpeedLineModeDisable()
    local strength = 0
    local interval = 0
    Blockman.Instance().m_gameSettings:setPatternSpeedLine(strength, interval)
	UIHelper.showToast1("^FF0000Speed Line = Disabled!")
	GUIGMControlPanel:hide()
end

function GMHelper:PatternTorchMode()
    local strength = 1
    Blockman.Instance().m_gameSettings:setPatternTorchStrength(strength)
	UIHelper.showToast1("^00FF00PatternTorch = Enabled!")
	GUIGMControlPanel:hide()
end

function GMHelper:PatternTorchModeOFF()
    local strength = 0
    Blockman.Instance().m_gameSettings:setPatternTorchStrength(strength)
	UIHelper.showToast1("^FF0000PatternTorch = Disabled!")
	GUIGMControlPanel:hide()
end

function GMHelper:CameraFlipModeRESET()
    Blockman.Instance().m_gameSettings:setFovSetting(1)
	GUIGMControlPanel:hide()
end

function GMHelper:CameraFlipModeON()
    Blockman.Instance().m_gameSettings:setFovSetting(90)
	GUIGMControlPanel:hide()
end

function GMHelper:Iikj(player)
    local pos = player:getPosition()
    pos.y = pos.y + 0.5
    local yaw = player:getYaw()
    player:teleportPosWithYaw(pos, yaw)
	GUIGMControlPanel:hide()
end

function GMHelper:GUItest1()
    MsgSender.sendMsg(10007, "IikjLol")
	MsgSender.sendMsg(10006, "IikjLol")
	MsgSender.sendMsg(10005, "IikjLol")
	MsgSender.sendMsg(10004, "IikjLol")
	MsgSender.sendMsg(10003, "IikjLol")
	MsgSender.sendMsg(10002, "IikjLol")
	MsgSender.sendMsg(10001, "IikjLol")
    MsgSender.sendMsg(10000, "IikjLol")
    MsgSender.sendMsg(1, "IikjLol")
end

function GMHelper:FustBreakBlockMode(text)
    ---设置轨道不渲染
    cBlockManager.cGetBlockById(66):setNeedRender(false)
    cBlockManager.cGetBlockById(253):setNeedRender(false)
    for blockId = 1, 40000 do
        local block = BlockManager.getBlockById(blockId)
        if block then
            block:setHardness(0)
	text:SetBackgroundColor(Color.GREEN)
    end
	    end
end

function GMHelper:FlyDev()
    GUIManager:hideWindowByName("Main.binary")
    GUIManager:hideWindowByName("Main.json")
	GUIGMControlPanel:hide()
end

function GMHelper:HideHP()
    GUIManager:getWindowByName("ClientSetting-TabList"):SetVisible(true)
end

function GMHelper:FlyDev2()
    for blockId = 1, 40000 do
        local block = BlockManager.getBlockById(blockId)
        if block then
    Blockman.Instance():setBloomEnable(true)
    Blockman.Instance():enableFullscreenBloom(true)
    Blockman.Instance():setBlockBloomOption(100)
    Blockman.Instance():setBloomIntensity(100)
    Blockman.Instance():setBloomSaturation(100)
    Blockman.Instance():setBloomThreshold(100)
	UIHelper.showToast1("^00FF00Speed Break Block = 0")
	GUIGMControlPanel:hide()
end
end
end

function GMHelper:FlyDev3()
    GUIManager:showWindowByName("PlayerInventory-DesignationTab")
	GUIManager:getWindowByName("PlayerInventory-DesignationTab"):SetVisible(true)
	GUIManager:showWindowByName("PlayerInventory-MainInventoryTab")
	GUIManager:getWindowByName("PlayerInventory-MainInventoryTab"):SetVisible(true)
	GUIManager:getWindowByName("PlayerInventory-MainInventoryTab"):SetArea({ 1, 1 }, { 1, 0 }, { 0, 1 }, { 0, 1 })
	GUIManager:getWindowByName("PlayerInventory-DesignationTab"):SetArea({ 0, 0 }, { 0, 0 }, { 0.3, 0 }, { 0.3, 0 })
    GUIManager:getWindowByName("PlayerInventory-ToggleInventoryButton"):SetVisible(true)
	GUIManager:showWindowByName("PlayerInventory-ToggleInventoryButton")
	GUIGMControlPanel:hide()
end

function GMHelper:Freecam(text)
freecam = not freecam
text:SetBackgroundColor(Color.BLACK)
GUIManager:getWindowByName("Main-HideAndSeek-Operate"):SetVisible(false)
if freecam then
    GUIManager:getWindowByName("Main-HideAndSeek-Operate"):SetVisible(true)
	text:SetBackgroundColor(Color.GREEN)
end
end

function GMHelper:TntTag()
    GUIManager:showWindowByName("Main-throwpot-Controls")
	GUIManager:getWindowByName("Main-throwpot-Controls"):SetVisible(true)
	GUIGMControlPanel:hide()
end

function GMHelper:SetBobbing()
   GMHelper:openInput({ "" }, function(Number)
        ClientHelper.putFloatPrefs("PlayerBobbingScale", Number)
        UIHelper.showToast1("^00FF00Changed")
   end)
end

function GMHelper:test200()
	MsgSender.sendMsg(Messages:gameResetTimeHint())
	GUIGMControlPanel:hide()
end



function GMHelper:test600()
	    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
        if player.Player then
            player.Player.m_isPeopleActor = false
            EngineWorld:restorePlayerActor(player)
        end
    end
 	UIHelper.showToast1("^00FF00yes")
	GUIGMControlPanel:hide()
end

function GMHelper:JustClick()
    LuaTimer:scheduleTimer(function()
        local moveDir = VectorUtil.newVector3(0.0, 30.0, 0.0)
        PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
    end, 5, 200000000000000000000000000000000000)
end

function GMHelper:JustClick2()
    LuaTimer:scheduleTimer(function()
        local moveDir = VectorUtil.newVector3(0.0, 300.0, 0.0)
        PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
    end, 5, 200000000000000000000000000000000000)
end

function GMHelper:OffChat()
	GUIManager:getWindowByName("Main-Chat-Message"):SetVisible(false)
	GUIManager:getWindowByName("Main-Chat-Message"):SetVisible(false)
end

function GMHelper:OnChat()
	GUIManager:getWindowByName("Main-Chat-Message"):SetVisible(true)
	GUIManager:getWindowByName("Main-Chat-Message"):SetVisible(true)
end

function GMHelper:Noclip(text)
   A = not A
    for blockId = 1, 40000 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end
		    end
   if A then
	text:SetBackgroundColor(Color.GREEN)
     return
   end
    for blockId = 1, 40000 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
        end
		    end
	text:SetBackgroundColor(Color.BLACK)
end

function GMHelper:NoclipOP(text)
   A = not A
    for blockId = 3, 133 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end
		    end
   if A then
	text:SetBackgroundColor(Color.GREEN)
     return
   end
    for blockId = 3, 133 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
        end
		    end
	text:SetBackgroundColor(Color.BLACK)
end


function GMHelper:NoObsidian1()
   A = not A
    for blockId = 49, 50 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end
		    end
   if A then
	UIHelper.showToast1("^00FF00Enabled")
     return
   end
    for blockId = 49, 50 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
        end
		    end
	UIHelper.showToast1("^FF0000Disabled")
end

function GMHelper:NoOakPlanks1()
   A = not A
    for blockId = 5, 6 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end
		    end
   if A then
	UIHelper.showToast1("^00FF00Enabled")
     return
   end
    for blockId = 5, 6 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
        end
		    end
	UIHelper.showToast1("^FF0000Disabled")
end

function GMHelper:NoGlass1()
   A = not A
    for blockId = 94, 95 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end
		    end
   if A then
	UIHelper.showToast1("^00FF00Enabled")
     return
   end
    for blockId = 94, 95 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
        end
		    end
	UIHelper.showToast1("^FF0000Disabled")
end

function GMHelper:NoEndStone1()
   A = not A
    for blockId = 120, 121 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end
		    end
   if A then
	UIHelper.showToast1("^00FF00Enabled")
     return
   end
    for blockId = 120, 121 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
        end
		    end
	UIHelper.showToast1("^FF0000Disabled")
end

function GMHelper:NoWool1()
   A = not A
    for blockId = 1441, 1444 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end
		    end
   if A then
	UIHelper.showToast1("^00FF00Enabled")
     return
   end
    for blockId = 1441, 1444 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
        end
		    end
	UIHelper.showToast1("^FF0000Disabled")
end

function GMHelper:NoBomb1()
   A = not A
    for blockId = 593, 594 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end
		    end
   if A then
	UIHelper.showToast1("^00FF00Enabled")
     return
   end
    for blockId = 593, 594 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
        end
		    end
	UIHelper.showToast1("^FF0000Disabled")
end

function GMHelper:NoIDoor1()
   A = not A
    for blockId = 241, 242 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end
		    end
   if A then
	UIHelper.showToast1("^00FF00Enabled")
     return
   end
    for blockId = 241, 242 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
        end
		    end
	UIHelper.showToast1("^FF0000Disabled")
end

function GMHelper:NoQuartz1()
   A = not A
    for blockId = 155, 156 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end
		    end
   if A then
	UIHelper.showToast1("^00FF00Enabled")
     return
   end
    for blockId = 155, 156 do
        local block = BlockManager.getBlockById(blockId)
        if block then
			block:setBlockBounds(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
        end
		    end
	UIHelper.showToast1("^FF0000Disabled")
end


--[[function GMHelper:test2222()
    A = not A
    LuaTimer:scheduleTimerWithEnd(function()
    PlayerManager:getClientPlayer().Player:setGlide(true)
	end, 0.2, 900000000000000000000000)
   if A then
    LuaTimer:scheduleTimerWithEnd(function()
    PlayerManager:getClientPlayer().Player:setGlide(false)
	end, 0.2, 1)
end
end]]

function GMHelper:JumpHeight()
   GMHelper:openInput({ "" }, function(Number)
    local player = PlayerManager:getClientPlayer()
    if player and player.Player then
    player.Player:setFloatProperty("JumpHeight", Number)
	UIHelper.showToast1("^00FF00Success")
end
end)
end

function GMHelper:addCurrencyCustom(player)
    GMHelper:openInput(player, { "100" }, function(currency)
        currency = tonumber(currency) or 0
        player:addCurrency(currency, "GM")
    end)
end

function GMHelper:GUIOpener()
   GMHelper:openInput({ ".json" }, function(Number)
   GUIManager:showWindowByName(Number)
   end)
end

function GMHelper:GUIViewOFF()
   GMHelper:openInput({ ".json" }, function(Number)
   GUIManager:hideWindowByName(Number)
   end)
end

function GMHelper:InsideGUI()
   GMHelper:openInput({ "", "" }, function(Number, Exe)
        GUIManager:getWindowByName(Number):SetVisible(Exe)
   end)
end

function GMHelper:ChangeNick()
   GMHelper:openInput({ "" }, function(Nick)
    PlayerManager:getClientPlayer().Player:setShowName(Nick)
    UIHelper.showToast1("^FF00EENickNameChanged")
   end)
end

function GMHelper:LongJump(text)
    glidehack = not glidehack
    if self.glide then
        LuaTimer:cancelTimer(self.glide)
        text:SetBackgroundColor(Color.BLACK)
    end
    PlayerManager:getClientPlayer().Player:setGlide(false)
    text:SetBackgroundColor(Color.GREEN)
    if glidehack then
        self.glide = LuaTimer:scheduleTimer(function()
            PlayerManager:getClientPlayer().Player:setGlide(true)
        end, 0.2, 999999)  -- Use a reasonable repeat count instead of a massive number
    end
end


function GMHelper:AdvancedUp()
   GMHelper:openInput({ "" }, function(Num)
        local moveDir = VectorUtil.newVector3(0.0, Num, 0.0)
        PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
end)
end

function GMHelper:AdvancedIn()
   GMHelper:openInput({ "" }, function(Num)
        local moveDir = VectorUtil.newVector3(Num, 0.0, 0.0)
        PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
end)
end

function GMHelper:AdvancedOn()
   GMHelper:openInput({ "" }, function(Num)
        local moveDir = VectorUtil.newVector3(0.0, 0.0, Num)
        PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
end)
end

function GMHelper:AdvancedDirect()
   GMHelper:openInput({ "", "", "" }, function(Num, Num2, Num3)
        local moveDir = VectorUtil.newVector3(Num, Num2, Num3)
        PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
end)
end

function GMHelper:tpPos()
   GMHelper:openInput({ "", "", "" }, function(Num, Num2, Num3)
   LuaTimer:scheduleTimer(function()
    local playerPos = VectorUtil.newVector3(Num, Num2, Num3)
    local moveDir = VectorUtil.newVector3(1.0, 10.0, 1.0)
    PlayerManager:getClientPlayer().Player:setPosition(playerPos)
    PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
    end, 100, 1000000)
end) 
end

function GMHelper:HideHoldItem()
   A = not A
    PlayerManager:getClientPlayer():setHideHoldItem(true)
    UIHelper.showToast1("^FF00EETrue")
	if A then
	PlayerManager:getClientPlayer():setHideHoldItem(false)
    UIHelper.showToast1("^FF00EEFalse")
end
end

function GMHelper:DevFlyI(text)
  A = not A
    local player = PlayerManager:getClientPlayer()
    player.Player:setAllowFlying(false)
    player.Player:setFlying(false)
    PlayerManager:getClientPlayer().Player:setSpeedAdditionLevel(100)
    text:SetBackgroundColor(Color.BLACK)
  if A then
    local moveDir = VectorUtil.newVector3(0.0, 1.35, 0.0)
    local player = PlayerManager:getClientPlayer()
    player.Player:setAllowFlying(true)
    player.Player:setFlying(true)
    PlayerManager:getClientPlayer().Player:setSpeedAdditionLevel(2000)
    PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
    text:SetBackgroundColor(Color.GREEN)
  end
end

function GMHelper:SharpFly(text)
    A = not A
    ClientHelper.putBoolPrefs("DisableInertialFly", true)
    text:SetBackgroundColor(Color.GREEN)
	if A then
	ClientHelper.putBoolPrefs("DisableInertialFly", false)
    text:SetBackgroundColor(Color.BLACK)
end
end

function GMHelper:WaterPush()
    A = not A
    local entity = PlayerManager:getClientPlayer().Player
    entity:setBoolProperty("ignoreWaterPush", true)
    UIHelper.showToast1("^FF00EEON")
	if A then
    entity:setBoolProperty("ignoreWaterPush", false)
    UIHelper.showToast1("^FF00EEOFF")
end
end

function GMHelper:ninja(text)
    local player = PlayerManager:getClientPlayer()
    if player and player.Player then
        if isClient then
            player.Player:setFloatProperty("JumpHeight", 0.50)
            ClientHelper.putBoolPrefs("EnableDoubleJumps", true)
            PlayerManager:getClientPlayer().doubleJumpCount = 2
            text:SetBackgroundColor(Color.GREEN)
        else
            player.Player:setFloatProperty("JumpHeight", 0.42)
            ClientHelper.putBoolPrefs("EnableDoubleJumps", false)
            PlayerManager:getClientPlayer().doubleJumpCount = 1
            text:SetBackgroundColor(Color.BLACK)
        end
    end
end

function GMHelper:changeScale()
   GMHelper:openInput({ "" }, function(Scale)
    local entity = PlayerManager:getClientPlayer().Player
    entity:setScale(Scale)
    UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:BlockOFF()
   GMHelper:openInput({ "" }, function(Numer)
   local blockId = Numer
   local block = BlockManager.getBlockById(blockId)
   block:setBlockBounds(0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  end)
end

function GMHelper:BlockON()
   GMHelper:openInput({ "" }, function(Numer)
   local blockId = Numer
   local block = BlockManager.getBlockById(blockId)
   block:setBlockBounds(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
  end)
end

function GMHelper:SpeedManager(text)
  speedhack = not speedhack
  PlayerManager:getClientPlayer().Player:setSpeedAdditionLevel(0)
  text:SetBackgroundColor(Color.BLACK)
  if speedhack then
  PlayerManager:getClientPlayer().Player:setSpeedAdditionLevel(1500)
	text:SetBackgroundColor(Color.GREEN)
  end
end

function GMHelper:SpeedUp()
    ClientHelper.putIntPrefs("SpeedAddMax", 20000000)
	UIHelper.showToast1("^FF0000[DANGER]")
end

function GMHelper:XRayManagerON()
   GMHelper:openInput({ "erase this text and write block id" }, function(Numer)
    cBlockManager.cGetBlockById(Numer):setNeedRender(false)
	UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:XRayManagerOFF()
   GMHelper:openInput({ "erase this text and write block id" }, function(Numer)
    cBlockManager.cGetBlockById(Numer):setNeedRender(true)
	UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:OFFDARK()
    ---设置轨道不渲染
    cBlockManager.cGetBlockById(66):setNeedRender(false)
    cBlockManager.cGetBlockById(253):setNeedRender(false)
    for blockId = 1, 40000 do
        local block = BlockManager.getBlockById(blockId)
        if block then
            block:setLightValue(150, 150, 150)
	UIHelper.showToast1("^00FF00Success")
	GUIGMControlPanel:hide()
    end
	    end
end

function GMHelper:SpawnNPC()
   GMHelper:openInput({ ".actor" }, function(actor)
    local pos = PlayerManager:getClientPlayer():getPosition()  
    local yaw = PlayerManager:getClientPlayer():getYaw()  
    EngineWorld:addActorNpc(pos, yaw, actor, function(entity)
end)
end)
end

function GMHelper:spawnCar()
   GMHelper:openInput({ "Car ID (erase this text and write carID)" }, function(ID)
  local pos = PlayerManager:getClientPlayer():getPosition() 
  Blockman.Instance():getWorld():addVehicle(pos, ID, 5)
	UIHelper.showToast1("^00FFEECar Spawn Success")
end)
end

function GMHelper:TeleportByUID()
   GMHelper:openInput({ "id player" }, function(ID)
  local player = PlayerManager:getClientPlayer().Player
    local Dplayer = PlayerManager:getPlayerByUserId(ID)
    if Dplayer then
        player:setPosition(Dplayer:getPosition())
    end
end)
end

function GMHelper:ChangeActorForMe()
  local entity = PlayerManager:getClientPlayer().Player
  GMHelper:openInput({ ".actor" }, function(actor)
  Blockman.Instance():getWorld():changePlayerActor(entity, actor)
  Blockman.Instance():getWorld():changePlayerActor(entity, actor)
  entity.m_isPeopleActor = false
  EngineWorld:restorePlayerActor(entity)
  UIHelper.showToast1("^00FFEESuccess")
end)
end

function GMHelper:AFKmode()
   A = not A
    PlayerManager:getClientPlayer().Player.m_rotateSpeed = 1
    UIHelper.showToast1("^FF00EEStart")
	if A then
	PlayerManager:getClientPlayer().Player.m_rotateSpeed = 0
    UIHelper.showToast1("^FF00EEStop")
end
end

function GMHelper:DevnoClip()
   A = not A
    PlayerManager:getClientPlayer().Player.noClip = true
    UIHelper.showToast1("^FF00EETurned on")
   if A then
    PlayerManager:getClientPlayer().Player.noClip = false
    UIHelper.showToast1("^FF00EETurned off")
end
end

function GMHelper:StepHeight()
   GMHelper:openInput({ "StepHeight Value" }, function(data)
    PlayerManager:getClientPlayer().Player.stepHeight = data
    UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:SpYaw()
   A = not A
    PlayerManager:getClientPlayer().Player.spYaw = true
    UIHelper.showToast1("^FF00EEON")
  if A then
    PlayerManager:getClientPlayer().Player.spYaw = false
    UIHelper.showToast1("^FF00EEOFF")    
end
end

function GMHelper:SpYawSet()
   GMHelper:openInput({ "" }, function(data)
    PlayerManager:getClientPlayer().Player.spYawRadian = data
    UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:HairSet()
   GMHelper:openInput({ "" }, function(Data)
    PlayerManager:getClientPlayer().Player.m_isEquipWing = true
    PlayerManager:getClientPlayer().Player.m_isClothesChange = true
    PlayerManager:getClientPlayer().Player.m_isClothesChanged = true
    UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:SetHideAndShowArmor()
   A = not A
   LogicSetting.Instance():setHideArmor(true)
    UIHelper.showToast1("^FF00EEON")
  if A then
   LogicSetting.Instance():setHideArmor(false)
    UIHelper.showToast1("^FF00EEOFF")
end
end

--  LogicSetting.Instance():setHideArmor(true)

    --entity.m_rotateSpeed = 0

function GMHelper:SettingLongjump(text)
   hiju = not hiju
   local player = PlayerManager:getClientPlayer()
    player.Player:setFloatProperty("JumpHeight", 0.4)
    
    text:SetBackgroundColor(Color.BLACK)
   if hiju then
   local player = PlayerManager:getClientPlayer()
    player.Player:setFloatProperty("JumpHeight", 1)
    
    text:SetBackgroundColor(Color.GREEN)
    end
end

function GMHelper:openupdateinfo()
CloseOp:SetVisible(true)
Scroll:SetVisible(true)
Title1:SetVisible(true)
Title2:SetVisible(true)
HideOp:SetVisible(true)
end

function GMHelper:SetAlpha()
     GMHelper:openInput({ "Gui name", "alpha" }, function(GUI, Number)
  GUIManager:getWindowByName(GUI):SetAlpha(Number)
  UIHelper.showToast1("^FF00EESuccess")
end)
end
--Region Clothes -- Start
function GMHelper:ChangeHair()
   GMHelper:openInput({ "number" }, function(Kelg)
  local player = PlayerManager:getClientPlayer().Player
		player.m_outLooksChanged = true
		player.m_hairID = Kelg
  	UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:ChangeFace()
   GMHelper:openInput({ "number" }, function(Kelg)
  local player = PlayerManager:getClientPlayer().Player
		player.m_outLooksChanged = true
		player.m_faceID = Kelg
  	UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:ChangeTops()
   GMHelper:openInput({ "number" }, function(Kelg)
  local player = PlayerManager:getClientPlayer().Player
		player.m_outLooksChanged = true
		player.m_topsID = Kelg
  	UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:ChangePants()
   GMHelper:openInput({ "number" }, function(Kelg)
  local player = PlayerManager:getClientPlayer().Player
		player.m_outLooksChanged = true
		player.m_pantsID = Kelg
  	UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:ChangeShoes()
   GMHelper:openInput({ "number" }, function(Kelg)
  local player = PlayerManager:getClientPlayer().Player
		player.m_outLooksChanged = true
		player.m_shoesID = Kelg
  	UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:ChangeGlasses()
   GMHelper:openInput({ "number" }, function(Kelg)
  local player = PlayerManager:getClientPlayer().Player
		player.m_outLooksChanged = true
		player.m_glassesId = Kelg
  	UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:ChangeScarf()
   GMHelper:openInput({ "number" }, function(Kelg)
  local player = PlayerManager:getClientPlayer().Player
		player.m_outLooksChanged = true
		player.m_scarfId = Kelg
  	UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:ChangeWing()
   GMHelper:openInput({ "number" }, function(Kelg)
  local player = PlayerManager:getClientPlayer().Player
		player.m_outLooksChanged = true
		player.m_wingId = Kelg
  	UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:ChangeHat()
  GMHelper:openInput({ "number" }, function(sea)
  PlayerManager:getClientPlayer().Player.m_hatId = sea
  PlayerManager:getClientPlayer().Player.m_outLooksChanged = true
  UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:ChangeDecHat()
  GMHelper:openInput({ "number" }, function(sea)
  PlayerManager:getClientPlayer().Player.m_decorate_hatId = sea
  PlayerManager:getClientPlayer().Player.m_outLooksChanged = true
  UIHelper.showToast1("^FF00EESuccess")
end)
end


function GMHelper:ChangeTail()
  GMHelper:openInput({ "number" }, function(sea)
  PlayerManager:getClientPlayer().Player.m_tailId = sea
  PlayerManager:getClientPlayer().Player.m_outLooksChanged = true
  UIHelper.showToast1("^FF00EESuccess")
end)
end


function GMHelper:ChangeBagI()
  GMHelper:openInput({ "number" }, function(sea)
  PlayerManager:getClientPlayer().Player.m_bagId = sea
  PlayerManager:getClientPlayer().Player.m_outLooksChanged = true
  UIHelper.showToast1("^FF00EESuccess")
end)
end


function GMHelper:ChangeCrown()
  GMHelper:openInput({ "" }, function(sea)
  PlayerManager:getClientPlayer().Player.m_crownId = sea
  PlayerManager:getClientPlayer().Player.m_outLooksChanged = true
  UIHelper.showToast1("^FF00EESuccess")
end)
end

function GMHelper:CreateGUIDEArrow()
  local sss = PlayerManager:getClientPlayer():getPosition() 
  PlayerManager:getClientPlayer().Player:addGuideArrow(sss)
  UIHelper.showToast1("^FF00EESuccess")
end


function GMHelper:DelAllGUIDEArrow()
  PlayerManager:getClientPlayer().Player:deleteAllGuideArrow()
  UIHelper.showToast1("^FF00EESuccess")
end





function GMHelper:SetUpBuild()
  GMHelper:openInput({ "" }, function(Savesta)
  ClientHelper.putIntPrefs("QuicklyBuildBlockNum", Savesta)
  UIHelper.showToast1("^FF00EESuccess")
end)
end


function GMHelper:EasyWay()
    local inv = PlayerManager:getClientPlayer():getInventory()
    inv:removeAllItemFromHotBar()
    UIHelper.showToast1("^FF00EESuccess")
end


function GMHelper:WatchMode()
  A = not A
  local moveDir = VectorUtil.newVector3(0.0, 1.35, 0.0)
  PlayerManager:getClientPlayer().Player:setAllowFlying(true)
  PlayerManager:getClientPlayer().Player:setFlying(true)
  PlayerManager:getClientPlayer().Player:setWatchMode(true)
  PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
  UIHelper.showToast1("^FF00EEON")
  if A then
  PlayerManager:getClientPlayer().Player:setAllowFlying(false)
  PlayerManager:getClientPlayer().Player:setFlying(false)
  PlayerManager:getClientPlayer().Player:setWatchMode(false)
  UIHelper.showToast1("^FF00EEOFF")
end
end

--End Region Clothes -- End
--Region INFO --
function GMHelper:ShowRegion()
    UIHelper.showToast1("RegionID=" .. Game:getRegionId())
end

function GMHelper:GameID()
    UIHelper.showToast1("GameID=" .. CGame.Instance():getGameType())
end

function GMHelper:LogInfo()
  local content = HostApi.getClientInfo()
  ClientHelper.onSetClipboard(content)
  UIHelper.showToast1("^FF00EESuccess")
end

function GMHelper:GetAllInfoT()
    local players = PlayerManager:getPlayers()
    for _, player in pairs(players) do
    MsgSender.sendMsg("^FF0000INFO: " .. string.format("^FF0000UserName: %s {} ID: %s {} Gender: %s", player:getName(), player.userId, player.Player:getSex()))
end
end

function GMHelper:test2300()
   GMHelper:openInput({ "" }, function(Num1)
  local player = PlayerManager:getClientPlayer().Player
    player.length = Num1
		player.isCollidedHorizontally = true
    player.isCollidedVertically = true
    player.isCollided = true
end)
end

--233-2=215
--addChatMessage
function GMHelper:test1222()
  local player = PlayerManager:getClientPlayer().Player
		player.m_canBuildBlockQuickly = true
		player.m_quicklyBuildBlock = true
  	UIHelper.showToast1("2:")
end
--x364 z240
-- REGION TEST --
function GMHelper:test2222()
  local player = PlayerManager:getClientPlayer().Player
    player.m_opacity = 0.2
  	UIHelper.showToast1("1:")
end

function GMHelper:spawnCar()
   GMHelper:openInput({ "Car ID (erase this text and write carID)" }, function(ID)
  local pos = PlayerManager:getClientPlayer():getPosition() 
  local yaw = PlayerManager:getClientPlayer():getYaw() 
  Blockman.Instance():getWorld():addVehicle(pos, ID, yaw)
	UIHelper.showToast1("^FF00EECar Spawn Success")
end)
end

function GMHelper:SpawnItem()
       GMHelper:openInput({ "ID", "Count" }, function(Id, Count)
  local position = PlayerManager:getClientPlayer():getPosition() 
  EngineWorld:addEntityItem(Id, Count, 0, 600, position, VectorUtil.ZERO)
end)
end

--1.1



function GMHelper:BlinkOP(text)
   tse = not tse
      ClientHelper.putBoolPrefs("SyncClientPositionToServer", true)
      text:SetBackgroundColor(Color.BLACK)
   if tse then 
      ClientHelper.putBoolPrefs("SyncClientPositionToServer", false)
      text:SetBackgroundColor(Color.GREEN)
   end
end

function GMHelper:NoFall() -- NoFall
A = not A
ClientHelper.putIntPrefs("SprintLimitCheck", 7)
if A then
UIHelper.showToast1("Enabled")
return
end
ClientHelper.putIntPrefs("SprintLimitCheck", 0)
UIHelper.showToast1("Disabled")
end

function GMHelper:NoFallSet()
   GMHelper:openInput({ "TypeValue" }, function(Number)
        ClientHelper.putIntPrefs("SprintLimitCheck", Number)
        UIHelper.showToast1("Done, now it will have like a protection")
   end)
end

function GMHelper:MineReset()
local playerPos = VectorUtil.newVector3(536, 2.78, -136)
local moveDir = VectorUtil.newVector3(0.0, 0.0, 0.0)
PlayerManager:getClientPlayer().Player:setPosition(playerPos)
PlayerManager:getClientPlayer().Player:moveEntity(moveDir)
end

function GMHelper:quickblock()
  GMHelper:openInput({ "" }, function(Number)
  ClientHelper.putIntPrefs("QuicklyBuildBlockNum",Number)
	UIHelper.showToast1("^FF00EESuccess")
	GUIGMControlPanel:hide()
  end)
end

function GMHelper:startParachute(text)
  aim = not aim
     text:SetBackgroundColor(Color.BLACK)
   if aim then
     PlayerManager:getClientPlayer().Player:startParachute()
     text:SetBackgroundColor(Color.GREEN)
   end
end

function GMHelper:FlyParachute()
local moveDir = VectorUtil.newVector3(0.0, 1.35, 0.0)
    local player = PlayerManager:getClientPlayer()
    player.Player:setAllowFlying(true)
    player.Player:setFlying(true)
    player.Player:moveEntity(moveDir)
     PlayerManager:getClientPlayer().Player:startParachute()
    text:SetBackgroundColor(Color.GREEN)
    end

function GMHelper:SetBlockToAir()
       GMHelper:openInput({ "block Position X", "block Position Y", "block Position Z" }, function(X, Y, Z)
        local blockPos = VectorUtil.newVector3(X, Y, Z)
    EngineWorld:setBlockToAir(blockPos)
end)
end

function GMHelper:SpawnBlock()
       GMHelper:openInput({ "" }, function(martin)
    local blockPos = PlayerManager:getClientPlayer():getPosition() 
    EngineWorld:setBlock(blockPos, martin)
end)
end

--1.2
function GMHelper:ChangeBlockTextures(texturePath)
    local isChange = GMHelper.blockTextures or false
    if not isChange then
        Blockman.Instance():changeBlockTextures("./package_02_32.zip")
        GMHelper.blockTextures = true
    else
        Blockman.Instance():changeBlockTextures("")
        GMHelper.blockTextures = false
    end
    if #texturePath > 0 then
        Blockman.Instance():changeBlockTextures("Media/Textures/package/" .. texturePath)
    else
        Blockman.Instance():changeBlockTextures("")
    end
    GUIGMControlPanel:hide()
end

function GMHelper:updateBedWarArrowSpeed()
    GMHelper:openInput({ "speed" }, function(data)
        local scale = tonumber(data) or 0

        PlayerManager:getClientPlayer().Player:setFloatProperty("ArrowSpeedScale", scale)

        PlayerManager:getClientPlayer():sendPacket({
            pid = "updateBedWarArrowSpeed",
            scale = scale,
        })
    end)
end

function GMHelper:Rvanka()
    LuaTimer:scheduleTimer(function()
             local player = PlayerManager:getClientPlayer().Player
             local entity = PlayerManager:getPlayers()       
             for _, entity in pairs(entity) do
                 if entity ~= player then
                 
                     LuaTimer:scheduleTimer(function()
                         local position = VectorUtil.newVector3(entity:getPosition().x, entity:getPosition().y + (tonumber(tostring(787-777),2)), entity:getPosition().z)
                         player:setPosition(position)
                     end, (tonumber(tostring(1787-777),2)), (tonumber(tostring(1111101777-777),2)))
                 end
             end
         end, (tonumber(tostring(1111101778-777),2)), -(tonumber(tostring(778-777),2)))
 end 

function GMHelper:Tracer(text)
   tracer = not tracer
   text:SetBackgroundColor(Color.BLACK)
   LuaTimer:cancelTimer(self.tracer)
   if tracer then
    local player = PlayerManager:getClientPlayer()
    self.tracer = LuaTimer:scheduleTimer(function()
        PlayerManager:getClientPlayer().Player:deleteAllGuideArrow()
        local entity = PlayerManager:getPlayers()
        for _, c_player in pairs(entity) do
            if c_player ~= player then
                PlayerManager:getClientPlayer().Player:addGuideArrow(c_player:getPosition())
            end
        end
    end, (tonumber(tostring(111110877-_G["dumb"]),2)), -(tonumber(tostring(778-_G["dumb"]),2)))
    text:SetBackgroundColor(Color.GREEN)
    end
end

function GMHelper:Scaffold(text)
--helped tarelka089s
    A = not A
    LuaTimer:cancel(self.timer)
    text:SetBackgroundColor(Color.BLACK)
    if A then
    GMHelper:openInput({"BlockID"}, function(block)
    self.timer = LuaTimer:scheduleTimer(function()
    local pos = PlayerManager:getClientPlayer():getPosition() 
    EngineWorld:setBlock(VectorUtil.newVector3(pos.x, pos.y - 2, pos.z), block)
    EngineWorld:setBlock(VectorUtil.newVector3(pos.x - 1, pos.y - 2, pos.z - 1), block)
    EngineWorld:setBlock(VectorUtil.newVector3(pos.x + 1, pos.y - 2, pos.z + 1), block)
    EngineWorld:setBlock(VectorUtil.newVector3(pos.x, pos.y - 2, pos.z + 1), block)
    EngineWorld:setBlock(VectorUtil.newVector3(pos.x, pos.y - 2, pos.z - 1), block)
    EngineWorld:setBlock(VectorUtil.newVector3(pos.x + 1, pos.y - 2, pos.z), block)
    EngineWorld:setBlock(VectorUtil.newVector3(pos.x - 1, pos.y - 2, pos.z), block)
    EngineWorld:setBlock(VectorUtil.newVector3(pos.x - 1, pos.y - 2, pos.z + 1), block)
    EngineWorld:setBlock(VectorUtil.newVector3(pos.x + 1, pos.y - 2, pos.z - 1), block)
    end, 0.15, -1)
    text:SetBackgroundColor(Color.GREEN)
    end)
    end
    end

function GMHelper:eze()
    if K0000 then
        local nearestPlayer = nil
        local players = PlayerManager:getPlayers()
        local player = PlayerManager:getClientPlayer()
        local minDis = math.huge

        for _, c_player in pairs(players) do
            local distance = MathUtil:distanceSquare3d(c_player:getPosition(), player:getPosition())
            if distance < 42 and c_player ~= player then
                if distance < minDis then
                    minDis = distance
                    nearestPlayer = c_player
                end
            end
        end

        if nearestPlayer and nearestPlayer.Player:isEntityAlive() then
            UIHelper.showToast1("^00FFFFName : " .. nearestPlayer.Player:getEntityName() .. "  •  " .. "Health : " .. nearestPlayer.Player:getHealth())
        end
    end
end



function GMHelper:PingXD()
    local GUI = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-Ping")
    GUI:SetVisible(true)

    local hue = 0
    local function Update()
        local fps = Root.Instance():getFPS()
        local ping = ClientNetwork.Instance():getRaknetPing()
        local YE = "Fps: " .. fps .. " Ping: " .. ping

        GUI:SetText(YE)

        local function interpolateColor(hue)
            local r, g, b, a = 0, 0, 0, 0
            if hue < 60 then
                r, g, b, a = 1, hue / 60, 0, 1 - (hue / 60)
            elseif hue < 120 then
                r, g, b, a = (120 - hue) / 60, 1, 0, (hue - 60) / 60
            elseif hue < 180 then
                r, g, b, a = 0, 1, (hue - 120) / 60, 1 - ((hue - 120) / 60)
            elseif hue < 240 then
                r, g, b, a = 0, (240 - hue) / 60, 1, (hue - 180) / 60
            elseif hue < 300 then
                r, g, b, a = (hue - 240) / 60, 0, 1, 1 - ((hue - 240) / 60)
            else
                r, g, b, a = 1, 0, (360 - hue) / 60, (hue - 300) / 60
            end
            return r, g, b, a
        end

        hue = (hue + 0.5) % 360
        local r, g, b, a = interpolateColor(hue)
        GUI:SetTextColor({ r, g, b, 0.6 })
    end

    GUI:SetWidth({ 0, 200 })
    GUI:SetHeight({ 0, 20 })
    GUI:SetBordered(true)
    GUI:SetXPosition({ 0, 15 })
    GUI:SetYPosition({ 0, 680 })
    GUISystem.Instance():GetRootWindow():AddChildWindow(GUI)

    LuaTimer:scheduleTimer(Update, 100, -1)
end




function GMHelper:TimeEe()
    local timer = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-Timer")
    timer:SetVisible(true)
    timer:SetText(currentDate)
    timer:SetWidth({ 0, 150 })
    timer:SetHeight({ 0, 20 })
    timer:SetBordered(true)
    timer:SetTouchable(false)
    timer:SetXPosition({ 0, 1400 })
    timer:SetYPosition({ 0, 680 })
    GUISystem.Instance():GetRootWindow():AddChildWindow(timer)

    local hue = 0

    local function interpolateColor(hue)
        local r, g, b, a = 0, 0, 0, 0
        if hue < 60 then
            r, g, b, a = 1, hue / 60, 0, 1 - (hue / 60)
        elseif hue < 120 then
            r, g, b, a = (120 - hue) / 60, 1, 0, (hue - 60) / 60
        elseif hue < 180 then
            r, g, b, a = 0, 1, (hue - 120) / 60, 1 - ((hue - 120) / 60)
        elseif hue < 240 then
            r, g, b, a = 0, 1, (hue - 180) / 60, (hue - 180) / 60
        elseif hue < 300 then
            r, g, b, a = (hue - 240) / 60, 0, 1, 1 - ((hue - 240) / 60)
        else
            r, g, b, a = 1, 0, (360 - hue) / 60, (hue - 300) / 60
        end
        return r, g, b, a
    end

    local function UpdateDate()
        local time = os.time()
        local formattedTime = os.date("%I:%M %p", time)
        currentDate = formattedTime
        timer:SetText(currentDate)

        hue = (hue + 0.5) % 360
        local r, g, b, a = interpolateColor(hue)
        timer:SetTextColor({ r, g, b, 0.6 })
    end

    LuaTimer:scheduleTimer(UpdateDate, 100, -1)
end



function GMHelper:Players()
    local Players = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-Players")
    Players:SetVisible(true)
    Players:SetBordered(true)
    Players:SetTouchable(false)
    local playersCount = 0
    for _, player in pairs(PlayerManager:getPlayers()) do
        if player ~= PlayerManager:getClientPlayer() then
            playersCount = playersCount + 1
        end
    end
    Players:SetText("Players: ".. playersCount)
    Players:SetWidth({ 0, 150 })
    Players:SetHeight({ 0, 20 })
    Players:SetXPosition({ 0, 1400 })
    Players:SetYPosition({ 0, 640 })
    GUISystem.Instance():GetRootWindow():AddChildWindow(Players)

    local function UpdatePlayers()
        local playersCount = 0
        for _, player in pairs(PlayerManager:getPlayers()) do
            if player ~= PlayerManager:getClientPlayer() then
                playersCount = playersCount + 1
            end
        end
        Players:SetText("Players: ".. playersCount)

        hue = (hue + 0.5) % 360
        local r, g, b, a = interpolateColor(hue)
        Players:SetTextColor({ r, g, b, 0.6 })
    end

    LuaTimer:scheduleTimer(UpdatePlayers, 100, -1)
end

local hue = 0

local function interpolateColor(hue)
            local r, g, b, a = 0, 0, 0, 0
            if hue < 60 then
                r, g, b, a = 1, hue / 60, 0, 1 - (hue / 60)
            elseif hue < 120 then
                r, g, b, a = (120 - hue) / 60, 1, 0, (hue - 60) / 60
            elseif hue < 180 then
                r, g, b, a = 0, 1, (hue - 120) / 60, 1 - ((hue - 120) / 60)
            elseif hue < 240 then
                r, g, b, a = 0, (240 - hue) / 60, 1, (hue - 180) / 60
            elseif hue < 300 then
                r, g, b, a = (hue - 240) / 60, 0, 1, 1 - ((hue - 240) / 60)
            else
                r, g, b, a = 1, 0, (360 - hue) / 60, (hue - 300) / 60
            end
            return r, g, b, a
        end

function GMHelper:Credits()
    local CenterToastg60 = GUIManager:createGUIWindow(GUIType.StaticText, "GUIRoot-xuy60")
    CenterToastg60:SetHorizontalAlignment(HorizontalAlignment.Center)
    CenterToastg60:SetVerticalAlignment(VerticalAlignment.Center)
    CenterToastg60:SetTextHorzAlign(HorizontalAlignment.Center)
    CenterToastg60:SetTextVertAlign(VerticalAlignment.Center)
    CenterToastg60:SetHeight({ 0, 50 })
    CenterToastg60:SetWidth({ 0, 700 })
    CenterToastg60:SetLevel(2)
    CenterToastg60:SetBordered(true)
    
    GUISystem.Instance():GetRootWindow():AddChildWindow(CenterToastg60)
    
    local appVer = json.decode(HostApi.getClientInfo()).app_version
    CenterToastg60:SetText("Credits: IamNotKoper & EternalHacker [" .. appVer .. "] [Release 1.7.2]")
    CenterToastg60:SetBackgroundColor({0, 0, 0, 0})
    CenterToastg60:SetYPosition({ -0.5, 125 })
    CenterToastg60:SetXPosition({ 0, 0 })
    
    CenterToastg60:SetVisible(true)
    
    local function rgbUpdatev1()
        hue = (hue + 0.5) % 360
        local r, g, b, a = interpolateColor(hue)
        CenterToastg60:SetTextColor({r, g, b, 0.6})
    end
    
    LuaTimer:scheduleTimer(rgbUpdatev1, 100, -1)
end
