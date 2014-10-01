local PLUGIN = Plugin("Topbar", {
		"MySQL",
		"Playerdata"
	}
)

util.AddNetworkString("SATopBarAddMessage")
function PLUGIN:AddMessage(msg)
	SA.Plugins.MySQL:Query(
		string.format(
			"INSERT INTO `sa_topbar_message` (`message`) VALUES('%s');",
			SA.Plugins.MySQL:Escape(msg)
		)
	)
	net.Start("SATopBarAddMessage")
		net.WriteString(msg)
	net.Broadcast()--net.Send(SA.Plugins.Playerdata:GetLoadedPlayers())
end

function PLUGIN:SetWarning(msg)
	net.Start("SATopBarWarning")
		net.WriteString(msg)
	net.Broadcast()
end

function PLUGIN:SetAlert(msg)
	net.Start("SATopBarAlert")
		net.WriteString(msg)
	net.Broadcast()
end


function PLUGIN:OnEnable()
	util.AddNetworkString("SATopBarWarning")
	util.AddNetworkString("SATopBarAlert")
	util.AddNetworkString("SATopBarMessages")
	local function _messageReceive(isok, data)
		if(not isok) then
			return
		end
		self._messages = {}
		self._messageCount = #data
		for _, row in next, data do
			table.insert(self._messages, row.message)
		end
	end
	
	SA:AddEventListener("DatabaseConnect", "LoadTopBarNews", function()
		SA.Plugins.MySQL:Query("SELECT `message` FROM `sa_topbar_message`;", _messageReceive)
	end)
	
	local function _sendTopBarMessages(ply)
		SA.Plugins.MySQL:Poll()
		if(not self._messageCount) then
			return
		end
		net.Start("SATopBarMessages")
			net.WriteUInt(self._messageCount, 8)
			for i = 1, self._messageCount do
				net.WriteString(self._messages[i])
			end
		net.Send(ply)
	end
	SA:AddEventListener("PlayerLoaded", "SendTopBarMessages", _sendTopBarMessages)
end

function PLUGIN:OnDisable()
	SA:RemoveEventListener("PlayerLoaded", "SendTopbarMessages")
	SA:RemoveEventListener("DatabaseConnect", "LoadTopBarNews")
end

SA:RegisterPlugin(PLUGIN)