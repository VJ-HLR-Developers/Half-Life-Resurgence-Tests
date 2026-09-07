AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/Combine_dropship.mdl"
ENT.StartHealth = 500
ENT.VJ_ID_Boss = true
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}

ENT.BloodColor = VJ.BLOOD_COLOR_WHITE
ENT.Immune_Bullet = true

ENT.DisableWandering = true
ENT.DisableChasingEnemy = true
ENT.IdleAlwaysWander = true

ENT.ConstantlyFaceEnemy = false

ENT.SoundTbl_Idle =
	"npc/combine_gunship/gunship_moan.wav"

ENT.SoundTbl_Pain =
	"npc/combine_gunship/ping_patrol.wav"


ENT.IdleSoundLevel = 120
ENT.PainSoundLevel = 120

local DROPSHIP_ACCEL_RATE = 300
local DROPSHIP_LANDING_HOVER_TIME = 5 // Time to spend on the ground if we have no troops to drop
local DROPSHIP_DEFAULT_SOLDIERS = 4
local DROPSHIP_MAX_SOLDIERS = 6
local DROPSHIP_MAX_SPEED = 60 *17.6
local DROPSHIP_LEAD_DISTANCE = 800
local DROPSHIP_MIN_CHASE_DIST_DIFF = 128
local DROPSHIP_AVOID_DIST = 256
local DROPSHIP_ARRIVE_DIST = 128
local DROPSHIP_BBOX_CRATE_MIN, DROPSHIP_BBOX_CRATE_MAX = -Vector(60, 60, 60), Vector(60, 60, 130)
local DROPSHIP_BBOX_MIN, DROPSHIP_BBOX_MAX = -Vector(60, 60, -60), Vector(60, 60, 140)
local DROPSHIP_CRATE_ROCKET_HITS = 4
local CRATE_TYPES = {
	CRATE_APC = -2,
	CRATE_STRIDER = -1,
	CRATE_NONE,
	CRATE_SOLDIER,
}
local LandingState = {
	LANDING_NO = 0,
	LANDING_LEVEL_OUT, // Heading to a point above the dropoff point
	LANDING_DESCEND, // Descending from to the dropoff point
	LANDING_TOUCHDOWN,
	LANDING_UNLOADING,
	LANDING_UNLOADED,
	LANDING_LIFTOFF,
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self.AnimTbl = {
		Idle = VJ.SequenceToActivity(self, "idle"),
		Cargo = VJ.SequenceToActivity(self, "cargo_idle"),
		Hover = VJ.SequenceToActivity(self, "cargo_hover"),
	}
	self:SetCollisionBounds(DROPSHIP_BBOX_MAX, DROPSHIP_BBOX_MIN)
	self:SetDropshipState(LandingState.LANDING_NO)
	self:CreateBoneFollowers()
	self:SetGroundEntity(NULL)
	self:AddFlags(FL_FLY)
	self:SetNavType(NAV_FLY)
	self:SetMoveType(MOVETYPE_STEP)
	self:CapabilitiesAdd(CAP_MOVE_FLY)
	timer.Simple(0, function()
		if IsValid(self) then
			self:SetPos(self:GetPos() +self:GetUp() *200)
			self:EquipCargo(CRATE_TYPES.CRATE_SOLDIER)
		end
	end)

	self:SetDesiredPosition(self:GetPos() +self:GetUp() *512 +self:GetForward() *512)
	self:SetMaxYawSpeed(2)

	self.CargoType = CRATE_TYPES.CRATE_NONE
	self.HasDroppedOffCargo = false
	self.IsGoingToDropOffCargo = false
	self.CargoDropOffPoint = nil
	self.PossibleDropOffPoint = nil
	self.NextWanderPointT = CurTime() +math.Rand(6, 12)
	self.NextFireT = 0
	self.NextFindDropOffT = 0

	self.FireLoop = CreateSound(self, "npc/combine_gunship/gunship_fire_loop1.wav")
	self.FireLoop:SetSoundLevel(120)
	self.FireLoop:ChangeVolume(1)

	self.EngineLoop = CreateSound(self, "npc/combine_gunship/dropship_engine_near_loop1.wav")
	self.EngineLoop:SetSoundLevel(120)
	self.EngineLoop:ChangeVolume(1)
	self.EngineLoop:Play()

	self.EngineLoopB = CreateSound(self, "npc/combine_gunship/dropship_onground_loop1.wav")
	self.EngineLoopB:SetSoundLevel(120)
	self.EngineLoopB:ChangeVolume(1)

	self.CargoLoop = CreateSound(self, "npc/combine_gunship/dropship_dropping_pod_loop1.wav")
	self.CargoLoop:SetSoundLevel(120)
	self.CargoLoop:ChangeVolume(1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BarrageFire(cargo)
	local i = 0
	timer.Create("vj_timer_fire_" .. self:EntIndex(), 0.1, 16, function()
		if IsValid(self:GetEnemy()) && !self.Dead then
			i = i +1
			local att = cargo:GetAttachment(3)
			sound.EmitHint(SOUND_DANGER, self:GetEnemy():GetPos(), 250, 0.25, self)
			local bullet = {}
			bullet.Num = 1
			bullet.Src = att.Pos
			bullet.Dir = (self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter() -att.Pos):Angle():Forward()
			bullet.Callback = function(attacker, tr, dmginfo)
				local laserhit = EffectData()
				laserhit:SetOrigin(tr.HitPos)
				laserhit:SetNormal(tr.HitNormal)
				laserhit:SetScale(25)
				util.Effect("AR2Impact", laserhit)
				dmginfo:SetDamageType(bit.bor(2, 4098, 2147483648))
			end
			bullet.Spread = Vector(0.02, 0.02, 0)
			bullet.Tracer = 1
			bullet.TracerName = "AirboatGunTracer"
			bullet.Force = 3
			bullet.Damage = self:ScaleByDifficulty(9)
			bullet.AmmoType = "AR2"
			self:FireBullets(bullet)

			ParticleEffectAttach("vj_muzzle_ar2_main", PATTACH_POINT_FOLLOW, cargo, 3)
			local FireLight1 = ents.Create("light_dynamic")
			FireLight1:SetKeyValue("brightness", 8)
			FireLight1:SetKeyValue("distance", 300)
			FireLight1:SetLocalPos(cargo:GetAttachment(3).Pos)
			FireLight1:SetLocalAngles(self:GetAngles())
			FireLight1:Fire("Color", "0 161 255 255")
			FireLight1:Spawn()
			FireLight1:Activate()
			FireLight1:Fire("TurnOn")
			FireLight1:Fire("Kill", nil, 0.07)
			self:DeleteOnRemove(FireLight1)
			if i == 16 then
				VJ.CreateSound(self, "npc/combine_gunship/attack_stop2.wav", 100)
			end
		else
			timer.Remove("vj_timer_fire_" .. self:EntIndex())
			self.NextFireT = CurTime() +1
			VJ.CreateSound(self, "npc/combine_gunship/attack_stop2.wav", 100)
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkAttack(isAttacking, enemy)
	local cargo = self.Cargo
	if IsValid(cargo) && self.CargoType == CRATE_TYPES.CRATE_SOLDIER then
		if IsValid(self:GetEnemy()) then
			local dist = self.EnemyData.DistanceNearest
			if dist <= 4000 && self:Visible(self:GetEnemy()) then
				if CurTime() > self.NextFireT then
					self:BarrageFire(cargo)
					VJ.CreateSound(self, "npc/combine_gunship/attack_start2.wav", 100)
					self.NextFireT = CurTime() +8
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetDropshipState(state)
	self._State = state
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetDropshipState()
	return self._State
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:EquipCargo(cargoType, count)
	self:SetCollisionBounds(DROPSHIP_BBOX_MAX, DROPSHIP_BBOX_MIN)
	self.CargoType = cargoType
	if cargoType == CRATE_TYPES.CRATE_SOLDIER then
		self:SetCollisionBounds(DROPSHIP_BBOX_CRATE_MAX, DROPSHIP_BBOX_CRATE_MIN)
		local att = self:GetAttachment(5)
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/combine_dropship_container.mdl")
		prop:SetPos(self:GetPos())
		prop:SetAngles(self:GetAngles())
		prop:Spawn()
		prop:Activate()
		prop:SetParent(self)
		prop:SetOwner(self)
		prop:AddEffects(bit.bor(EF_PARENT_ANIMATES))
		-- prop:Fire("SetParentAttachment", "Cargo", 0)
		-- prop:Fire("SetParentAttachment", 5, 0)
		prop:SetMoveType(MOVETYPE_PUSH)
		prop:SetGroundEntity(NULL)
		-- prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:DeleteOnRemove(prop)
		self.Cargo = prop
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DropOffCargo()
	if self.HasDroppedOffCargo then return end
	local cargo = self.Cargo
	if !IsValid(cargo) then return end

	self:SetMaxYawSpeed(0)
	self:SetLocalVelocity(self:GetVelocity() *0.5)
	self.HasDroppedOffCargo = true
	self.EngineLoop:Stop()
	self.EngineLoopB:Play()
	self.CargoLoop:Play()
	-- self:SetDropshipState(LandingState.LANDING_UNLOADING)

	if self.CargoType == CRATE_TYPES.CRATE_SOLDIER then
		cargo:ResetSequence("open_idle")
		cargo:SetPlaybackRate(0.25)
		local soldierCount = math.random(DROPSHIP_DEFAULT_SOLDIERS, DROPSHIP_MAX_SOLDIERS)
		for i = 1, soldierCount do
			timer.Simple(2.7 *i, function()
				if IsValid(cargo) && IsValid(self) then
					local att = cargo:GetAttachment(cargo:LookupAttachment("Deploy_Start"))
					local class = VJ.PICK({"npc_vj_hlr2_com_soldier", "npc_vj_hlr2_com_soldier", "npc_vj_hlr2_com_soldier", "npc_vj_hlr2_com_soldier", "npc_vj_hlr2_com_shotgunner"})
					local soldier = ents.Create(class)
					soldier:SetPos(att.Pos)
					soldier:SetAngles(cargo:GetAngles())
					soldier:Spawn()
					soldier.VJ_NPC_Class = self.VJ_NPC_Class
					soldier:Activate()
					soldier:SetMoveType(MOVETYPE_FLY)
					soldier:Give(VJ.PICK(list.Get("NPC")[class].Weapons))
					soldier:SetOwner(cargo)
					timer.Simple(0, function()
						if IsValid(soldier) then
							local _, dur = soldier:PlayAnim("vjseq_Dropship_Deploy", true, false, false, 0, {OnFinish=function()
								soldier:SetMoveType(MOVETYPE_STEP)
								soldier:SetLastPosition(soldier:GetPos() +soldier:GetForward() *math.random(200, 400) +soldier:GetRight() *math.random(-400, 400) +soldier:GetUp() *math.random(0, 25))
								soldier:SCHEDULE_GOTO_POSITION("TASK_RUN_PATH", function(x)
									x.CanShootWhenMoving = true
									x.ConstantlyFaceEnemyVisible = true
								end)

								if i == soldierCount then
									self:SetDropshipState(LandingState.LANDING_NO)
									self:SetDesiredPosition(self:GetPos() +self:GetUp() *512)
									self:SetMaxYawSpeed(2)
									self.CargoDropOffPoint = nil
									self.IsGoingToDropOffCargo = false
									cargo:ResetSequence("close_idle")
									cargo:SetPlaybackRate(0.25)
									self.EngineLoop:Play()
									self.EngineLoopB:Stop()
									self.CargoLoop:Stop()
									self:SetDropshipState(LandingState.LANDING_LIFTOFF)
								end
							end})
							soldier:SetState(VJ_STATE_ONLY_ANIMATION_NOATTACK, dur)
						end
					end)
				end
			end)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local math_angApproach = math.ApproachAngle
--
function ENT:OnUpdatePoseParamTracking(pitch, yaw, roll)
	if IsValid(self.Cargo) && self.CargoType == CRATE_TYPES.CRATE_SOLDIER then
		self.Cargo:SetPoseParameter("weapon_pitch", math_angApproach(self.Cargo:GetPoseParameter("weapon_pitch"), -pitch, 10))
		self.Cargo:SetPoseParameter("weapon_yaw", math_angApproach(self.Cargo:GetPoseParameter("weapon_yaw"), yaw, 10))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	local state = self:GetDropshipState()
	return state == (LandingState.LANDING_NO or LandingState.LANDING_LIFTOFF) && (IsValid(self.Cargo) && self.AnimTbl.Cargo or self.AnimTbl.Idle) or self.AnimTbl.Hover
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	self:Flight()

	if timer.Exists("vj_timer_fire_" .. self:EntIndex()) then
		self.FireLoop:Play()
	else
		self.FireLoop:Stop()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetDesiredPosition(pos)
	self.DesiredPosition = pos
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetDesiredPosition()
	return self.DesiredPosition
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetCalculatedPosition(pos, calcType)
	if calcType == 1 then
		local trDown = util.TraceHull({
			start = pos,
			endpos = pos +Vector(0, 0, -1024),
			filter = {self, self.Cargo},
			mins = DROPSHIP_BBOX_MAX,
			maxs = DROPSHIP_BBOX_MIN,
		})

		if trDown.Hit then
			return trDown.HitPos +trDown.HitNormal *self:GetCollisionBounds().z
		end
		return false
	end

	local tr = util.TraceHull({
		start = self:GetPos(),
		endpos = pos,
		filter = {self, self.Cargo},
		mask = MASK_SOLID_BRUSHONLY,
		mins = DROPSHIP_BBOX_MAX,
		maxs = DROPSHIP_BBOX_MIN,
	})

	if tr.Hit then
		local trLeft = util.TraceHull({
			start = self:GetPos(),
			endpos = pos +Vector(0, 0, 128) +self:GetRight() *256,
			filter = {self, self.Cargo},
			mask = MASK_SOLID_BRUSHONLY,
			mins = DROPSHIP_BBOX_MAX,
			maxs = DROPSHIP_BBOX_MIN,
		})
		local trRight = util.TraceHull({
			start = self:GetPos(),
			endpos = pos +Vector(0, 0, 128) -self:GetRight() *256,
			filter = {self, self.Cargo},
			mask = MASK_SOLID_BRUSHONLY,
			mins = DROPSHIP_BBOX_MAX,
			maxs = DROPSHIP_BBOX_MIN,
		})

		if trLeft.Hit && trRight.Hit then
			return false
		end
		if trLeft.Hit then
			return trRight.HitPos
		end
		if trRight.Hit then
			return trLeft.HitPos
		end
	end
	return tr.HitPos or false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:GetMoveDirection()
	if self:GetVelocity():Length() <= 5 then return false end
	local myPos = self:GetPos()
	local dir = ((self:GetDesiredPosition() or myPos) - myPos)
	return (self:GetAngles() -dir:Angle()):Forward()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FindNodesNearPoint(checkPos, total, dist, minDist)
	local nodegraph = table.Copy(VJ_Nodegraph.Data.Nodes)
	local closestNode = NULL
	local closestDist = 999999
	for _, v in pairs(nodegraph) do
		local dist = v.pos:Distance(checkPos)
		if dist < closestDist then
			closestNode = v
			closestDist = dist
		end
	end
	local savedPoints = {}
	for _, v in pairs(nodegraph) do
		if v.pos:Distance(closestNode.pos) <= (dist or 1024) && v.pos:Distance(closestNode.pos) >= (minDist or 0) && v.type == 2 then
			table.insert(savedPoints, v.pos)
		end
	end
	return #savedPoints > 0 && savedPoints or false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Flight()
	local state = self:GetDropshipState()
	if self:IsFlagSet(FL_ONGROUND) then
		self:SetGroundEntity(NULL)
	end

	local moveDir = self:GetMoveDirection()
	if moveDir && state != LandingState.LANDING_DESCEND then
		if self.CargoType == CRATE_TYPES.CRATE_NONE then
			self:SetPoseParameter("body_accel", moveDir.x)
			self:SetPoseParameter("body_sway", -moveDir.y)
			self:SetPoseParameter("cargo_body_accel", 0)
			self:SetPoseParameter("cargo_body_sway", 0)
		else
			self:SetPoseParameter("cargo_body_accel", moveDir.x)
			self:SetPoseParameter("cargo_body_sway", -moveDir.y)
			self:SetPoseParameter("body_accel", 0)
			self:SetPoseParameter("body_sway", 0)
		end
	end

	local ent = self:GetEnemy()
	if !self.HasDroppedOffCargo && IsValid(ent) && CurTime() > self.NextFindDropOffT && !self.PossibleDropOffPoint then
		-- self.IsGoingToDropOffCargo = true
		-- self:SetDesiredPosition(state == LandingState.LANDING_DESCEND && self.CargoDropOffPoint or ent:GetPos() +ent:GetUp() *512)
		-- PossibleDropOffPoint

		local nodes = self:FindNodesNearPoint(ent:GetPos(), 16, 1024, 256)
		if nodes then
			for x, randNode in RandomPairs(nodes) do
				local tr = util.TraceHull({
					start = randNode,
					endpos = randNode +Vector(0, 0, 512),
					filter = {self, self.Cargo},
					mins = DROPSHIP_BBOX_MAX /2,
					maxs = DROPSHIP_BBOX_MIN /2,
				})
				-- print("Checking", x, tr.HitPos:Distance(randNode))
				-- VJ.DEBUG_TempEnt(randNode, self:GetAngles(), Color(43, 255, 0), 5)
				if tr.HitPos:Distance(randNode +Vector(0, 0, 512)) <= 256 then
					-- print("FOUND", x)
					randNode = tr.HitPos
					self.PossibleDropOffPoint = randNode
					self.IsGoingToDropOffCargo = true
					self:SetDesiredPosition(randNode)
					break
				end
			end
		end
		self.NextFindDropOffT = CurTime() +math.Rand(6, 12)
	end
	local flPos
	if !self.IsGoingToDropOffCargo then
		if state == LandingState.LANDING_NO then
			if CurTime() > self.NextWanderPointT then
				local randPos = self:GetPos() +VectorRand() *math.random(1024, 2048)
				while !util.IsInWorld(randPos) do
					randPos = self:GetPos() +VectorRand() *math.random(1024, 2048)
				end
				self:SetDesiredPosition(randPos)
				self.NextWanderPointT = CurTime() +(self:GetPos():Distance(randPos) /(DROPSHIP_MAX_SPEED *1.5)) +math.Rand(0.2, 1.5)
			end
		end
	end
	local pos = self:GetPos()
	local desiredPos = self:GetDesiredPosition()
	if desiredPos == vector_origin then
		return
	end
	local dist = pos:Distance(desiredPos)

	-- if !self.HasDroppedOffCargo then
		if state == LandingState.LANDING_NO then
			local calcPos = self:GetCalculatedPosition(desiredPos, 0)
			if calcPos then
				flPos = calcPos
			end
			-- VJ.DEBUG_TempEnt(calcPos, self:GetAngles(), Color(212, 0, 255), 5)
		elseif state == LandingState.LANDING_DESCEND && !self.CargoDropOffPoint then
			local calcPos = self:GetCalculatedPosition(desiredPos, 1)
			if calcPos then
				flPos = calcPos
				self.CargoDropOffPoint = flPos
				self:SetLocalVelocity(self:GetVelocity() *0.1)
				-- VJ.DEBUG_TempEnt(calcPos, self:GetAngles(), Color(212, 0, 255), 5)
			end
		end
	-- end

	if self.CargoDropOffPoint then
		flPos = self.CargoDropOffPoint
	end
	if flPos then
		local accel = DROPSHIP_ACCEL_RATE *FrameTime()
		local vel = self:GetVelocity()
		local dir = (flPos -pos):GetNormalized()
		local dist = pos:Distance(flPos)
		local speed = vel:Length()
		local desiredSpeed = speed
		local bArrived = dist <= DROPSHIP_ARRIVE_DIST *1.25

		-- VJ.DEBUG_TempEnt(flPos, self:GetAngles(), Color(255, 0, 0), 5)
		if bArrived then
			if desiredSpeed > 0 then
				desiredSpeed = desiredSpeed -(accel *2)
			end
			accel = accel *30
			self:SetLocalVelocity(vel *0.9)
			self:SetTurnTarget(flPos, 0.2)
			if !self.HasDroppedOffCargo && self.IsGoingToDropOffCargo && !self.CargoDropOffPoint then
				self:SetDropshipState(LandingState.LANDING_DESCEND)
				self:SetPoseParameter("body_accel", 0)
				self:SetPoseParameter("body_sway", 0)
				self:SetPoseParameter("cargo_body_accel", 0)
				self:SetPoseParameter("cargo_body_sway", 0)
				if !self.EngineLoopB:IsPlaying() then
					self:SetLocalVelocity(self:GetVelocity() *0.1)
				end
				self.EngineLoop:Stop()
				self.EngineLoopB:Play()
				self.CargoLoop:Stop()
			elseif self.CargoDropOffPoint then
				self:DropOffCargo()
			end
		else
			if self.CargoDropOffPoint then
				local tr = util.TraceHull({
					start = self:GetPos(),
					endpos = self:GetPos() -Vector(0, 0, 150),
					filter = {self, self.Cargo},
					mins = DROPSHIP_BBOX_CRATE_MAX /2,
					maxs = DROPSHIP_BBOX_CRATE_MIN /2,
					mask = MASK_SOLID_BRUSHONLY,
				})
				-- Entity(1):ChatPrint("Trace Hull: " .. tostring(tr.Hit) .. " " .. tostring(tr.HitPos))
				if tr.HitWorld then
					flPos = tr.HitPos +tr.HitNormal
					self:SetLocalVelocity(self:GetVelocity() *0.1)
					self:DropOffCargo()
				end
			end
			if desiredSpeed < ((DROPSHIP_MAX_SPEED *(self.Alerted && 1 or 0.4)) *(self.CargoDropOffPoint && 0.25 or 1)) then
				desiredSpeed = desiredSpeed +accel
			end
			self:SetLocalVelocity(vel +(dir *accel))
			self:SetTurnTarget(flPos, 0.2)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCreateDeathCorpse(dmginfo, hitgroup, corpse)
	corpse:SetBodygroup(1, 1)
	local cargo = self.Cargo
	if IsValid(cargo) && self.CargoType == CRATE_TYPES.CRATE_SOLDIER then
		util.BlastDamage(self, self, cargo:GetPos(), 200, 40)
		util.ScreenShake(cargo:GetPos(), 100, 200, 1, 2500)
		VJ.EmitSound(cargo, "vj_fire/explosion2.wav", 100, 100)
		VJ.EmitSound(cargo, "vj_fire/explosion3.wav", 100, 100)
		for i = 1, math.random(3, 4) do
			ParticleEffect("vj_explosion2", cargo:GetPos() +VectorRand() *128, Angle())
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	self.EngineLoop:Stop()
	self.EngineLoopB:Stop()
	self.CargoLoop:Stop()
	self.FireLoop:Stop()
	timer.Remove("vj_timer_fire_" .. self:EntIndex())
end