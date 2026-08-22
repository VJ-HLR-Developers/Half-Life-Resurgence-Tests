AddCSLuaFile()

SWEP.Base 								= "weapon_vj_base"
SWEP.PrintName							= "Dual Pistols"
SWEP.Author 							= "Cpt. Hazama"
SWEP.Contact							= ""

SWEP.WorldModel							= "models/weapons/w_pistol.mdl"
SWEP.HoldType 							= "pistol"

SWEP.NPC_NextPrimaryFire 				= 0.08
SWEP.NPC_TimeUntilFire 					= 0
SWEP.NPC_TimeUntilFireExtraTimers 		= {}

SWEP.Primary.Sound						= {"Weapon_Pistol.Single"}
SWEP.Primary.DistantSound				= {"Weapon_Pistol.NPC_Single"}
SWEP.Primary.Damage						= 6
SWEP.Primary.ClipSize					= 999

SWEP.PrimaryEffects_MuzzleFlash 		= false
SWEP.PrimaryEffects_SpawnShells 		= false

SWEP.Primary.Force						= 5
SWEP.Primary.Ammo						= "Pistol"
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:Init()
	self:SetDrawWorldModel(false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttackEffects(owner)
	ParticleEffectAttach("vj_rifle_full", PATTACH_POINT_FOLLOW, self:GetOwner(), self.CurrentMuzzle == "left" && 1 or 2)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnAnimEvent(pos, ang, event, options)
	if event == 5001 then return true end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:OnGetBulletPos()
	local att = self.CurrentMuzzle == "left" && 1 or 2
	return self:GetOwner():GetAttachment(att).Pos
end