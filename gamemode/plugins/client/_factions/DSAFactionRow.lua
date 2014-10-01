surface.CreateFont(
	"SAFactionRow",
	{
		font = "neuropol",
		size = 25,
		weight = 300,
		antialias = true,
		additive = false,
	}
)
local PANEL = {}

function PANEL:Init()
	self._bgColor = Color(0, 0, 0, 255)
	
	self._factionName = vgui.Create("DLabel", self)
	self._factionName:SetFont("SAFactionRow")
	
	self._memberCount = vgui.Create("DLabel", self)
	self._memberCount:SetFont("SAFactionRow")
end

function PANEL:PerformLayout()
	self._factionName:SetPos(4, 4)
	self._memberCount.y = 4
	self._memberCount:AlignRight(4)
end

function PANEL:SetFaction(factionID)
	local ref = team.GetAllTeams()[factionID]
	self._bgColor.r = ref.Color.r
	self._bgColor.g = ref.Color.g
	self._bgColor.b = ref.Color.b
	
	self._factionName:SetText(ref.Name)
	self._factionName:SizeToContents()
	
	self._memberCount:SetText(tostring(SA.Plugins.Factions:GetMemberCount(factionID)))
	self._memberCount:SizeToContents()
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
	
	self._bgColor.a = a + 200
	draw.RoundedBoxEx(8, 0, 0, w, h, self._bgColor, true, true, true, true)
	self._bgColor.a = oldA
	return true
end

vgui.Register("DSAFactionRow", PANEL, "DPanel")