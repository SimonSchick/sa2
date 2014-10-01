local PLUGIN = Plugin("Globalchatlog", {
	"MySQL",
	"Playerdata"
})

function PLUGIN:SetUseBuffer(b)
	self._useBuffer = true
end

function PLUGIN:SetBufferSize(val)
	self._bufferSize = val
end

function PLUGIN:OnEnable()
	self._useBuffer = false
	self._bufferSize = 5
	
	SA:AddEventListener("GlobalChat", "GlobalChatLog", function(ply, txt, isPublic)
		if(self._useBuffer) then
			return
		end
		SA.Plugins.MySQL:Query(
			string.format(
[[INSERT INTO `sa_global_chatlog` (`playerid`, `serverid`, `text`, `timestamp`)
VALUES('%u', '%u', '%s', UNIX_TIMESTAMP());]],
				ply.__SAPID,
				SA:GetServerID(),
				SA.Plugins.MySQL:Escape(text)
			)
		)
	end)
end

function PLUGIN:OnDisable()
	SA:RemoveEventListener("GlobalChat", "GlobalChatLog")
end

SA:RegisterPlugin(PLUGIN)