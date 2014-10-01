local PLUGIN = Plugin("Helpmenu", {})

function PLUGIN:OnEnable()
	include(SA.Folder:sub(11).."/gamemode/plugins/client/_helpmenu/DSAHelpMenu.lua")
	self._helpPanel = vgui.Create("DSAHelpMenu")
	self._helpPanel:SetSize(ScrW()*0.6, ScrH()*0.6)
	self._helpPanel:CenterVertical()
	self._helpPanel.x = ScrW()
	self._helpPanel:SetVisible(false)
	net.Receive("SAHelpMenu", function()
		self._helpPanel:Show()
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAHelpMenu", nil)
	self._helpPanel:Remove()
end

SA:RegisterPlugin(PLUGIN)