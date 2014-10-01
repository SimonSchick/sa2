local PLUGIN = Plugin("Topbar", {})
PANEL._panelQueue = {}

function PLUGIN:OnEnable()
	include(SA.Folder:sub(11).."/gamemode/plugins/client/_topbar/DSATopbar.lua")


	timer.Simple(3, function()
		self.Panel = vgui.Create("DSATopbar")
		self.Panel:SetAlpha(0)
		self.Panel:AlphaTo(255, 2, 0)
		self.Panel:SetBorderColorReference(team.GetColor(LocalPlayer():Team()))
		
		for k, v in next, self._panelQueue do
			v[2]:SetVisible(true)
			self.Panel:AddPanel(v[1], v[2])
		end
		self._panelQueue = nil
	end)
	net.Receive("SATopBarWarning", function()
		self.Panel:SetWarning(net.ReadString())
	end)

	net.Receive("SATopBarAlert", function()
		self.Panel:SetAlert(net.ReadString())
	end)
end

function PLUGIN:OnDisable()
	self.Panel:Remove()
	net.Receive("SATopBarWarning", nil)

	net.Receive("SATopBarAlert", nil)
end

function PLUGIN:AddPanel(line, pnl)
	if(not self.Panel) then
		pnl:SetVisible(false)
		table.insert(self._panelQueue, {line, pnl})
		return
	end
	self.Panel:AddPanel(line, pnl)
end

function PLUGIN:RemovePanel(pnl)
	self.Panel:Unregister(pnl)
end

SA:RegisterPlugin(PLUGIN)