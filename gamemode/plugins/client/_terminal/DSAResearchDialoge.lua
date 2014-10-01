local PANEL = {}

function PANEL:ActionSignal(key, value)

end

function PANEL:ApplySchemeSettings()

end

function PANEL:Init()
	local researchIcon = vgui.Create("DImage", self)
	self.researchIcon = researchIcon
	
	local researchDescription = vgui.Create("DLabel", self)
	self.researchDescription = researchDescription
	
	local researchStartButton = vgui.Create("DButton", self)
	researchStartButton:SetText("Research")
	self.researchStartButton = researchStartButton
	
	local researchAbortButton = vgui.Create("DButton", self)
	researchAbortButton:SetText("Abort Research")
	self.researchAbortButton = researchAbortButton
	
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

end

function PANEL:Think()
end

vgui.Register("DSAResearchDialoge", PANEL, "DPanel")