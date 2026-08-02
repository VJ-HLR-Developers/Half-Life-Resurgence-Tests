AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/breen.mdl"
ENT.StartHealth = 100
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.BloodColor = VJ.BLOOD_COLOR_RED
ENT.AnimTbl_MeleeAttack = "vjseq_MeleeAttack01"
ENT.TimeUntilMeleeAttackDamage = 0.7
ENT.HasGrenadeAttack = false
ENT.AnimTbl_GrenadeAttack = ACT_RANGE_ATTACK_THROW
ENT.GrenadeAttackThrowTime = 0.87
ENT.GrenadeAttackAttachment = "anim_attachment_RH"
ENT.HasOnPlayerSight = true
ENT.OnPlayerSightDistance = 500
ENT.OnPlayerSightDispositionLevel = 2

ENT.CanFlinch = true

ENT.SoundTbl_FootStep = {"npc/footsteps/hardboot_generic1.wav", "npc/footsteps/hardboot_generic2.wav", "npc/footsteps/hardboot_generic3.wav", "npc/footsteps/hardboot_generic4.wav", "npc/footsteps/hardboot_generic5.wav", "npc/footsteps/hardboot_generic6.wav", "npc/footsteps/hardboot_generic8.wav"}
ENT.SoundTbl_Idle = {
	"vo/citadel/br_oheli07.wav",
	"vo/citadel/br_oheli08.wav",
	"vo/citadel/br_oheli09.wav",
	"vo/citadel/br_foundation.wav"
}
ENT.SoundTbl_IdleDialogue = {
	"vo/citadel/br_bidder_b.wav",
	"vo/citadel/br_deliver.wav",
	"vo/citadel/br_gift_b.wav",
	"vo/citadel/br_hostbody.wav",
	"vo/citadel/br_newleader_b.wav",
	"vo/citadel/br_nothingtosay_b.wav",
	"vo/citadel/br_rabble_a.wav",
	"vo/citadel/br_rabble_c.wav",
	"vo/citadel/br_untenable.wav"
}
ENT.SoundTbl_IdleDialogueAnswer = {
	"vo/citadel/br_dictate_a.wav",
	"vo/citadel/br_farside.wav",
	"vo/citadel/br_gift_a.wav",
	"vo/citadel/br_newleader_a.wav",
	"vo/citadel/br_newleader_c.wav",
	"vo/citadel/br_nopoint.wav",
	"vo/citadel/br_nothingtosay_a.wav",
	"vo/citadel/br_rabble_b.wav",
	"vo/citadel/br_rabble_d.wav"
}
ENT.SoundTbl_CombatIdle = {
	"vo/citadel/br_playgame_b.wav",
	"vo/citadel/br_unleash.wav"
}
ENT.SoundTbl_ReceiveOrder =
	"vo/citadel/br_whatittakes.wav"

ENT.SoundTbl_OnPlayerSight = {
	"vo/k_lab/br_thereheis.wav",
	"vo/citadel/br_freemanatlast.wav",
	"vo/citadel/br_goback.wav",
	"vo/citadel/br_guest_a.wav"
}
ENT.SoundTbl_Investigate =
	"vo/k_lab/br_tele_02.wav"

ENT.SoundTbl_LostEnemy =
	"vo/k_lab/br_significant.wav"

ENT.SoundTbl_Alert = {
	"vo/citadel/br_ohshit.wav",
	"vo/citadel/br_playgame_b.wav"
}
ENT.SoundTbl_CallForHelp = {
	"vo/citadel/br_guards.wav",
	"vo/citadel/br_justhurry.wav"
}
ENT.SoundTbl_MedicReceiveHealth =
	"vo/citadel/br_guest_b.wav"

ENT.SoundTbl_Suppressing = {
	"vo/citadel/br_mock05.wav",
	"vo/citadel/br_mock06.wav",
	"vo/citadel/br_mock09.wav",
	"vo/citadel/br_mock13.wav"
}
ENT.SoundTbl_WeaponReload =
	"vo/citadel/br_ohshit.wav"

ENT.SoundTbl_GrenadeSight = {
	"vo/citadel/br_ohshit.wav",
	"vo/citadel/br_gravgun.wav"
}
ENT.SoundTbl_DangerSight = {
	"vo/citadel/br_ohshit.wav",
	"vo/citadel/br_no.wav"
}
ENT.SoundTbl_KilledEnemy = {
	"vo/citadel/br_laugh01.wav",
	"vo/citadel/br_mock05.wav",
	"vo/citadel/br_mock06.wav",
	"vo/citadel/br_mock09.wav",
	"vo/citadel/br_mock13.wav"
}
ENT.SoundTbl_AllyDeath = {
	"vo/citadel/br_failing11.wav",
	"vo/citadel/br_ohshit.wav",
	"vo/citadel/br_no.wav"
}
ENT.SoundTbl_Pain = {
	"vo/citadel/br_no.wav",
	"vo/citadel/br_youfool.wav"
}
ENT.SoundTbl_Death = {
	"vo/citadel/br_failing11.wav",
	"vo/citadel/br_youneedme.wav"
}
-- Unused, Breencast lines not included
/*"vo/k_lab/br_significant.wav"
"vo/k_lab/br_tele_03.wav"
"vo/k_lab/br_tele_05.wav"
"vo/citadel/br_betrayed.wav"
"vo/citadel/br_bidder_a.wav"
"vo/citadel/br_circum.wav"
"vo/citadel/br_create.wav"
"vo/citadel/br_gift_c.wav"
"vo/citadel/br_guest_c.wav"
"vo/citadel/br_guest_d.wav"
"vo/citadel/br_guest_f.wav"
"vo/citadel/br_judithwhat.wav"
"vo/citadel/br_mentors.wav"
"vo/citadel/br_playgame_a.wav"
"vo/citadel/br_playgame_c.wav"
"vo/citadel/br_stubborn.wav"
"vo/citadel/br_synapse.wav"
"vo/citadel/br_synapse02.wav"
"vo/citadel/br_yesjudith.wav"
"vo/citadel/br_worthit.wav"*/

ENT.MainSoundPitch = 100

-- Specific kill sounds
local sdKilledEnemyPlayer = {"vo/citadel/br_mock01.wav", "vo/citadel/br_mock04.wav", "vo/citadel/br_mock07.wav"}
---------------------------------------------------------------------------------------------------------------------------------------------
local defAng = Angle()
--
function ENT:Init()
	local myPos = self:GetPos()
	local myAng = self:GetAngles()

	local combineElite1 = ents.Create("npc_vj_hlr2_com_elite")
	combineElite1:SetPos(myPos + self:GetRight() * 40 + self:GetUp() * -10)
	combineElite1:SetAngles(myAng)
	combineElite1.DoNotDuplicate = true
	combineElite1:Spawn()
	combineElite1:SetOwner(self)
	combineElite1:Give("weapon_vj_ar2")
	self.CombineElite1 = combineElite1

	local combineElite2 = ents.Create("npc_vj_hlr2_com_elite")
	combineElite2:SetPos(myPos + self:GetRight() * -40 + self:GetUp() * -10)
	combineElite2:SetAngles(myAng)
	combineElite2.DoNotDuplicate = true
	combineElite2:Spawn()
	combineElite2:SetOwner(self)
	combineElite2:Give("weapon_vj_ar2")
	self.CombineElite2 = combineElite2
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	local combineElite1 = self.CombineElite1
	local combineElite2 = self.CombineElite2
	if IsValid(combineElite1) && !combineElite1.IsFollowing then
		combineElite1:Follow(self, true)
		combineElite1.IsFollowing = true
	end
	if IsValid(combineElite2) && !combineElite2.IsFollowing then
		combineElite2:Follow(self, true)
		combineElite2.IsFollowing = true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if math.random(1, 2) == 1 && ent:IsNPC() then
		if ent.VJ_HLR_Freeman then
			self:PlaySoundSystem("Alert", self.SoundTbl_OnPlayerSight)
			return
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnKilledEnemy(ent, inflictor, wasLast)
	if math.random(1, 2) == 1 then
		if ent:IsPlayer() or ent.VJ_HLR_Freeman then
			self:PlaySoundSystem("KilledEnemy", sdKilledEnemyPlayer)
			return
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	if !self.Dead then -- Remove Combine Elites if we were removed (Undo, remover tool, etc.)
		local combineElite1 = self.CombineElite1
		local combineElite2 = self.CombineElite2
		if IsValid(combineElite1) then combineElite1:Remove() end
		if IsValid(combineElite2) then combineElite2:Remove() end
	end
end