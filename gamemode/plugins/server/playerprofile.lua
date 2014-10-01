local PLUGIN = Plugin("Playerprofile", {"Playerdata"})


function PLUGIN:OnEnable()
	SA.Plugins.Playerdata:RegisterCallback("description", function(ply, val)
		ply.__SAPlayerProfile = {description = val}
	end)
	net.Receive("SAPlayerPlayerQuery", function(len, ply)
		net.Start("SAPlayerPlayerQueryResponse")
			local qryPly = net.ReadEntity()
			net.WriteEntity(qryPly)
			net.WriteString(qryPly.__SAPlayerDescription.description)
		net.Send(ply)
	end)
end

function PLUGIN:OnDisable()
	net.Receive("SAPlayerPlayerQuery", nil)
end

SA:RegisterPlugin(PLUGIN)