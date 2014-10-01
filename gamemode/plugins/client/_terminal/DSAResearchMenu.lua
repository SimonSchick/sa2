local PANEL = {}

include("DSAResearchList.lua")
include("DSAResearchTree.lua")

function PANEL:ActionSignal(key, value)

end

function PANEL:ApplySchemeSettings()

end

function PANEL:Init()
	local tabHolder = vgui.Create("DPropertySheet", self)
	local researchList = vgui.Create("DSAResearchList")
	self.researchList = researchList
	tabHolder:SetActiveTab(
		tabHolder:AddSheet(
			"Research List",
			researchList,
			"gui/silkicons/lightbulb",
			false,
			false,
			"A list of researches"
		).Tab
	)
	self.tabHolder = tabHolder
	local researchTree = vgui.Create("DSAResearchTree")
	self.researchTree = ResearchList
	tabHolder:AddSheet(
		"Research Tree",
		researchTree,
		"gui/silkicons/lightbulb",
		false,
		false,
		"A list of researches"
	)
	self.researchTree = researchTree
	
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
	self.tabHolder:StretchToParent(2, 24, 2, 2)
end

function PANEL:Think()
end

vgui.Register("DSAResearchMenu", PANEL, "DPanel")