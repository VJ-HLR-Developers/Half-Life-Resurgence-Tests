AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/headcrabclassic.mdl"
ENT.StartHealth = 10
ENT.HullType = HULL_TINY

ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "HeadcrabClassic.SpineControl",
	FirstP_Offset = Vector(3, 0, -1),
}

ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.BloodParticle = "blood_impact_yellow_01"

ENT.HasMeleeAttack = false

ENT.HasLeapAttack = true
ENT.AnimTbl_LeapAttack = ACT_RANGE_ATTACK1
ENT.LeapAttackMaxDistance = 300
ENT.LeapAttackMinDistance = 0
ENT.TimeUntilLeapAttackDamage = 0.3
ENT.NextLeapAttackTime = 1.4
ENT.NextAnyAttackTime_Leap = 0.85
ENT.TimeUntilLeapAttackVelocity = 0.1
ENT.LeapAttackVelocityForward = 70
ENT.LeapAttackVelocityUp = 200
ENT.LeapAttackDamage = 8
ENT.LeapAttackExtraTimers = {0.4, 0.6, 0.8, 1}
ENT.LeapAttackStopOnHit = true
ENT.LeapAttackDamageDistance = 40

ENT.HasExtraMeleeAttackSounds = true
ENT.FootstepSoundTimerRun = 0.2
ENT.FootstepSoundTimerWalk = 0.2

ENT.SoundTbl_FootStep = {"npc/headcrab_poison/ph_step1.wav", "npc/headcrab_poison/ph_step2.wav", "npc/headcrab_poison/ph_step3.wav", "npc/headcrab_poison/ph_step4.wav"}
ENT.SoundTbl_Alert = "npc/headcrab/alert1.wav"
ENT.SoundTbl_Idle = {"npc/headcrab/idle1.wav", "npc/headcrab/idle2.wav", "npc/headcrab/idle3.wav"}
ENT.SoundTbl_LeapAttackJump = {"npc/headcrab/attack1.wav", "npc/headcrab/attack2.wav", "npc/headcrab/attack3.wav"}
ENT.SoundTbl_LeapAttackDamage = "npc/headcrab/headbite.wav"
ENT.SoundTbl_Pain = {"npc/headcrab/pain1.wav", "npc/headcrab/pain2.wav", "npc/headcrab/pain3.wav"}
ENT.SoundTbl_Death = {"npc/headcrab/die1.wav", "npc/headcrab/die2.wav"}
ENT.SoundTbl_IdleDialogue = {"npc/headcrab/idle1.wav", "npc/headcrab/idle2.wav", "npc/headcrab/idle3.wav"}
ENT.SoundTbl_IdleDialogueAnswer = {"npc/headcrab/alert1.wav", "npc/headcrab/idle1.wav", "npc/headcrab/idle2.wav", "npc/headcrab/idle3.wav"}

ENT.MainSoundPitch = 100
ENT.FootstepSoundLevel = 50
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(8, 10, 15), Vector(-8, -10, 0))
end