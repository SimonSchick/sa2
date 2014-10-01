local PLUGIN = Plugin("Passlog", {"MySQL"}, {"gatekeeper"})


function PLUGIN:OnEnable()
	hook.Add("PlayerPasswordAuth", "SAPassLog", function(user, pass, steam, ip)
		local svPass = GetConVarString("sv_password")
		if(svPass ~= "" and pass ~= svPass) then
			SA.Plugins.MySQL:Query(
				string.format(
[[INSERT INTO `sa_passlog` (`steamid`, `pass`, `ip`, `timestamp`)
VALUES(SteamToInt('%s'), '%s', INET_ATON('%s'), UNIX_TIMESTAMP());]],
					SA.Plugins.MySQL:Escape(steam),
					SA.Plugins.MySQL:Escape(pass),
					ip:match("%d+%.%d+%.%d+%.%d+")
				)
			)
		end
	end)
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)