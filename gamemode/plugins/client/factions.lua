local PLUGIN = Plugin("Factions", {"Clientquery"})
PLUGIN._factions = {} -- id, name, description, red, green, blue
PLUGIN._queries = {}
PLUGIN._queryID = 0

function PLUGIN:QueryMembers(teamID, callback)
	SA.Plugins.Clientquery:StartRequest("FactionMembers", nil, function()
		local tbl = {}
		for i = 1, net.ReadUInt(16) do
			tbl[net.ReadUInt(32)] = {
				name = net.ReadString(),
				memberSince = net.ReadUInt(32),
				rank = net.ReadUInt(8)
			}
		end
		callback(tbl)
	end)
		net.WriteUInt(teamID, 8)
	SA.Plugins.Clientquery:DispatchRequest()
end

function PLUGIN:GetDescription(factionID)
	return self._factions[factionID].description
end

function PLUGIN:GetMemberCount(factionID)
	return self._factions[factionID].count
end

function PLUGIN:GetAll()
	return self._factions
end

function PLUGIN:OnEnable()
	include(SA.Folder:sub(11).."/gamemode/plugins/client/_factions/DSAFactionMenu.lua")
	self._factionPanel = vgui.Create("DSAFactionMenu")
	self._factionPanel:SetSize(ScrW()*0.6, ScrH()*0.6)
	self._factionPanel:CenterVertical()
	self._factionPanel.x = ScrW()
	self._factionPanel:SetVisible(false)
	
	local _num = 0
	net.Receive("SAFactionList", function(len)
		_num = net.ReadUInt(8)
		for i=1, _num do
			local id = net.ReadUInt(8)
			self._factions[id] = {
				name = net.ReadString(),
				description = net.ReadString(),
				red = net.ReadUInt(8),
				green = net.ReadUInt(8),
				blue = net.ReadUInt(8),
				count = net.ReadUInt(16)
			}
			team.SetUp(
				id,
				self._factions[id].name,
				Color(self._factions[id].red, self._factions[id].green, self._factions[id].blue, 255)
			)
		end
	end)
	
	net.Receive("SAFactionMenu", function()
		self._factionPanel:Show()
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAFactionMenu", nil)
	self._factionPanel:Remove()
end


SA:RegisterPlugin(PLUGIN)