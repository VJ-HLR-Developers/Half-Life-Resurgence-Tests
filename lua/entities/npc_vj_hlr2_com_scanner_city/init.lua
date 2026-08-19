AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/Combine_Scanner.mdl"
ENT.StartHealth = 30
ENT.HullType = HULL_TINY
ENT.MovementType = VJ_MOVETYPE_AERIAL
ENT.TurningUseAllAxis = true

ENT.PoseParameterLooking_Names = {pitch={"flex_vert", "tail_control"}, yaw={"flex_horz"}, roll={}}

ENT.Aerial_FlyingSpeed_Calm = 180
ENT.Aerial_FlyingSpeed_Alerted = 250
ENT.AA_GroundLimit = 30
ENT.AA_MinWanderDist = 250
ENT.AA_MoveAccelerate = 3
ENT.Aerial_AnimTbl_Calm = ACT_IDLE
ENT.Aerial_AnimTbl_Alerted = ACT_IDLE

ENT.VJ_NPC_Class = {"CLASS_COMBINE"}

ENT.Bleeds = false

ENT.HasMeleeAttack = false

ENT.ConstantlyFaceEnemy = true
ENT.ConstantlyFaceEnemy_MinDistance = 250

ENT.LimitChaseDistance = true
ENT.LimitChaseDistance_Max = 250
ENT.LimitChaseDistance_Min = 1

ENT.SoundTbl_Breath = "npc/scanner/cbot_fly_loop.wav"
ENT.SoundTbl_CombatIdle = {
	"npc/scanner/combat_scan1.wav",
	"npc/scanner/combat_scan2.wav",
	"npc/scanner/combat_scan3.wav",
	"npc/scanner/combat_scan4.wav",
	"npc/scanner/combat_scan5.wav"
}
ENT.SoundTbl_Idle = {
	"npc/scanner/scanner_scan1.wav",
	"npc/scanner/scanner_scan2.wav",
	"npc/scanner/scanner_scan4.wav",
	"npc/scanner/scanner_scan5.wav",
	-- "npc/scanner/scanner_blip1.wav",
	"npc/scanner/cbot_servochatter.wav"
}
ENT.SoundTbl_Alert = {
	"npc/scanner/scanner_alert1.wav",
	"npc/scanner/cbot_servoscared.wav"
}
ENT.SoundTbl_CallForHelp =
	"npc/scanner/scanner_siren2.wav"

ENT.SoundTbl_Pain = {
	"npc/scanner/scanner_pain1.wav",
	"npc/scanner/scanner_pain2.wav"
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(12, 12, 15), Vector(-12, -12, -15))

	self.DoingCameraAttack = false
	self.NextCameraAttackT = 0

	self.EyeSprite = ents.Create("env_sprite")
	self.EyeSprite:SetKeyValue("model", "vj_base/sprites/glow.vmt")
	self.EyeSprite:SetKeyValue("scale", "0.1")
	self.EyeSprite:SetKeyValue("rendermode", "9")
	self.EyeSprite:SetKeyValue("rendercolor", "255 110 0")
	self.EyeSprite:SetKeyValue("spawnflags", "1")
	self.EyeSprite:SetParent(self)
	self.EyeSprite:SetOwner(self)
	self.EyeSprite:Fire("SetParentAttachment", self:LookupAttachment("eye") > 0 && "eye" or "eyes", 0)
	self.EyeSprite:Spawn()
	self:DeleteOnRemove(self.EyeSprite)

	if !self.HLR_IsClawScanner then
		local envLight = ents.Create("env_projectedtexture")
		envLight:SetLocalPos(self:GetPos())
		envLight:SetLocalAngles(self:GetAngles())
		envLight:SetKeyValue("lightcolor", "255 255 255")
		envLight:SetKeyValue("lightfov", "40")
		envLight:SetKeyValue("farz", "1000")
		envLight:SetKeyValue("nearz", "10")
		envLight:SetKeyValue("shadowquality", "1")
		envLight:Input("SpotlightTexture", NULL, NULL, "effects/flashlight001")
		envLight:SetOwner(self)
		envLight:SetParent(self)
		envLight:Spawn()
		envLight:Fire("setparentattachment", "light")
		self:DeleteOnRemove(envLight)

		local spotlight = ents.Create("beam_spotlight")
		spotlight:SetPos(self:GetPos())
		spotlight:SetAngles(self:GetAngles())
		spotlight:SetKeyValue("spotlightlength", 700)
		spotlight:SetKeyValue("spotlightwidth", 30)
		spotlight:SetKeyValue("spawnflags", "2")
		spotlight:Fire("Color", "255 255 255")
		spotlight:SetParent(self)
		spotlight:Spawn()
		spotlight:Activate()
		spotlight:Fire("setparentattachment", "light")
		spotlight:Fire("lighton")
		spotlight:AddEffects(EF_PARENT_ANIMATES)
		self:DeleteOnRemove(spotlight)
	end

	local glow1 = ents.Create("env_sprite")
	glow1:SetKeyValue("model", "sprites/light_ignorez.vmt")
	glow1:SetKeyValue("scale", "0.6")
	glow1:SetKeyValue("rendermode", "9")
	glow1:SetKeyValue("rendercolor", "255 255 255")
	glow1:SetKeyValue("spawnflags", "0.1")
	glow1:SetParent(self)
	glow1:SetOwner(self)
	glow1:Fire("SetParentAttachment", "light", 0)
	glow1:Spawn()
	self:DeleteOnRemove(glow1)

	local glowLight = ents.Create("light_dynamic")
	glowLight:SetKeyValue("brightness", "4")
	glowLight:SetKeyValue("distance", "30")
	glowLight:SetLocalPos(self:GetPos() +self:OBBCenter())
	glowLight:SetLocalAngles(self:GetAngles())
	glowLight:Fire("Color", "255 255 255")
	glowLight:SetParent(self)
	glowLight:SetOwner(self)
	glowLight:Spawn()
	glowLight:Fire("TurnOn")
	glowLight:Fire("SetParentAttachment", "light", 0)
	self:DeleteOnRemove(glowLight)

	self.ScanLoop = CreateSound(self, VJ.PICK{"npc/scanner/scanner_scan_loop1.wav", "npc/scanner/scanner_scan_loop2.wav", "npc/scanner/combat_scan_loop1.wav", "npc/scanner/combat_scan_loop2.wav", "npc/scanner/combat_scan_loop4.wav", "npc/scanner/combat_scan_loop6.wav"})
	self.ScanLoop:SetSoundLevel(70)

-- dynamo_wheel: 0.5 ( -180, 180 )
-- tail_control: 0.238 ( -25, 80 )
-- alert_control: 0.5 ( -1, 1 )
-- flex_vert: 0.5 ( -20, 20 )
-- flex_horz: 0.5 ( -20, 20 )
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	-- local vel = self:GetVelocity()
	-- self:SetPoseParameter("flex_vert", vel.z)
	-- self:SetPoseParameter("flex_horz", -vel.x)
	-- self:SetPoseParameter("tail_control", vel.y)
	self:SetPoseParameter("dynamo_wheel", Lerp(FrameTime() *3, self:GetPoseParameter("dynamo_wheel"), self:GetPoseParameter("dynamo_wheel") +1))
	self:SetPoseParameter("alert_control", IsValid(self:GetEnemy()) && Lerp(FrameTime() *5, self:GetPoseParameter("alert_control"), 1) || Lerp(FrameTime() *3, self:GetPoseParameter("alert_control"), 0))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkAttack(isAttacking, enemy)
	local dist = self.EnemyData.DistanceNearest
	if dist <= self.LimitChaseDistance_Max && CurTime() > self.NextCameraAttackT && !self.DoingCameraAttack && math.random(1, 20) == 1 then
		self.DoingCameraAttack = true
		VJ.CreateSound(self, "npc/scanner/scanner_blip1.wav", 75)
		if !self.HLR_IsClawScanner then
			self:PlayAnim("flare", true, false, false, 0, {OnFinish=function(interrupted, anim)
				VJ.CreateSound(self, "npc/scanner/scanner_photo1.wav", 75)
				for _, v in pairs(ents.FindInSphere(self:GetPos() +self:GetForward(), 175)) do
					if v:IsPlayer() then
						v:ScreenFade(SCREENFADE.IN, Color(255, 255, 255), 1, 2)
					end
				end
				local att = self:GetAttachment(self:LookupAttachment("light"))
				local trace = {}
				trace.start = att.Pos
				trace.endpos = att.Pos +att.Ang:Forward() *256
				trace.filter = self
				local tr = util.TraceLine(trace)

				local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
				util.Effect("camera_flash", effectdata, true)
				self:PlayAnim("retract", true, false, false, 0, {OnFinish=function(interrupted, anim)
					self.DoingCameraAttack = false
					self.NextCameraAttackT = CurTime() +10
				end})
			end})
		else
			VJ.CreateSound(self, "npc/scanner/scanner_photo1.wav", 75)
			for _, v in pairs(ents.FindByClass("npc_vj_hlr2_com_strider")) do
				if v:CheckRelationship(v) == D_LI && !IsValid(v:GetEnemy()) && !v:IsBusy() then
					v:ForceSetEnemy(self, true)
					v:SCHEDULE_ALERT_CHASE(true)
				end
			end
			for _, v in pairs(ents.FindInSphere(self:GetPos() +self:GetForward(), 175)) do
				if v:IsPlayer() then
					v:ScreenFade(SCREENFADE.IN, Color(255, 255, 255), 1, 2)
				end
			end
			local att = self:GetAttachment(self:LookupAttachment("light"))
			local trace = {}
			trace.start = att.Pos
			trace.endpos = att.Pos +att.Ang:Forward() *256
			trace.filter = self
			local tr = util.TraceLine(trace)

			local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			util.Effect("camera_flash", effectdata, true)

			self.DoingCameraAttack = false
			self.NextCameraAttackT = CurTime() +10
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnAlert(ent)
	self.ScanLoop:Stop()
	self.ScanLoop:Play()
	if self.HLR_IsClawScanner then
		for _, v in pairs(ents.FindByClass("npc_vj_hlr2_com_strider")) do
			if v:CheckRelationship(v) == D_LI && !IsValid(v:GetEnemy()) && !v:IsBusy() then
				v:ForceSetEnemy(self, true)
				v:SCHEDULE_ALERT_CHASE(true)
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnResetEnemy()
	self.ScanLoop:Stop()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmginfo, hitgroup, status)
	if status == "Init" then
		ParticleEffect("explosion_turret_break", self:GetPos(), Angle(), nil)
		ParticleEffect("electrical_arc_01_system", self:GetPos(), Angle(), nil)
		util.BlastDamage(self, self, self:GetPos(), 80, 20)
		VJ.EmitSound(self, "npc/scanner/scanner_electric2.wav", 80)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	self.ScanLoop:Stop()
end