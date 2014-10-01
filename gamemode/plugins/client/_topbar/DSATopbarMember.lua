local PANEL = {}

function PANEL:Init()
	self.requestWidth = 0
end

function PANEL:RequestWidth()
	return self.requestWidth
end

function PANEL:ModifyBorderColor(r, g, b)
	return r, g, b
end

vgui.Register("DSATopbarMember", PANEL, "DPanel")