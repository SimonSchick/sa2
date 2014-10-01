if SERVER then
	AddCSLuaFile( "shared.lua" )
end

SWEP.Base				= "weapon_base"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.PrintName 			= "Scanner"
SWEP.Slot			= 0
SWEP.SlotPos			= 0

SWEP.ViewModel			= "models/weapons/v_smg1.mdl"
SWEP.WorldModel 		= "models/weapons/w_smg1.mdl"
SWEP.ViewModelFlip		= false

SWEP.Primary.Automatic		= false
SWEP.Primary.Delay		= 1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Delay		= 1

SWEP.HoldType			= "rpg"

SWEP.ScanModeTexts = {"X-Ray"}
SWEP.Enabled = false
SWEP.ScanMode = 1
SWEP.ScanModeText = SWEP.ScanModeTexts[1]
SWEP.MaxScanMode = #SWEP.ScanModeTexts

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:Precache()
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self.Enabled = not self.Enabled
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	if self.ScanMode >= self.MaxScanMode then
		self.ScanMode = 1
		self.ScanModeText = self.ScanModeTexts[1]
		return
	end
	self.ScanMode = self.ScanMode + 1
	self.ScanModeText = self.ScanModeTexts[self.ScanMode]
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
end

function SWEP:Reload()
	self.ScanMode = 1
	self.ScanModeText = self.ScanModeTexts[1]
	self.Enabled = false
end

function SWEP:Holster( wep )
	self.Enabled = false
	return true
end

function SWEP:OnRemove()
	self.Enabled = false
end

if CLIENT then
	function SWEP:ViewModelDrawn()
		local vmodel = self.Owner:GetViewModel()
		local struct = vmodel:GetAttachment(vmodel:LookupAttachment("1"))
		local pos,ang
		ang = struct.Ang
		if not self.Enabled then
			ang:RotateAroundAxis(ang:Forward(), -30)
			pos = Vector(-20,10,-12)
		else
			pos = Vector(-20,10,-12)
		end
		pos:Rotate(ang)
		pos = pos + struct.Pos
		cam.Start3D2D(pos, ang, 0.025)
			cam.IgnoreZ(true)
			
			--BG
			surface.SetDrawColor(0,0,0,200)
			surface.DrawRect(0,0,600,400)
			
			--Content
			
			
			--Outline
			surface.SetDrawColor(255,255,255,255)
			surface.DrawOutlinedRect(0,0,600,400)
			cam.IgnoreZ(false)
		cam.End3D2D()
	end
end