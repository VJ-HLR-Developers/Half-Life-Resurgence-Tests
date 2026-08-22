AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/zombie_poison.mdl"
ENT.StartHealth = 175
ENT.HullType = HULL_HUMAN

ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}

ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.BloodParticle = "blood_impact_green_01"

ENT.MeleeAttackDamage = 18
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 35
ENT.MeleeAttackDamageDistance = 75
ENT.TimeUntilMeleeAttackDamage = false

ENT.CanFlinch = true
ENT.AnimTbl_Flinch = ACT_SMALL_FLINCH

ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true
ENT.MainSoundPitch = 100

ENT.SoundTbl_FootStep = {"npc/zombie_poison/pz_left_foot1.wav", "npc/zombie_poison/pz_right_foot1.wav"}
ENT.SoundTbl_Idle = {"npc/zombie_poison/pz_idle2.wav", "npc/zombie_poison/pz_idle3.wav", "npc/zombie_poison/pz_idle4.wav"}
ENT.SoundTbl_DefBreath = {"npc/zombie_poison/pz_breathe_loop1.wav", "npc/zombie_poison/pz_breathe_loop2.wav"}
ENT.SoundTbl_Alert = {"npc/zombie_poison/pz_alert1.wav", "npc/zombie_poison/pz_alert2.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"npc/zombie_poison/pz_warn1.wav", "npc/zombie_poison/pz_warn2.wav"}
ENT.SoundTbl_Pain = {"npc/zombie_poison/pz_pain1.wav", "npc/zombie_poison/pz_pain2.wav", "npc/zombie_poison/pz_pain3.wav"}
ENT.SoundTbl_DeathFollow = {"npc/zombie_poison/pz_die1.wav", "npc/zombie_poison/pz_die2.wav"}
ENT.SoundTbl_Warn = {"npc/zombie_poison/pz_warn1.wav", "npc/zombie_poison/pz_warn2.wav"}
ENT.SoundTbl_Throw = {"npc/zombie_poison/pz_throw2.wav", "npc/zombie_poison/pz_throw3.wav"}
ENT.SoundTbl_MeleeAttackExtra = {"npc/zombie/claw_strike1.wav", "npc/zombie/claw_strike2.wav", "npc/zombie/claw_strike3.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"npc/zombie/claw_miss1.wav", "npc/zombie/claw_miss2.wav"}

ENT.HeadcrabClass = "npc_vj_hlr2_headcrab_poison"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetSlump(doSlump)
	if doSlump then
		self:SetState(VJ_STATE_ONLY_ANIMATION_NOATTACK)
		self.SlumpAnimation = VJ.SequenceToActivity(self, "slump_a")
		self:SetMaxLookDistance(150)
		self.SightAngle = 360
		self:AddFlags(FL_NOTARGET)
	else
		self:PlayAnim("slumprise_a", true, false, false, 0, {OnFinish=function(interrupted, anim)
			self:SetState()
		end})
		self:SetMaxLookDistance(10000)
		self.SightAngle = 156
		self:RemoveFlags(FL_NOTARGET)
		self.SoundTbl_Breath = self.SoundTbl_DefBreath
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
	local zType = self.ZombieType or math.random(1, 8)
	self.SlumpAnimation = ACT_IDLE

	if self.OnInit then
		self:OnInit()
	end

	if self.Slump then
		self:SetSlump(true)
	else
		self.SoundTbl_Breath = self.SoundTbl_DefBreath
	end

	if self.ZombieType != 69 then
		if zType != 4 then -- 4 skin is normal poison zombie
			local hp = self.StartHealth *((zType == 1 && zType == 3) && 1.2 or (zType >= 5 && zType <= 7) && 1.5 or zType == 8 && 2 or 1)
			self:SetHealth(hp)
			self:SetMaxHealth(hp)
			if (zType == 1 && zType == 3) or (zType >= 5 && zType <= 7) then
				self.DeathLoot = "weapon_frag"
				self.DeathLootChance = 12
			elseif zType == 8 then
				self.DeathLoot = "item_ammo_ar2_altfire"
				self.DeathLootChance = 6
			end
			if zType == 3 then
				self.SoundTbl_FootStepAdd = {"vj_hlr/src/npc/zolice/gear1.wav", "vj_hlr/src/npc/zolice/gear2.wav", "vj_hlr/src/npc/zolice/gear3.wav"}
			elseif zType >= 5 && zType <= 8 then
				self.SoundTbl_FootStepAdd = {"vj_hlr/src/npc/zombine/gear1.wav", "vj_hlr/src/npc/zombine/gear2.wav", "vj_hlr/src/npc/zombine/gear3.wav"}
			end
		end
		self:SetSkin(zType)
	end

	self:SetBodygroup(1, 1)
	self:SetBodygroup(2, 1)
	self:SetBodygroup(3, 1)
	self:SetBodygroup(4, 1)

	self.Headcrabs = 3
	self.ReleasedHeadcrabs = {}
	self.NextThrowT = CurTime() +math.Rand(1, 3)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ThrowHeadcrab(pos)
	local current = self.Headcrabs
	if current == 0 then return end
	self:SetBodygroup(1 +current, 0)
	self.Headcrabs = current -1

	sound.EmitHint(SOUND_DANGER, pos, 250, 1, self)

	local att = self:GetAttachment(self:LookupAttachment("headcrab" .. 1 +current))
	local p = ents.Create(self.HeadcrabClass)
	p:SetPos(att.Pos)
	p:SetAngles(Angle(0, (pos -p:GetPos()):Angle().y, 0))
	p.VJ_NPC_Class = self.VJ_NPC_Class
	p:SetOwner(self)
	p:Spawn()
	p:SetOwner(self)
	VJ.CreateSound(p, p.SoundTbl_LeapAttackJump, 75)
	p.CanAlertCrab = false
	p.WasThrown = true
	p:SetEnemy(self:GetEnemy())
	-- p:SetTurnTarget("Enemy")
	p:SetGroundEntity(NULL)
	p:SetLocalVelocity(p:CalculateProjectile("Curve", p:GetPos(), pos, 850))
	p:SetState(VJ_STATE_ONLY_ANIMATION_NOATTACK)
	table.insert(self.ReleasedHeadcrabs, p)

	-- local ply = self:GetCreator()
	-- if IsValid(ply) then -- Kind of silly, as you can remove them as they are thrown. Leaving for future use if wanted
	-- 	undo.Create(self:GetName() .. "'s " .. p:GetName())
	-- 		undo.AddEntity(p)
	-- 		undo.SetPlayer(ply)
	-- 	undo.Finish()
	-- end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "step" then
		VJ.EmitSound(self, self.SoundTbl_FootStep, self.FootstepSoundLevel)
		if self.SoundTbl_FootStepAdd then
			VJ.EmitSound(self, self.SoundTbl_FootStepAdd, self.FootstepSoundLevel)
		end
	elseif key == "melee" then
		self:ExecuteMeleeAttack()
		if self.IsBeta then
			VJ.EmitSound(self, "vj_hlr/gsrc/npc/bullchicken/bc_spithit3.wav")

			local pos, ang = self:GetBonePosition(53)
			ParticleEffect("vj_acid_impact2", pos, ang, nil)
		end
	elseif key == "throw" then
		local ent = self:GetEnemy()
		self:ThrowHeadcrab(IsValid(ent) && ent:GetPos() +ent:OBBCenter() or self:GetPos() +self:GetForward() *400 +self:OBBCenter())
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkAttack(isAttacking, enemy)
	local eneData = self.EnemyData
	local dist = eneData.DistanceNearest
	local headcrabs = self.Headcrabs

	if headcrabs > 0 && ((self.VJ_IsBeingControlled && self.VJ_TheController:KeyDown(IN_ATTACK2)) or (!self.VJ_IsBeingControlled && dist <= 700 && dist > 250 && math.random(1, 50) == 1 && eneData.Visible && CurTime() > self.NextThrowT && !self:IsBusy())) then
		if dist <= 350 then
			self:PlayAnim("headcrab2Leap", true, false, true)
		else
			VJ.CreateSound(self, self.SoundTbl_Warn, 80)
			self:PlayAnim("ThrowWarning", true, false, true, 0, {OnFinish=function(interrupted, anim)
				if interrupted then
					return
				end
				self:PlayAnim("Throw", true, false, true)
				VJ.CreateSound(self, self.SoundTbl_Throw, 80)
			end})
		end
		sound.EmitHint(SOUND_DANGER, enemy:GetPos(), 250, 1, self)
		self.NextThrowT = CurTime() + math.random(8, 12)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	if self.IsSlumped then
		self.IdleSoundBlockTime = CurTime() +math.random(4, 8)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnBleed(dmginfo, hitgroup)
	if self.IsSlumped then
		self:SetSlump(false)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCreateDeathCorpse(dmginfo, hitgroup, ent)
	if self:GetBodygroup(1) == 0 then
		return false
	end

	VJ.CreateSound(ent, self.SoundTbl_DeathFollow, self.DeathSoundLevel)
	for i = 1, self.Headcrabs do
		local crab = ents.Create(self.HeadcrabClass or "npc_vj_hlr2_headcrab_poison")
		crab:SetPos(self:GetAttachment(self:LookupAttachment("headcrab" .. i)).Pos or self:EyePos())
		crab:SetAngles(self:GetAngles() +Angle(0, math.random(0, 360), 0))
		crab.VJ_NPC_Class = self.VJ_NPC_Class
		crab:Spawn()
		crab:SetGroundEntity(NULL) -- This fixes that issue where they snap to the ground when spawned
		crab:SetLocalVelocity(self:GetVelocity() *dmginfo:GetDamageForce():Length())
		if ent:IsOnFire() then
			crab:Ignite(math.random(8, 10))
		end
		ent:SetBodygroup(1 +i, 0)
		crab.EntitiesToNoCollide = {crab:GetClass()}
	end
	local dmgtype = dmginfo:GetDamageType()
	if hitgroup == HITGROUP_HEAD then
		ent:SetBodygroup(1, 0)
		local mdl = self.HeadcrabClass == "npc_vj_hlr2b_headcrab_poison" && "models/vj_hlr/hl2b/headcrab_poison.mdl" or "models/headcrabblack.mdl"
		self:CreateExtraDeathCorpse(
			"prop_ragdoll",
			mdl,
			{Pos = self:GetAttachment(self:LookupAttachment("headcrab1")).Pos or self:EyePos()})
	else
		if math.random(1, (dmgtype == DMG_CLUB or dmgtype == DMG_SLASH or DMG_BLAST) && 1 or 3) == 1 then
			ent:SetBodygroup(1, 0)
			local crab = ents.Create(self.HeadcrabClass or "npc_vj_hlr2_headcrab_poison")
			crab:SetPos(self:GetAttachment(self:LookupAttachment("headcrab1")).Pos or self:EyePos())
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
function ENT:TranslateActivity(act)
	if act == ACT_IDLE then
		if self.IsSlumped then
			return self.SlumpAnimation
		end
	elseif (act == ACT_RUN or act == ACT_WALK) && self:IsOnFire() then
		return ACT_WALK_ON_FIRE
	end
	return act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	if !self.Dead then
		for _, v in pairs(self.ReleasedHeadcrabs) do
			if IsValid(v) then
				v:Remove()
			end
		end
	end
end