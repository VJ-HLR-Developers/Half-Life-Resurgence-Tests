AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.VJ_ID_Boss = true
ENT.Model = "models/vj_hlr/hl2/combine_heavychopper.mdl"
ENT.StartHealth = 4000
ENT.SightAngle = 360
ENT.HullType = HULL_LARGE
ENT.TurningSpeed = 2

ENT.PoseParameterLooking_Names = {pitch={"l_aim_pitch", "r_aim_pitch"}, yaw={"l_aim_yaw", "r_aim_yaw"}, roll={}}

ENT.MovementType = VJ_MOVETYPE_AERIAL
ENT.Aerial_FlyingSpeed_Alerted = 350
ENT.Aerial_FlyingSpeed_Calm = 325
ENT.Aerial_AnimTbl_Calm = ACT_IDLE
ENT.Aerial_AnimTbl_Alerted = ACT_IDLE
ENT.AA_GroundLimit = 1200
ENT.AA_MinWanderDist = 1000
ENT.AA_MoveAccelerate = 4
ENT.AA_MoveDecelerate = 4

ENT.PoseParameterLooking_InvertPitch = true
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}

ENT.Bleeds = false
ENT.Immune_Toxic = true
ENT.Immune_Bullet = true
ENT.Immune_Fire = true

ENT.HasMeleeAttack = false

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
ENT.SoundTbl_Death = "npc/attack_helicopter/aheli_crash_alert2.wav"

ENT.AlertSoundLevel = 150
ENT.PainSoundLevel = 150
ENT.DeathSoundLevel = 150
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjVel(projectile)
	return self:CalculateProjectile("Line", self:GetAttachment(self:LookupAttachment(self.RangeUseAttachmentForPosID)).Pos, self:GetEnemy():GetPos() +self:GetEnemy():OBBCenter(), 0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(140, 140, 100), Vector(-140, -140, -75))
	self:SetPos(self:GetPos() +Vector(0, 0, 400))

	self.IdleLP = CreateSound(self, "npc/attack_helicopter/aheli_rotor_loop1.wav")
	self.IdleLP:SetSoundLevel(115)
	self.IdleLP:Play()
	self.IdleLP:ChangeVolume(1)
	self.IdleLP:ChangePitch(72)

	self.FireLP = CreateSound(self, "weapons/airboat/airboat_gun_loop2.wav")
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
function ENT:CreateFakeBullet(att)
	local startPos = self:GetAttachment(self:LookupAttachment(att)).Pos

	local FakeSpawn = ents.Create("prop_vj_animatable")
	FakeSpawn:SetPos(startPos)
	FakeSpawn:SetParent(self)
	FakeSpawn:Spawn()
	FakeSpawn:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	FakeSpawn:SetNoDraw(true)
	FakeSpawn:DrawShadow(false)
	self:DeleteOnRemove(FakeSpawn)

	return FakeSpawn
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FireBullet()
	local spread = 60
	sound.EmitHint(SOUND_DANGER, self:GetEnemy():GetPos(), 250, 0.25, self)
	for i = 1, 3 do
		if !IsValid(self:GetEnemy()) then return end
		local ent = self:CreateFakeBullet("Muzzle1")
		VJ.EmitSound(ent, {"weapons/airboat/airboat_gun_energy1.wav", "weapons/airboat/airboat_gun_energy2.wav"}, 95)

		local startpos = self:GetAttachment(self:LookupAttachment("Muzzle1")).Pos
		local bulletPos = ent:GetPos()
		local bullet = {}
		bullet.Num = 1
		bullet.Src = bulletPos
		bullet.Dir = (self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter()) -startpos
		bullet.Spread = Vector(math.random(-spread, spread), math.random(-spread, spread), 0)
		bullet.Tracer = 1
		bullet.TracerName = "AirboatGunTracer"
		bullet.Force = 5
		bullet.Damage = self:ScaleByDifficulty(7)
		bullet.AmmoType = "AR2"
		bullet.IgnoreEntity = ent
		bullet.Attacker = self
		bullet.Callback = function(attacker, tr, dmginfo)
			local laserhit = EffectData()
			laserhit:SetOrigin(tr.HitPos)
			laserhit:SetNormal(tr.HitNormal)
			laserhit:SetScale(25)
			util.Effect("AR2Impact", laserhit)
			dmginfo:SetAttacker(self)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageType(bit.bor(2, 4098, 2147483648))

			util.ScreenShake(tr.HitPos, 16, 100, 0.5, 175)
			sound.Play("weapons/fx/nearmiss/bulletltor0" .. math.random(3, 9) .. ".wav", tr.HitPos +tr.HitNormal *60, 60, 100, 1)
			if tr.MatType && VJ.HasValue({MAT_METAL, MAT_GRATE, MAT_CONCRETE, MAT_COMPUTER, MAT_VENT}, tr.MatType) then
				sound.Play("weapons/fx/rics/ric" .. math.random(1, 5) .. ".wav", tr.HitPos, 65, 100, 1)
			end
		end
		ent:FireBullets(bullet)
		SafeRemoveEntity(ent)

		local ent = self:CreateFakeBullet("Muzzle2")
		VJ.EmitSound(ent, {"weapons/airboat/airboat_gun_energy1.wav", "weapons/airboat/airboat_gun_energy2.wav"}, 95)

		local startposB = self:GetAttachment(self:LookupAttachment("Muzzle2")).Pos
		local bulletPos = ent:GetPos()
		local bullet = {}
		bullet.Num = 1
		bullet.Src = bulletPos
		bullet.Dir = (self:GetEnemy():GetPos()+self:GetEnemy():OBBCenter()) -startposB
		bullet.Spread = Vector(math.random(-spread, spread), math.random(-spread, spread), 0)
		bullet.Tracer = 1
		bullet.TracerName = "AirboatGunTracer"
		bullet.Force = 5
		bullet.Damage = self:ScaleByDifficulty(7)
		bullet.AmmoType = "AR2"
		bullet.IgnoreEntity = ent
		bullet.Attacker = self
		bullet.Callback = function(attacker, tr, dmginfo)
			local laserhit = EffectData()
			laserhit:SetOrigin(tr.HitPos)
			laserhit:SetNormal(tr.HitNormal)
			laserhit:SetScale(25)
			util.Effect("AR2Impact", laserhit)
			dmginfo:SetDamageType(bit.bor(2, 4098, 2147483648))
			dmginfo:SetAttacker(self)
			dmginfo:SetInflictor(self)

			util.ScreenShake(tr.HitPos, 16, 100, 0.5, 175)
			sound.Play("weapons/fx/nearmiss/bulletltor0" .. math.random(3, 9) .. ".wav", tr.HitPos +tr.HitNormal *60, 60, 100, 1)
			if tr.MatType && VJ.HasValue({MAT_METAL, MAT_GRATE, MAT_CONCRETE, MAT_COMPUTER, MAT_VENT}, tr.MatType) then
				sound.Play("weapons/fx/rics/ric" .. math.random(1, 5) .. ".wav", tr.HitPos, 65, 100, 1)
			end
		end
		ent:FireBullets(bullet)
		SafeRemoveEntity(ent)

		ParticleEffect("vj_rifle_full_blue", startpos, self:GetAngles(), self)
		ParticleEffect("vj_rifle_full_blue", startposB, self:GetAngles(), self)

		local FireLight1 = ents.Create("light_dynamic")
		FireLight1:SetKeyValue("brightness", "4")
		FireLight1:SetKeyValue("distance", "120")
		FireLight1:SetPos(startpos)
		FireLight1:SetLocalAngles(self:GetAngles())
		FireLight1:Fire("Color", "0 161 255 255")
		FireLight1:SetParent(self)
		FireLight1:Spawn()
		FireLight1:Activate()
		FireLight1:Fire("TurnOn")
		FireLight1:Fire("Kill", nil, 0.07)
		self:DeleteOnRemove(FireLight1)

		local FireLight1 = ents.Create("light_dynamic")
		FireLight1:SetKeyValue("brightness", "4")
		FireLight1:SetKeyValue("distance", "120")
		FireLight1:SetPos(startposB)
		FireLight1:SetLocalAngles(self:GetAngles())
		FireLight1:Fire("Color", "0 161 255 255")
		FireLight1:SetParent(self)
		FireLight1:Spawn()
		FireLight1:Activate()
		FireLight1:Fire("TurnOn")
		FireLight1:Fire("Kill", nil, 0.07)
		self:DeleteOnRemove(FireLight1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BarrageFire()
	timer.Create("vj_timer_fire_" .. self:EntIndex(), 0.1, 150, function()
		if IsValid(self:GetEnemy()) && !self.Dead then
			self:FireBullet()
		else
			timer.Remove("vj_timer_fire_" .. self:EntIndex())
			self.NextFireT = CurTime() +1
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkAttack(isAttacking, enemy)
	if IsValid(self:GetEnemy()) then
		local dist = self.EnemyData.DistanceNearest
		if CurTime() > self.NextBombT then
			local tr = util.TraceHull({
				start = self:GetPos(),
				endpos = (self:GetPos() +self:GetUp() *-15000),
				mins = self:OBBMins(),
				maxs = self:OBBMaxs(),
				filter = self
			})
			if IsValid(tr.Entity) && self:Disposition(tr.Entity) == D_HT then
				local bomb = ents.Create("combine_mine")
				bomb:SetPos(self:GetAttachment(5).Pos)
				bomb:Spawn()
				local phys = bomb:GetPhysicsObject()
				if IsValid(phys) then
					phys:SetVelocity(((tr.Entity:GetPos() +(tr.Entity:GetRight() *math.Rand(-400, 400))) -bomb:LocalToWorld(Vector())))
				end
				constraint.NoCollide(bomb, self, 0, 0)
				self.NextBombT = CurTime() +math.Rand(2, 4)
			elseif !IsValid(tr.Entity) then
				if dist <= 2300 && math.random(1, 150) == 1 then
					local bomb = ents.Create("npc_rollermine")
					bomb:SetPos(self:GetAttachment(5).Pos)
					bomb:Spawn()
					constraint.NoCollide(bomb, self, 0, 0)
					self.NextBombT = CurTime() +math.Rand(8, 14)
				end
			end
		end
		if dist <= 4000 && self:Visible(self:GetEnemy()) then
			if CurTime() > self.NextFireT then
				if !self.Charged then
					if !self.Charging then
						self.Charging = true
						VJ.EmitSound(self, "weapons/cguard/charging.wav", 105, 85)
						local dur = SoundDuration("weapons/cguard/charging.wav")
						timer.Simple(dur +(dur *0.85), function()
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
				self.NextFireT = CurTime() +20
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	local velNorm = self:GetVelocity():GetNormalized()
	local speed = FrameTime()*4
	self:SetPoseParameter("tilt_x", Lerp(speed, self:GetPoseParameter("tilt_x"), velNorm.x))
	self:SetPoseParameter("tilt_y", Lerp(speed, self:GetPoseParameter("tilt_y"), velNorm.y))

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