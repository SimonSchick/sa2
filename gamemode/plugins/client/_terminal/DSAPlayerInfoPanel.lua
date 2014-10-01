local PANEL = {}

function PANEL:ActionSignal(key, value)

end

function PANEL:ApplySchemeSettings()

end

function PANEL:Init()
	local playerAvatar = vgui.Create("AvatarImage", self)
	self.playerAvatar = playerAvatar
	
	local playerName = vgui.Create("DLabel", self)
	self.playerName = playerName
	
	local playerDescription = vgui.Create("DLabel", self)
	self.playerDescription = playerDescription
	
	local playerStatistics = vgui.Create("DListView", self)
	playerStatistics:AddColumn("Statistic name")
	playerStatistics:AddColumn("Value")
	self.playerStatistics = playerStatistics

	self:SetPaintBackground(false)
end

function PANEL:OnCursorEntered()

end

function PANEL:OnCursorExited()

end

function PANEL:OnCursorMoved(mouseX, mouseY)

end

function PANEL:OnKeyCodePressed(keyCode)

end

function PANEL:OnMousePressed(mouseCode)
	if(ValidEntity(self.player)) then
		SAGUI:ShowPlayerInfo(self.player)
	end
end

function PANEL:OnMouseReleased(mouseCode)
	
end

function PANEL:OnMouseWheeled(scrollDelta)

end

function PANEL:Paint()

end

function PANEL:PaintOver()

end

function PANEL:PerformLayout()

end

function PANEL:Think()
end

function PANEL:SetPlayer(ply)
	if(!ValidEntity(ply)) then
		return false
	end
	self.player = ply
	if(ValidEntity(self.playerAvatar:GetPlayer())) then --prevention of memory leak
		newAvatar = vgui.Create("AvatarImage", self)
		newAvatar:SetPlayer(ply)
		self.playerAvatar = newAvatar
	else
		self.playerAvatar:SetPlayer(ply)
	end

	self.playerName:SetText(ply:GetName())
	
	self.playerStatistics:Clear()
	for k, v in next, statistics.GetPlayerStatistics(ply) do
		self.playerStatistics:AddLine(k, tostring(v)) --MAKE THIS FANCIER!!
	end
	
	self:PerformLayout()
end

function PANEL:GetPlayer()
	return self.player
end

vgui.Register("DSAPlayerInfoPanel", PANEL, "DPanel")