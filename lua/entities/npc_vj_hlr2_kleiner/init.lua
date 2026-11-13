AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/kleiner.mdl"
ENT.StartHealth = 100
ENT.HealthRegenParams = {
	Enabled = true,
	Amount = 1,
	Delay = VJ.SET(0.35, 0.35),
}
ENT.HullType = HULL_HUMAN

ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
ENT.AlliedWithPlayerAllies = true
ENT.BloodColor = VJ.BLOOD_COLOR_RED
ENT.AnimTbl_MeleeAttack = "vjseq_MeleeAttack01"
ENT.TimeUntilMeleeAttackDamage = 0.7
ENT.HasGrenadeAttack = false
ENT.AnimTbl_GrenadeAttack = ACT_RANGE_ATTACK_THROW
ENT.GrenadeAttackThrowTime = 0.87
ENT.GrenadeAttackAttachment = "anim_attachment_RH"
ENT.HasOnPlayerSight = true
ENT.BecomeEnemyToPlayer = 2

ENT.CanFlinch = true

ENT.SoundTbl_FootStep = {"npc/footsteps/hardboot_generic1.wav", "npc/footsteps/hardboot_generic2.wav", "npc/footsteps/hardboot_generic3.wav", "npc/footsteps/hardboot_generic4.wav", "npc/footsteps/hardboot_generic5.wav", "npc/footsteps/hardboot_generic6.wav", "npc/footsteps/hardboot_generic8.wav"}
ENT.SoundTbl_Idle = {
	"vo/k_lab/kl_blast.wav",
	"vo/k_lab/kl_hedyno01.wav",
	"vo/k_lab/kl_coaxherout.wav",
	"vo/k_lab/kl_masslessfieldflux.wav",
	"vo/k_lab/kl_ohdear.wav",
	"vo/k_lab2/kl_aroundhere.wav",
	"vo/k_lab2/kl_cantleavelamarr_b.wav",
	"vo/k_lab2/kl_comeoutlamarr.wav",
	"vo/k_lab2/kl_lamarr.wav",
	"vo/k_lab/kl_helloalyx02.wav",
	"vo/episode_1/intro/kl_damage.wav",
	"vo/episode_1/intro/kl_damage01.wav",
	"vo/episode_1/intro/kl_damage03.wav",
	"vo/episode_1/intro/kl_vicinity.wav",
	"vo/outland_11a/silo/kl_silo_givenup02.wav",
	"vo/outland_11a/silo/kl_silo_givenup03.wav",
	"vo/outland_11a/silo/kl_silo_hm.wav",
	"vo/outland_11a/silo/kl_silo_inorder01.wav",
	"vo/outland_11a/silo/kl_silo_inorder02.wavq",
	"vo/outland_11a/silo/kl_silo_trove01.wav"
}
ENT.SoundTbl_IdleDialogue = {
	"vo/k_lab/kl_bonvoyage.wav",
	"vo/k_lab/kl_fruitlessly.wav",
	"vo/k_lab/kl_holdup02.wav",
	"vo/k_lab/kl_hesnotthere.wav",
	"vo/k_lab/kl_islamarr.wav",
	"vo/k_lab/kl_modifications01.wav",
	"vo/k_lab/kl_modifications02.wav",
	"vo/k_lab/kl_weowe.wav",
	"vo/k_lab2/kl_atthecitadel01_b.wav",
	"vo/k_lab2/kl_blowyoustruck02.wav",
	"vo/outland_01/intro/kl_transmit_callmag02.wav",
	"vo/outland_01/intro/kl_transmit_superportal02.wav",
	"vo/k_lab2/kl_notallhopeless.wav",
	"vo/episode_1/intro/kl_damage04.wav",
	"vo/episode_1/intro/kl_noquestion02.wav",
	"vo/episode_1/intro/kl_noquestion03.wav",
	"vo/outland_12a/launch/kl_launch_check05.wav"
}
ENT.SoundTbl_IdleDialogueAnswer = {
	"vo/k_lab/kl_almostforgot.wav",
	"vo/k_lab/kl_fewmoments01.wav",
	"vo/k_lab/kl_fewmoments02.wav",
	"vo/k_lab/kl_nonsense.wav",
	"vo/k_lab/kl_nownow01.wav",
	"vo/k_lab/kl_packing01.wav",
	"vo/k_lab/kl_wishiknew.wav",
	"vo/k_lab2/kl_aweekago01.wav",
	"vo/outland_01/intro/kl_transmit_neversaid.wav",
	"vo/outland_01/intro/kl_transmit_superportal01.wav",
	"vo/trainyard/kl_whatisit02.wav",
	"vo/trainyard/kl_alyxaround.wav",
	"vo/k_lab/kl_moduli02.wav",
	"vo/k_lab2/kl_notallhopeless_b.wav",
	"vo/episode_1/intro/kl_damage02.wav",
	"vo/episode_1/intro/kl_imsorryeli02.wav",
	"vo/episode_1/intro/kl_noquestion01.wav",
	"vo/outland_11a/silo/kl_silo_givenup01.wav",
	"vo/outland_11a/silo/kl_silo_goingover01.wav",
	"vo/outland_11a/silo/kl_silo_wheredata01.wav",
	"vo/outland_12a/launch/kl_launch_check10.wav",
	"vo/outland_12a/launch/kl_launch_check11.wav",
	"vo/outland_12a/launch/kl_launch_valiant01.wav"
}
ENT.SoundTbl_CombatIdle = {
	"vo/trainyard/kl_morewarn03.wav",
	"vo/outland_11a/silo/kl_silo_wheredata03.wav",
	"vo/k_lab/kl_interference.wav"
}
ENT.SoundTbl_ReceiveOrder = {
	"vo/outland_11a/silo/kl_silo_sayinghello01.wav",
	"vo/outland_11a/silo/kl_silo_yesyes.wav",
	"vo/outland_12a/launch/kl_launch_awe05.wav",
	"vo/outland_12a/launch/kl_launch_check12.wav"
}
ENT.SoundTbl_FollowPlayer =
	"vo/k_lab/kl_opportunetime01.wav"

ENT.SoundTbl_UnFollowPlayer = {
	"vo/k_lab/kl_bonvoyage.wav",
	"vo/k_lab2/kl_lamarrwary01.wav",
	"vo/trainyard/kl_verywell.wav"
}
ENT.SoundTbl_YieldToPlayer =
	"vo/k_lab/kl_suitfits01.wav"

ENT.SoundTbl_OnPlayerSight = {
	"vo/k_lab/kl_getoutrun01.wav",
	"vo/k_lab/kl_mygoodness02.wav",
	"vo/k_lab/kl_mygoodness03.wav",
	"vo/trainyard/kl_morewarn02.wav",
	"vo/k_lab/kl_fitglove01.wav",
	"vo/outland_11a/silo/kl_silo_hev.wav"
}
ENT.SoundTbl_Investigate = {
	"vo/k_lab/kl_fiddlesticks.wav",
	"vo/k_lab/kl_whatisit.wav",
	"vo/k_lab2/kl_atthecitadel01.wav",
	"vo/k_lab2/kl_cantleavelamarr.wav",
	"vo/k_lab2/kl_slowteleport01.wav",
	"vo/outland_01/intro/kl_transmit_callmag01.wav",
	"vo/outland_11a/silo/kl_silo_somethingelse01.wav",
	"vo/outland_11a/silo/kl_silo_somethingelse02.wav",
	"vo/outland_12a/launch/kl_launch_anomaly01.wav"
}
ENT.SoundTbl_LostEnemy =
	"vo/k_lab/kl_thenwhere.wav"

ENT.SoundTbl_Alert = {
	"vo/k_lab2/kl_greatscott.wav",
	"vo/trainyard/kl_morewarn01.wav",
	"vo/k_lab/kl_mygoodness01.wav"
}
ENT.SoundTbl_CallForHelp =
	"vo/k_lab/kl_interference.wav"

ENT.SoundTbl_BecomeEnemyToPlayer =
	"vo/k_lab/kl_getoutrun02.wav"

ENT.SoundTbl_Suppressing =
	"vo/k_lab/kl_getoutrun02.wav"

ENT.SoundTbl_WeaponReload =
	"vo/k_lab/kl_fiddlesticks.wav"

ENT.SoundTbl_GrenadeSight = {
	"vo/k_lab/kl_getoutrun02.wav",
	"vo/k_lab/kl_getoutrun03.wav",
	"vo/k_lab/kl_ahhhh.wav"
}
ENT.SoundTbl_DangerSight = {
	"vo/k_lab/kl_getoutrun02.wav",
	"vo/k_lab/kl_getoutrun03.wav",
	"vo/k_lab/kl_ahhhh.wav"
}
ENT.SoundTbl_KilledEnemy = {
	"vo/k_lab/kl_excellent.wav",
	"vo/k_lab/kl_nownow02.wav",
	"vo/k_lab/kl_relieved.wav",
	"vo/outland_11a/silo/kl_silo_incredible.wav",
	"vo/outland_12a/launch/kl_launch_atlast.wav",
	"vo/outland_12a/launch/kl_launch_wedidit.wav"
}
ENT.SoundTbl_AllyDeath = {
	"vo/k_lab/kl_dearme.wav",
	"vo/k_lab/kl_ohdear.wav",
	"vo/k_lab/kl_hedyno03.wav"
}
ENT.SoundTbl_Pain = {
	"vo/k_lab/kl_dearme.wav",
	"vo/k_lab/kl_ohdear.wav",
	"vo/outland_12a/launch/kl_launch_awe01.wav",
	"vo/outland_12a/launch/kl_launch_sigh.wav"
}
ENT.SoundTbl_DamageByPlayer =
	"vo/k_lab/kl_getoutrun01.wav"

ENT.SoundTbl_Death = {
	"vo/k_lab/kl_ahhhh.wav",
	"vo/k_lab/kl_hedyno03.wav"
}

-- Unused
-- NOTE: Number sounds aren't included here!
/*"vo/trainyard/kl_intend.wav"
"vo/trainyard/kl_whatisit01.wav"
"vo/k_lab/kl_barneyhonor.wav"
"vo/k_lab/kl_barneysturn.wav"
"vo/k_lab/kl_besokind.wav"
"vo/k_lab/kl_cantcontinue.wav"
"vo/k_lab/kl_cantwade.wav"
"vo/k_lab/kl_careful.wav"
"vo/k_lab/kl_charger01.wav"
"vo/k_lab/kl_charger02.wav"
"vo/k_lab/kl_comeout.wav"
"vo/k_lab/kl_credit.wav"
"vo/k_lab/kl_finalsequence.wav"
"vo/k_lab/kl_finalsequence02.wav"
"vo/k_lab/kl_fitglove02.wav"
"vo/k_lab/kl_getinposition.wav"
"vo/k_lab/kl_debeaked.wav"
"vo/k_lab/kl_delaydanger.wav"
"vo/k_lab/kl_diditwork.wav"
"vo/k_lab/kl_ensconced.wav"
"vo/k_lab/kl_gordongo.wav"
"vo/k_lab/kl_gordonthrow.wav"
"vo/k_lab/kl_helloalyx01.wav"
"vo/k_lab/kl_heremypet01.wav"
"vo/k_lab/kl_heremypet02.wav"
"vo/k_lab/kl_holdup01.wav"
"vo/k_lab/kl_initializing.wav"
"vo/k_lab/kl_initializing02.wav"
"vo/k_lab/kl_nocareful.wav"
"vo/k_lab/kl_opportunetime02.wav"
"vo/k_lab/kl_plugusin.wav"
"vo/k_lab/kl_projectyou.wav"
"vo/k_lab/kl_redletterday01.wav"
"vo/k_lab/kl_redletterday02.wav"
"vo/k_lab/kl_slipin01.wav"
"vo/k_lab/kl_slipin02.wav"
"vo/k_lab/kl_suitfits02.wav"
"vo/k_lab/kl_waitmyword.wav"
"vo/k_lab/kl_yourturn.wav"
"vo/k_lab2/kl_blowyoustruck01.wav"
"vo/k_lab2/kl_dontgiveuphope02.wav"
"vo/k_lab2/kl_dontgiveuphope03.wav"
"vo/k_lab2/kl_givenuphope.wav"
"vo/k_lab2/kl_howandwhen01.wav"
"vo/k_lab2/kl_howandwhen02.wav"
"vo/k_lab2/kl_lamarrwary02.wav"
"vo/k_lab2/kl_nolongeralone.wav"
"vo/k_lab2/kl_nolongeralone_b.wav"
"vo/k_lab2/kl_notallhopeless.wav"
"vo/k_lab2/kl_slowteleport01_b.wav"
"vo/k_lab2/kl_slowteleport02.wav"
"vo/episode_1/intro/kl_hopeyoufar.wav"
"vo/episode_1/intro/kl_imsorryeli01.wav"
"vo/episode_1/intro/kl_insufficient.wav"
"vo/episode_1/intro/kl_intothecore.wav"
"vo/outland_11a/silo/kl_silo_arrived.wav"
"vo/outland_11a/silo/kl_silo_auxil01.wav"
"vo/outland_11a/silo/kl_silo_auxil02.wav"
"vo/outland_11a/silo/kl_silo_berightthere.wav"
"vo/outland_11a/silo/kl_silo_delight.wav"
"vo/outland_11a/silo/kl_silo_fiethecode01.wav"
"vo/outland_11a/silo/kl_silo_fiethecode02.wav"
"vo/outland_11a/silo/kl_silo_goingover02.wav"
"vo/outland_11a/silo/kl_silo_goldmine01.wav"
"vo/outland_11a/silo/kl_silo_goldmine02.wav"
"vo/outland_11a/silo/kl_silo_goldmine03.wav"
"vo/outland_11a/silo/kl_silo_idontbelieveit01.wav"
"vo/outland_11a/silo/kl_silo_ionlymeant.wav"
"vo/outland_11a/silo/kl_silo_ireally.wav"
"vo/outland_11a/silo/kl_silo_keeponthis.wav"
"vo/outland_11a/silo/kl_silo_nostoppingher.wav"
"vo/outland_11a/silo/kl_silo_noweli01.wav"
"vo/outland_11a/silo/kl_silo_nowfound.wav"
"vo/outland_11a/silo/kl_silo_nowmag01.wav"
"vo/outland_11a/silo/kl_silo_nowmag02.wav"
"vo/outland_11a/silo/kl_silo_sayinghello02.wav"
"vo/outland_11a/silo/kl_silo_trove02.wav"
"vo/outland_11a/silo/kl_silo_waste01.wav"
"vo/outland_11a/silo/kl_silo_wheredata01.wav"
"vo/outland_11a/silo/kl_silo_wheredata02.wav"
"vo/outland_11a/silo/kl_silo_wheredata03.wav"
"vo/outland_12a/launch/kl_launch_anomaly02.wav"
"vo/outland_12a/launch/kl_launch_check01a.wav"
"vo/outland_12a/launch/kl_launch_check01b.wav"
"vo/outland_12a/launch/kl_launch_check02.wav"
"vo/outland_12a/launch/kl_launch_check04.wav"
"vo/outland_12a/launch/kl_launch_check06.wav"
"vo/outland_12a/launch/kl_launch_check07.wav"
"vo/outland_12a/launch/kl_launch_check08.wav"
"vo/outland_12a/launch/kl_launch_check09.wav"
"vo/outland_12a/launch/kl_launch_show01.wav"
"vo/outland_12a/launch/kl_launch_show02.wav"
"vo/outland_12a/launch/kl_launch_show03.wav"
"vo/outland_12a/launch/kl_launch_theirsuccess.wav"
"vo/outland_12a/launch/kl_launch_ticking01.wav"
"vo/outland_12a/launch/kl_launch_ticking02.wav"
*/
-- Specific alert sounds
local sdAlertHeadcrab = {"vo/k_lab/kl_hedyno02.wav", "vo/k_lab2/kl_onehedy.wav"}

ENT.MainSoundPitch = 100

function ENT:OnAlert(ent)
	if math.random(1, 2) == 1 and ent:IsNPC() then
		if ent.VJ_ID_Headcrab then
			self:PlaySoundSystem("Alert", sdAlertHeadcrab)
			return
		end
	end
end