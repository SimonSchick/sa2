local PLUGIN = Plugin("Restart", {"Systimer", "Topbar"}, {"gatekeeper"})


function PLUGIN:InitiateRestart(time, lock)
	self._oldHostname = GetConVarString("hostname")
	self._oldPassword = GetConVarString("sv_password")
	if(lock) then
		RunConsoleCommand(
			"sv_password",
			string.format("%x%x",
				util.CRC(SysTime()),
				util.CRC(math.random())
			)
		)
	end
	RunConsoleCommand("hostname", 
		string.format( "%s[RESTARTING IN %u SECONDS]", self._oldHostname, time)
	)
	SA.Plugins.Systimer:CreateTimer("Restart", math.floor(time/10), 10, function(repsLeft)
		if(repsLeft == 0) then
			game.ConsoleCommand("exit\n")
			return
		end
		local str = string.format( "%s[RESTARTING IN %u SECONDS]", self._oldHostname, repsLeft*10)
		RunConsoleCommand("hostname", 
			str
		)
		SA.Plugins.Topbar:SetAlert(str)
	end)
end

function PLUGIN:AbortRestart()
	SA.Plugins.Systimer:RemoveTimer("Restart")
	RunConsoleCommand("hostname", self._oldHostname)
	RunConsoleCommand("sv_password", self._oldPassword)
	SA.Plugins.Topbar:SetAlert("")
end

function PLUGIN:OnEnable()
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)