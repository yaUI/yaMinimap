local addon, ns = ...
local E, M = unpack(vCore)
local cfg = CreateFrame("Frame")
--------------

cfg.showInfo = false		-- enable disable fps/latency
cfg.showClock = false			-- ONLY show clock
cfg.watchFrame = false		-- Control the Watchframe
cfg.AddonNumb = 30			-- maximum number of addons shown in tooltip (will always show set number of top memory usage addons)
cfg.scale = 1

cfg.texture = "Interface\\Buttons\\WHITE8x8"
cfg.barTexture = M:Fetch("vui", "statusbar")
cfg.dropTexture = M:Fetch("vui", "backdrop")
cfg.dropEdgeTexture = M:Fetch("vui", "backdropEdge")

cfg.font = M:Fetch("font", "Roboto")
cfg.fontSize = M:Fetch("font", "size")
cfg.fontFlag = M:Fetch("font", "outline")

cfg.mailIco = M:Fetch("vui", "mail")

-- minimap default position - you can move it ingame by holding down ALT!
cfg.pos = "TOPRIGHT"
cfg.x = -30
cfg.y = -15
cfg.orderhallY = -40

-- Watchframe stuff
cfg.qparent = UIParent         
cfg.qanchor = "TOPRIGHT"  	 
cfg.qx = -60           
cfg.qy = -260         
cfg.qheight = 450             

--------------
ns.cfg = cfg