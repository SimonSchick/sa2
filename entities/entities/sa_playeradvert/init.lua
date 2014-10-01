include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()
end

function ENT:SetOwnerID(id)
	self._ownerID = id
end

function ENT:GetOwnerID()
	return self._ownerID
end