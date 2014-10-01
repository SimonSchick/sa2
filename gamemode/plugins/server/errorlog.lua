local PLUGIN = Plugin("Errorlog", {"MySQL"})

local sformat = string.format
local tinsert = table.insert
local tostring = tostring

function PLUGIN:OnEnable()
	hook.Add("LuaError", "SAErrorLog", function(err, file, line, stack, locals, upvalues)
		if(err ~= true) then
			
			local runTime = CurTime()
		
			local report = {
				os.date("!UTC: %H:%M:%S - %d.%m.%y\n"),
				sformat(
					"Server Time: %02d:%02d:%02d\n",
					math.floor(runTime/3600),
					math.floor(runTime/60) % 60,
					runTime % 60
				),
				sformat("Full error message: '%s'\n", err),
				sformat("File: %s\n", file),
				sformat("Line: %d\n", line)
			}
			if(#stack ~= 0) then
				tinsert(report, "Stack-Trace: \n")
				for i = 1, #stack do
					tinsert(
						report, sformat("\tLevel %d: File: %s - Function: %s - Line: %d\n",
						i, stack[i][1], stack[i][2], stack[i][3])
					)
				end
			else
				tinsert(report, "NO STACKTRACE FOUND!")
			end
			tinsert(report, "\n")
			
			
			if(#locals ~= 0) then
				tinsert(report, "Locals: \n")
				for i = 1, #locals do
					tinsert(report, sformat("\tLevel %d:\n", i))
					for k, v in next, locals[i] do
						tinsert(report, sformat("\t\t%s = %s\n", tostring(k), tostring(v)))
					end
					tinsert(report, "\n")
				end
				tinsert(report, "\n")
			else
				tinsert(report, "NO LOCALS FOUND!\n")
			end
			
			if(#upvalues ~= 0) then
				tinsert(report, "Upvalues: \n")
				for i = 1, #upvalues do
					tinsert(report, sformat("\tLevel %d:\n", i))
					for k, v in next, upvalues[i] do
						tinsert(report, sformat("\t\t%s = %s\n", tostring(k), tostring(v)))
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
[[INSERT IGNORE INTO `sa_servererror` (`serverid`, `timestamp`, `errorcrc`,
`report`) VALUES('%u', UNIX_TIMESTAMP(), CRC32('%s'), '%s');]],
					SA:GetServerID(),
					SA.Plugins.MySQL:Escape(err),
					report
				)
			)
		end
	end)
end

function PLUGIN:OnDisable()
	hook.Remove("LuaError", "SAErrorLog")
end

SA:RegisterPlugin(PLUGIN)