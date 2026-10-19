AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/stalker_ep2.mdl"
ENT.StartHealth = 50
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.BloodColor = VJ.BLOOD_COLOR_RED
ENT.Behavior = VJ_BEHAVIOR_NEUTRAL

ENT.HasMeleeAttack = false

ENT.LimitChaseDistance = "OnlyRange"
ENT.LimitChaseDistance_Max = 1600
ENT.LimitChaseDistance_Min = 0
ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true

ENT.SoundTbl_FootStep = {
	"npc/stalker/stalker_footstep_left1.wav",
	"npc/stalker/stalker_footstep_left2.wav",
	"npc/stalker/stalker_footstep_right1.wav",
	"npc/stalker/stalker_footstep_right2.wav"
}
ENT.SoundTbl_Idle = {
	"npc/stalker/breathing3.wav",
	"npc/stalker/stalker_alert1b.wav",
	"npc/stalker/stalker_alert2b.wav",
	"npc/stalker/stalker_alert3b.wav",
	"npc/stalker/stalker_ambient01.wav"
}
ENT.SoundTbl_Alert = {
	"npc/stalker/stalker_scream1.wav",
	"npc/stalker/stalker_scream2.wav",
	"npc/stalker/stalker_scream3.wav",
	"npc/stalker/stalker_scream4.wav"
}
ENT.SoundTbl_CallForHelp =
	"npc/stalker/go_alert2a.wav"

ENT.SoundTbl_Pain = {
	"npc/stalker/stalker_pain1.wav",
	"npc/stalker/stalker_pain2.wav",
	"npc/stalker/stalker_pain3.wav"
}
ENT.SoundTbl_Death = {
	"npc/stalker/stalker_die1.wav",
	"npc/stalker/stalker_die2.wav"
}

ENT.MainSoundPitch = 100
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(20, 20, 65), Vector(-20, -20, 0))
	self.Laser = CreateSound(self, "npc/stalker/laser_burn.wav")
	self.Laser:SetSoundLevel(75)
	self.NextLAnimT = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then
		self:PlayFootstepSound()
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
	self.DisableChasingEnemy = self.IsLaserAttacking
	if self.IsLaserAttacking then
		-- if CurTime() > self.NextLAnimT then
			-- self:PlayAnim(ACT_RANGE_ATTACK1, true, false, true)
			-- self.NextLAnimT = CurTime() +self:SequenceDuration(self:LookupSequence("rangeattack")) -0.1
		-- end
		local moveCheck = VJ.PICK(self:VJ_CheckAllFourSides(math.random(150, 400), true, "0111"))
		if moveCheck && math.random(1, 50) == 1 then
			self:StopMoving()
			self:SetLastPosition(moveCheck)
			self:SCHEDULE_GOTO_POSITION(math.random(1, 2) == 1 and "TASK_RUN_PATH" or "TASK_WALK_PATH", function(x) x:EngTask("TASK_FACE_ENEMY", 0) x.TurnData = {Type = VJ.FACE_ENEMY} end)
		end
		self:SetTurnTarget("Enemy")
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
			eyeGlow:Fire("SetParentAttachment", "eyes",0)
			eyeGlow:Spawn()
			eyeGlow:Activate()
			self:DeleteOnRemove(eyeGlow)
			self.EyeGlow = eyeGlow
		end
	else
		self.NextLAnimT = 0
	end
	if !self.VJ_Controlled then
		local ent = self:GetEnemy()
		if IsValid(ent) then
			if self:Visible(ent) && ent:GetPos():Distance(self:GetPos()) < self.LimitChaseDistance_Max then
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
		if self.VJ_Controller:GetPlayer():KeyDown(IN_ATTACK2) then
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
	if !IsValid(self:GetEnemy()) || IsValid(self:GetEnemy()) && self:GetEnemy():Health() <= 0 then
		if self.IsLaserAttacking then
			self:LaserReset()
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	self.Laser:Stop()
end