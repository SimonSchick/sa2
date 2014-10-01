surface.CreateFont(
	"SALoginPanelTitle",
	{
		font = "neuropol",
		size = 18,
		weight = 400,
		antialias = true,
		additive = false,
	}
)
local PANEL = {}

function PANEL:Init()
	self._title = vgui.Create("DLabel", self)
	self._title:SetFont("SALoginPanelTitle")
	self._title:SetText("Login Required")
	self._title:SizeToContents()
	
	self._statusLabel = vgui.Create("DLabel", self)
	self._statusLabel:SetFont("SALoginPanelTitle")
	
	self._textEntry = vgui.Create("DTextEntry", self)
	self._textEntry.OnEnter = function(txtEntry)
		SA.Plugins.Clientsecurity:TryLogin(txtEntry:GetValue())
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
	self._title:CenterHorizontal()
	
	self._textEntry:SetWide(w-6)
	self._textEntry:Center()
	
	self._statusLabel:AlignBottom(0)
	self._statusLabel:CenterHorizontal()
	
	local cSize = (w+h)/20
	self._innerPoly = buildPolyBox(2, 2, w-4, h-4, cSize, cSize)
	self._outerPoly = buildPolyBox(0, 0, w, h, cSize, cSize)
end

function PANEL:SetCookieLoginEnabled(b)
	self._textEntry:SetEditable(false)
end

function PANEL:SetTimeout(time)
	self._showCountDown = true
	self._timeOutTime = SysTime() + time
	self._statusLabel:SetVisible(true)
	self._statusLabel:SetColor(Color(255, 0, 0, 255))
end

function PANEL:SetAttemptsLeft(attempts)
	self._attemptsLeft = count
end

function PANEL:SetSuccess(b)
	self._successfull = b
end

function PANEL:Think()
	if(self._showCountDown) then
		self._statusLabel:SetText(
			string.format(
				"Time left: %06.2f seconds",
				self._timeOutTime - SysTime()
			)
		)
		self._statusLabel:SizeToContents()
		self._statusLabel:CenterHorizontal()
	end
end

function PANEL:Show()
	self:SetVisible(true)
	self:MoveTo(50, self.y, 1, 0, 1)
	self._title:SetColor(team.GetColor(LocalPlayer():Team()))
	gui.EnableScreenClicker(true)
	self:MakePopup()
	self._textEntry:RequestFocus()
end

function PANEL:Hide()
	self:MoveTo(-self:GetWide(), self.y, 1, 0, 1)
	timer.Simple(1, function()
		self:SetVisible(false)
	end)
	self._showCountDown = false
	self._statusLabel:SetColor(Color(0, 0, 255, 255))
	self._statusLabel:SetText("Login successful")
	self._statusLabel:SizeToContents()
	self._statusLabel:CenterHorizontal()
	gui.EnableScreenClicker(false)
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
			
			if(self._successfull) then
				surface.SetDrawColor(0, 255, 0, 200)
			else
				surface.SetDrawColor(0, 0, (RealTime()*127.5)%255, 200)
			end
			
			surface.DrawPoly(self._innerPoly)
			
			surface.SetDrawColor(team.GetColor(lp:Team()))
			
			render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
			render.SetStencilFailOperation(STENCILOPERATION_KEEP)
			surface.DrawPoly(self._outerPoly)
			
		render.SetStencilEnable(false)
	end
	return true
end

vgui.Register("DSALoginPanel", PANEL, "EditablePanel")