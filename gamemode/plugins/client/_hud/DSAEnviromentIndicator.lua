local PANEL = {}

function PANEL:Init()
	self._hovered = false
	self._bgFade = 0
end

local function buildPolyBox(x, y, width, height, cornerWidth, cornerHeight)
	return {
		{x=x, y=y},
		{x=x+width-cornerWidth, y=y},
		{x=x+width, y=y+cornerHeight},
		{x=x+width, y=y+height-cornerHeight},
		{x=x+width-cornerWidth, y=y+height},
		{x=x, y=y+height},
	}
end

function PANEL:PerformLayout(w, h)
	local csize = (w+h)/10
	self._cSize = csize
	self._innerPoly = buildPolyBox(2, 2, w-4, h-4, csize, csize)
	self._outerPoly = buildPolyBox(0, 0, w, h, csize, csize)
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
			
			if(self._hovered) then
				self._bgFade = math.min(self._bgFade + 0.025/FrameTime(), 120)
			else
				self._bgFade = math.max(self._bgFade - 0.025/FrameTime(), 0)
			end
			
			surface.SetDrawColor(0, self._bgFade, 0, 200)
			surface.DrawPoly(self._innerPoly)
			
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			
			surface.SetDrawColor(team.GetColor(lp:Team()))
			surface.DrawPoly(self._outerPoly)
		render.SetStencilEnable(false)
		
		local posX = w-16
		for i = self._cSize, h-self._cSize, 18 do
			surface.DrawRect(posX, i, 8, 8)
		end
	end
end

function PANEL:OnCursorEntered()
	self._hovered = true
end

function PANEL:OnCursorExited()
	self._hovered = false
end

function PANEL:Think()
end

function PANEL:OnMouseReleased()
	local w, h = self:GetSize()
	local x, y = self:CursorPos()
	if((x > w-self._cSize) and ((y >= self._cSize) and (y <= h-self._cSize))) then
		self:Toggle()
	end
end

function PANEL:Toggle()
	if(self._isOpen) then
		self:Hide()
		return
	end
	self:Show()
end

function PANEL:Hide()
	self._isOpen = false
	self:MoveTo(-self:GetWide()+self._cSize, self.y, 0.2, 0, 1)
	--self._infoPanel:SetVisible(false)
end

function PANEL:Show()
	self._isOpen = true
	self:MoveTo(-5, self.y, 0.2, 0, 1)
	--self._infoPanel:SetVisible(true)
end

vgui.Register("DSAEnviromentIndicator", PANEL, "DPanel")