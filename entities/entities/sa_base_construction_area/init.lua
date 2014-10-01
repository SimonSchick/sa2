AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	--[[CHECK FOR ENOUGH SPACE HERE]]
	
	local plate = ents.Create("prop_physics")
	plate:SetModel("models/hunter/plates/plate32x32.mdl")
	plate:SetMaterial("phoenix_storms/dome")
	plate:SetPos(self:GetPos())
	plate:SetMoveType(0)
	self.plate = plate
	
	self:SetModel("models/smallbridge/other/sbconsole.mdl")
	self:SetPos(plate:LocalToWorld(Vector(775,775,1.75)))
	self:SetUseType(3)
	self:SetMoveType(0)
	
	self.building = false
	self.queye = {}
	self.currentent = nil
	self.progress = 0
end

function ENT:Use(activator,call)
	if(activator:IsPlayer()) then
		if(activator:CanUseFactory(self.level)) then
			umsg.Start("factory_panel_open",activator)
				umsg.Entity(self)
			umsg.End()
			self.occupied = true
			self.user = activator
		else
			self:EmitSound("buttons/combine_button_locked.wav", 500, 200)
		end
	end
end

function ENT:OnRemove()
	self.plate:Remove()
end

function ENT:Think()
end

function ENT:BuildStart()
	self.building = true
end

function ENT:Build()
end

function ENT:BuildEnd()
	self.building = false
end

function ENT:BuildAbort()
	self.progress = 0
	self.building = false
end
