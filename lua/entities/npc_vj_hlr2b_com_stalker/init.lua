AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2b/stalker.mdl"
ENT.StartHealth = 50
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.BloodColor = VJ.BLOOD_COLOR_RED
ENT.BloodParticle = "blood_impact_red_01_mist"

ENT.MeleeAttackDamage = 15
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDistance = 40
ENT.MeleeAttackDamageDistance = 70

ENT.LimitChaseDistance = "OnlyRange"
ENT.LimitChaseDistance_Max = 950
ENT.LimitChaseDistance_Min = 200
ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "Bip01 Head",
	FirstP_Offset = Vector(1, 0, 1)
}

ENT.SoundTbl_FootStep = {
	"vj_hlr/src/npc/beta_stalker/stalker_footstep_left1.wav",
	"vj_hlr/src/npc/beta_stalker/stalker_footstep_left2.wav",
	"vj_hlr/src/npc/beta_stalker/stalker_footstep_right1.wav",
	"vj_hlr/src/npc/beta_stalker/stalker_footstep_right2.wav"
}
ENT.SoundTbl_Scramble = {
	"vj_hlr/src/npc/beta_stalker/scramble1.wav",
	"vj_hlr/src/npc/beta_stalker/scramble2.wav",
	"vj_hlr/src/npc/beta_stalker/scramble3.wav",
	"vj_hlr/src/npc/beta_stalker/scramble4.wav",
	"vj_hlr/src/npc/beta_stalker/scramble5.wav",
	"vj_hlr/src/npc/beta_stalker/scramble6.wav",
	"vj_hlr/src/npc/beta_stalker/scramble7.wav",
	"vj_hlr/src/npc/beta_stalker/scramble8.wav",
	"vj_hlr/src/npc/beta_stalker/scramble9.wav",
	"vj_hlr/src/npc/beta_stalker/scramble10.wav"
}
ENT.SoundTbl_Alert = {
	"vj_hlr/src/npc/beta_stalker/go_alert1.wav",
	"vj_hlr/src/npc/beta_stalker/go_alert2.wav",
	"vj_hlr/src/npc/beta_stalker/go_alert3.wav",
	"vj_hlr/src/npc/beta_stalker/announce1.wav",
	"vj_hlr/src/npc/beta_stalker/announce2.wav",
	"vj_hlr/src/npc/beta_stalker/announce3.wav"
}
ENT.SoundTbl_BeforeMeleeAttack = {
	"vj_hlr/src/npc/beta_stalker/attack1.wav",
	"vj_hlr/src/npc/beta_stalker/attack2.wav",
	"vj_hlr/src/npc/beta_stalker/attack3.wav",
	"vj_hlr/src/npc/beta_stalker/attack4.wav",
	"vj_hlr/src/npc/beta_stalker/attack5.wav",
	"vj_hlr/src/npc/beta_stalker/attack6.wav",
	"vj_hlr/src/npc/beta_stalker/attack7.wav",
	"vj_hlr/src/npc/beta_stalker/attack8.wav",
	"vj_hlr/src/npc/beta_stalker/attack9.wav",
	"vj_hlr/src/npc/beta_stalker/attack10.wav"
}
ENT.SoundTbl_MeleeAttackExtra = {"vj_hlr/gsrc/npc/zombie/claw_strike1.wav", "vj_hlr/gsrc/npc/zombie/claw_strike2.wav", "vj_hlr/gsrc/npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_Pain = {
	"vj_hlr/src/npc/beta_stalker/pain1.wav",
	"vj_hlr/src/npc/beta_stalker/pain2.wav",
	"vj_hlr/src/npc/beta_stalker/pain3.wav",
	"vj_hlr/src/npc/beta_stalker/pain4.wav"
}
ENT.SoundTbl_Death = {
	"vj_hlr/src/npc/beta_stalker/die1.wav",
	"vj_hlr/src/npc/beta_stalker/die2.wav",
	"vj_hlr/src/npc/beta_stalker/die3.wav"
}

ENT.MainSoundPitch = 100
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(20, 20, 65), Vector(-20, -20, 0))
	self.Laser = CreateSound(self, "vj_hlr/src/npc/beta_stalker/laser_burn.wav")
	self.Laser:SetSoundLevel(75)
	self.NextLAnimT = 0
	self.NextRunAwayT = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then
		self:PlayFootstepSound()
	elseif key == "melee" then
		self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FireLaser()
	if IsValid(self:GetEnemy()) then
		local startpos =  self:GetAttachment(1).Pos
		local tr = util.TraceLine({
			start = self:GetAttachment(1).Pos,
			endpos = self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter() +VectorRand() *4,
			filter = self
		})
		local hitpos = tr.HitPos

		if tr.Hit then
			local elec = EffectData()
			elec:SetStart(startpos)
			elec:SetOrigin(hitpos)
			elec:SetEntity(self)
			elec:SetAttachment(1)
			util.Effect("VJ_HLR_StalkerBeam", elec)

			VJ.ApplyRadiusDamage(self, self, hitpos, 30, 2, DMG_BURN, true, false, {Force=1})
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:LaserReset()
	self.IsLaserAttacking = false
	self.Laser:Stop()
	self:StopAttacks(true)
	self.NextChaseTime = CurTime()
	self.NextIdleTime = CurTime()
	if IsValid(self.EyeGlow) then
		self.EyeGlow:Remove()
		self.EyeGlow = nil
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	if self.IsLaserAttacking then
		if CurTime() > self.NextLAnimT then
			self:PlayAnim(ACT_RANGE_ATTACK1, true, false, true)
			self.NextLAnimT = CurTime() +self:SequenceDuration(self:LookupSequence("rangeattack")) -0.1
		end
		self:FireLaser()
		if !self.Laser:IsPlaying() then
			self.Laser:Play()
			local eyeGlow = ents.Create("env_sprite")
			eyeGlow:SetKeyValue("model", "vj_base/sprites/glow.vmt")
			eyeGlow:SetKeyValue("scale", "0.2")
			eyeGlow:SetKeyValue("rendermode", "5")
			eyeGlow:SetKeyValue("rendercolor", "255 0 0")
			eyeGlow:SetKeyValue("spawnflags", "1")
			eyeGlow:SetParent(self)
			eyeGlow:Fire("SetParentAttachment", "0",0)
			eyeGlow:Spawn()
			eyeGlow:Activate()
			self:DeleteOnRemove(eyeGlow)
			self.EyeGlow = eyeGlow
		end
	else
		self.NextLAnimT = 0
	end
	if !self.VJ_IsBeingControlled then
		local ent = self:GetEnemy()
		if IsValid(ent) then
			if self:Visible(ent) && (CurTime() > self.NextRunAwayT) && ent:GetPos():Distance(self:GetPos()) < self.LimitChaseDistance_Max && ent:GetPos():Distance(self:GetPos()) > self.LimitChaseDistance_Min then
				if !self.IsLaserAttacking then
					self.IsLaserAttacking = true
					VJ.EmitSound(self, "vj_hlr/src/npc/beta_stalker/laser_start.wav", 70, 100)
				end
			else
				if self.IsLaserAttacking then
					self:LaserReset()
				end
			end
		end
	else
		if self.VJ_TheController:KeyDown(IN_ATTACK2) then
			if !self.IsLaserAttacking then
				self.IsLaserAttacking = true
				VJ.EmitSound(self, "vj_hlr/src/npc/beta_stalker/laser_start.wav", 70, 100)
			end
		else
			if self.IsLaserAttacking then
				self:LaserReset()
			end
		end
	end
	if !IsValid(self:GetEnemy()) || IsValid(self:GetEnemy()) && self:GetEnemy():Health() <= 0 && self.IsLaserAttacking then
		self:LaserReset()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	self.Laser:Stop()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "PostDamage" && CurTime() > self.NextRunAwayT && !self.VJ_IsBeingControlled then
		self:LaserReset()
		VJ.CreateSound(self, self.SoundTbl_Scramble, 80, 100)
		self:SCHEDULE_COVER_ENEMY("TASK_RUN_PATH", function(x) x.RunCode_OnFail = function() self.NextRunAwayT = 0 end end)
		self.NextRunAwayT = CurTime() + 5
	end
end