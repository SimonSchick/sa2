local PANEL = {}

function PANEL:ActionSignal(key, value)

end

function PANEL:ApplySchemeSettings()

end

function PANEL:Init()
	self.ResearchTree = self:GetParent()
	
	local drawBackgroundCheckbox = vgui.Create("DCheckBoxLabel", self)
	drawBackgroundCheckbox:SetText("Show textured background?")
	drawBackgroundCheckbox.OnChange = function(checkBox, val)
		self.ResearchTree:SetDrawBackground(val)
	end
	self.drawBackgroundCheckbox = drawBackgroundCheckbox
	
	
	local drawConnectorsForegroundCheckbox = vgui.Create("DCheckBoxLabel", self)
	drawConnectorsForegroundCheckbox:SetText("Show connectors in the foreground?")
	drawConnectorsForegroundCheckbox.OnChange = function(checkBox, val)
		self.ResearchTree:SetDrawInForeground(val)
	end
	self.drawConnectorsForegroundCheckbox = drawConnectorsForegroundCheckbox
	
	drawUnavailableCheckBox = vgui.Create("DCheckBoxLabel", self)
	drawUnavailableCheckBox:SetText("Show unavailable Researches?")
	function drawUnavailableCheckBox.OnChange(checkBox, val)
		self.ResearchTree:SetDrawUnavailable(val)
	end
	self.drawUnavailableCheckBox = drawUnavailableCheckBox
	
	connectorTypeLabel = vgui.Create("DLabel", self)
	connectorTypeLabel:SetText("Connector type")
	self.connectorTypeLabel = connectorTypeLabel
	
	connectorTypeSelector = vgui.Create("DComboBox", self)
	connectorTypeSelector:AddChoice("Straight", "straight")
	connectorTypeSelector:AddChoice("Cornered", "cornered")
	connectorTypeSelector:AddChoice("Curved", "bezier")
	function connectorTypeSelector.OnSelect(_, _, _, data)
		self:SetLineType(data)
	end
	self.connectorTypeSelector = connectorTypeSelector
	
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

vgui.Register("DSAResearchTreeConfig", PANEL, "DPanel")