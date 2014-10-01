local PLUGIN = Plugin("Errorreporter", {"Config"})

PLUGIN._errorCache = {}
PLUGIN._errorQueue = {}

PLUGIN._allowedAlways = false
PLUGIN._allowedSession = false
PLUGIN._allowedOnce = false

PLUGIN._userWasAsked = false
PLUGIN._userIsBeingAsked = false

PLUGIN._reportQueueActive = false

PLUGIN.ReportAlways = 0
PLUGIN.ReportSession = 1
PLUGIN.ReportOnce = 2
PLUGIN.ReportNever = 3

function PLUGIN:OnEnable()
	sql.Query("CREATE TABLE IF NOT EXISTS `SAErrorReporter` (hashint INT NOT NULL PRIMARY KEY)")
	
	local PANEL = {}
	
	function PANEL:Init()
		local title = vgui.Create("DLabel", self)
		title:SetText("An error has occured,\nwhat would you like to do?")
		title:SizeToContents()
		self._title = title
		
		local allowAlways = vgui.Create("DButton", self)
		allowAlways:SetText("Allow always")
		allowAlways:SetSize(120, 30)
		allowAlways.DoClick = function(btn)
			PLUGIN:SetErrorReporting(PLUGIN.ReportAlways)
			PLUGIN:EndGetUserAgreement()
		end
		self._allowAlways = allowAlways
		
		
		local allowSession = vgui.Create("DButton", self)
		allowSession:SetText("Allow for this session")
		allowSession:SetSize(120, 30)
		allowSession.DoClick = function(btn)
			PLUGIN:SetErrorReporting(PLUGIN.ReportSession)
			PLUGIN:EndGetUserAgreement()
		end
		self._allowSession = allowSession
		
		local allowOnce = vgui.Create("DButton", self)
		allowOnce:SetText("Allow once")
		allowOnce:SetSize(120, 30)
		allowOnce.DoClick = function(btn)
			PLUGIN:SetErrorReporting(PLUGIN.ReportOnce)
			PLUGIN:EndGetUserAgreement(true)
		end
		self._allowOnce = allowOnce
		
		local allowNever = vgui.Create("DButton", self)
		allowNever:SetText("Never allow")
		allowNever:SetSize(120, 30)
		allowNever.DoClick = function(btn)
			PLUGIN:SetErrorReporting(PLUGIN.ReportNever)
			PLUGIN:EndGetUserAgreement()
		end
		self._allowNever = allowNever
	end
	
	function PANEL:PerformLayout()
		self._title:SetPos(0, 5)
		self._title:CenterHorizontal()
		
		self._allowAlways:MoveBelow(self._title, 5)
		self._allowAlways:CenterHorizontal()
		
		self._allowSession:CopyPos(self._allowAlways)
		self._allowSession:MoveBelow(self._allowAlways, 5)
		
		self._allowOnce:CopyPos(self._allowSession)
		self._allowOnce:MoveBelow(self._allowSession, 5)
		
		self._allowNever:CopyPos(self._allowOnce)
		self._allowNever:MoveBelow(self._allowOnce, 5)
	end
	
	vgui.Register("SAErrorReporterAgreementGetter", PANEL, "Panel")
	
	
	local PANEL = {}
	
	function PANEL:Init()
		local title = vgui.Create("DLabel", self)
		title:SetText("SpaceAge Error Reporter")
		title:SizeToContents()
		self._title = title
		
		local msg = vgui.Create("DLabel", self)
		msg:SetText("")
		self._msg = msg
		
		local agreementGetter = vgui.Create("SAErrorReporterAgreementGetter", self)
		agreementGetter:SetVisible(false)
		agreementGetter:SetPos(-200, 100)
		self._agreementGetter = agreementGetter
	end
	
	function PANEL:PerformLayout()
		self._title:SetPos(0, 5)
		self._title:CenterHorizontal()
		
		self._msg:CopyPos(self._title)
		self._msg:MoveBelow(self._msg, 5)
	end
	
	function PANEL:EnableAgreementGetter()
		self._agreementGetter:SetVisible(true)
		local w, h = self:GetSize()
		
		self._agreementGetter:StretchToParent(2, 55, 2, 2)
		self._agreementGetter:SetPos(0, h + 1)
		
		self._agreementGetter:CenterHorizontal()
		local getterX, getterY = self._agreementGetter:GetPos()
		self._agreementGetter:MoveTo(getterX, 55, 2, 0, 1)
	end
	
	function PANEL:DisableAgreementGetter()
		self:MoveOffScreen()
		local x, y = self._agreementGetter:GetPos()
		local w, h = self:GetSize()
		self._agreementGetter:MoveTo(x, h+1, 2, 0, 1)
		timer.Simple(2.1, function() self._agreementGetter:SetVisible(false) end)
		PLUGIN:SetErrorQueueEnabled(false)
	end
	
	
	function PANEL:MoveOnScreen()
		self:SetVisible(true)
		local w, h = self:GetSize()
		self:SetPos(-w-1, 100)
		self:MoveTo(2, 100, 1, 0, 2)
		self:MakePopup()
	end
	
	function PANEL:MoveOffScreen()
		local w, h = self:GetSize()
		self:MoveTo(-w-1, 100, 1, 0, 2)
		timer.Simple(2.1, function() self:SetVisible(false) end)
	end
	
	function PANEL:Paint(w, h)
		local col = (math.sin(RealTime())+1)*122.5
		surface.SetDrawColor(col, col, 0 , 200)
		surface.DrawRect(0, 0, w, h)
	end
	
	vgui.Register("DSAErrorReporter", PANEL, "EditablePanel")
	
	
	self._menu = vgui.Create("DSAErrorReporter")
	self._menu:SetSize(150, 400)
	self._menu:SetVisible(false)
	
	
	local count = tonumber(
		sql.Query("SELECT COUNT(hashint) as count FROM `SAErrorReporter`")[1].count
	)
	if(count > 100000) then
		timer.Simple(4, function()
			MsgC(Color(255, 255, 255, 255), "CLEAR UR ERROR CACHE U FUCKR!\n")
		end)
	end
	local tbl = sql.Query("SELECT `hashint` FROM `SAErrorReporter`")
	local len
	if(not tbl) then
		len = 0
	else
		len = #tbl
	end
	
	local tonumber = tonumber
	for i = 1, len do
		self._errorCache[i] = tonumber(tbl[i])
	end
	
	--TODO ASK CLIENT FOR PERMISSION
	hook.Add("LuaError", "SAErrorReporter", function(err, line, file, stack, locals, upvalues)
		if(self._reportQueueActive) then--queue is active
			table.insert(self._errorQueue, {err, line, file, stack, locals, upvalues})
			return
		elseif(not self._userWasAsked and not self._userIsBeingAsked) then--user was not asked yet
			table.insert(self._errorQueue, {err, line, file, stack, locals, upvalues})--push current error
			self:StartGetUserAgreement()
			return
		elseif(self._userWasAsked and not (self._allowedAlways or self._allowedSession)) then--user denied previous request
			return
		end
		self:SendError(err, line, file, stack, locals, upvalues)
	end)
	
	timer.Create("SAErrorReporterDequeue", 1, 0, function()
		if(	not self._reportQueueActive and
			#self._errorQueue ~= 0 and
			(self._allowedAlways or self._allowedSession or self._allowedOnce)) then
			self._allowedOnce = false
			self:SendQueuedError()
		end
	end)
end

function PLUGIN:StartGetUserAgreement()
	self._menu:EnableAgreementGetter()
	self._menu:MoveOnScreen()
	self:SetErrorQueueEnabled(true)
	self._userIsBeingAsked = true
end

function PLUGIN:EndGetUserAgreement(isOnce)
	self._menu:DisableAgreementGetter()
	self._menu:MoveOffScreen()
	self:SetErrorQueueEnabled(false)
	self._userIsBeingAsked = false
	if(not isOnce) then
		self._userWasAsked = true
	end
end

function PLUGIN:OnDisable()
	self._menu:Remove()
	hook.Remove("LuaError", "SAErrorReporter")
	timer.Remove("SAErrorReporterDequeue")
	self._errorCache = nil
end

function PLUGIN:SendQueuedError()
	self:SendError(unpack(table.remove(self._errorQueue, 1)))
end

function PLUGIN:SendError(err, file, line, stack, locals, upvalues)
	local crc = util.CRC(err)
	if(not self._errorCache[crc]) then
		sql.Query(string.format("INSERT INTO `SAErrorReporter` (hashint) VALUES('%i')", crc))
		
		net.Start("SAErrorReporter")
			
			net.WriteFloat(CurTime())
			
			net.WriteString(err)
			net.WriteString(file)
			net.WriteUInt(line, 32)
			
			net.WriteUInt(#stack, 8)
			for i = 1, #stack do
				net.WriteString(stack[i][1])
				net.WriteString(stack[i][2])
				net.WriteUInt(stack[3][1], 32)
			end
			
			net.WriteUInt(#locals, 8)
			for i = 1, #locals do
				net.WriteUInt(table.Count(locals[i]), 8)
				for k, v in next, locals[i] do
					net.WriteString(tostring(k))
					net.WriteString(tostring(v))
				end
			end
			
			net.WriteUInt(#upvalues, 8)
			for i = 1, #upvalues do
				for k, v in next, upvalues[i] do
					net.WriteUInt(table.Count(upvalues[i]), 8)
					net.WriteString(tostring(k))
					net.WriteString(tostring(v))
				end
			end
		net.SendToServer()
	end
end

function PLUGIN:ClearErrorCache()
	self._errorCache = {}
	sql.Query("DELETE FROM `SAErrorReporter`")
end

function PLUGIN:SetErrorReporting(num)
	if(num == self.ReportAlways) then
		self._allowedAlways = true
		self._allowedSession = false
		self._allowedOnce = false
		SA.Plugins.Config:Set("error_reporting", "1")
	elseif(num == self.ReportSession) then
		self._allowedAlways = false
		self._allowedSession = true
		self._allowedOnce = false
	elseif(num == self.ReportOnce) then
		self._allowedAlways = false
		self._allowedSession = false
		self._allowedOnce = true
		self:SendError(unpack(table.remove(self._errorQueue, 1)))
	elseif(num == self.ReportNever) then
		self._allowedAlways = false
		self._allowedSession = false
		self._allowedOnce = false
	end
end

function PLUGIN:SetErrorQueueEnabled(b)
	self._reportQueueActive = b
end

SA:RegisterPlugin(PLUGIN)