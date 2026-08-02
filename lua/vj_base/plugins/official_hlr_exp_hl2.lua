/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
VJ.AddPlugin("Half-Life Resurgence: Half Life 2", "NPC")

/*
	Credits:
	- Sabrean = Custom Zombie Models
*/
local spawnCategory = "HL Resurgence: Source"

-- Misc
VJ.AddNPC("G-Man", "npc_vj_hlr2_gman", spawnCategory)
VJ.AddNPC("Mounted Turret", "sent_vj_hlr2_mountedturret", spawnCategory)

-- Antlions
local subCategory = "Antlion"
VJ.AddNPC("Antlion", "npc_vj_hlr2_antlion", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Antlion Worker", "npc_vj_hlr2_antlion_worker", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Antlion Guard", "npc_vj_hlr2_antlion_guard", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Antlion Guardian", "npc_vj_hlr2_antlion_guardian", spawnCategory, {SubCategory = subCategory})

-- Combine
subCategory = "Combine"
VJ.AddNPC_HUMAN("Wallace Breen", "npc_vj_hlr2_com_breen", {"weapon_vj_ar2"}, spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Guard", "npc_vj_hlr2b_com_guard", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Stalker (Beta)", "npc_vj_hlr2b_com_stalker", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Prowler", "npc_vj_hlr2b_com_alienassassin", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Cremator", "npc_vj_hlr2b_com_cremator", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Assassin", "npc_vj_hlr2b_com_assassin", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Stalker", "npc_vj_hlr2_com_stalker", spawnCategory, {SubCategory = subCategory})
//VJ.AddNPC("Overwatch Manhack", "npc_vj_hlr2_com_manhack", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch City Scanner", "npc_vj_hlr2_com_scanner_city", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Shield Scanner", "npc_vj_hlr2_com_scanner_shield", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Hunter Synth", "npc_vj_hlr2_com_hunter", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch APC", "npc_vj_hlr2_com_apc", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch APC (Meme)", "npc_vj_hlr2_com_apc_meme", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Strider Synth", "npc_vj_hlr2_com_strider", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Advisor", "npc_vj_hlr2_com_advisor", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Mortar Synth", "npc_vj_hlr2_com_mortar", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Crab Synth", "npc_vj_hlr2_com_crab", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Ceiling Turret", "npc_vj_hlr2_com_ceilingturret", spawnCategory, {SubCategory = subCategory, OnCeiling = true})
VJ.AddNPC("Overwatch Ion Cannon Turret", "npc_vj_hlr2_com_ionturret", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Hunter Chopper", "npc_vj_hlr2_com_chopper", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Heavy Chopper", "npc_vj_hlr2_com_chopper_heavy", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Gunship Synth", "npc_vj_hlr2_com_gunship", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Overwatch Dropship Synth", "npc_vj_hlr2_com_dropship", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Vortigaunt Slave", "npc_vj_hlr2_vortigaunt_slave", spawnCategory, {SubCategory = subCategory})

-- Resistance
subCategory = "Resistance"
VJ.AddNPC("Vortigaunt", "npc_vj_hlr2_vortigaunt", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC_HUMAN("Gordon Freeman", "npc_vj_hlr2_freeman", {"weapon_vj_smg1", "weapon_vj_ar2", "weapon_vj_spas12"}, spawnCategory, {SubCategory = subCategory})
VJ.AddNPC_HUMAN("Isaac Kleiner", "npc_vj_hlr2_kleiner", {"weapon_vj_spas12"}, spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Lamarr", "npc_vj_hlr2_lamarr", spawnCategory, {SubCategory = subCategory})

-- Xen
subCategory = "Xen"
VJ.AddNPC("Leech", "npc_vj_hlr2_leech", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Hydra", "npc_vj_hlr2b_hydra", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Bullsquid", "npc_vj_hlr2b_bullsquid", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Houndeye", "npc_vj_hlr2b_houndeye", spawnCategory, {SubCategory = subCategory})
VJ.AddNPC("Ichthyosaur", "npc_vj_hlr2_ichthyosaur", spawnCategory, {SubCategory = subCategory})
//VJ.AddNPC("Barnacle", "npc_vj_hlr2_barnacle", spawnCategory, {SubCategory = subCategory, OnCeiling = true})
	-- Headcrabs & Zombies
	VJ.AddNPC("Zombie", "npc_vj_hlr2_zombie", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Prowler Zombie", "npc_vj_hlr2b_zombie_assassin", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Fast Zombie", "npc_vj_hlr2_zombie_fast", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Poison Zombie", "npc_vj_hlr2_zombie_poison", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Zombine", "npc_vj_hlr2_zombine", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Headcrab", "npc_vj_hlr2_headcrab", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Fast Headcrab", "npc_vj_hlr2_headcrab_fast", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Poison Headcrab", "npc_vj_hlr2_headcrab_poison", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Zombie (Slump)", "npc_vj_hlr2_zombie_slump", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Fast Zombie (Slump)", "npc_vj_hlr2_zombie_fast_slump", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Poison Zombie (Slump)", "npc_vj_hlr2_zombie_poison_slump", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Zombine (Slump)", "npc_vj_hlr2_zombine_slump", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Zombie (Beta)", "npc_vj_hlr2b_zombie", spawnCategory, {SubCategory = subCategory})
	//VJ.AddNPC("Zombie (2002)", "npc_vj_hlr2b_zombie_fat", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Fast Zombie (Beta)", "npc_vj_hlr2b_zombie_fast", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Poison Zombie (Beta)", "npc_vj_hlr2b_zombie_poison", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Headcrab (Beta)", "npc_vj_hlr2b_headcrab", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Fast Headcrab (Beta)", "npc_vj_hlr2b_headcrab_fast", spawnCategory, {SubCategory = subCategory})
	VJ.AddNPC("Poison Headcrab (Beta)", "npc_vj_hlr2b_headcrab_poison", spawnCategory, {SubCategory = subCategory})

-- NPC Weapons
VJ.AddNPCWeapon("VJ_HL2B_HMG1", "weapon_vj_hlr2b_hmg1", spawnCategory)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Particles ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
VJ.AddParticle("particles/advisor.pcf", {})
VJ.AddParticle("particles/advisor_fx.pcf", {})
VJ.AddParticle("particles/vj_hlr_flechette_projectile.pcf", {"hunter_flechette_trail", "hunter_projectile_explosion_1"})
VJ.AddParticle("particles/vj_hlr_hunter_shield.pcf", {"vj_hlr_huntershield_impact1"})
VJ.AddParticle("particles/vj_hlr_cremator.pcf", {"vj_hlr_cremator_range", "vj_hlr_cremator_projectile", "vj_hlr_cremator_projectile_impact"})
VJ.AddParticle("particles/vj_hlr_alienassassin.pcf", {"vj_hlr_assassin_bodysmoke", "vj_hlr_assassin_smokegrenade", "vj_hlr_assassin_smokegrenade_b"})

if CLIENT then
	local math_abs = math.abs
	local blueFX = Vector(0, 0.4, 6)
	local whiteFX = Vector(1, 1, 1)
	matproxy.Add({
		name = "HLR.Camo", -- Used for Combine Assassin's new cloak materials. It's made with her in mind, so if we use it for other stuff it might not function properly in it's current state
		init = function(self, mat, values)
			self.Result = values.resultvar
			self.CloakColorTint = mat:GetVector("$cloakcolortint") or whiteFX
		end,
		bind = function(self, mat, ent)
			if (!IsValid(ent)) then return end

			local parent = ent:GetParent()
			local checkEnt = IsValid(parent) && parent or ent
			ent.Mat_cloakfactor = ent.Mat_cloakfactor or (IsValid(parent) && parent.Mat_cloakfactor or 0)
			local curValue = ent.Mat_cloakfactor
			local finalResult = curValue or 0
			if checkEnt.HLR_UsesCloakSystem then
				if checkEnt:GetCloaked() then
					finalResult = checkEnt:IsNPC() && (checkEnt:GetVelocity():Length() > 60 && 0.97 or checkEnt:GetFireTime() > CurTime() && 0.92) or 0.997
				else
					finalResult = 0
				end
			end
			ent.Mat_cloakfactor = Lerp(FrameTime() *0.3, curValue, finalResult)
			self.CloakColorTint = LerpVector(FrameTime() *0.3, self.CloakColorTint, math_abs(curValue -finalResult) > 0.1 && blueFX or whiteFX)
			mat:SetVector("$cloakcolortint", self.CloakColorTint)
			mat:SetFloat(self.Result, ent.Mat_cloakfactor)
		end
	})
end