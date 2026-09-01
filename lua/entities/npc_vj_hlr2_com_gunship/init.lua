AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/combine_gunship.mdl"
ENT.StartHealth = 1000
ENT.Aerial_FlyingSpeed_Calm = 520
ENT.Aerial_FlyingSpeed_Alerted = 600
ENT.Aerial_AnimTbl_Calm = ACT_IDLE
ENT.Aerial_AnimTbl_Alerted = ACT_IDLE

ENT.PoseParameterLooking_InvertPitch = false
ENT.PoseParameterLooking_InvertYaw = false
ENT.PoseParameterLooking_Names = {pitch={"flex_vert"}, yaw={"flex_herz"}, roll={"fin_accel"}}

ENT.HasRangeAttack = false

ENT.HasDeathAnimation = false
ENT.HasDeathCorpse = false

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "Chopper.Blade_Hull",
	FirstP_Offset = Vector(140, 0, -45),
}

ENT.SoundTbl_Idle = {"npc/combine_gunship/ping_patrol.wav", "npc/combine_gunship/ping_search.wav", "npc/combine_gunship/gunship_ping_search.wav"}
ENT.SoundTbl_Alert = {"npc/combine_gunship/gunship_moan.wav", "npc/combine_gunship/see_enemy.wav"}
ENT.SoundTbl_Pain = "npc/combine_gunship/gunship_pain.wav"
ENT.SoundTbl_Death = "npc/combine_gunship/gunship_explode2.wav"

ENT.AlertSoundLevel = 150
ENT.PainSoundLevel = 150
ENT.DeathSoundLevel = 150
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(140, 140, 100), Vector(-140, -140, -75))
	self:SetPos(self:GetPos() +Vector(0, 0, 400))

	self.IdleLP1 = CreateSound(self, "npc/combine_gunship/gunship_engine_loop3.wav")
	self.IdleLP1:SetSoundLevel(105)
	self.IdleLP1:Play()
	self.IdleLP1:ChangeVolume(1)

	self.IdleLP2 = CreateSound(self, "npc/combine_gunship/engine_rotor_loop1.wav")
	self.IdleLP2:SetSoundLevel(110)
	self.IdleLP2:Play()
	self.IdleLP2:ChangeVolume(1)

	self.IdleLP3 = CreateSound(self, "npc/combine_gunship/engine_whine_loop1.wav")
	self.IdleLP3:SetSoundLevel(105)
	self.IdleLP3:Play()
	self.IdleLP3:ChangeVolume(1)

	self.FireLP = CreateSound(self, "npc/combine_gunship/gunship_weapon_fire_loop6.wav")
	self.FireLP:SetSoundLevel(120)
	self.FireLP:ChangeVolume(1)

	self.NextFireT = 0
	self.NextBombT = 0
	self.CarpetBombing = false

	self.PP_Vert = 0
	self.PP_Horz = 0
	self.PP_Accel = 0

	self:CreateBoneFollowers()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BarrageFire()
	local i = 0
	timer.Create("vj_timer_fire_" .. self:EntIndex(), 0.1, 20, function()
		if IsValid(self:GetEnemy()) && !self.Dead then
			i = i +1
			local att = self:GetAttachment(1)
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

			ParticleEffectAttach("vj_rifle_full_blue", PATTACH_POINT_FOLLOW, self, 1)
			local FireLight1 = ents.Create("light_dynamic")
			FireLight1:SetKeyValue("brightness", 8)
			FireLight1:SetKeyValue("distance", 300)
			FireLight1:SetLocalPos(self:GetAttachment(1).Pos)
			FireLight1:SetLocalAngles(self:GetAngles())
			FireLight1:Fire("Color", "0 161 255 255")
			FireLight1:Spawn()
			FireLight1:Activate()
			FireLight1:Fire("TurnOn")
			FireLight1:Fire("Kill", nil, 0.07)
			self:DeleteOnRemove(FireLight1)
			if i == 20 then
				VJ.CreateSound(self, "npc/combine_gunship/attack_stop2.wav", 100)
				self:PlayAnim(ACT_VM_RELOAD, false, false, false)
			end
		else
			timer.Remove("vj_timer_fire_" .. self:EntIndex())
			self.NextFireT = CurTime() +1
			VJ.CreateSound(self, "npc/combine_gunship/attack_stop2.wav", 100)
			self:PlayAnim(ACT_VM_RELOAD, false, false, false)
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkAttack(isAttacking, enemy)
	local dist = self.EnemyData.DistanceNearest
	if dist <= 4000 && self:Visible(self:GetEnemy()) && CurTime() > self.NextFireT then
		self:BarrageFire()
		VJ.CreateSound(self, "npc/combine_gunship/attack_start2.wav", 100)
		self.NextFireT = CurTime() +8
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:BellyCannon(ent)
	self:StartWarpCannon()
end

ENT.ConstantlyFaceEnemy = true
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	if self.CarpetBombing && CurTime() > self.NextBombT then
		if !IsValid(self:GetEnemy()) then
			self.CarpetBombing = false
			return
		end
		local dest = self:GetEnemy():GetPos() +Vector(0, 0, 1200)
		-- if CurTime() > self.AA_CurrentMoveTime then
			self:AA_MoveTo(dest, true, "Calm", {FaceDest=true, IgnoreGround = true})
		-- end
		if self:GetPos():Distance(dest) <= 100 then
			self:BellyCannon()
			self.NextBombT = CurTime() +math.Rand(10, 15)
		end
		return
	end

	if !IsValid(self:GetEnemy()) then
		local gesture = self:AddGestureSequence(self:LookupSequence("scanning"))
		self:SetLayerPriority(gesture, 1)
		self:SetLayerPlaybackRate(gesture, 0.5)
	elseif IsValid(self:GetEnemy()) then
		if CurTime() > self.NextBombT && !self.CarpetBombing then
			-- local tr = util.TraceHull({
				-- start = self:GetPos(),
				-- endpos = (self:GetPos() +self:GetUp() *-15000),
				-- mins = self:OBBMins(),
				-- maxs = self:OBBMaxs(),
				-- filter = {self}
			-- })
			-- if IsValid(tr.Entity) && self:Disposition(tr.Entity) == D_HT then
			if math.random(1, 80) == 1 then
				self.CarpetBombing = true
			end
				-- self:BellyCannon()
			-- end
			-- self.NextBombT = CurTime() +math.Rand(7, 12)
		end
	end

	local speed = 3
	-- if self.AA_CurrentMoveTime > CurTime() then
		-- local remaining = self.AA_CurrentMoveTime -CurTime()
		-- speed = math.Clamp(remaining, 0, 6)
		-- if remaining < 2.65 then
			-- self.PP_Vert = 0
			-- self.PP_Horz = 0
			-- self.PP_Accel = 0
			-- return
		-- end
		-- self.PP_Vert = self:MovingUp() && 35 or self:MovingDown() && -35 or self.PP_Vert +math.Rand(-5, 5)
		-- self.PP_Horz = self:MovingLeft() && -35 or self:MovingRight() && 35 or self.PP_Horz +math.Rand(-5, 5)
		-- self.PP_Accel = self:MovingForward() && 1 or self:MovingBackward() && -1 or self.PP_Accel +math.Rand(-0.1, 0.1)
	-- else
		-- self.PP_Vert = math.Clamp(self.PP_Vert +math.Rand(-5, 5), -12, 12)
		-- self.PP_Horz = math.Clamp(self.PP_Horz +math.Rand(-5, 5), -12, 12)
		-- self.PP_Accel = self.PP_Accel +math.Rand(-0.1, 0.1)
	-- end

	-- self:SetPoseParameter("flex_vert", Lerp(FrameTime() *speed, self:GetPoseParameter("flex_vert"), self.PP_Vert))
	-- self:SetPoseParameter("flex_horz", Lerp(FrameTime() *speed, self:GetPoseParameter("flex_horz"), self.PP_Horz))
	-- self:SetPoseParameter("fin_accel", Lerp(FrameTime() *speed, self:GetPoseParameter("fin_accel"), self.PP_Accel))

	local x, y, z = self:GetVelocity():GetNormalized().x *35, self:GetVelocity():GetNormalized().y *35, self:GetVelocity():GetNormalized().z *35
	self:SetPoseParameter("flex_vert", Lerp(FrameTime() *speed, self:GetPoseParameter("flex_vert"), x))
	self:SetPoseParameter("flex_horz", Lerp(FrameTime() *speed, self:GetPoseParameter("flex_horz"), y))
	self:SetPoseParameter("fin_accel", Lerp(FrameTime() *speed, self:GetPoseParameter("fin_accel"), z))

	if timer.Exists("vj_timer_fire_" .. self:EntIndex()) then
		self.FireLP:Play()
	else
		self.FireLP:Stop()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmginfo, hitgroup, status)
	if status == "Init" then
		local deathCorpse = ents.Create("prop_vj_animatable")
		deathCorpse:SetModel(self:GetModel())
		deathCorpse:SetPos(self:GetPos())
		deathCorpse:SetAngles(self:GetAngles())
		deathCorpse:SetSkin(self:GetModel() == "models/vj_hlr/hl1/osprey_blkops.mdl" and 1 or 0)
		function deathCorpse:Initialize()
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
			self:SetCollisionGroup(COLLISION_GROUP_NONE)
			self:SetSolid(SOLID_CUSTOM)
			local phys = self:GetPhysicsObject()
			if IsValid(phys) then
				phys:Wake()
				phys:EnableGravity(true)
				phys:SetBuoyancyRatio(0)
				phys:SetVelocity(self:GetVelocity())
			end
		end
		deathCorpse.NextExpT = 0
		deathCorpse:Spawn()
		deathCorpse:Activate()
		local phys = deathCorpse:GetPhysicsObject()
		phys:SetVelocity(self:GetVelocity() +self:GetForward() *math.random(900, 1500))

		ParticleEffectAttach("smoke_burning_engine_01", PATTACH_POINT_FOLLOW, deathCorpse, 5)

		local function Explode(ent, pos)
			VJ.EmitSound(ent, "vj_base/ambience/explosion2.wav", 100, 100)
			util.BlastDamage(ent, ent, pos, 200, 40)
			util.ScreenShake(pos, 100, 200, 1, 2500)
			ParticleEffect("vj_explosion2", pos, Angle(), nil)
			if math.random(1, 4) == 1 && ent:GetClass() != "prop_ragdoll" then VJ.CreateSound(ent, "npc/combine_gunship/gunship_pain.wav", 90, math.random(95, 110)) end
		end

		function deathCorpse:Think()
			if CurTime() > self.NextExpT && math.random(1, 3) == 1 then
				self.NextExpT = CurTime() + math.Rand(0.2, 0.5)
				local expPos = self:GetPos() + Vector(math.Rand(-150, 150), math.Rand(-150, 150), math.Rand(-150, -50))
				Explode(deathCorpse, expPos)
			end

			self:NextThink(CurTime())
			return true
		end

		function deathCorpse:PhysicsCollide(data, phys)
			if self.Dead then return end
			if data.HitEntity.IsVJBaseCorpse_Gib then return end
			self.Dead = true

			util.BlastDamage(self, self, self:GetPos() +self:OBBCenter(), 600, 200)

			self.Corpse = ents.Create("prop_ragdoll")
			self.Corpse:SetModel(self:GetModel())
			self.Corpse:SetPos(self:GetPos())
			self.Corpse:SetAngles(self:GetAngles())
			self.Corpse:Spawn()
			self.Corpse:Activate()
			self.Corpse:SetColor(self:GetColor())
			self.Corpse:SetMaterial(self:GetMaterial())
			self.Corpse:SetSkin(1)
			if self.DeathCorpseSubMaterials then
				for _, x in ipairs(self.DeathCorpseSubMaterials) do
					if self:GetSubMaterial(x) != "" then
						self.Corpse:SetSubMaterial(x, self:GetSubMaterial(x))
					end
				end
			end
			self.Corpse.IsVJBaseCorpse = true
			self.Corpse.ChildEnts = self.DeathCorpse_ChildEnts or {}
			if GetConVar("ai_serverragdolls"):GetInt() == 1 then
				undo.ReplaceEntity(self, self.Corpse)
			else
				VJ.Corpse_Add(self.Corpse)
				if GetConVar("vj_npc_corpse_undo"):GetInt() == 1 then undo.ReplaceEntity(self, self.Corpse) end -- Undoable
			end
			cleanup.ReplaceEntity(self, self.Corpse)
			for boneLimit = 0, self.Corpse:GetPhysicsObjectCount() - 1 do -- 128 = Bone Limit
				local childphys = self.Corpse:GetPhysicsObjectNum(boneLimit)
				if IsValid(childphys) then
					local childphys_bonepos, childphys_boneang = self:GetBonePosition(self.Corpse:TranslatePhysBoneToBone(boneLimit))
					if (childphys_bonepos) then
						childphys:SetAngles(childphys_boneang)
						childphys:SetPos(childphys_bonepos)
					end
				end
			end
			self.Corpse:Fire("FadeAndRemove", nil, 360)
			self.Corpse:CallOnRemove("vj_" .. self.Corpse:EntIndex(), function(ent, exttbl)
				if !exttbl then return end
				for _, v in ipairs(exttbl) do
					if IsValid(v) then
						if v:GetClass() == "prop_ragdoll" then v:Fire("FadeAndRemove", nil, 0) else v:Fire("kill", nil, 0) end
					end
				end
			end, self.Corpse.ChildEnts)
			hook.Call("CreateEntityRagdoll", nil, self, self.Corpse)
			ParticleEffectAttach("smoke_burning_engine_01", PATTACH_POINT_FOLLOW, self.Corpse, 2)
			ParticleEffectAttach("smoke_burning_engine_01", PATTACH_POINT_FOLLOW, self.Corpse, 4)

			local phys = self.Corpse:GetPhysicsObject()
			phys:SetVelocity(self:GetVelocity() +self:GetForward() *math.random(1400, 1750))

			local corpse = self.Corpse
			for i = 1, 6 do
				timer.Simple(i *math.Rand(0.25, 0.45), function()
					if IsValid(corpse) && math.random(1, 2) == 1 then
						local expPos = corpse:GetPos() + Vector(math.Rand(-150, 150), math.Rand(-150, 150), math.Rand(-150, -50))
						Explode(corpse, expPos)
					end
				end)
			end

			self:Remove()
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DoTrace()
	local tracedata = {}
	tracedata.start = self:GetAttachment(self:LookupAttachment("bellygun")).Pos
	tracedata.endpos = self:GetAttachment(self:LookupAttachment("bellygun")).Pos +Vector(0, 0, -999999)
	tracedata.filter = {self}
	return util.TraceLine(tracedata).HitPos
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:WarpCannon()
	local attackpos = self:DoTrace()

	local beam = EffectData()
	beam:SetStart(self:GetAttachment(2).Pos)
	beam:SetOrigin(attackpos)
	beam:SetEntity(self)
	beam:SetAttachment(2)
	util.Effect("VJ_HLR_StriderBeam", beam)

	local hitTime = 1 /math.min(1, self:GetAttachment(2).Pos:Distance(attackpos) /10000)
	hitTime = math.Clamp(hitTime, 0, 1) ^0.5
	timer.Simple(hitTime, function()
		if IsValid(self) then
			VJ.ApplyRadiusDamage(self, self, attackpos, 300, 500, bit.bor(DMG_DISSOLVE, DMG_BLAST), true, false, {Force=175})
			local FireLight1 = ents.Create("light_dynamic")
			FireLight1:SetKeyValue("brightness", "8")
			FireLight1:SetKeyValue("distance", "300")
			FireLight1:SetPos(self:GetAttachment(self:LookupAttachment("bellygun")).Pos)
			FireLight1:SetLocalAngles(self:GetAngles())
			FireLight1:Fire("Color", "0 31 225")
			FireLight1:SetParent(self)
			FireLight1:Spawn()
			FireLight1:Activate()
			FireLight1:Fire("TurnOn")
			FireLight1:Fire("Kill", nil, 0.1)
			self:DeleteOnRemove(FireLight1)
		end
	end)
	timer.Simple(0.5, function()
		if IsValid(self) then
			VJ.EmitSound(self, "npc/strider/fire.wav", 130, math.random(100, 110))
			self.CarpetBombing = false

			ParticleEffectAttach("vj_rifle_full_blue", PATTACH_POINT_FOLLOW, self, 2)
			timer.Simple(0.2, function() if IsValid(self) then self:StopParticles() end end)
			local FireLight1 = ents.Create("light_dynamic")
			FireLight1:SetKeyValue("brightness", "4")
			FireLight1:SetKeyValue("distance", "120")
			FireLight1:SetPos(self:GetAttachment(self:LookupAttachment("bellygun")).Pos)
			FireLight1:SetLocalAngles(self:GetAngles())
			FireLight1:Fire("Color", "0 31 225")
			FireLight1:SetParent(self)
			FireLight1:Spawn()
			FireLight1:Activate()
			FireLight1:Fire("TurnOn")
			FireLight1:Fire("Kill", nil, 0.07)
			self:DeleteOnRemove(FireLight1)
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:StartWarpCannon()
	VJ.CreateSound(self, "npc/strider/charging.wav", 110)

	local muz = ents.Create("env_sprite")
	muz:SetKeyValue("model", "effects/strider_bulge_dx60.vmt")
	muz:SetKeyValue("scale", tostring(math.Rand(1, 1.5)))
	muz:SetKeyValue("GlowProxySize", "2.0") -- Size of the glow to be rendered for visibility testing.
	muz:SetKeyValue("HDRColorScale", "1.0")
	muz:SetKeyValue("renderfx", "14")
	muz:SetKeyValue("rendermode", "3") -- Set the render mode to "3" (Glow)
	muz:SetKeyValue("renderamt", "255") -- Transparency
	muz:SetKeyValue("disablereceiveshadows", "0") -- Disable receiving shadows
	muz:SetKeyValue("framerate", "10.0") -- Rate at which the sprite should animate, if at all.
	muz:SetKeyValue("spawnflags", "0")
	muz:SetParent(self)
	muz:Fire("SetParentAttachment", "bellygun")
	muz:SetAngles(Angle(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)))
	muz:Spawn()
	muz:Activate()
	muz:Fire("Kill", nil, SoundDuration("npc/strider/charging.wav") +0.3)

	local pinch = ents.Create("env_sprite")
	pinch:SetKeyValue("model", "effects/strider_pinch_dudv.vmt")
	pinch:SetKeyValue("scale", tostring(math.Rand(0.2, 0.4)))
	pinch:SetKeyValue("GlowProxySize", "2.0") -- Size of the glow to be rendered for visibility testing.
	pinch:SetKeyValue("HDRColorScale", "1.0")
	pinch:SetKeyValue("renderfx", "14")
	pinch:SetKeyValue("rendermode", "3") -- Set the render mode to "3" (Glow)
	pinch:SetKeyValue("renderamt", "255") -- Transparency
	pinch:SetKeyValue("disablereceiveshadows", "0") -- Disable receiving shadows
	pinch:SetKeyValue("framerate", "10.0") -- Rate at which the sprite should animate, if at all.
	pinch:SetKeyValue("spawnflags", "0")
	pinch:SetParent(self)
	pinch:Fire("SetParentAttachment", "bellygun")
	pinch:SetAngles(Angle(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)))
	pinch:Spawn()
	pinch:Activate()
	pinch:Fire("Kill", nil, SoundDuration("npc/strider/charging.wav") +1)

	timer.Simple(SoundDuration("npc/strider/charging.wav"), function()
		if IsValid(self) then
			self:WarpCannon()
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	self.IdleLP1:Stop()
	self.IdleLP2:Stop()
	self.IdleLP3:Stop()
	self.FireLP:Stop()
	timer.Remove("vj_timer_fire_" .. self:EntIndex())
end