local PLUGIN = Plugin("Helpmenu")

function PLUGIN:OnEnable()
	util.AddNetworkString("SAHelpMenu")
	hook.Add("ShowHelp", "SAHelpMenu", function(ply)
		net.Start("SAHelpMenu")
		net.Send(ply)
		return true
	end)
end

function PLUGIN:OnDisable()
	hook.Remove("ShowHelp", "SAHelpMenu")
end

SA:RegisterPlugin(PLUGIN)