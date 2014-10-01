include("DSAScoreBoardRowInfo.lua")

surface.CreateFont(
	"SAScoreBoardRowText",
	{
		font = "neuropol",
		size = 32,
		weight = 400,
		antialias = true,
		additive = false,
	}
)

local PANEL = {}

function PANEL:Init()
	self._bgColor = Color(0, 0, 0, 0)
	
	self._avatarImg = vgui.Create("AvatarImage", self)
	self._avatarImg:SetSize(32, 32)
	
	self._playerName = vgui.Create("DLabel", self)
	self._playerName:SetFont("SAScoreBoardRowText")
	
	self._factionName = vgui.Create("DLabel", self)
	self._factionName:SetFont("SAScoreBoardRowText")
	
	self._playTime = vgui.Create("DLabel", self)
	self._playTime:SetFont("SAScoreBoardRowText")
	
	self._ping = vgui.Create("DLabel", self)
	self._ping:SetFont("SAScoreBoardRowText")
	
	self._infoCard = vgui.Create("DSAScoreBoardRowInfo", self)
	self._infoCard:SetVisible(false)
	
	self._rowStep = 0
end

function PANEL:Expand()
	self._isExpanded = true
	self:SizeTo(self:GetWide(), 148, 0.25, 0, 1)
	self._infoCard:Update()
	self._infoCard:SetVisible(true)
end

function PANEL:SetRowStep(v)
	self._rowStep = v
end

function PANEL:Collapse()
	self._isExpanded = false
	self:SizeTo(self:GetWide(), 48, 0.25, 0, 1)
	self._infoCard:SetVisible(false)
end

function PANEL:Toggle()
	if(self._isExpanded) then
		self:Collapse()
		return
	end
	self:Expand()
end

function PANEL:OnMousePressed(key)
end

function PANEL:OnMouseReleased(key)
	self:Toggle()
end

function PANEL:PerformLayout()
	self._avatarImg:SetPos(8, 8)
	
	self._playerName.y = 8
	self._playerName:MoveRightOf(self._avatarImg, 4)
	
	self._factionName.y = 8
	self._factionName.x = 300
	
	self._playTime.y = 8
	self._playTime:AlignRight(150)
	
	self._ping.y = 8
	self._ping:AlignRight(8)
	
	self._infoCard:StretchToParent(2, 48, 2, 2)
end

function PANEL:Update()
	self._ping:SetText(tostring(self._ply:Ping()))
	self._ping:SizeToContents()
	self._ping:AlignRight(6)
	local teamRef = team.GetAllTeams()[self._ply:Team()]
	if(teamRef) then
		self._factionName:SetText(teamRef.Name)
		self._factionName:SizeToContents()
		
		self._bgColor.r = teamRef.Color.r
		self._bgColor.g = teamRef.Color.g
		self._bgColor.b = teamRef.Color.b
	end
	
	self._playTime:SetText(SA.Plugins.Playtime:GetPlaytimeString(self._ply))
	self._playTime:SizeToContents()
end

function PANEL:GetPlayer()
	return self._ply
end

function PANEL:SetPlayer(ply)
	self._ply = ply
	self._avatarImg:SetPlayer(ply)
	self._infoCard:SetPlayer(ply)
	self._playerName:SetText(ply:SAGetCleanName())
	self._playerName:SizeToContents()
	self:Update()
end

function PANEL:OnCursorEntered()
	self._hovered = true
end

function PANEL:OnCursorExited()
	self._hovered = false
end

function PANEL:Paint(w, h)
	local a = self._bgColor.a
	if(self._hovered) then
		a = math.min(a + 0.025/FrameTime(), 55)
	else
		a = math.max(a - 0.025/FrameTime(), 0)
	end
	local oldA = a
	
	self._bgColor.a = a + (math.sin(math.rad((RealTime()+self._rowStep)*90))+1)*50+100
	draw.RoundedBoxEx(8, 0, 0, w, h, self._bgColor, true, true, true, true)
	self._bgColor.a = oldA
end

vgui.Register("DSAScoreBoardRow", PANEL, "DPanel")