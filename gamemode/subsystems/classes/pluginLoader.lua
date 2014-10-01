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

local function _AddLuaDir(dir)
	local files, folders = file.Find(dir.."/*", LUA_PATH)
	for _, folders in next, folders do
		_AddLuaDir(dir.."/"..tv)
	end
	for _, name in next, files do
		AddCSLuaFile(dir.."/"..name)
	end
end

local colOutline = Color(0, 0, 255)
local colTextDefault = Color(255, 255, 0)
local colTextOK = Color(0, 255, 0)
local colTextBAD = Color(255, 0, 0)


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

local gmPath = SA.Folder:sub(11)

pluginManager = class("PluginLoader", {
	methods = {
		PluginLoader = function(self, isDebug)
			self.Plugins = {}
			self._registerErrors = {}
			self._loadedModules = {}
			self._pluginRegistered = false
		end,
		_loadDir = function(self, dir, clientside, serverside)
			local files, folders = file.Find(dir.."/*", LUA_PATH)
			local absFilePath, isok, err
			for _, fileName in next, files do
				absFilePath = dir.."/"..fileName
				if (clientside and SERVER) then
					AddCSLuaFile(absFilePath)
					continue
				end
				if (serverside and SERVER) then
					self._pluginRegistered = false
					local res = CompileString(file.Read(path, "GAME"), path, false)
					if(type(res) == "string") then
						self:Error(
							"Could not update plugin '%s', parse error: '%s'",
							name,
							res
						)
						continue
					end
					local succ, err = res()
					if(not succ) then
						self:Error(
							"Could not update plugin '%s', load error: '%s'",
							name,
							res
						)
						continue
					end
					if not self._pluginRegistered then
						self:Error("Loaded file '%s' without registerting a plugin", fileName)
					end
				end
			end	
			
			for _, fileName in next, folders do
				if(fileName:sub(1,1) == "_") then
					if(clientside) then
						_AddLuaDir(dir.."/"..fileName)
					end
					continue
				end
				absFilePath = dir.."/"..fileName
				self:_loadDir(absFilePath, clientside, serverside)
			end
		end,
			
		ReadPlugins = function(self)
			if(_DEBUG) then
				printTextBox("DEBUG PLUGIN READING BEGIN")
				Msg("\n")
			end
			
			self:_loadDir(gmPath.."/gamemode/plugins/server", false, true)
			self:_loadDir(gmPath.."/gamemode/plugins/client", true, false)
		
			if(_DEBUG) then
				Msg("\n")
				printTextBox("DEBUG PLUGIN READING END")
			end
		end,
		
		ReadPlugin = function()
		end,
		_enableDependant = function(self)
			local doLoad
			local succ, err
			local enableStack = self._enableStack
			local enableErrors = self._enableErrors
			for name, plugin in next, enableStack do
				doLoad = true
				if(plugin._dependencies) then
					for _, dependence in next, plugin._dependencies do
						if(not self.Plugins[dependence]) then
							enableStack[name] = nil
							enableErrors[plugin] = string.format(
								"Depedency '%s' is missing",
								dependence
							)
							break
						end
						if(enableStack[dependence]) then
							doLoad = false
							break
						end
					end
					if(not doLoad) then
						continue
					end
				end
				enableStack[name] = nil
				if(plugin._dependencies) then
					plugin.Using = {}
					for _, dependence in next, plugin._dependencies do
						plugin.Using[dependence] = self.Plugins[dependence]
					end
				end
				succ, err = pcall(plugin.OnEnable, plugin, _DEBUG)
				plugin.IsLoaded = true
				if(not succ) then 
					enableErrors[plugin] = err:gsub("%[[%w_/%.]-:", "[")
				end
			end
			if(next(enableStack)) then
				enableDepedant()
			end
		end,
		
		EnablePlugins = function(self)
			if(_DEBUG) then
				printTextBox("DEBUG PLUGIN ENABLE BEGIN")
				Msg("\n")
			end
			self._enableStack = {}
			for k, v in next, self.Plugins do
				if(v._noLoad) then
					continue
				end
				self._enableStack[k] = v
			end
			self._enableErrors = {}
			self:_enableDepedant()
			if(_DEBUG) then
				Msg("\n")
				printTextBox("DEBUG PLUGIN ENABLE END")
			end
		end,
		
		DisablePlugin = function(self, name)
			for plugName, plugin in next, self.Plugins do
				if(plugin._dependencies) then
					for _, depend in next, PLUGIN._dependencies do
						if(depend == name) then
							if(self.Plugins[plugName].IsLoaded) then
								self:DisablePlugin(plugName)
								self.Plugins[plugName]:Warning(
									"Cascading shutdown of plugin caused by disabling '%s'", name
								)
							end
						end
					end
				end
			end
			self.Plugins[name]:OnDisable()
			self.Plugins[name].IsLoaded = false
		end,
		
		PrintPluginList = function(self)
			local errors = 0
			local loaded = 0
			
			local len = getMaxErrLength(self.Plugins)
			
			local ok = "OK"..string.rep(" ", len-2)--prebuild for speed
			local repMinus = string.rep("-", len-7)
			local repSpace = string.rep(" ", len-7)
			printHeader(repSpace, repMinus)
			local _registerErrors = self._registerErrors
			local _enableErrors = self._enableErrors
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
		end,
		
		PrintPluginListPlain = function(self)
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
			local _registerErrors = self._registerErrors
			local _enableErrors = self._enableErrors
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
			self._enableErrors = nil
		end,
		
		_logRegisterError = function(self, plugin, err)
			self.Plugins[plugin.Name] = plugin
			plugin._noLoad = true
			self._registerErrors[plugin] = err
		end,
		
		RegisterPlugin = function(self, plugin)
			local fileName = debug.getinfo(2).short_src:match("([a-zA-Z0-9]-)%.lua$"):lower()
			local err
			if(not plugin.Name) then
				plugin.Name = "NAMEMISSING"
				return self:_logRegisterError(plugin, "Attempted to register without name")
			end
			if(fileName ~= plugin.Name:lower()) then
				return self:_logRegisterError(self, plugin, string.format(
					"Filename('%s') does not match plugin name.",
					fileName,
					plugin.Name
				))
			end
			_pluginRegistered = true
			if(not plugin.Name) then
				return self:_logRegisterError(plugin, "Attempted to register without name")
			end
			if(plugin._dependencies) then
				for _, dependence in next, plugin._dependencies do
					if(plugin.Name == dependence) then
						return self:_logRegisterError(plugin, string.format("Depends on itself", plugin.Name))
					end
				end
			end
			if(not plugin.OnEnable) then
				return self:_logRegisterError(plugin, string.format("OnEnable not defined", plugin.Name))
			end
			if(not plugin.OnDisable) then
				return self:_logRegisterError(plugin, string.format("OnDisable not defined", plugin.Name))
			end
			if(plugin.modules) then
				local succ, err
				for k, v in next, plugin.modules do
					if(not _loadedmodules[v]) then
						succ, err = pcall(require, v)
						if(not succ or err == nil) then
							if(type(err) == "string") then
								return self:_logRegisterError(plugin, string.format(
										"Module '%s' (%s) missing",
										v,
										err,
										plugin.Name
									)
								)
							end
							return doErrReg(self, plugin, 
									string.format(
									"Module '%s' missing",
									v,
									plugin.Name
								)
							)
						end
					end
				end
			end
			self._pluginRegistered = true
			self.Plugins[plugin.Name] = plugin
		end
		}
	}
)