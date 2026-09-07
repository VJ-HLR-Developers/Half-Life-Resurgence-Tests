/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "obj_vj_projectile_base"
ENT.PrintName = "Overwatch Cremator"
ENT.Author = "DrVrej"
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"

if CLIENT then
	VJ.AddKillIcon("obj_vj_hlr2b_cremator", ENT.PrintName)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

ENT.Model = "models/vj_base/projectiles/spit_acid_medium.mdl"
ENT.ProjectileType = VJ.PROJ_TYPE_GRAVITY
ENT.DoesRadiusDamage = true
ENT.RadiusDamageRadius = 200
ENT.RadiusDamage = 45
ENT.RadiusDamageUseRealisticRadius = true
ENT.RadiusDamageType = bit.bor(DMG_BURN, DMG_DISSOLVE, DMG_ENERGYBEAM)
ENT.SoundTbl_Idle = "vj_hlr/gsrc/npc/kingpin/kingpin_move.wav"
ENT.SoundTbl_OnCollide = "vj_hlr/src/npc/cremator/plasma_stop.wav"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetNoDraw(true)
	self:DrawShadow(false)

	ParticleEffectAttach("vj_hlr_cremator_projectile", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	VJ.EmitSound(self, "vj_hlr/src/npc/cremator/plasma_ignite.wav", 75)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	sound.EmitHint(SOUND_DANGER, self:GetPos() +self:GetVelocity(), self.RadiusDamageRadius, 1, self)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDestroy(data, phys)
	ParticleEffect("vj_hlr_cremator_projectile_impact", data.HitPos, Angle())
end