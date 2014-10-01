local PLUGIN = Plugin("Playeradverts", {})

function PLUGIN:OnEnable()
	if(game.GetMap() ~= "sa_lobby") then
		return
	end
	net.Receive("SAPlayerAdvertSend", function()
		local len = net.ReadUInt(16)
		for i = 1, len do
			local adScreen = Entity(net.WriteUInt(16))
			adScreen:SetOwnerID(net.WriteUInt(16))
			adScreen:SetContents(net.ReadString())
		end
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAPlayerAdvertSend", nil)
end

SA:RegisterPlugin(PLUGIN)