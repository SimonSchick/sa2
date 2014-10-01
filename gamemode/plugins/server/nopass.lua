local PLUGIN = Plugin("Nopass", {"MySQL"}, {"gatekeeper"})

function PLUGIN:OnEnable()
	RunConsoleCommand("gk_force_protocol_enable", "1")
	RunConsoleCommand("gk_force_protocol", "21")
	local function _onGet(isok, data)
		if(not isok) then
			return
		end
		self._steamLookup = {
			["STEAM_0:0:18039563"] = true,--Wizard
			["STEAM_0:0:28961696"] = true,--Raklatif
			["STEAM_0:0:5394890"] = true,--Dori
			["STEAM_0:0:15553142"] = true,--Zachar
			["STEAM_0:1:19184957"] = true,--dicktron
			["STEAM_0:1:12783335"] = true
		}
		for idx, row in next, data do
			self._steamLookup[row.steamid] = true
		end
	end
	SA:AddEventListener("DatabaseConnect", "NoPass", function()
		SA.Plugins.MySQL:QueryWait(
			"SELECT IntToSteam(`steamid`) AS `steamid` FROM `sa_player` WHERE `no_pass` = '1'",
			_onGet
		)
	end)
	hook.Add("PlayerPasswordAuth", "SANoPass", function(user, pass, steam, ip)
		SA.Plugins.MySQL:Poll()
		if(self._steamLookup[steam]) then
			return true
		end
	end)
end

function PLUGIN:OnDisable()
	SA:RemoveEventListener("DatabaseConnect", "NoPass")
	hook.Remove("PlayerPasswordAuth", "SANoPass")
end

SA:RegisterPlugin(PLUGIN)