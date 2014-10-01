GM.Name = "SpaceAge2"
GM.Author = "Wizard"
GM.Email = "webmaster@spaceage.eu"
GM.Website = "http://www.spaceage.eu"
GM.TeamBased = false

--CalcMainActivity handled by base

function GM:CanPlayerEnterVehicle(ply, vehicle, role)
	return true
end

function GM:ContextScreenClick(vec, button, pressed, ply)
end

function GM:CreateTeams()
end

--DoAnimationEvent handled by base


function GM:EntityKeyValue(ent, key, value)
end

function GM:EntityRemoved(ent)
end

function GM:FinishMove(ply, move)
end

function GM:GravGunPunt(ply, ent)
	return true
end

--HandlePlayerDriving handled by base
--HandlePlayerDucking handled by base
--HandlePlayerJumping handled by base
--HandlePlayerSwimming handled by base

function GM:Initialize()
	self:StartLoader()
	self.IsInitialized = true
end

function GM:KeyPress(ply, key)
end

function GM:KeyRelease(ply, key)
end

function GM:Move(ply, moveData)
end

function GM:OnEntityCreated(ent)
end

--OnPlayerHitGround handled seperated

function GM:PhysgunDrop(ply, ent)
end

function GM:PhysgunPickup(ply, ent)
	return true
end

function GM:PlayerAuthed(ply, steamID, uniqueID)
end

function GM:PlayerConnect(name, ip)
end

function GM:PlayerEnteredVehicle(ply, vehicle, role)
end

function GM:PlayerFootstep(ply, vPos, iFoot, strSoundName, fVolume, pFilter)
end

function GM:PlayerNoClip()
	return true
end

local fStepTime
local fMaxSpeed
function GM:PlayerStepSoundTime(ply, iType, bWalking)
	fStepTime = 650
	fMaxSpeed = ply:GetMaxSpeed()
	if (iType == STEPSOUNDTIME_NORMAL || iType == STEPSOUNDTIME_WATER_FOOT) then
		if (fMaxSpeed <= 100) then 
			fStepTime = 400
		elseif (fMaxSpeed <= 300) then 
			fStepTime = 350
		else 
			fStepTime = 300 
		end
	elseif (iType == STEPSOUNDTIME_ON_LADDER) then
		fStepTime = 450 
	elseif (iType == STEPSOUNDTIME_WATER_KNEE) then
		fStepTime = 600 
	end
	
	-- Step slower if crouching
	if (ply:Crouching()) then
		fStepTime = fStepTime + 100
	end
	return fStepTime
end

function GM:PlayerTraceAttack(ply, dmginfo, dir, trace)
	return false
end

function GM:PostGamemodeLoaded()
end

function GM:PropBreak(attacker, prop)
end
--Restored handled by base
--Saved handled by base
function GM:SetupMove(ply, move)
end

function GM:ShouldCollide(Ent1, Ent2)
	return true
end

function GM:ShutDown()
end

function GM:Think()
end

function GM:Tick()
end
--TranslateActivity
--UpdateAnimation

function net.SendFilter(ply)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end