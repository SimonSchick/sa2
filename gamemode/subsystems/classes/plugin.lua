local braceColor = Color(0, 0, 255, 255)
local inBraceColor = Color(255, 0, 0, 255)
local errorCol = Color(255, 20, 0, 255)
local warnCol = Color(255, 255, 0, 0)
local printCol = Color(20, 255, 0, 0)

local MsgC = MsgC
local sformat = string.format
Plugin = class("Plugin", {
	methods = {
		Plugin = function(self, name, dependencies, modules)
			self.Name = name
			--self._dependencies = dependencies
			--self._modules = modules
			self.Dependencies = dependencies
			self.Modules = modules
		end,
		Error = function(self, err, ...)
			MsgC(braceColor, "[")
			MsgC(inBraceColor, "SA")
			MsgC(braceColor, "][")
			MsgC(inBraceColor, "ERROR")
			MsgC(braceColor, "][")
			MsgC(inBraceColor, self.Name)
			MsgC(braceColor, "]")
			MsgC(errorCol, 
				sformat(err.."\n", ...)
			)
		end,
		Warning = function(self, warn, ...)
			MsgC(braceColor, "[")
			MsgC(inBraceColor, "SA")
			MsgC(braceColor, "][")
			MsgC(inBraceColor, "WARNING")
			MsgC(braceColor, "][")
			MsgC(inBraceColor, self.Name)
			MsgC(braceColor, "]")
			MsgC(warnCol, 
				sformat(warn.."\n", ...)
			)
		end,
		Print = function(self, msg, ...)
			MsgC(braceColor, "[")
			MsgC(inBraceColor, "SA")
			MsgC(braceColor, "][")
			MsgC(inBraceColor, "NOTICE")
			MsgC(braceColor, "][")
			MsgC(inBraceColor, self.Name)
			MsgC(braceColor, "]")
			MsgC(printCol, 
				sformat(msg.."\n", ...)
			)
		end,
		__tostring = function(self)
			return "SA2Plugin :"..self.Name
		end
		}
	}
)