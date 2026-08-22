AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/zombie.mdl"
ENT.StartHealth = 50
ENT.HullType = HULL_HUMAN

ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}

ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.BloodParticle = "blood_impact_green_01"

ENT.MeleeAttackDamage = 10
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 35
ENT.MeleeAttackDamageDistance = 75
ENT.TimeUntilMeleeAttackDamage = false

ENT.CanFlinch = true
ENT.FlinchChance = 8
ENT.FlinchCooldown = 3
ENT.AnimTbl_Flinch = ACT_FLINCH_PHYSICS
ENT.FlinchHitGroupMap = {
	{HitGroup = HITGROUP_HEAD, Animation = "vjges_flinch_head"},
	{HitGroup = HITGROUP_CHEST, Animation = "vjges_flinch_chest"},
	{HitGroup = HITGROUP_LEFTARM, Animation = "vjges_flinch_leftArm"},
	{HitGroup = HITGROUP_RIGHTARM, Animation = "vjges_flinch_rightArm"},
	{HitGroup = HITGROUP_LEFTLEG, Animation = ACT_FLINCH_LEFTLEG},
	{HitGroup = HITGROUP_RIGHTLEG, Animation = ACT_FLINCH_RIGHTLEG}
}

ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true
ENT.MainSoundPitch = 100

ENT.SoundTbl_FootStep = {"npc/zombie/foot1.wav", "npc/zombie/foot2.wav", "npc/zombie/foot3.wav"}
ENT.SoundTbl_Idle = {"npc/zombie/zombie_voice_idle1.wav", "npc/zombie/zombie_voice_idle2.wav", "npc/zombie/zombie_voice_idle3.wav", "npc/zombie/zombie_voice_idle4.wav", "npc/zombie/zombie_voice_idle5.wav", "npc/zombie/zombie_voice_idle6.wav", "npc/zombie/zombie_voice_idle7.wav", "npc/zombie/zombie_voice_idle8.wav", "npc/zombie/zombie_voice_idle9.wav", "npc/zombie/zombie_voice_idle10.wav", "npc/zombie/zombie_voice_idle11.wav", "npc/zombie/zombie_voice_idle12.wav", "npc/zombie/zombie_voice_idle13.wav", "npc/zombie/zombie_voice_idle14.wav"}
ENT.SoundTbl_Alert = {"npc/zombie/zombie_alert1.wav", "npc/zombie/zombie_alert2.wav", "npc/zombie/zombie_alert3.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"npc/zombie/zo_attack1.wav", "npc/zombie/zo_attack2.wav"}
ENT.SoundTbl_MeleeAttackExtra = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"npc/zombie/claw_miss1.wav", "npc/zombie/claw_miss2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
ENT.SoundTbl_DeathFollow = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetSlump(doSlump)
	if doSlump then
		self:SetState(VJ_STATE_ONLY_ANIMATION_NOATTACK)
		local tr = util.TraceHull({
			start = self:GetPos(),
			endpos = self:GetPos() +self:GetForward() *-25,
			mins = self:OBBMins(),
			maxs = self:OBBMaxs(),
			filter = self
		})
		self.SlumpSet = tr.Hit && "a" or "b"
		self.SlumpAnimation = VJ.SequenceToActivity(self, "slump_" .. self.SlumpSet)
		self:SetMaxLookDistance(150)
		self.SightAngle = 360
		self:AddFlags(FL_NOTARGET)
	else
		self:PlayAnim("slumprise_" .. self.SlumpSet, true, false, false, 0, {OnFinish=function(interrupted, anim)
			self:SetState()
		end})
		self:SetMaxLookDistance(10000)
		self.SightAngle = 156
		self:RemoveFlags(FL_NOTARGET)
	end
	self.CanFlinch = doSlump && 0 or 1
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
	local zType = self.ZombieType or math.random(0, 6)
	self.SlumpAnimation = ACT_IDLE

	if self.Slump then
		self:SetSlump(true)
	end

	if self.ZombieType != 69 then
		if zType > 1 then -- If they're a Rebel/Medic or Metro-Police, then make their health equivalent to their non-zombie types
			local hp = self.StartHealth *1.2
			self:SetHealth(hp)
			self:SetMaxHealth(hp)
			if zType == 4 or zType == 5 then -- Is a Medic, perhaps drop a Medkit?
				self.DeathLoot = {"item_healthvial"}
				self.DeathLootChance = 3
			else
				self.DeathLoot = {"weapon_frag"}
				self.DeathLootChance = 12
				if zType == 6 then
					self.SoundTbl_FootStep = {"vj_hlr/src/npc/zolice/gear1.wav", "vj_hlr/src/npc/zolice/gear2.wav", "vj_hlr/src/npc/zolice/gear3.wav"}
					self.SoundTbl_Idle = {"vj_hlr/src/npc/zolice/idle1.wav", "vj_hlr/src/npc/zolice/idle2.wav", "vj_hlr/src/npc/zolice/idle3.wav", "vj_hlr/src/npc/zolice/idle4.wav", "vj_hlr/src/npc/zolice/idle5.wav", "vj_hlr/src/npc/zolice/idle6.wav"}
					self.SoundTbl_Alert = {"vj_hlr/src/npc/zolice/alert1.wav", "vj_hlr/src/npc/zolice/alert2.wav", "vj_hlr/src/npc/zolice/alert3.wav"}
					self.SoundTbl_BeforeMeleeAttack = {"vj_hlr/src/npc/zolice/attack1.wav", "vj_hlr/src/npc/zolice/attack2.wav", "vj_hlr/src/npc/zolice/attack3.wav", "vj_hlr/src/npc/zolice/attack4.wav", "vj_hlr/src/npc/zolice/attack6.wav"}
					self.SoundTbl_Pain = {"vj_hlr/src/npc/zolice/pain1.wav", "vj_hlr/src/npc/zolice/pain2.wav", "vj_hlr/src/npc/zolice/pain3.wav", "vj_hlr/src/npc/zolice/pain4.wav"}
					self.SoundTbl_DeathFollow = {"vj_hlr/src/npc/zolice/die1.wav", "vj_hlr/src/npc/zolice/die2.wav", "vj_hlr/src/npc/zolice/die3.wav", "vj_hlr/src/npc/zolice/die4.wav"}
				end
			end
		end
		self:SetSkin(zType)
	end

	if self.OnInit then
		self:OnInit()
	end

	self:SetBodygroup(1, 1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then
		VJ.EmitSound(self, self.SoundTbl_FootStep, self.FootstepSoundLevel)
	elseif key == "scuff" then
		VJ.EmitSound(self, "npc/zombie/foot_slide" .. math.random(1, 3) .. ".wav", self.FootstepSoundLevel)
	elseif key == "melee" or key == "swat" then
		self.MeleeAttackDamage = 10
		self:ExecuteMeleeAttack()
		if key == "swat" then
			VJ.EmitSound(self, "npc/zombie/zombie_hit.wav", 75)
		end
	elseif key == "melee_both" then
		self.MeleeAttackDamage = 25
		self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if act == ACT_IDLE then
		if self.IsSlumped then
			return self.SlumpAnimation
		elseif self:IsOnFire() then
			return ACT_IDLE_ON_FIRE
		end
	elseif (act == ACT_RUN or act == ACT_WALK) && self:IsOnFire() then
		return ACT_WALK_ON_FIRE
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
			"models/headcrabclassic.mdl",
			{Pos = self:GetAttachment(self:LookupAttachment("headcrab")).Pos or self:EyePos()},
			function(crab)
				if self.HeadcrabClass == "npc_vj_hlr2b_headcrab" then
					crab:SetMaterial("models/hl_resurgence/hl2b/headcrab/headcrabsheet")
				end
			end
		)
	else
		if math.random(1, (dmgtype == DMG_CLUB or dmgtype == DMG_SLASH) && 1 or 3) == 1 then
			ent:SetBodygroup(1, 0)
			local crab = ents.Create(self.HeadcrabClass or "npc_vj_hlr2_headcrab")
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