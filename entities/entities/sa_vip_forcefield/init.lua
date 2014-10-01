include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local nullAng = Angle(0, 0, 0)

local forceFields = {}
util.AddNetworkString("SAVIPForceFieldTouch")
local function checkState()
	if(next(forceFields)) then
		hook.Add("SetupMove", "SAVipForceField", function(ply, data)
			if(true) then
				local vel
				local hitPos
				local plyPos = ply:OBBCenter()
				for forceField in next, forceFields do
					vel = data:GetVelocity()
					local hitPos = util.IntersectRayWithPlane(
						plyPos,
						vel,
						forceField.vertex1,
						forceField.normal
					)
					if(not hitPos) then
						continue
					end
					if(plyPos:Distance(hitPos) < 80) then
						local pos, _ = WorldToLocal(hitPos, nullAng, vertex1, (vertex2-vertex1):Angle())
						if(pos.x >= 0 and pos.x <= forceField.sizeX and
							pos.y >= 0 and pos.y <= forceField.sizeY) then
							data:SetVelocity(vel*-1)
							net.Start("SAVIPForceFieldTouch")
								net.WriteEntity(forceField)
							net.SendPVS(hitPos)
							return
						end
					end
				end
			end
		end)
	else
		hook.Remove("SetupMove", "SAVipForceField")
	end
end
function ENT:Initialize()
	self.vertex1 = Vector(0, 0, 0)
	self.vertex2 = Vector(0, 0, 0)
	self.vertex3 = Vector(0, 0, 0)
	self.vertex4 = Vector(0, 0, 0)
	forceFields[self] = true
	checkState()
end

function ENT:OnRemove()
	forceFields[self] = false
	checkState()
end


util.AddNetworkString("SAVipForceFieldVertexes")
function ENT:SetVertexes(vert1, vert2, vert3)
	self.normal = (vert2-vert1):Cross(vert3-vert1)
	net.Start("SAVipForceFieldVertexes")
		net.WriteEntity(self)
		net.WriteVector(vert1)
		net.WriteVector(vert2)
		net.WriteVector(vert3)
		net.WriteNormal(self.normal)
	net.Send()
	self.vertex1:Set(vert1)
	self.vertex2:Set(vert2)
	self.vertex3:Set(vert3)
	
	self.vertex4:Set(vert1)
	self.vertex4:Add(vert2-vert1)
	self.vertex4:Add(vert3-vert1)
	
	local pos, _ = WorldToLocal(vert1, nullAng, self.vertex4, (vert2-vert1):Angle())
	self.sizeX = pos.x
	self.sizeY = pos.y
	
	self:SetPos((vert1 + self.vertex4)/2)
end