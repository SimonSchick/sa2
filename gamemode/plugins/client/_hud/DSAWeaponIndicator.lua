surface.CreateFont(
	"SAClip1Indicator",
	{
		font = "neuropol",
		size = 30,
		weight = 400,
		antialias = true,
		additive = false,
	}
)

surface.CreateFont(
	"SAClip2Indicator",
	{
		font = "neuropol",
		size = 20,
		weight = 400,
		antialias = true,
		additive = false,
	}
)
local PANEL = {}

AccessorFunc(PANEL, "m_fLerpFactor", "Lerp")

function PANEL:Init()
	local lp = LocalPlayer()
	if(not ValidEntity(lp)) then
		self._showClip1 = 0
		self._showClip2 = 0
	else
		self._showClip1 = lp:clip1()
		self._showClip2 = lp:clip2()
	end
	self.m_fLerpFactor = 0.025
	
	self._clip1Raise = 0
	self._clip2Raise = 0
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
	self._clip1PolyTblInner = buildPolyBox(w*0.66-cSize*2-2, 0.45*h+2, w*0.33+cSize-4, h*0.55-4, cSize, cSize)
	self._clip1PolyTblOuter = buildPolyBox(w*0.66-cSize*2-4, 0.45*h, w*0.33+cSize, h*0.55, cSize, cSize)

	self._clip2PolyTblInner = buildPolyBox(w*0.33+2-cSize, 2, w*0.33+cSize-4, h*0.55-4, cSize, cSize)
	self._clip2PolyTblOuter = buildPolyBox(w*0.33-cSize, 0, w*0.33+cSize, h*0.55, cSize, cSize)
	
	self._weaponPolyTblInner = buildPolyBox(2, 0.45*h+2, w*0.33+cSize-4, h*0.33-4, cSize, cSize)
	self._weaponPolyTblOuter = buildPolyBox(0, 0.45*h, w*0.33+cSize, h*0.33, cSize, cSize)
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
			
			if(self._clip1Raise > 0) then
				surface.SetDrawColor(math.min(self._clip1Raise*5, 200), 0, 0, 200)
			elseif(self._clip1Raise < 0) then
				surface.SetDrawColor(math.min(-self._clip1Raise*5, 200), 0, 0, 200)
			else
				surface.SetDrawColor(0, 0, 0, 200)
			end
			surface.DrawPoly(self._clip1PolyTblInner)
			
			if(self._clip2Raise > 0) then
				surface.SetDrawColor(0, 0, math.min(self._clip2Raise*10, 200), 200)
			elseif(self._clip2Raise < 0) then
				surface.SetDrawColor(math.min(-self._clip2Raise*10, 200), 0, 0, 200)
			else
				surface.SetDrawColor(0, 0, 0, 200)
			end
			surface.DrawPoly(self._clip2PolyTblInner)
			
			surface.SetDrawColor(team.GetColor(lp:Team()))
			
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			surface.DrawPoly(self._clip2PolyTblOuter)
			surface.DrawPoly(self._clip1PolyTblOuter)
			
		render.SetStencilEnable(false)
	end
	
	if self._showClip1 < 50 then
		surface.SetTextColor(255, math.min(self._showClip1, 100)*2.55, 0, 210)
	else
		surface.SetTextColor(255-math.min(self._showClip1, 100)*2.55, 255, 0, 210)
	end
	
	surface.SetFont("SAClip1Indicator")
	local sVal = tostring(math.Round(self._showClip1))
	local tw, th = surface.GetTextSize(sVal)
	surface.SetTextPos(((w*0.55)-tw)/2,((h*0.55)-th)/2)
	surface.DrawText(sVal)
	
	if self._showClip2 < 50 then
		surface.SetTextColor(255, math.min(self._showClip2, 100)*2.55, 0, 210)
	else
		surface.SetTextColor(math.min(self._showClip2, 100)*2.55, 255, 0, 210)
	end
	
	surface.SetFont("SAClip2Indicator")
	local csize = (w+h)/20
	sVal = tostring(math.ceil(self._showClip2))
	tw, th = surface.GetTextSize(sVal)
	surface.SetTextPos((0.55*w-csize-2) + (0.225*w) - tw/2 ,(0.55*h-csize-2) + (0.225*h) - th/2)
	
	surface.DrawText(sVal)
	return true
end

function PANEL:Think()
	if(not ValidEntity(LocalPlayer())) then
		return
	end
	local weap = LocalPlayer():GetActiveWeapon()
	if(weap) then
		local clip1 = weap:Clip1()
		self._clip1Raise = clip1 - self._showClip1
		
		local clip2 = weap:Clip2()
		self._clip2Raise = clip2 - self._showClip2
		
		self._showClip1 = Lerp(self.m_fLerpFactor, self._showClip1, clip1)
		self._showClip2 = Lerp(self.m_fLerpFactor, self._showClip2, clip2)
	end
end

vgui.Register("DSAWeaponIndicator", PANEL, "DPanel")