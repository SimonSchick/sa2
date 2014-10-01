local PLUGIN = Plugin("Terminal", {"Playerdata"})

function PLUGIN:OpenMenu(term)
	self._panel:Show()
end

function PLUGIN:CloseMenu(term)
	self._panel:Hide()
end

function PLUGIN:PlayerClosedMenu()
	net.Start("SATerminalClose")
	net.SendToServer()
end

function PLUGIN:OnEnable()
	local dir = SA.Folder:sub(11).."/gamemode/plugins/client/_terminal/"
	include(dir.."DSATerminalMenu.lua")
	
	self._panel = vgui.Create("DSATerminalMenu")
	self._panel:SetSize(ScrW()/2, ScrH()/2)
	self._panel:Center()
	self._panel:SetVisible(false)
	
	self._panel.OnClose = function()
		self:PlayerClosedMenu()
	end
	net.Receive("SATerminalOpen", function()
		self:OpenMenu(net.ReadEntity())
	end)
	net.Receive("SATerminalClose", function()
		self:CloseMenu(net.ReadEntity())
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SATerminalOpen", nil)
	net.Receive("SATerminalClose", nil)
end

SA:RegisterPlugin(PLUGIN)