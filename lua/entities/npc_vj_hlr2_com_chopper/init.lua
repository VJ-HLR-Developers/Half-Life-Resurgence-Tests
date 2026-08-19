AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.VJ_ID_Boss = true
ENT.Model = "models/vj_hlr/hl2/combine_helicopter.mdl"
ENT.StartHealth = 2000
ENT.SightAngle = 360
ENT.HullType = HULL_LARGE
ENT.TurningSpeed = 2

ENT.MovementType = VJ_MOVETYPE_AERIAL
ENT.Aerial_FlyingSpeed_Alerted = 450
ENT.Aerial_FlyingSpeed_Calm = 400
ENT.Aerial_AnimTbl_Calm = ACT_IDLE
ENT.Aerial_AnimTbl_Alerted = ACT_IDLE
ENT.AA_GroundLimit = 1200
ENT.AA_MinWanderDist = 1000
ENT.AA_MoveAccelerate = 8
ENT.AA_MoveDecelerate = 4

ENT.PoseParameterLooking_InvertPitch = true
ENT.PoseParameterLooking_InvertYaw = true
ENT.PoseParameterLooking_Names = {pitch={"weapon_pitch"}, yaw={"weapon_yaw"}, roll={}}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}

ENT.Bleeds = false
ENT.Immune_Toxic = true
ENT.Immune_Bullet = true
ENT.Immune_Fire = true

ENT.HasMeleeAttack = false

ENT.HasRangeAttack = true
ENT.AnimTbl_RangeAttack = false
ENT.RangeAttackProjectiles = "obj_vj_hlr2_rocket"
ENT.TimeUntilRangeAttackProjectileRelease = 0
ENT.NextRangeAttackTime = VJ.SET(5, 10)
ENT.RangeAttackMaxDistance = 7500
ENT.RangeAttackMinDistance = 0
ENT.RangeUseAttachmentForPos = true
ENT.RangeAttackExtraTimers = {1}

ENT.HasDeathAnimation = true
ENT.AnimTbl_Death = ACT_DIESIMPLE
ENT.DeathAnimationTime = false
ENT.DeathCorpseCollisionType = COLLISION_GROUP_NONE

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "Chopper.Blade_Hull",
	FirstP_Offset = Vector(140, 0, -45),
}

ENT.ConstantlyFaceEnemy = true
ENT.ConstantlyFaceEnemy_IfVisible = true
ENT.ConstantlyFaceEnemy_IfAttacking = false
ENT.ConstantlyFaceEnemy_Postures = "Both"
ENT.ConstantlyFaceEnemy_MinDistance = 7500

ENT.LimitChaseDistance = true
ENT.LimitChaseDistance_Max = 4000
ENT.LimitChaseDistance_Min = 0
	-- ====== Sound File Paths ====== --
-- Leave blank if you don"t want any sounds to play
ENT.SoundTbl_Alert = "npc/attack_helicopter/aheli_megabomb_siren1.wav"
ENT.SoundTbl_Pain = "npc/attack_helicopter/aheli_damaged_alarm1.wav"
-- ENT.SoundTbl_Death = "npc/attack_helicopter/aheli_crash_alert2.wav"

ENT.AlertSoundLevel = 150
ENT.PainSoundLevel = 150
ENT.DeathSoundLevel = 150
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjVel(projectile)
	return self:CalculateProjectile("Line", self:GetAttachment(self:LookupAttachment(self.RangeUseAttachmentForPosID)).Pos, self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter(), 500)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(140, 140, 100), Vector(-140, -140, -75))
	self:SetPos(self:GetPos() +Vector(0, 0, 400))

	self.IdleLP = CreateSound(self, "npc/attack_helicopter/aheli_rotor_loop1.wav")
	self.IdleLP:SetSoundLevel(105)
	self.IdleLP:Play()
	self.IdleLP:ChangeVolume(1)

	self.FireLP = CreateSound(self, "npc/attack_helicopter/aheli_weapon_fire_loop3.wav")
	self.FireLP:SetSoundLevel(120)
	self.FireLP:ChangeVolume(1)

	self.Charged = false
	self.Charging = false
	self.NextFireT = 0
	self.NextBombT = 0
	self.CarpetBombing = false
	self.CarpetBombPos = Vector()
	self.NextCarpetBombT = 0
	self.NextDropCarpetT = 0

	self.RangeUseAttachmentForPosID = "Damage0"

	local eyeglow = ents.Create("env_sprite")
	eyeglow:SetKeyValue("model", "sprites/light_glow01.vmt")
	eyeglow:SetKeyValue("scale", "5")
	eyeglow:SetKeyValue("rendermode", "9")
	eyeglow:SetKeyValue("rendercolor", "225 225 225 0")
	eyeglow:SetKeyValue("spawnflags", "1") -- If animated
	eyeglow:SetParent(self)
	eyeglow:Fire("SetParentAttachment", "spotlight", 0)
	eyeglow:Spawn()
	eyeglow:Activate()
	self:DeleteOnRemove(eyeglow)

	local spotlight = ents.Create("env_projectedtexture")
	spotlight:SetPos( self:GetPos() + Vector() )
	spotlight:SetAngles( self:GetAngles() + Angle() )
	spotlight:SetKeyValue("lightcolor", "225 225 225 255")
	spotlight:SetKeyValue("lightfov", "75")
	spotlight:SetKeyValue("farz", "2500")
	spotlight:SetKeyValue("nearz", "0.1")
	spotlight:SetKeyValue("enableshadows", "1")
	spotlight:SetKeyValue("shadowquality", "1")
	spotlight:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )
	spotlight:SetOwner(self)
	spotlight:SetParent(self)
	spotlight:Spawn()
	spotlight:Activate()
	spotlight:Fire("setparentattachment", "spotlight")
	self:DeleteOnRemove(spotlight)

	self:CreateBoneFollowers()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "Init" && dmginfo:IsDamageType(DMG_PHYSGUN) then
		dmginfo:SetDamage(0)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnRangeAttackExecute(status, enemy, projectile)
	if status == "PostSpawn" then
		self.RangeUseAttachmentForPosID = self.RangeUseAttachmentForPosID == "Damage0" && "Damage3" or "Damage0"
		VJ.CreateSound(projectile, "weapons/rpg/rocketfire1.wav", 80)
		VJ.CreateSound(projectile, "vj_base/weapons/rpg/rpg1_single_dist.wav", 120)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BarrageFire()
	local bomb = self.CarpetBombing
	timer.Create("vj_timer_fire_" .. self:EntIndex(), 0.1, 50, function()
		if IsValid(self:GetEnemy()) && !self.Dead then
			if bomb then timer.Remove("vj_timer_fire_" .. self:EntIndex()) return end
			sound.EmitHint(SOUND_DANGER, self:GetEnemy():GetPos(), 250, 0.25, self)
			for i = 1, 3 do
				local att = self:GetAttachment(2)
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
				bullet.Spread = Vector(0.05, 0.05, 0)
				bullet.Tracer = 1
				bullet.TracerName = "AirboatGunTracer"
				bullet.Force = 3
				bullet.Damage = self:ScaleByDifficulty(7)
				bullet.AmmoType = "AR2"
				self:FireBullets(bullet)
			end

			ParticleEffectAttach("vj_rifle_full_blue", PATTACH_POINT_FOLLOW, self, 2)
			local FireLight1 = ents.Create("light_dynamic")
			FireLight1:SetKeyValue("brightness", 8)
			FireLight1:SetKeyValue("distance", 300)
			FireLight1:SetLocalPos(self:GetAttachment(2).Pos)
			FireLight1:SetLocalAngles(self:GetAngles())
			FireLight1:Fire("Color", "0 161 255 255")
			FireLight1:Spawn()
			FireLight1:Activate()
			FireLight1:Fire("TurnOn")
			FireLight1:Fire("Kill", nil, 0.07)
			self:DeleteOnRemove(FireLight1)
		else
			timer.Remove("vj_timer_fire_" .. self:EntIndex())
			self.NextFireT = CurTime() +1
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "explosion" then
		local pos, ang = self:GetBonePosition(0)
		VJ.EmitSound(self, "vj_base/ambience/explosion2.wav", 100, 100)
		util.BlastDamage(self, self, pos, 200, 40)
		util.ScreenShake(pos, 100, 200, 1, 2500)
		if self.HasGibOnDeathEffects then ParticleEffect("vj_explosion2", pos, Angle(), nil) end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkAttack(isAttacking, enemy)
	if self.CarpetBombing then
		self.NextChaseTime = CurTime() +1
	end
	self.HasRangeAttack = !self.CarpetBombing
	local ent = self:GetEnemy()
	if IsValid(ent) then
		local dist = self.EnemyData.DistanceNearest
		if self:Health() <= self:GetMaxHealth() *0.5 then
			if !self.CarpetBombing && CurTime() > self.NextCarpetBombT then
				self.CarpetBombing = true
				local entPos = ent:GetPos()
				entPos.z = self:GetPos().z
				local tr = util.TraceHull({
					start = self:GetPos(),
					endpos = self:GetPos() +(entPos - self:GetPos()):GetNormalized() *7500,
					filter = self,
					mins = self:OBBMins(),
					maxs = self:OBBMaxs(),
				})
				self.CarpetBombPos = tr.HitPos +tr.HitNormal *100
				self.NextCarpetBombT = CurTime() +9999
			end
			if self.CarpetBombing then
				self:AA_MoveTo(self.CarpetBombPos, false, "Alert", {FaceDest=true, FaceDestTarget=false, IgnoreGround = true})
				local resMe = self:NearestPoint(self.CarpetBombPos)
				if resMe:Distance(self.CarpetBombPos) <= 100 then
					self:AA_StopMoving()
					self.CarpetBombing = false
					self.NextCarpetBombT = CurTime() +math.Rand(30, 60)
					return
				end
				self:SetEnemy(NULL)
				-- self:SetTurnTarget(self.CarpetBombPos)
				if CurTime() > self.NextDropCarpetT then
					local pos = {
						[1] = {SpawnPos = self:GetAttachment(3).Pos, Right=0},
						[2] = {SpawnPos = self:GetAttachment(3).Pos +self:GetRight() *50, Right=-1000},
						[3] = {SpawnPos = self:GetAttachment(3).Pos +self:GetRight() *-50, Right=1000}
					}
					for i = 1, 3 do
						local bomb = ents.Create("grenade_helicopter")
						bomb:SetPos(pos[i].SpawnPos)
						bomb:Fire("ExplodeIn", 3)
						bomb:Spawn()
						local phys = bomb:GetPhysicsObject()
						if IsValid(phys) then
							phys:SetVelocity(((self:GetPos() +Vector(0, 0, -500) +self:GetRight() *pos[i].Right) -self:GetPos()))
						end
						constraint.NoCollide(bomb, self, 0, 0)
					end
					self.NextDropCarpetT = CurTime() +0.35
				end
			end
		end
		if self.CarpetBombing then return end
		if CurTime() > self.NextBombT then
			local tr = util.TraceHull({
				start = self:GetPos(),
				endpos = (self:GetPos() +self:GetUp() *-15000),
				mins = Vector(-100, -100, -100),
				maxs = Vector(100, 100, 100),
				filter = self
			})
			if IsValid(tr.Entity) && self:Disposition(tr.Entity) == D_HT then
				local count = self:Health() <= self:GetMaxHealth() *0.5 && 3 or 1
				local pos = {
					[1] = self:GetAttachment(3).Pos,
					[2] = self:GetAttachment(3).Pos +self:GetRight() *50,
					[3] = self:GetAttachment(3).Pos +self:GetRight() *-50
				}
				for i = 1, count do
					local bomb = ents.Create("grenade_helicopter")
					bomb:SetPos(pos[i])
					bomb:Spawn()
					local offset = i > 1 && (tr.Entity:GetRight() *math.Rand(-400, 400)) or Vector()
					local phys = bomb:GetPhysicsObject()
					if IsValid(phys) then
						phys:SetVelocity(((tr.Entity:GetPos() +offset) -bomb:LocalToWorld(Vector())))
					end
					constraint.NoCollide(bomb, self, 0, 0)
				end
			end
			self.NextBombT = CurTime() +math.Rand(2, 4)
		end
		if dist <= 4000 && self:Visible(self:GetEnemy()) then
			if CurTime() > self.NextFireT then
				if !self.Charged then
					if !self.Charging then
						self.Charging = true
						VJ.EmitSound(self, "npc/attack_helicopter/aheli_charge_up.wav", 105)
						timer.Simple(SoundDuration("npc/attack_helicopter/aheli_charge_up.wav"), function()
							if IsValid(self) then
								self.Charged = true
								self.Charging = false
							end
						end)
					end
					return
				end
				self:BarrageFire()
				self.Charged = false
				self.NextFireT = CurTime() +10
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	self.ConstantlyFaceEnemy = !self.CarpetBombing
	self:SetPoseParameter("move_yaw", Lerp(FrameTime()*4, self:GetPoseParameter("move_yaw"), self:GetVelocity():GetNormal().y))

	if timer.Exists("vj_timer_fire_" .. self:EntIndex()) then
		self.FireLP:Play()
	else
		self.FireLP:Stop()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmginfo, hitgroup, status)
	if status == "Init" then
		ParticleEffectAttach("fire_large_01", PATTACH_POINT_FOLLOW, self, 8)
		ParticleEffectAttach("smoke_burning_engine_01", PATTACH_POINT_FOLLOW, self, 4)
		ParticleEffectAttach("smoke_burning_engine_01", PATTACH_POINT_FOLLOW, self, 6)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCreateDeathCorpse(dmginfo, hitgroup, corpse)
	local pos, ang = self:GetBonePosition(0)
	corpse:SetPos(pos)
	corpse:GetPhysicsObject():SetVelocity(((self:GetPos() +self:GetRight() *-700 +self:GetForward() *-300 +self:GetUp() *-200) -self:GetPos()))
	util.BlastDamage(self, self, corpse:GetPos(), 400, 40)
	util.ScreenShake(corpse:GetPos(), 100, 200, 1, 2500)

	VJ.EmitSound(self, "vj_base/ambience/explosion2.wav", 100, 100)
	VJ.EmitSound(self, "vj_base/ambience/explosion3.wav", 100, 100)
	util.BlastDamage(self, self, corpse:GetPos(), 200, 40)
	util.ScreenShake(corpse:GetPos(), 100, 200, 1, 2500)
	if self.HasGibOnDeathEffects then ParticleEffect("vj_explosion2", corpse:GetPos(), Angle(), nil) end

	if math.random(1, 3) == 1 then
		self:CreateExtraDeathCorpse("prop_ragdoll", "models/combine_soldier.mdl", {Pos = corpse:GetPos()+corpse:GetUp()*90+corpse:GetRight()*-30, Vel = Vector(math.Rand(-600, 600), math.Rand(-600, 600), 500)}, function(extraent) extraent:Ignite(math.Rand(8, 10), 0); extraent:SetColor(Color(90, 90, 90)) end)
	end

	if self.HasGibOnDeathEffects then
		ParticleEffect("vj_explosion3", corpse:GetPos(), Angle(), nil)
		ParticleEffect("vj_explosion2", corpse:GetPos() +corpse:GetForward()*-130, Angle(), nil)
		ParticleEffect("vj_explosion2", corpse:GetPos() +corpse:GetForward()*130, Angle(), nil)
		ParticleEffectAttach("fire_large_01", PATTACH_POINT_FOLLOW, corpse, 8)
		ParticleEffectAttach("smoke_burning_engine_01", PATTACH_POINT_FOLLOW, corpse, 1)

		local explosioneffect = EffectData()
		explosioneffect:SetOrigin(corpse:GetPos())
		util.Effect("VJ_Medium_Explosion1", explosioneffect)
		util.Effect("Explosion", explosioneffect)

		local dusteffect = EffectData()
		dusteffect:SetOrigin(corpse:GetPos())
		dusteffect:SetScale(800)
		util.Effect("ThumperDust", dusteffect)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	self.IdleLP:Stop()
	self.FireLP:Stop()
	timer.Remove("vj_timer_fire_" .. self:EntIndex())
end