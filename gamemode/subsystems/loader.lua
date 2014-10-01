--TODO:
--IMPLEMENT CONSOLE PRINTS FOR CLIENTS, WITH COLOR!!
--IMPLEMENT A BETTER CICULARITY CHECK

local colOutline = Color(0, 0, 255)
local colTextDefault = Color(255, 255, 0)
local colTextOK = Color(0, 255, 0)
local colTextBAD = Color(255, 0, 0)

local FANCYBOOT = system.HasFocus() or true

local gmPath = SA.Folder:sub(11)

AddCSLuaFile(gmPath.."/gamemode/config/DisabledPlugins.lua")

local _DEBUG = true

------------
--INTERNAL--
------------
SA.DisabledLUAs = {}
local _pluginRegistered = 0
local function _AddLuaDir(dir)
	local files, folders = file.Find(dir.."/*", LUA_PATH)
	for _, folders in next, folders do
		_AddLuaDir(dir.."/"..tv)
	end
	for _, name in next, files do
		AddCSLuaFile(dir.."/"..name)
	end
end

local function _LoadDir(dir, mtype, clientside, serverside, rootlen)
	local tbl = file.Find(dir.."/*.lua", LUA_PATH)
	local v, isok, err
	for _, tv in next, tbl do
		if(SA.DisabledPlugins[tv]) then
			continue
		end
		v = dir.."/"..tv
		isok, err = pcall(function()
			if (clientside and SERVER) then AddCSLuaFile(v) end
			if (serverside and SERVER) then
				_pluginRegistered = false
				include(v)
				if not _pluginRegistered then
					self:Error("Loaded file '%s' without registerting a plugin", tv)
				end
			end
		end)
	end	
	
	tbl = file.FindDir(dir.."/*", LUA_PATH)
	for _, tv in next, tbl do
		if(tv:sub(1,1) == "_") then
			if(clientside) then
				_AddLuaDir(dir.."/"..tv)
			end
			continue
		end
		v = dir.."/"..tv
		_LoadDir(v, mtype, clientside, serverside)
	end
end

function SA:LoadDisabledLUAs()
	if not pcall(function()
		SA.DisabledLUAs = util.KeyValuesToTable(file.Read("sa_config/disabled_luas.txt", "DATA"))
	end) then
		SA.DisabledLUAs = {}
	end
end

local path = gmPath.."/gamemode/config/"
function SA:GetConfigPath()
	return path
end

local printTextBox
if(FANCYBOOT) then
	function printTextBox(txt)
		local len = txt:len()
		MsgC(colOutline, " /")
		MsgC(colOutline, string.rep("-", len))
		MsgC(colOutline, "\\\n| ")
		MsgC(colTextDefault, txt)
		MsgC(colOutline, " |\n \\")
		MsgC(colOutline, string.rep("-", len))
		MsgC(colOutline, "/\n")
	end
else
	function printTextBox(txt)
		local len = txt:len()
		Msg(" /")
		Msg(string.rep("-", len))
		Msg("\\\n| ")
		Msg(txt)
		Msg(" |\n \\")
		Msg(string.rep("-", len))
		Msg("/\n")
	end
end
function SA:ReloadPlugins()
	include(SA.Folder:sub(11).."/gamemode/config/DisabledPlugins.lua")
	if(_DEBUG) then
		printTextBox("DEBUG PLUGIN READING BEGIN")
		Msg("\n")
	end
	
	_LoadDir(gmPath.."/gamemode/plugins/server", "Server", false, true)
	_LoadDir(gmPath.."/gamemode/plugins/client", "Client", true, false)
	
	if(_DEBUG) then
		Msg("\n")
		printTextBox("DEBUG PLUGIN READING END")
	end
	
	self:EnablePlugins()
end



----------------------
--PLUGIN REGISTERING--
----------------------


SA.Plugins = {}
local _loadedModules = {}
local _registerErrors = {}

local function doErrReg(self, PLUGIN, err)
	self.Plugins[PLUGIN.Name] = PLUGIN
	self._noLoad = true
	_registerErrors[PLUGIN] = err
end

function SA:RegisterPlugin(PLUGIN)
	local fileName = debug.getinfo(2).short_src:match("([a-zA-Z0-9]-)%.lua$"):lower()
	local err
	if(not PLUGIN.Name) then
		PLUGIN.Name = "NAMEMISSING"
		return doErrReg(self, PLUGIN, "Attempted to register without name")
	end
	if(fileName ~= PLUGIN.Name:lower()) then
		return doErrReg(self, PLUGIN, string.format(
			"Filename('%s') does not match plugin name.",
			fileName,
			PLUGIN.Name
		))
	end
	_pluginRegistered = true
	if(not PLUGIN.Name) then
		return doErrReg(self, PLUGIN, "Attempted to register without name")
	end
	if(PLUGIN.Dependencies) then
		for _, dependence in next, PLUGIN.Dependencies do
			if(PLUGIN.Name == dependence) then
				return doErrReg(self, PLUGIN, string.format("Depends on itself", PLUGIN.Name))
			end
		end
	end
	if(not PLUGIN.OnEnable) then
		return doErrReg(self, PLUGIN, string.format("OnEnable not defined", PLUGIN.Name))
	end
	if(not PLUGIN.OnDisable) then
		return doErrReg(self, PLUGIN, string.format("OnDisable not defined", PLUGIN.Name))
	end
	if(PLUGIN.Modules) then
		for k, v in next, PLUGIN.Modules do
			if(not _loadedModules[v]) then
				succ, err = pcall(require, v)
				if(not succ or err == nil) then
					if(type(err) == "string") then
						return doErrReg(self, PLUGIN, string.format(
								"Module '%s' (%s) missing",
								v,
								err,
								PLUGIN.Name
							)
						)
					end
					return doErrReg(self, PLUGIN, 
							string.format(
							"Module '%s' missing",
							v,
							PLUGIN.Name
						)
					)
				end
			end
		end
	end
	self.Plugins[PLUGIN.Name] = PLUGIN
end


------------------
--PLUGIN LOADING--
------------------

local MAX_CIRCULAR = 10

-------------------
--PLUGIN ENABLING--
-------------------

local _enableStack = {}
local _enableErrors
local i = 0
local function enableDepedant()
	i = i + 1
	local doLoad
	local isok
	for name, PLUGIN in next, _enableStack do
		doLoad = true
		if(PLUGIN.Dependencies) then
			for _, dependence in next, PLUGIN.Dependencies do
				if(not SA.Plugins[dependence]) then
					_enableStack[name] = nil
					_enableErrors[PLUGIN] = string.format(
						"Depedency '%s' is missing",
						dependence
					)
					break
				end
				if(_enableStack[dependence]) then
					doLoad = false
					break
				end
			end
			if(not doLoad) then
				continue
			end
		end
		_enableStack[name] = nil
		if(PLUGIN.Dependencies) then
			PLUGIN.Using = {}
			for _, dependence in next, PLUGIN.Dependencies do
				PLUGIN.Using[dependence] = SA.Plugins[dependence]
			end
		end
		isok, err = pcall(PLUGIN.OnEnable, PLUGIN, _DEBUG)
		PLUGIN.IsLoaded = true
		if(not isok) then 
			_enableErrors[PLUGIN] = err:gsub("%[[%w_/%.]-:", "[")
		end
	end
	if(next(_enableStack)) then
		enableDepedant()
	end
end

local function getMaxErrLength(plugins)
	local max = -1
	local tempLen
	for k, v in next, _enableErrors do
		tempLen = v:len()
		if(tempLen > max) then
			max = tempLen
		end
	end
	for k, v in next, _registerErrors do
		tempLen = v:len()
		if(tempLen > max) then
			max = tempLen
		end
	end
	return max
end

if(FANCYBOOT) then
	local function printCols(repSpace)
		MsgC(colOutline, "| ")
		MsgC(colTextDefault, "   PLUGIN NAME")
		MsgC(colOutline, "   | ")
		MsgC(colTextDefault, "STATUS")
		MsgC(colOutline, "  | ")
		MsgC(colTextDefault, "MESSAGE ")
		Msg(repSpace)
		MsgC(colOutline, "|\n")
	end
	
	local function printHeader(repSpace, repMinus)
		MsgC(colOutline, "          ____________________________\n         / ")
		MsgC(colTextDefault, "Enabling SpaceAge2 Plugins")
		MsgC(colOutline, " \\\n /-----------------+---------+---------"..repMinus.."\\\n")
		printCols(repSpace)
		MsgC(colOutline, "+------------------+---------+---------"..repMinus.."+\n")
	end
	local function printFooter(repSpace, repMinus, loaded, errors)
		MsgC(colOutline, "+------------------+---------+---------"..repMinus.."+\n")
		printCols(repSpace)
		MsgC(colOutline, " \\-----------------+---------+---------"..repMinus.."/\n")
		MsgC(colOutline, "  \\             ")
		MsgC(colTextOK, string.format("ENABLED PLUGINS: %3u", loaded))
		Msg(repSpace)
		MsgC(colOutline, "  /\n   \\            ")
		MsgC(colTextBAD, string.format("FAILED  PLUGINS: %3u", errors))
		Msg(repSpace)
		MsgC(colOutline, " /\n    \\-------------------------------"..repMinus.."/\n")
	end
	local function printFailed(name, errStr)
		MsgC(colOutline, "| ")
		MsgC(colTextDefault, string.format("%16s", name))
		MsgC(colOutline, " | ")
		MsgC(colTextBAD, "FAILED")
		MsgC(colOutline, "  | ")
		MsgC(colTextBAD, errStr)
		MsgC(colOutline, " |\n")
	end
	local function printLoaded(name, okString)
		MsgC(colOutline, "| ")
		MsgC(colTextDefault, string.format("%16s", name))
		MsgC(colOutline, " | ")
		MsgC(colTextOK, "ENABLED")
		MsgC(colOutline, " | ")
		MsgC(colTextOK, okString)
		MsgC(colOutline, " |\n")
	end
	function SA:ShowEnabled()
		local errors = 0
		local loaded = 0
		
		local len = getMaxErrLength(self.Plugins)
		
		local ok = "OK"..string.rep(" ", len-2)--prebuild for speed
		local repMinus = string.rep("-", len-7)
		local repSpace = string.rep(" ", len-7)
		printHeader(repSpace, repMinus)
		
		for k, v in next, self.Plugins do
			if(_enableErrors[v]) then
				printFailed(v.Name, _enableErrors[v]..string.rep(" ",len-_enableErrors[v]:len()))
				errors = errors + 1
			elseif(_registerErrors[v]) then
				printFailed(v.Name , _registerErrors[v]..string.rep(" ",len-_registerErrors[v]:len()))
				errors = errors + 1
			else
				printLoaded(v.Name, ok)
				loaded = loaded + 1
			end
		end
		printFooter(repSpace, repMinus, loaded, errors)
		_enableErrors = nil
	end
else
	function SA:ShowEnabled()
		local errors = 0
		local loaded = 0
		
		local len = getMaxErrLength(self.Plugins)
		
		local ok = "OK"..string.rep(" ", len-2)
		local repMinus = string.rep("-", len-7)
		local repSpace = string.rep(" ", len-7)
		Msg("          ____________________________\n")
		Msg("         / Enabling SpaceAge2 Plugins \\\n")
		Msg(" /-----------------+---------+---------"..repMinus.."\\\n")
		Msg("| PLUGIN NAME      | STATUS  | MESSAGE "..repSpace.."|\n")
		Msg("+------------------+---------+---------"..repMinus.."+\n")
		
		for k, v in next, self.Plugins do
			if(_enableErrors[v]) then
				Msg(string.format("| %16s | FAILED  | %s |\n", v.Name, _enableErrors[v]..string.rep(" ",len-_enableErrors[v]:len())))
				errors = errors + 1
			elseif(_registerErrors[v]) then
				Msg(string.format("| %16s | FAILED  | %s |\n", v.Name , _registerErrors[v]..string.rep(" ",len-_registerErrors[v]:len())))
				errors = errors + 1
			else
				Msg(string.format("| %16s | ENABLED | %s |\n", v.Name, ok))
				loaded = loaded + 1
			end
		end
		Msg("+------------------+---------+---------"..repMinus.."+\n")
		Msg("| PLUGIN NAME      | STATUS  | MESSAGE "..repSpace.."|\n")
		Msg(" \\-----------------+---------+---------"..repMinus.."/\n")
		Msg(string.format("  \\             ENABLED PLUGINS: %3u"..repSpace.."  /\n", loaded))
		Msg(string.format("   \\            FAILED  PLUGINS: %3u"..repSpace.." /\n", errors))
		Msg("    \\-------------------------------"..repMinus.."/\n")
		_enableErrors = nil
	end
end

function SA:EnablePlugins()
	if(_DEBUG) then
		printTextBox("DEBUG PLUGIN ENABLE BEGIN")
		Msg("\n")
	end
	for k, v in next, self.Plugins do
		if(v._noLoad) then
			continue
		end
		_enableStack[k] = v
	end
	_enableErrors = {}
	enableDepedant()
	if(_DEBUG) then
		Msg("\n")
		printTextBox("DEBUG PLUGIN ENABLE END")
	end
	self:ShowEnabled()
end

function SA:PrintCredits()
	Msg("  /-----------------------------------\\\n")
	Msg(" |          LOADING SPACEAGE2          |\n")
	Msg(" +-------------------------------------+\n")
	Msg(" |              DISCLAIMER             |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" +-------------------------------------+\n")
	Msg(" |             DEVELOPED BY            |\n")
	Msg(" |         Simon  aka 'Wizard'         |\n")
	Msg(" |          Mark  aka 'Doridian'       |\n")
	Msg(" |                                     |\n")
	Msg(" |          Special Thanks to:         |\n")
	Msg(" |  Raklatif   - Motivation & Mapping  |\n")
	Msg(" |  Bubbles100 -       Modelling       |\n")
	Msg(" |                                     |\n")
	Msg(" |              Thanks to:             |\n")
	Msg(" |   Tobjv        -   Caring for SA1   |\n")
	Msg(" |   Zachar       -   Coding for SA1   |\n")
	Msg(" |   SBMP Team    -   Models           |\n")
	Msg(" |   Garry Newman -   Creating gmod    |\n")
	Msg(" |                                     |\n")
	Msg(" |    And A Very Special Thanks To:    |\n")
	Msg(" | GMod-Aurora Team - heavy motivation |\n")
	Msg(" |                                     |\n")
	Msg(" |                                     |\n")
	Msg(" | © SpaceAge Team All Rights Reserved |\n")
	Msg(" |                                     |\n")
	Msg("  \\-----------------------------------/\n")
end
----------------------
--MAIN LOAD FUNCTION--
----------------------

function SA:StartLoader()
	SA:PrintCredits()
	self:LoadDisabledLUAs()
	self:ReloadPlugins()
end

--------
--MISC--
--------

function SA:DisablePlugin(name)
	for plugName, PLUGIN in next, self.Plugins do
		if(PLUGIN.Dependencies) then
			for _, depend in next, PLUGIN.Dependencies do
				if(depend == name) then
					if(self.Plugins[plugName].IsLoaded) then
						self:DisablePlugin(plugName)
						SA:Warning("Cascading shutdown of plugin '%s'", plugName)
					end
				end
			end
		end
	end
	self.Plugins[name]:OnDisable()
	self.Plugins[name].IsLoaded = false
end

function SA:EnablePlugin(name, enableDepends)
	local plugin = self.Plugins[name]
	if(plugin.IsLoaded) then
		return
	end
	if(plugin.Dependencies) then
		local dependsMissing = {}
		for _, depend in next, plugin.Dependencies do
			if(not self.Plugins[depend].IsLoaded) then
				dependsMissing[#dependsMissing+1] = depend
				if(enableDepends) then
					self:EnablePlugin(depend, enableDepends)
				end
			end
		end
		if(not enableDepends and #dependsMissing ~= 0) then
			for i = 1, #dependsMissing do
				SA:Warning(
					"Could not loading plugin '%s' depedency '%s' is missing, please pass true to load dependencies",
					name,
					dependsMissing[i]
				)
				return false
			end
		end
	end
	self.Plugins[name]:OnEnable(_DEBUG)
	SA:Print(
		"Successfully enabled plugin '%s'",
		name
	)
end

function SA:UpdatePlugin(name)
	local path = debug.getinfo(self.Plugins[name].OnEnable).short_src:gsub("\\", "/")
	local res = CompileString(file.Read(path, "GAME"), path, false)
	if(type(res) == "string") then
		SA:Error(
			"Could not update plugin '%s', parse error: '%s'",
			name,
			res
		)
		return false
	else
		self.Plugins[name] = nil--to avoid the name check
		local isok, res = pcall(res)
		if(not isok) then
			SA:Error(
				"Could not update plugin '%s', run error: '%s'",
				name,
				res
			)
			return false
		end
		if(not self.Plugins[name]) then
			SA:Error(
				"Could not find plugin table for plugin '%s' after update, did the plugin name change?",
				name
			)
			return false
		end
		isok, err = pcall(self.EnablePlugin, self, name)
		if(not isok) then
			SA:Error(
				"Could not enable plugin '%s' after update '%s'",
				name
			)
		end
	end
	SA:Print(
		"Successfully updated plugin '%s'",
		name
	)
end

util.AddNetworkString("SAPluginUpdate")
function SA:UpdateClientPlugin(name)
	--in this case we cannot rely on function signatures, this will be bad enough...
	local lowName = name:lower()
	local path = SA.Folder:sub(10).."/gamemode/plugins/client/"
	local code
	if(not file.Exists(path..lowName..".lua", "GAME")) then
		for i = 1, 10 do
			SA:Warning(
				"Internal plugin name for plugin '%s' does not match file name, please fix this, proceeding with regex",
				name
			)
		end
		local fileList = file.Find(path.."*.lua", "GAME")
		for _, fileName in next, fileList do
			code = file.Read(path..fileName)
			local matchName = code:match("local PLUGIN%s*=%s*{\n\tName%s*=%s*[\"']([a-zA-Z0-9]-)[\"']")
			if(matchName == name) then
				break
			end
		end
	else
		code = file.Read(path..lowName..".lua", "GAME")
	end
	if(not code) then
		SA:Error(
			"Could not find client plugin '%s'",
			name
		)
	end
	local res = CompileString(code, path..fileName, false)
	if(not res) then
		SA:Error(
			"Could not update client plugin '%s', parse error: '%s'",
			name,
			res
		)
		return
	end
	code = util.Compress(code)
	net.Start("SAPluginUpdate")
		net.WriteString(name)
		net.WriteUInt(code:len(), 16)
		net.WriteData(code)
	net.Broadcast()
	SA:Print(
		"Successfully updated client plugin '%s'",
		name
	)
end