surface.CreateFont(
	"SAHelpMenuTitle",
	{
		font = "neuropol",
		size = 55,
		weight = 300,
		antialias = true,
		additive = false,
	}
)
local PANEL = {}

function PANEL:Init()
	self._title = vgui.Create("DLabel", self)
	self._title:SetText("Help menu")
	self._title:SetFont("SAFactionMenuTitle")
	self._title:SizeToContents()

	self._closeButton = vgui.Create("DButton", self)
	self._closeButton:SetText("Close")
	self._closeButton.DoClick = function(btn)
		self:Hide()
	end
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
	
	self._title.y = 2
	self._title:CenterHorizontal()
	
	self._closeButton.x = cSize
	self._closeButton:AlignBottom(2)
	self._closeButton:SetSize(w-cSize*2, cSize-4)
	
	self._innerPoly = buildPolyBox(2, 2, w-4, h-4, cSize, cSize)
	self._outerPoly = buildPolyBox(0, 0, w, h, cSize, cSize)
end

function PANEL:Show()
	self:SetVisible(true)
	local pW, pH = self:GetParent():GetSize()
	self:MoveTo(
		(pW * 0.5) - (self:GetWide() * 0.5),
		(pH * 0.5) - (self:GetTall() * 0.5),
		1,
		0,
		1
	)
	self:MakePopup()
end

function PANEL:Hide()
	self:MoveTo(ScrW(), self.y, 1, 0, 1)
	timer.Simple(1, function()
		self:SetVisible(false)
	end)
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
	return true
end

vgui.Register("DSAHelpMenu", PANEL, "EditablePanel")