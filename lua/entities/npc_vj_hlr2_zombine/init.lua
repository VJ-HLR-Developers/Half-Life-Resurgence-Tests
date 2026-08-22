AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/zombine.mdl"
ENT.StartHealth = 100
ENT.HullType = HULL_WIDE_HUMAN

ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}

ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.BloodParticle = "blood_impact_green_01"

ENT.MeleeAttackDamage = 15
ENT.AnimTbl_MeleeAttack = "FastAttack"
ENT.MeleeAttackDistance = 35
ENT.MeleeAttackDamageDistance = 75
ENT.TimeUntilMeleeAttackDamage = false

ENT.DeathLootChance = 10
ENT.DeathLoot = "weapon_frag"

ENT.CanFlinch = true
ENT.FlinchChance = 8
ENT.FlinchCooldown = 5
ENT.AnimTbl_Flinch = ACT_FLINCH_PHYSICS
ENT.FlinchHitGroupMap = {
	{HitGroup = {HITGROUP_LEFTLEG}, Animation = {ACT_FLINCH_LEFTLEG}},
	{HitGroup = {HITGROUP_RIGHTLEG}, Animation = {ACT_FLINCH_RIGHTLEG}}
}

ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true
ENT.MainSoundPitch = 100

ENT.SoundTbl_FootStep = {"vj_hlr/src/npc/zombine/gear1.wav", "vj_hlr/src/npc/zombine/gear2.wav", "vj_hlr/src/npc/zombine/gear3.wav"}
ENT.SoundTbl_Idle = {"vj_hlr/src/npc/zombine/zombine_idle1.wav", "vj_hlr/src/npc/zombine/zombine_idle2.wav", "vj_hlr/src/npc/zombine/zombine_idle3.wav", "vj_hlr/src/npc/zombine/zombine_idle4.wav"}
ENT.SoundTbl_Alert = {"vj_hlr/src/npc/zombine/zombine_alert1.wav", "vj_hlr/src/npc/zombine/zombine_alert2.wav", "vj_hlr/src/npc/zombine/zombine_alert3.wav", "vj_hlr/src/npc/zombine/zombine_alert4.wav", "vj_hlr/src/npc/zombine/zombine_alert5.wav", "vj_hlr/src/npc/zombine/zombine_alert7.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"vj_hlr/src/npc/zombine/zombine_charge1.wav", "vj_hlr/src/npc/zombine/zombine_charge2.wav"}
ENT.SoundTbl_MeleeAttackExtra = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"npc/zombie/claw_miss1.wav", "npc/zombie/claw_miss2.wav"}
ENT.SoundTbl_Pain = {"vj_hlr/src/npc/zombine/zombine_pain1.wav", "vj_hlr/src/npc/zombine/zombine_pain2.wav", "vj_hlr/src/npc/zombine/zombine_pain3.wav", "vj_hlr/src/npc/zombine/zombine_pain4.wav"}
ENT.SoundTbl_DeathFollow = {"vj_hlr/src/npc/zombine/zombine_die1.wav", "vj_hlr/src/npc/zombine/zombine_die2.wav"}
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
	self.IsSlumped = doSlump
	self.CanFlinch = doSlump && 0 or 1
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if self.IsSlumped then
		self:SetSlump(false)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	local zType = self.ZombieType or math.random(0, 3)
	self.SlumpAnimation = ACT_IDLE

	if self.Slump then
		self:SetSlump(true)
	end

	self.GrenadePulled = false
	self.GrenadeTime = 0
	self.RageState = false

	if self.ZombieType != 69 then
		if zType == 3 then
			local hp = self.StartHealth *1.25
			self:SetHealth(hp)
			self:SetMaxHealth(hp)
			self.DeathLoot = "item_ammo_ar2_altfire"
		end
		self:SetSkin(zType)
	end

	self:SetBodygroup(1, 1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then
		VJ.EmitSound(self, self.SoundTbl_FootStep, self.FootstepSoundLevel)
	elseif key == "pin" then
		self:CreateGrenade()
	elseif key == "melee" then
		self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkAttack(isAttacking, enemy)
	local dist = self.EnemyData.DistanceNearest
	if !self.RageState && (self.VJ_IsBeingControlled && self.VJ_TheController:KeyDown(IN_JUMP) or !self.VJ_IsBeingControlled && dist <= 750 && math.random(1, dist *0.5) == 1) then
		VJ.STOPSOUND(self.CurrentSpeechSound)
		VJ.STOPSOUND(self.CurrentIdleSound)
		VJ.CreateSound(self, "vj_hlr/src/npc/zombine/zombine_alert6.wav", 80)
		self.RageState = true
		self.RageStateTime = CurTime() +math.Rand(6, 12)
	elseif self.RageState && CurTime() > self.RageStateTime then
		self.RageState = false
	end

	if !self.GrenadePulled && !self:IsBusy() && (self.VJ_IsBeingControlled && self.VJ_TheController:KeyDown(IN_ATTACK2) or !self.VJ_IsBeingControlled && math.random(1, (self:Health() < self:GetMaxHealth() *0.25) && 15 or 150) == 1 && dist < 300) then
		self.GrenadePulled = true
		self.GrenadeTime = CurTime() +20
		VJ.CreateSound(self, "npc/zombine/zombine_readygrenade" .. math.random(1, 2) .. ".wav", 80, 100)
		self:PlayAnim("pullGrenade", true, false, true)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	if self.IsSlumped then
		self.IdleSoundBlockTime = CurTime() +math.random(4, 8)
	else
		if self.GrenadePulled && CurTime() > self.GrenadeTime then
			self:SetHealth(0)
			self.GodMode = false
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(100)
			dmginfo:SetDamageType(DMG_BLAST)
			dmginfo:SetAttacker(self)
			dmginfo:SetInflictor(IsValid(self.GrenadeEntity) && self.GrenadeEntity or self)
			dmginfo:SetDamagePosition(self:GetAttachment(self:LookupAttachment("grenade_attachment")).Pos)
			self:TakeDamageInfo(dmginfo)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if act == ACT_IDLE then
		if self.IsSlumped then
			return self.SlumpAnimation
		elseif self.GrenadePulled then
			return ACT_IDLE_AGITATED
		end
	elseif act == ACT_RUN then
		if self.RageState then
			return self.GrenadePulled && ACT_RUN_AGITATED or ACT_RUN
		end
		return ACT_WALK
	elseif act == ACT_WALK then
		if self.RageState then
			return self.GrenadePulled && ACT_RUN_AGITATED or ACT_RUN
		end
		return self.GrenadePulled && ACT_WALK_AGITATED or ACT_WALK
	end
	return act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCreateDeathCorpse(dmginfo, hitgroup, ent)
	if self:GetBodygroup(1) == 0 then
		return false
	end

	local oldEnt = self.GrenadeEntity
	if IsValid(oldEnt) then
		local grenent = ents.Create("obj_vj_grenade")
		grenent:SetModel("models/weapons/w_npcnade.mdl")
		grenent:SetPos(self:GetAttachment(self:LookupAttachment("grenade_attachment")).Pos)
		grenent:SetAngles(self:GetAttachment(self:LookupAttachment("grenade_attachment")).Ang)
		grenent.FuseTime = (oldEnt.CurFuss -CurTime())
		grenent:Spawn()
		grenent.SoundTbl_Idle = "weapons/grenade/tick1.wav"
		grenent.IdleSoundPitch = VJ.SET(100, 100)

		local redGlow = ents.Create("env_sprite")
		redGlow:SetKeyValue("model", "vj_base/sprites/glow.vmt")
		redGlow:SetKeyValue("scale", "0.07")
		redGlow:SetKeyValue("rendermode", "5")
		redGlow:SetKeyValue("rendercolor", "150 0 0")
		redGlow:SetKeyValue("spawnflags", "1") -- If animated
		redGlow:SetParent(grenent)
		redGlow:Fire("SetParentAttachment", "fuse", 0)
		redGlow:Spawn()
		redGlow:Activate()
		grenent:DeleteOnRemove(redGlow)
		util.SpriteTrail(grenent, 1, Color(200, 0, 0), true, 15, 15, 0.35, 0.0167, "VJ_Base/sprites/trail.vmt")
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
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCreateSound(sdData, sdFile)
	if VJ.HasValue(self.SoundTbl_Pain, sdFile) then return end
	VJ.EmitSound(self, "npc/combine_soldier/vo/on" .. math.random(1, 2) .. ".wav")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateGrenade()
	if IsValid(self.GrenadeEntity) then return end
	local grenent = ents.Create("obj_vj_grenade")
	grenent:SetModel("models/weapons/w_npcnade.mdl")
	grenent:SetPos(self:GetAttachment(self:LookupAttachment("grenade_attachment")).Pos)
	grenent:SetAngles(self:GetAttachment(self:LookupAttachment("grenade_attachment")).Ang)
	grenent:SetOwner(self)
	grenent:SetParent(self)
	grenent:Fire("SetParentAttachment", "grenade_attachment", 0)
	grenent.FuseTime = 3.5
	grenent.CurFuss = CurTime() +3.5
	grenent:Spawn()
	grenent:Activate()
	grenent:SetSolid(SOLID_NONE)
	grenent.SoundTbl_Idle = {"weapons/grenade/tick1.wav"}
	grenent.IdleSoundPitch = VJ.SET(100, 100)
	self:DeleteOnRemove(grenent)

	local redGlow = ents.Create("env_sprite")
	redGlow:SetKeyValue("model", "vj_base/sprites/glow.vmt")
	redGlow:SetKeyValue("scale", "0.07")
	redGlow:SetKeyValue("rendermode", "5")
	redGlow:SetKeyValue("rendercolor", "150 0 0")
	redGlow:SetKeyValue("spawnflags", "1") -- If animated
	redGlow:SetParent(grenent)
	redGlow:Fire("SetParentAttachment", "fuse", 0)
	redGlow:Spawn()
	redGlow:Activate()
	grenent:DeleteOnRemove(redGlow)
	util.SpriteTrail(grenent, 1, Color(200, 0, 0), true, 15, 15, 0.35, 0.0167, "VJ_Base/sprites/trail.vmt")

	-- timer.Simple(3.485, function()
	-- 	if IsValid(self) && IsValid(grenent) then
	-- 		grenent:SetOwner(NULL)
	-- 		grenent:SetParent(NULL)
	-- 	end
	-- end)

	self.GrenadeEntity = grenent
	self.GrenadeTime = CurTime() +3.5
	-- grenent.VJHumanTossingAway = true // Soldiers kept stealing their grenades xD
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "PreDamage" then
		if hitgroup == HITGROUP_HEAD then return end
		if dmginfo:IsBulletDamage() then
			if self.HasSounds && self.HasImpactSounds then VJ.EmitSound(self, "VJ.Impact.Armor") end
			if math.random(1, 3) == 1 then
				dmginfo:ScaleDamage(0.50)
				local spark = ents.Create("env_spark")
				spark:SetKeyValue("Magnitude", "1")
				spark:SetKeyValue("Spark Trail Length", "1")
				spark:SetPos(dmginfo:GetDamagePosition())
				spark:SetAngles(self:GetAngles())
				spark:SetParent(self)
				spark:Spawn()
				spark:Activate()
				spark:Fire("StartSpark", nil, 0)
				spark:Fire("StopSpark", nil, 0.001)
				self:DeleteOnRemove(spark)
			else
				dmginfo:ScaleDamage(0.80)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnBleed(dmginfo, hitgroup)
	if self.IsSlumped then
		self:SetSlump(false)
	else
		if !self.RageState && !self:IsBusy() && math.random(1, 10) == 1 then
			VJ.STOPSOUND(self.CurrentSpeechSound)
			VJ.STOPSOUND(self.CurrentIdleSound)
			VJ.CreateSound(self, "vj_hlr/src/npc/zombine/zombine_alert6.wav", 80)
			self.RageState = true
			self.RageStateTime = CurTime() +math.Rand(6, 12)
		end
	end
end