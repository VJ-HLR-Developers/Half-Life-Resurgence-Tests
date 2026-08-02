AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2b/houndeye.mdl"
ENT.StartHealth = 80
ENT.HullType = HULL_WIDE_SHORT
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_XEN"}
ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.BloodParticle = "vj_hlr_blood_yellow"
ENT.Immune_Sonic = true
ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = ACT_RANGE_ATTACK1
ENT.MeleeAttackDistance = 130
ENT.MeleeAttackDamageDistance = 400
ENT.MeleeAttackDamageAngleRadius = 180
ENT.TimeUntilMeleeAttackDamage = 2.35
ENT.MeleeAttackDamage = 25
ENT.MeleeAttackDamageType = DMG_SONIC
ENT.MeleeAttackDSP = 34
ENT.MeleeAttackDSPLimit = false
ENT.DisableDefaultMeleeAttackDamageCode = true
ENT.DisableFootStepSoundTimer = true

ENT.CanFlinch = true
ENT.AnimTbl_Flinch = "vjseq_flinch_small"

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "HoundEye.Head",
	FirstP_Offset = Vector(4, 0, 0),
}

ENT.SoundTbl_FootStep = {
	"npc/zombie/foot1.wav",
	"npc/zombie/foot2.wav",
	"npc/zombie/foot3.wav",
}
ENT.SoundTbl_CallForHelp = "vj_hlr/src/npc/houndeye/he_bark_group_attack.wav"
ENT.SoundTbl_ReceiveOrder = "vj_hlr/src/npc/houndeye/he_bark_group_attack_reply.wav"
ENT.SoundTbl_AllyDeath = "vj_hlr/src/npc/houndeye/he_bark_group_retreat.wav"
ENT.SoundTbl_Idle = {
	"vj_hlr/src/npc/houndeye/he_idle1.wav",
	"vj_hlr/src/npc/houndeye/he_idle2.wav",
	"vj_hlr/src/npc/houndeye/he_idle3.wav",
	"vj_hlr/src/npc/houndeye/he_idle4.wav"
}
ENT.SoundTbl_Alert = {
	"vj_hlr/src/npc/houndeye/he_alert1.wav",
	"vj_hlr/src/npc/houndeye/he_alert2.wav",
	"vj_hlr/src/npc/houndeye/he_alert3.wav"
}
ENT.SoundTbl_BeforeMeleeAttack = {
	"vj_hlr/src/npc/houndeye/he_attack1.wav",
	"vj_hlr/src/npc/houndeye/he_attack2.wav",
	"vj_hlr/src/npc/houndeye/he_attack3.wav"
}
ENT.SoundTbl_Pain = {
	"vj_hlr/src/npc/houndeye/he_pain1.wav",
	"vj_hlr/src/npc/houndeye/he_pain2.wav",
	"vj_hlr/src/npc/houndeye/he_pain3.wav",
	"vj_hlr/src/npc/houndeye/he_pain4.wav",
	"vj_hlr/src/npc/houndeye/he_pain5.wav",
	"vj_hlr/src/npc/houndeye/he_yelp1.wav"
}
ENT.SoundTbl_Death = {
	"vj_hlr/src/npc/houndeye/he_die1.wav",
	"vj_hlr/src/npc/houndeye/he_die2.wav",
	"vj_hlr/src/npc/houndeye/he_die3.wav"
}

ENT.FootstepSoundLevel = 80
ENT.FootstepSoundPitch = VJ.SET(110, 115)
ENT.MainSoundPitch = 100
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(17, 17, 40), Vector(-17, -17, 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then
		self:PlayFootstepSound()
	elseif key == "hunt" then
		VJ.EmitSound(self, "vj_hlr/src/npc/houndeye/he_hunt" .. math.random(1, 4) .. ".wav")
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if math.random(1, 2) == 1 then
		self:PlayAnim({"vjseq_madidle1", "vjseq_madidle2", "vjseq_madidle3"}, true, false, true)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnMeleeAttackExecute(status, ent, isProp)
	if status == "Init" then
		effects.BeamRingPoint(self:GetPos() +Vector(0, 0, 5), 0.3, 2, 400, 16, 0, Color(248, 0, 35), {material="vj_hl/sprites/shockwave", framerate=20, flags=0})
		effects.BeamRingPoint(self:GetPos() +Vector(0, 0, 5), 0.3, 2, 200, 16, 0, Color(248, 0, 35), {material="vj_hl/sprites/shockwave", framerate=20, flags=0})

		if self.HasSounds && self.HasMeleeAttackSounds then
			VJ.EmitSound(self, "vj_hlr/src/npc/houndeye/he_blast" .. math.random(1, 3) .. ".wav", 100, math.random(80, 100))
		end

		VJ.ApplyRadiusDamage(self, self, self:GetPos(), 400, self.MeleeAttackDamage, self.MeleeAttackDamageType, true, true, {DisableVisibilityCheck=true, Force=80})
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFlinch(dmginfo, hitgroup, status)
	if status == "Init" then
		-- Houndeye shouldn't have its sonic attack interrupted by a flinch animation!
		return self.AttackAnimTime > CurTime()
	end
end