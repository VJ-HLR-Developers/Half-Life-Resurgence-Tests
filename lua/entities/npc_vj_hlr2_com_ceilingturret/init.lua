include("entities/npc_vj_hlr2_com_sentry/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/ceiling_turret.mdl"
ENT.HasDeathCorpse = false
ENT.StartHealth = 250
ENT.SightDistance = 2200
ENT.PoseParameterLooking_TurningSpeed = 25

function ENT:Init()
	self:SetCollisionBounds(Vector(13, 13, 0), Vector(-13, -13, -40))
	self:SetPos(self:GetPos() +Vector(0, 0, 32))
	self.RangeAttackMaxDistance = self.SightDistance
	self.RangeAttackAngleRadius = 180
	self.SightAngle = 90

	self.Turret_Sprite = ents.Create("env_sprite")
	self.Turret_Sprite:SetKeyValue("model", "vj_base/sprites/glow.vmt")
	self.Turret_Sprite:SetKeyValue("scale", "0.1")
	self.Turret_Sprite:SetKeyValue("rendermode", "5")
	self.Turret_Sprite:SetKeyValue("rendercolor", "255 0 0")
	self.Turret_Sprite:SetKeyValue("spawnflags", "1") -- If animated
	self.Turret_Sprite:SetParent(self)
	self.Turret_Sprite:Fire("SetParentAttachment", "light")
	self.Turret_Sprite:Spawn()
	self.Turret_Sprite:Activate()
	self.Turret_Sprite:Fire("HideSprite")
	self:DeleteOnRemove(self.Turret_Sprite)
end

function ENT:OnThinkActive()
	if IsValid(self:GetEnemy()) or self.Alerted then
		self.Turret_StandDown = false
		self.AnimTbl_IdleStand = "idlealert"
		-- Handle the light sprite
		if self.Turret_HasLOS == true and IsValid(self:GetEnemy()) then
			self.Turret_Sprite:Fire("Color", "255 0 0") -- Red
			self.Turret_Sprite:Fire("ShowSprite")
		elseif self.HasPoseParameterLooking == true then -- So when the alert animation is playing, it won't replace the activating light (green)
			self.Turret_Sprite:Fire("Color", "255 165 0") -- Orange
			self.Turret_Sprite:Fire("ShowSprite")
		end

		local scan = false
		local pyaw = self:GetPoseParameter("aim_yaw")

		-- Make it scan around if the enemy is behind, which is unreachable for it!
		if IsValid(self:GetEnemy()) and self.Turret_HasLOS == false and (self:GetForward():Dot((self:GetEnemy():GetPos() - self:GetPos()):GetNormalized()) <= math.cos(math.rad(self.RangeAttackAngleRadius))) then
			scan = true
			self.HasPoseParameterLooking = false
		else
			self.HasPoseParameterLooking = true
		end

		 -- Look around randomly when the enemy is not found
		if !IsValid(self:GetEnemy()) or scan == true then
			-- Playing a beeping noise
			if self.Turret_NextScanBeepT < CurTime() then
				VJ.EmitSound(self, "npc/turret_floor/ping.wav", 75, 100)
				self.Turret_NextScanBeepT = CurTime() + 1
			end
			-- LEFT TO RIGHT
			-- Change the rotation direction when the max number is reached for a direction
			if pyaw >= 60 then
				self.Turret_ScanDirSide = 1
			elseif pyaw <= -60 then
				self.Turret_ScanDirSide = 0
			end
			self:SetPoseParameter("aim_yaw", pyaw + (self.Turret_ScanDirSide == 1 and -8 or 8))
			-- UP AND DOWN
			-- Change the rotation direction when the max number is reached for a direction
			if self:GetPoseParameter("aim_pitch") >= 15 then
				self.Turret_ScanDirUp = 1
			elseif self:GetPoseParameter("aim_pitch") <= -15 then
				self.Turret_ScanDirUp = 0
			end
			self:SetPoseParameter("aim_pitch", self:GetPoseParameter("aim_pitch") + (self.Turret_ScanDirUp == 1 and -3 or 3))
		end
	else
		-- Play the retracting sequence and sound
		if !self.Alerted and self.Turret_StandDown == false then
			self.Turret_Sprite:Fire("Color", "0 150 0") -- Green
			self.Turret_Sprite:Fire("ShowSprite")
			self.Turret_StandDown = true
			self:PlayAnim({"retract"}, true, false)
			VJ.EmitSound(self, "npc/turret_floor/retract.wav", 70, 100)
		end
		if self.Turret_StandDown == true then
			if self:GetPoseParameter("aim_yaw") == 0 then -- Hide the green light once it fully rests
				self.Turret_Sprite:Fire("HideSprite")
			end
			self.AnimTbl_IdleStand = {ACT_IDLE}
		end
	end
end