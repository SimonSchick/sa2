local PLUGIN = Plugin("Clientquery")

function PLUGIN:OnEnable()
	util.AddNetworkString("SAClientQuery")
	self._callbackedReceivers = {}
	self._receivers = {}
	local t = SysTime()
	net.Receive("SAClientQuery", function(len, ply)
		local nID = net.ReadUInt(16)
		local rec = self._receivers[nID]
		if(not rec) then
			self:Warning("Received unknown query id from player %q", ply:SteamID())
		else
			rec = self._callbackedReceivers[nID]
			if(t < rec[2][ply] or rec[5] and (rec[5] and rec[5](ply)) and true) then--wtf
				net.WriteUInt(0, 1)
				net.Send(ply)
				return
			end
			rec[3](ply, len-16-9*8, net.ReadString(), rec[4])
			rec[2][ply] = t + rec[1]
		end
		if(not rec[2][ply]) then
			rec[2][ply] = 0
		end
		
		net.Start("SAClientQuery")
		net.WriteUInt(nID, 16)
		net.WriteString(net.ReadString())--send back the request id without processing
		if(t < rec[2][ply] or rec[4] and (rec[4] and rec[4](ply)) and true) then--wtf
			net.WriteUInt(0, 1)
			net.Send(ply)
			return
		end
		net.WriteUInt(1, 1)
		rec[3](ply, len-16)
		net.Send(ply)
		rec[2][ply] = t + rec[1]
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAClientQuery", nil)
end

function PLUGIN:RegisterQuery(name, tbl)
	util.AddNetworkString(name)
	local id = util.NetworkStringToID(name)
	if(tbl.sender and tbl.receiver) then
		local oldSender = tbl.sender
		tbl.sender = function(token, ...)
			net.Start("SAClientQuery")
			net.WriteUInt(nID, 16)
			net.WriteString(net.ReadString(32))
			net.WriteUInt(1, 1)
			oldSender(token, ...)
			net.Send(ply)
		end
		self._callbackedReceivers[id] = {tbl.interval, {}, tbl.receiver, tbl.sender, tbl.validator}
	else
		self._receivers[id] = {tbl.interval, {}, tbl.callback, tbl.validator}
	end
end

SA:RegisterPlugin(PLUGIN)