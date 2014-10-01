local PLUGIN = Plugin("Sysstats", {
	"Playerdata"
})

util.AddNetworkString("SASysStats")
function PLUGIN:OnEnable()
	hook.Add("PlayerInitialSpawn", "SAPlayerSysStats", function(ply)
		ply.__SASysStats = {}
	end)
	
	local ref
	local width, height
	net.Receive("SASysStats", function(len, ply)
		if(len ~= 36) then
			SA:Error(
				"Received malformed SysStat packet from player with PID:'%u' expected 36, got %u bits",
				ply.__SAPID,
				len
			)
			return
		end
		ref = ply.__SASysStats
		ref.hasWindows = net.ReadUInt(1) == 1
		ref.hasOSX = net.ReadUInt(1) == 1
		ref.hasLinux = net.ReadUInt(1) == 1
		ref.hasNotebook = net.ReadUInt(1) == 1
		width = net.ReadUInt(16)
		height = net.ReadUInt(16)
		if(width > 3840 or height > 2160) then
			self:Error(
				"Ignoring unreasonable screen resolution from ply with PID:'%u' (%ux%u)",
				ply.__SAPID,
				width,
				height
			)
			ref.screenWidth = 0
			ref.screenHeight = 0
			return
		end
		ref.screenWidth = width
		ref.screenHeight = height
	end)
	SA.Plugins.Playerdata:RegisterCallback("haswindows", nil, function(ply)
		return tostring(ply.__SASysStats.hasWindows and 1 or 0)
	end)
	
	SA.Plugins.Playerdata:RegisterCallback("hasosx", nil, function(ply)
		return tostring(ply.__SASysStats.hasOSX and 1 or 0)
	end)
	
	SA.Plugins.Playerdata:RegisterCallback("haslinux", nil, function(ply)
		return tostring(ply.__SASysStats.hasLinux and 1 or 0)
	end)
	
	SA.Plugins.Playerdata:RegisterCallback("hasnotebook", nil, function(ply)
		return tostring(ply.__SASysStats.hasNotebook and 1 or 0)
	end)
	
	SA.Plugins.Playerdata:RegisterCallback("screenwidth", nil, function(ply)
		return tostring(ply.__SASysStats.screenWidth)
	end)
	
	SA.Plugins.Playerdata:RegisterCallback("screenheight", nil, function(ply)
		return tostring(ply.__SASysStats.screenHeight)
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SASysStats", nil)

	SA.Plugins.Playerdata:RemoveCallback("haswindows")
	SA.Plugins.Playerdata:RemoveCallback("hasosx")
	SA.Plugins.Playerdata:RemoveCallback("haslinux")
	SA.Plugins.Playerdata:RemoveCallback("hasnotebook")
	SA.Plugins.Playerdata:RemoveCallback("screenwidth")
	SA.Plugins.Playerdata:RemoveCallback("screenheight")
end

SA:RegisterPlugin(PLUGIN)