local PLUGIN = Plugin("Playtime", {"Topbar"})

function PLUGIN:GetPlaytimeString(ply)
	local t = ply:SAGetPlayTime()
	return string.format(
		"%02d:%02d:%02d",
		math.floor(t/3600),
		math.floor(t/60) % 60,
		t % 60
	)
end

function PLUGIN:OnEnable()
	local PANEL = {}
	function PANEL:GetText()
		local lp = LocalPlayer()
		if lp ~= NULL then
			local time = lp:SAGetPlayTime()
			return string.format(
				"Playtime: %02d:%02d:%02d",
				math.floor(time/3600),
				math.floor(time/60) % 60,
				time % 60
			)
		else
			return "LOADING"
		end
	end
	vgui.Register("DSATopbarPlayTime", PANEL, "DSATopbarTextMember")

	self._playTimePanel = vgui.Create("DSATopbarPlayTime")
	
	SA.Plugins.Topbar:AddPanel(21, self._playTimePanel)

	net.Receive("SAPlayTime", function()
		net.ReadEntity().__SAPlayTime = net.ReadUInt(32)
		self._lastUpdate = os.time()
	end)
	
	net.Receive("SAPlayTimeUpdate", function()
		for i = 1, net.ReadUInt(8) do
			net.ReadEntity().__SAPlayTime = net.ReadUInt(32)
		end
	end)
	
	
	function _R.Player:SAGetPlayTime()
		if(not self.__SAPlayTime) then
			return 0
		end
		return self.__SAPlayTime + (os.time() - PLUGIN._lastUpdate)
	end
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)