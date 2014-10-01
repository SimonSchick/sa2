surface.CreateFont(
	"SAHealthIndicator",
	{
		font = "neuropol",
		size = 45,
		weight = 300,
		antialias = true,
		additive = false,
	}
)

surface.CreateFont(
	"SAArmorIndicator",
	{
		font = "neuropol",
		size = 35,
		weight = 300,
		antialias = true,
		additive = false,
	}
)

local PANEL = {}

AccessorFunc(PANEL, "m_fLerpFactor", "Lerp")

function PANEL:Init()
	local lp = LocalPlayer()
	if(not ValidEntity(lp)) then
		self._showHealth = 0
		self._showArmor = 0
	else
		self._showHealth = lp:Health()
		self._showArmor = lp:Armor()
	end
	self.m_fLerpFactor = 0.025
	
	self._healthRaise = 0
	self._armorRaise = 0
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
	self._healthPolyTblInner = buildPolyBox(2, 2, w*0.55-4, h*0.55-4, cSize, cSize)
	self._healthPolyTblOuter = buildPolyBox(0, 0, w*0.55, h*0.55, cSize, cSize)

	self._armorPolyTblInner = buildPolyBox(w*0.55-cSize-2, h*0.55-cSize-2, w*0.45-4, h*0.45-4, cSize, cSize)
	self._armorPolyTblOuter = buildPolyBox(w*0.55-cSize-4, h*0.55-cSize-4, w*0.45, h*0.45, cSize, cSize)
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
			
			if(self._healthRaise > 0) then
				surface.SetDrawColor(0, math.min(self._healthRaise*5, 200), 0, 200)
			elseif(self._healthRaise < 0) then
				surface.SetDrawColor(math.min(-self._healthRaise*5, 200), 0, 0, 200)
			else
				surface.SetDrawColor(0, 0, 0, 200)
			end
			surface.DrawPoly(self._healthPolyTblInner)
			
			if(self._armorRaise > 0) then
				surface.SetDrawColor(0, 0, math.min(self._armorRaise*10, 200), 200)
			elseif(self._armorRaise < 0) then
				surface.SetDrawColor(math.min(-self._armorRaise*10, 200), 0, 0, 200)
			else
				surface.SetDrawColor(0, 0, 0, 200)
			end
			surface.DrawPoly(self._armorPolyTblInner)
			
			surface.SetDrawColor(team.GetColor(lp:Team()))
			
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			surface.DrawPoly(self._armorPolyTblOuter)
			surface.DrawPoly(self._healthPolyTblOuter)
			
		render.SetStencilEnable(false)
	end
	
	if self._showHealth < 50 then
		surface.SetTextColor(255, math.min(self._showHealth, 100)*2.55, 0, 210)
	else
		surface.SetTextColor(255-math.min(self._showHealth, 100)*5.1, 255, 0, 210)
	end
	
	surface.SetFont("SAHealthIndicator")
	local sVal = tostring(math.Round(self._showHealth))
	local tw, th = surface.GetTextSize(sVal)
	surface.SetTextPos(((w*0.55)-tw)/2,((h*0.55)-th)/2)
	surface.DrawText(sVal)
	
	if self._showArmor < 50 then
		surface.SetTextColor(255, 0, math.min(self._showArmor, 100)*2.55, 210)
	else
		surface.SetTextColor(255-math.min(self._showArmor, 100)*2.55, 0, 255, 210)
	end
	
	surface.SetFont("SAArmorIndicator")
	local csize = (w+h)/20
	sVal = tostring(math.ceil(self._showArmor))
	tw, th = surface.GetTextSize(sVal)
	surface.SetTextPos((0.55*w-csize-2) + (0.225*w) - tw/2 ,(0.55*h-csize-2) + (0.225*h) - th/2)
	
	surface.DrawText(sVal)
	return true
end

function PANEL:Think()
	if(not ValidEntity(LocalPlayer())) then
		return
	end
	local health = math.max(0, LocalPlayer():Health())
	self._healthRaise = health - self._showHealth
	
	local armor = math.max(0, LocalPlayer():Armor())
	self._armorRaise = armor - self._showArmor
	
	self._showHealth = Lerp(self.m_fLerpFactor, self._showHealth, health)
	self._showArmor = Lerp(self.m_fLerpFactor, self._showArmor, armor)
end

vgui.Register("DSAHealthIndicator", PANEL, "DPanel")