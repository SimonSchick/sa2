local PLUGIN = Plugin("Damagesystem")

local materialMultipliers = {
	metal_bouncy = 2.0,
	metal = 2.0,
	default = 1.0,
	dirt = 0.2,
	slipperyslime = 0.1,
	wood = 0.5,
	glass = 1.0,
	concrete_block = 1.5,
	ice = 0.4,
	rubber = 0.3,
	paper = 0.1,
	zombieflesh = 0.2,
	gmod_ice = 0.4,
	gmod_bouncy = 0.4,
	gmod_silent = 0.4,
	weapon = 2
}
function PLUGIN:OnEnable()
	local dmgFlags = DMG_GENERIC| DMG_CRUSH 		| DMG_BULLET |
					DMG_BURN	| DMG_BLAST 		| DMG_SHOCK |
					DMG_SONIC	| DMG_ENERGYBEAM 	| DMG_RADIATION |
					DMG_ACID 	| DMG_PLASMA		| DMG_BUCKSHOT
	
	local dmgKinetic = DMG_CRUSH | DMG_BULLET | DMG_BLAST | DMG_BUCKSHOT
	local dmgEnergetic = DMG_SHOCK | DMG_ENERGYBEAM | DMG_RADIATION | DMG_PLASMA | DMG_SONIC
	local dmgChemical = DMG_BURN | DMG_ACID
	hook.Add("OnEntityCreated", "SADamageSystem", function(ent)
		if(not ent:IsPlayer() and not ent:IsNPC() and not ent:IsWorld()) then
			local phys = ent:GetPhysicsObject()
			--if(phys:IsValid()) then
			if(pcall(_R.PhysObj.Wake, phys)) then
				local resistance = (phys:GetMass()*phys:GetVolume()^0.333)*materialMultipliers[phys:GetMaterial()]
				ent.__SADamageInfo = {
					hull = resistance,
					armor = resistance*0.8
				}
			end
		end
	end)
	hook.Add("EntityTakeDamage", "SADamageSystem", function(target, inflictor, attacker, dmg, dmgInf)
		if(not target:IsPlayer() and target.__SADamageInfo) then
			local dmgType = dmgInf:GetDamageType()
			
			local subStractedDamage = something
			if(target.__SADamageInfo.parent and target.__SADamageInfo.parent.__SADamageInfo.hull > 0) then
				target.__SADamageInfo.parent:TakeDamageInfo(dmgInf)
				return
			end
			local entDmgInf = target.__SADamageInfo
			local matches = 1
			
			dmgInf:Scale(entDmgInf.mulMain)
			if((dmgType & dmgFlags) ~= 0) then
				if((dmgType & dmgKinetic) ~= 0) then
					dmgInf:ScaleDamage(entDmgInf.mulKin)
					dmgInf:SubtractDamage(entDmgInf.resKin)
					matches = matches + 0.5
				end
				if((dmgType & dmgEnergetic) ~= 0) then
					dmgInf:ScaleDamage(entDmgInf.mulElec)
					dmgInf:SubtractDamage(entDmgInf.resEner)
					matches = matches + 0.5
				end
				if((dmgType & dmgChemical) ~= 0) then
					dmgInf:ScaleDamage(entDmgInf.mulChem)
					dmgInf:SubtractDamage(entDmgInf.resChem)
					matches = matches + 0.5
				end
				dmgType:Scale(matches)
			end
			--stuff
			target.__SADamageInfo = dmgInf:GetDamage()
		end
	end)
end

function PLUGIN:OnDisable()
	hook.Remove("OnEntityCreated", "SADamageSystem")
	hook.Remove("EntityTakeDamage", "SADamageSystem")
end

SA:RegisterPlugin(PLUGIN)