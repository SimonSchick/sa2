include("DSAFactionRow.lua")
local PANEL = {}

function PANEL:Init()
	self:SetAutoSize(true)
	self:EnableVerticalScrollbar()
	self._wasUpdated = false
end

function PANEL:Paint(w, h)
	return true
end

function PANEL:Update()
	if(self._wasUpdated) then
		return
	end
	self._wasUpdated = true
	for k in next, SA.Plugins.Factions:GetAll() do
		local row = vgui.Create("DSAFactionRow")
		row:SetHeight(32)
		row:SetFaction(k)
		self:AddItem(row)
	end
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

vgui.Register("DSAFactionList", PANEL, "DPanelList")