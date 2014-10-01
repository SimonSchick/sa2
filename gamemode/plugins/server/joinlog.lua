local PLUGIN = Plugin("Joinlog", {"MySQL", "Playerdata"})

function PLUGIN:OnEnable()
	SA:AddEventListener("PlayerLoaded", "JoinLog", function(ply)
		if(ply:IsBot()) then
			SA.Plugins.MySQL:Query(
				string.format(
[[INSERT INTO `sa_player_join` (`playerid`, `ip`, `timestamp`)
VALUES('%u', INET_ATON('%s'), UNIX_TIMESTAMP());]],
					ply.__SAPID,
					"0.0.0.0"
				)
			)
			return
		end
		SA.Plugins.MySQL:Query(
			string.format(
[[INSERT INTO `sa_player_join` (`playerid`, `ip`, `timestamp`)
VALUES('%u', INET_ATON('%s'), UNIX_TIMESTAMP());]],
				ply.__SAPID,
				ply:IPAddress():match("%d+%.%d+%.%d+%.%d+")
			)
		)
	end)
end

function PLUGIN:OnDisable()
	SA:RemoveEventListener("PlayerLoaded", "JoinLog")
end

SA:RegisterPlugin(PLUGIN)
