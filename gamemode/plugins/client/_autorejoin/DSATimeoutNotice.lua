surface.CreateFont(
	"SATimeoutNotice",
	{
		font = "neuropol",
		size = 25,
		weight = 400,
		antialias = true,
		additive = false,
	}
)
local PANEL = {}

function PANEL:Init()
	self._text = vgui.Create("DLabel", self)
	self._text:SetFont("SATimeoutNotice")
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
	self._text:Center()
	
	local cSize = (w+h)/20
	self._innerPoly = buildPolyBox(2, 2, w-4, h-4, cSize, cSize)
	self._outerPoly = buildPolyBox(0, 0, w, h, cSize, cSize)
end

function PANEL:UpdateText(msg)
	self._text:SetText(msg)
	self._text:SizeToContents()
	self._text:Center()
end

function PANEL:UpdateMessage(ticksLeft)
	if(ticksLeft == 6) then
		self:UpdateText("Server Crash Possible...")
	elseif(ticksLeft == 4) then
		self:UpdateText("Server Restarting...")
	elseif(ticksLeft == 3) then
		self._restartTime = SysTime() + 12
		self._showRestartCountDown = true
	elseif(ticksLeft == 0) then
		self._showRestartCountDown = false
		self:UpdateText("Rejoining...")
		LocalPlayer():ConCommand("retry")
	end
end

function PANEL:Think()
	if(self._showRestartCountDown) then
		self:UpdateText(
			string.format("Rejoin in: %05.2f seconds", self._restartTime-SysTime())
		)
	end
end

function PANEL:StartNotice()
	self._text:SetColor(team.GetColor(LocalPlayer():Team()))
	self:AlphaTo(255, 4, 0)
	self:SetVisible(true)
	SA.Plugins.Systimer:CreateTimer("TimeoutNotice", 8, 4, function(val)
		self:UpdateMessage(val)
	end)
	self:UpdateText("Connection Problem...")
end

local function animDone(anim, pnl)
	pnl:SetVisible(false)
end

function PANEL:EndNotice()
	self:AlphaTo(0, 1, 0, animDone)
	self._showRestartCountDown = false
	SA.Plugins.Systimer:RemoveTimer("TimeoutNotice")
	self:UpdateText("Nevermind...")
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
			
			local t = RealTime()*127.5
			surface.SetDrawColor(t%255, 0, 0, 200)
			
			surface.DrawPoly(self._innerPoly)
			
			surface.SetDrawColor(team.GetColor(lp:Team()))
			
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			surface.DrawPoly(self._outerPoly)
			
		render.SetStencilEnable(false)
	end
	return true
end

vgui.Register("DSATimeoutNotice", PANEL, "DPanel")