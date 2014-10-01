local PLUGIN = Plugin("Terminal", {
	"Playerdata"
})

function PLUGIN:CanOpenTerminal(term, ply)
	return true
end

function PLUGIN:OpenMenu(term, ply)
	net.Start("SATerminalOpen")
		net.WriteEntity(term)
	net.Send(ply)
	ply:Lock()
	ply.__SAActiveTerminal = term
end

function PLUGIN:CloseMenu(term, ply)
	net.Start("SATerminalClose")
		net.WriteEntity(term)
	net.Send(ply)
	ply.__SAActiveTerminal = nil
end

function PLUGIN:OnEnable()
	util.AddNetworkString("SATerminalClose")
	util.AddNetworkString("SATerminalOpen")
	
	net.Receive("SATerminalClose", function(len, ply)
		if(ply.__SAActiveTerminal) then
			ply.__SAActiveTerminal:PlayerClosedMenu(ply)
		end
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SATerminalClose", nil)
end

SA:RegisterPlugin(PLUGIN)