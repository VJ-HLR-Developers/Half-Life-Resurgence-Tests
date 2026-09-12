AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/crabsynth.mdl"
ENT.StartHealth = 850
ENT.HullType = HULL_HUMAN
ENT.TurningSpeed = 12

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "Bip02 Neck",
	FirstP_Offset = Vector(30, 0, 10),
	FirstP_ShrinkBone = false
}

ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.BloodColor = VJ.BLOOD_COLOR_BLUE

ENT.PoseParameterLooking_InvertPitch = true

ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 140
ENT.MeleeAttackDamageDistance = 180
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackAnimationFaceEnemy = false
ENT.MeleeAttackBleedEnemyChance = 1
ENT.MeleeAttackBleedEnemyReps = 10
ENT.MeleeAttackPlayerSpeedTime = 10

ENT.HasRangeAttack = true
ENT.AnimTbl_RangeAttack = ACT_RANGE_ATTACK1
ENT.RangeAttackAnimationFaceEnemy = false
ENT.RangeAttackMaxDistance = 1750
ENT.RangeAttackMinDistance = 500
ENT.TimeUntilRangeAttackProjectileRelease = false
ENT.NextRangeAttackTime = VJ.SET(5, 9)

ENT.ConstantlyFaceEnemy_MinDistance = 1750

ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true
ENT.MainSoundPitch = 100

ENT.SoundTbl_Idle = "vj_hlr/src/npc/crab/taunt.wav"
ENT.SoundTbl_Pain = "vj_hlr/src/npc/crab/pain1.wav"
ENT.SoundTbl_MeleeAttackExtra = "vj_hlr/src/npc/crab/stab.wav"
ENT.SoundTbl_MeleeAttackMiss = "vj_hlr/src/npc/crab/step2.wav"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(45, 45, 100), Vector(-45, -45, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Controller_Initialize(ply, controlEnt)
	function controlEnt:OnThink()
		self.VJC_BullseyeTracking = self.VJCE_NPC:GetIdealActivity() == ACT_WALK
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	-- print(key)
	if key == "step" then
		VJ.EmitSound(self, "vj_hlr/src/npc/crab/step2.wav", 75)
	elseif key == "step_heavy" then
		VJ.EmitSound(self, "vj_hlr/src/npc/crab/step.wav", 80)
		util.ScreenShake(self:GetPos(), 8, 100, 0.2, 500)
	elseif key == "attack" then
		self.MeleeAttackDamage = 20
		self.HasMeleeAttackKnockBack = false
		self.MeleeAttackBleedEnemy = false
		self.MeleeAttackPlayerSpeed = false
		self:ExecuteMeleeAttack()
	elseif key == "attack_stab" then
		self.MeleeAttackDamage = 40
		self.HasMeleeAttackKnockBack = false
		self.MeleeAttackBleedEnemy = true
		self.MeleeAttackPlayerSpeed = true
		self:ExecuteMeleeAttack()
	elseif key == "attack_left" then
		self.MeleeAttackDamage = 20
		self.HasMeleeAttackKnockBack = true
		self.MeleeAttackBleedEnemy = false
		self.MeleeAttackPlayerSpeed = false
		self:ExecuteMeleeAttack()
	elseif key == "gun_drop" then
		VJ.EmitSound(self, "vj_hlr/src/npc/crab/flesh_rip.wav", 80)
	elseif key == "gun_load" then
		VJ.EmitSound(self, "vj_hlr/src/npc/crab/gun_drop.wav", 80)
	elseif key == "gun_charge" then
		VJ.EmitSound(self, "vj_hlr/src/npc/crab/charge_cannon.wav", 80)
	elseif key == "gun_fire" then
		VJ.EmitSound(self, "vj_hlr/src/npc/crab/fire.wav", 150)
		ParticleEffectAttach("vj_muzzle_ar2_main", PATTACH_POINT_FOLLOW, self, 1)
		local att = self:GetAttachment(1)
		local targetPos = IsValid(self:GetEnemy()) && self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter() or self:GetPos() +self:GetForward() *1500
		for i = 1, 2 do
			local bullet = {}
			bullet.Num = 1
			bullet.Src = att.Pos
			bullet.Dir = targetPos -att.Pos
			bullet.Callback = function(attacker, tr, dmginfo)
				local laserhit = EffectData()
				laserhit:SetOrigin(tr.HitPos)
				laserhit:SetNormal(tr.HitNormal)
				laserhit:SetScale(25)
				util.Effect("AR2Impact", laserhit)

				util.ScreenShake(tr.HitPos, 16, 100, 0.2, 100, true)
			end
			bullet.Spread = Vector(math.random(-45, 45), math.random(-45, 45), math.random(-45, 45))
			bullet.Tracer = 1
			bullet.TracerName = "AirboatGunTracer"
			bullet.Force = 3
			bullet.Damage = self:ScaleByDifficulty(13)
			bullet.AmmoType = "AR2"
			self:FireBullets(bullet)
		end
	elseif key == "gun_retract" then
		VJ.EmitSound(self, "vj_hlr/src/npc/crab/gun_retract.wav", 80)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity()
	return self:GetForward() *125 +self:GetRight() *-450 +self:GetUp() *150
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	self.ConstantlyFaceEnemy = self:GetIdealActivity() == ACT_WALK
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if act == ACT_RUN && !IsValid(self.VJ_TheController) then
		local dist = self.EnemyData.DistanceNearest
		if dist && (dist >= 2000 or dist <= 500) then
			return ACT_RUN
		end
		return ACT_WALK
	end
	return act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "PreDamage" then
		if hitgroup == 15 then
			self.HasBloodParticle = true
			self.HasBloodDecal = true
			dmginfo:SetDamage(dmginfo:GetDamage() *4.5)
			VJ.EmitSound(self, "ambient/energy/zap" .. math.random(1, 9) .. ".wav", 70)
			local spark = ents.Create("env_spark")
			spark:SetKeyValue("Magnitude", "1")
			spark:SetKeyValue("Spark Trail Length", "1")
			spark:SetPos(dmginfo:GetDamagePosition())
			spark:SetAngles(self:GetAngles())
			spark:SetParent(self)
			spark:Spawn()
			spark:Activate()
			spark:Fire("StartSpark", nil, 0)
			spark:Fire("StopSpark", nil, 0.001)
			self:DeleteOnRemove(spark)
		else
			self.HasBloodParticle = false
			self.HasBloodDecal = false
			if dmginfo:IsBulletDamage() then
				dmginfo:ScaleDamage(0.35)
			end
		end
	end
end