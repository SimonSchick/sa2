local PLUGIN = Plugin("Playername", {"Playerdata", "MySQL"})


function PLUGIN:OnEnable()
	local function cleanName(name)
		return name:gsub("([%(%[%{%<]+)[^%(%[%{%<]+([%)%]%}%>]+)", ""):gsub("([%(%[%{%<%)%]%}%>])", "")
	end
	
	util.AddNetworkString("SAPlayername")
	SA.Plugins.Playerdata:RegisterCallback("name", 
		function(ply, val)
			if(val == "") then
				val = cleanName(ply:GetName())
				ply.__SACleanName = val
			else
				ply.__SACleanName = val
			end
			net.Start("SAPlayername")
				net.WriteEntity(ply)
				net.WriteString(val)
			net.Broadcast()
			
			local plys = player.GetAll()
			
			net.Start("SAPlayernameUpdate")
				net.WriteUInt(#plys-1, 8)
				for _, otherPly in next, plys do
					if(otherPly == ply) then
						continue
					end
					net.WriteEntity(otherPly)
					net.WriteString(otherPly.__SACleanName)
					print("SENDING PLAYERNAME TO PLAYER", ply, otherPly, otherPly.__SACleanName)
				end
			net.Send(ply)
		end
	)
	
	util.AddNetworkString("SAPlayernameUpdate")
	
	util.AddNetworkString("SAPlayernameQueryResponse")
	local function _playerQueryDone(isok, data, ply, indentifier)
		if(not isok) then
			return
		end
		net.Start("SAPlayernameQueryResponse")
			net.WriteUInt(indentifier, 8)
			net.WriteString(data[1].name)
		net.Send(ply)
	end
	
	net.Receive("SAPlayernameQuery", function(len, ply)
		SA.Plugins.MySQL(
			string.format(
				"SELECT `name` FROM `sa_player` WHERE `playerid` = '%u'",
				net.ReadUInt(32)
			),
			_playerQueryDone,
			ply,
			net.ReadUInt(8)
		)
	end)
	
	local meta = _R.Player
	
	function meta:SASetName(name)
		name = cleanName(name)
		self.__SACleanName = name
		SA.Plugins.MySQL(
			string.format(
				"UPDATE `sa_player` SET `name` = '%s' WHERE `playerid` = '%u'",
				SA.Plugins.MySQL:Escape(name),
				self.__SAPID
			)
		)
	end
	
	function meta:SAGetCleanName()
		return self.__SACleanName
	end
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)