AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/vj_base/projectiles/spit_acid_small.mdl", "models/vj_base/projectiles/spit_acid_medium.mdl", "models/vj_base/projectiles/spit_acid_medium.mdl"}
ENT.ProjectileType = VJ.PROJ_TYPE_GRAVITY
ENT.DoesRadiusDamage = true
ENT.RadiusDamageRadius = 40
ENT.RadiusDamage = 20
ENT.RadiusDamageUseRealisticRadius = true
ENT.RadiusDamageType = DMG_ACID
ENT.CollisionDecal = "BeerSplash"
ENT.SoundTbl_Idle = "vj_base/ambience/acid_idle.wav"
ENT.SoundTbl_OnCollide = "vj_base/ambience/acid_splat.wav"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	ParticleEffectAttach("vj_acid_idle", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	ParticleEffect("vj_acid_impact1", self:GetPos(), Angle())
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	sound.EmitHint(SOUND_DANGER, self:GetPos() +self:GetVelocity(), self.RadiusDamageRadius, 1, self)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDestroy(data, phys)
	ParticleEffect("vj_acid_impact1", data.HitPos, Angle())
	ParticleEffect("vj_acid_impact2", data.HitPos, Angle())
end