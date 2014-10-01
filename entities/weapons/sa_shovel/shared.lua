if CLIENT then
	SWEP.PrintName = "Shovel"
	SWEP.Slot = 0
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

GemTypes = {
	{ color = Color(255, 255, 255, 255), name = "Rock", value = 10 },
	{ color = Color(200, 200, 200, 255), name = "Granite", value = 20 },
	{ color = Color(150, 150, 150, 255), name = "Shale", value = 50 },
	{ color = Color(0, 255, 0, 255), name = "Emerald", value = 3000 },
	{ color = Color(255, 0, 0, 255), name = "Ruby", value = 10000 },
	{ color = Color(0, 0, 255, 255), name = "Sapphire", value = 50000 },
	{ color = Color(0, 0, 0, 255), name = "Obsidian", value = 250000 },	
	{ color = Color(255, 255, 255, 100), name = "Diamond", value = 1000000 }
}

SWEP.Author = "Raklatif"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = "Dig For Gems"

SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "crowbar"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true

SWEP.NextStrike = 0

SWEP.ViewModel = "models/weapons/v_shovel.mdl"
SWEP.WorldModel = "models/weapons/w_shovel.mdl"

SWEP.Sound = Sound("weapons/iceaxe/iceaxe_swing1.wav")
SWEP.Clang1 = Sound("weapons/crowbar/crowbar_impact1.wav")
SWEP.Clang2 = Sound("weapons/crowbar/crowbar_impact2.wav")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.Animations = {
   ACT_VM_PRIMARYATTACK_1,
   ACT_VM_PRIMARYATTACK_2,
   ACT_VM_PRIMARYATTACK_3,
   ACT_VM_PRIMARYATTACK_4,
   ACT_VM_PRIMARYATTACK_5,
}

SWEP.Animations.Count = #SWEP.Animations

function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_IDLE );
	return true;
end

function SWEP:ThirdPAnim()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire(CurTime() + 1)
	if CurTime() < self.NextStrike then return end
	timer.Simple(0.5, function() self:SendWeaponAnim( ACT_VM_IDLE ) end)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound(self.Sound)

	self.NextStrike = CurTime() + 1

	local ply = self.Owner
	local trace = { }
	trace.start = ply:GetShootPos()
	trace.endpos = trace.start + ply:GetAimVector() * 95
	trace.filter = ply
	local tr = util.TraceLine(trace)
	
	if tr.HitWorld then
		Msg( "Hit Ground!\n" )
		if math.random(1,2) == 2 then
			self:EmitSound(self.Clang1)
		else
			self:EmitSound(self.Clang2)
		end
	end
end

function SWEP:SecondaryAttack()
	if CurTime() < self.NextStrike then return end
	self.NextStrike = CurTime() + 0.3
end

if CLIENT then	
end


