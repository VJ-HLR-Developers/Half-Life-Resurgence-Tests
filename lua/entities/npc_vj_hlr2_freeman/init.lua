AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/gordon_freeman.mdl"
ENT.StartHealth = 100
ENT.HealthRegenParams = {
	Enabled = true,
	Amount = 2,
	Delay = VJ.SET(0.1, 0.1),
}
ENT.HullType = HULL_HUMAN
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
ENT.AlliedWithPlayerAllies = true
ENT.BloodColor = VJ.BLOOD_COLOR_RED
ENT.AnimTbl_MeleeAttack = "vjseq_MeleeAttack01"
ENT.TimeUntilMeleeAttackDamage = 0.7

ENT.HasGrenadeAttack = true
ENT.GrenadeAttackModel = "models/weapons/w_npcnade.mdl"
ENT.AnimTbl_GrenadeAttack = ACT_RANGE_ATTACK_THROW
ENT.GrenadeAttackThrowTime = 0.87
ENT.GrenadeAttackAttachment = "anim_attachment_RH"

ENT.BecomeEnemyToPlayer = 2

ENT.WeaponInventory_AntiArmorList = "weapon_vj_hlr2_rpg"
ENT.WeaponInventory_MeleeList = "weapon_vj_crowbar"

ENT.SoundTbl_FootStep = {"NPC_Citizen.FootstepLeft", "NPC_Citizen.FootstepRight"}
ENT.SoundTbl_Breath = "player/breathe1.wav"
ENT.SoundTbl_Pain = {"player/pl_pain5.wav", "player/pl_pain6.wav", "player/pl_pain7.wav"}

ENT.MainSoundPitch = 100
ENT.BreathSoundLevel = 40

ENT.WeaponsList = {
	["Close"] = {
		"weapon_vj_spas12",
		"weapon_vj_9mmpistol"
	},
	["Normal"] = {
		"weapon_vj_357",
		"weapon_vj_smg1",
		"weapon_vj_ar2"
	},
	["Far"] = {
		"weapon_vj_crossbow"
	},
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self.NextWeaponSwitchT = CurTime() + math.Rand(2, 4)

	for _, category in pairs(self.WeaponsList) do
		for _, wep in pairs(category) do
			self:Give(wep)
		end
	end

	self:DoChangeWeapon(VJ.PICK(self.WeaponsList["Normal"]), true)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if math.random(1, 2) == 1 && ent:IsNPC() && ent.VJ_ID_Headcrab then
		self:DoChangeWeapon("weapon_vj_crowbar", true)
		return
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	local ent = self:GetEnemy()
	local dist = self.EnemyData.DistanceNearest
	if IsValid(ent) then
		local wep = self:GetActiveWeapon()
		local selectType = false
		if dist > 2200 then
			selectType = "Far"
		elseif dist <= 2200 && dist > 650 then
			selectType = "Normal"
		else
			selectType = "Close"
		end

		if selectType != false && !self:IsBusy() && CurTime() > self.NextWeaponSwitchT && math.random(1, wep:Clip1() > 0 && (wep:Clip1() <= wep:GetMaxClip1() *0.35) && 1 or (selectType == "Close" && 20 or 150)) == 1 then
			self:DoChangeWeapon(VJ.PICK(self.WeaponsList[selectType]), true)
			wep = self:GetActiveWeapon()
			self.NextWeaponSwitchT = CurTime() + math.Rand(6, math.Round(math.Clamp(wep:Clip1() *0.5, 1, wep:Clip1())))
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnGrenadeAttackExecute(status, grenade, overrideEnt, landDir, landingPos)
	if status == "PostSpawn" && !IsValid(overrideEnt) then
		-- Glow and trail are both based on the original: https://github.com/ValveSoftware/source-sdk-2013/blob/master/src/game/server/hl2/grenade_frag.cpp#L158
		local redGlow = ents.Create("env_sprite")
		redGlow:SetKeyValue("model", "sprites/redglow1.vmt")
		redGlow:SetKeyValue("scale", "0.2")
		redGlow:SetKeyValue("rendermode", "3") -- kRenderGlow
		redGlow:SetKeyValue("renderfx", "14") -- kRenderFxNoDissipation
		redGlow:SetKeyValue("renderamt", "200")
		redGlow:SetKeyValue("rendercolor", "255 255 255")
		redGlow:SetKeyValue("GlowProxySize", "4.0")
		redGlow:SetParent(grenade)
		redGlow:Fire("SetParentAttachment", "fuse")
		redGlow:Spawn()
		redGlow:Activate()
		grenade:DeleteOnRemove(redGlow)
		local redTrail = util.SpriteTrail(grenade, 1, Color(255, 0, 0), true, 8, 1, 0.5, 0.0555, "sprites/bluelaser1.vmt")
		redTrail:SetKeyValue("rendermode", "5") -- kRenderTransAdd
		redTrail:SetKeyValue("renderfx", "0") -- kRenderFxNone
		grenade.SoundTbl_Idle = "Grenade.Blip"
		grenade.IdleSoundPitch = VJ.SET(100, 100)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo, hitgroup, status)
	if status == "PreDamage" then
		-- Absorb bullet damage
		if dmginfo:IsBulletDamage() then
			if self.HasSounds && self.HasImpactSounds then VJ.EmitSound(self, "VJ.Impact.Armor") end
			if math.random(1, 3) == 1 then
				dmginfo:ScaleDamage(0.50)
				local spark = ents.Create("env_spark")
				spark:SetKeyValue("Magnitude", "1")
				spark:SetKeyValue("Spark Trail Length", "1")
				spark:SetPos(dmginfo:GetDamagePosition())
				spark:SetAngles(self:GetAngles())
				spark:SetParent(self)
				spark:Spawn()
				spark:Activate()
				spark:Fire("StartSpark", nil, 0)
				spark:Fire("StopSpark", nil, 0.001)
				self:DeleteOnRemove(spark)
			else
				dmginfo:ScaleDamage(0.60)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmginfo, hitgroup, status)
	if status == "Finish" then
		local myCenterPos = self:GetPos() + self:OBBCenter()
		for _, category in pairs(self.WeaponsList) do
			for _, wep in pairs(category) do
				local e = ents.Create(wep)
				e:SetPos(myCenterPos +VectorRand(-30, 30))
				e:SetAngles(self:GetAngles())
				e:Spawn()
				local phys = e:GetPhysicsObject()
				if ((IsValid(dmginfo:GetInflictor()) && dmginfo:GetInflictor():GetClass() == "prop_combine_ball") or (!IsValid(dmginfo:GetInflictor()))) && IsValid(phys) then
					phys:SetMass(60)
					phys:ApplyForceCenter(dmginfo:GetDamageForce())
				end
			end
		end
		local e = ents.Create(self.WeaponInventory.AntiArmor:GetClass())
		e:SetPos(myCenterPos)
		e:SetAngles(self:GetAngles())
		e:Spawn()
		local phys = e:GetPhysicsObject()
		if ((IsValid(dmginfo:GetInflictor()) && dmginfo:GetInflictor():GetClass() == "prop_combine_ball") or (!IsValid(dmginfo:GetInflictor()))) && IsValid(phys) then
			phys:SetMass(60)
			phys:ApplyForceCenter(dmginfo:GetDamageForce())
		end
		local e = ents.Create(self.WeaponInventory.Melee:GetClass())
		e:SetPos(myCenterPos)
		e:SetAngles(self:GetAngles())
		e:Spawn()
		local phys = e:GetPhysicsObject()
		if ((IsValid(dmginfo:GetInflictor()) && dmginfo:GetInflictor():GetClass() == "prop_combine_ball") or (!IsValid(dmginfo:GetInflictor()))) && IsValid(phys) then
			phys:SetMass(60)
			phys:ApplyForceCenter(dmginfo:GetDamageForce())
		end
	end
end