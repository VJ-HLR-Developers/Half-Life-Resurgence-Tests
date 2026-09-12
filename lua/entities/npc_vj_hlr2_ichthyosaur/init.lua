AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/icky.mdl"
ENT.StartHealth = 200
ENT.HullType = HULL_LARGE_CENTERED

ENT.IdleAlwaysWander = true
ENT.TurningUseAllAxis = true
ENT.MovementType = VJ_MOVETYPE_AQUATIC

ENT.Aquatic_SwimmingSpeed_Calm = 150
ENT.Aquatic_SwimmingSpeed_Alerted = 500
ENT.Aquatic_AnimTbl_Calm = ACT_GLIDE
ENT.Aquatic_AnimTbl_Alerted = ACT_SWIM

ENT.ControllerParams = {
	ThirdP_Offset = Vector(-25, 0, 0),
	FirstP_Bone = "Bip01 Head",
	FirstP_Offset = Vector(12, 0, 5),
	FirstP_ShrinkBone = false
}

ENT.VJ_NPC_Class = {"CLASS_XEN"}

ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.HasBloodPool = false

ENT.HasMeleeAttack = true
ENT.MeleeAttackDamage = 35
ENT.MeleeAttackDamageType = DMG_ALWAYSGIB
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDistance = 75
ENT.MeleeAttackDamageDistance = 120
ENT.HasDeathAnimation = true
ENT.AnimTbl_Death = ACT_DIESIMPLE

ENT.MeleeAttackBleedEnemy = true
ENT.MeleeAttackBleedEnemyChance = 1
ENT.MeleeAttackBleedEnemyReps = 10
ENT.MeleeAttackPlayerSpeed = true
ENT.MeleeAttackPlayerSpeedTime = 10

ENT.SoundTbl_Breath = "npc/ichthyosaur/water_breath.wav"
ENT.SoundTbl_Alert = "npc/ichthyosaur/water_growl5.wav"
ENT.SoundTbl_CombatIdle = "npc/ichthyosaur/water_growl5.wav"
ENT.SoundTbl_BeforeMeleeAttack = {"npc/ichthyosaur/attack_growl1.wav", "npc/ichthyosaur/attack_growl2.wav", "npc/ichthyosaur/attack_growl3.wav"}
ENT.SoundTbl_MeleeAttack = "npc/ichthyosaur/snap.wav"

ENT.MainSoundPitch = 100

ENT.Icky_Idle = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(40, 40, 40), Vector(-40, -40, -40))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "melee" then
		self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnMeleeAttackExecute(status, ent, isProp)
	if status == "Init" then
		local pos = self:GetPos() +self:GetAngles():Forward() *35
		effects.Bubbles(pos +Vector(-32, -32, -32), pos +Vector(32, 32, 32), math.random(16, 32), math.random(100, 300), 1)
	elseif status == "PreDamage" then
		self:SetHealth(math.Clamp(self:Health() + ((self.MeleeAttackDamage > ent:Health() && ent:Health()) or self.MeleeAttackDamage), self:Health(), self:GetMaxHealth()*2))
		self:PlayAnim(ACT_RANGE_ATTACK1_LOW, true, false, true)
		if ent:IsPlayer() then
			ent:ScreenFade(SCREENFADE.IN, Color(64, 0, 0), 0.5, 0)
		end
	elseif status == "Miss" then
		self:PlayAnim(ACT_RANGE_ATTACK2_LOW, true, false, false)
		VJ.CreateSound(self, "npc/ichthyosaur/snap_miss.wav", 75)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	local waterLevel = self:WaterLevel()
	if math.random(1, 10) == 1 && waterLevel > 0 then
		effects.Bubbles(self:GetPos() +(self:OBBMins() *0.5), self:GetPos() +(self:OBBMaxs() *0.5), math.random(1, 4), math.random(100, 300), 1)
	end
	if self.Icky_Idle == 0 && waterLevel == 0 then
		self.Icky_Idle = 1
		self.HasMeleeAttack = false
		self.HasDeathAnimation = false
		self.NextIdleStandTime = 0
		self.AnimTbl_IdleStand = {"thrash"}
	elseif self.Icky_Idle == 1 && waterLevel > 0 then
		self.Icky_Idle = 0
		self.HasMeleeAttack = true
		self.HasDeathAnimation = true
		self.NextIdleStandTime = 0
		self.AnimTbl_IdleStand = {ACT_IDLE}
	end
end