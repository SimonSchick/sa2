AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
function ENT:Initialize()
	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	
	self:SetModel("")
end

function ENT:OnRemove()
end

function ENT:Use(activator, caller)
end

function ENT:OnTakeDamage(dmginfo)
	return false
end