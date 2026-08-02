/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
AddCSLuaFile()

ENT.Base 			= "base_gmodentity"
ENT.Type 			= "anim"
ENT.PrintName 		= "Blob"
ENT.Author 			= ""
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"

local BLOB_HEIGHTVEC = Vector(0, 0, 8)
local BLOB_VEC0 = Vector()
---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	VJ.AddKillIcon("sent_vj_hlr2_metaball", ENT.PrintName)

	function ENT:Draw()
		self:DrawModel()
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

function ENT:Initialize()
	self:SetModel("models/vj_hlr/hl2b/metaball.mdl")
	self:SetMoveType(MOVETYPE_FLY)
	self:SetMoveCollide(MOVECOLLIDE_FLY_SLIDE)
	self:SetSolid(SOLID_NONE)
	self:AddSolidFlags(bit.bor(FSOLID_NOT_STANDABLE, FSOLID_NOT_SOLID))
	self:AddEffects(EF_NOSHADOW)

	-- self:PhysicsInit(SOLID_VPHYSICS)
	-- self:SetMoveType(MOVETYPE_VPHYSICS)
	-- self:SetSolid(SOLID_VPHYSICS)

	self.Scale = math.Rand(0.8, 1)
	self.MoveType = 0
	self.LastPosition = Vector()
	self.SinePhase = 0
	self.SineFrequency = 0
	self.SineAmplitude = 0

	self:SetModelScale(self.Scale)

	local phys = self:GetPhysicsObject()
	if phys and IsValid(phys) then
		phys:Wake()
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0)
		phys:EnableDrag(false)
		phys:EnableGravity(false)
	end

	local rAng = Angle()
	rAng.y = math.Rand(0, 360)
	self:SetAngles(rAng)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetVel(vec)
	self:SetAbsVelocity(vec)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:AddVel(vec)
	if type(vec) == "number" then return end
	vec = self:GetAbsVelocity() +vec
	self:SetAbsVelocity(vec)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Think()
	-- if IsValid(self:GetOwner()) && IsValid(self:GetOwner():GetEnemy()) then
		-- self:MoveTowardsTargetEntity(187, self:GetOwner():GetEnemy())
	-- end
	-- util.ParticleTracerEx("Weapon_Combine_Ion_Cannon_Beam", self:GetPos(), self.LastPosition, false, self:EntIndex(), 0)
	-- VJ.DEBUG_TempEnt(self.LastPosition, Angle(), Color(145, 255, 0), 5)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ModifyVelocityForSurface(flInterval, flSpeed)
	local vecStart = self:GetPos()
	local up = BLOB_HEIGHTVEC
	local vecWishedGoal = vecStart +(self:GetAbsVelocity() *flInterval)
	local onWall = false

	local tr = util.TraceLine({
		start = vecStart + up,
		endpos = vecWishedGoal + up,
		mask = MASK_SHOT,
		filter = self,
		collisiongroup = COLLISION_GROUP_NONE,
	})

	if tr.Fraction == 1 then
		local tr = util.TraceLine({
			start = vecWishedGoal + up,
			endpos = vecWishedGoal -(up *2),
			mask = MASK_SHOT,
			filter = self,
			collisiongroup = COLLISION_GROUP_NONE,
		})

		tr.HitPos.z = tr.HitPos.z +0.0625
	else
		onWall = true
		local ent = tr.Entity
		if IsValid(ent) && !ent:IsWorld() then
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				local vecMassCenter = phys:GetMassCenter()
				local vecMassCenterWorld = phys:LocalToWorld(vecMassCenter)
				if tr.HitPos.z > vecMassCenterWorld.z then
					phys:ApplyForceOffset((-150 *self:GetModelScale()) *tr.HitNormal, tr.HitPos)
				end
			end
		end
	end
	local vecDir = tr.HitPos -vecStart
	vecDir:Normalize()
	self:SetVel(vecDir *flSpeed)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MoveTowardsTargetEntity(speed, ent)
	ent = ent or (self:GetOwner() && self:GetOwner():GetEnemy())

	if IsValid(ent) then
		-- Try to attack my target's enemy directly if I can
		local entEnemy = ent.GetEnemy && ent:GetEnemy()
		if IsValid(entEnemy) && entEnemy:GetPos():Distance(self:GetPos()) < ent:GetPos():Distance(self:GetPos()) then
			ent = entEnemy
		end
		local vecDir = ent:WorldSpaceCenter() -self:GetPos()
		vecDir:Normalize()
		self:SetVel(vecDir *speed)
		self.LastPosition = ent:GetPos()
	else
		self.LastPosition = self:GetPos()
        self:SetVel(BLOB_VEC0)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MoveTowardsTargetLocation(speed, pos)
	self.LastPosition = pos
	local vecDir = pos -self:GetPos()
	local dist = pos:Distance(self:GetPos())
	if dist <= 8 then
		self:SetActiveMovementRule(BLOB_MOVE_DONT_MOVE)
	end
	speed = math.min(dist, speed)
	self:SetVel(vecDir *speed)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ReconfigureRandomParams()
	self.SinePhase = math.Rand(0.01, 0.9)
	self.SineFrequency = math.Rand(10, 20)
	self.SineAmplitude = math.Rand(0.5, 1.5)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:EnforceSpeedLimits(flMinSpeed, flMaxSpeed)
	local vecVelocity = self:GetAbsVelocity()
	local flSpeed = vecVelocity:Normalize() or 0

	if flSpeed > flMaxSpeed then
		self:SetVel(vecVelocity *flMaxSpeed)
	elseif flSpeed < flMinSpeed then
		self:SetVel(vecVelocity *flMinSpeed)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:PhysicsCollide(data, physobj)
	local velSpeed = physobj:GetVelocity():Length()
	if velSpeed > 50 then
		VJ.EmitSound(self, "ambient/water/water_spray" .. math.random(1, 3) .. ".wav", 75, math.random(90, 110))
	end
	local hitEnt = data.HitEntity
	if IsValid(hitEnt) && (hitEnt:IsNPC() or hitEnt:IsPlayer()) then
		local dmg = DamageInfo()
		dmg:SetDamage(5)
		dmg:SetDamageType(bit.bor(DMG_SLASH, DMG_DROWN))
		dmg:SetAttacker(IsValid(self:GetOwner()) && self:GetOwner() or self)
		dmg:SetInflictor(self)
		dmg:SetDamagePosition(data.HitPos)
		hitEnt:TakeDamageInfo(dmg, self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnTakeDamage(dmginfo)
	self:AddVel(dmginfo:GetDamageForce() *0.1)
end