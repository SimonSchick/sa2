include("DSAFactionRow.lua")
local PANEL = {}

function PANEL:Init()
	self:SetAutoSize(true)
	self:EnableVerticalScrollbar()
end

function PANEL:Paint(w, h)
	return true
end

function PANEL:Update()
end

function PANEL:PerformLayout(w, h)
	local YPos = 0
	
	if ( self.VBar && !m_bSizeToContents ) then

		self.VBar:SetPos( w - 13, 0 )
		self.VBar:SetSize( 13, h )
		self.VBar:SetUp( h, self.pnlCanvas:GetTall() )
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

vgui.Register("DSAFactionNewsFeed", PANEL, "DPanelList")