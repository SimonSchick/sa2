local PLUGIN = Plugin("Autorejoin", {})

function PLUGIN:OnEnable()
	include(SA.Folder:sub(11).."/gamemode/plugins/client/_autorejoin/DSATimeoutNotice.lua")
	local notice = vgui.Create("DSATimeoutNotice")
	
	notice:SetSize(350, 120)
	notice:Center()
	notice:SetVisible(false)
	self._noticePanel = notice
	self._isTimingOut = false
	net.Receive("SAHeartBeat", function()
		self._lastBeat = SysTime()
		SA.Plugins.Systimer:SetNextInterval("AutoRejoin", 5)
		if(self._isTimingOut) then
			notice:EndNotice()
			self._isTimingOut = false
		end
	end)
	SA.Plugins.Systimer:CreateTimer("AutoRejoin", 0, 6, function()
		if(not self._isTimingOut) then
			notice:StartNotice()
			self._isTimingOut = true
		end
	end)
end

function PLUGIN:OnDisable()
	self._noticePanel:Remove()
	SA.Plugins.Systimer:RemoveTimer("AutoRejoin")
end

SA:RegisterPlugin(PLUGIN)