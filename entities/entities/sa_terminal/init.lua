include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()

	self:SetModel("models/props/terminal.mdl")
	
	self:SetUseType(ONOFF_USE)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:OnRemove()
	SA.Plugins.Terminal:CloseMenu(self, activator)
end

function ENT:OpenMenu(ply)
	self._currentPlayer = activator
	SA.Plugins.Terminal:OpenMenu(self, ply)
end

function ENT:Close(ply)
	self._currentPlayer = nil
	SA.Plugins.Terminal:CloseMenu(self, activator)
end

function ENT:PlayerClosedMenu(ply)
	self._currentPlayer = nil
end

function ENT:Use(activator, caller)
	if(self._currentPlayer and self._currentPlayer ~= NULL) then
		return
	end
	if(activator:IsPlayer()) then
		if(SA.Plugins.Terminal:CanOpenTerminal(self, activator)) then
			self:OpenMenu(activator)
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	return false
end