include("shared.lua")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
	self._produces = {energy = 0}
	self._running = false
end

function ENT:RDTick()
	node:AddResource("energy", self:GetUp():Dot(sunDir))
end