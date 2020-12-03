local addon, ns = ...
local E, M = unpack(yaCore);
local cfg = ns.cfg
--------------

Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", cfg.x, cfg.y)
Minimap:SetSize(150, 150)
Minimap:SetQuestBlobRingScalar(0) --Remove the hideous circular texture during objective areas

local dummy = function() end
local _G = getfenv(0)

function CheckPosition(f)
	if OrderHallCommandBar == nil then return end

	if OrderHallCommandBar:IsShown() then
		Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", cfg.x, cfg.orderhallY)
		MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, cfg.orderhallY)
	else
		Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", cfg.x, cfg.y)
		MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, cfg.y)
	end
end


E:Wait(1, CheckPosition)

function CreateInnerBorder(f)
	if f.iborder then return end
	f.iborder = CreateFrame("Frame", nil, f, "BackdropTemplate")
	f.iborder:SetPoint("TOPLEFT", 1, -1)
	f.iborder:SetPoint("BOTTOMRIGHT", -1, 1)
	f.iborder:SetFrameLevel(f:GetFrameLevel())
	f.iborder:SetBackdrop({
	  edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1,
	  insets = { left = -1, right = -1, top = -1, bottom = -1}
	})
	f.iborder:SetBackdropBorderColor(0, 0, 0)
	return f.iborder
end

function frame1px(f)
	Mixin(f, BackdropTemplateMixin)
	f:SetBackdrop({
		bgFile =  [=[Interface\ChatFrame\ChatFrameBackground]=],
        edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, 
		insets = {left = -1, right = -1, top = -1, bottom = -1} 
	})
	f:SetBackdropColor(.06,.06,.06,1)
	f:SetBackdropBorderColor(.15,.15,.15,1)
	CreateInnerBorder(f)	
end

MinimapCluster:EnableMouse(false)

-- Hide world map button
MiniMapWorldMapButton:Hide()

-- Hide Border
MinimapBorder:Hide()
MinimapBorderTop:Hide()

-- Hide Zoom Buttons
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()

-- Hide North texture at top
MinimapNorthTag:SetTexture(nil)

-- Hide Zone Frame
MinimapZoneTextButton:Hide()

-- Hide Calendar Button
GameTimeFrame:Hide()
MinimapCluster:EnableMouse(false)

--Garrison Button
GarrisonLandingPageMinimapButton:ClearAllPoints()
GarrisonLandingPageMinimapButton:SetPoint("TOPLEFT", MinimapBackdrop, -15, -5)
GarrisonLandingPageMinimapButton:SetSize(40, 40)

--Tracking
MiniMapTrackingBackground:SetAlpha(0)
MiniMapTrackingButton:SetAlpha(0)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("BOTTOMRIGHT", Minimap, 0, 0)
MiniMapTracking:SetScale(.9)

-- Queue Button and Tooltip
QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("BOTTOMLEFT", 0, 0)
QueueStatusMinimapButtonBorder:Hide()
E:Strip(QueueStatusFrame)
E:CreateBackdrop(QueueStatusFrame)

-- Mail icon
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("TOPLEFT", Minimap, 0, 0)
MiniMapMailFrame:SetFrameStrata("LOW")
MiniMapMailIcon:SetTexture(cfg.mailIco)
MiniMapMailBorder:Hide()

---Hide Instance Difficulty flag
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:Hide()

-- Enable mouse scrolling
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end)

----------------------------------------------------------------------------------------
-- Right click menu
----------------------------------------------------------------------------------------
local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
    {text = SLASH_CALENDAR1:gsub("/(.*)","%1"):gsub("^%l", string.upper), 
    func = function()
    if(not CalendarFrame) then LoadAddOn("Blizzard_Calendar") end
        Calendar_Toggle()
    end},
    {text = CHARACTER_BUTTON,
    func = function() ToggleCharacter("PaperDollFrame") end},
    {text = SPELLBOOK_ABILITIES_BUTTON,
    func = function() ToggleFrame(SpellBookFrame) end},
    {text = TALENTS_BUTTON,
    func = function() ToggleTalentFrame() end},
    {text = ACHIEVEMENT_BUTTON,
    func = function() ToggleAchievementFrame() end},
    {text = QUESTLOG_BUTTON,
    func = function() ToggleFrame(QuestLogFrame) end},
    {text = SOCIAL_BUTTON,
    func = function() ToggleFriendsFrame(1) end},
    {text = PLAYER_V_PLAYER,
    func = function() ToggleFrame(PVPFrame) end},
    {text = LFG_TITLE,
    func = function() ToggleFrame(LFDParentFrame) end},
    {text = L_LFRAID,
    func = function() ToggleFrame(LFRParentFrame) end},
    {text = HELP_BUTTON,
    func = function() ToggleHelpFrame() end},
}

Minimap:SetScript("OnMouseUp", function(self, btn)
	if btn == "RightButton" then
		EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
	
	else
		Minimap_OnClick(self)
	end
end)

-- Set Square Map Mask
Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')

function GetMinimapShape() return 'SQUARE' end

if cfg.showInfo then
	local FLMframe = CreateFrame("Button", "FLMframe", UIParent, "BackdropTemplate")
	FLMframe:SetPoint("TOP", Minimap, "BOTTOM", 0, 172)
	FLMframe:SetSize(Minimap:GetWidth(), cfg.fontSize+6)
	FLMframe:SetFrameLevel(4)
	CreateShadow(FLMframe)

	local text = FLMframe:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER", FLMframe, 4, -2)
	text:SetFont(cfg.font, cfg.fontSize, cfg.fontFlag)
	text:SetTextColor(E.Color.r, E.Color.g, E.Color.b)

	local function Addoncompare(a, b)
		return a.memory > b.memory
	end

	local function MemFormat(v)
		if (v > 1024) then
			return string.format("%.2f MiB", v / 1024)
		else
			return string.format("%.2f KiB", v)
		end
	end
	local function MemFormatColor(v)
		if (v > 1024) then
			return string.format("%.2f|r |cffE08585M|riB", v / 1024)
		else
			return string.format("%.2f|r |cffB3E085K|riB", v)
		end
	end

	local function ColorGradient(perc, ...)
		if (perc > 1) then
			local r, g, b = select(select('#', ...) - 2, ...)
			return r, g, b
		elseif (perc < 0) then
			local r, g, b = ...
			return r, g, b
		end
		
		local num = select('#', ...) / 3

		local segment, relperc = math.modf(perc*(num-1))
		local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

		return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
	end

	local function TimeFormat(time)
		local t = format("%.1ds",floor(mod(time,60)))
		if (time > 60) then
			time = floor(time / 60)
			t = format("%.1dm ",mod(time,60))..t
			if (time > 60) then
				time = floor(time / 60)
				t = format("%.1dh ",mod(time,24))..t
				if (time > 24) then
					time = floor(time / 24)
					t = format("%dd ",time)..t
				end
			end
		end
		return t
	end

	local function ColorizeLatency(v)
		if (v < 100) then
			return {r = 0, g = 1, b = 0}
		elseif (v < 300) then
			return {r = 1, g = 1, b = 0}
		else
			return {r = 1, g = 0, b = 0}
		end
	end

	local function ColorizeFramerate(v)
		if (v < 10) then
			return {r = 1, g = 0, b = 0}
		elseif (v < 30) then
			return {r = 1, g = 1, b = 0}
		else
			return {r = 0, g = 1, b = 0}
		end
	end
		
		--========[ update ]========--

	local lastUpdate = 0
	local updateDelay = 1
	
	FLMframe:SetScript("OnEnter", function()
		GameTooltip:SetOwner(FLMframe)
		collectgarbage()
		local memory, i, addons, total, entry, total
		local latencycolor = ColorizeLatency(select(3, GetNetStats()))
		local fpscolor = ColorizeFramerate(GetFramerate())
			
		GameTooltip:AddLine(date("%A, %d %B, %Y"), 1, 1, 1)
		GameTooltip:AddDoubleLine("Framerate:", format("%.1f fps", GetFramerate()), E.Color.r, E.Color.g, E.Color.b, fpscolor.r, fpscolor.g, fpscolor.b)
		GameTooltip:AddDoubleLine("Latency:", format("%d ms", select(3, GetNetStats())), E.Color.r, E.Color.g, E.Color.b, latencycolor.r, latencycolor.g, latencycolor.b)
		GameTooltip:AddDoubleLine("System Uptime:", TimeFormat(GetTime()), E.Color.r, E.Color.g, E.Color.b, 1, 1, 1)
		GameTooltip:AddDoubleLine(". . . . . . . . . . .", ". . . . . . . . . . .", 1, 1, 1, 1, 1, 1)
		
		addons = {}
		total = 0
		UpdateAddOnMemoryUsage()
		for i = 1, GetNumAddOns(), 1 do
			if GetAddOnMemoryUsage(i) > 0 then
				memory = GetAddOnMemoryUsage(i)
				entry = {name = GetAddOnInfo(i), memory = memory}
				table.insert(addons, entry)
				total = total + memory
			end
		end
		
		table.sort(addons, Addoncompare)

		i = 0
		for _,entry in pairs(addons) do
			local cr, cg, cb = ColorGradient((entry.memory / 800), 0, 1, 0, 1, 1, 0, 1, 0, 0)
			GameTooltip:AddDoubleLine(entry.name, MemFormat(entry.memory), 1, 1, 1, cr, cg, cb)
		
			i = i + 1
			if i >= 30 then
				break
			end		
		end
		
		local cr, cg, cb = ColorGradient((entry.memory / 800), 0, 1, 0, 1, 1, 0, 1, 0, 0) 
		GameTooltip:AddDoubleLine(". . . . . . . . . . .", ". . . . . . . . . . .", 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine("Total", MemFormat(total), E.Color.r, E.Color.g, E.Color.b, cr, cg, cb)
		GameTooltip:AddDoubleLine("..with Blizzard", MemFormat(collectgarbage("count")), E.Color.r, E.Color.g, E.Color.b, cr, cg, cb)
		GameTooltip:Show()
	end)

	FLMframe:SetScript("OnLeave", function() 
		GameTooltip:Hide() 
	end)

		--========[ mem cleanup ]========--
	FLMframe:SetScript("OnClick", function()
		if (not IsAltKeyDown()) then
			UpdateAddOnMemoryUsage()
			local memBefore = gcinfo()
			collectgarbage()
			UpdateAddOnMemoryUsage()
			local memAfter = gcinfo()
			spam("Memory cleaned: |cff00FF00"..MemFormat(memBefore - memAfter))
		end
	end)
	
	FLMframe:SetScript("OnUpdate", function(self, elapsed)
		lastUpdate = lastUpdate + elapsed
		if (lastUpdate > updateDelay) then
			lastUpdate = 0
			
			local addons, memory, total, entry
			addons = {}
			total = 0
			UpdateAddOnMemoryUsage()
			for i = 1, GetNumAddOns(), 1 do
				if GetAddOnMemoryUsage(i) > 0 then
					memory = GetAddOnMemoryUsage(i)
					entry = {name = GetAddOnInfo(i), memory = memory}
					table.insert(addons, entry)
					total = total + memory
				end
			end
			
			fps = GetFramerate()
			fps = "|c00ffffff"..floor(fps+0.5).."|r fps   "
			lag = select(3, GetNetStats())
			lag = "|c00ffffff"..lag.."|r ms   "
			mem = "|c00ffffff"..MemFormatColor(total)
			text:SetText(lag..fps..mem)
		end
	end)
end

frame1px(Minimap)
--Backdrop
E:CreateBackdrop(Minimap)

if cfg.watchFrame then
	WatchFrame:ClearAllPoints()	
	WatchFrame.ClearAllPoints = function() end
	WatchFrame:SetPoint(cfg.qanchor, cfg.qparent, cfg.qanchor, cfg.qx, cfg.qy)
	WatchFrame.SetPoint = function() end
	WatchFrame:SetClampedToScreen(true)
	WatchFrame:SetHeight(cfg.qheight)
end

--[[ Clock ]]
if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end

local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
clockFrame:Hide()
if cfg.showClock then
	clockTime:SetFont(M:Fetch("font", "SansNarrow"), 10, "THINOUTLINE")
	clockTime:SetTextColor(1,1,1)
	TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 1)
	clockTime:Show()
end