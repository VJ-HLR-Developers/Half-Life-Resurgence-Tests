AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/manhack.mdl"
ENT.StartHealth = 25
ENT.HullType = HULL_TINY
ENT.MovementType = VJ_MOVETYPE_AERIAL
ENT.AA_MoveAccelerate = 3
ENT.AA_MoveDecelerate = 7
ENT.AA_GroundLimit = 300
ENT.Aerial_FlyingSpeed_Calm = 350
ENT.Aerial_FlyingSpeed_Alerted = 600
ENT.TurningUseAllAxis = true

ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.Bleeds = false

ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = false
ENT.MeleeAttackDistance = 1
ENT.MeleeAttackDamageDistance = 0
ENT.TimeUntilMeleeAttackDamage = 1
ENT.NextAnyAttackTime_Melee = 0.8
ENT.MeleeAttackDamage = 0

ENT.HasExtraMeleeAttackSounds = true

ENT.SoundTbl_MeleeAttackExtra = {
	"npc/manhack/grind_flesh1.wav",
	"npc/manhack/grind_flesh2.wav",
	"npc/manhack/grind_flesh3.wav"
}
ENT.SoundTbl_Pain = "npc/manhack/bat_away.wav"
ENT.SoundTbl_Death = "npc/manhack/gib.wav"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	timer.Simple(0, function()
		if IsValid(self:GetOwner()) then
			self:PlayAnim("Deploy", true, false, true)
			self:SetVelocity(self:GetUp() *100)
		else
			self:SetPos(self:GetPos() +self:GetUp() *45)
		end
	end)

	self.AnimationTranslations[ACT_IDLE] = ACT_FLY
	self.AnimationTranslations[ACT_MELEE_ATTACK1] = ACT_FLY
	self.AnimationTranslations[ACT_INVALID] = ACT_FLY
	self.AnimationTranslations[ACT_WALK] = ACT_FLY
	self.AnimationTranslations[ACT_RUN] = ACT_FLY

	self.IdleLoop1 = CreateSound(self, "npc/manhack/mh_engine_loop1.wav")
	self.IdleLoop2 = CreateSound(self, "npc/manhack/mh_engine_loop2.wav")
	self.BladeLoop = CreateSound(self, "npc/manhack/mh_blade_loop1.wav")
	self.IdleLoop1:SetSoundLevel(65)
	self.IdleLoop2:SetSoundLevel(65)
	self.BladeLoop:SetSoundLevel(55)
	self.IdleLoop1:Play()
	self.IdleLoop2:Play()
	self.BladeLoop:Play()

	self.Panels = 0
	self.Manhack_HasHit = false
	self.Manhack_HitID = 0

	local spr = ents.Create("env_sprite")
	spr:SetKeyValue("model", "sprites/glow1.vmt")
	spr:SetKeyValue("scale", "0.6")
	spr:SetKeyValue("rendermode", "9")
	spr:SetKeyValue("renderfx", "14")
	spr:SetKeyValue("rendercolor", "255 0 0")
	spr:SetKeyValue("renderamt", "192")
	spr:SetParent(self)
	spr:Fire("SetParentAttachment", "light")
	spr:Spawn()
	spr:Activate()
	self:DeleteOnRemove(spr)

	local envLight = ents.Create("env_projectedtexture")
	envLight:SetLocalPos(self:GetPos())
	envLight:SetLocalAngles(self:GetAngles())
	envLight:SetKeyValue("lightcolor", "255 0 0")
	envLight:SetKeyValue("lightfov", "25")
	envLight:SetKeyValue("farz", "378")
	envLight:SetKeyValue("nearz", "10")
	envLight:SetKeyValue("shadowquality", "1")
	envLight:Input("SpotlightTexture", NULL, NULL, "effects/flashlight001")
	envLight:SetOwner(self)
	envLight:SetParent(self)
	envLight:Spawn()
	envLight:Fire("setparentattachment", "light")
	self:DeleteOnRemove(envLight)

	local spotlight = ents.Create("beam_spotlight")
	spotlight:SetPos(self:GetPos())
	spotlight:SetAngles(self:GetAngles())
	spotlight:SetKeyValue("spotlightlength", 90)
	spotlight:SetKeyValue("spotlightwidth", 30)
	spotlight:SetKeyValue("spawnflags", "2")
	spotlight:Fire("Color", "255 0 0")
	spotlight:SetParent(self)
	spotlight:Spawn()
	spotlight:Activate()
	spotlight:Fire("setparentattachment", "light")
	spotlight:Fire("lighton")
	spotlight:AddEffects(EF_PARENT_ANIMATES)
	self:DeleteOnRemove(spotlight)

	local light = ents.Create("light_dynamic")
	light:SetKeyValue("brightness", "2")
	light:SetKeyValue("distance", "100")
	light:SetLocalPos(Vector())
	light:SetLocalAngles(Angle())
	light:Fire("Color", "255 0 0")
	light:SetParent(self)
	light:Spawn()
	light:Activate()
	light:Fire("TurnOn")
	light:Fire("SetParentAttachment", "light")
	self:DeleteOnRemove(light)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:TranslateActivity(act)
	if act == ACT_IDLE then
		return ACT_FLY
	end
	local translation = self.AnimationTranslations[act]
	if translation then
		if istable(translation) then
			if act == ACT_IDLE then
				return self:ResolveAnimation(translation)
			end
			return translation[math.random(1, #translation)] or act
		else
			return translation
		end
	end
	return act
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Manhack_Displacement(angForce, velForce, velTime, ent)
	if !self.Manhack_HasHit then
		if angForce == nil then angForce = 35 end
		if velForce == nil then velForce = 250 end
		if velTime == nil then velTime = math.Rand(0.8, 1.35) end
		self.Manhack_HasHit = true
		self.Manhack_HitID = self.Manhack_HitID +1
		self.DisableChasingEnemy = true
		self.DisableWandering = true
		self:SetMaxYawSpeed(0)
		if ent then
			if ent == Entity(0) then
				local tr = util.TraceLine({
					start = self:GetPos(),
					endpos = self:GetPos() +self:GetForward() *512,
					filter = self
				})
				self:SetAngles(self:GetTurnAngle(tr.HitNormal:Angle()))
			else
				self:SetAngles(-self:GetTurnAngle(((self:GetPos() +self:OBBCenter()) -(ent:GetPos() +ent:OBBCenter())):Angle()))
			end
		else
			self:SetAngles(self:GetAngles() + Angle(math.random(-angForce, angForce), math.random(-angForce, angForce), math.random(-angForce, angForce)))
		end
		self:SetVelocity(self:GetForward() *-velForce +self:GetRight() *math.random(-velForce *0.6, velForce *0.6) +self:GetUp() *math.random(-velForce *0.2, velForce *0.2))

		local id = self.Manhack_HitID
		timer.Simple(velTime, function()
			if IsValid(self) && self.Manhack_HitID == id then
				self:SetMaxYawSpeed(self.TurningSpeed)
				self.DisableChasingEnemy = false
				self.DisableWandering = false
				self.Manhack_HasHit = false
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	local dist = self.EnemyData.DistanceNearest
	if dist then
		self.Panels = Lerp(FrameTime() *10, self.Panels, (dist <= 275 && IsValid(self:GetEnemy())) && 100 or 0)
		if self.Panels >= 25 then
			if !self.BladeLoop:IsPlaying() then
				VJ.CreateSound(self, "npc/manhack/mh_blade_snick1.wav", 60)
			end
			self.BladeLoop:Play()
		else
			self.BladeLoop:Stop()
		end
		self:SetPoseParameter("Panel1", (self.Panels /100) *90)
		self:SetPoseParameter("Panel2", (self.Panels /100) *90)
		self:SetPoseParameter("Panel3", (self.Panels /100) *90)
		self:SetPoseParameter("Panel4", (self.Panels /100) *90)
		self:SetPoseParameter("PincerTop", (self.Panels /100) *45)
		self:SetPoseParameter("PincerBottom", (self.Panels /100) *45)

		local pitch = math.Clamp(self:GetVelocity():Length() /self.Aerial_FlyingSpeed_Calm, 0.85, 1.5) *100
		if !self.Manhack_HasHit && self:GetActivity() == ACT_FLY && IsValid(self:GetEnemy()) && dist <= 275 && dist > 1 then
			self:SetVelocity(self:GetForward() *200)
			pitch = 150
		end
		self.IdleLoop1:ChangePitch(pitch)
		self.IdleLoop2:ChangePitch(pitch)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTouch(ent)
	if !self.BladeLoop:IsPlaying() then return end
	if !ent:IsNPC() && !ent:IsPlayer() && !ent:IsNextBot() then
		VJ.EmitSound(self, "npc/manhack/grind" .. math.random(1, 5) .. ".wav", 75)
		self:SetMaxYawSpeed(self.TurningSpeed)
		self.DisableChasingEnemy = false
		self.DisableWandering = false
		self.Manhack_HasHit = false
		if ent.TakeDamageInfo then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(10)
			dmginfo:SetDamageType(DMG_SLASH)
			dmginfo:SetAttacker(self)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamagePosition(self:GetPos())
			ent:TakeDamageInfo(dmginfo)
		end
		local effectData = EffectData()
		effectData:SetOrigin(self:GetPos())
		effectData:SetNormal((self:GetPos() -ent:GetPos()):GetNormal())
		effectData:SetMagnitude(3)
		effectData:SetScale(1)
		util.Effect("ElectricSpark", effectData)
		self:Manhack_Displacement(125, nil, nil, ent)
	else
		VJ.EmitSound(self, "npc/manhack/grind_flesh" .. math.random(1, 3) .. ".wav", 75)
		if self:CheckRelationship(ent) == D_HT then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(5)
			dmginfo:SetDamageType(DMG_SLASH)
			dmginfo:SetAttacker(self)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamagePosition(self:GetPos())
			ent:TakeDamageInfo(dmginfo)
			self:Manhack_Displacement(65, nil, nil, ent)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "PostDamage" then
		-- self:Manhack_Displacement(100, nil, nil, dmginfo:GetInflictor() or dmginfo:GetAttacker())
		local attacker = dmginfo:GetInflictor() or dmginfo:GetAttacker()
		local effectData = EffectData()
		effectData:SetOrigin(dmginfo:GetDamagePosition())
		effectData:SetNormal(dmginfo:GetDamageForce():GetNormal())
		effectData:SetMagnitude(3)
		effectData:SetScale(1)
		util.Effect("ElectricSpark", effectData)

		self:SetLocalVelocity(vector_origin)
		self:SetVelocity((self:GetPos() -attacker:GetPos()):GetNormal() *(dmginfo:GetDamageForce():Length() *0.25))
		self.Manhack_HasHit = true
		self.Manhack_HitID = self.Manhack_HitID +1
		self.DisableChasingEnemy = true
		self.DisableWandering = true
		local id = self.Manhack_HitID
		timer.Simple(math.Rand(0.4, 0.7), function()
			if IsValid(self) && self.Manhack_HitID == id then
				self.Manhack_HasHit = false
				self.DisableChasingEnemy = false
				self.DisableWandering = false
			end
		end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	self.IdleLoop1:Stop()
	self.IdleLoop2:Stop()
	self.BladeLoop:Stop()
end