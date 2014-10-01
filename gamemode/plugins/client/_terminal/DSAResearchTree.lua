include("DSAResearchTreeHelper.lua")
include("DSAResearchTreeConfig.lua")
local PANEL = {}

AccessorFunc(PANEL, "m_bDrawBackground", "DrawBackground")
AccessorFunc(PANEL, "m_bDrawInForeground", "DrawInForeground")
AccessorFunc(PANEL, "m_bDrawUnavailable", "DrawUnavailable")
AccessorFunc(PANEL, "m_sLineType", "LineType")


function PANEL:ActionSignal(key, value)

end

function PANEL:ApplySchemeSettings()
end

function PANEL:Init()
	self.m_bDrawBackground = true
	self.m_bDrawInForeground = false
	self.m_bDrawUnavailable = true
	self.m_sLineType = "straight"
	
	self.researchPanels = {}
	self.panelPositionsX = {}
	self.panelPositionsY = {}
	self.panelSizesW = {}
	self.panelSizesH = {}
	self.drawnPanelConnectors = {}

	local researchPanel

	for k, v in next, SA.Plugins.Research:GetAll() do
		researchPanel = vgui.Create("DSAResearchPanel", self)
		researchPanel:SetResearch(k)
		self.researchPanels[k] = researchPanel
	end
	local helpPanel = vgui.Create("DSAResearchTreeHelper", self)
	helpPanel:SetVisible(false)
	self.helpPanel = helpPanel
	
	local configPanel = vgui.Create("DSAResearchTreeConfig", self)
	configPanel:SetVisible(false)
	self.configPanel = configPanel
	
	local showHelpPanelButton = vgui.Create("DButton", self)
	showHelpPanelButton:SetText("Show help menu")
	showHelpPanelButton.DoClick = function(btn)
		self.helpPanel:SetVisible(true)
	end
	self.showHelpPanelButton = showHelpPanelButton
	
	local showConfigPanelButton = vgui.Create("DButton", self)
	showConfigPanelButton:SetText("Show help menu")
	showConfigPanelButton.DoClick = function(btn)
		self.configPanel:SetVisible(true)
	end
	self.showConfigPanelButton = showConfigPanelButton

	self:SetPaintBackground(false)

	self:PerformLayout()
end

function PANEL:OnCursorEntered()

end

function PANEL:OnCursorExited()

end

function PANEL:OnCursorMoved(mouseX, mouseY)

end

function PANEL:OnKeyCodePressed(keyCode)
	if(keyCode == KEY_F1) then
		self.helpPanel:SetVisible(true)
	if(keyCode == KEY_F2) then
		self.configPanel:SetVisible(true)
	end
end

function PANEL:OnMousePressed(mouseCode)
	--do on-drag scrolling here
end

function PANEL:OnMouseReleased(mouseCode)
	--do on-drag scrolling here
end

function PANEL:OnMouseWheeled(scrollDelta)
	--zoom?
end

function PANEL:Paint()
	if(!self.m_bDrawInForeground) then
		self:MainPaint()
	end
end

function PANEL:PaintOver()
	if(self.m_bDrawInForeground) then
		self:MainPaint()
	end
end

function PANEL:PerformLayout()
	for k, v in next, self.researchPanels do
		local x, y = 0, 0
		local w, h = v:GetSize()
		
		--positiong here
		
		self.panelPositionsX[k] = x
		self.panelPositionsY[k] = y
		self.panelSizesW[k] = w
		self.panelSizesH[k] = h
	end
	
	self.showHelpPanelButton:SetPos(0, 2)
	self.showHelpPanelButton:AlignRight(4)
	
	self.showConfigPanelButton:SetPos(0, 2)
	self.showConfigPanelButton:MoveRightOf(self.showHelpPanelButton)
	
	self.panelIterator, self.panelIteratorTable = next, self.researchPanels
end

function PANEL:Think()
	return false
end

function PANEL:AddResearch(resName, posX, posY)
	researchPanel = vgui.Create("DSAResearchPanel", self)
	researchPanel:SetResearch(resName)
	researchPanels[resName] = researchPanel

	local w, h = researchPanel:GetSize()
	self.panelPositionsX[resName] = posX
	self.panelPositionsY[resName] = posY
	self.panelSizesW[resName] = w
	self.panelSizesH[resName] = h
	self:PerformLayout()
end

local backgroundMat = Material("spaceage2/gui/ResearchTreeBackground")
function PANEL:MainPaint()
	if(self.m_sLineType == "straight") then
		self:DrawLinksStraight()
	elseif(self.m_sLineType == "cornered") then
		self:DrawLinksCornered()
	elseif(self.m_sLineType == "bezier") then
		self:DrawLinksBezier()
	end
	if(self.m_bDrawBackground) then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(backgroundMat)
		surface.DrawTexturedRect(0, 0, self:GetSize())
	else
		surface.SetDrawColor(50, 50, 50, 255)
		surface.DrawRect(0, 0, self:GetSize())
	end
end

local sSetDrawColor = surface.SetDrawColor
local sDrawRect = surface.DrawRect
local sDrawLine = surface.DrawLine
local msin = math.sin
local mrad = math.rad
local RealTime = RealTime
--[[
	Name: DSAResearchTree:DrawLinksStraight()
	Description: Draws straight connector lines between the researches
]]--
function PANEL:DrawLinksStraight()
	local researched = researches.GetResearched()
	local available = researches.GetAvailable()
	local requirements
	local spacing
	local posX
	local posY
	local panelSizesW = self.panelSizesW
	local panelSizesH = self.panelSizesH
	local panelPositionsX = self.panelPositionsX
	local panelPositionsY = self.panelPositionsY
	local availableColor = (msin(mrad(RealTime()*90))+1)*100+155
	for k, v in self.panelIterator, self.panelIteratorTable do
		requirements = researches.Get(k).requirements
		if(requirements) then
			spacing = panelSizesH[k]/#requirements
			posX = panelPositionsX[k]
			posY = panelPositionsY[k]
			if(researched[k]) then
				sSetDrawColor(100, 100, 255, 200)
			elseif(available[k]) then
				sSetDrawColor(100, 100, availableColor, 200)
			end
			for i=1, #requirements do
				sDrawRect(posX-2, posY+spacing*i, 2, 2)--current panel connectors
				
				sDrawLine(
					panelPositionsX[requirements[i]] + panelSizesW[requirements[i]], 
					panelPositionsY[requirements[i]] + panelSizesH[requirements[i]]/2,
					posX-2, posY+spacing*i
				)--dat fucking line
				
				if(drawnPanelConnectors[requirements[i]]) then
					continue
				end
				sDrawRect(panelPositionsX[requirements[i]] + panelSizesW[requirements[i]], 
				panelPositionsY[requirements[i]] + panelSizesH[requirements[i]]/2, 2, 2)--requirement panel connector
				end
			end
		end
	end
end

--[[
	Name: DSAResearchTree:DrawLinksCornered()
	Description: Draws cornered connectors between the researches
]]--
function PANEL:DrawLinksCornered()
	local researched = researches.GetResearched()
	local available = researches.GetAvailable()
	local requirements
	local spacing
	local posX
	local posY
	local panelSizesW = self.panelSizesW
	local panelSizesH = self.panelSizesH
	local panelPositionsX = self.panelPositionsX
	local panelPositionsY = self.panelPositionsY
	local requirementPositionX
	local requirementPositionY
	local requirementSizeW
	local requirementSizeH
	local availableColor = (msin(mrad(RealTime()*128))+1)*100+150
	for k, v in self.panelIterator, self.panelIteratorTable do
		requirements = researches.Get(k).requirements
		if(requirements) then
			spacing = panelSizesH[k]/#requirements
			posX = panelPositionsX[k]
			posY = panelPositionsY[k]
			if(researched[k]) then
				sSetDrawColor(100, 100, 255, 200)
			elseif(available[k]) then
				sSetDrawColor(100, 100, availableColor, 200)
			end
			for i=1, #requirements do
				sDrawRect(posX-2, posY+spacing*i, 2, 2)--current panel connectors
				
				requirementPositionX = panelPositionsX[requirements[i]]
				requirementPositionY = panelPositionsY[requirements[i]]
				
				requirementSizeW = panelSizesW[requirements[i]]
				requirementSizeH = panelSizesH[requirements[i]]
				
				sDrawRect(panelPositionsX[requirements[i]] + panelSizesW[requirements[i]], 
					requirementPositionY + requirementSizeH/2, 
					requirementPositionX + requirementSizeW - posX, 1) --first line
					
				sDrawRect(
					requirementPositionX + requirementSizeW + (posX - (requirementPositionX + requirementSizeW)), 
					posY + spacing*i,
					1,
					(requirementPositionY + requirementSizeH/2) - (posY+spacing*i)--height difference
				) 
				
				sDrawRect(
					requirementPositionX + requirementSizeW + (posX - (requirementPositionX + requirementSizeW)), 
					posY + spacing*i,
					requirementPositionY + requirementSizeH/2,
					1
				) --last line
				
				if(drawnPanelConnectors[requirements[i]]) then
					continue
				end
				sDrawRect(
					requirementPositionX + requirementSizeW,
					requirementPositionY + requirementSizeH/2,
					2,
					2
				)--requirement panel connector
			end
		end
	end
end

--[[
	Name: DSAResearchTree:DrawLinksBezier()
	Description: Draws bezier curve connector lines between the researches
]]--
function PANEL:DrawLinksBezier()
	local researched = researches.GetResearched()
	local available = researches.GetAvailable()
	local requirements
	local spacing
	local posX
	local posY
	local panelSizesW = self.panelSizesW
	local panelSizesH = self.panelSizesH
	local panelPositionsX = self.panelPositionsX
	local panelPositionsY = self.panelPositionsY
	local availableColor = (msin(mrad(RealTime()*128))+1)*100+150
	for k, v in self.panelIterator, self.panelIteratorTable do --cache due performence reasons
		requirements = researches.Get(k).requirements
		if(requirements) then
			spacing = panelSizesH[k]/#requirements
			posX = panelPositionsX[k]
			posY = panelPositionsY[k]
			if(researched[k]) then
				sSetDrawColor(100, 100, 255, 200)
			elseif(available[k]) then
				sSetDrawColor(100, 100, availableColor, 200)
			end
			for i=1, #requirements do
				sDrawRect(posX-2, posY+spacing*i, 2, 2)--current panel connectors
				
				--DRAW BEZIER HERE!!!!
				
				if(drawnPanelConnectors[requirements[i]]) then
					continue
				end
				sDrawRect(panelPositionsX[requirements[i]] + panelSizesW[requirements[i]], 
				panelPositionsY[requirements[i]] + panelSizesH[requirements[i]]/2, 2, 2)--requirement panel connector
			end
		end
	end
end

function PANEL:SetDrawUnavailable(b)--accessor override
	if(b) then
		m_bDrawUnavailable = true
		for k, v in next, self.researchPanels do
			if(!researches.IsAvailable(k)) then
				v:SetVisible(true)
			end
		end
		return
	end
	for k, v in next, self.researchPanels do
		if(!researches.IsAvailable(k)) then
			v:SetVisible(false)
		end
	end
end

vgui.Register("DSAResearchTree", PANEL, "DPanel")