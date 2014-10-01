local PLUGIN = Plugin("Clientquery", {})


local activeRequests = {}
local permaRequests = {}
function PLUGIN:OnEnable()
	self._receivers = {}
	local t = SysTime()
	net.Receive("SAClientQuery", function(len)
		local id = net.ReadUInt(16)
		local ident = net.ReadString()
		local succ = net.ReadUInt(1) == 1
		if(permaRequests[id]) then
			if(succ) then
				permaRequests[id](len-16-9*8)
				return
			end
			permaRequests[id](false)
			return
		end
		local req = activeRequests[id][ident]
		if(not req) then
			self:Error("Received unknown identifier for request id: %s", util.NetworkIDToString(id))
		end
		if(succ) then
			activeRequests[id][ident](len-16-9*8)
			return
		end
		activeRequests[id][ident](false)
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAClientQuery", nil)
end

function PLUGIN:AddPermHandler(name, callback)
	permaRequests[util.NetworkStringToID(name)] = callback
end

local currReq = false
function PLUGIN:StartRequest(name, isPerma, callback)
	if(currReq) then
		self:Error("Attempted to launch a new query without completing the previous one(%q)", name)
		return
	end
	local currReq = util.NetworkStringToID(name)
	local ident = string.format("%x", util.CRC(SysTime()*math.random()))
	if(not activeRequests[currReq]) then
		activeRequests[currReq] = {[ident] = callback}
	else
		activeRequests[currReq][ident] = callback
	end
	net.Start("SAClientQuery")
		net.WriteUInt(currReq, 16)
		net.WriteString(ident)
end

function PLUGIN:DispatchRequest()
	net.SendToServer()
	currReq = nil
end

SA:RegisterPlugin(PLUGIN)