include("DSAChatBoxLine.lua")

local PANEL = {}

function PANEL:Init()
	self._lines = {}
	local t = RealTime() - 1
	self._lastChat = t
	self._lastNote = t
	self._lastMentioning = t
	self._doFlashOnEvent = true
	self._backgroundColor = Color(100, 100, 100, 50)
	self._useBackgroundColor = Color(100, 100, 100, 220)
	self._drawBackground = true
	self._drawTimeStampts = true
	
	self:SetPaintBackgroundEnabled(false)
	self:SetPaintBorderEnabled(false)
	
	local textBox = vgui.Create("DPanelList", self)
	textBox:EnableVerticalScrollbar(true)
	textBox:SetSpacing(0)
	textBox:SetPadding(0)
	self._textBox = textBox
	
	local textEntry = vgui.Create("DTextEntry", self)
	textEntry:SetMultiline(false)
	textEntry.OnEnter = function(textEntry)
		LocalPlayer():ConCommand("say "..textEntry:GetText())
		textEntry:SetText("")
		self:Hide()
	end
	
	textEntry.OnChange = function(textEntry)
	end
	
	textEntry.OnKeyCode = function(textEntry, key)
		if(key == KEY_TAB) then
			local newValue = hook.Call("OnChatTab", SA, self:GetValue())
			if(newValue) then
				textEntry:SetText(newValue)
			end
		end
	end
	
	self._textEntry = textEntry
	self:SetSize(self:GetSize())
	self:InvalidateLayout(true)
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
	local tH, tH = self._textEntry:GetSize()
	
	local cSize = (w+h)/20
	
	self._textBox:SetPos(cSize/2+2, cSize/2+2)
	self._textBox:SetSize(w-cSize-4, h-cSize-4)
	
	self._textEntry:SetPos(cSize, h - tH - 2)
	self._textEntry:SetSize(w-cSize*2, 20)
	
	self._innerPoly = buildPolyBox(2, 2, w-4, h-4, cSize, cSize)
	self._outerPoly = buildPolyBox(0, 0, w, h, cSize, cSize)
end

function PANEL:SetShowTimeStamps(b)
	self._drawTimeStamps = b
end

function PANEL:OnTab()
end

function PANEL:Show()
	self._isOpen = true
	self:SetVisible(true)
	self:AlphaTo(255, 0.2, 0)
	self._textEntry:SetVisible(true)
	self._textEntry:RequestFocus()
	self:MakePopup()
	timer.Remove("SAChatBoxHide")
	timer.Remove("SAChatBoxFadeOut")
end

function PANEL:Hide()
	self._isOpen = false
	self:AlphaTo(0, 0.2, 0)
	self:KillFocus()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
	gui.EnableScreenClicker(false)
	timer.Create("SAChatBoxHide", 0.2, 1, function() self:SetVisible(false) end)
end

function PANEL:Popup(time)
	if(self._isOpen) then
		return
	end

	self._textEntry:SetVisible(false)
	self:SetVisible(true)
	self:AlphaTo(240, 0.5, 0)
	timer.Create("SAChatBoxFadeOut", time-0.5, 1, function() self:AlphaTo(0, 0.5, 0) end)
	timer.Create("SAChatBoxHide", time, 1, function() self:Hide() end)
end

function PANEL:PushPanel(pnl)
	table.insert(self._lines, pnl)
	self._textBox:AddItem(pnl)
	
	pnl:InvalidateLayout(true)
	self._textBox:InvalidateLayout(true)
	self:InvalidateLayout(true)
	
	self._textBox:ScrollToChild(pnl)
end

function PANEL:PushLine(line)
	line:SetShowTimeStamps(self._drawTimeStamps)
	self:PushPanel(line)
end

function PANEL:AddChatLine(ply, text, isTeamChat, isPlayerDead)
	local newLine = vgui.Create("DSAChatBoxLine")
	newLine:SetPlayer(ply)
	if(text:find(LocalPlayer():GetName(), 1, true)) then
		newLine:SetBackgroundColor(Color(255, 0, 0, 255))
	end
	newLine:SetText(text)
	self:PushLine(newLine)
end

function PANEL:AddNotify(txt)
	local newLine = vgui.Create("DSAChatBoxLine", self)
	newLine:SetText(txt)
	newLine:SetBackgroundColor(Color(0, 0, 255, 255))
	self:PushLine(newLine)
end

function PANEL:AddYoutube(vidID)
	local html = vgui.Create("HTML")
	html:SetHTML(
[[<html>
<body marginwidth="0" marginheight="0" style="background-color: rgb(38,38,38)">
	<embed width="100%" height="100%" name="plugin" src="http://youtube.googleapis.com/v/]]
	..vidID..
	[[" type="application/x-shockwave-flash">
</body>
</html>]]
	)
	html:SetSize(200, 200)
	self:PushPanel(html)
end

function PANEL:AddLine(...)--numbers, strings, colors, players
	local newLine = vgui.Create("DSAChatBoxLine", self)
	newLine:SetText(...)
	self:PushLine(newLine)
end

function PANEL:AddBBCodeLine(...)
	local newLine = vgui.Create("DSAChatBoxLine", self)
	newLine:SetBBCodeText(...)
	self:PushLine(newLine)
end

function PANEL:SetBackgroundColor(col)
	self._backgroundColor = col
end

function PANEL:SetFlashOnEvent(b)
	self._doFlashOnEvent = b
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
			
			local t = RealTime()
			if(self._doFlashOnEvent) then
				if(self._lastChat+2 >= t) then
					surface.SetDrawColor(255, 255, 0, math.min(255 - (t - self._lastChat)*127.5, 100))
				elseif(self._lastNote+2 >= t) then
					surface.SetDrawColor(0, 0, 255, math.min(255 - (t - self._lastNote)*127.5, 100))
				elseif(self._lastMentioning+2 >= t) then
					surface.SetDrawColor(255, 0, 0, math.min(255 - (t - self._lastMentioning)*127.5, 100))
				elseif(self._isOpen) then
					surface.SetDrawColor(self._useBackgroundColor)
				else
					surface.SetDrawColor(self._backgroundColor)
				end
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

vgui.Register("DSAChatBox", PANEL ,"EditablePanel")