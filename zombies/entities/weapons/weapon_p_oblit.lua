AddCSLuaFile()
if CLIENT then
	SWEP.PrintName = "Obliterator Handgun"
	SWEP.Slot = 1
	SWEP.SlotPos = 0
	SWEP.ViewModelFlip = true
	SWEP.ViewModelFOV = 60
end
SWEP.Base = "weapon_zs_base"
SWEP.HoldType = "pistol"
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true
SWEP.CSMuzzleFlashes = false
SWEP.ReloadSound = Sound("Weapon_Pistol.Reload")
SWEP.Primary.Sound = Sound("Weapon_Pistol.NPC_Single")
SWEP.Primary.Damage = 14
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.ClipSize = 12
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"
SWEP.ConeMax = 0.08
SWEP.ConeMin = 0.04
SWEP.IronSightsPos = Vector(-5.95, 3, 2.75)
SWEP.IronSightsAng = Vector(-0.15, -1, 2)