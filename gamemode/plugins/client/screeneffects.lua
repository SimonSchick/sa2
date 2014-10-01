local PLUGIN = Plugin("Screeneffects", {"Config"})

function PLUGIN:OnEnable()
	local bloodSplash = Material("screeneffects/bloodsplah")
	local bloodDrop = Material("screeneffects/blooddrop")
	net.Receive("SAScreenEffectsInfo", function()
		local type = net.ReadUInt(dmginfo:GetDamageType(), 32)
		local dmg = net.ReadUInt(dmginfo:GetDamage(), 16)
	end)
	hook.Add("RenderScreenspaceEffects", "SAScreenEffects", function()
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAScreenEffectsInfo", nil)
	hook.Remove("RenderScreenspaceEffects", "SAScreenEffects")
end