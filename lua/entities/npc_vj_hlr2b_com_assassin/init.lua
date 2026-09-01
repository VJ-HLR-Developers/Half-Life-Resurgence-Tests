AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2b/combine_assassin.mdl"
ENT.StartHealth = 65
ENT.HullType = HULL_HUMAN
ENT.JumpParams = {
	MaxRise = 620,
	MaxDrop = 620,
	MaxDistance = 620
}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.BloodColor = VJ.BLOOD_COLOR_RED

ENT.HasMeleeAttack = true
ENT.MeleeAttackDamage = 10
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 55
ENT.MeleeAttackDamageDistance = 90
ENT.TimeUntilMeleeAttackDamage = false

ENT.CanTurnWhileMoving = false
ENT.Weapon_IgnoreSpawnMenu = true
ENT.Weapon_Strafe = false
ENT.AnimTbl_WeaponAttackGesture = true

ENT.AnimTbl_CallForHelp = false

ENT.AnimTbl_ShootWhileMovingRun = ACT_SPRINT -- Animations it will play when shooting while running | NOTE: Weapon may translate the animation that they see fit!
ENT.AnimTbl_ShootWhileMovingWalk = ACT_RUN -- Animations it will play when shooting while walking | NOTE: Weapon may translate the animation that they see fit!

ENT.DisableFootStepSoundTimer = true
ENT.AnimTbl_TakingCover = ACT_IDLE_ANGRY

ENT.DropDeathLoot = false

ENT.SoundTbl_BeforeMeleeAttack = {"npc/metropolice/pain1.wav", "npc/metropolice/pain2.wav", "npc/metropolice/pain3.wav", "npc/metropolice/pain4.wav"}
ENT.SoundTbl_Pain = {"npc/combine_soldier/pain1.wav", "npc/combine_soldier/pain2.wav", "npc/combine_soldier/pain3.wav"}
ENT.SoundTbl_Death = {"npc/combine_soldier/die1.wav", "npc/combine_soldier/die2.wav", "npc/combine_soldier/die3.wav"}

ENT.MainSoundPitch = 145

ENT.Assassin_NextJumpT = 0
ENT.Assassin_OffGround = false
ENT.Assassin_CloakLevel = 1
ENT.Assassin_NextCloakT = 0
ENT.Assassin_NextDodgeT = CurTime()
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetAnimationTranslations(wepHoldType)
	self.AnimationTranslations[ACT_RANGE_ATTACK1] 				= ACT_RANGE_ATTACK1
	self.AnimationTranslations[ACT_GESTURE_RANGE_ATTACK1] 		= ACT_RANGE_ATTACK1
	self.AnimationTranslations[ACT_RANGE_ATTACK1_LOW] 			= ACT_RANGE_ATTACK1
	self.AnimationTranslations[ACT_RELOAD] 						= ACT_IDLE_ANGRY
	self.AnimationTranslations[ACT_COVER_LOW] 					= ACT_IDLE_ANGRY
	self.AnimationTranslations[ACT_RELOAD_LOW] 					= ACT_IDLE_ANGRY

	self.AnimationTranslations[ACT_IDLE] 						= ACT_IDLE
	self.AnimationTranslations[ACT_IDLE_ANGRY] 					= ACT_IDLE_ANGRY

	self.AnimationTranslations[ACT_WALK] 						= ACT_WALK
	self.AnimationTranslations[ACT_WALK_AIM] 					= ACT_WALK
	self.AnimationTranslations[ACT_WALK_CROUCH] 				= ACT_WALK
	self.AnimationTranslations[ACT_WALK_CROUCH_AIM] 			= ACT_WALK

	self.AnimationTranslations[ACT_RUN] 						= ACT_RUN
	self.AnimationTranslations[ACT_RUN_AIM] 					= ACT_RUN
	self.AnimationTranslations[ACT_RUN_CROUCH] 					= ACT_RUN
	self.AnimationTranslations[ACT_RUN_CROUCH_AIM] 				= ACT_RUN
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(13, 13, 60), Vector(-13, -13, 0))
	-- self:SetRenderMode(RENDERMODE_TRANSADD)

		util.SpriteTrail(self, 5, Color(255, 0, 0), true, 12, 1, 0.25, 1 /(25 +1) *0.5, "VJ_Base/sprites/trail.vmt")
		local spriteGlow = ents.Create("env_sprite")
		spriteGlow:SetKeyValue("rendercolor", "255 0 0")
		spriteGlow:SetKeyValue("GlowProxySize", "2.0")
		spriteGlow:SetKeyValue("HDRColorScale", "1.0")
		spriteGlow:SetKeyValue("renderfx", "14")
		spriteGlow:SetKeyValue("rendermode", "3")
		spriteGlow:SetKeyValue("renderamt", "255")
		spriteGlow:SetKeyValue("disablereceiveshadows", "0")
		spriteGlow:SetKeyValue("mindxlevel", "0")
		spriteGlow:SetKeyValue("maxdxlevel", "0")
		spriteGlow:SetKeyValue("framerate", "10.0")
		spriteGlow:SetKeyValue("model", "VJ_Base/sprites/glow.vmt")
		spriteGlow:SetKeyValue("spawnflags", "0")
		spriteGlow:SetKeyValue("scale", "0.1")
		spriteGlow:SetParent(self)
		spriteGlow:Fire("SetParentAttachment", "eyes")
		spriteGlow:Spawn()
		self:DeleteOnRemove(spriteGlow)

	self:Give("weapon_vj_hlr_dualpistol")
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCreateSound(sdData, sdFile)
	if VJ.HasValue(self.SoundTbl_BeforeMeleeAttack, sdFile) then return end
	VJ.EmitSound(self, "npc/combine_soldier/vo/on" .. math.random(1, 2) .. ".wav")
	timer.Simple(SoundDuration(sdFile), function() if IsValid(self) && sdData:IsPlaying() then VJ.EmitSound(self, "npc/combine_soldier/vo/off" .. math.random(1, 3) .. ".wav") end end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key, activator, caller, data)
	if key == "Foot" then
		VJ.EmitSound(self, "npc/footsteps/hardboot_generic2.wav", 72, 100)
		VJ.EmitSound(self, {"npc/stalker/stalker_footstep_left1.wav", "npc/stalker/stalker_footstep_left2.wav", "npc/stalker/stalker_footstep_right1.wav", "npc/stalker/stalker_footstep_right2.wav"}, 75)
	elseif key == "left" or key == "right" then
		local wep = self:GetActiveWeapon()
		if IsValid(wep) then
			wep.CurrentMuzzle = key
		end
	end
	if string.StartWith(key, "melee") then
		self:ExecuteMeleeAttack()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThink()
	if IsValid(self:GetActiveWeapon()) then
		self:GetActiveWeapon():SetClip1(999)
	end

	if self.Dead then return end
	local validEnt = IsValid(self:GetEnemy())
	local cloaked = self:GetCloaked()
	-- local cloaklvl = math.Clamp(self.Assassin_CloakLevel *255, 40, 255)
	-- self:SetColor(Color(255, 255, 255, math.Clamp(self.Assassin_CloakLevel * 255, 40, 255)))
	-- self.Assassin_CloakLevel = math.Clamp(self.Assassin_CloakLevel + 0.05, 0, 1)
	-- if cloaklvl <= 220 then -- Yete asorme tsadz e, ere vor mouys NPC-nere chi desnen iren!
	if cloaked && CurTime() > self:GetFireTime() && self:GetMoveVelocity():Length() <= 60 then -- Yupe sa pee pee inz la poo poo
		self:AddFlags(FL_NOTARGET)
		self:DrawShadow(false)
	else
		self:DrawShadow(true)
		self:RemoveFlags(FL_NOTARGET)
	end

	if self.Assassin_OffGround == true then
		if self:GetVelocity().z == 0 then
			self.Assassin_OffGround = false
			self:ClearSchedule()
			self:StopMoving()
			self:PlayAnim(ACT_LAND, true, false, false)
			self.AnimTbl_IdleStand = {ACT_IDLE}
		else
			if self:GetActivity() != ACT_GLIDE then
				self:PlayAnim(ACT_GLIDE, true, false, false)
			end
		end
	end
	if (self.VJ_IsBeingControlled && self.VJ_TheController:KeyDown(IN_RELOAD) or !self.VJ_IsBeingControlled && validEnt && !cloaked) && CurTime() > self.Assassin_NextCloakT then
		self:SetCloaked(!cloaked)
		VJ.EmitSound(self, "npc/roller/mine/combine_mine_deploy1.wav", 60, self:GetCloaked() && 120 or 100)
		self.Assassin_NextCloakT = CurTime() +1
	elseif !self.VJ_IsBeingControlled && !self.Alerted && cloaked then
		self:SetCloaked(false)
		self.Assassin_NextCloakT = CurTime() +1
	end
	if (self.VJ_IsBeingControlled && self.VJ_TheController:KeyDown(IN_JUMP) or validEnt && !self.VJ_IsBeingControlled && CurTime() > self.Assassin_NextDodgeT && !self:IsMoving() && self:GetPos():Distance(self:GetEnemy():GetPos()) < 2200) && self:IsOnGround() then
		self:Dodge()
	end
	if validEnt && self.WeaponAttackState == VJ.WEP_ATTACK_STATE_FIRE_STAND && self.VJ_IsBeingControlled == false && CurTime() > self.Assassin_NextJumpT && !self:IsMoving() && self:GetPos():Distance(self:GetEnemy():GetPos()) < 1400 then
		self:StopMoving()
		self:SetGroundEntity(NULL)
		if math.random(1, 2) == 1 then
			self:SetLocalVelocity(((self:GetPos() + self:GetRight()*100) - (self:GetPos() + self:OBBCenter())):GetNormalized()*200 +self:GetForward()*1 +self:GetUp()*600 + self:GetRight()*1)
		else
			self:SetLocalVelocity(((self:GetPos() + self:GetRight()*-100) - (self:GetPos() + self:OBBCenter())):GetNormalized()*200 +self:GetForward()*1 +self:GetUp()*600 + self:GetRight()*1)
		end
		self.AnimTbl_IdleStand = ACT_GLIDE
		self:PlayAnim(ACT_JUMP, true, false, true, 0, {}, function(sched)
			self.Assassin_OffGround = true
			self:PlayAnim(ACT_GLIDE, true, false, false)
		end)
		self.Assassin_NextJumpT = CurTime() + 8
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Dodge()
	if !self:IsBusy() then
		if self.VJ_IsBeingControlled then
			local ply = self.VJ_TheController
			self:PlayAnim((ply:KeyDown(IN_MOVELEFT) && "FlipLeft") or (ply:KeyDown(IN_MOVERIGHT) && "FlipRight") or (ply:KeyDown(IN_FORWARD) && "FlipForwardB") or "flipback", true, false, true)
			self.Assassin_NextDodgeT = CurTime() +math.Rand(2, 6)
		else
			local checkdist = self:VJ_CheckAllFourSides(400)
			local randmove = {}
			if checkdist.Backward == true then randmove[#randmove+1] = "Backward" end
			if checkdist.Right == true then randmove[#randmove+1] = "Right" end
			if checkdist.Left == true then randmove[#randmove+1] = "Left" end
			if checkdist.Forward == true then randmove[#randmove+1] = "Forward" end
			local pickmove = VJ.PICK(randmove)
			local anim = "flipback"
			if pickmove == "Right" then anim = "FlipRight" end
			if pickmove == "Left" then anim = "FlipLeft" end
			if pickmove == "Forward" then anim = "FlipForwardB" end
			if type(pickmove) == "table" && #pickmove == 4 then
				anim = VJ.PICK({"flipback", "FlipRight", "FlipLeft", "FlipForwardB"})
			end
			if pickmove == "Backward" or pickmove == "Right" or pickmove == "Left" then
				self:PlayAnim(anim, true, false, true)
				self.Assassin_NextDodgeT = CurTime() +math.Rand(2, 6)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnFireBullet(data)
	self.Assassin_CloakLevel = 0
	self:SetFireTime(CurTime() + 1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnWeaponCanFire()
	if self.Assassin_OffGround == true then return false end
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnBleed(dmginfo, hitgroup)
	if !self.VJ_IsBeingControlled && CurTime() > self.Assassin_NextDodgeT && !self:IsMoving() && self:IsOnGround() then
		self:Dodge()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmginfo, hitgroup, status)
	if status == "Finish" then
		self:SetCloaked(false)
		self:SetBodygroup(1, 1)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeathWeaponDrop(dmginfo, hitgroup, wepEnt)
	wepEnt:Remove()
	for i = 1, 2 do
		local att = self:GetAttachment(2 +i)
		local pistol = ents.Create("weapon_vj_9mmpistol")
		pistol:SetPos(att.Pos)
		pistol:SetAngles(att.Ang)
		pistol:Spawn()
	end
end