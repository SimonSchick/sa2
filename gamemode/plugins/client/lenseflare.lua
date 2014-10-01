local PLUGIN = Plugin("Lenseflare", {})

function PLUGIN:OnEnable()
	local iris = surface.GetTextureID("lensflare/iris")
	local flare = surface.GetTextureID("lensflare/flare")
	local color_ring = surface.GetTextureID("lensflare/color_ring")
	local bar = surface.GetTextureID("lensflare/bar")
	local sDrawTexturedRect = surface.DrawTexturedRect
	local sSetDrawColor = surface.SetDrawColor
	local sSetTexture = surface.SetTexture

	local ScrW, ScrH = ScrW, ScrH

	local function DrawLensFlare(mul, sunx, suny, colr, colg, colb, cola)
		if mul == 0 then return end
		local w, h = ScrW(), ScrH()
		local w2, h2 = w/2, h/2
		mul = mul + math.Rand(0, 0.0001)
		local sz = w * 0.15*mul
		
		local val = sunx - w2
		local val2 = suny - h2

		local alpha = 255 * math.pow(cola, 3)
		
		sSetTexture(flare)
		sSetDrawColor(255*colr, 230*colg, 180*colb, 255 * cola)
		local csz, csz2 = sz*25, sz*12.5
		sDrawTexturedRect(sunx - csz2, suny - csz2, csz, csz)

		sSetTexture(color_ring)
		sSetDrawColor(255*colr, 255*colg, 255*colb, alpha * 3.137)
		csz, csz2 = sz*1.5, sz* 0.75
		sDrawTexturedRect(val*0.5+w2-csz2, val2*0.5+h2 - csz2, csz, csz)

		sSetTexture(bar)
		sSetDrawColor(255*colr, 230*colg, 180*colb, alpha)
		csz, csz2 = sz*10, sz* 0.5
		sDrawTexturedRect(val*-0.5+w2-csz2, val2*-0.5+h2-csz2, csz, csz)
		
		sSetTexture(iris)
		sSetDrawColor(255*colr, 230*colg, 180*colb, alpha)
		csz, csz2 = sz*1.5, sz* 0.75
		sDrawTexturedRect(val*1.8+w2-csz2, val2*1.8+h2-csz2, csz, csz)
		csz, csz2 = sz*0.15, sz* 0.075
		sDrawTexturedRect(val*1.82+w2-csz2, val2*1.82+h2-csz2, csz, csz)
		csz, csz2 = sz*0.1, sz* 0.5
		sDrawTexturedRect(val*1.5+w2-csz2, val2*1.5+h2-csz2, csz, csz)
		csz, csz2 = sz*0.05, sz* 0.025
		sDrawTexturedRect(val*0.6+w2-csz2, val2*0.6+h2-csz2, csz, csz)
		csz, csz2 = sz*0.05, sz* 0.025
		sDrawTexturedRect(val*0.59+w2-csz2, val2*0.59+h2-csz2, csz, csz)
		csz, csz2 = sz*0.15, sz* 0.075
		sDrawTexturedRect(val*0.3+w2-csz2, val2*0.3+h2-csz2, csz, csz)
		csz, csz2 = sz*0.1, sz* 0.05
		sDrawTexturedRect(val*-0.7+w2-csz2, val2*-0.7+h2-csz2, csz, csz)
		csz, csz2 = sz*0.1, sz* 0.05
		sDrawTexturedRect(val*-0.72+w2-csz2, val2*-0.72+h2-csz2, csz, csz)
		csz, csz2 = sz*0.15, sz* 0.075
		sDrawTexturedRect(val*-0.73+w2-csz2, val2*-0.73+h2-csz2, csz, csz)
		csz, csz2 = sz*0.05, sz* 0.025
		sDrawTexturedRect(val*-0.9+w2-csz2, val2*-0.9+h2-csz2, csz, csz)
		csz, csz2 = sz*0.1, sz* 0.05
		sDrawTexturedRect(val*-0.92+w2-csz2, val2*-0.92+h2-csz2, csz, csz)
		csz, csz2 = sz*0.05, sz* 0.025
		sDrawTexturedRect(val*-1.3+w2-csz2, val2*-1.3+h2-csz2, csz, csz)
		csz2 = sz* 0.5
		sDrawTexturedRect(val*-1.5+w2-csz2, val2*-1.5+h2-csz2, sz, sz)
		csz, csz2 = sz*0.15, sz* 0.075
		sDrawTexturedRect(val*-1.7+w2-csz2, val2*-1.7+h2-csz2, csz, csz)
	end
	
	local itensity, r, g, b, a = SA:CallEvent("GetLenseFlareValues")
	
	if(not intensity) then
		itensity = 0.5
		r = 0.6
		g = 0.6
		b = 0.6
		a = 0.6
	end
	
	local sunPos = Vector(0, 0, 0)
	local sunPos2D
	
	local mpow = math.pow
	local mClamp = math.Clamp
	local EyeVector = EyeVector
	
	hook.Add("RenderScreenspaceEffects", "SALensFlare", function()
		local sun = util.GetSunInfo()
		if(not sun) then
			hook.Remove("RenderScreenspaceEffects", "SALensFlare")--no sun D:
			return
		end
		local obs = sun.obstruction
		local dir = sun.direction
		if obs ~= 0 then
			sunPos:Zero()
			sunPos:Add(dir)
			sunPos:Mul(4096)
			sunPos:Add(EyePos())
			
			sunPos2D = sunPos:ToScreen()
			DrawLensFlare(
				mClamp((dir:Dot(EyeVector()) - 0.4) * (1 - mpow(1 - obs, 2)), 0, 1) * itensity,
				sunPos2D.x,
				sunPos2D.y,
				r, g, b, a
			)
		end
	end)
end

function PLUGIN:OnDisable()
	hook.Remove("RenderScreenspaceEffects", "SALensFlare")
end

SA:RegisterPlugin(PLUGIN)