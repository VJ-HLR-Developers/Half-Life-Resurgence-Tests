/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "obj_vj_projectile_base"
ENT.PrintName		= "Flechette"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
---------------------------------------------------------------------------------------------------------------------------------------------
if CLIENT then
	VJ.AddKillIcon("obj_vj_hlr2_flechette", ENT.PrintName, VJ.KILLICON_PROJECTILE)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

ENT.Model = "models/vj_hlr/hl2/projectiles/hunter_flechette.mdl"
ENT.CollisionBehavior = VJ.PROJ_COLLISION_PERSIST
ENT.CollisionDecal = "Impact.Concrete"
ENT.SoundTbl_Idle = "weapons/fx/nearmiss/bulletltor03.wav"
ENT.SoundTbl_OnCollide = {
	"vj_hlr/src/npc/ministrider/flechette_impact_stick1.wav",
	"vj_hlr/src/npc/ministrider/flechette_impact_stick2.wav",
	"vj_hlr/src/npc/ministrider/flechette_impact_stick3.wav",
	"vj_hlr/src/npc/ministrider/flechette_impact_stick4.wav",
	"vj_hlr/src/npc/ministrider/flechette_impact_stick5.wav"
}

ENT.IdleSoundLevel = 60
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	ParticleEffectAttach("hunter_flechette_trail", PATTACH_POINT_FOLLOW, self, 1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCollisionPersist(data, phys)
	local owner = self:GetOwner()
	local hitEnt = NULL
	local dmgPos = (data != nil and data.HitPos) or self:GetPos()

	if IsValid(data.HitEntity) && data.HitEntity != Entity(0) then
		self.SoundTbl_OnCollide = {
			"vj_hlr/src/npc/ministrider/flechette_flesh_impact1.wav",
			"vj_hlr/src/npc/ministrider/flechette_flesh_impact2.wav",
			"vj_hlr/src/npc/ministrider/flechette_flesh_impact3.wav",
			"vj_hlr/src/npc/ministrider/flechette_flesh_impact4.wav"
		}
		hitEnt = data.HitEntity
		if IsValid(owner) then
			if (VJ.IsProp(hitEnt)) or (hitEnt:IsNPC() && (hitEnt:Disposition(owner) == D_HT or hitEnt:Disposition(owner) == D_FR) && hitEnt:Health() > 0 && (hitEnt != owner) && (hitEnt:GetClass() != owner:GetClass())) or (hitEnt:IsPlayer() && !VJ_CVAR_IGNOREPLAYERS && hitEnt:Alive() && hitEnt:Health() > 0) then
				local dmgInfo = DamageInfo()
				dmgInfo:SetDamage(4)
				dmgInfo:SetDamageType(DMG_SLASH)
				dmgInfo:SetAttacker(owner)
				dmgInfo:SetInflictor(self)
				dmgInfo:SetDamagePosition(dmgPos)
				VJ.DamageSpecialEnts(owner, hitEnt, dmgInfo)
				hitEnt:TakeDamageInfo(dmgInfo, self)
			end
		else
			local dmgInfo = DamageInfo()
			dmgInfo:SetDamage(4)
			dmgInfo:SetDamageType(DMG_SLASH)
			dmgInfo:SetAttacker(self)
			dmgInfo:SetInflictor(self)
			dmgInfo:SetDamagePosition(dmgPos)
			VJ.DamageSpecialEnts(self, hitEnt, dmgInfo)
			hitEnt:TakeDamageInfo(dmgInfo, self)
		end
		self:Destroy(data, phys)
	else
		local fakeEnt = ents.Create("prop_vj_animatable")
		fakeEnt:SetModel(self:GetModel())
		fakeEnt:SetPos(data.HitPos + data.HitNormal)
		fakeEnt:SetAngles(self:GetAngles())
		fakeEnt:Activate()
		fakeEnt:Spawn()
		local snd = "vj_hlr/src/npc/ministrider/hunter_flechette_preexplode" .. math.random(1, 3) .. ".wav"
		VJ.CreateSound(self, snd, 80)
		sound.EmitHint(SOUND_DANGER, self:GetPos(), 160, SoundDuration(snd) *1.5, fakeEnt)
		timer.Simple(SoundDuration(snd) *1.5, function()
			if IsValid(fakeEnt) then
				VJ.EmitSound(fakeEnt, "vj_hlr/src/npc/ministrider/flechette_explode" .. math.random(1, 3) .. ".wav", 95)
				ParticleEffect("hunter_projectile_explosion_1", data.HitPos, Angle(), nil)
				VJ.ApplyRadiusDamage(IsValid(self) && self or IsValid(owner) && owner or fakeEnt, IsValid(owner) && owner or IsValid(self) && self or fakeEnt, data.HitPos, 128, 12, bit.bor(DMG_BLAST, DMG_DISSOLVE), true, true)
				util.Decal("Scorch", data.HitPos +data.HitNormal, data.HitPos -data.HitNormal)
				fakeEnt:Remove()
			end
		end)
		self:Destroy(data, phys)
	end
end