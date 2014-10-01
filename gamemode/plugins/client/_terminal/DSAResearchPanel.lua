local PANEL = {}

function PANEL:ActionSignal(key, value)

end

function PANEL:ApplySchemeSettings()

end

function PANEL:Init()
	local researchName = vgui.Create("DLabel", self)
	researchName:SetText("")
	self.researchName = researchName
	
	local researcheIcon = vgui.Create("DImage", self)
	self.researcheIcon = researcheIcon
	
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
	savgui:ShowResearchDialoge(self.resName)
end

function PANEL:OnMouseReleased(mouseCode)

end

function PANEL:OnMouseWheeled(scrollDelta)

end

function PANEL:Paint()
	--draw research bar
end

function PANEL:PaintOver()

end

function PANEL:PerformLayout()

end

function PANEL:Think()
end

function PANEL:SetResearch(resName)
	--[[
	local research = SA.Research.Get(resName)
	self.researchName:SetText(research.fullName)
	self.researchImage:SetImage(research.icon)
	self.researchProgress = research.progress
	self.researchETA = research.ETA
	self.research = resName
	]]
end

vgui.Register("DSAResearchPanel", PANEL, "DPanel")