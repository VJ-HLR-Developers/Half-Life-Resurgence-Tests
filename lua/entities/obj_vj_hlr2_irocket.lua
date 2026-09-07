/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "obj_vj_projectile_base"
ENT.PrintName = "Combine Rocket"
ENT.Author = "DrVrej"
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
	VJ.AddKillIcon("obj_vj_hlr2_irocket", ENT.PrintName, VJ.KILLICON_PROJECTILE)

	function ENT:Think()
		if self:IsValid() then
			self.Emitter = ParticleEmitter(self:GetPos())
			self.SmokeEffect1 = self.Emitter:Add("particles/flamelet2", self:GetPos() +self:GetForward()*-7)
			self.SmokeEffect1:SetVelocity(self:GetForward() *math.Rand(0, -50) +Vector(math.Rand(5, -5), math.Rand(5, -5), math.Rand(5, -5)) +self:GetVelocity())
			self.SmokeEffect1:SetDieTime(0.2)
			self.SmokeEffect1:SetStartAlpha(100)
			self.SmokeEffect1:SetEndAlpha(0)
			self.SmokeEffect1:SetStartSize(10)
			self.SmokeEffect1:SetEndSize(1)
			self.SmokeEffect1:SetRoll(math.Rand(-0.2, 0.2))
			self.SmokeEffect1:SetAirResistance(200)
			self.Emitter:Finish()
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

ENT.Model = "models/weapons/w_missile_launch.mdl"
ENT.DoesRadiusDamage = true
ENT.RadiusDamageRadius = 300
ENT.RadiusDamage = 100
ENT.RadiusDamageUseRealisticRadius = true
ENT.RadiusDamageType = bit.bor(DMG_BLAST, DMG_SHOCK, DMG_DISSOLVE)
ENT.RadiusDamageForce = 90
ENT.CollisionDecal = "Scorch"
ENT.SoundTbl_Idle = "weapons/rpg/rocket1.wav"
ENT.SoundTbl_OnCollide = "ambient/explosions/explode_8.wav"

-- Custom
ENT.Rocket_Follow = true
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	//ParticleEffectAttach("vj_rocket_idle1_smoke", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	//ParticleEffectAttach("vj_rocket_idle2_smoke2", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	ParticleEffectAttach("electrical_arc_01_system", PATTACH_POINT_FOLLOW, self, 0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	local owner = self:GetOwner()
	local phys = self:GetPhysicsObject()
	if IsValid(owner) && IsValid(phys) then
		local pos = self:GetPos() + self:GetForward() * 200
		if owner:IsNPC() && IsValid(owner:GetEnemy()) then
			pos = owner:GetEnemy():GetPos() + owner:GetEnemy():OBBCenter()
		elseif (owner:IsPlayer()) && self.Rocket_Follow == true then
			pos = self:GetOwner():GetEyeTrace().HitPos
		end
		phys:SetVelocity(self:CalculateProjectile("Line", self:GetPos(), pos, 2000))
		self:SetAngles((pos - self:GetPos()):Angle())
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDestroy(data, phys)
	util.ScreenShake(data.HitPos, 16, 200, 1, 3000)

	local effectdata = EffectData()
	effectdata:SetOrigin(data.HitPos)
	util.Effect( "HelicopterMegaBomb", effectdata )
	util.Effect( "ThumperDust", effectdata )
	util.Effect( "Explosion", effectdata )
	util.Effect( "VJ_Small_Explosion1", effectdata )

	self.ExplosionLight1 = ents.Create("light_dynamic")
	self.ExplosionLight1:SetKeyValue("brightness", "4")
	self.ExplosionLight1:SetKeyValue("distance", "300")
	self.ExplosionLight1:SetLocalPos(data.HitPos)
	self.ExplosionLight1:Fire("Color", "0 31 225")
	self.ExplosionLight1:SetParent(self)
	self.ExplosionLight1:Spawn()
	self.ExplosionLight1:Activate()
	self.ExplosionLight1:Fire("TurnOn")
	self:DeleteOnRemove(self.ExplosionLight1)

	for i = 1, math.random(3, 5) do
		ParticleEffect("vj_aurora_shockwave", self:GetPos(), Angle(), nil)
		ParticleEffect("electrical_arc_01_system", self:GetPos(), Angle(), nil)
	end
end