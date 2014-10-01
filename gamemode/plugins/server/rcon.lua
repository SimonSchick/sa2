local PLUGIN = Plugin("RCon", {"MySQL"}, {"rcon", "crypt"})


function PLUGIN:OnEnable()
	local function _accountsLoaded(isok, data)
		self._accounts = data
	end
	
	local function _blacklistLoaded(isok, data)
		self._cmdBlacklist = {}
		for _, v in next, data do
			table.insert(self._cmdBlacklist, data.command)
		end
	end
	
	SA:AddEventListener("DatabaseConnect", "LoadRCon", function()
		SA.Plugins.MySQL:Query(
			"SELECT `id`, `name`, `password`, `use_blacklist` as `useBlacklist` FROM `sa_rcon_account`;",
			_accountsLoaded
		)
		SA.Plugins.MySQL:Query(
			"SELECT `command` FROM `sa_rcon_command_blacklist`;",
			_blacklistLoaded
		)
	end)
	
	local authed = {}
	
	hook.Add("RCONCheckPassword", "SARCon", function(pass, ip, port)
		if(not self._accounts) then
			SA.Plugins.MySQL:Poll()
			if(not self._accounts) then
				return false
			end
		end
		if(authed[ip..":"..port]) then
			return true
		end
		local pass = crypt.sha256(pass, true)
		for i = 1, #self._accounts do
			if(pass == self._accounts[i].password) then
				authed[ip..":"..port] = self._accounts[i]
				return true
			end
		end
		return false
	end)
	
	local function tblFind(tbl, val)
		for k, v in next, tbl do
			if(val:find(v, 1, true)) then
				return true
			end
		end
		return false
	end
 
	hook.Add("RCONWriteDataRequest", "SARCon", function(id, request, data, ip, port)
		if(id == 1) then--auth channel, ignore shit
			return
		end
		if(request == 2) then--command
			local user = authed[ip..":"..port]
			if(user) then
				if(user.useBlacklist and tblFind(self._cmdBlacklist, data)) then
					return false
				end
				SA.Plugins.MySQL:Query(
					string.format(
						"INSERT INTO `sa_rcon_log` (`rconid`, `command`, `timestamp`) VALUES('%u', '%s', UNIX_TIMESTAMP());",
						user.id,
						SA.Plugins.MySQL:Escape(data)
					)
				)
				return true
			end
			return false
		end
		if(request == 3) then--auth
			--why?
		end
	end)

	hook.Add("RCON_LogCommand", "SARCon", function(msg, ip, port)
	end)
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)