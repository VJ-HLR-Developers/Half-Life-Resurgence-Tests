AddCSLuaFile()

sound.Add({
	name = "VJ.HL2R.BetaHMG1.Fire",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 140,
	pitch = {95, 105},
	sound = {"vj_hlr/src/wep/hmg1/hmg1_7.wav", "vj_hlr/src/wep/hmg1/hmg1_8.wav", "vj_hlr/src/wep/hmg1/hmg1_9.wav"}
})

SWEP.Base = "weapon_vj_base"
SWEP.PrintName = "GR9 Heavy Machine Gun"
SWEP.Author = "DrVrej"
SWEP.Contact = "http://steamcommunity.com/groups/vrejgaming"
SWEP.Spawnable = false
SWEP.Category = "Half-Life Resurgence"

SWEP.ViewModel = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/vj_hlr/hl2b/weapons/w_hmg1.mdl"
SWEP.HoldType = "ar2"
SWEP.Slot = 3
SWEP.SlotPos = 4
SWEP.UseHands = true

SWEP.MadeForNPCsOnly = true
SWEP.NPC_CustomSpread = 1.768
SWEP.NPC_NextPrimaryFire = 0.08
SWEP.NPC_ReloadSound = "vj_hlr/src/wep/hmg1/hmg_reload.wav"

SWEP.Primary.Damage = 15
SWEP.Primary.ClipSize = 30
SWEP.Primary.Force = 1
SWEP.Primary.Recoil = 0.7
SWEP.Primary.Delay = 0.07
SWEP.Primary.Cone = 18
SWEP.Primary.Ammo = "AR2"
SWEP.Primary.Sound = "VJ.HL2R.BetaHMG1.Fire"
SWEP.PrimaryEffects_MuzzleAttachment = "muzzle"
SWEP.PrimaryEffects_ShellAttachment = "eject"
SWEP.PrimaryEffects_ShellType = "RifleShellEject"

SWEP.ReloadSound = "vj_hlr/src/wep/hmg1/hmg_reload.wav"