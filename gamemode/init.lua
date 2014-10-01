if(SAWasLoaded) then
	GM = SA
	GAMEMODE = SA
	return
end
include("subsystems/boot.lua")
 
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
 
include("shared.lua")

local braceColor = Color(0, 0, 255, 255)
local inBraceColor = Color(255, 0, 0, 255)
local errorCol = Color(255, 20, 0, 255)
local warnCol = Color(255, 255, 0, 0)
local printCol = Color(20, 255, 0, 0)

SAWasLoaded = true
function GM:AllowPlayerPickup(ply, ent)
	return true
end

local validSpawnPointTypes = {
	"info_player_deathmatch",--hl2dm 
	"info_player_combine",
	"info_player_rebel",
	
	"info_player_counterterrorist",--cs:s
	"info_player_terrorist",
	
	"info_player_axis",--dod:s
	"info_player_allies",
	
	"gmod_player_start",--gmod old
	"info_player_start",
	"info_player_teamspawn"--tf2
}

function GM:BuildPlayerSpawnTable()
	self._validSpawnPoints = {}
	local find
	for i = 1, #validSpawnPointTypes do
		find = ents.FindByClass(validSpawnPointTypes[i])
		for k = 1, #find do
			if (find[k]:HasSpawnFlags(1)) then--master spawn flag
				self._validSpawnPoints = {find[k]}
				return
			end
			table.insert(self._validSpawnPoints, find[k])
		end
	end
end

function GM:CanExitVehicle(ply, vec)
	return true
end

function GM:CanPlayerSuicide(ply)
	return true
end

function GM:CanPlayerUnfreeze(ply, ent, physObj)
	return false
end

function GM:CreateEntityRagdoll(ent, ragdoll)
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	ply:CreateRagdoll()
	ply:AddDeaths(1)
	
	if(attacker:IsValid() and attacker:IsPlayer()) then
		if(attacker ~= ply) then
			attacker:AddFrags(1)
		end
	end
end

function GM:EntityTakeDamage(ent, inflictor, attacker, amount, dmginfo)
	if(ent:IsPlayer()) then
		hook.Call("PlayerTakeDamage", self, ent, inflictor, attacker, amount, dmginfo)
	end
	if(ent:IsNPC()) then
		hook.Call("NPCTakeDamage", self, ent, inflictor, attacker, amount, dmginfo)
	end
end

function GM:Error(str, ...)
	ErrorNoHalt(
		string.format(
			"[SA] %s",
			string.format(str, ...)
		)
	)
end

function GM:GetFallDamage(ply, speed)
	--speed = speed - 580
	--return speed * (100/(1024-580))
	return 0
end

function GM:GetGameDescription() 
 	return "SpaceAge2"
end

include(GM:GetConfigPath().."SERVERID.lua")
local sID = 1--tonumber(file.Find("gamemodes/"..GM.Folder.."/gamemode/config/SERVERID_*", "GAME_PATH")[1]:match("SERVERID_(%d)"))
function GM:GetServerID()
	return sID
end

function GM:GravGunOnDropped(ply, ent)
end

function GM:GravGunOnPickedUp(ply, ent)
end

function GM:GravGunPickupAllowed(ply, ent)
	return true
end

local min = Vector(-16, -16, 0)
local max = Vector(16, 16, 64)
function GM:IsSpawnpointSuitable(ply, spawnpointent, bMakeSuitable)

	if(	not spawnpointent or
		not spawnpointent:IsValid() or
		not spawnpointent:IsInWorld() or
		spawnpointent == ply._lastSpawnpoint or
		spawnpointent == self.LastSpawnPoint) then
		return false
	end

	local pos = spawnpointent:GetPos()
	
	if (ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED) then
		return true
	end
	
	local blockers = 0
	for k, v in next, ents.FindInBox(pos + min, pos + max) do
		if (v:IsPlayer() and v:Alive()) then
		
			blockers = blockers + 1
			
			if (bMakeSuitable) then
				v:Kill()
			end
		end
	end
	
	if (bMakeSuitable) then
		return true
	end
	if (blockers > 0) then
		return false
	end
	return true
end

function GM:NetworkIDValidated(name, steamID)
end

function GM:OnDamagedByExplosion(ply, dmgInfo)
	ply:SetDSP(35, false)
end

function GM:OnNPCKilled(victim, attacker, inflictor)
end

function GM:OnPhysgunFreeze(weapon, physobj, ent, ply)
	if (!physobj:IsMoveable()) then return false end
	if (ent:GetUnFreezable()) then return false end
	
	physobj:EnableMotion(false)
	
	if (ent:GetClass() == "prop_vehicle_jeep") then
		local objects = ent:GetPhysicsObjectCount()
		for i=0, objects-1 do
			ent:GetPhysicsObjectNum(i):EnableMotion(false)
		end
	end
	ply:AddFrozenPhysicsObject(ent, physobj)
	return true
end

function GM:OnPhysgunReload(wpn, ply)
	ply:PhysgunUnfreeze()
end

local fallDamage = DamageInfo()
fallDamage:SetDamageType(DMG_FALL | DMG_CRUSH)
function GM:OnPlayerHitGround(ply, bInWater, bOnFloater, flFallSpeed)
	if((flFallSpeed - 500)/5 <= 0) then
		return true
	end
	fallDamage:SetInflictor(GetWorldEntity())
	fallDamage:SetAttacker(GetWorldEntity())
	fallDamage:SetDamage((flFallSpeed - 500)/5)
	ply:TakeDamageInfo(fallDamage)
	return false
end

function GM:PlayerCanHearPlayersVoice(listener, sender)
	return true
end

function GM:PlayerCanPickupItem(ply, item)
	return true
end

function GM:PlayerCanPickupWeapon(ply, wpn)
	return true
end

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
	return true
end

function GM:PlayerDeath(victim, inflictor, attacker)
end

function GM:PlayerDeathSound()
	return false
end

function GM:PlayerDeathThink(ply)
	if(not ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP)) then
		return
	end
	ply:Spawn()
end

function GM:PlayerDisconnected(ply)
end

function GM:PlayerHurt(victim, attacker)
end

function GM:PlayerInitialSpawn(ply)
end

function GM:PlayerLeaveVehicle(ply, vehicle)
end

function GM:PlayerLoadout(ply)
	ply:Give("weapon_physcannon")
	ply:Give("weapon_physgun")
	
	local cl_defaultweapon = ply:GetInfo("cl_defaultweapon")
	
	if(ply:HasWeapon(cl_defaultweapon)) then
		ply:SelectWeapon(cl_defaultweapon) 
	end
end

function GM:PlayerSay(ply, text, isPublic)
	return text
end

function GM:PlayerShouldAct(ply, actname, actid)
	return true
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	return true
end

function GM:PlayerSilentDeath(ply)
end

function GM:PlayerSpawn(ply)
	hook.Call("PlayerLoadout", self, ply)
	
	hook.Call("PlayerSetModel", self, ply)
end

function GM:PlayerSpawnAsSpectator(ply)
	ply:StripWeapons()
	if(ply:Team() == TEAM_UNASSIGNED)then
		ply:Spectate(OBS_MODE_FIXED)
		return
	end
	ply:SetTeam(TEAM_SPECTATOR)
	ply:Spectate(OBS_MODE_ROAMING)
end

function GM:PlayerSpray(ply)
	return false--allow
end

function GM:PlayerSwitchFlashlight(ply, isOn)
	return true
end

function GM:PlayerUse(ply, ent)
	return true
end

function GM:PlayerSelectSpawn(ply)

	if (#self._validSpawnPoints == 0) then
		Error("Could not find suitable spawn")
		return nil 
	end

	if(#self._validSpawnPoints == 1) then
		return self._validSpawnPoints[1]
	end

	if (self.TeamBased) then
		return self:PlayerSelectTeamSpawn(ply:Team(), ply)
	end
	
	local chosen
	
	-- Try to work out the best, random spawnpoint (in 6 goes)
	for i=0, 10 do
		chosen = table.Random(self._validSpawnPoints)
		if (self:IsSpawnpointSuitable(ply, chosen, i==10)) then
			self.LastSpawnPoint = chosen
			ply._lastSpawnpoint = chosen
			return chosen
		end
	end
	return chosen
end

function GM:PlayerSelectTeamSpawn(teamID, ply)
	local spawnPoints = team.GetSpawnPoints(TeamID)
	if (not spawnPoints or #SpawnPoints == 0) then
		return
	end
	
	local chosen = nil
	
	for i=0, 10 do
		local chosen = table.Random(SpawnPoints)
		if (self:IsSpawnpointSuitable(ply, chosen, i==10)) then
			return chosen
		end
	end
	return chosen
end

function GM:PlayerSetModel(ply)
	local modelname = player_manager.TranslatePlayerModel(ply:GetInfo("cl_playermodel"))
	util.PrecacheModel(modelname)
	ply:SetModel(modelname)
end

function GM:PlayerTakeDamage(ply, inflictor, attacker, amount, dmginfo)
end

function GM:Print(str, ...)
	MsgC(braceColor, "[")
	MsgC(inBraceColor, "SA")
	MsgC(braceColor, "][")
	MsgC(inBraceColor, "NOTICE")
	MsgC(braceColor, "]")
	MsgC(printCol, string.format(str.."\n", ...))
end

function GM:InitPostEntity()
	self:BuildPlayerSpawnTable()
end

function GM:ScaleNPCDamage(npc, hitgroup, dmginfo)
	if(hitgroup == HITGROUP_HEAD)then
		dmginfo:ScaleDamage(10)
	end

	if(hitgroup == HITGROUP_LEFTARM or
	hitgroup == HITGROUP_RIGHTARM or 
	hitgroup == HITGROUP_LEFTLEG or
	hitgroup == HITGROUP_RIGHTLEG or
	hitgroup == HITGROUP_GEAR)then
		dmginfo:ScaleDamage(0.25)
	end
end

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
	if (hitgroup == HITGROUP_HEAD) then
		dmginfo:ScaleDamage(5)
	end
	
	if (hitgroup == HITGROUP_LEFTARM or
	hitgroup == HITGROUP_RIGHTARM or 
	hitgroup == HITGROUP_LEFTLEG or
	hitgroup == HITGROUP_RIGHTLEG or
	hitgroup == HITGROUP_GEAR)then
		dmginfo:ScaleDamage(0.25)
	end
end

function GM:SetPlayerSpeed(ply, walkSpeed, runSpeed)
end

function GM:SetupPlayerVisibility(pPlayer, pViewEntity)
end

function GM:ShowHelp(ply)
end

function GM:ShowSpare1(ply)
end

function GM:ShowSpare2(ply)
end

function GM:ShowTeam(ply)
end

function GM:WeaponEquip(ply, weapon)
end

function GM:Warning(str, ...)
	MsgC(braceColor, "[")
	MsgC(inBraceColor, "SA")
	MsgC(braceColor, "][")
	MsgC(inBraceColor, "WARNING")
	MsgC(braceColor, "]")
	MsgC(warnCol, string.format(str.."\n", ...))
end