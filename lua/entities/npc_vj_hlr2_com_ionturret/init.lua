include("entities/npc_vj_hlr2_com_sentry/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/combine_cannon_gun.mdl"
ENT.StartHealth = 500
ENT.Immune_Bullet = true
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.Turret_HasAlarm = false
ENT.Turret_BulletAttachment = "muzzle"
ENT.TimeUntilRangeAttackProjectileRelease = 0.001
ENT.NextRangeAttackTime = 1.2
ENT.NextAnyAttackTime_Range = 1.2
ENT.RangeAttackProjectiles = nil
ENT.RangeAttackEntityToSpawn = nil
ENT.Turret_FireSound = {"^vj_hlr/src/npc/ioncannon/ion_cannon_shot1.wav", "^vj_hlr/src/npc/ioncannon/ion_cannon_shot2.wav", "^vj_hlr/src/npc/ioncannon/ion_cannon_shot3.wav"}

ENT.GibOnDeathFilter = false
ENT.GeneratorHealth = 100

ENT.ControllerParams = {
	FirstP_Bone = "polySurface167",
	FirstP_Offset = Vector(-5, 1, 20),
	FirstP_ShrinkBone = false
}

local doorSound = !IsMounted("ep2")
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self.SightDistance = 5000
	self:SetCollisionBounds(Vector(8, 12, 22), Vector(-8, -12, 0))
	self.RangeAttackMaxDistance = self.SightDistance
	self.RangeAttackAngleRadius = 75
	self.SightAngle = 140

	if self.SideTurret then return end

	local prop = ents.Create("prop_vj_animatable")
	prop:SetModel("models/vj_hlr/hl2/combine_cannon_stand.mdl")
	prop:SetPos(self:GetPos())
	prop:SetAngles(self:GetAngles())
	prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	prop:Spawn()
	prop:AddEFlags(EFL_DONTBLOCKLOS)
	self:DeleteOnRemove(prop)
	self.MainStand = prop

	local prop1 = ents.Create("prop_vj_animatable")
	prop1:SetModel("models/vj_hlr/hl2/combine_cannon_stand02.mdl")
	prop1:SetPos(self:GetPos())
	prop1:SetAngles(self:GetAngles())
	-- prop1:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	prop1:Spawn()
	prop1:AddEFlags(EFL_DONTBLOCKLOS)
	self:DeleteOnRemove(prop1)
	self.SmallStand = prop1

	local prop2 = ents.Create("prop_vj_animatable")
	prop2:SetModel("models/vj_hlr/hl2/combine_cannon_powergen.mdl")
	prop2:SetPos(self:GetPos() +self:GetRight() *-170 +self:GetForward() *-60.5 +self:GetUp() *-0.25)
	prop2:SetAngles(self:GetAngles() +Angle(0, 90, 0))
	prop2:Spawn()
	prop2:AddFlags(bit.bor(FL_NPC, FL_OBJECT))
	prop2:SetCollisionGroup(COLLISION_GROUP_NPC)
	prop2:SetHealth(self.GeneratorHealth)
	prop2:SetMaxHealth(self.GeneratorHealth)
	prop2.VJ_NPC_Class = self.VJ_NPC_Class
	prop2.Dead = false
	prop2.DoorState = 0
	prop2.OnTakeDamage = function(self, dmginfo)
		if dmginfo:GetDamageType() == DMG_BLAST && self:GetSequenceName(self:GetSequence()) == "open" then
			self:SetHealth(self:Health() -dmginfo:GetDamage())
		end
		if self:Health() <= 0 && !self.Dead then
			if IsValid(self:GetParent()) then
				dmginfo:SetDamage(999999999)
				self:GetParent():TakeDamageInfo(dmginfo)
			end
		end
	end
	self:DeleteOnRemove(prop2)
	self.Generator = prop2
	self.Bullseye = prop2

	-- local propbullseye = ents.Create("obj_vj_bullseye")
	-- propbullseye:SetModel("models/hunter/plates/plate.mdl")
	-- propbullseye:SetPos(prop2:GetBonePosition(0) +Vector(0, 0, 35) +self:GetRight() *35)
	-- propbullseye:SetAngles(prop2:GetAngles())
	-- propbullseye:SetParent(propbullseye)
	-- propbullseye.VJ_NPC_Class = self.VJ_NPC_Class
	-- propbullseye:Spawn()
	-- propbullseye:SetColor(Color(0, 255, 0))
	-- propbullseye:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	-- propbullseye:SetNoDraw(false)
	-- propbullseye:DrawShadow(false)
	-- self:DeleteOnRemove(propbullseye)
	-- self.Bullseye = propbullseye

	-- local prop2 = ents.Create("obj_vj_bullseye")
	-- prop2:SetModel("models/vj_hlr/hl2/combine_cannon_powergen.mdl")
	-- prop2:SetPos(self:GetPos() +self:GetRight() *-170 +self:GetForward() *-60.5 +self:GetUp() *-0.25)
	-- prop2:SetAngles(self:GetAngles() +Angle(0, 90, 0))
	-- prop2:SetParent(prop2)
	-- prop2.VJ_NPC_Class = self.VJ_NPC_Class
	-- prop2:Spawn()
	-- prop2:SetCollisionGroup(COLLISION_GROUP_NPC)
	-- prop2:SetHealth(self.GeneratorHealth)
	-- prop2:SetMaxHealth(self.GeneratorHealth)
	-- prop2:SetCollisionBounds(Vector(20, 20, 70), Vector(-20, -20, 0))
	-- prop2.Dead = false
	-- prop2.DoorState = 0
	-- prop2.OnTakeDamage = function(self, dmginfo)
	-- 	if dmginfo:GetDamageType() == DMG_BLAST && self:GetSequenceName(self:GetSequence()) == "open" then
	-- 		self:SetHealth(self:Health() -dmginfo:GetDamage())
	-- 	end
	-- 	if self:Health() <= 0 && !self.Dead then
	-- 		if IsValid(self:GetParent()) then
	-- 			dmginfo:SetDamage(999999999)
	-- 			self:GetParent():TakeDamageInfo(dmginfo)
	-- 		end
	-- 	end
	-- end
	-- self:DeleteOnRemove(prop2)
	-- self.Generator = prop2
	-- self.Bullseye = prop2

	-- local bullseye = ents.Create("obj_vj_bullseye")
	-- bullseye:SetModel("models/hunter/plates/plate.mdl")
	-- bullseye:SetPos(prop2:GetBonePosition(0) +Vector(0, 0, 60) +self:GetRight() *25)
	-- bullseye:SetParent(prop2)
	-- bullseye.VJ_NPC_Class = self.VJ_NPC_Class
	-- bullseye:Spawn()
	-- bullseye:SetNoDraw(true)
	-- bullseye:DrawShadow(false)
	-- self:DeleteOnRemove(bullseye)
	-- self.Bullseye = bullseye

	self:SetPos(self:GetPos() +self:GetUp() *54 +self:GetForward() *18)

	prop:SetParent(self)
	prop1:SetParent(self)
	prop2:SetParent(self)

	timer.Simple(0, function()
		self:SetPos(self:GetPos() +self:GetUp() *54)
		for i = 1, 2 do
			local t = ents.Create("npc_vj_hlr2_com_ionturret")
			t:SetPos(self:GetPos() +self:GetRight() *(i == 1 && -24 or 24) +self:GetForward() *4 +Vector(0, 0, 1))
			t:SetAngles(self:GetAngles() +Angle(0, i == 1 && 40 or -40, 0))
			t.SideTurret = true
			t:Spawn()
			t:SetParent(self)
			if i == 1 then self.Turret1 = t else self.Turret2 = t end
			self:DeleteOnRemove(t)
		end
		self.Obstacles = {self, self.Generator, self.MainStand, self.SmallStand, self.Turret1, self.Turret2}
		self.Turret1.Obstacles = {self.Generator, self.MainStand, self.SmallStand, self, self.Turret2}
		self.Turret2.Obstacles = {self.Generator, self.MainStand, self.SmallStand, self, self.Turret1}

		self:SetCollisionBounds(Vector(8, 12, 22), Vector(-8, -12, -54))

		self:SetAngles(Angle(0, self:GetAngles().y +180, 0))

		local hookName = "VJ_HLR_CombineCannon_" .. self:EntIndex()
		hook.Add("PhysgunPickup", "", function(ply, ent)
			if !IsValid(self) then
				hook.Remove("PhysgunPickup", hookName)
			end
			if ent == self.Generator or ent == self.MainStand or ent == self.SmallStand or ent == self.Turret1 or ent == self.Turret2 then
				return false
			end
		end)
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoTrace()
	-- if IsValid(self:GetEnemy()) then return end
	local tr = util.TraceLine({
		start = self:GetAttachment(1).Pos,
		endpos = self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter() +VectorRand() *60,
		filter = self.Obstacles,
		-- mask = MASK_SHOT_HULL
	})
	PrintTable(self.Obstacles)
	return tr.HitPos
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRangeAttackExecute(status, enemy, projectile)
	if status == "Init" then
		local attackpos = self:DoTrace()
		util.ParticleTracerEx("weapon_combine_ion_cannon", self:GetPos(), attackpos, false, self:EntIndex(), 1)
		ParticleEffect("vj_aurora_shockwave", attackpos, Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)), nil)
		ParticleEffect("Weapon_Combine_Ion_Cannon_Exlposion_c", attackpos +Vector(0, 0, -35), Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)), nil)
		util.ScreenShake(attackpos, 16, 200, 2, 1500)
		util.ScreenShake(self:GetPos(), 12, 100, 0.4, 800)
		sound.Play("weapons/mortar/mortar_explode3.wav", attackpos, 80, 100)
		VJ.ApplyRadiusDamage(self, self, attackpos, 80, 50, bit.bor(DMG_BLAST, DMG_BURN, DMG_DISSOLVE, DMG_AIRBOAT), true, false, {Force = 150})

		VJ.EmitSound(self, self.Turret_FireSound, 120, math.random(100, 110))
		self:PlayAnim("vjseq_fire", true, 0.15)
		local gest = self:AddGestureSequence(self:LookupSequence("fire"))
		self:SetLayerPriority(gest, 1)
		self:SetLayerPlaybackRate(gest, 0.5)

		ParticleEffectAttach("vj_rifle_full_blue", PATTACH_POINT_FOLLOW, self, 1)

		local FireLight1 = ents.Create("light_dynamic")
		FireLight1:SetKeyValue("brightness", "4")
		FireLight1:SetKeyValue("distance", "120")
		FireLight1:SetPos(self:GetAttachment(1).Pos)
		FireLight1:SetLocalAngles(self:GetAngles())
		FireLight1:Fire("Color", "0 31 225")
		FireLight1:SetParent(self)
		FireLight1:Spawn()
		FireLight1:Activate()
		FireLight1:Fire("TurnOn")
		FireLight1:Fire("Kill", nil, 0.07)
		self:DeleteOnRemove(FireLight1)
		return true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	self.HasPoseParameterLooking = false -- Make it not aim at the enemy right away!
	timer.Simple(0.6, function()
		if IsValid(self) then
			self.HasPoseParameterLooking = true
		end
	end)
	self:PlayAnim({"deploy"}, true, false)
	VJ.EmitSound(self, {"npc/turret_floor/click1.wav"}, 70, 100)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	local parameter = self:GetPoseParameter("aim_yaw")
	if parameter != self.Turret_CurrentParameter then
		self.turret_turningsd = CreateSound(self, "ambient/alarms/combine_bank_alarm_loop4.wav")
		self.turret_turningsd:SetSoundLevel(60)
		self.turret_turningsd:PlayEx(1, 100)
	else
		VJ.STOPSOUND(self.turret_turningsd)
	end
	self.Turret_CurrentParameter = parameter

	local gen = self.Generator
	if IsValid(gen) then
		if !self.Turret_StandDown && gen.DoorState != 2 then
			gen.DoorState = 2
			gen:ResetSequence(gen:LookupSequence("close"))
			self.Bullseye:AddFlags(FL_NOTARGET)
			if doorSound then VJ.CreateSound(gen, "vj_hlr/src/npc/ioncannon/ol09_gungrate_open.wav", 80) end
		elseif self.Turret_StandDown && gen.DoorState != 1 then
			gen.DoorState = 1
			gen:ResetSequence(gen:LookupSequence("open"))
			self.Bullseye:RemoveFlags(FL_NOTARGET)
			if doorSound then VJ.CreateSound(gen, "vj_hlr/src/npc/ioncannon/ol09_gungrate_open.wav", 80) end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnUpdatePoseParamTracking(pitch, yaw, roll)
	-- Compare the difference between the current position of the pose parameter and the position it's suppose to go to
	if (math.abs(math.AngleDifference(self:GetPoseParameter("aim_yaw"), math.ApproachAngle(self:GetPoseParameter("aim_yaw"), yaw, self.PoseParameterLooking_TurningSpeed))) >= 10) or (math.abs(math.AngleDifference(self:GetPoseParameter("aim_pitch"), math.ApproachAngle(self:GetPoseParameter("aim_pitch"), pitch, self.PoseParameterLooking_TurningSpeed))) >= 10) then
		self.Turret_HasLOS = false
	else
		if self.Turret_HasLOS == false && IsValid(self:GetEnemy()) then -- If it just got LOS, then play the gun "activate" sound
			VJ.EmitSound(self, {"npc/turret_floor/active.wav"}, 70, 100)
		end
		self.Turret_HasLOS = true
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	if IsValid(self:GetEnemy()) or self.Alerted then
		self.Turret_StandDown = false
		self.AnimTbl_IdleStand = {"idlealert"}

		local scan = false
		local pyaw = self:GetPoseParameter("aim_yaw")

		-- Make it scan around if the enemy is behind, which is unreachable for it!
		if IsValid(self:GetEnemy()) && self.Turret_HasLOS == false && (self:GetForward():Dot((self:GetEnemy():GetPos() - self:GetPos()):GetNormalized()) <= math.cos(math.rad(self.RangeAttackAngleRadius))) then
			scan = true
			self.HasPoseParameterLooking = false
		else
			self.HasPoseParameterLooking = true
		end

		 -- Look around randomly when the enemy is not found
		if !IsValid(self:GetEnemy()) or scan == true then
			-- Playing a beeping noise
			if self.Turret_NextScanBeepT < CurTime() then
				VJ.EmitSound(self, {"npc/roller/code2.wav"}, 75, 100)
				self.Turret_NextScanBeepT = CurTime() + 1
			end
			-- LEFT TO RIGHT
			-- Change the rotation direction when the max number is reached for a direction
			if pyaw >= 60 then
				self.Turret_ScanDirSide = 1
			elseif pyaw <= -60 then
				self.Turret_ScanDirSide = 0
			end
			self:SetPoseParameter("aim_yaw", pyaw + (self.Turret_ScanDirSide == 1 and -2 or 2))
			-- UP AND DOWN
			-- Change the rotation direction when the max number is reached for a direction
			if self:GetPoseParameter("aim_pitch") >= 15 then
				self.Turret_ScanDirUp = 1
			elseif self:GetPoseParameter("aim_pitch") <= -15 then
				self.Turret_ScanDirUp = 0
			end
			self:SetPoseParameter("aim_pitch", self:GetPoseParameter("aim_pitch") + (self.Turret_ScanDirUp == 1 and -3 or 3))
		end
	else
		-- Play the retracting sequence and sound
		if !self.Alerted && self.Turret_StandDown == false then
			self.Turret_StandDown = true
			self:PlayAnim({"retire"}, true, 1)
			VJ.EmitSound(self, {"npc/turret_floor/retract.wav"}, 70, 100)
		end
		if self.Turret_StandDown == true then
			self.AnimTbl_IdleStand = {ACT_IDLE}
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local defAng = Angle()
--
function ENT:OnDeath(dmginfo, hitgroup, status)
	if status == "Finish" then
		VJ.EmitSound(self, "vj_hlr/src/npc/ioncannon/ol09_biggundestroy.wav", 110)
		local function explode(ent)
			ent = ent or self
			if !IsValid(ent) then return end
			local startPos = ent:GetPos() + ent:OBBCenter()
			ParticleEffect("explosion_turret_break_fire", startPos, defAng, NULL)
			ParticleEffect("explosion_turret_break_flash", startPos, defAng, NULL)
			ParticleEffect("explosion_turret_break_pre_smoke Version #2", startPos, defAng, NULL)
			ParticleEffect("explosion_turret_break_sparks", startPos, defAng, NULL)
			ParticleEffect("vj_explosion1", startPos, defAng, NULL)
		end
		explode(self)
		explode(self.MainStand)
		explode(self.SmallStand)
		explode(self.Generator)
		explode(self.Turret1)
		explode(self.Turret2)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local sdGibCollide = {"physics/metal/metal_box_impact_hard1.wav", "physics/metal/metal_box_impact_hard2.wav", "physics/metal/metal_box_impact_hard3.wav"}
--
function ENT:HandleGibOnDeath(dmginfo, hitgroup)
	self.HasDeathSounds = false
	local function gibs(ent)
		ent = ent or self
		if !IsValid(ent) then return end
		self:CreateGibEntity("obj_vj_gib", "models/combine_turrets/floor_turret_gib1.mdl", {BloodType = "", Pos = ent:LocalToWorld(Vector(0, 0, 40)), CollisionSound = sdGibCollide})
		self:CreateGibEntity("obj_vj_gib", "models/combine_turrets/floor_turret_gib2.mdl", {BloodType = "", Pos = ent:LocalToWorld(Vector(0, 0, 20)), CollisionSound = sdGibCollide})
		self:CreateGibEntity("obj_vj_gib", "models/combine_turrets/floor_turret_gib3.mdl", {BloodType = "", Pos = ent:LocalToWorld(Vector(0, 0, 30)), CollisionSound = sdGibCollide})
		self:CreateGibEntity("obj_vj_gib", "models/combine_turrets/floor_turret_gib4.mdl", {BloodType = "", Pos = ent:LocalToWorld(Vector(0, 0, 35)), CollisionSound = sdGibCollide})
		self:CreateGibEntity("obj_vj_gib", "models/combine_turrets/floor_turret_gib5.mdl", {BloodType = "", Pos = ent:LocalToWorld(Vector(0, 0, 35)), CollisionSound = sdGibCollide})
	end

	gibs(self)
	gibs(self.MainStand)
	gibs(self.SmallStand)
	gibs(self.Generator)
	gibs(self.Turret1)
	gibs(self.Turret2)

	return true
end