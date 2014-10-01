include("DSATopbarMember.lua")
include("DSATopbarTextMember.lua")

local PANEL = {}

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetWide(ScrW())
	self.panels = {}
	self.borderColor = Color(255, 255, 255, 255)
	self.isDown = true
	
	self:SetFont("Default")
	
	self.panelRows = {}
	
	self.colSpacing = 4
	self.rowSpacing = 2
	self.paddingTop = 2
	
	self.posOffset = 4
	
	self._nextPerform = 0
	
	self._isUp = false
end

function PANEL:GetFont()
	return self.font
end

local dummy
function PANEL:SetFont(font)
	self.font = font
	surface.SetFont(font)
	dummy, self.lineHeight = surface.GetTextSize(
		"abjcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	)
	self.lineHeight = self.lineHeight + 2--pixel spacing
end

function PANEL:PerformLayout(w, h)
	local rowFill
	local reqWidth
	local rowAdd = 0
	local trueRow = 0
	local skipRow = false
	for row, panels in SortedPairs(self.panelRows) do
		rowFill = 0
		skipRow = false
		for idx, pnl in next, panels do
			pnl:Update()
			reqWidth = math.min(pnl:RequestWidth(), w)
			if((rowFill + reqWidth) > w) then
				rowAdd = rowAdd + 1
				rowFill = 0
			end
			pnl:SetPos(rowFill, (trueRow+rowAdd)*(self.lineHeight+self.rowSpacing)+self.paddingTop)
			pnl:SetSize(reqWidth, self.lineHeight)
			rowFill = rowFill + reqWidth + self.colSpacing
			
			if(!pnl:IsVisible()) then
				if(pnl:GetSize() >= w) then
					skipRow = true
				end
				continue
			end
		end
		if(!skipRow) then
			trueRow = trueRow + 1
		end
	end
	self:SetSize(w, (trueRow+rowAdd)*(self.rowSpacing+self.lineHeight)+4+self.paddingTop)
end

function PANEL:Update()
	local teams = team.GetAllTeams()
	local id = LocalPlayer():Team()
	if(teams[id]) then
		local colRef = teams[id].Color
		self.borderColor.r = colRef.r
		self.borderColor.g = colRef.g
		self.borderColor.b = colRef.b
	end
end

function PANEL:Think()
	local t = RealTime()
	if(t >= self._nextPerform) then
		self._nextPerform = t + 1
		self:Update()
		self:InvalidateLayout(true)
	end
end
	

function PANEL:ApplySchemeSettings()
end

function PANEL:AddPanel(line, pnl)
	if(!self.panelRows[line]) then
		self.panelRows[line] = {}
	end
	self.panelRows[line][pnl] = pnl
	self.panels[pnl] = pnl
	pnl:SetParent(self)
	self:InvalidateLayout(true)
end

function PANEL:Unregister(pnl)
	self.panels[pnl] = nil
	self.panelPositions[pnl] = nil
	self.panelSizes[pnl] = nil
	for k, v in next, self.panelRows do
		if(v[pnl]) then
			self.panelRows[k][pnl] = nil
		end
	end
	self:InvalidateLayout(true)
end

local gradient = Material("gui/gradient_down")

function PANEL:Paint(w, h)
	surface.SetMaterial(gradient)
	surface.SetDrawColor(0, 0, 0, 230)
	surface.DrawTexturedRect(0, 0, w, self:GetTall()*2)
	
	local r = self.borderColor.r
	local g = self.borderColor.g
	local b = self.borderColor.b
	for i = 1, #self.panels do
		r, g, b = self.panels[i]:ModifyBorderColor(r, g, b)
	end
	
	surface.SetDrawColor(r, g, b, 255)
	surface.DrawRect(0, h-3, ScrW(), 4)
end

function PANEL:GetBorderColorReference()
	return self.borderColor
end

function PANEL:GetBorderColor()
	return self.borderColor.r, self.borderColor.g, self.borderColor.b
end

function PANEL:SetBorderColor(r, g, b)
	self.borderColor.r = r
	self.borderColor.g = g
	self.borderColor.b = b
end

function PANEL:SetBorderColorReference(col)
	self.borderColor = col
end

function PANEL:OnMousePressed(key)
	local x, y = self:CursorPos()
	local h = self:GetTall()
	if(y <= h and y >= h-3) then
		self:TogglePosition()
	end
end

function PANEL:TogglePosition()
	if(self._isUp) then
		self:MoveTo(0, 0, 1, 0, 1)
	else
		if(self._alertActive) then
			self:MoveTo(0, -self:GetTall()+3+self.lineHeight, 1, 0, 1)
			return
		end
		self:MoveTo(0, -self:GetTall()+3, 1, 0, 1)
	end
	self._isUp = not self._isUp
end

vgui.Register("DSATopbar", PANEL, "DPanel")