include("DSAResearchMenu.lua")
include("DSAMarketMenu.lua")
include("DSALeaderBoard.lua")

local PANEL = {}

function PANEL:ActionSignal(key, value)

end

function PANEL:ApplySchemeSettings()

end

function PANEL:Init()
	self.m_bDeleteOnClose = false
	local tabHolder = vgui.Create("DPropertySheet", self)

	local researchMenu = vgui.Create("DSAResearchMenu")
	local marketMenu = vgui.Create("DSAMarketMenu")
	
	
	tabHolder:AddSheet("Research Menu", researchMenu, "gui/silkicons/lightbulb", false, false, "Dicks")
	tabHolder:AddSheet("Market Menu", marketMenu, "gui/silkicons/lightbulb", false, false, "Dicksssss")
	self.tabHolder = tabHolder
	

end

function PANEL:Show()
	self:SetAlpha(0)
	self:AlphaTo(255, 1, 0, 1)
	self:SetVisible(true)
end

function PANEL:PerformLayout()
	DFrame.PerformLayout(self)
	self.tabHolder:StretchToParent(2, 24, 2, 2)
end

vgui.Register("DSATerminalMenu", PANEL, "DFrame")