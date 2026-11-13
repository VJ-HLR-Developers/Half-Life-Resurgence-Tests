/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
EFFECT.Distortion = Material("effects/strider_pinch_dudv")
EFFECT.BlueExplosive = Material("effects/bluemuzzle")
EFFECT.BlueElectricity = Material("vj_hl/hl2/effects/lgtning")

function EFFECT:Init(data)
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Ent = data:GetEntity()
	self.Att = data:GetAttachment()
	self.Normal = self.EndPos:GetNormalized()
	if IsValid(self.Ent) then self.StartPos = self.Ent:GetAttachment(self.Att).Pos end

	self.HitPos = self.EndPos -self.StartPos
	self.DieTime = CurTime() +1
	self:SetRenderBoundsWS(self.StartPos, self.EndPos)

	self.Dir = self.EndPos -self.StartPos
	self.TracerTime = math.min(1, self.StartPos:Distance(self.EndPos) /10000)
	self.Length = 0.2
end

function EFFECT:Think()
	if !IsValid(self.Ent) then return false end
	self.StartPos = self.Ent:GetAttachment(self.Att).Pos
	self.Dir = self.EndPos -self.StartPos
	if (CurTime() > self.DieTime) then
		util.ScreenShake(self.EndPos, 16, 300, 2, 1500)
		sound.Play("weapons/mortar/mortar_explode3.wav", self.EndPos, 100, 100)
		local ang = self.Normal:Angle():Right():Angle()
		local emitter = ParticleEmitter(self.EndPos)
		for i = 1, 7 do
			local vec = (self.Normal +1.2 *VectorRand()):GetNormalized()
			local particle = emitter:Add("effects/bluespark", self.EndPos +math.Rand(3, 30) *vec)
			particle:SetVelocity(math.Rand(700, 800) *vec)
			particle:SetDieTime(math.Rand(0.8, 1))
			particle:SetStartAlpha(150)
			particle:SetStartSize(math.Rand(7, 15))
			particle:SetEndSize(0)
			particle:SetStartLength(math.Rand(30, 40))
			particle:SetEndLength(0)
			particle:SetColor(255, 255, 255)
			particle:SetGravity(Vector(0, 0, -400))
			particle:SetAirResistance(5)
			particle:SetCollide(true)
			particle:SetBounce(0.9)
		end
		for i = 1, 15 do
			ang:RotateAroundAxis(self.Normal, math.Rand(0, 360))
			local vec = ang:Forward()
			local particle = emitter:Add("particle/particle_smokegrenade", self.EndPos +math.Rand(5, 20) *vec)
			particle:SetVelocity(math.Rand(1000, 1800) *vec)
			particle:SetDieTime(math.Rand(2.5, 3))
			particle:SetStartAlpha(math.Rand(80, 170))
			particle:SetStartSize(math.Rand(150, 200))
			particle:SetEndSize(math.Rand(70, 80))
			particle:SetColor(50, 50, 200)
			particle:SetAirResistance(600)
		end
		for i = 1, 10 do
			local vec = (self.Normal +0.6 *VectorRand()):GetNormalized()
			local particle = emitter:Add("particle/particle_smokegrenade", self.EndPos +math.Rand(5, 20) *vec)
			particle:SetVelocity(math.Rand(1800, 2500) *vec)
			particle:SetDieTime(math.Rand(2.5, 3))
			particle:SetStartAlpha(math.Rand(80, 170))
			particle:SetStartSize(math.Rand(60, 150))
			particle:SetEndSize(math.Rand(80, 90))
			particle:SetColor(255, 241, 232)
			particle:SetGravity(Vector(0, 0, 100))
			particle:SetAirResistance(500)
		end
		emitter:Finish()
		return false
	end
	return true
end

function EFFECT:Render()
	render.SetMaterial(self.Distortion)
	render.DrawBeam(self.StartPos, self.EndPos, 30, math.Rand(0, 1), math.Rand(0, 1) +((self.StartPos -self.EndPos):Length() /128), Color(255, 255, 255, (50 /((self.DieTime -0.5) -CurTime()))))
	render.SetMaterial(self.BlueElectricity)
	render.DrawBeam(self.StartPos, self.EndPos, 10, math.Rand(0, 1), math.Rand(0, 1) +((self.StartPos -self.EndPos):Length() /128), Color(50, 50, 255, (50 /((self.DieTime -0.5) -CurTime()))))

	local fDelta = (self.DieTime -CurTime()) /self.TracerTime
	fDelta = math.Clamp(fDelta, 0, 1) ^0.5
	render.SetMaterial(self.BlueExplosive)
	local sinWave = math.sin(fDelta *math.pi)
	render.DrawBeam(
		self.EndPos -self.Dir *(fDelta -sinWave *self.Length),
		self.EndPos -self.Dir *(fDelta +sinWave *self.Length),
		5 +sinWave *35, 1, 0, Color(255, 255, 255, 255)
	)
end