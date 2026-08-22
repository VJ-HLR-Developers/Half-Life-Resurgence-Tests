AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/zombie_fast.mdl"
ENT.StartHealth = 50
ENT.HullType = HULL_HUMAN

ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}

ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.BloodParticle = "blood_impact_green_01"

ENT.MeleeAttackDamage = 6
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 35
ENT.MeleeAttackDamageDistance = 75
ENT.TimeUntilMeleeAttackDamage = false

ENT.HasLeapAttack = true
ENT.AnimTbl_LeapAttack = ACT_JUMP
ENT.LeapAttackMaxDistance = 400
ENT.LeapAttackMinDistance = 150
ENT.TimeUntilLeapAttackDamage = 0.2
ENT.NextLeapAttackTime = 3
ENT.NextAnyAttackTime_Leap = 0.4
ENT.LeapAttackExtraTimers = {0.4, 0.6, 0.8, 1}
ENT.TimeUntilLeapAttackVelocity = 0.2
ENT.LeapAttackVelocityForward = 300
ENT.LeapAttackVelocityUp = 250
ENT.LeapAttackDamage = 15
ENT.LeapAttackDamageDistance = 100

ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true
ENT.MainSoundPitch = 100

ENT.SoundTbl_FootStep = {"npc/fast_zombie/foot1.wav", "npc/fast_zombie/foot2.wav", "npc/fast_zombie/foot3.wav", "npc/fast_zombie/foot4.wav"}
ENT.SoundTbl_DefBreath = {"npc/fast_zombie/breathe_loop1.wav", "npc/fast_zombie/gurgle_loop1.wav"}
ENT.SoundTbl_Alert = {"npc/fast_zombie/fz_alert_far1.wav", "npc/fast_zombie/fz_alert_close1.wav"}
ENT.SoundTbl_BeforeMeleeAttack = "npc/fast_zombie/leap1.wav"
ENT.SoundTbl_LeapAttackJump = "npc/fast_zombie/fz_scream1.wav"
ENT.SoundTbl_MeleeAttackExtra = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"npc/zombie/claw_miss1.wav", "npc/zombie/claw_miss2.wav"}
ENT.SoundTbl_Pain = "npc/fast_zombie/wake1.wav"
ENT.SoundTbl_DeathFollow = "npc/fast_zombie/wake1.wav"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetSlump(doSlump)
	if doSlump then
		self:SetState(VJ_STATE_ONLY_ANIMATION_NOATTACK)
		self.SlumpSet = math.random(1, 2) == 1 && "a" or "b"
		self.SlumpAnimation = VJ.SequenceToActivity(self, "slump_" .. self.SlumpSet)
		self:SetMaxLookDistance(150)
		self.SightAngle = 360
		self:AddFlags(FL_NOTARGET)
	else
		self:PlayAnim("slumprise_" .. (self.SlumpSet == "a" && VJ.PICK({"a", "c"}) or self.SlumpSet), true, false, false, 0, {OnFinish=function(interrupted, anim)
			self:SetState()
		end})
		self:SetMaxLookDistance(10000)
		self.SightAngle = 156
		self:RemoveFlags(FL_NOTARGET)
		self.SoundTbl_Breath = self.SoundTbl_DefBreath
	end
	self.IsSlumped = doSlump
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if self.IsSlumped then
		self:SetSlump(false)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	if self.OnInit then
		self:OnInit()
	end
	self.SlumpAnimation = ACT_IDLE

	if self.Slump then
		self:SetSlump(true)
	else
		self.SoundTbl_Breath = self.SoundTbl_DefBreath
	end

	self:SetBodygroup(1, 1)
	self:SetCollisionBounds(Vector(13, 13, 50), Vector(-13, -13, 0))

	self.TotalHits = 0
	self.LastHitT = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then
		VJ.EmitSound(self, self.SoundTbl_FootStep, self.FootstepSoundLevel)
	elseif key == "melee" then
		self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnMeleeAttackExecute(status, ent, isProp)
	if status == "PreDamage" then
		if CurTime() > self.LastHitT then self.TotalHits = 0 end
		self.TotalHits = self.TotalHits +1
		self.LastHitT = CurTime() +0.6
		if self.TotalHits >= 8 then
			VJ.CreateSound(self, "npc/fast_zombie/fz_frenzy1.wav", 80)
			self:PlayAnim("BR2_Roar", true, false, true)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if act == ACT_IDLE then
		if self.IsSlumped then
			return self.SlumpAnimation
		elseif !self:OnGround() && !self:IsMoving() then
			return ACT_GLIDE
		elseif self:IsOnFire() && !self.IsBeta then
			return ACT_IDLE_ON_FIRE
		end
	elseif act == ACT_CLIMB_DOWN then
		return ACT_CLIMB_UP
	end
	return act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	if !self.IsSlumped then
		self.IdleSoundBlockTime = CurTime() +math.random(4, 8)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "PreDamage" then
		local nonGes = (hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG)
		self.FlinchChance = nonGes && 8 or 2
		self.FlinchCooldown = nonGes && 5 or 2
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnBleed(dmginfo, hitgroup)
	if self.IsSlumped then
		self:SetSlump(false)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCreateDeathCorpse(dmginfo, hitgroup, ent)
	if self:GetBodygroup(1) == 0 then
		return false
	end

	VJ.CreateSound(ent, self.SoundTbl_DeathFollow, self.DeathSoundLevel)
	local dmgtype = dmginfo:GetDamageType()
	if hitgroup == HITGROUP_HEAD or dmgtype == DMG_BLAST then
		ent:SetBodygroup(1, 0)
		self:CreateExtraDeathCorpse(
			"prop_ragdoll",
			"models/headcrab.mdl",
			{Pos = self:GetAttachment(self:LookupAttachment("headcrab")).Pos or self:EyePos()},
			function(crab)
				if self.HeadcrabClass == "npc_vj_hlr2b_headcrab_fast" then
					crab:SetMaterial("models/hl_resurgence/hl2b/headcrab_fast/allinonebacup2")
				end
			end
		)
	else
		if math.random(1, (dmgtype == DMG_CLUB or dmgtype == DMG_SLASH) && 1 or 3) == 1 then
			ent:SetBodygroup(1, 0)
			local crab = ents.Create(self.HeadcrabClass or "npc_vj_hlr2_headcrab_fast")
			crab:SetPos(self:GetAttachment(self:LookupAttachment("headcrab")).Pos or self:EyePos())
			crab:SetAngles(self:GetAngles())
			crab:Spawn()
			crab:SetGroundEntity(NULL) -- This fixes that issue where they snap to the ground when spawned
			crab:SetLocalVelocity(self:GetVelocity() *dmginfo:GetDamageForce():Length())
			if ent:IsOnFire() then
				crab:Ignite(math.random(8, 10))
			end
			undo.ReplaceEntity(self, crab)
		end
	end
end