include("shared.lua")

local mat = Matrix()
local cache_vector = Vector()
local dummy_angle = Angle(0, 0, 0)

--funcs
local cPushModelMatrix = cam.PushModelMatrix
local cPopModelMatrix = cam.PopModelMatrix

local mrad = math.rad
local msin = math.sin
local mcos = math.cos
local mfloor = math.floor
local mClamp = math.Clamp

local tinsert = table.insert

local rSetMaterial = render.SetMaterial
local rStartBeam = render.StartBeam
local rAddBeam = render.AddBeam
local rEndBeam = render.EndBeam

local LocalToWorld = LocalToWorld
local CurTime = CurTime
local DynamicLight = DynamicLight
local EyePos = EyePos
local next = next
--END CACHING--

--HELPER FUNCTIONS--

local cached = {}

function ENT:PreCalculate()--Function to generate vertex coordinates based on vertex count
	local qual = self.config.quality
	if(cached[qual]) then
		self.sins = cached[qual][1]
		self.coss = cached[qual][2]
	end
	local sins = {}
	local coss = {}
	local val
	for i = 1, qual do
		val = mrad((360/qual)*i)
		tinsert(sins, msin(val))
		tinsert(coss, mcos(val))
	end
	cached[qual] = {sins, coss}
	self.sins = sins
	self.coss = coss
end

function ENT:SetupPlanets()
	for k, v in next, self.config.planets do
		local plnt = ClientsideModel(v.model, RENDERGROUP_OPAQUE)
		plnt:SetModelScale(v.size)
		v.planet = plnt
		--[[
		if(v.moons) then
			for k, v in pairs(v.moons) do
				
			end
		end
		]]--
	end
end
--END HELPER FUNCTIONS--

--CONFIG--
--END CONFIG--
function ENT:Initialize()
	self.time = 0
	self.config = {
		quality = 50, --vertexes
		dynamic_quality = true,
		scale = 0.5,
		sun = {
			model = "models/Holograms/hq_icosphere.mdl",
			size = Vector(),
			glow = {
					r = 255,
					g = 255,
					b = 255,
					Brightness = 3,
					Size = 1024,
					Style = 0
				}
		},
		planets = {--TODO: MAKE THIS LESS STATIC!
			{
				--PATH--
				radius = 50, --gmod units
				offset = Vector(0, 0, 0),
				pathangle = Angle(5, -5, 5),
				pathcolor = Color(255, 255, 255, 255),
				scale = Vector(1, 1, 1),
				pathwidth = 4,
				pathmaterial = Material("cable/physbeam"),
				--END PATH--
				
				--PLANET
				speed = 11, --degrees
				rotation = 10, --degrees
				axis = Vector(0, 0, 1), --axis the planet rotates around
				model = "models/Holograms/hq_icosphere.mdl", --Planet model
				size = Vector(1, 1, 1), --planet size
				glow = {
					r = 255,
					g = 255,
					b = 255,
					brightness = 128,
					style = 0
				},
				sprite = {
					w = 1,
					h = 1,
					material = Material("cable/physbeam"),
					r = 255,
					g = 255,
					b = 255
				},
				moons = {
				}
				--END PLANET--
			}, {
				radius = 150, --gmod units
				offset = Vector(0, 0, 0),
				speed = 9, --degrees
				rotation = 10, --degrees
				axis = Vector(0, 0, 1), --axis the planet rotates around
				model = "models/Holograms/hq_icosphere.mdl", --Planet model
				size = Vector(1, 1, 1), --planet size
				pathangle = Angle(5, 0, 0),
				pathcolor = Color(255, 255, 255, 255),
				scale = Vector(1, 1, 1),
				pathwidth = 4,
				pathmaterial = Material("cable/physbeam")
			}, {
				radius = 250, --gmod units
				offset = Vector(0, 0, 0),
				speed = 7, --degrees
				rotation = 10, --degrees
				axis = Vector(0, 0, 1), --axis the planet rotates around
				model = "models/Holograms/hq_icosphere.mdl", --Planet model
				size = Vector(1, 1, 1), --planet size
				pathangle = Angle(2, 5, 10),
				pathcolor = Color(255, 255, 255, 255),
				scale = Vector(1, 1, 1),
				pathwidth = 4,
				pathmaterial = Material("cable/physbeam")
			}, {
				radius = 75, --gmod units
				offset = Vector(0, 0, 0),
				speed = 3, --degrees
				rotation = 10, --degrees
				axis = Vector(0, 0, 1), --axis the planet rotates around
				model = "models/Holograms/hq_icosphere.mdl", --Planet model
				size = Vector(1, 1, 1), --planet size
				pathangle = Angle(5, 5, 15),
				pathcolor = Color(255, 255, 255, 255),
				scale = Vector(1, 1, 1),
				pathwidth = 4,
				pathmaterial = Material("cable/physbeam")
			}, {
				radius = 400, --gmod units
				offset = Vector(0, 0, 0),
				speed = 2, --degrees
				rotation = 10, --degrees
				axis = Vector(0, 0, 1), --axis the planet rotates around
				model = "models/Holograms/hq_icosphere.mdl", --Planet model
				size = Vector(1, 1, 1), --planet size
				pathangle = Angle(0, 5, 1),
				pathcolor = Color(255, 255, 255, 255),
				scale = Vector(1, 1, 1),
				pathwidth = 4,
				pathmaterial = Material("cable/physbeam")
			}, {
				radius = 300, --gmod units
				offset = Vector(0, 0, 0),
				speed = 4, --degrees/sec
				rotation = 10, --degrees/sec
				axis = Vector(0, 0, 1), --axis the planet rotates around
				model = "models/Holograms/hq_icosphere.mdl", --Planet model
				size = Vector(1, 1, 1), --planet size
				pathangle = Angle(-25, 5, 5),
				pathcolor = Color(255, 255, 255, 255),
				scale = Vector(1, 1, 1),
				pathwidth = 4,
				pathmaterial = Material("cable/physbeam")
			}
		}
	}
	self:PreCalculate()
	self:SetupPlanets()
end

local col
local rad
local pwidth
local qual
local pcolor
local ang
local pos
local tscale
local epos
local rt
local dynlight
local scale
local cScale
local time
function ENT:Draw()
	local config = self.config

	epos = self:GetPos()
	time = CurTime()
	scale = config.scale
	if(config.dynamic_quality) then
		qual = mClamp(mfloor(90000/EyePos():Distance(epos)), 8, 128)
		config.quality = qual
		self:PreCalculate()
	else
		qual = config.quality
	end
	local sins = self.sins
	local coss = self.coss
	--qual = config.quality
	
	for k, v in next, config.planets do
		ang = v.pathangle+self:GetAngles()
		pos = epos+v.offset
		mat:SetAngles(ang)
		mat:SetTranslation(pos)
		cScale = v.scale*scale
		mat:Scale(cScale)
		--BEAM DRAWING
		cPushModelMatrix(mat)
			rSetMaterial(v.pathmaterial)
			rad = v.radius
			pwidth = v.pathwidth/((cScale.x+cScale.y)/2)
			pcolor = v.pathcolor
			rStartBeam(qual+1)
				for i = 1, qual do
					cache_vector.x = coss[i]*rad
					cache_vector.y = sins[i]*rad
					rAddBeam(cache_vector, pwidth, 0, pcolor)
				end
				cache_vector.x = coss[1]*rad
				cache_vector.y = sins[1]*rad
				rAddBeam(cache_vector, pwidth, 0, pcolor)
			rEndBeam()
		cPopModelMatrix()
		--BEAM DRAWING END--
		
		--PLANET DRAWING--
		local plnt = v.planet
		if(plnt) then
			local t = mrad(time*v.speed)
			cache_vector.x = mcos(t)*rad	
			cache_vector.y = msin(t)*rad
			pos, ang = LocalToWorld(cache_vector*v.scale*scale, dummy_angle, pos, ang)
			plnt:SetPos(pos)
	
			ang:RotateAroundAxis(v.axis, v.rotation*time)
			
			plnt:SetAngles(ang)
		end
		--PLANET DRAWING END--
	end
	--SUN--
	local curTime = CurTime()
	if(curTime >= self._nextDynLight) then
		self._nextDynLight = curTime + 0.1
		local dynLight = DynamicLight(self:EntIndex())--DURP
		for k, v in next, self.config.sun.glow do
			dynLight[k] = v
		end
		dynLight.Decay = 200
		self.dynLight = dynlight
		
		dynLight.DieTime = curTime + 0.1
		dynLight.Pos = epos
		--SUN END--
		self:DrawModel()
	end
end

function ENT:OnRemove()
	for k, v in next, self.config.planets do
		v.planet:Remove()
	end
end