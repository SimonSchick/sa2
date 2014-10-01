local Vector = Vector
local Angle = Angle
local tinsert = table.insert

local ENV_CUBE = 1

local ENV_SIMPLE_BOX = 2
local ENV_SIMPLE_CYLINDER = 3
local ENV_SIMPLE_SPHERE = 4

local ENV_BOX = 5
local ENV_CYLINDER = 6
local ENV_SPHERE = 7
local ENV_COMPLEX_SPHERE = 8

local PLUGIN = Plugin("Enviroments")

local types = {}
local enviroments = {}

function PLUGIN:RegisterType(name, tbl)
	types[name] = tbl
end

function PLUGIN:GetType(name)
	return types[name]
end

function PLUGIN:Register(name, mode, _type, tbl)
	if(mode == ENV_CUBE) then--{pos1, pos2}
		enviroments[name] = {
			Mode = mode,
			Type = _type,
			Size = tbl[1],
			Mesh = generateCubeMesh(tbl[1])
		}
		return true
	end
	if(mode == ENV_SIMPLE_BOX) then--{pos1, pos2}
		enviroments[name] = {
			Mode = mode,
			Type = _type,
			Min = tbl[1],
			Max = tbl[2],
			Center = (tbl[2] + tbl[1])/2,
			Mesh = generateCubeMesh((tbl[2] + tbl[1])/2)
		}
		return true
	end
	if(mode == ENV_SIMPLE_CYLINDER) then--{pos, height, radius}
		enviroments[name] = {
			Mode = mode,
			Type = _type,
			Center = tbl[1],
			Height = tbl[2],
			Radius = tbl[3],
			Mesh = generateCylinderMesh(tbl[1], tbl[2], tbl[3])
		}
		return true
	end
	if(mode == ENV_SIMPLE_SPHERE) then--{pos, radius}
		enviroments[name] = {
			Mode = mode,
			Type = _type,
			Center = tbl[1],
			Radius = tbl[2],
			Mesh = generateSphereMesh(tbl[1], tbl[2], 15, 15), 
		}
		return true
	end
	if(mode == ENV_BOX) then--{pos1, size, ang}
		enviroments[name] = {
			Mode = mode,
			Type = _type,
			Min = tbl[1],
			Max = tbl[2],
			Center = (tbl[2] + tbl[1])/2,
			Angle = tbl[3],
			Mesh = generateBoxMesh((tbl[2] + tbl[1])/2)
		}
		return true
	end
	if(mode == ENV_CYLINDER) then--{pos, pos2, radius}
		enviroments[name] = {
			Mode = mode,
			Type = _type,
			Center = tbl[1],
			Height = tbl[2],
			Radius = tbl[3],
			Angle = tbl[4],
			Mesh = generateCylinderMesh(tbl[1], tbl[2], tbl[3])
		}
		return true
	end
	if(mode == ENV_SPHERE) then--{pos, radx, rady, radz}
		enviroments[name] = {
			Mode = mode,
			Type = _type,
			Center = tbl[1],
			RadX = tbl[2],
			RadY = tbl[3],
			RadZ = tbl[4],
			Mesh = generateSphereMesh3Rad(tbl[1], tbl[2], tbl[3], tbl[4], 15, 15)
		}
		return true
	end
	return false
end

function PLUGIN:GetAll()
	return enviroments
end

function PLUGIN:GetByType(mode)
	local tbl = {}
	for k, v in next, enviroments do
		if(v[1] == mode) then
			tbl[k] = v
		end
	end
	return tbl
end

function PLUGIN:GetByName(name)
	return enviroment[name]
end

local function checkCube(pos, size)
	return (pos.x >= -(pos.x)) and (size.x <= pos.x) and (-(size.y) >= pos.y) and (size.y <= pos.y) (size.z >= -(pos.z)) and (size.z <= pos.z)
end

local function checkBoxSimple(pos, min, max)
	return (max.x >= pos.x) and (min.x <= pos.x) and (max.y >= pos.y) and (min.y <= pos.y) (max.z >= pos.z) and (min.z <= pos.z)
end

local function checkCylinderSimple(pos, origin, height, rad)
	return (pos.z >= origin.z) and (pos.z <= origin.z + height) and (((origin.x - pos.x)^2 + (origin.y - pos.y)^2) <= rad^2)
end

local function checkSphereSimple(pos, origin, rad)
	return ((origin.x - pos.x)^2 + (origin.y - pos.y)^2 + (origin.z - pos.z)^2  <= rad^2)
end

local function checkBox(pos, min, max, ang)
	local pos, _ = WorldToLocal(pos, nullAng, max-min, ang)
	return (max.x >= pos.x) and (min.x <= pos.x) and (max.y >= pos.y) and (min.y <= pos.y) (max.z >= pos.z) and (min.z <= pos.z)
end

local function checkCylinder(pos, origin, ang, height, rad)
	local pos, _ = WorldToLocal(pos, nullAng, max-min, ang)
	return (pos.z >= min.z) and (pos.z <= min.z + height) and (((min.x - pos.x)^2 + (min.y - pos.y)^2) <= rad^2)
end

local function checkSphere(pos, origin, radX, radY, radZ)
	return (min.x >= pos.x + radX) and (min.x <= pos.x - radX) and (min.y >= pos.y + radY) and (min.y <= pos.y - radY) and (min.z >= pos.z + radZ) and (min.z <= pos.z - radZ)
end

local function checkComplexSphere(pos, origin, ang, rad)
	local pos, _ = WorldToLocal(pos, nullAng, max-min, ang)
	return (min.x >= pos.x + radX) and (min.x <= pos.x - radX) and (min.y >= pos.y + radY) and (min.y <= pos.y - radY) and (min.z >= pos.z + radZ) and (min.z <= pos.z - radZ)
end

function PLUGIN:GetEnviroments(pos)
	local envs = {}
	for k, v in next, enviroments do
		if(v[1] == ENV_CUBE) then
			if(checkCube(pos, v.Size)) then
				tinsert(envs, v)
				continue
			end
		end
		if(v[1] == ENV_SIMPLE_BOX) then
			if(checkBoxSimple(pos, v.Min, v[4].Max)) then
				tinsert(envs, v)
				continue
			end
		end
		if(v[1] == ENV_SIMPLE_SPHERE) then
			if(checkSphereSimple(pos, v[3].Center, v[4].Radius)) then
				tinsert(envs, v)
				continue
			end
		end
		if(v[1] == ENV_SIMPLE_CYLINDER) then
			if(checkCylinderSimple(pos, v.Center, v.Height, v.Radius)) then
				tinsert(envs, v)
				continue
			end
		end
		if(v[1] == ENV_BOX) then
			if(checkBox(pos, v.Min, v.Max, v.Ang)) then
				tinsert(envs, v)
				continue
			end
		end
		if(v[1] == ENV_SPHERE) then
			if(checkCylinder(pos, v.Center, v.Angle, v.Height, v.Height)) then
				tinsert(envs, v)
				continue
			end
		end
		if(v[1] == ENV_CYLINDER) then
			if(checkSphere(pos, v.Center, v.RadX, v.RadY, v.RadZ)) then
				tinsert(envs, v)
				continue
			end
		end
	end
end

function PLUGIN:GetPriorEnviroment(pos)
	local nearest_dist = 99999999999
	local nearest
	local val
	for k, v in next, GetEnviroments(pos) do
		val = ((v[3].x - pos.x)^2 + (v[3].y - pos.y)^2 + (v[3].z - pos.z)^2)
		if (val < nearest_pos) then
			nearest = v
			nearest_dist =  val
		end
	end
end

SA:RegisterPlugin(PLUGIN)