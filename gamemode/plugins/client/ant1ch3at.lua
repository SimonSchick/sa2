local PLUGIN = Plugin("Anticheat", {"Playerdata"})

local debug = debug

local needed = {
	"gethook",
	"getinfo",
	"getlocal",
	"setlocal",
	"getupvalue",
	"setupvalue",
	"setfenv",
	"getfenv",
	"setmetatable",
	"getmetatable",
	"traceback"
}

local function testNeeded()
	for _, v in next, needed do
		if(not debug[k]) then
			return missing
		end
	end
end

local testUpValue1, testUpValue2 = "SKLJGKJDF", "51356in"
local function _checkDebugLib()
	if(not debug) then
		return "missing"
	end
	local a = testNeeded()
	if(a) then return a end
	
	local func, mask, count = debug.gethook()
	if(not func == "external hook" or
		mask ~= "" or
		count ~= 500000000) then
		return "gethook"
	end
	local infTbl = debug.getinfo(1)
	if(infTbl.nups ~= 0 or
		infTbl.what ~= "main" or
		infTbl.func ~= _checkDebugLib or
		--infTbl.lastlinedefined ~= INSERT LAST LINE OF CODE HERE
		infTbl.source ~= "@gamemodes\spaceage2\gamemode\plugins\server\ant1ch3at.lua" or
		infTbl.currentline ~= 46 or
		infTbl.namewhat ~= "" or
		infTbl.linedefined ~= 0 or
		infTbl.short_src ~= "gamemodes\spaceage2\gamemode\plugins\server\ant1ch3at.lua") then
		return "getinfo"
	end
	
	
	
	local function localTestFunc()
		local lTestValueA, lTestValueB = "auoibf", 654145
		local n1, v1 = debug.getlocal(1, 1)
		local n2, v2 = debug.getlocal(1, 2)
		if((n1 ~= "lTestValueA" or v1 ~= "auoibf") or
			n2 ~= "lTestValueB" or v1 ~= "654145") then
			return "getlocal"
		end
		debug.setlocal(1, 1, "SAKJDBG")
		debug.setlocal(1, 2, "fgsaedf")
		if(lTestValueA ~= "SAKJDBG" or lTestValueB ~= "fgsaedf") then
			return "setlocal"
		end
	end
	local res = localTestFunc()
	if(res) then
		return res
	end
	
	local got1, got2 = false, false
	for i = 1, 30 do--max upvalues
		k, v = debug.getupvalue(_checkDebugLib, i)
		if(k == "testUpValue1" and v == "SKLJGKJDF") then
			got1 = true
			debug.setupvalue(_checkDebugLib, i, "IT WORKS")
			if(testUpValue1 ~= "IT WORKS") then
				return "setupvalue"
			end
		elseif(k == "testUpValue2" and v == "51356in") then
			got2 = true
			debug.setupvalue(_checkDebugLib, i, "IT WORKS")
			if(testUpValue2 ~= "IT WORKS") then
				return "setupvalue"
			end
		end
		
		if(not k and not (got1 and got2)) then
			return "getupvalue"
		elseif(got1 and got2) then
			break
		end
	end
	
	--setfenv func test
	local function setfenvFuncTest()
		print("THIS SHOULD NOT HAPPEN!")
	end
	local ok, err = pcall(debug.setfenv(setfenvFuncTest, {}))
	if(ok) then
		return "setfenv"
	elseif(err ~= "gamemodes\spaceage2\gamemode\plugins\server\ant1ch3at.lua:1: attempt to call global 'print' (a nil value)") then
		return "setfenv"
	end
	
	local function setHookTest()
		--be useless
	end
	debug.sethook(setHookTest, "crl", 5000)
	local func, mask, count = debug.gethook()
	if(func ~= setHookTest or mask ~= "crl" or count ~= 5000) then
		return "sethook"
	end
	Msg(" ")--restore inf loop detect
	
	
	if(debug.traceback() ~= 
[[STACKTRACE HERE
]]) then
		return "traceback"
	end
	
	local testRef = {}
	debug.setmetatable(_G, testRef)
	if(debug.getmetatable(_G) ~= testRef) then
		return "setmetatable"
	end
	debug.setmetatable(_G, nil)
end

local function _fEnvCheck()
	local function setFEnvCheck()
		setfenv(1, {})
		print("THIS SHOULD NOT HAPPEN!")
	end
	local res, err = pcall(setFEnvCheck)
	if(res == true) then
		return false
	end
end

local function _Gcheck()
	if(table.Count(_G) ~= 42) then
		return "count"
	end
	if(debug.getmetatable(_G)) then
		return "metatable"
	end
end

local function _hookCheck()
	local k, v = debug.getupvalue(hook.Add, 1)
	local hookTbl = hook.GetTable()
	if(k ~= "Hooks") then
		return "hookaddwrongupvalue"
	end
	if(hookTbl ~= v) then
		return "hooktablenothookcalltable"
	end
	k, v = debug.getupvalue(hook.Add, 2)
	if(k or v) then
		return "hookaddtoomanyups"
	end
	
	k, v = debug.getupvalue(hook.Call, 1)
	if(k ~= "Hooks") then
		return "hookaddwrongupvalue"
	end
	if(hookTbl ~= v) then
		return "hooktablenothookcalltable"
	end
	k, v = debug.getupvalue(hook.Call, 2)
	if(k or v) then
		return "hookaddtoomanyups"
	end
	
	k, v = debug.getupvalue(hook.Remove, 1)
	if(k ~= "Hooks") then
		return "hookremovewrongupvalue"
	end
	if(hookTbl ~= v) then
		return "hooktablenothookremovetable"
	end
	k, v = debug.getupvalue(hook.Remove, 2)
	if(k or v) then
		return "hookremovetoomanyups"
	end
	
	for k, v in next, hook.GetTable() do
		if(not hookWhitelist[k]) then
			return "unknownhook"
		end
		for hookName, func in next, v do 
			if(not hookNameWhitelist[hookName]) then
				return "unknownhookname"
			end
		end
	end
end

local function _timerCheck()
	--[[timer.Destroy
	timer.Simple
	timer.Adjust
	timer.UnPause
	timer.Create
	timer.Check
	timer.IsTimer
	timer.Remove
	timer.Stop
	timer.Start
	timer.Pause
	timer.Toggle]]
end

local function _cvarCheck()
end

local cvarCallbackWhitelist = {
}

local function _cvarsCheck()--the library not cvars
	local k, v = debug.getupvalue(cvars.GetConVarCallbacks, 1)
	if(k ~= "ConVars") then
		return "getconvarcallbackswronguplvaue"
	end
	k, v = debug.getupvalue(cvars.GetConVarCallbacks, 2)
	if(k or v) then
		return "getconvarcallbackstoomanyupvalues"
	end
	
	k, v = debug.getupvalue(cvars.OnConVarChanged, 1)
	if(k ~= "pairs" or v ~= pairs) then
		return "conconvarchangedwrongupvalue"
	end
	k, v = debug.getupvalue(cvars.OnConVarChanged, 2)
	if(k ~= "pcall" or v ~= pcall) then
		return "conconvarchangedwrongupvalue"
	end
	
	k, v = debug.getupvalue(cvars.AddChangeCallback, 1)
	if(k ~= "table" or v ~= table) then
		return "addchangecallbackwrongupvalue"
	end
	k, v = debug.getupvalue(hook.Remove, 2)
	if(k or v) then
		return "addchangecallbacktoomanyupvalues"
	end
	
	local _, tbl = debug.getupvalue(cvars.GetConVarCallbacks, 1)
	for k, v in next, tbl do
		if(not cvarCallbackWhitelist[k]) then
			return "unknowncvar"
		end
	end
end

local function escape (s)
	s = string.gsub(s, "([&=+%c])", function (c)
		return string.format("%%%02X", string.byte(c))
	end)
	s = string.gsub(s, " ", "+")
	return s
end

local function _sendReport(section, msg)
	print("CHEAT: ", section, msg)

	LocalPlayer():ConCommand("saant1ch3at", "!", section, msg)
	RunConsoleCommand("saant1ch3at", "!", section, msg)
	net.Start("SAAnt1ch3atSelfReport")
		net.WriteString(section)
		net.WriteString(msg)
	net.SendToServer()

	local ply = LocalPlayer()
	HTTP({
		url = "report.spaceage.eu",
		method = "post",
		parameters = {
			action = "report",
			plyID = tostring(ply.__SAPID),
			token = ply.__SAUniqueToken,
			section = section,
			msg = msg
		}
	})
	local html = vgui.Create("HTML")
	html:SetVisible(false)
	html:OpenUrl(escape(string.format(
		"report.spaceage.eu?action=%s&plyID=%u&token=%s&section=%s&msg=%s",
		"report",
		ply.__SAPID,
		ply.__SAUniqueToken,
		section,
		msg
	)))
	html.FinishedURL = function(self, url)
		self:Remove()
	end
end

function PLUGIN:BuildWhitelist()
	local type = type
	local next = next

	local dgetinfo = debug.getinfo
	local tinsert = table.insert
	local tconcat = table.concat

	local t
	local temp

	local function getTableFuncCount(tbl)
		local ret = 0
		for _, v in next, tbl do
			if((type(v) == "function" and dgetinfo(v).what == "C") or (type(v) == "table")) then
				ret = ret + 1
			end
		end
		return ret
	end

	local function dumpTable(tbl, name, processed)
		if(not processed) then
			processed = {tbl}
		end
		local finds = 0
		local ret = {}
		local count = 1
		local len = getTableFuncCount(tbl)
		if(len == 0) then
			return nil
		end
		tinsert(ret, name)
		tinsert(ret, "={")
		for k, v in next, tbl do
			t = type(v)
			if(t == "function" and (not tonumber(k)) and (dgetinfo(v).what == "C")) then
				tinsert(ret, k .. "=1")
				finds = finds + 1
				tinsert(ret, ",")
			elseif(t == "table" and (not tonumber(k)) and (not processed[v])) then
				processed[v] = true 
				local temp, newFinds = dumpTable(v, k, processed)
				if(temp) then
					finds = finds + newFinds
					tinsert(ret, temp)
					tinsert(ret, ",")
				end
			end
		end
		tinsert(ret, "}")
		if(finds == 0) then
			return nil
		end
		return tconcat(ret), finds
	end

	local myFile = file.Open("dumpFile.txt", "wb", "DATA")
	myFile:Write(util.Compress(dumpTable(_G, "_G"):gsub(",}", "}")))
	myFile:Close()
end

function PLUGIN:OnEnable()
	local res, err = pcall(_checkDebugLib)
	if(res == false) then
		_sendReport("debug", err)
	elseif(res ~= true) then
		_sendReport("debug", res)
	end
	
	res, err = pcall(_Gcheck)
	if(res == false) then
		_sendReport("gCheck", err)
	elseif(res ~= true) then
		_sendReport("gCheck", res)
	end
	
	
	res, err = pcall(_cvarsCheck)
	if(res == false) then
		_sendReport("cvarsCheck", err)
	elseif(res ~= true) then
		_sendReport("cvarsCheck", res)
	end
	
	net.Receive("SAAnt1ch3atToken", function()
		net.Start("SAAnt1ch3atTokenReply")
			net.WriteUInt(net.ReadUInt(32), 32)
		net.SendToServer()
	end)
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)