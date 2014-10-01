local PLUGIN = Plugin("ScreenEffects")

function PLUGIN:OnEnable()
	util.AddNetworkString("SAScreenEffectsInfo")
	hook.Add("ScalePlayerDamage", "SAScreenEffects", function(ply, hitgroup, dmginfo)
		net.Start("SAScreenEffectsInfo")
			net.WriteUInt(dmginfo:GetDamageType(), 32)
			net.WriteUInt(dmginfo:GetDamage(), 16)
		net.Send(ply)
	end)
end

function PLUGIN:OnDisable()
	hook.Remove("ScalePlayerDamage", "SAScreenEffects")
end

SA:RegisterPlugin(PLUGIN)