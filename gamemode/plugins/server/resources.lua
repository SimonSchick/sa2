local PLUGIN = Plugin("Resources", {"MySQL"})


function PLUGIN:RegisterNode(node)
	table.insert(self._nodes, node)
end

function PLUGIN:GetNodes()
	return self._nodes
end

function PLUGIN:OnEnable()
	self._resources = {}
	self._count = 0
	self._nodes = {}
	util.AddNetworkString("SAResourceList")

	SA:AddEventListener("DatabaseConnect", "Resources", function()
		SA.Plugins.MySQL:Query(
			"SELECT `resourceid`, `resource_name`, `base_value`, `weight` FROM `sa_resource`;",
			function(isok, data)
				if(not isok) then
					return
				end
				local c = 0
				for _, row in next, data do
					self._resources[row.resourceid] = {
						name = row.resource_name,
						baseValue = row.base_value,
						weight = row.weight
					}
					c = c + 1
				end
				self._count = c
			end)
		end
	)
	hook.Add("PlayerInitialSpawn", "SAResources", function(ply)
		net.Start("SAResourceList")
			net.WriteUInt(self._count, 16)
			for resID, resTbl in next, self._resources do
				net.WriteUInt(resID, 16)
				net.WriteString(resTbl.name)
				net.WriteFloat(resTbl.baseValue)
				net.WriteFloat(resTbl.weight)
			end
		net.Send(ply)
	end)
	
	local tickDelay = 0.5
	local nextTick = 0
	local currTime
	util.AddNetworkString("SANodeUpdate")
	util.AddNetworkString("SANodeMaxUpdate")
	util.AddNetworkString("SARDTick")
	hook.Add("Tick", "SAResourceTick", function()
		currTime = CurTime()
		if(nextTick <= currTime) then
			nextTick = currTime + tickDelay
			for _, node in next, self._nodes do
				node:RDTick()
			end
			net.Start("SARDTick")
			net.Broadcast()
			
			for _, node in next, self._nodes do
				if(node._isDirty) then
					net.Start("SANodeUpdate")
						net.WriteEntity(node)
						for resID, dirty in next, node._dirtyResources do
							if(dirty) then--in this case, the length of the message will determine the count
								net.WriteUInt(resID, 16)
								net.WriteUInt(node._resources[resID], 32)
							end
							node._dirtyResources[resID] = false
							node._oldResources[resID] = node._resources[resID]
						end
					net.SendPVS(node:GetPos())
					node._isDirty = false
				end
				--[[net.Start("SANodeMaxUpdate") --TODO: DO MAX NETWORKING
					net.WriteEntity(node)
					for resID, dirty in next, node._dirtyResources do
						if(dirty) then--in this case, the length of the message will determine the count
							net.WriteUInt(resID, 16)
							net.WriteUInt(node._resources[resID], 32)
						end
					end
				net.SendPVS(node:GetPos())]]
			end
		end
	end)
end

function PLUGIN:OnDisable()
	hook.Remove("PlayerInitialSpawn", "SAResources")
	SA:RemoveEventListener("DatabaseConnect", "Resources")
end

function PLUGIN:GetResource(id)
	return self._resources[id]
end

SA:RegisterPlugin(PLUGIN)