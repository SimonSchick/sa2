include("DSAScoreBoardRow.lua")
local PANEL = {}

function PANEL:Init()
	self._nextThink = RealTime()+2
	self:Update()
	self:SetAutoSize(true)
	self:EnableVerticalScrollbar()
end

function PANEL:Paint(w, h)
	return true
end

function PANEL:Update()
	local doPeform = false
	local plyRows = {}
	local ply
	for _, row in next, self.Items do
		ply = row:GetPlayer()
		if(not ply:IsValid()) then
			self:RemoveItem(row)
			continue
		end
		row:Update()
		plyRows[ply] = true
	end
	for _, ply in next, player.GetHumans() do
		if(not plyRows[ply]) then
			local newRow = vgui.Create("DSAScoreBoardRow")
			newRow:SetPlayer(ply)
			newRow:CopyWidth(self)
			newRow:SetHeight(48)
			self:AddItem(newRow)
		end
	end
end

function PANEL:Think()
	local t = RealTime()
	if(t >= self._nextThink) then
		self:Update()
		self._nextThink = t + 1
	end
end

function PANEL:PerformLayout(w)
	local YPos = 0
	
	if ( self.VBar && !m_bSizeToContents ) then

		self.VBar:SetPos( self:GetWide() - 13, 0 )
		self.VBar:SetSize( 13, self:GetTall() )
		self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
		YPos = self.VBar:GetOffset()
		
		if ( self.VBar.Enabled ) then w = w - 13 end

	end

	self.pnlCanvas:SetPos( 0, YPos )
	self.pnlCanvas:SetWide( w )
	
	self:Rebuild()
	
	if ( self:GetAutoSize() ) then
	
		self:InvalidateLayout()
		self.pnlCanvas:SetPos( 0, 0 )
	
	end	

end

vgui.Register("DSAScoreBoardRowContainer", PANEL, "DPanelList")