AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/antlion_worker.mdl"
ENT.StartHealth = 60

ENT.BloodParticle = "vj_acid_impact1_small_splat"

ENT.HasRangeAttack = true
ENT.AnimTbl_RangeAttack = ACT_RANGE_ATTACK1
ENT.RangeAttackProjectiles = "obj_vj_hlr2_antlionspit"
ENT.TimeUntilRangeAttackProjectileRelease = false
ENT.NextRangeAttackTime = 1.5
ENT.RangeAttackMaxDistance = 2000
ENT.RangeAttackMinDistance = 400

ENT.LimitChaseDistance = "OnlyRange"
ENT.LimitChaseDistance_Max = "UseRangeDistance"
ENT.LimitChaseDistance_Min = "UseRangeDistance"

ENT.HasDeathAnimation = true
ENT.AnimTbl_Death = "explode"
ENT.GibOnDeathFilter = false
ENT.SoundTbl_Death = {
	"npc/antlion/antlion_preburst_scream1.wav",
	"npc/antlion/antlion_preburst_scream2.wav"
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackProjPos(projectile)
	return self:GetPos() + self:GetUp() * 20 + self:GetForward() * 30
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:HandleGibOnDeath(dmginfo, hitgroup)
	timer.Simple(0.89999995708466, function()
		if IsValid(self) then
			VJ.EmitSound(self, "npc/antlion/antlion_burst" .. math.random(1, 2) .. ".wav", 75, 100)
			ParticleEffect("vj_acid_impact3", self:GetPos(), Angle(), nil)
			VJ.ApplyRadiusDamage(self, self, self:GetPos(), 160, 50, DMG_ACID, true, false, {Force = 50})

			local head = self:GetPos() +self:GetForward() *50 +self:GetRight() *0 +self:GetUp() *30
			local lF = self:GetPos() +self:GetForward() *40 +self:GetRight() *-15 +self:GetUp() *30
			//local lB = self:GetPos() +self:GetForward() *-45 +self:GetRight() *-15 +self:GetUp() *30
			local rF = self:GetPos() +self:GetForward() *40 +self:GetRight() *15 +self:GetUp() *30
			//local rB = self:GetPos() +self:GetForward() *-45 +self:GetRight() *15 +self:GetUp() *30
			self:CreateGibEntity("prop_ragdoll", "models/gibs/antlion_worker_gibs_backlegl.mdl", {BloodType = "Yellow", Pos = lF})
			self:CreateGibEntity("prop_ragdoll", "models/gibs/antlion_worker_gibs_backlegr.mdl", {BloodType = "Yellow", Pos = rF})
			self:CreateGibEntity("prop_ragdoll", "models/gibs/antlion_worker_gibs_frontlegl.mdl", {BloodType = "Yellow", Pos = lF})
			self:CreateGibEntity("prop_ragdoll", "models/gibs/antlion_worker_gibs_frontlegr.mdl", {BloodType = "Yellow", Pos = rF})
			self:CreateGibEntity("obj_vj_gib", "models/gibs/antlion_worker_gibs_head.mdl", {BloodType = "Yellow", Pos = head})
		end
	end)
	return true, {AllowAnim = true}
end