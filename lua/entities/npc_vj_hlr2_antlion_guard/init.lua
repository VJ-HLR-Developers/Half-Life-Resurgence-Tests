AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/antlion_guard.mdl"
ENT.StartHealth = 500
ENT.HullType = HULL_LARGE
ENT.VJ_ID_Boss = true

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "Antlion_Guard.head",
	FirstP_Offset = Vector(5, 0, 3),
}

ENT.VJ_NPC_Class = {"CLASS_ANTLION"}
ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW
ENT.BloodParticle = "blood_impact_yellow_01"

ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 70
ENT.MeleeAttackDamageDistance = 150
ENT.MeleeAttackDamage = 25
ENT.MeleeAttackDamageType = bit.bor(DMG_SLASH, DMG_CRUSH)
ENT.HasMeleeAttackKnockBack = true

ENT.FootstepSoundTimerRun = 0.21
ENT.FootstepSoundTimerWalk = 0.3
ENT.HasExtraMeleeAttackSounds = true
ENT.MainSoundPitch = 100

-- ENT.SoundTbl_Breath = "npc/antlion_guard/growl_idle.wav"
ENT.SoundTbl_FootStep = {"npc/antlion_guard/foot_heavy1.wav", "npc/antlion_guard/foot_heavy2.wav", "npc/antlion_guard/foot_light1.wav", "npc/antlion_guard/foot_light2.wav"}
ENT.SoundTbl_Death = {"npc/antlion_guard/antlion_guard_die1.wav", "npc/antlion_guard/antlion_guard_die2.wav"}
ENT.SoundTbl_BeforeMeleeAttack = "npc/antlion_guard/angry1.wav"
ENT.SoundTbl_MeleeAttackExtra = "npc/antlion_guard/shove1.wav"

ENT.BreathSoundLevel = 70

ENT.IsGuardian = false
ENT.ChargePercentage = 0.65
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Controller_Initialize(ply, controlEnt)
	ply:ChatPrint("MOUSE2: Charge Attack")
	ply:ChatPrint("RELOAD: Summon Antlions")
	-- ply:ChatPrint("RELOAD: Summon Antlions (Only works on weak surfaces [Grass, Snow, Sand, etc])")
end
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.Guard_AnimationCache = {}
ENT.Guard_Antlions = {}
--
function ENT:Init()
	self:SetCollisionBounds(Vector(40, 40, 80), Vector(-40, -40, 0))
	self.IsDiging = false
	self.ChargeAnim = VJ.SequenceToActivity(self, "charge_loop")
	self.Breath = CreateSound(self, "npc/antlion_guard/growl_idle.wav")
	self.Breath:PlayEx(0.65, 100)
	self.ChargeBreath = CreateSound(self, "npc/antlion_guard/growl_high.wav")
	self.ChargeBreath:PlayEx(0, 0)

	self.NextSummonT = CurTime() +6
	self.NextChargeT = CurTime() +5
	self.StopChargingT = CurTime()
	self.Charging = false
	self.BreathPitch = 100

	if !self.Guard_AnimationCache["charge_loop"] then
		self.Guard_AnimationCache["charge_loop"] = self:GetSequenceActivity(self:LookupSequence("charge_loop"))
	end

	if self.IsGuardian then
		self:SetSkin(1)
		self.MeleeAttackDamage = 110
		self.MeleeAttackDamageType = bit.bor(DMG_SLASH, DMG_POISON, DMG_CRUSH)
		self.Immune_Toxic = true
	end
	if self:IsDirt(self:GetPos()) then
		self.IsDiging = true
		self:SetNoDraw(true)
		timer.Simple(0.000001, function()
			self:PlayAnim("floor_break", true, VJ.AnimDuration(self, "floor_break"), false)
			self.HasMeleeAttack = false
			timer.Simple(0.5, function()
				if IsValid(self) then
					self:SetNoDraw(false)
					self:EmitSound("physics/concrete/concrete_break2.wav", 110, 100)
					ParticleEffect("advisor_plat_break", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("strider_impale_ground", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("advisor_plat_break", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("strider_impale_ground", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					if self.IsGuardian then self:CreateEffects() end
				end
			end)
			timer.Simple(0.7, function()
				if IsValid(self) then
					self:EmitSound("physics/concrete/concrete_break2.wav", 110, 100)
					ParticleEffect("advisor_plat_break", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("strider_impale_ground", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("advisor_plat_break", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("strider_impale_ground", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
				end
			end)
			timer.Simple(1.4, function()
				if IsValid(self) then
					self:EmitSound("physics/concrete/concrete_break2.wav", 110, 100)
					ParticleEffect("advisor_plat_break", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("strider_impale_ground", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("advisor_plat_break", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("strider_impale_ground", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
				end
			end)
			timer.Simple(2, function()
				if IsValid(self) then
					self:EmitSound("physics/concrete/concrete_break2.wav", 110, 100)
					ParticleEffect("advisor_plat_break", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("strider_impale_ground", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("advisor_plat_break", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("strider_impale_ground", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
				end
			end)
			timer.Simple(2.5, function()
				if IsValid(self) then
					self:EmitSound("physics/concrete/concrete_break2.wav", 110, 100)
					ParticleEffect("advisor_plat_break", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("strider_impale_ground", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("advisor_plat_break", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
					ParticleEffect("strider_impale_ground", self:GetPos() +VectorRand() *50, self:GetAngles(), nil)
				end
			end)
			timer.Simple(VJ.AnimDuration(self, "floor_break"), function()
				if IsValid(self) then
					self.IsDiging = false
					self.HasMeleeAttack = true
				end
			end)
		end)
	else
		if self.IsGuardian then self:CreateEffects() end
	end
	//charge_cancel, charge_crash, charge_loop, charge_stop, floor_break, flinch1, flinch2, pain
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateEffects()
	local glow1 = ents.Create("env_sprite")
	glow1:SetKeyValue("model", "vj_base/sprites/glow.vmt")
	glow1:SetKeyValue("scale", "1")
	glow1:SetKeyValue("rendermode", "5")
	glow1:SetKeyValue("rendercolor", "127 225 0")
	glow1:SetKeyValue("spawnflags", "1")
	glow1:SetParent(self)
	glow1:Fire("SetParentAttachment", "attach_glow1", 0)
	glow1:Spawn()
	glow1:Activate()
	self:DeleteOnRemove(glow1)
	local glow2 = ents.Create("env_sprite")
	glow2:SetKeyValue("model", "vj_base/sprites/glow.vmt")
	glow2:SetKeyValue("scale", "0.4")
	glow2:SetKeyValue("rendermode", "5")
	glow2:SetKeyValue("rendercolor", "127 225 0")
	glow2:SetKeyValue("spawnflags", "1")
	glow2:SetParent(self)
	glow2:Fire("SetParentAttachment", "attach_glow2", 0)
	glow2:Spawn()
	glow2:Activate()
	self:DeleteOnRemove(glow2)
	local glow3 = ents.Create("env_sprite")
	glow3:SetKeyValue("model", "vj_base/sprites/glow.vmt")
	glow3:SetKeyValue("scale", "0.4")
	glow3:SetKeyValue("rendermode", "5")
	glow3:SetKeyValue("rendercolor", "127 225 0")
	glow3:SetKeyValue("spawnflags", "1")
	glow3:SetParent(self)
	glow3:Fire("SetParentAttachment", "0", 0)
	glow3:Spawn()
	glow3:Activate()
	self:DeleteOnRemove(glow3)
	local glow4 = ents.Create("env_sprite")
	glow4:SetKeyValue("model", "vj_base/sprites/glow.vmt")
	glow4:SetKeyValue("scale", "0.4")
	glow4:SetKeyValue("rendermode", "5")
	glow4:SetKeyValue("rendercolor", "127 225 0")
	glow4:SetKeyValue("spawnflags", "1")
	glow4:SetParent(self)
	glow4:Fire("SetParentAttachment", "1", 0)
	glow4:Spawn()
	glow4:Activate()
	self:DeleteOnRemove(glow4)
	local glowlight = ents.Create("light_dynamic")
	glowlight:SetKeyValue("_light", "127 225 0 200")
	glowlight:SetKeyValue("brightness", "1")
	glowlight:SetKeyValue("distance", "300")
	glowlight:SetKeyValue("style", "0")
	glowlight:SetPos(self:GetPos())
	glowlight:SetParent(self)
	glowlight:Spawn()
	glowlight:Activate()
	glowlight:Fire("SetParentAttachment", "attach_glow2")
	glowlight:Fire("TurnOn", "", 0)
	glowlight:DeleteOnRemove(self)
	local glowlight_top = ents.Create("light_dynamic")
	glowlight_top:SetKeyValue("_light", "127 225 0 200")
	glowlight_top:SetKeyValue("brightness", "2")
	glowlight_top:SetKeyValue("distance", "300")
	glowlight_top:SetKeyValue("style", "0")
	glowlight_top:SetPos(self:GetPos())
	glowlight_top:SetParent(self)
	glowlight_top:Spawn()
	glowlight_top:Activate()
	glowlight_top:Fire("SetParentAttachment", "attach_glow1")
	glowlight_top:Fire("TurnOn", "", 0)
	glowlight_top:DeleteOnRemove(self)
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
function ENT:FindNodesNearPoint(checkPos, total, dist, minDist)
	local nodegraph = table.Copy(VJ_Nodegraph.Data.Nodes)
	local closestNode = NULL
	local closestDist = 999999
	local minDist = minDist or 0
	for _, v in pairs(nodegraph) do
		local dist = v.pos:Distance(checkPos)
		if dist < closestDist && dist > minDist then
			closestNode = v
			closestDist = dist
		end
	end
	local savedPoints = {}
	for _, v in pairs(nodegraph) do
		if v.pos:Distance(closestNode.pos) <= (dist or 1024) then
			table.insert(savedPoints, v.pos)
		end
	end
	return #savedPoints > 0 && savedPoints or false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SummonAllies(anim)
	if self:IsBusy("Activities") or self.Charging then return end
	local anim = anim or "bark"
	self:PlayAnim(anim, true, false, false)
	timer.Simple(0.5, function()
		if IsValid(self) then
			VJ.CreateSound(self, "npc/antlion_guard/angry2.wav", 95, 100)
			for i = 1, math.random(4, self.IsGuardian && 10 or 6) do
				local pos = self:FindNodesNearPoint(self:GetPos(), 16, 1024, 256)
				self:CreateAntlion(VJ.PICK(pos) or self:GetPos() +self:GetRight() *math.Rand(-512, 512) +self:GetForward() *math.Rand(-512, 512))
			end
		end
	end)
	if anim == "bark" then
		timer.Simple(1, function()
			if IsValid(self) then
				VJ.CreateSound(self, "npc/antlion_guard/angry3.wav", 95, 100)
			end
		end)
		timer.Simple(1.65, function()
			if IsValid(self) then
				self:EmitSound("npc/antlion_guard/angry2.wav", 95, 100)
			end
		end)
	else
		timer.Simple(1.4, function()
			if IsValid(self) then
				VJ.CreateSound(self, "npc/antlion_guard/angry1.wav", 95, 100)
			end
		end)
	end
	self.NextSummonT = CurTime() +math.Rand(25, 45)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if self:IsBusy("Activities") or self.Charging then return end
	self.NextChargeT = CurTime() +5
	if math.random(1, 3) == 1 && CurTime() > self.NextSummonT then
		self:SummonAllies(VJ.PICK({"bark", "roar"}))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CreateAntlion(pos)
	-- print(pos)
	local class = "npc_vj_hlr2_antlion"
	if math.random(1, 3) == 1 then
		class = "npc_vj_hlr2_antlion_worker"
	end
	local antlion = ents.Create(class)
	antlion:SetPos(pos +Vector(0, 0, 10))
	antlion:SetAngles(self:GetAngles())
	antlion:Spawn()
	antlion:Activate()
	antlion.VJ_NPC_Class = self.VJ_NPC_Class
	antlion:Dig(true)
	table.insert(self.Guard_Antlions, antlion)
	ParticleEffect("advisor_plat_break", antlion:GetPos(), antlion:GetAngles(), antlion)
	ParticleEffect("strider_impale_ground", antlion:GetPos(), antlion:GetAngles(), antlion)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MeleeAttackKnockbackVelocity(ent)
	return self:GetForward() *math.random(400, 500) +self:GetUp() *300
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "PreDamage" && dmginfo:IsBulletDamage() then
		dmginfo:ScaleDamage(math.Rand(0.5, 0.75))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkAttack(isAttacking, enemy)
	local eneData = self.EnemyData
	local dist = eneData.DistanceNearest
	if self.IsCharging then
		if CurTime() > self.ChargeT then
			self:SetMaxYawSpeed(self.TurningSpeed)
			self.IsCharging = false
			self.ChargeT = 0
			self.DisableChasingEnemy = false
			self.HasMeleeAttack = true
			self:CapabilitiesAdd(CAP_MOVE_JUMP)
			self:PlayAnim("charge_stop", true, false, false)
			self.ChargeBreath:Stop()
			return
		end

		self.DisableChasingEnemy = true
		self.HasMeleeAttack = false
		self:SetMaxYawSpeed(2)
		self:SetTurnTarget(enemy, -1)
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
		-- VJ.DEBUG_TempEnt(self:GetLastPosition(), self:GetAngles(), Color(255, 0, 0), 5)
		if tr.Hit then
			self:SetMaxYawSpeed(self.TurningSpeed)
			self.IsCharging = false
			self.ChargeT = 0
			self.HasMeleeAttack = true
			self.DisableChasingEnemy = false
			self:CapabilitiesAdd(CAP_MOVE_JUMP)
			self:SetState()
			self.ChargeBreath:Stop()
			if tr.HitWorld then
				self:PlayAnim({"charge_crash", "charge_crash02", "charge_crash03"}, true, false, false)
				util.ScreenShake(self:GetPos(), 1000, 100, 1, 500)
				VJ.CreateSound(self, "npc/antlion_guard/shove1.wav", 75)
			else
				self:PlayAnim("charge_stop", true, false, false)
				local gest = self:AddGestureSequence(self:LookupSequence("charge_hit"))
				self:SetLayerPriority(gest, 1)
				self:SetLayerPlaybackRate(gest, 0.5)
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
					dmginfo:SetDamage(50)
					dmginfo:SetDamageType(bit.bor(DMG_SLASH, DMG_CRUSH))
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

	local controlled = self.VJ_IsBeingControlled
	local ply = self.VJ_TheController
	if (controlled && ply:KeyDown(IN_ATTACK2) or !controlled && eneData.Visible && dist > 500 && dist <= 2500 && !self:IsBusy() && math.random(1, 50) == 1 && math.abs(self:GetPos().z -enemy:GetPos().z) <= 128) && !self.IsCharging then
		self.IsCharging = true
		self.ChargeT = CurTime() +6
		VJ.CreateSound(self, {"npc/antlion_guard/angry1.wav", "npc/antlion_guard/angry2.wav", "npc/antlion_guard/angry3.wav"}, 72)
		self.ChargeBreath:Play()
		self.ChargeBreath:ChangeVolume(1, 1)
		self:PlayAnim("charge_startfast", true, false, true, 0, {OnFinish=function(interrupted, anim)
			if interrupted then
				return
			end
			self:CapabilitiesRemove(CAP_MOVE_JUMP)
		end})
		return
	end

	if ((controlled && ply:KeyDown(IN_RELOAD)) or !controlled && math.random(1, 75) == 1) && CurTime() > self.NextSummonT then
		self:SummonAllies()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	local hasEnemy = IsValid(self:GetEnemy())

	self.BreathPitch = Lerp(FrameTime() *10, self.BreathPitch, hasEnemy && 110 or 90)
	self.Breath:ChangeVolume(hasEnemy && 1 or 0.65, 1)
	self.Breath:ChangePitch(self.BreathPitch)
	self.ChargeBreath:ChangePitch(self.BreathPitch)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if act == ACT_IDLE then
		if self.IsCharging then
			return self.Guard_AnimationCache["charge_loop"]
		end
	elseif (act == ACT_WALK or act == ACT_RUN) then
		if self.IsCharging then
			return self.Guard_AnimationCache["charge_loop"]
		end
	end
	return act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	self.Breath:Stop()
	self.ChargeBreath:Stop()
	if !self.Dead then
		for _, v in ipairs(self.Guard_Antlions) do
			if IsValid(v) then v:Remove() end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local defAng = Angle()
local angY45 = Angle(0, 45, 0)
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