AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2b/alien_assassin.mdl"
ENT.StartHealth = 80
ENT.HullType = HULL_HUMAN
ENT.JumpParams = {
	MaxRise = 620,
	MaxDrop = 1098,
	MaxDistance = 890
}

ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.BloodColor = VJ.BLOOD_COLOR_RED

ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDamage = 15
ENT.MeleeAttackDistance = 55
ENT.MeleeAttackDamageDistance = 100
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackBleedEnemyChance = 1
ENT.MeleeAttackBleedEnemyReps = 10
ENT.MeleeAttackPlayerSpeedTime = 5

ENT.HasRangeAttack = true
ENT.AnimTbl_RangeAttack = {ACT_RANGE_ATTACK1, "tripwire", "pests"}
ENT.RangeAttackMaxDistance = 1750
ENT.RangeAttackMinDistance = 350
ENT.TimeUntilRangeAttackProjectileRelease = false
ENT.NextRangeAttackTime = VJ.SET(5, 9)

ENT.DisableFootStepSoundTimer = true
ENT.HasExtraMeleeAttackSounds = true
ENT.MainSoundPitch = 140

ENT.SoundTbl_FootStep = {
	"npc/fast_zombie/foot1.wav",
	"npc/fast_zombie/foot2.wav",
	"npc/fast_zombie/foot3.wav",
	"npc/fast_zombie/foot4.wav"
}
ENT.SoundTbl_Idle = {
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_01.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_02.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_03.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_04.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_05.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_06.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_07.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_08.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_09.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_10.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_11.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_12.wav"
}
ENT.SoundTbl_BeforeMeleeAttack = {
	"vj_hlr/src/npc/alienassassin/vox_abandon_gurgle_01.wav",
	"vj_hlr/src/npc/alienassassin/vox_abandon_gurgle_02.wav",
	"vj_hlr/src/npc/alienassassin/vox_abandon_gurgle_03.wav"
}
ENT.SoundTbl_BeforeRangeAttack = {
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_01.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_02.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_03.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_04.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_05.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_06.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_07.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_08.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_09.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_10.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_11.wav",
	"vj_hlr/src/npc/alienassassin/vox_grunt_misc_12.wav"
}
ENT.SoundTbl_Pain = {
	"vj_hlr/src/npc/alienassassin/vox_abandon_grunt_01.wav",
	"vj_hlr/src/npc/alienassassin/vox_abandon_grunt_02.wav",
	"vj_hlr/src/npc/alienassassin/vox_abandon_grunt_03.wav"
}
ENT.SoundTbl_Death = {
	"vj_hlr/src/npc/alienassassin/vox_shockwave_yell_01.wav",
	"vj_hlr/src/npc/alienassassin/vox_shockwave_yell_02.wav",
	"vj_hlr/src/npc/alienassassin/vox_shockwave_yell_03.wav",
	"vj_hlr/src/npc/alienassassin/vox_shockwave_yell_04.wav",
	"vj_hlr/src/npc/alienassassin/vox_shockwave_yell_05.wav"
}

ENT.Assassin_NextJumpT = 0
ENT.Assassin_CloakLevel = 1
ENT.Assassin_TargetCloakLevel = 1
--
local projKnife = "models/weapons/w_knife_t.mdl"
local projPest = "models/weapons/w_bugbait.mdl"
local projHopwire = "models/vj_hlr/hl2b/weapons/tripwire.mdl"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	for i = 1, 2 do
		util.SpriteTrail(self, i +3, Color(4, 255, 0), true, 4, 1, 0.35, 1 /(25 +1) *0.5, "VJ_Base/sprites/trail.vmt")
		local spriteGlow = ents.Create("env_sprite")
		spriteGlow:SetKeyValue("rendercolor", "4 255 0")
		spriteGlow:SetKeyValue("GlowProxySize", "2.0")
		spriteGlow:SetKeyValue("HDRColorScale", "1.0")
		spriteGlow:SetKeyValue("renderfx", "14")
		spriteGlow:SetKeyValue("rendermode", "3")
		spriteGlow:SetKeyValue("renderamt", "255")
		spriteGlow:SetKeyValue("disablereceiveshadows", "0")
		spriteGlow:SetKeyValue("mindxlevel", "0")
		spriteGlow:SetKeyValue("maxdxlevel", "0")
		spriteGlow:SetKeyValue("framerate", "10.0")
		spriteGlow:SetKeyValue("model", "VJ_Base/sprites/glow.vmt")
		spriteGlow:SetKeyValue("spawnflags", "0")
		spriteGlow:SetKeyValue("scale", "0.075")
		spriteGlow:SetParent(self)
		spriteGlow:Fire("SetParentAttachment", "light" .. i)
		spriteGlow:Spawn()
		self:DeleteOnRemove(spriteGlow)
	end

	self.NextJumpAwayT = 0
	self.NextRunAwayT = CurTime() + math.Rand(1, 2)
	self.RunAwayT = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	local prevClockLvl = self:GetColor().a
	local targetLvl = self.Assassin_TargetCloakLevel * 255
	local cloakLvl = math.Clamp(self.Assassin_CloakLevel * 255, 40, 255)
	if cloakLvl < targetLvl then
		self.Assassin_CloakLevel = math.Clamp(self.Assassin_CloakLevel + 0.05, 0, targetLvl / 255)
	elseif cloakLvl > targetLvl then
		self.Assassin_CloakLevel = math.Clamp(self.Assassin_CloakLevel - 0.05, 0, targetLvl / 255)
	end
	cloakLvl = math.Clamp(self.Assassin_CloakLevel * 255, 40, 255)
	self:SetColor(Color(255, 255, 255, cloakLvl))
	if cloakLvl <= 220 then
		self:DrawShadow(false)
		self:AddFlags(FL_NOTARGET)
	else
		self:DrawShadow(true)
		self:RemoveFlags(FL_NOTARGET)
	end
	local curTime = CurTime()
	local busy = self:IsBusy()
	if curTime < self.RunAwayT then
		if !self:IsMoving() && !busy then
			self:SCHEDULE_COVER_ENEMY()
		end
		self.DisableChasingEnemy = true
		self.Assassin_TargetCloakLevel = 0
		return
	elseif self.DisableChasingEnemy && curTime > self.RunAwayT then
		self.DisableChasingEnemy = false
		self.Assassin_TargetCloakLevel = 1
		self:StopParticles()
	end
	if !busy && IsValid(self:GetEnemy()) && curTime > self.Assassin_NextJumpT && self.EnemyData.Distance < 1400 && !self.VJ_IsBeingControlled && math.random(1, 30) == 1 then
		self:ForceMoveJump(((self:GetPos() +self:GetRight() *(math.random(1, 2) == 1 && 500 or -500) +self:GetForward() *(math.random(1, 2) == 1 && 1 or -500)) -(self:GetPos() +self:OBBCenter())):GetNormalized() *300 +self:GetUp() *600)
		self.Assassin_NextJumpT = curTime + math.Rand(7, 11)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkAttack(atkType, ent)
	if !atkType then
		local curTime = CurTime()
		local data = self.EnemyData
		local busy = self:IsBusy()
		if !busy && data.Visible && data.DistanceNearest <= 100 && curTime > self.NextJumpAwayT then
			self:VJ_ACT_PLAYACTIVITY("jumpbackt", true, false, true)
			self.NextJumpAwayT = curTime + math.Rand(2.5, 7.5)
			return
		elseif !busy && data.DistanceNearest > 300 && data.DistanceNearest <= 1500 && curTime > self.NextRunAwayT then
			self:VJ_ACT_PLAYACTIVITY("smoke", true, false, true)
			return
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRangeAttack(status, enemy)
	if status == "PreInit" then
		return self:GetNavType() == NAV_JUMP
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	-- print(key)
	if key == "step" then
		self:PlayFootstepSound()
	elseif key == "attack" then
		self:ExecuteMeleeAttack()
	elseif key == "draw_knife" then
		SafeRemoveEntity(self.HoldObject)
		local att = self:GetAttachment(self:LookupAttachment("rhand"))
		local prop = ents.Create("prop_physics")
		prop:SetModel(projKnife)
		prop:SetPos(att.Pos)
		prop:SetAngles(att.Ang)
		prop:SetParent(self)
		prop:Spawn()
		prop:Activate()
		prop:SetOwner(self)
		prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		prop:Fire("SetParentAttachment", "rhand")
		self:DeleteOnRemove(prop)
		self.HoldObject = prop
	elseif key == "draw_tripwire" then
		SafeRemoveEntity(self.HoldObject)
		local att = self:GetAttachment(self:LookupAttachment("rhand"))
		local prop = ents.Create("prop_physics")
		prop:SetModel(projHopwire)
		prop:SetPos(att.Pos)
		prop:SetAngles(att.Ang)
		prop:SetParent(self)
		prop:Spawn()
		prop:Activate()
		prop:SetOwner(self)
		prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		prop:Fire("SetParentAttachment", "rhand")
		self:DeleteOnRemove(prop)
		self.HoldObject = prop
	elseif key == "draw_pests" then
		SafeRemoveEntity(self.HoldObject)
		local att = self:GetAttachment(self:LookupAttachment("rhand"))
		local prop = ents.Create("prop_physics")
		prop:SetModel(projPest)
		prop:SetPos(att.Pos)
		prop:SetAngles(att.Ang)
		prop:SetParent(self)
		prop:Spawn()
		prop:Activate()
		prop:SetOwner(self)
		prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		prop:Fire("SetParentAttachment", "rhand")
		self:DeleteOnRemove(prop)
		self.HoldObject = prop
	elseif key == "attack_knife" then
		SafeRemoveEntity(self.HoldObject)
		local ent = self:GetEnemy()
		local targetPos = IsValid(ent) && ent:GetPos() +ent:OBBCenter() or self:GetPos() +self:OBBCenter() +self:GetForward() *1000
		local att = self:GetAttachment(self:LookupAttachment("rhand"))
		local proj = ents.Create("obj_vj_projectile_base")
		proj:SetModel(projKnife)
		proj:SetPos(att.Pos)
		proj:SetAngles((targetPos -proj:GetPos()):Angle() +Angle(-90, 0, 0))
		proj:SetOwner(self)
		proj:SetNoDraw(false)
		proj:DrawShadow(true)
		proj.DoesDirectDamage = true
		proj.DirectDamage = 25
		proj.DirectDamageType = DMG_SLASH
		proj:Spawn()
		proj:Activate()

		local phys = proj:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(VJ.CalculateTrajectory(self, ent, "Line", proj:GetPos(), IsValid(ent) && 0.75 or targetPos, 4000))
		end
	elseif key == "attack_tripwire" then
		SafeRemoveEntity(self.HoldObject)
		local ent = self:GetEnemy()
		local targetPos = IsValid(ent) && ent:GetPos() +ent:OBBCenter() or self:GetPos() +self:OBBCenter() +self:GetForward() *1000
		local att = self:GetAttachment(self:LookupAttachment("rhand"))
		local proj = ents.Create("obj_vj_projectile_base")
		proj:SetModel(projHopwire)
		proj:SetPos(att.Pos)
		proj:SetAngles((targetPos -proj:GetPos()):Angle() +Angle(-90, 0, 0))
		proj:SetOwner(self)
		proj:SetNoDraw(false)
		proj:DrawShadow(true)
		proj.ProjectileType = VJ.PROJ_TYPE_PROP
		proj.DoesRadiusDamage = true
		proj.RadiusDamageRadius = 250
		proj.RadiusDamage = 95
		proj.RadiusDamageUseRealisticRadius = true
		proj.RadiusDamageType = bit.bor(DMG_BLAST, DMG_SHOCK)
		proj.RadiusDamageForce = 90
		proj.CollisionBehavior = VJ.PROJ_COLLISION_NONE
		proj.SoundTbl_Idle = "vj_hlr/src/npc/alienassassin/ball_loop1.wav"
		proj.SoundTbl_OnCollide = "weapons/hegrenade/he_bounce-1.wav"
		proj.Activated = false
		proj.FuseTime = CurTime() + ((targetPos:Distance(proj:GetPos()) / self.RangeAttackMaxDistance) *0.35)
		// Credits: Referenced the Half-Life 2 Beta SWEPs pack to see how they did the ropes for the hopwire
		function proj:Init()
			util.SpriteTrail(proj, 0, Color(0, 213, 255), true, 8, 1, 0.65, 1 /(25 +1) *0.5, "VJ_Base/sprites/trail.vmt")
			local spriteGlow = ents.Create("env_sprite")
			spriteGlow:SetKeyValue("rendercolor", "0 213 255")
			spriteGlow:SetKeyValue("GlowProxySize", "2.0")
			spriteGlow:SetKeyValue("HDRColorScale", "1.0")
			spriteGlow:SetKeyValue("renderfx", "14")
			spriteGlow:SetKeyValue("rendermode", "3")
			spriteGlow:SetKeyValue("renderamt", "255")
			spriteGlow:SetKeyValue("disablereceiveshadows", "0")
			spriteGlow:SetKeyValue("mindxlevel", "0")
			spriteGlow:SetKeyValue("maxdxlevel", "0")
			spriteGlow:SetKeyValue("framerate", "10.0")
			spriteGlow:SetKeyValue("model", "VJ_Base/sprites/glow.vmt")
			spriteGlow:SetKeyValue("spawnflags", "0")
			spriteGlow:SetKeyValue("scale", "0.5")
			spriteGlow:SetPos(proj:GetPos())
			spriteGlow:SetParent(proj)
			spriteGlow:Spawn()
			proj:DeleteOnRemove(spriteGlow)
		end
		function proj:OnThink()
			proj:NextThink(CurTime())
			if !proj.Activated then
				local phys = proj:GetPhysicsObject()
				if IsValid(phys) && CurTime() > self.FuseTime && phys:GetVelocity():Length() <= 350 then
					proj.Activated = true
					proj.Hooks = {}
					proj.FilterEnts = {proj, proj:GetOwner()}
					phys:SetVelocity(Vector())
					phys:ApplyForceCenter(Vector(0, 0, 1500))
					for i = 1, math.random(6, 10) do
						proj.SoundTbl_Idle = nil
						VJ.STOPSOUND(proj.CurrentIdleSound)
						VJ.EmitSound(proj, "weapons/tripwire/mine_activate.wav", 70)
						timer.Simple(0.25, function()
							if IsValid(proj) then
								timer.Simple(i *0.1, function()
									if IsValid(proj) then
										proj:SpawnRope(i)
										if i == 10 then
											phys:SetVelocity(Vector())
											phys:SetAngleVelocity(Vector())
										end
									end
								end)
							end
						end)
					end
				end
			else
				local hooks = proj.Hooks
				if #hooks > 0 then
					for _, hook in pairs(hooks) do
						if IsValid(hook) && hook.Frozen then
							local tr = util.TraceLine({
								start = proj:GetPos(),
								endpos = hook:GetPos(),
								filter = proj.FilterEnts
							})
							if tr.HitNonWorld then
								local trEnt = tr.Entity
								if (trEnt.VJ_HLR_HopwireHook or trEnt == proj) && !VJ.HasValue(proj.FilterEnts, trEnt) or IsValid(proj:GetOwner()) && proj:GetOwner():CheckRelationship(trEnt) == D_LI then
									table.insert(proj.FilterEnts, trEnt)
									return
								end
								-- print(trEnt)
								proj:Destroy(tr, proj:GetPhysicsObject())
								break
							end
						end
					end
				end
			end
		end
		function proj:SpawnRope(index)
			local ropeObj = ents.Create("prop_vj_animatable")
			ropeObj:SetModel("models/vj_hlr/hl2b/weapons/tripwire.mdl")
			ropeObj:SetPos(proj:GetPos())
			ropeObj:SetOwner(proj)
			ropeObj:Spawn()
			ropeObj:Activate()
			ropeObj.Frozen = false
			proj:DeleteOnRemove(ropeObj)
			ropeObj.IdleLoop = CreateSound(ropeObj, "weapons/tripwire/ropeshoot.wav")
			ropeObj.IdleLoop:SetSoundLevel(70)
			ropeObj.IdleLoop:Play()
			local trail = util.SpriteTrail(ropeObj, 0, Color(255, 255, 255), true, 1, 1, 5, 1 /(25 +1) *0.5, "cable/physbeam")
			local spriteGlow = ents.Create("env_sprite")
			spriteGlow:SetKeyValue("rendercolor", "0 125 255")
			spriteGlow:SetKeyValue("GlowProxySize", "2.0")
			spriteGlow:SetKeyValue("HDRColorScale", "1.0")
			spriteGlow:SetKeyValue("renderfx", "14")
			spriteGlow:SetKeyValue("rendermode", "3")
			spriteGlow:SetKeyValue("renderamt", "255")
			spriteGlow:SetKeyValue("disablereceiveshadows", "0")
			spriteGlow:SetKeyValue("mindxlevel", "0")
			spriteGlow:SetKeyValue("maxdxlevel", "0")
			spriteGlow:SetKeyValue("framerate", "10.0")
			spriteGlow:SetKeyValue("model", "VJ_Base/sprites/glow.vmt")
			spriteGlow:SetKeyValue("spawnflags", "0")
			spriteGlow:SetKeyValue("scale", "0.075")
			spriteGlow:SetPos(ropeObj:GetPos())
			spriteGlow:SetParent(ropeObj)
			spriteGlow:Spawn()
			ropeObj:DeleteOnRemove(spriteGlow)
			function ropeObj:PhysicsCollide(data, collision)
				ropeObj:Freeze()
			end
			function ropeObj:Think()
				if ropeObj:GetPos():Distance(proj:GetPos()) > 1000 then
					ropeObj:Remove()
					return
				end
				ropeObj:NextThink(CurTime())
			end
			function ropeObj:Freeze()
				local phys = ropeObj:GetPhysicsObject()
				if !ropeObj.Frozen && IsValid(phys) then
					SafeRemoveEntity(trail)
					ropeObj.Frozen = true
					phys:EnableMotion(false)
					ropeObj.IdleLoop:Stop()
					VJ.EmitSound(ropeObj, "weapons/tripwire/hook.wav", 70)
					constraint.Elastic(ropeObj:GetOwner(), ropeObj, 0, 0, Vector(), Vector(), 150, 24, 0.1, "cable/physbeam", 1, false )
				end
			end
			function ropeObj:OnRemove()
				if ropeObj.IdleLoop then
					ropeObj.IdleLoop:Stop()
				end
			end
			ropeObj:PhysicsInit(MOVETYPE_VPHYSICS)
			ropeObj:SetMoveType(MOVETYPE_VPHYSICS)
			ropeObj:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
			ropeObj:SetSolid(SOLID_BBOX)
			ropeObj:SetNoDraw(true)
			ropeObj:DrawShadow(false)
			local phys = ropeObj:GetPhysicsObject()
			if IsValid(phys) then
				phys:Wake()
				phys:SetMass(1)
				phys:EnableGravity(true)
				phys:EnableDrag(false)
				phys:SetBuoyancyRatio(0)
			end
			ropeObj:SetTrigger(true)
			ropeObj:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
			if IsValid(phys) then
				phys:SetVelocity(Vector(math.Rand(-1, 1) *1500, math.Rand(-1, 1) *1500, math.Rand(-1, 1) *1500))
			end
			ropeObj.VJ_HLR_HopwireHook = true
			table.insert(proj.Hooks, ropeObj)
		end
		function proj:OnDamaged(dmginfo)
			local phys = proj:GetPhysicsObject()
			if IsValid(phys) then
				phys:AddVelocity(dmginfo:GetDamageForce() * 0.1)
			end
		end
		function proj:OnCollision(data, phys)
			local getVel = phys:GetVelocity()
			local curVelSpeed = getVel:Length()
			if curVelSpeed > 500 then
				phys:SetVelocity(getVel * 0.9)
			end

			if curVelSpeed > 100 then
				proj:PlaySound("OnCollide")
			end
		end
		local defAngle = Angle()
		function proj:OnDestroy()
			local myPos = proj:GetPos()

			VJ.EmitSound(proj, "vj_hlr/src/npc/alienassassin/ball_zap1.wav", 75)
			VJ.EmitSound(proj, "vj_hlr/src/npc/alienassassin/ball_shoot1.wav", 75)
			for i = 1, 5 do
				ParticleEffect("vj_aurora_shockwave", myPos, defAngle)
				ParticleEffect("electrical_arc_01_system", myPos, defAngle)
			end

			local expLight = ents.Create("light_dynamic")
			expLight:SetKeyValue("brightness", "4")
			expLight:SetKeyValue("distance", "300")
			expLight:SetLocalPos(myPos)
			expLight:SetLocalAngles(proj:GetAngles())
			expLight:Fire("Color", "0 80 255")
			expLight:SetParent(proj)
			expLight:Spawn()
			expLight:Activate()
			expLight:Fire("TurnOn")
			proj:DeleteOnRemove(expLight)

			proj:DealDamage()
		end
		proj:Spawn()
		proj:Activate()

		local phys = proj:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(VJ.CalculateTrajectory(self, ent, "Curve", proj:GetPos(), IsValid(ent) && 0.75 or targetPos, 50))
		end
	elseif key == "attack_pests" then
		SafeRemoveEntity(self.HoldObject)
		local ent = self:GetEnemy()
		local targetPos = IsValid(ent) && ent:GetPos() +ent:OBBCenter() or self:GetPos() +self:OBBCenter() +self:GetForward() *1000
		local att = self:GetAttachment(self:LookupAttachment("rhand"))
		local proj = ents.Create("obj_vj_projectile_base")
		proj:SetModel(projPest)
		proj:SetPos(att.Pos)
		proj:SetAngles((targetPos -proj:GetPos()):Angle() +Angle(-90, 0, 0))
		proj:SetOwner(self)
		proj:SetNoDraw(false)
		proj:DrawShadow(true)
		proj.DoesRadiusDamage = true
		proj.RadiusDamageRadius = 175
		proj.RadiusDamage = 50
		proj.RadiusDamageUseRealisticRadius = true
		proj.RadiusDamageType = DMG_POISON
		proj.RadiusDamageForce = 5
		local defAngle = Angle()
		function proj:OnDestroy()
			local myPos = proj:GetPos()
			VJ.EmitSound(proj, "npc/antlion/antlion_shoot3.wav", 75)
			ParticleEffect("vj_acid_impact1_gas", myPos, defAngle)
			ParticleEffect("vj_acid_impact1_small_splat", myPos, defAngle)
			for i = 1, 10 do
				ParticleEffect("vj_acid_impact1_floaters", myPos, defAngle)
			end
		end
		proj:Spawn()
		proj:Activate()

		local phys = proj:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableGravity(true)
			phys:EnableDrag(true)
			phys:SetMass(1)
			if self:GetSequenceName(self:GetSequence()) == "jumpbackt" then
				phys:SetVelocity(VJ.CalculateTrajectory(self, ent, "Line", proj:GetPos(), IsValid(ent) && 0.75 or targetPos, 1800))
			else
				phys:SetVelocity(VJ.CalculateTrajectory(self, ent, "Curve", proj:GetPos(), IsValid(ent) && 0.75 or targetPos, 50))
			end
		end
	elseif key == "smoke" then
		ParticleEffectAttach("vj_hlr_assassin_bodysmoke", PATTACH_POINT_FOLLOW, self, 0)
		self.RunAwayT = CurTime() + math.Rand(2.5, 7.5)
		self.NextRunAwayT = self.RunAwayT + math.Rand(2.5, 7.5)
		self:StopAllSounds()
		VJ.CreateSound(self, "vj_hlr/src/npc/alienassassin/tattle1.wav", 70)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "PreDamage" && dmginfo:IsBulletDamage() && (hitgroup == 2 or hitgroup == 3 or hitgroup == 6 or hitgroup == 7) then
		if self.HasSounds && self.HasImpactSounds then
			VJ.EmitSound(self, "VJ.Impact.Armor")
		end
		dmginfo:ScaleDamage(0.8)
	end
end