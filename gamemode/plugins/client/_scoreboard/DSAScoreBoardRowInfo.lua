local PANEL = {}

function PANEL:Init()
	self._bgColor = Color(0, 255, 0, 0)
end

function PANEL:Update()
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
		a = math.min(a + 0.1/FrameTime(), 120)
	else
		a = math.max(a - 0.1/FrameTime(), 0)
	end
	self._bgColor.a = a
	draw.RoundedBoxEx(8, 0, 0, w, h, self._bgColor, true, true, true, true)
end

vgui.Register("DSAScoreBoardRowInfo", PANEL, "DPanel")