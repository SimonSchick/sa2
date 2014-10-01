include("subsystems/cl_boot.lua")
include("shared.lua")

--AddDeathNotice not required

local ply
function GM:AdjustMouseSensitivity(def)
	ply = LocalPlayer()
	if (not ply or not ply:IsValid()) then
		return -1
	end

	local wep = ply:GetActiveWeapon()
	if (wep and wep.AdjustMouseSensitivity) then
		return wep:AdjustMouseSensitivity()
	end

	return -1
end

function GM:CalcVehicleThirdPersonView(vehicle, ply, origin, angles, fov, znear, zfar)
	local view = {
		angles = angles,
		fov = fov
	}
	
	if (not Vehicle.CalcView) then
		local min, max = Vehicle:WorldSpaceAABB()
		max:Sub(min)
		
		Vehicle.CalcView = {
			OffsetUp = max.z,
			OffsetOut = (max.x + max.y + max.z) * 0.33
		}
	end
	
	-- Trace back from the original eye position, so we don't clip through walls/objects
	local TargetOrigin = Vehicle:GetPos() + (view.angles:Up() * Vehicle.CalcView.OffsetUp * 0.66) + (view.angles:Forward() * -Vehicle.CalcView.OffsetOut)
	 
	local tr = util.TraceLine({
		start = origin,
		endpos = TargetOrigin,
		filter = Vehicle
	}) 
	
	view.origin = origin + tr.Normal * ((origin - TargetOrigin):Length() - 10) * tr.Fraction

	return view
end

local view = {
	origin = Vector(),
	angles = Angle(),
	fov = fov,
	znear = znear,
	zfar = zfar
}

local nilView = {}

function GM:CalcView(ply, origin, angles, fov, znear, zfar)

	local ragdoll = ply:GetRagdollEntity()
	if(ragdoll && ragdoll ~= NULL && ragdoll:IsValid()) then

		local eyes = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
		view.znear = 0.5
		view.origin = eyes.Pos
		view.angles = eyes.Ang
		view.fov = 90

		return view
	end
	
	local Vehicle = ply:GetVehicle()
	local wep = ply:GetActiveWeapon()

	
	if (ValidEntity(Vehicle) and gmod_vehicle_viewmode:GetBool() and ply:ShouldDrawLocalPlayer()) then
		return GAMEMODE:CalcVehicleThirdPersonView(Vehicle, ply, origin*1, angles*1, fov, znear, zfar)
	end

	if (ValidEntity(wep)) then
	
		local func = wep.GetViewModelPosition
		if (func) then
			view.vm_origin,  view.vm_angles = func(wep, origin*1, angles*1) -- Note: *1 to copy the object so the child function can't edit it.
		end
		
		func = wep.CalcView
		if (func) then
			view.origin, view.angles, view.fov = func(wep, ply, origin*1, angles*1, fov) -- Note: *1 to copy the object so the child function can't edit it.
		end
	end
	return nilView
end

function GM:ChatText(playerindex, playername, text, filter)
	return false
end

function GM:ChatTextChanged(text)
end

function GM:CreateMove(cmd)
end

function GM:DrawMonitors()
end

local braceColor = Color(0, 0, 255, 255)
local inBraceColor = Color(255, 0, 0, 255)
function GM:Error(str, ...)
	MsgC(braceColor, "[")
	MsgC(inBraceColor, "SA")
	MsgC(braceColor, "]")
	MsgC(Color(255, 50, 0, 255), 
		string.format(str.."\n", ...)
	)
end

function GM:FinishChat()
end

function GM:ForceDermaSkin()
end

function GM:GetMotionBlurValues(x, y, fwd, spin)
	return x, y, fwd, spin
end

local teamID
function GM:GetTeamColor(ent)
	teamID = TEAM_UNASSIGNED
	if (ent.Team) then
		teamID = ent:Team()
	end
	return GAMEMODE:GetTeamNumColor(teamID)
end

function GM:GetTeamNumColor(num)
	return team.GetColor(num)
end
--GetTeamScoreInfo --unused

function GM:GetVehicles()
	return vehicles.GetTable()
end

function GM:GUIMouseDoublePressed(mouseCode, aimVec)
end

function GM:GUIMousePressed(mouseCode, AimVector)
end

function GM:GUIMouseReleased(mouseCode, AimVector)
end

function GM:HUDAmmoPickedUp(itemname, amount)
end

function GM:HUDDrawScoreBoard()
end

function GM:HUDItemPickedUp()
end

function GM:HUDPaint()
end

function GM:HUDPaintBackground()
end

function GM:HUDShouldDraw(elem)
	if(elem == "CHudHealth" or elem == "CHudBattery" or
	elem == "CHudCrosshair" or elem == "CHudAmmo" or
	elem == "CHudSecondaryAmmo") then
		return false
	end
	return true
end

function GM:HUDWeaponPickedUp(weapon)
end

function GM:InputMouseApply(cmd, x, y, angle)
end
function GM:OnAchievementAchieved(ply, achid)
	chat.AddText(ply, Color(230, 230, 230), " earned the *worthless* achievement ", Color(255, 200, 0), achievements.GetName(achid))
end

local lastWord
local lastLen
local plyName
function GM:OnChatTab(str)
	lastWord = str:match("%a+$"):lower()
	lastLen = lastWord:len()
	if lastWord then
		return str
	end
	
	for k, v in next, player.GetAll() do
		plyName = v:Nick()
		if (lastLen < plyName:len() and plyName:lower():find(lastWord, 1, true)) then
			return str:sub(1, (lastLen * -1) - 1) .. plyName
		end		
	end
	return str
end

--OnContextMenuClose sandbox
--OnContextMenuOpen sandbox
function GM:OnPlayerChat(player, strText, bTeamOnly, bPlayerIsDead)
	local tab = {}
	
	if (bPlayerIsDead) then
		table.insert(tab, Color(255, 30, 40))
		table.insert(tab, "*DEAD* ")
	end
	
	if (bTeamOnly) then
		table.insert(tab, Color(30, 160, 40))
		table.insert(tab, "(TEAM) ")
	end
	
	if (IsValid(player)) then
		table.insert(tab, player)
	else
		table.insert(tab, "*Console*")
	end
	
	table.insert(tab, Color(255, 255, 255))
	table.insert(tab, ": "..strText)
	
	chat.AddText(unpack(tab))

	return true
end
--OnSpawnMenuClose Sandbox
--OnSpawnMenuOpen Sandbox
function GM:PlayerBindPress(ply, bind, pressed)
	-- If we're driving, toggle third person view using duck
	if (pressed && bind == "+duck" && ValidEntity(ply:GetVehicle())) then
	
		local iVal = gmod_vehicle_viewmode:GetInt()
		if (iVal == 0) then iVal = 1 else iVal = 0 end
		RunConsoleCommand("gmod_vehicle_viewmode", iVal)
		return true
		
	end

	return false	
	
end
function GM:PlayerEndVoice(ply)
end

function GM:PlayerStartVoice(ply)
end


--PopulateToolMenu Sandbox
function GM:PostDrawEffects()
end

function GM:PostDrawHUD()
end

function GM:PostDrawOpaqueRenderables(bDrawingDepth, bDrawingSkybox)
end

function GM:PostDrawSkyBox(bDrawingDepth, bDrawingSkybox)
end

function GM:PostDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
end

function GM:PostDrawViewModel(ViewModel, Weapon, Player)
	if (!IsValid(Weapon)) then return false end
	if (Weapon.PostDrawViewModel == nil) then return false end
	return Weapon:PostDrawViewModel(ViewModel, Weapon, Player)
end

function GM:PrePlayerDraw(ply)
end

function GM:PostPlayerDraw(ply)
end

function GM:PostRenderVGUI()
end

function GM:PreDrawEffects()
end

function GM:PreDrawHUD()
end

function GM:PreDrawOpaqueRenderables(bDrawingDepth, bDrawingSkybox)
end

function GM:PreDrawSkyBox()
end

function GM:PreDrawTranslucentRenderables(bDrawingDepth, bDrawingSkybox)
end

function GM:PreDrawViewModel(ViewModel, Weapon, Player)
	if (!IsValid(Weapon)) then return false end
	if (Weapon.PreDrawViewModel == nil) then return false end
	return Weapon:PreDrawViewModel(ViewModel, Weapon, Player)
end

function GM:Print(str, ...)
	MsgC(braceColor, "[")
	MsgC(inBraceColor, "SA")
	MsgC(braceColor, "][")
	MsgC(inBraceColor, "NOTICE")
	MsgC(braceColor, "]")
	MsgC(printCol, string.format(str.."\n", ...))
end

--PreReloadToolsMenu Sandbox
function GM:RenderScene(origin, angle, fov)
end

function GM:RenderScreenspaceEffects()
end

function GM:ScoreboardHide()
end

function GM:ScoreboardShow()
end

function GM:ShouldDrawLocalPlayer()
end

function GM:StartChat()
end

--SuppressHint Sandbox
function GM:VGUIMousePressed(panel, mousecode)
end

function GM:Warning(str, ...)
	MsgC(braceColor, "[")
	MsgC(inBraceColor, "SA")
	MsgC(braceColor, "][")
	MsgC(inBraceColor, "WARNING")
	MsgC(braceColor, "]")
	MsgC(warnCol, string.format(str.."\n", ...))
end

function GM:ShowHelp()
end

function GM:ShowSpare1()
end

function GM:ShowSpare2()
end

function GM:ShowTeam()
end

function GM:PreventScreenClicks( cmd )
	return true
end

function GM:GUIMousePressed(mousecode, AimVector)
end

function GM:GUIMouseReleased(mousecode, AimVector)

end