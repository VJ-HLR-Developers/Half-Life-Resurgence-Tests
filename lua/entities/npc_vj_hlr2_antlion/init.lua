AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/antlion_soldier.mdl"
ENT.StartHealth = 30
ENT.HullType = HULL_HUMAN

ENT.VJ_NPC_Class = {"CLASS_ANTLION"}

ENT.JumpParams = {
	MaxRise = 1000,
	MaxDrop = 1500,
	MaxDistance = 1500
}

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "Antlion.Head_Bone",
	FirstP_Offset = Vector(15, 0, 2),
}

ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.BloodParticle = "blood_impact_yellow_01"

ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1, "pounce", "pounce2"}
ENT.MeleeAttackDistance = 50
ENT.MeleeAttackDamageDistance = 85
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDamage = 5

ENT.HasLeapAttack = true
ENT.AnimTbl_LeapAttack = ACT_JUMP
-- ENT.AnimTbl_LeapAttack = "fly_in"
ENT.LeapAttackMaxDistance = 1024
ENT.LeapAttackMinDistance = 256
ENT.TimeUntilLeapAttackDamage = 0.2
ENT.NextLeapAttackTime = 6
ENT.NextAnyAttackTime_Leap = 2.4
ENT.LeapAttackExtraTimers = {0.4, 0.6, 0.8, 1, 1.2, 1.4, 1.6, 1.8, 2, 2.2, 2.4}
ENT.TimeUntilLeapAttackVelocity = 0.2
ENT.LeapAttackDamage = 5
ENT.LeapAttackDamageDistance = 100

ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true
ENT.MainSoundPitch = 100

ENT.ConstantlyFaceEnemy = true
ENT.ConstantlyFaceEnemy_Postures = "Moving"
ENT.ConstantlyFaceEnemy_MinDistance = 500

ENT.SoundTbl_FootStep = {"npc/antlion/foot1.wav", "npc/antlion/foot2.wav", "npc/antlion/foot3.wav", "npc/antlion/foot4.wav"}
ENT.SoundTbl_Idle = {
	"npc/antlion/idle1.wav",
	"npc/antlion/idle2.wav",
	"npc/antlion/idle3.wav",
	"npc/antlion/idle4.wav",
	"npc/antlion/idle5.wav"
}
ENT.SoundTbl_Alert =
	"npc/antlion/distract1.wav"

ENT.SoundTbl_BeforeMeleeAttack = {
	"npc/antlion/attack_single1.wav",
	"npc/antlion/attack_single2.wav",
	"npc/antlion/attack_single3.wav"
}
ENT.SoundTbl_Pain = {
	"npc/antlion/pain1.wav",
	"npc/antlion/pain2.wav"
}
ENT.SoundTbl_Death = {
	"npc/antlion/pain1.wav",
	"npc/antlion/pain2.wav"
}

ENT.Antlion_StartedLeapAttack = false
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnLeapAttack(status, enemy)
	if status == "Jump" then
		self.Antlion_StartedLeapAttack = true
		return self:CalculateProjectile("Curve", self:GetPos(), self:GetAimPosition(enemy, self:GetPos(), 1, 1100), 1100)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjVel(projectile)
	local projPos = projectile:GetPos()
	return self:CalculateProjectile("Curve", projPos, self:GetAimPosition(self:GetEnemy(), projPos, 1, 1100) +(VectorRand() *28), 1100)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:IsDirt(pos)
	local tr = util.TraceLine({
		start = pos,
		endpos = pos -Vector(0, 0, 40),
		filter = self,
		mask = MASK_NPCWORLDSTATIC
	})
	local mat = tr.MatType
	return tr.HitWorld && (mat == MAT_SAND || mat == MAT_DIRT || mat == MAT_FOLIAGE || mat == MAT_SLOSH || mat == 85)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Dig(ignoreDirt)
	if !ignoreDirt && self:IsDirt(self:GetPos()) or ignoreDirt then
		self:SetNoDraw(true)
		self.IsDigging = true
		timer.Simple(0.02, function()
			if IsValid(self) then
				self:EmitSound("physics/concrete/concrete_break2.wav", 80, 100)
				VJ.EmitSound(self, "npc/antlion/digup1.wav", 75, 100)
				ParticleEffect("advisor_plat_break", self:GetPos(), self:GetAngles(), self)
				ParticleEffect("strider_impale_ground", self:GetPos(), self:GetAngles(), self)
				self:PlayAnim("digout", true, VJ.AnimDuration(self, "digout"), false)
				self.HasMeleeAttack = false
				timer.Simple(0.15, function() if IsValid(self) then self:SetNoDraw(false) end end)
				timer.Simple(VJ.AnimDuration(self, "digout"), function() if IsValid(self) then self.HasMeleeAttack = true self.IsDigging = false end end)
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(20, 20, 64), Vector(-20, -20, 0))
	self:SetSkin(math.random(0, 3))
	self.DefaultDamage = self.MeleeAttackDamage
	if self:GetSkin() > 0 && !self.HasDeathAnimation then
		local mul = self:GetSkin()
		if self:GetSkin() == 1 then
			mul = 2
		end
		local hp = self:Health() *mul
		self:SetHealth(hp)
		self:SetMaxHealth(hp)
		self.DefaultDamage = self.MeleeAttackDamage *mul
		self.MeleeAttackDamage = self.DefaultDamage
	end
	self.FlyLoop = CreateSound(self, "npc/antlion/fly1.wav")
	self.FlyLoop:SetSoundLevel(80)
	self.IsDigging = false
	self:Dig()
	if self.HasDeathAnimation then
		self.HasDeathCorpse = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	if self.Antlion_StartedLeapAttack && self:OnGround() then
		self.Antlion_StartedLeapAttack = false
		self:PlayAnim("jump_stop", true, false, false)
	end
	if self.FlyLoop:IsPlaying() then
		if self:GetSequenceActivity(self:GetSequence()) == 27 or self:GetSequenceActivity(self:GetSequence()) == 30 then
			return
		end
		self.FlyLoop:Stop()
		self:SetBodygroup(1, 0)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if self.IsDiging == true then return end
	if math.random(1, 6) == 1 then
		local tbl = VJ.PICK({"distract", "roar"})
		self:PlayAnim(tbl, true, VJ.AnimDuration(self, tbl), false)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "melee" then
		self.MeleeAttackDamage = self.DefaultDamage
		self:ExecuteMeleeAttack()
	elseif key == "melee_pounce" then
		self.MeleeAttackDamage = self.DefaultDamage *1.5
		self:ExecuteMeleeAttack()
	elseif key == "step" || key == "step_light" then
		self:PlayFootstepSound()
	elseif key == "scream" then
		VJ.EmitSound(self, "npc/antlion/antlion_preburst_scream" .. math.random(1, 2) .. ".wav", 75, 100)
	elseif key == "explode" then
		VJ.EmitSound(self, "npc/antlion/antlion_burst" .. math.random(1, 2) .. ".wav", 75, 100)
	elseif key == "range" then
		for i = 1, math.random(2, 4) do
			self:ExecuteRangeAttack()
		end
	elseif key == "step_heavy" then
		VJ.EmitSound(self, "npc/antlion/shell_impact" .. math.random(1, 4) .. ".wav", 75, 100)
	elseif key == 78 then
		VJ.EmitSound(self, "npc/antlion/attack_double" .. math.random(1, 3) .. ".wav", 75, 100)
	elseif key == "on" then
		self:SetBodygroup(1, 1)
		self.FlyLoop:Play()
	elseif key == "off" then
		self:SetBodygroup(1, 0)
		self.FlyLoop:Stop()
		VJ.EmitSound(self, "npc/antlion/land1.wav", 75, 100)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if act == ACT_IDLE && self.Antlion_StartedLeapAttack then
		return ACT_GLIDE
	end
	return act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	self.FlyLoop:Stop()
end