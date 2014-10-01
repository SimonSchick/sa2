local PANEL = {}

surface.CreateFont(
	"SA2TopbarText",
	{
		font = "neuropol",
		size = 20,
		weight = 400,
		antialias = true,
		additive = false,
	}
)

function PANEL:GetText()
	return "TEXT HERE"
end

function PANEL:Init()
	surface.SetFont("SA2TopbarText")
	self.requestWidth = surface.GetTextSize(self:GetText())
end

function PANEL:Update()
	self._text = self:GetText()
end

function PANEL:Paint(w, h)
	surface.SetFont("SA2TopbarText")
	surface.SetTextColor(255, 255, 255, 255)
	local x, y = surface.GetTextSize(self._text)
	self.requestWidth = x+4
	surface.SetTextPos((w-x)/2, (h-y)/2)
	surface.DrawText(self._text)
end

function PANEL:RequestWidth()
	return self.requestWidth
end

vgui.Register("DSATopbarTextMember", PANEL, "DSATopbarMember")