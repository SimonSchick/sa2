local PLUGIN = Plugin("Credits", {"Topbar"})

local tostring = tostring
local function _addCommasToStr(str)
	return str:reverse():gsub("(...)", "%1,"):reverse()
end

local function _addCommasToInt(num)
	return tostring(num):reverse():gsub("(...)", "%1,"):reverse()
end

function PLUGIN:OnEnable()
	local PANEL = {}
	function PANEL:GetText()
		local lp = LocalPlayer()
		if lp ~= NULL then
			return "Credits: ".._addCommasToInt(lp.__SACredits)
		else
			return "LOADING"
		end
	end
	vgui.Register("DSATopbarCredits", PANEL, "DSATopbarTextMember")
	
	local PANEL = {}
	function PANEL:GetText()
		local lp = LocalPlayer()
		if lp ~= NULL then
			return "Score: ".._addCommasToInt(lp.__SAScore)
		else
			return "LOADING"
		end
	end
	vgui.Register("DSATopbarScore", PANEL, "DSATopbarTextMember")


	self._creditsPanel = vgui.Create("DSATopbarCredits")
	self._scorePanel = vgui.Create("DSATopbarScore")
	
	SA.Plugins.Topbar:AddPanel(20, self._creditsPanel)
	SA.Plugins.Topbar:AddPanel(20, self._scorePanel)
	
	net.Receive("SACreditsUpdate", function()
		LocalPlayer().__SACredits = net.ReadDouble()
	end)
	
	net.Receive("SAScoreUpdate", function()
		net.ReadEntity().__SAScore = net.ReadDouble()
	end)
	
	local plyMeta = _R.Player

	function plyMeta:SAGetScore()
		return self.__SAScore
	end

	function plyMeta:SAHasCredits(num)
		return self.__SACredits >= num
	end
end

function PLUGIN:OnDisable()
	net.Receive("SACreditsUpdate", nil)
	
	SA.Plugins.Topbar:RemovePanel(self._creditsPanel)
	SA.Plugins.Topbar:RemovePanel(self._scorePanel)
end

SA:RegisterPlugin(PLUGIN)