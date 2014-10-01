local PLUGIN = Plugin("Playeradverts", {"MySQL", "Playerdata"})


function PLUGIN:OnEnable()
	self._adData = {}
	self._ads = {}
	if(game.GetMap() ~= "sa_lobby") then
		return
	end
	local function _adsLoaded(isok, data)
		if(not isok) then
			return
		end
		for _, row in next, data do
			_adData[row.adid] = {
				ownerID = row.playerid,
				adData = row.contents
			}
		end
	end
	
	SA:AddEventListener("DatabaseConnect", "PlayerAdvert", function()
		SA.Plugins.MySQL:Query(
			"SELECT `id`, `playerid`, `contents` FROM `sa_player_advert`;",
			_adsLoaded
		)
	end)
	util.AddNetworkString("SAPlayerAdvertSend")
	SA:AddEventListener("PlayerLoaded", "PlayerAdvert", function(ply)
		net.Start("SAPlayerAdvertSend")
			net.WriteUInt(table.Count(self._adData), 16)
			for k, v in next, self._adData do
				net.WriteUInt(k, 16)
				net.WriteUInt(v.ownerID, 16)
				net.WriteString(v.contents)
			end
		net.Send(ply)
	end)
	hook.Add("InitPostEntity", "SAPlayerAdvert", function()
		for k, point in next, ents.FindByName("playeradvert_*") do
			local adScreen = vgui.Create("sa_playeradvert")
			adScreen:SetPos(point:GetPos())
			adScreen:SetAngles(point:GetAngles())
			local adID = tonumber(point:GetName():match("playeradvert_(%d)+"))
			local adData = self._adData[adID]
			if(adData) then
				adScreen:SetAdID(adID)
				adScreen:SetOwnerID(adData.ownerID)
				adScreen:SetContents(adData.contents)
			end
			adScreen:Spawn()
			table.insert(self._ads, adScreen)
		end
	end)
end

function PLUGIN:OnDisable()
end

SA:RegisterPlugin(PLUGIN)