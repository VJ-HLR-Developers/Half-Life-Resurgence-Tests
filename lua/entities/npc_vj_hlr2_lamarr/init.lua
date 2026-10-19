AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/Lamarr.mdl"
ENT.StartHealth = 200

ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
ENT.AlliedWithPlayerAllies = true
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(8, 10, 15), Vector(-8, -10, 0))

	self.Headcrab_Sleeping = false
	self.Headcrab_NextSleepT = CurTime() + math.random(20, 30)
	self.Headcrab_WakeUpT = 0
	self.Headcrab_SleepAnimT = 0
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	if self.Headcrab_Sleeping then
		self.Headcrab_WakeUpT = 0
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnBleed(dmginfo, hitgroup)
	if self.Headcrab_Sleeping then
		self.Headcrab_WakeUpT = 0
	else
		self.Headcrab_NextSleepT = CurTime() + math.random(20, 30)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()

	if self.Headcrab_Sleeping then
		if CurTime() > self.Headcrab_SleepAnimT then
			self:PlayAnim("SleepLoop", true, false, false)
			VJ.EmitSound(self, "npc/headcrab/idle2.wav", 65, 100)
			self.Headcrab_SleepAnimT = CurTime() +self:SequenceDuration("SleepLoop")
		elseif CurTime() > self.Headcrab_WakeUpT then
			self.Headcrab_Sleeping = false
			self.Headcrab_NextSleepT = CurTime() + math.Rand(15, 45)
			self:SetMaxLookDistance(10000)
			self:SetFOV(160)
		end
		return
	end

	if self.VJ_Controlled then return end

	if !self.Alerted && !IsValid(self:GetEnemy()) && !self:IsMoving() && CurTime() > self.Headcrab_NextSleepT && !self.Headcrab_Sleeping && !self:IsBusy() then
		self.Headcrab_Sleeping = true
		self.Headcrab_WakeUpT = CurTime() +math.Rand(15, 30)
		self:SetState(VJ_STATE_ONLY_ANIMATION)
		self:SetMaxLookDistance(325)
		self:SetFOV(360)
	end
end