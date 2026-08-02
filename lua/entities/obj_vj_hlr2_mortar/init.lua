AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/items/combine_rifle_ammo01.mdl"
ENT.ProjectileType = VJ.PROJ_TYPE_GRAVITY
ENT.DoesRadiusDamage = true
ENT.RadiusDamageRadius = 200
ENT.RadiusDamage = 40
ENT.RadiusDamageUseRealisticRadius = true
ENT.RadiusDamageType = DMG_DISSOLVE
ENT.CollisionDecal = "Scorch"
ENT.SoundTbl_Idle = "vj_hlr/src/npc/combot/cbot_energyball_loop1.wav"
ENT.SoundTbl_OnCollide = "vj_hlr/src/npc/mortarsynth/grenade_fire.wav"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	ParticleEffectAttach("electrical_arc_01_system", PATTACH_POINT_FOLLOW, self, 0)
	sound.EmitHint(SOUND_DANGER, self:GetPos() +self:GetVelocity(), self.RadiusDamageRadius, 1, self)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	-- ParticleEffectAttach("electrical_arc_01_system", PATTACH_POINT_FOLLOW, self, 0)
	self:SetNoDraw(true)
	self:DrawShadow(false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDealDamage(data, phys, hitEnts)
	if hitEnts then
		for _, v in pairs(hitEnts) do
			v:EmitSound("ambient/energy/weld" .. math.random(1, 2) .. ".wav", 60, 100)
			if IsValid(v) then
				local zapEnt = v
				timer.Create("VJ_HLR2_ZapEffect" .. self:EntIndex() .. tostring(zapEnt), 0.2, 15, function()
					if IsValid(zapEnt) then
						local effect = EffectData()
						effect:SetOrigin(zapEnt:GetPos())
						effect:SetStart(zapEnt:GetPos())
						effect:SetMagnitude(5)
						effect:SetEntity(zapEnt)
						util.Effect("teslaHitBoxes", effect)
						zapEnt:EmitSound("Weapon_StunStick.Activate")
					end
				end)
				if v:IsPlayer() && IsValid(v:GetActiveWeapon()) then
					local wep = v:GetActiveWeapon()
					v:DropWeapon(wep)
					local zapWep = wep
					timer.Create("VJ_HLR2_ZapEffect_PWep" .. self:EntIndex() .. tostring(zapWep), 0.2, 15, function()
						if IsValid(zapWep) then
							local effect = EffectData()
							effect:SetOrigin(zapWep:GetPos())
							effect:SetStart(zapWep:GetPos())
							effect:SetMagnitude(5)
							effect:SetEntity(zapWep)
							util.Effect("teslaHitBoxes", effect)
							zapWep:EmitSound("Weapon_StunStick.Activate")
						end
					end)
				elseif v:IsNPC() && v.IsVJBaseSNPC && IsValid(v:GetActiveWeapon()) && math.random(1, 3) == 1 then
					local class = v:GetActiveWeapon():GetClass()
					local ent = ents.Create(class)
					ent:SetPos(v:GetActiveWeapon():GetPos())
					ent:SetAngles(v:GetActiveWeapon():GetAngles())
					ent:Spawn()
					if IsValid(ent:GetPhysicsObject()) then
						ent:GetPhysicsObject():SetVelocity(ent:GetPos() +VectorRand() *20)
					end
					v:GetActiveWeapon():Remove()
					local zapNWep = ent
					timer.Create("VJ_HLR2_ZapEffect_NWep" .. self:EntIndex() .. tostring(zapNWep), 0.2, 15, function()
						if IsValid(zapNWep) then
							local effect = EffectData()
							effect:SetOrigin(zapNWep:GetPos())
							effect:SetStart(zapNWep:GetPos())
							effect:SetMagnitude(5)
							effect:SetEntity(zapNWep)
							util.Effect("teslaHitBoxes", effect)
							zapNWep:EmitSound("Weapon_StunStick.Activate")
						end
					end)
				end
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDestroy(data, phys)
	for i = 1, 5 do
		ParticleEffect("vj_aurora_shockwave", self:GetPos(), Angle(), nil)
		ParticleEffect("electrical_arc_01_system", self:GetPos(), Angle(), nil)
	end
end