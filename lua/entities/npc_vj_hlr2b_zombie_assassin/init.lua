AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2b/zombie_assassin.mdl"
ENT.StartHealth = 75
ENT.HullType = HULL_HUMAN

ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "Bip01 Head",
	FirstP_Offset = Vector(3, 0, 0),
}

ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.BloodParticle = "blood_impact_green_01"

ENT.MeleeAttackDamage = 15
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 35
ENT.MeleeAttackDamageDistance = 75
ENT.TimeUntilMeleeAttackDamage = false

ENT.SoundTbl_FootStep = {
	"physics/flesh/flesh_squishy_impact_hard1.wav",
	"physics/flesh/flesh_squishy_impact_hard2.wav",
	"physics/flesh/flesh_squishy_impact_hard3.wav",
	"physics/flesh/flesh_squishy_impact_hard4.wav"
}
ENT.SoundTbl_FootStep_Run = {"physics/flesh/flesh_strider_impact_bullet1.wav", "physics/flesh/flesh_strider_impact_bullet2.wav"}
ENT.SoundTbl_Breath = "npc/zombie_poison/pz_breathe_loop1.wav"
ENT.SoundTbl_Idle = {"npc/barnacle/barnacle_gulp1.wav", "npc/barnacle/barnacle_gulp2.wav", "^ambient/creatures/town_moan1.wav"}
ENT.SoundTbl_Alert = {"npc/barnacle/barnacle_pull1.wav", "npc/barnacle/barnacle_pull2.wav", "npc/barnacle/barnacle_pull3.wav", "npc/barnacle/barnacle_pull4.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"npc/zombie_poison/pz_warn1.wav", "npc/zombie_poison/pz_warn2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
ENT.SoundTbl_Death = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}
ENT.SoundTbl_MeleeAttackExtra = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"npc/zombie/claw_miss1.wav", "npc/zombie/claw_miss2.wav"}
ENT.SoundTbl_Investigate = {
	"ambient/voices/citizen_beaten3.wav",
	"ambient/voices/citizen_beaten4.wav",
	"ambient/voices/m_scream1.wav",
	"vo/npc/male01/help01.wav",
	"vo/npc/male01/moan01.wav",
	"vo/npc/male01/moan03.wav",
	"vo/npc/male01/overhere01.wav",
	"vo/npc/male01/gordead_ans06.wav",
	"vo/npc/male01/gordead_ans19.wav"
}

ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true
ENT.BreathSoundLevel = 45
ENT.MainSoundPitch = VJ.SET(75, 85)
ENT.InvestigateSoundPitch = VJ.SET(75, 80)

ENT.AnimationSet = 0
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self.NextScreamT = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then
		VJ.EmitSound(self, self.SoundTbl_FootStep, 60)
	elseif key == "step_run" then
		VJ.EmitSound(self, self.SoundTbl_FootStep_Run, 68)
	elseif key == "melee" then
		self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	local controlled = self.VJ_IsBeingControlled
	local set = self.AnimationSet
	local enemy = self:GetEnemy()
	if IsValid(enemy) && !controlled then
		local dist = self.EnemyData.DistanceNearest
		if CurTime() > self.NextScreamT && math.random(1, 15) == 1 && dist < 200 then
			VJ.CreateSound(self, "^npc/stalker/go_alert2a.wav", 100, 65)
			util.ScreenShake(self:GetPos(), 10, 120, 2, 400)
			sound.EmitHint(SOUND_DANGER, self:GetPos(), 400, 1.5, self)
			for _, v in pairs(ents.FindInSphere(self:GetPos(), 400)) do
				if v:IsPlayer() && self:CheckRelationship(v) == D_HT then
					local time = ((400 /self:GetPos():Distance(v:GetPos())) -1) *1.5
					self:DoMeleeAttackPlayerSpeed(v, 70, 90, time)
					net.Start("VJ_HLR2_ZombieAssassinScream")
						net.WriteEntity(v)
					net.Send(v)
				end
			end
			self.NextScreamT = CurTime() +math.Rand(10, 25)
		end
		if !(enemy:GetForward():Dot((self:GetPos() -enemy:GetPos()):GetNormalized()) > math.cos(math.rad(60))) && dist > 600 then
			if set != 1 then
				self.AnimTbl_Run = ACT_WALK
				self.AnimationSet = 1
			end
		else
			if set != 0 then
				self.AnimTbl_Run = ACT_RUN
				self.AnimationSet = 0
			end
		end
	else
		if set != 0 then
			self.AnimTbl_Run = ACT_RUN
			self.AnimationSet = 0
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCreateDeathCorpse(dmginfo, hitgroup, ent)
	if self:GetBodygroup(0) == 1 then
		return false
	end

	VJ.CreateSound(ent, self.SoundTbl_DeathFollow, self.DeathSoundLevel)
	local dmgtype = dmginfo:GetDamageType()
	if hitgroup == HITGROUP_HEAD then
		ent:SetBodygroup(0, 1)
		self:CreateExtraDeathCorpse(
			"prop_ragdoll",
			"models/headcrabclassic.mdl",
			{Pos = self:EyePos()},
			function(crab)
				crab:SetMaterial("models/hl_resurgence/hl2b/headcrab/headcrabsheet")
			end
		)
	else
		if math.random(1, (dmgtype == DMG_CLUB or dmgtype == DMG_SLASH or DMG_BLAST) && 1 or 3) == 1 then
			ent:SetBodygroup(0, 1)
			local crab = ents.Create("npc_vj_hlr2b_headcrab")
			crab:SetPos(self:EyePos())
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