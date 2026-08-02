AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2b/bullsquid.mdl"
ENT.StartHealth = 80

ENT.VJ_NPC_Class = {"CLASS_XEN"}
ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.BloodParticle = "blood_impact_yellow_01"
ENT.Immune_Toxic = true

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "Bullsquid.Head_Bone1",
	FirstP_Offset = Vector(8, 0, 5),
}

ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDamage = 20
ENT.MeleeAttackDistance = 55
ENT.MeleeAttackDamageDistance = 125
ENT.HasMeleeAttackKnockBack = true
ENT.TimeUntilMeleeAttackDamage = false

ENT.HasRangeAttack = true
ENT.AnimTbl_RangeAttack = ACT_RANGE_ATTACK1
ENT.TimeUntilRangeAttackProjectileRelease = false
ENT.RangeAttackProjectiles = "obj_vj_hlr2_antlionspit"
ENT.RangeAttackReps = 3
ENT.NextRangeAttackTime = 1.5
ENT.RangeAttackMaxDistance = 1024
ENT.RangeAttackMinDistance = 256

ENT.Aquatic_SwimmingSpeed_Calm = 200
ENT.Aquatic_SwimmingSpeed_Alerted = 300
ENT.Aquatic_AnimTbl_Calm = {ACT_SWIM}
ENT.Aquatic_AnimTbl_Alerted = {ACT_SWIM}
ENT.AA_ConstantlyMove = true

ENT.LimitChaseDistance = "OnlyRange"
ENT.LimitChaseDistance_Max = "UseRangeDistance"
ENT.LimitChaseDistance_Min = "UseRangeDistance"

ENT.SoundTbl_FootStep = "npc/zombie_poison/pz_left_foot1.wav"
ENT.SoundTbl_Idle = {
	"vj_hlr/src/npc/bullsquid/idle1.wav",
	"vj_hlr/src/npc/bullsquid/idle2.wav",
	"vj_hlr/src/npc/bullsquid/idle3.wav",
	"vj_hlr/src/npc/bullsquid/idle4.wav",
	"vj_hlr/src/npc/bullsquid/idle5.wav",
	"vj_hlr/src/npc/bullsquid/snort1.wav",
	"vj_hlr/src/npc/bullsquid/snort2.wav",
	"vj_hlr/src/npc/bullsquid/snort3.wav"
}
ENT.SoundTbl_Alert = "vj_hlr/src/npc/bullsquid/excited1.wav"
ENT.SoundTbl_BeforeMeleeAttack = {
	"vj_hlr/src/npc/bullsquid/attack2.wav",
	"vj_hlr/src/npc/bullsquid/attackgrowl1.wav",
	"vj_hlr/src/npc/bullsquid/attackgrowl2.wav",
	"vj_hlr/src/npc/bullsquid/attackgrowl3.wav"
}
ENT.SoundTbl_MeleeAttackMiss = "vj_hlr/src/npc/bullsquid/tail_whip1.wav"
ENT.SoundTbl_RangeAttack = {
	"vj_hlr/src/npc/bullsquid/attack1.wav",
	"vj_hlr/src/npc/bullsquid/attack3.wav"
}
ENT.SoundTbl_Pain = {
	"vj_hlr/src/npc/bullsquid/pain1.wav",
	"vj_hlr/src/npc/bullsquid/pain2.wav",
	"vj_hlr/src/npc/bullsquid/pain3.wav",
	"vj_hlr/src/npc/bullsquid/pain4.wav"
}
ENT.SoundTbl_Death = {
	"vj_hlr/src/npc/bullsquid/die1.wav",
	"vj_hlr/src/npc/bullsquid/die2.wav",
	"vj_hlr/src/npc/bullsquid/die3.wav"
}

ENT.Bullsquid_MoveType = 0 -- 0 = Normal | 1 = Swimming
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(40, 40, 40), Vector(-40, -40, 0))

	self:ManipulateBoneJiggle(3, 1)
	self:ManipulateBoneJiggle(4, 1)
	self:ManipulateBoneJiggle(5, 1)
	self:ManipulateBoneJiggle(6, 1)
	self:ManipulateBoneJiggle(7, 1)
	self:ManipulateBoneJiggle(8, 1)
	self:ManipulateBoneJiggle(9, 1)
	self:ManipulateBoneJiggle(10, 1)
	self:ManipulateBoneJiggle(11, 1)
	self:ManipulateBoneJiggle(12, 1)
	self:ManipulateBoneJiggle(13, 1)
	self:ManipulateBoneJiggle(14, 1)
	self:ManipulateBoneJiggle(15, 1)
	self:ManipulateBoneJiggle(16, 1)
	self:ManipulateBoneJiggle(17, 1)
	self:ManipulateBoneJiggle(18, 1)
	self:ManipulateBoneJiggle(19, 1)
	self:ManipulateBoneJiggle(20, 1)
	self:ManipulateBoneJiggle(21, 1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then
		self:PlayFootstepSound()
	elseif key == "attack" then
		self:ExecuteMeleeAttack()
	elseif key == "range" then
		for _ = 1, math.random(2, 4) do
			self:ExecuteRangeAttack()
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	if self:WaterLevel() > 1 then
		if self.Bullsquid_MoveType != 1 then
			if self.MovementType != VJ_MOVETYPE_AQUATIC then
				self:DoChangeMovementType(VJ_MOVETYPE_AQUATIC)
			end
			self.HasMeleeAttack = false
			self.HasRangeAttack = false
			self.Bullsquid_MoveType = 1
		end
		if IsValid(self:GetEnemy()) && self:GetEnemy():WaterLevel() < 3 then
			self:AA_MoveTo(self:GetEnemy(), true)
		end
	else
		if self.Bullsquid_MoveType != 0 then
			if self.MovementType != VJ_MOVETYPE_GROUND then
				self:DoChangeMovementType(VJ_MOVETYPE_GROUND)
			end
			self.HasMeleeAttack = true
			self.HasRangeAttack = true
			self.Bullsquid_MoveType = 0
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity(ent)
	return self:GetForward() * 55 + self:GetUp() * 255
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjPos(projectile)
	return self:GetAttachment(self:LookupAttachment("mouth")).Pos
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjVel(projectile)
	local projPos = projectile:GetPos()
	return self:CalculateProjectile("Curve", projPos, self:GetAimPosition(self:GetEnemy(), projPos, 1, 1100) +(VectorRand() *28), 1100)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if self:WaterLevel() < 2 then
		if ent.VJ_ID_Headcrab && math.random(1, 2) == 1 then
			self:PlayAnim("hc_spot", true, false, true)
		else
			if math.random(1, 3) == 1 then
				self:PlayAnim(ACT_HOP, true, false, true)
			end
		end
	end
end