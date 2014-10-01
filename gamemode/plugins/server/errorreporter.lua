local PLUGIN = Plugin("Errorreporter", {"MySQL", "Playerdata"})

local sformat = string.format
local tinsert = table.insert

local tostring = tostring

function PLUGIN:OnEnable()
	util.AddNetworkString("SAErrorReporter")
	net.Receive("SAErrorReporter", function(len, ply)
		if(ply.__SAErrorReporterBan) then
			net.ReadData(len)--purge cache
			return
		end
		if(not ply.__SAReportedErrors) then
			ply.__SAReportedErrors = 1
		else
			ply.__SAReportedErrors = ply.__SAReportedErrors + 1
		end
		if(len < 100) then
			self:Warning(
				"Ignoring unreasonable error report from player with PID:'%u' expected 100 got %u bits",
				ply.__SAPID,
				len
			)
			return--bullshit
		end
		
		local runTime = net.ReadFloat()
		local actualError = net.ReadString()
		local report = {
			os.date("!UTC: %H:%M:%S - %d.%m.%y\n"),
			sformat(
				"Server Time: %02d:%02d:%02d\n",
				math.floor(runTime/3600),
				math.floor(runTime/60) % 60,
				runTime % 60
			),
			sformat("Full error message: '%s'\n", actualError),
			sformat("File: %s\n", net.ReadString()),
			sformat("Line: %d\n\n", net.ReadUInt(32)),
		}

		local stackSize = net.ReadUInt(8)
		local stack = {}
		if(stackSize ~= 0) then
			tinsert(report, "Stack-Trace: \n")
			for i = 1, stackSize do
				tinsert(report, sformat(
					"\tLevel %d: File: %s - Function: %s - Line: %d\n",
					i,
					net.ReadString(),
					net.ReadString(),
					net.ReadUInt(32))
				)
			end
		else
			tinsert(report, "NO STACKTRACE FOUND!")
		end
		tinsert(report, "\n")
		
		local localLevels = net.ReadUInt(8)
		local locals
		if(localLevels ~= 0) then
			tinsert(report, "Locals: \n")
			for i = 1, localLevels do
				locals = net.ReadUInt(8)
				tinsert(report, sformat("\tLevel %d:\n", i))
				for k = 1, locals do
					tinsert(report, sformat("\t\t%s = %s\n", net.ReadString(), net.ReadString()))
				end
				tinsert(report, "\n")
			end
			tinsert(report, "\n")
		else
			tinsert(report, "NO LOCALS FOUND!\n")
		end

		
		local upvalueLevels = net.ReadUInt(8)
		local upvalues
		if(upvalueLevels ~= 0) then
			tinsert(report, "Upvalues: \n")
			for i = 1, upvalueLevels do
				upvalues = net.ReadUInt(8)
				tinsert(report, sformat("\tLevel %d:\n", i))
				for k = 1, upvalues do
					tinsert(report, sformat("\t\t%s = %s\n", net.ReadString(), net.ReadString()))
				end
				tinsert(report, "\n")
			end
			tinsert(report, "\n")
		else
			tinsert(report, "NO UPVALUES FOUND!\n")
		end
		
		report = SA.Plugins.MySQL:Escape(table.concat(report))
			
		SA.Plugins.MySQL:Query(
			sformat(
	[[INSERT IGNORE INTO `sa_clienterror` (`serverid`, `playerid`, `timestamp`,
	`errorcrc`, `report`) VALUES('%u', '%u', '%u', UNIX_TIMESTAMP(), CRC32('%s');]],
				SA:GetServerID(),
				ply.__SAPID,
				SA.Plugins.MySQL:Escape(actualError),
				report
			)
		)
	end)
	
	timer.Create("SAErrorSpamDetector", 5, 0, function()
		for k, v in next, player.GetAll() do
			if(v.__SAErrorReporterBan) then
				continue
			end
			if(not v.__SAReportedErrors) then
				v.__SAReportedErrors = 0
				continue
			end
			if(v.__SAErrorReporterViolations == 3) then	
				v.__SAErrorReporterBan = true
				continue
			end
			if(v.__SAReportedErrors > 5) then
				v.__SAErrorReporterViolations = v.__SAErrorReporterViolations + 1
			end
			v.__SAReportedErrors = 0
		end
	end)
end

function PLUGIN:OnDisable()
	hook.Remove("LuaError", "SAErrorLog")
	timer.Remove("SAErrorSpamDetector")
end

SA:RegisterPlugin(PLUGIN)