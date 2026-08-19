AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vortigaunt.mdl"
-- ENT.Model = "models/vortigaunt_slave.mdl"
ENT.StartHealth = 100
ENT.HullType = HULL_HUMAN

ENT.JumpParams = {
	MaxRise = 80,
	MaxDrop = 192,
	MaxDistance = 250,
}

ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY", "CLASS_VORTIGAUNT"}
ENT.AlliedWithPlayerAllies = true
ENT.HasOnPlayerSight = true
ENT.BecomeEnemyToPlayer = 2

ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.BloodParticle = "blood_impact_yellow_01"

ENT.MeleeAttackDamage = 10
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 35
ENT.MeleeAttackDamageDistance = 75
ENT.TimeUntilMeleeAttackDamage = false

ENT.HasRangeAttack = true
ENT.AnimTbl_RangeAttack = ACT_RANGE_ATTACK1
ENT.RangeAttackMaxDistance = 1024
ENT.RangeAttackMinDistance = 256
ENT.TimeUntilRangeAttackProjectileRelease = false
ENT.NextRangeAttackTime = VJ.SET(3, 6)

ENT.LimitChaseDistance = "OnlyRange"
ENT.LimitChaseDistance_Max = "UseRangeDistance"
ENT.LimitChaseDistance_Min = "UseRangeDistance"

ENT.IsMedic = true
ENT.Medic_HealDistance = 256
ENT.Medic_HealAmount = 50
ENT.Medic_SpawnPropOnHeal = false

ENT.CanFlinch = true
ENT.FlinchChance = 1
ENT.FlinchCooldown = 3
ENT.AnimTbl_Flinch = {"vjges_flinch_01", "vjges_flinch_02", "vjges_flinch_03"}

ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true
ENT.MainSoundPitch = 100

ENT.SoundTbl_FootStep = {"vj_hlr/src/npc/vort/vort_foot1.wav", "vj_hlr/src/npc/vort/vort_foot2.wav", "vj_hlr/src/npc/vort/vort_foot3.wav", "vj_hlr/src/npc/vort/vort_foot4.wav"}
ENT.SoundTbl_IdleDialogue = {
	"vo/eli_lab/vort_elab_use01.wav",
	"vo/eli_lab/vort_elab_use02.wav",
	"vo/eli_lab/vort_elab_use03.wav",
	"vo/eli_lab/vort_elab_use04.wav",
	"vo/eli_lab/vort_elab_use05.wav",
	"vj_hlr/src/npc/vort/vo/vort_grp_greetings04.wav",
	"vj_hlr/src/npc/vort/vo/vortigese02.wav",
	"vj_hlr/src/npc/vort/vo/vortigese03.wav",
	"vj_hlr/src/npc/vort/vo/vortigese04.wav",
	"vj_hlr/src/npc/vort/vo/vortigese05.wav",
	"vj_hlr/src/npc/vort/vo/vortigese07.wav",
	"vj_hlr/src/npc/vort/vo/vortigese08.wav",
	"vj_hlr/src/npc/vort/vo/vortigese09.wav",
	"vj_hlr/src/npc/vort/vo/vortigese13.wav",
	"vo/npc/vortigaunt/vques01.wav",
	"vo/npc/vortigaunt/vques02.wav",
	"vo/npc/vortigaunt/vques03.wav",
	"vo/npc/vortigaunt/vques04.wav",
	"vo/npc/vortigaunt/vques05.wav",
	"vo/npc/vortigaunt/vques06.wav",
	"vo/npc/vortigaunt/vques07.wav",
	"vo/npc/vortigaunt/vques08.wav",
	"vo/npc/vortigaunt/vques09.wav",
	"vo/npc/vortigaunt/vques10.wav"
}
ENT.SoundTbl_IdleDialogueAnswer = {
	"vj_hlr/src/npc/vort/vo/vort_grp_agree01.wav",
	"vj_hlr/src/npc/vort/vo/vort_grp_agree02.wav",
	"vj_hlr/src/npc/vort/vo/vort_grp_agree03.wav",
	"vj_hlr/src/npc/vort/vo/vort_grp_agree04.wav",
	"vj_hlr/src/npc/vort/vo/vort_grp_agree05.wav",
	"vj_hlr/src/npc/vort/vo/vort_grp_agree06.wav",
	"vj_hlr/src/npc/vort/vo/vort_grp_agree07.wav",
	"vj_hlr/src/npc/vort/vo/vortigese02.wav",
	"vj_hlr/src/npc/vort/vo/vortigese03.wav",
	"vj_hlr/src/npc/vort/vo/vortigese04.wav",
	"vj_hlr/src/npc/vort/vo/vortigese05.wav",
	"vj_hlr/src/npc/vort/vo/vortigese07.wav",
	"vj_hlr/src/npc/vort/vo/vortigese08.wav",
	"vj_hlr/src/npc/vort/vo/vortigese09.wav",
	"vj_hlr/src/npc/vort/vo/vortigese13.wav",
	"vj_hlr/src/npc/vort/vo/yes.wav",
	"vo/npc/vortigaunt/vanswer01.wav",
	"vo/npc/vortigaunt/vanswer02.wav",
	"vo/npc/vortigaunt/vanswer03.wav",
	"vo/npc/vortigaunt/vanswer04.wav",
	"vo/npc/vortigaunt/vanswer05.wav",
	"vo/npc/vortigaunt/vanswer06.wav",
	"vo/npc/vortigaunt/vanswer07.wav",
	"vo/npc/vortigaunt/vanswer08.wav",
	"vo/npc/vortigaunt/vanswer09.wav",
	"vo/npc/vortigaunt/vanswer10.wav",
	"vo/npc/vortigaunt/vanswer11.wav",
	"vo/npc/vortigaunt/vanswer12.wav",
	"vo/npc/vortigaunt/vanswer13.wav",
	"vo/npc/vortigaunt/vanswer14.wav",
	"vo/npc/vortigaunt/vanswer15.wav",
	"vo/npc/vortigaunt/vanswer16.wav",
	"vo/npc/vortigaunt/vanswer17.wav",
	"vo/npc/vortigaunt/vanswer18.wav"
}
ENT.SoundTbl_FollowPlayer = {
	"vo/coast/vgossip_02.wav",
	"vj_hlr/src/npc/vort/vo/accompany.wav",
	"vj_hlr/src/npc/vort/vo/bodyyours.wav",
	"vj_hlr/src/npc/vort/vo/dedicate.wav",
	"vj_hlr/src/npc/vort/vo/dreamed.wav",
	"vj_hlr/src/npc/vort/vo/fmaccompany.wav",
	"vj_hlr/src/npc/vort/vo/fmmustfollow.wav",
	"vj_hlr/src/npc/vort/vo/fmmustmove.wav",
	"vj_hlr/src/npc/vort/vo/followfm.wav",
	"vj_hlr/src/npc/vort/vo/gloriousend.wav",
	"vj_hlr/src/npc/vort/vo/honorfollow.wav",
	"vj_hlr/src/npc/vort/vo/leadon.wav",
	"vj_hlr/src/npc/vort/vo/leadus.wav",
	"vj_hlr/src/npc/vort/vo/onward.wav",
	"vj_hlr/src/npc/vort/vo/pleasure.wav",
	"vj_hlr/src/npc/vort/vo/propitious.wav",
	"vj_hlr/src/npc/vort/vo/vort_excellent.wav",
	"vj_hlr/src/npc/vort/vo/vort_fmisinvcomp.wav",
	"vj_hlr/src/npc/vort/vo/weareyours.wav",
	"vj_hlr/src/npc/vort/vo/weclaimyou.wav",
	"vj_hlr/src/npc/vort/vo/wefollowfm.wav",
	"vj_hlr/src/npc/vort/vo/wewillhelp.wav",
	"vj_hlr/src/npc/vort/vo/yesforward.wav"
}
ENT.SoundTbl_UnFollowPlayer = {
	"vj_hlr/src/npc/vort/vo/fmknowsbest.wav",
	"vj_hlr/src/npc/vort/vo/gladly.wav",
	"vj_hlr/src/npc/vort/vo/halt.wav",
	"vj_hlr/src/npc/vort/vo/herewestay.wav",
	"vj_hlr/src/npc/vort/vo/here.wav",
	"vj_hlr/src/npc/vort/vo/hold.wav",
	"vj_hlr/src/npc/vort/vo/mutual.wav",
	"vj_hlr/src/npc/vort/vo/ourplacehere.wav"
}
ENT.SoundTbl_YieldToPlayer = {
	"vj_hlr/src/npc/vort/vo/fmadvance.wav",
	"vj_hlr/src/npc/vort/vo/fminway.wav",
	"vj_hlr/src/npc/vort/vo/hastefm.wav"
}
ENT.SoundTbl_OnPlayerSight = {
	"vo/canals/vort_reckoning.wav",
	"vo/coast/bugbait/vbaittrain01a.wav",
	"vj_hlr/src/npc/vort/vo/cautionfm.wav",
	"vj_hlr/src/npc/vort/vo/cautionfm02.wav",
	"vj_hlr/src/npc/vort/vo/empowerus.wav",
	"vj_hlr/src/npc/vort/vo/fmdoesushonor.wav",
	"vj_hlr/src/npc/vort/vo/fmhonorsus.wav",
	"vj_hlr/src/npc/vort/vo/freeman.wav",
	"vj_hlr/src/npc/vort/vo/honorours.wav",
	"vj_hlr/src/npc/vort/vo/vort_goodfightwithus.wav",
	"vj_hlr/src/npc/vort/vo/vort_goodtogether.wav",
	"vj_hlr/src/npc/vort/vo/wellmet.wav"
}
ENT.SoundTbl_LostEnemy = {
	"vj_hlr/src/npc/vort/vo/thatisall.wav",
	"vj_hlr/src/npc/vort/vo/vort_skillsformidable.wav"
}
ENT.SoundTbl_Alert = {
	"vj_hlr/src/npc/vort/vo/alert.wav",
	"vj_hlr/src/npc/vort/vo/assent.wav",
	"vj_hlr/src/npc/vort/vo/caution.wav",
	"vj_hlr/src/npc/vort/vo/fmbeware.wav",
	"vj_hlr/src/npc/vort/vo/fmmustbeware.wav",
	"vj_hlr/src/npc/vort/vo/forfreedom.wav",
	"vj_hlr/src/npc/vort/vo/forthefm.wav",
	"vj_hlr/src/npc/vort/vo/forward.wav",
	"vj_hlr/src/npc/vort/vo/giveover.wav",
	"vj_hlr/src/npc/vort/vo/nodenexus.wav",
	"vj_hlr/src/npc/vort/vo/prevail.wav",
	"vj_hlr/src/npc/vort/vo/surge.wav",
	"vj_hlr/src/npc/vort/vo/vortigese02.wav",
	"vj_hlr/src/npc/vort/vo/vortigese03.wav",
	"vj_hlr/src/npc/vort/vo/vortigese04.wav",
	"vj_hlr/src/npc/vort/vo/vortigese05.wav",
	"vj_hlr/src/npc/vort/vo/vortigese07.wav",
	"vj_hlr/src/npc/vort/vo/vortigese08.wav",
	"vj_hlr/src/npc/vort/vo/vortigese09.wav",
	"vj_hlr/src/npc/vort/vo/vortigese13.wav"
}
ENT.SoundTbl_BeforeMeleeAttack =
	"vj_hlr/src/npc/vort/vo/vort_attack21.wav"

ENT.SoundTbl_KilledEnemy = {
	"vj_hlr/src/npc/vort/vo/allfornow.wav",
	"vj_hlr/src/npc/vort/vo/allinoneinall.wav",
	"vj_hlr/src/npc/vort/vo/done.wav",
	"vj_hlr/src/npc/vort/vo/passon.wav",
	"vj_hlr/src/npc/vort/vo/returntoall.wav",
	"vj_hlr/src/npc/vort/vo/satisfaction.wav",
	"vj_hlr/src/npc/vort/vo/tothevoid.wav",
	"vj_hlr/src/npc/vort/vo/troubleus.wav",
	"vj_hlr/src/npc/vort/vo/undeserving.wav"
}
ENT.SoundTbl_AllyDeath = {
	"vj_hlr/src/npc/vort/vo/regrettable.wav",
	"vj_hlr/src/npc/vort/vo/returnvoid.wav"
}
ENT.SoundTbl_Pain = {
	"vo/npc/vortigaunt/vortigese03.wav",
	"vo/npc/vortigaunt/vortigese05.wav",
	"vo/npc/vortigaunt/vortigese07.wav"
}

/*
	Animations
		"Defend"
		"dispel"
		"heal_start"
		"heal_cycle"
		"heal_end"
*/
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.Vort_AnimationCache = {} -- Should we use this? Better than converting these everytime theyre needed ig
--
function ENT:Init()
	self:CapabilitiesAdd(bit.bor(CAP_ANIMATEDFACE))

	if !self.Vort_AnimationCache["Defend"] then
		self.Vort_AnimationCache["Defend"] = self:GetSequenceActivity(self:LookupSequence("Defend"))
		self.Vort_AnimationCache["dispel"] = self:GetSequenceActivity(self:LookupSequence("dispel"))
		self.Vort_AnimationCache["heal_start"] = self:GetSequenceActivity(self:LookupSequence("heal_start"))
		self.Vort_AnimationCache["heal_cycle"] = self:GetSequenceActivity(self:LookupSequence("heal_cycle"))
		self.Vort_AnimationCache["heal_end"] = self:GetSequenceActivity(self:LookupSequence("heal_end"))
	end

	self.Vort_DispelT = 0
	self.NextRandMoveT = 0
	self.AnimTbl_Medic_GiveHealth = self.Vort_AnimationCache["heal_cycle"]
end
---------------------------------------------------------------------------------------------------------------------------------------------
local getEventName = util.GetAnimEventNameByID
--
function ENT:OnAnimEvent(ev, evTime, evCycle, evType, evOptions)
	local event = getEventName(ev)
	-- print("OnAnimEvent: ", "eventName", event, "ev", ev, "evTime", evTime, "evCycle", evCycle, "evType", evType, "evOptions", evOptions)
	if event == "AE_VORTIGAUNT_ZAP_POWERUP" or event == "AE_VORTIGAUNT_DEFEND_BEAMS" or event == "AE_VORTIGAUNT_HEAL_STARTBEAMS" then
		local short = event == "AE_VORTIGAUNT_DEFEND_BEAMS"
		local noElec = event == "AE_VORTIGAUNT_HEAL_STARTBEAMS"
		if !short && !noElec && (!self.Vort_ZapPowerUp or self.Vort_ZapPowerUp && !self.Vort_ZapPowerUp:IsPlaying()) then
			self.Vort_ZapPowerUp = CreateSound(self, "npc/vort/attack_charge.wav")
			self.Vort_ZapPowerUp:Play()
		end

		for i = 3, (noElec && 3 or 4) do
			ParticleEffectAttach(noElec && "vortigaunt_hand_glow" or "vortigaunt_charge_token", PATTACH_POINT_FOLLOW, self, i)

			local light = ents.Create("light_dynamic")
			light:SetKeyValue("_light", "44 255 139 255")
			light:SetKeyValue("style", "0")
			light:SetKeyValue("distance", "200")
			light:SetKeyValue("brightness", "2")
			light:SetLocalPos(self:GetAttachment(i).Pos)
			light:SetLocalAngles(self:GetAttachment(i).Ang)
			light:Spawn()
			light:Activate()
			light:SetParent(self)
			light:Fire("TurnOn")
			light:Fire("SetParentAttachment", i == 3 && "leftclaw" or "rightclaw")
			self:DeleteOnRemove(light)

			if !noElec then
				local target = ents.Create("prop_vj_animatable")
				target:SetName("vortigaunt_charge_token" .. i .. "_" .. target:EntIndex())
				target:SetModel("models/props_junk/watermelon01.mdl")
				target:SetPos(self:GetAttachment(i).Pos +VectorRand() *math.Rand(0, 128))
				target:Spawn()
				target:Activate()
				target:SetNoDraw(true)
				target:DrawShadow(false)
				target:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
				target:SetSolid(SOLID_NONE)

				local att = self:GetAttachment(i)
				local particle = ents.Create("info_particle_system")
				particle:SetKeyValue("effect_name", "vortigaunt_beam_charge")
				particle:SetPos(att.Pos)
				particle:SetAngles(att.Ang)
				particle:SetKeyValue("start_active", "1")
				particle:SetKeyValue("cpoint1", target:GetName())
				particle:Spawn()
				particle:Activate()
				particle:SetParent(self)
				particle:Fire("SetParentAttachment", i == 3 && "leftclaw" or "rightclaw")
				particle:DeleteOnRemove(target)
				self:DeleteOnRemove(particle)
			end

			local deleteTime = (short or noElec) && 0.25 or 1.5
			SafeRemoveEntityDelayed(target, deleteTime)
			SafeRemoveEntityDelayed(particle, deleteTime)
			SafeRemoveEntityDelayed(light, deleteTime)
			if short then
				timer.Simple(0.25, function()
					if IsValid(self) then
						self:StopParticles()
					end
				end)
			end
		end
	elseif event == "AE_VORTIGAUNT_SHOOT_SOUNDSTART" then
		VJ.STOPSOUND(self.Vort_ZapPowerUp)
		VJ.EmitSound(self, "vj_hlr/src/npc/vort/attack_shoot.wav", 75)
		VJ.EmitSound(self, "vj_hlr/src/npc/vort/vort_attack_shoot" .. math.random(1, 2) .. ".wav", 75)
	elseif event == "AE_VORTIGAUNT_ZAP_SHOOT" then
		self:ExecuteRangeAttack()
	elseif event == "AE_VORTIGAUNT_ZAP_DONE" then
		self:StopParticles()
	elseif event == "AE_VORTIGAUNT_CLAW_LEFT" then
		self:ExecuteMeleeAttack()
	elseif event == "AE_VORTIGAUNT_CLAW_RIGHT" then
		self:ExecuteMeleeAttack()
	elseif event == "AE_VORTIGAUNT_START_DISPEL" then
		VJ.EmitSound(self, "vj_hlr/src/npc/vort/vort_dispell.wav", 75)
	elseif event == "AE_VORTIGAUNT_ACCEL_DISPEL" then
		VJ.EmitSound(self, "vj_hlr/src/npc/vort/vort_attack_shoot1.wav", 85)
	elseif event == "AE_VORTIGAUNT_DISPEL" then
		self:StopParticles()
		VJ.STOPSOUND(self.Vort_ZapPowerUp)
		VJ.EmitSound(self, "vj_hlr/src/npc/vort/vort_explode" .. math.random(1, 2) .. ".wav", 85)
		util.ScreenShake(self:GetPos(), 16, 100, 1, 600)
		VJ.ApplyRadiusDamage(self, self, self:GetPos(), 500, 90, bit.bor(DMG_SHOCK, DMG_ENERGYBEAM, DMG_BLAST), true, false, {Force = 175})
		for _, v in pairs(ents.FindInSphere(self:GetPos(), 500)) do
			if (v:IsNPC() && v != self or v:IsPlayer()) && self:CheckRelationship(v) == D_LI then
				v:SetHealth(math.Clamp(v:Health() +25, 1, v:GetMaxHealth()))
			end
		end
		self:SetHealth(math.Clamp(self:Health() +50, 1, self:GetMaxHealth()))

		effects.BeamRingPoint(self:GetPos(), 0.2, 12, 500, 64, 0, Color(44, 255, 139), {material="sprites/lgtning.vmt", framerate=2, flags=0, speed=0, delay=0, spread=0})
		effects.BeamRingPoint(self:GetPos(), 0.2, 12, 500, 64, 0, Color(44, 255, 139), {material="sprites/lgtning.vmt", framerate=2, flags=0, speed=0, delay=0, spread=0})

		local light = ents.Create("light_dynamic")
		light:SetKeyValue("_light", "44 255 139 255")
		light:SetKeyValue("style", "0")
		light:SetKeyValue("distance", "600")
		light:SetKeyValue("brightness", "4")
		light:SetPos(self:GetPos())
		light:Spawn()
		light:Activate()
		light:Fire("TurnOn")
		SafeRemoveEntityDelayed(light, 0.15)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRangeAttackExecute(status, enemy, projectile)
	if status == "Init" then
		local startPos = self:GetPos() + self:GetUp()*45 + self:GetForward()*40
		local tr = util.TraceLine({
			start = startPos,
			endpos = self:GetAimPosition(enemy, startPos, 0),
			filter = self
		})
		local hitPos = tr.HitPos

		util.ParticleTracerEx("vortigaunt_beam", startPos, hitPos, false, self:EntIndex(), self:LookupAttachment("leftclaw"))
		util.ParticleTracerEx("vortigaunt_beam", startPos, hitPos, false, self:EntIndex(), self:LookupAttachment("rightclaw"))

		sound.Play("vj_hlr/src/npc/vort/vort_attack_shoot" .. math.random(3, 4) .. ".wav", hitPos, 75)
		VJ.ApplyRadiusDamage(self, self, hitPos, 100, 25, bit.bor(DMG_SHOCK, DMG_ENERGYBEAM), true, false, {Force = 90})

		local light = ents.Create("light_dynamic")
		light:SetKeyValue("_light", "44 255 139 255")
		light:SetKeyValue("style", "0")
		light:SetKeyValue("distance", "200")
		light:SetKeyValue("brightness", "2")
		light:SetPos(hitPos)
		light:Spawn()
		light:Activate()
		light:Fire("TurnOn")
		SafeRemoveEntityDelayed(light, 0.1)
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local alertAntlions = {"vj_hlr/src/npc/vort/vo/alert_antlions.wav"}
--
function ENT:OnAlert(ent)
	if math.random(1, 2) == 1 && ent:IsNPC() then
		for _, v in ipairs(ent.VJ_NPC_Class or {1}) do
			if v == "CLASS_ANTLION" or ent:Classify() == CLASS_ANTLION then
				self:PlaySoundSystem("Alert", alertAntlions)
				return
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnMedicBehavior(status, statusData)
	if status == "OnHeal" then
		if statusData:IsPlayer() then
			statusData:SetArmor(math.Clamp(statusData:Armor() + 25, 0, 100))
		end
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if self.Alerted then
		if act == ACT_IDLE then
			return ACT_IDLE_ANGRY
		elseif act == ACT_WALK then
			return ACT_WALK_AIM
		elseif act == ACT_RUN then
			return ACT_RUN_AIM
		end
	end
	return act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SelectSchedule()
	self.BaseClass.SelectSchedule(self)
	if !self.Dead && self.Vort_RunAway && !self:IsBusy() && !self.VJ_IsBeingControlled then
		self.Vort_RunAway = false
		self:SCHEDULE_COVER_ENEMY("TASK_RUN_PATH", function(x) x.RunCode_OnFail = function() self.NextDoAnyAttackT = 0 end end)
		self.NextDoAnyAttackT = CurTime() + 5
		self.NextRandMoveT = CurTime() + 5
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkAttack(isAttacking, enemy)
	if !self.VJ_IsBeingControlled then
		local eneData = self.EnemyData
		if eneData.Visible && CurTime() > self.NextRandMoveT && eneData.DistanceNearest <= self.RangeAttackMaxDistance && !self:IsBusy() && !self.Vort_RunAway then
			local checkdist = self:VJ_CheckAllFourSides(375)
			local randmove = {}
			if checkdist.Backward == true then randmove[#randmove+1] = "Backward" end
			if checkdist.Right == true then randmove[#randmove+1] = "Right" end
			if checkdist.Left == true then randmove[#randmove+1] = "Left" end
			local pickmove = VJ.PICK(randmove)
			if pickmove == "Backward" then self:SetLastPosition(self:GetPos() +self:GetForward() *1000) end
			if pickmove == "Right" then self:SetLastPosition(self:GetPos() +self:GetRight() *1000) end
			if pickmove == "Left" then self:SetLastPosition(self:GetPos() +self:GetRight() *1000) end
			if pickmove == "Backward" or pickmove == "Right" or pickmove == "Left" then
				self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x) x:EngTask("TASK_FACE_ENEMY", 0) x.TurnData = {Type = VJ.FACE_ENEMY} end)
				self.NextRandMoveT = CurTime() +math.Rand(3, 6)
			end
		end
	else
		local ply = self.VJ_TheController
		if ply:KeyDown(IN_JUMP) && CurTime() > self.Vort_DispelT && !self:IsBusy() then
			local _, dur = self:PlayAnim("dispel", true, false, false)
			self.NextDoAnyAttackT = CurTime() +dur
			self.NextRandMoveT = CurTime() +dur
			self.Vort_DispelT = CurTime() +dur
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "PostDamage" then
		if self.VJ_IsBeingControlled then return end
		if math.random(1, dmginfo:IsBulletDamage() && 3 or 6) == 1 then
			self.Vort_RunAway = true
		elseif !self.Vort_RunAway && math.random(1, 4) == 1 && !dmginfo:IsBulletDamage() && CurTime() > self.Vort_DispelT then
			local _, dur = self:PlayAnim("dispel", true, false, false)
			self.NextDoAnyAttackT = CurTime() +dur
			self.NextRandMoveT = CurTime() +dur
			self.Vort_DispelT = CurTime() +dur +math.random(1, 4)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFlinch(dmginfo, hitgroup, status)
	if status == "Execute" then
		self:StopParticles()
		VJ.STOPSOUND(self.Vort_ZapPowerUp)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnChangeActivity(newAct)
	self:StopParticles()
	VJ.STOPSOUND(self.Vort_ZapPowerUp)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	VJ.STOPSOUND(self.Vort_ZapPowerUp)
end