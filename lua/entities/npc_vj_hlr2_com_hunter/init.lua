AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/hunter.mdl"
ENT.StartHealth = 210
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.BloodColor = VJ.BLOOD_COLOR_WHITE

ENT.CallForHelpDistance = 6000
ENT.AnimTbl_CallForHelp = {"hunter_respond_1", "hunter_respond_3"}

ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = {
	"meleert",
	"meleeleft",
	"melee_02",
	"melee_02",
	"melee_02",
	"melee_02",
}
ENT.MeleeAttackDamage = 20
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDistance = 70
ENT.MeleeAttackDamageDistance = 130
ENT.MeleeAttackBleedEnemy = true
ENT.MeleeAttackBleedEnemyChance = 1
ENT.MeleeAttackBleedEnemyDamage = 3
ENT.MeleeAttackPlayerSpeed = true

ENT.HasDeathAnimation = true
ENT.AnimTbl_Death = ACT_DIESIMPLE

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "MiniStrider.body_joint",
	FirstP_Offset = Vector(18, 0, -5),
}

ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true

-- ENT.SoundTbl_Breath = "npc/combine_gunship/gunship_engine_loop3.wav"
ENT.SoundTbl_FootStep = {
	"npc/ministrider/ministrider_footstep1.wav",
	"npc/ministrider/ministrider_footstep2.wav",
	"npc/ministrider/ministrider_footstep3.wav",
	"npc/ministrider/ministrider_footstep4.wav",
	"npc/ministrider/ministrider_footstep5.wav"
}
ENT.SoundTbl_Idle = {
	"npc/ministrider/hunter_idle1.wav",
	"npc/ministrider/hunter_idle2.wav",
	"npc/ministrider/hunter_idle3.wav"
}
ENT.SoundTbl_CombatIdle = {
	"npc/ministrider/hunter_angry1.wav",
	"npc/ministrider/hunter_angry2.wav",
	"npc/ministrider/hunter_angry3.wav"
}
ENT.SoundTbl_Alert = {
	"npc/ministrider/hunter_alert1.wav",
	"npc/ministrider/hunter_alert2.wav",
	"npc/ministrider/hunter_alert3.wav"
}
ENT.SoundTbl_CallForHelp = {
	"npc/ministrider/hunter_foundenemy1.wav",
	"npc/ministrider/hunter_foundenemy2.wav",
	"npc/ministrider/hunter_foundenemy3.wav"
}
ENT.SoundTbl_ReceiveOrder = {
	"npc/ministrider/hunter_foundenemy_ack1.wav",
	"npc/ministrider/hunter_foundenemy_ack2.wav",
	"npc/ministrider/hunter_foundenemy_ack3.wav"
}
ENT.SoundTbl_Investigate = {
	"npc/ministrider/hunter_scan1.wav",
	"npc/ministrider/hunter_scan2.wav",
	"npc/ministrider/hunter_scan3.wav",
	"npc/ministrider/hunter_scan4.wav"
}
ENT.SoundTbl_LostEnemy = {
	"npc/ministrider/hunter_scan1.wav",
	"npc/ministrider/hunter_scan2.wav",
	"npc/ministrider/hunter_scan3.wav",
	"npc/ministrider/hunter_scan4.wav"
}
ENT.SoundTbl_KilledEnemy = {
	"npc/ministrider/hunter_laugh1.wav",
	"npc/ministrider/hunter_laugh2.wav",
	"npc/ministrider/hunter_laugh3.wav",
	"npc/ministrider/hunter_laugh4.wav",
	"npc/ministrider/hunter_laugh5.wav"
}
ENT.SoundTbl_Pain = {
	"npc/ministrider/hunter_pain2.wav",
	"npc/ministrider/hunter_pain4.wav"
}
ENT.SoundTbl_AllyDeath = {
	"npc/ministrider/hunter_defendstrider1.wav",
	"npc/ministrider/hunter_defendstrider2.wav",
	"npc/ministrider/hunter_defendstrider3.wav"
}
ENT.SoundTbl_BeforeMeleeAttack = "npc/ministrider/hunter_prestrike1.wav"
ENT.SoundTbl_MeleeAttackExtra = "npc/ministrider/ministrider_skewer1.wav"
ENT.SoundTbl_Death = {
	"npc/ministrider/hunter_die2.wav",
	"npc/ministrider/hunter_die3.wav"
}

ENT.IdleSoundLevel = 90
ENT.AlertSoundLevel = 95
ENT.PainSoundLevel = 90
ENT.MainSoundPitch = 100

-- Custom
ENT.Flechette_Speed = 3000
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCallForHelp(ally)
	if ally:GetClass() == self:GetClass() && !ally:IsBusy("Activities") && !IsValid(ally:GetEnemy()) then
		ally:PlaySoundSystem("CallForHelp")
		ally:PlayAnim(ally.AnimTbl_CallForHelp, true, false, ally.CallForHelpAnimFaceEnemy)
		ally.NextCallForHelpAnimationT = CurTime() +ally.CallForHelpAnimCooldown
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(18, 18, 100), Vector(-18, -18, 0))
	-- self:CreateBoneFollowers()

	self.Shots = 0
	self.CurrentEye = 4

	self.DoRangeAttack = false
	self.IsPlanted = false

	self.LastSawEnemyPosition = nil

	self.NextRangeT = CurTime() +1
	self.NextShootAnimT = 0
	self.NextShootT = 0
	self.NextRandMoveT = 0

	self.ChargeAnimationCache = VJ.SequenceToActivity(self, "charge_loop")
	self.IsCharging = false
	self.ChargeT = 0

	self:SetStepHeight(28)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FireFlechette()
	if self.Shots < 12 then
		local targetPos = IsValid(self:GetEnemy()) && self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter() or self:GetPos() +self:GetForward() *400 +VectorRand(-1, 1) *math.Rand(0, 100)
		local proj = ents.Create("obj_vj_hlr2_flechette")
		proj:SetPos(self:GetAttachment(self.CurrentEye).Pos)
		proj:SetAngles((targetPos -self:GetAttachment(self.CurrentEye).Pos):Angle())
		proj:Spawn()
		proj:Activate()
		proj:SetOwner(self)
		proj:SetPhysicsAttacker(self)
		local phys = proj:GetPhysicsObject()
		if IsValid(phys) then
			local vel = self:RangeAttackProjVel(proj)
			phys:Wake()
			phys:SetVelocity(vel)
			proj:SetAngles(vel:GetVelocity():Angle())
		end

		VJ.EmitSound(self, "^npc/ministrider/ministrider_fire1.wav", 105, 100)
		ParticleEffectAttach("vj_rifle_full_blue", PATTACH_POINT_FOLLOW, self, self.CurrentEye)

		local FireLight1 = ents.Create("light_dynamic")
		FireLight1:SetKeyValue("brightness", "4")
		FireLight1:SetKeyValue("distance", "120")
		FireLight1:SetPos(self:GetAttachment(self.CurrentEye).Pos)
		FireLight1:SetLocalAngles(self:GetAngles())
		FireLight1:Fire("Color", "0 31 225")
		FireLight1:SetParent(self)
		FireLight1:Spawn()
		FireLight1:Activate()
		FireLight1:Fire("TurnOn")
		FireLight1:Fire("Kill", nil, 0.07)
		self:DeleteOnRemove(FireLight1)

		if self.CurrentEye == 4 then
			self.CurrentEye = 5
		else
			self.CurrentEye = 4
		end
		self.Shots = self.Shots +1
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	-- print(key)
	if key == "step" then
		self:PlayFootstepSound()
	elseif key == "melee" then
		self:ExecuteMeleeAttack()
	elseif key == "range" then
		self:FireFlechette()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjVel(projectile)
	local ent = self:GetEnemy()
	local targetPos
	if IsValid(ent) && ent:Visible(self) then
		targetPos = ent:GetPos() +ent:OBBCenter()
	else
		targetPos = self.EnemyData.VisiblePos or projectile:GetPos() +projectile:GetForward() *1000
	end
	targetPos = targetPos +VectorRand(-35, 35)
	return self:CalculateProjectile("Line", projectile:GetPos(), targetPos, self.Flechette_Speed)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "PreDamage" && dmginfo:IsBulletDamage() then
		dmginfo:ScaleDamage(dmginfo:GetDamageType() == DMG_BUCKSHOT && 0.5 or 0.6)
		self.DamageSpark1 = ents.Create("env_spark")
		self.DamageSpark1:SetKeyValue("Magnitude", "1")
		self.DamageSpark1:SetKeyValue("Spark Trail Length", "1")
		self.DamageSpark1:SetPos(dmginfo:GetDamagePosition())
		self.DamageSpark1:SetAngles(self:GetAngles())
		self.DamageSpark1:SetParent(self)
		self.DamageSpark1:Spawn()
		self.DamageSpark1:Activate()
		self.DamageSpark1:Fire("StartSpark", nil, 0)
		self.DamageSpark1:Fire("StopSpark", nil, 0.001)
		self:DeleteOnRemove(self.DamageSpark1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if act == ACT_IDLE then
		if self.IsPlanted then
			return ACT_RANGE_ATTACK2
		elseif self.IsCharging then
			return self.ChargeAnimationCache
		end
	elseif (act == ACT_WALK or act == ACT_RUN) then
		if self.IsCharging then
			return self.ChargeAnimationCache
		end
	end
	return act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	if self.IsCharging && !self:IsBusy() then
		if CurTime() > self.ChargeT then
			self:SetMaxYawSpeed(self.TurningSpeed)
			self.IsCharging = false
			self.ChargeT = 0
			self.DisableChasingEnemy = false
			self.HasMeleeAttack = true
			self:CapabilitiesAdd(CAP_MOVE_JUMP)
			self:SetState()
			self:PlayAnim("charge_miss_slide", true, false, false)
			return
		end

		self.DisableChasingEnemy = true
		self.HasMeleeAttack = false
		self:SetMaxYawSpeed(2)
		self:SetTurnTarget("Enemy", 0.2)
		local tr = util.TraceHull({
			start = self:GetPos() +self:OBBCenter(),
			endpos = self:GetPos() +self:OBBCenter() +self:GetForward() *100,
			filter = self,
			mins = self:OBBMins() *0.85,
			maxs = self:OBBMaxs() *0.85,
		})
		self:SetLastPosition(tr.HitPos +tr.HitNormal *200)
		self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x) x:EngTask("TASK_FACE_ENEMY", 0) x.TurnData = {Type = VJ.FACE_ENEMY} end)
		if self:OnGround() then
			self:SetVelocity(self:GetMoveVelocity() *1.01)
		end
		if tr.Hit then
			self:SetMaxYawSpeed(self.TurningSpeed)
			self.IsCharging = false
			self.ChargeT = 0
			self.HasMeleeAttack = true
			self.DisableChasingEnemy = false
			self:CapabilitiesAdd(CAP_MOVE_JUMP)
			self:SetState()
			if tr.HitWorld then
				self:PlayAnim("charge_crash", true, false, false)
				util.ScreenShake(self:GetPos(), 1000, 100, 1, 500)
			else
				self:PlayAnim("charge_miss_slide", true, false, false)
				local ent = tr.Entity
				local isProp = IsValid(ent) && VJ.IsProp(ent) or false
				if IsValid(ent) && (isProp or self:CheckRelationship(ent) == D_HT) then
					if isProp then
						local phys = ent:GetPhysicsObject()
						if IsValid(phys) then
							phys:ApplyForceCenter(self:GetForward() *1000 +self:GetUp() *200)
						end
					else
						local vel = self:GetForward() *600 +self:GetUp() *200
						ent:SetGroundEntity(NULL)
						ent:SetVelocity(vel)
					end
					local dmginfo = DamageInfo()
					dmginfo:SetDamage(20)
					dmginfo:SetDamageType(bit.bor(DMG_CRUSH, DMG_SLASH))
					dmginfo:SetDamageForce(self:GetForward() *1000)
					dmginfo:SetAttacker(self)
					dmginfo:SetInflictor(self)
					dmginfo:SetDamagePosition(tr.HitPos)
					ent:TakeDamageInfo(dmginfo)
				end
			end
			-- PrintTable(tr)
			-- VJ.DEBUG_TempEnt(tr.HitPos, self:GetAngles(), Color(255, 0, 0), 5)
		end
		return
	end

	if self.DoRangeAttack then
		if self.Shots >= 12 then
			self.NextRangeT = CurTime() +math.Rand(3, 6)
			self.DoRangeAttack = false
			self.IsPlanted = false
			self.HasMeleeAttack = true
			self:PlayAnim("vjseq_unplant", true, false, true, 0, {OnFinish=function(interrupted, anim)
				if interrupted then
					return
				end
				self:SetState()
			end})
			return
		end
		if !self.IsPlanted && !self:IsBusy() then
			self:SetState(VJ_STATE_ONLY_ANIMATION)
			self:PlayAnim("vjseq_plant", true, false, true, 0, {OnFinish=function(interrupted, anim)
				if interrupted then
					return
				end
				self.IsPlanted = true
			end})
		elseif self.IsPlanted && CurTime() > self.NextShootT then
			self:FireFlechette()
			self.NextShootT = CurTime() +0.07
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkAttack(isAttacking, enemy)
	if self.IsCharging then return end

	local eneData = self.EnemyData
	local dist = eneData.DistanceNearest
	if eneData.Visible then
		if !self.VJ_IsBeingControlled && !self:IsBusy() && CurTime() > self.NextRandMoveT && !self.DoRangeAttack && dist > 400 then
			local checkdist = self:VJ_CheckAllFourSides(400)
			local randmove = {}
			if checkdist.Backward == true then randmove[#randmove+1] = "Backward" end
			if checkdist.Right == true then randmove[#randmove+1] = "Right" end
			if checkdist.Left == true then randmove[#randmove+1] = "Left" end
			local pickmove = VJ.PICK(randmove)
			if pickmove == "Backward" then self:SetLastPosition(self:GetPos() +self:GetForward() *400) end
			if pickmove == "Right" then self:SetLastPosition(self:GetPos() +self:GetRight() *400) end
			if pickmove == "Left" then self:SetLastPosition(self:GetPos() +self:GetRight() *400) end
			if pickmove == "Backward" or pickmove == "Right" or pickmove == "Left" then
				self:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x) x:EngTask("TASK_FACE_ENEMY", 0) x.TurnData = {Type = VJ.FACE_ENEMY} end)
				self.NextRandMoveT = CurTime() +math.Rand(2, 3)
				return
			end
		end

		if dist > 500 && dist <= 2500 && !self.IsCharging && !self:IsBusy() && !self.DoRangeAttack && (self.VJ_IsBeingControlled && self.VJ_TheController:KeyDown(IN_JUMP) or !self.VJ_IsBeingControlled && math.random(1, 50) == 1) && math.abs(self:GetPos().z -enemy:GetPos().z) <= 128 then
			self:PlayAnim("charge_start", true, false, true, 0, {OnFinish=function(interrupted, anim)
				if interrupted then
					return
				end
				self:CapabilitiesRemove(CAP_MOVE_JUMP)
			end})
			self.IsCharging = true
			-- self:SetState(VJ_STATE_ONLY_ANIMATION)
			self.ChargeT = CurTime() +6
			return
		end
	end

	if self.VJ_IsBeingControlled && self.VJ_TheController:KeyDown(IN_ATTACK2) && !self.DoRangeAttack && !self.IsCharging or !self.VJ_IsBeingControlled && !self.IsCharging && CurTime() > self.NextRangeT && !self.DoRangeAttack && dist > 250 && dist <= 2200 then
		if !self:VisibleVec(eneData.VisiblePos or enemy:GetPos() + enemy:OBBCenter()) then return end
		self.Shots = 0
		self.DoRangeAttack = true
		self.HasMeleeAttack = false
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local defAng = Angle()
local angY45 = Angle(0, 45, 0)
local angYN45 = Angle(0, -45, 0)
local angY90 = Angle(0, 90, 0)
local angYN90 = Angle(0, -90, 0)
local angY135 = Angle(0, 135, 0)
local angYN135 = Angle(0, -135, 0)
local angY180 = Angle(0, 180, 0)
--
function ENT:Controller_Movement(cont, ply, bullseyePos)
	if self.MovementType != VJ_MOVETYPE_STATIONARY then
		local gerta_lef = ply:KeyDown(IN_MOVELEFT)
		local gerta_rig = ply:KeyDown(IN_MOVERIGHT)
		local gerta_arak = ply:KeyDown(IN_SPEED)
		local aimVector = ply:GetAimVector()
		local FT = FrameTime() *(self.TurningSpeed *1.25)

		self.ControllerParams.TurnAngle = self.ControllerParams.TurnAngle or defAng

		if self.IsCharging then
			return
		end

		if ply:KeyDown(IN_FORWARD) then
			if self.MovementType == VJ_MOVETYPE_AERIAL or self.MovementType == VJ_MOVETYPE_AQUATIC then
				self:AA_MoveTo(cont.VJCE_Bullseye, true, gerta_arak and "Alert" or "Calm", {IgnoreGround = true})
			else
				-- if gerta_lef then
				-- 	cont:StartMovement(aimVector, angY45)
				-- elseif gerta_rig then
				-- 	cont:StartMovement(aimVector, angYN45)
				-- else
				-- 	cont:StartMovement(aimVector, defAng)
				-- end
				self.ControllerParams.TurnAngle = LerpAngle(FT, self.ControllerParams.TurnAngle, gerta_lef && angY45 or gerta_rig && angYN45 or defAng)
				cont:StartMovement(aimVector, self.ControllerParams.TurnAngle)
			end
		elseif ply:KeyDown(IN_BACK) then
			-- if gerta_lef then
			-- 	cont:StartMovement(aimVector*-1, angYN45)
			-- elseif gerta_rig then
			-- 	cont:StartMovement(aimVector*-1, angY45)
			-- else
			-- 	cont:StartMovement(aimVector*-1, defAng)
			-- end
			self.ControllerParams.TurnAngle = LerpAngle(FT, self.ControllerParams.TurnAngle, gerta_lef && angY135 or gerta_rig && angYN135 or angY180)
			cont:StartMovement(aimVector, self.ControllerParams.TurnAngle)
		elseif gerta_lef then
			-- cont:StartMovement(aimVector, angY90)
			self.ControllerParams.TurnAngle = LerpAngle(FT, self.ControllerParams.TurnAngle, angY90)
			cont:StartMovement(aimVector, self.ControllerParams.TurnAngle)
		elseif gerta_rig then
			-- cont:StartMovement(aimVector, angYN90)
			self.ControllerParams.TurnAngle = LerpAngle(FT, self.ControllerParams.TurnAngle, angYN90)
			cont:StartMovement(aimVector, self.ControllerParams.TurnAngle)
		else
			self:StopMoving()
			if self.MovementType == VJ_MOVETYPE_AERIAL or self.MovementType == VJ_MOVETYPE_AQUATIC then
				self:AA_StopMoving()
			end
		end
	end
end