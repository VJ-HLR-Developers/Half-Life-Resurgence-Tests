AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/mortarsynth.mdl"
ENT.StartHealth = 80
ENT.HullType = HULL_TINY
ENT.MovementType = VJ_MOVETYPE_AERIAL
ENT.Aerial_FlyingSpeed_Calm = 180
ENT.Aerial_FlyingSpeed_Alerted = 250
ENT.Aerial_AnimTbl_Calm = ACT_IDLE
ENT.Aerial_AnimTbl_Alerted = "mortar_forward"
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.BloodColor = VJ.BLOOD_COLOR_BLUE

ENT.HasMeleeAttack = false
//ENT.AnimTbl_MeleeAttack = ACT_RANGE_ATTACK1
//ENT.MeleeAttackDistance = 60
//ENT.MeleeAttackDamageDistance = 80
//ENT.TimeUntilMeleeAttackDamage = 0.7
//ENT.NextAnyAttackTime_Melee = 1.3
//ENT.MeleeAttackDamage = 30

ENT.HasDeathCorpse = false
ENT.HasExtraMeleeAttackSounds = true

ENT.HasRangeAttack = true
ENT.AnimTbl_RangeAttack = ACT_RANGE_ATTACK1
ENT.RangeAttackProjectiles = "obj_vj_hlr2_mortar"
ENT.TimeUntilRangeAttackProjectileRelease = 0.7
ENT.NextRangeAttackTime = 3
ENT.RangeAttackMaxDistance = 2500
ENT.RangeAttackMinDistance = 1

ENT.CanFlinch = true
ENT.FlinchChance = 3
ENT.FlinchCooldown = 2
ENT.AnimTbl_Flinch = "Mortar_Flinch_Front"

ENT.LimitChaseDistance = true
ENT.LimitChaseDistance_Max = "UseRangeDistance"
ENT.LimitChaseDistance_Min = "UseRangeDistance"

ENT.SoundTbl_Breath = "vj_hlr/src/npc/mortarsynth/hover.wav"
ENT.SoundTbl_Idle = {"vj_hlr/src/npc/combot/cbot_battletalk1.wav", "vj_hlr/src/npc/combot/cbot_battletalk2.wav", "vj_hlr/src/npc/combot/cbot_battletalk3.wav", "vj_hlr/src/npc/combot/cbot_battletalk4.wav"}
ENT.SoundTbl_CombatIdle = {"vj_hlr/src/npc/combot/cbot_scan1.wav", "vj_hlr/src/npc/combot/cbot_scan2.wav"}
ENT.SoundTbl_Alert = "vj_hlr/src/npc/combot/cbot_alert1.wav"
ENT.SoundTbl_RangeAttack = "vj_hlr/src/npc/mortarsynth/attack_shoot.wav"
ENT.SoundTbl_Pain = {"vj_hlr/src/npc/combot/cbot_servoscared.wav", "vj_hlr/src/npc/combot/cbot_servosurprise.wav"}
ENT.SoundTbl_Death = "vj_hlr/src/npc/waste_scanner/grenade_fire.wav"

ENT.BreathSoundLevel = 75
ENT.AlertSoundLevel = 90
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(33, 33, 26), Vector(-33, -33, -30))

	local glowFX = ents.Create("light_dynamic")
	glowFX:SetKeyValue("brightness", "2")
	glowFX:SetKeyValue("distance", "125")
	glowFX:SetLocalPos(self:GetPos() +self:OBBCenter() +self:GetForward() *20 +self:GetUp() *-4)
	glowFX:SetLocalAngles(self:GetAngles())
	glowFX:Fire("Color", "0 50 255")
	glowFX:SetParent(self)
	glowFX:Spawn()
	glowFX:Activate()
	glowFX:Fire("TurnOn", "", 0)
	-- glowFX:Fire("SetParentAttachment", "2", 0)
	self:DeleteOnRemove(glowFX)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjPos(projectile)
	return self:GetPos() + self:GetUp() * 10 + self:GetForward() * -20
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjVel(projectile)
	return self:CalculateProjectile("Curve", projectile:GetPos(), self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter(), 1200)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFlinch(dmginfo, hitgroup, status)
	if status == "Init" then
		local dmgtype = dmginfo:GetDamageType()
		if (dmgtype == DMG_BULLET or dmgtype == DMG_SLASH) then
			self.AnimTbl_Flinch = {"Mortar_Flinch_Back", "Mortar_Flinch_Left", "Mortar_Flinch_Right", "Mortar_Flinch_Front"}
		else
			self.AnimTbl_Flinch = {"Mortar_BigFlinch_Back", "Mortar_BigFlinch_Left", "Mortar_BigFlinch_Right", "Mortar_BigFlinch_Front"}
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmginfo, hitgroup, status)
	if status == "Init" then
		ParticleEffect("explosion_turret_break", self:GetPos(), Angle(), nil)
		ParticleEffect("electrical_arc_01_system", self:GetPos(), Angle(), nil)
		util.BlastDamage(self, self, self:GetPos(), 80, 20)
	end
end