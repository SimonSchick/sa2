include("DSAScoreBoardRowContainer.lua")

local PANEL = {}

function PANEL:Init()
	self._rowContainer = vgui.Create("DSAScoreBoardRowContainer", self)
end

local function buildPolyBox(x, y, width, height, cornerWidth, cornerHeight)
	return {
		{x=x+cornerWidth, y=y},
		{x=x+width-cornerWidth, y=y},
		{x=x+width, y=y+cornerHeight},
		{x=x+width, y=y+height-cornerHeight},
		{x=x+width-cornerWidth, y=y+height},
		{x=x+cornerWidth, y=y+height},
		{x=x, y=y+height-cornerHeight},
		{x=x, y=y+cornerHeight}
	}
end

function PANEL:PerformLayout(w, h)
	local cSize = (w+h)/20
	self._rowContainer:StretchToParent(5, cSize, 5, cSize)
	
	self._innerPoly = buildPolyBox(2, 2, w-4, h-4, cSize, cSize)
	self._outerPoly = buildPolyBox(0, 0, w, h, cSize, cSize)
end

local STENCILCOMPARISONFUNCTION_ALWAYS = STENCILCOMPARISONFUNCTION_ALWAYS
local STENCILOPERATION_REPLACE = STENCILOPERATION_REPLACE
local STENCILCOMPARISONFUNCTION_NOTEQUAL = STENCILCOMPARISONFUNCTION_NOTEQUAL
local STENCILOPERATION_KEEP = STENCILOPERATION_KEEP

local white = surface.GetTextureID("vgui/white")
function PANEL:Paint(w, h)
	local lp = LocalPlayer()
	if(lp:IsValid()) then
		surface.SetTexture(white)
		render.SetStencilEnable(true)
			render.SetStencilReferenceValue(42)
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
			render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
			render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
			
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawPoly(self._innerPoly)
			
			surface.SetDrawColor(team.GetColor(lp:Team()))
			
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			surface.DrawPoly(self._outerPoly)
			
		render.SetStencilEnable(false)
	end
end

function PANEL:Show()
	self._rowContainer:Update()
	local pW, pH = self:GetParent():GetSize()
	self:SetVisible(true)
	self:MoveTo(
		(pW * 0.5) - (self:GetWide() * 0.5),
		(pH * 0.5) - (self:GetTall() * 0.5),
		0.2,
		0,
		1
	)
	timer.Remove("SAScoreBoardHide")
end

function PANEL:Hide()
	self:SetVisible(true)
	self:MoveTo(
		(self:GetParent():GetWide() * 0.5) - (self:GetWide() * 0.5),
		-self:GetTall()-10,
		0.2,
		0,
		1
	)
	timer.Create("SAScoreBoardHide", 0.2, 1, function() self:SetVisible(false) end)
end
vgui.Register("DSAScoreBoard", PANEL, "DPanel")