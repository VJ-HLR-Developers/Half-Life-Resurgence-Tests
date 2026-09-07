AddCSLuaFile()

ENT.Base = "prop_vj_animatable"
ENT.Type = "anim"
ENT.PrintName = "Mounted Turret"
ENT.Author = "Cpt. Hazama"
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
ENT.Category = "Half-Life Resurgence"

if CLIENT then return end

local animTbl = {
	["idle"] = "idle_inactive",
	["idle_mounted"] = "idle",
	["mount"] = "activate",
	["dismount"] = "retract"
}

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_barricade_short01a.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	local turret = ents.Create("prop_vj_animatable")
	turret:SetModel("models/props_combine/bunker_gun01.mdl")
	turret:SetPos(self:GetPos() +self:GetUp() *8 +self:GetForward() *-3.4)
	turret:SetAngles(self:GetAngles())
	turret:Spawn()
	turret:SetParent(self)
	turret:SetMoveType(MOVETYPE_NONE)
	turret:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:DeleteOnRemove(turret)
	turret:ResetSequence(animTbl["idle"])
	self.Emplacement = turret

	local envLight = ents.Create("env_projectedtexture")
	envLight:SetLocalPos(self:GetPos())
	envLight:SetLocalAngles(self:GetAngles())
	envLight:SetKeyValue("lightcolor", "255 247 206")
	envLight:SetKeyValue("lightfov", "50")
	envLight:SetKeyValue("farz", "2400")
	envLight:SetKeyValue("nearz", "10")
	envLight:SetKeyValue("shadowquality", "1")
	envLight:Input("SpotlightTexture", NULL, NULL, "effects/flashlight001")
	envLight:SetOwner(self)
	envLight:SetParent(turret)
	envLight:Spawn()
	envLight:Fire("setparentattachment", "light")
	self:DeleteOnRemove(envLight)

	local spotlight = ents.Create("beam_spotlight")
	spotlight:SetPos(self:GetPos())
	spotlight:SetAngles(self:GetAngles())
	spotlight:SetKeyValue("spotlightlength", 2200)
	spotlight:SetKeyValue("spotlightwidth", 50)
	spotlight:SetKeyValue("spawnflags", "2")
	spotlight:Fire("Color", "255 247 206")
	spotlight:SetParent(turret)
	spotlight:Spawn()
	spotlight:Activate()
	spotlight:Fire("setparentattachment", "light")
	spotlight:Fire("lighton")
	spotlight:AddEffects(EF_PARENT_ANIMATES)
	self:DeleteOnRemove(spotlight)

	local glow1 = ents.Create("env_sprite")
	glow1:SetKeyValue("model", "sprites/light_ignorez.vmt")
	glow1:SetKeyValue("scale", "0.4")
	glow1:SetKeyValue("rendermode", "9")
	glow1:SetKeyValue("rendercolor", "255 247 206")
	glow1:SetKeyValue("spawnflags", "0.1")
	glow1:SetParent(turret)
	glow1:SetOwner(self)
	glow1:Fire("SetParentAttachment", "light", 0)
	glow1:Spawn()
	self:DeleteOnRemove(glow1)

	self.Operator = nil
	self.DetectedOperator = nil
	self.Gun_Status = 0 -- 0 = Not in use | 1 = Changing Status | 2 = In use | 3 = Overheated
	self.Overheat = 0
	self.OverheatRechargeT = 0
	self.LastShotT = 0
end

function ENT:ManGun(ent)
	self.Operator = ent
	self.OperatorData = {
		OldIdle = ent.AnimationTranslations[ACT_IDLE],
		OldCover = ent.AnimationTranslations[ACT_COVER_LOW],
		OldTurnSpeed = ent:GetMaxYawSpeed(),
		OldMoveType = ent:GetMoveType(),
	}
	ent:StopMoving()
	ent:ClearSchedule()
	ent:SetState(VJ_STATE_ONLY_ANIMATION_NOATTACK)
	ent:SetMoveType(MOVETYPE_NONE)
	ent:SetMaxYawSpeed(0)
	ent:SetWeaponState(VJ.WEP_STATE_HOLSTERED)
	local wep = ent:GetActiveWeapon()
	if IsValid(wep) then
		wep:SetNoDraw(true)
		wep:DrawShadow(false)
	end
	ent.AnimationTranslations[ACT_IDLE] = ACT_IDLE_MANNEDGUN
	ent.AnimationTranslations[ACT_COVER_LOW] = ACT_IDLE_MANNEDGUN
	self.VJ_HLR_ApproachingTurret = false
	self.VJ_HLR_ManningTurret = true
	self.DetectedOperator = NULL
end

function ENT:UnMan()
	local operator = self.Operator
	local data = self.OperatorData
	operator:SetState()
	operator:SetMaxYawSpeed(data.OldTurnSpeed)
	operator:SetMoveType(data.OldMoveType)
	operator.AnimationTranslations[ACT_IDLE] = data.OldIdle
	operator.AnimationTranslations[ACT_COVER_LOW] = data.OldCover
	operator:SetWeaponState()
	local wep = operator:GetActiveWeapon()
	if IsValid(wep) then
		wep:SetNoDraw(false)
		wep:DrawShadow(true)
	end
	operator:SetPos(operator:GetPos() +operator:GetForward() *-16 +self:GetUp() *6)

	operator.VJ_HLR_NextApproachTurretT = CurTime() +10
	operator.VJ_HLR_ApproachingTurret = false
	operator.VJ_HLR_ManningTurret = false
	local turret = self.Emplacement
	turret:SetPoseParameter("aim_pitch", 0)
	turret:SetPoseParameter("aim_yaw", 0)
	self.Operator = NULL
end

function ENT:Think()
	local turret = self.Emplacement
	if !IsValid(turret) then
		self:Remove()
		return
	end

	local curTime = CurTime()
	local operator = self.Operator
	if IsValid(operator) then
		if self.Gun_Status != 2 && self.Gun_Status != 1 then
			self.Emplacement:ResetSequence(animTbl["mount"])
			self:EmitSound("weapons/shotgun/shotgun_cock.wav", 70, 100)
			self.Gun_Status = 1
			timer.Simple(1.3, function()
				if IsValid(self) then
					self.Gun_Status = 2
					self:EmitSound("buttons/combine_button1.wav", 70, 100)
				end
			end)
		elseif self.Gun_Status == 2 then
			self.Emplacement:ResetSequence(animTbl["idle_mounted"])
		end
	else
		if self.Gun_Status == 2 && self.Gun_Status != 1 then
			self.Emplacement:ResetSequence(animTbl["dismount"])
			self:EmitSound("weapons/shotgun/shotgun_cock.wav", 70, 92)
			self.Gun_Status = 1
			timer.Simple(1.3, function()
				if IsValid(self) then
					self.Gun_Status = 0
					self:EmitSound("buttons/combine_button2.wav", 70, 100)
				end
			end)
		elseif self.Gun_Status == 0 then
			self.Emplacement:ResetSequence(animTbl["idle"])
		end
	end
	if curTime > self.LastShotT then
		self.Overheat = 0
	end
	if curTime > self.OverheatRechargeT && turret.Loop then
		turret:StopParticles()
		turret.Loop:Stop()
	end
	self.TargetPos = self:GetPos() +self:GetForward() *-50
	self.HandlePos = self:GetPos() +self:GetForward() *-40 +self:GetUp() *-31
	if !IsValid(operator) then
		self:UpdatePoseParamTracking(true)
		local possibleOperator = self.DetectedOperator
		if !IsValid(possibleOperator) then
			for _, v in ipairs(ents.FindInSphere(self:GetPos(), 500)) do
				if v:IsNPC() && v:Visible(self) && v.IsVJBaseSNPC && VJ.AnimExists(v, ACT_IDLE_MANNEDGUN) && (!v.VJ_HLR_ApproachingTurret && !v.VJ_HLR_ManningTurret) then
					if v.VJ_HLR_NextApproachTurretT && v.VJ_HLR_NextApproachTurretT > curTime then return end
					self.DetectedOperator = v
					v.VJ_HLR_ApproachingTurret = true
					break
				end
			end
		else
			possibleOperator:SetLastPosition(self.TargetPos)
			possibleOperator:SCHEDULE_GOTO_POSITION(possibleOperator.Alerted && "TASK_RUN_PATH" or "TASK_WALK_PATH")
			if possibleOperator:GetPos():Distance(self.TargetPos) <= 50 then
				possibleOperator:SetPos(self.TargetPos)
				self:ManGun(possibleOperator)
			end
		end
	else
		operator:SetPos(self.HandlePos)
		operator:SetAngles(self:GetAngles())
		if IsValid(operator:GetEnemy()) then
			local ene = operator:GetEnemy()
			if (turret:GetForward():Dot((ene:GetPos() -turret:GetPos()):GetNormalized()) > math.cos(math.rad(operator:GetFOV() / 2))) && (ene:GetPos():Distance(self:GetPos()) < 3500) then
				if self:Visible(ene) then
					self:FireEmplacement()
				end
			else
				if ene:GetPos():Distance(operator:GetPos()) <= 500 then
					self:UnMan()
				end
			end
		end
		self:UpdatePoseParamTracking()
	end
	self:NextThink(curTime +0.065)
	return true
end

function ENT:FireEmplacement()
	if self.Gun_Status != 2 or self.OverheatRechargeT > CurTime() then return end
	local operator = self.Operator
	if !IsValid(operator) then return end
	local turret = self.Emplacement
	local att = turret:GetAttachment(1)
	local bullet = {}
	bullet.Num = 1
	bullet.Src = att.Pos
	bullet.Dir = (operator:GetEnemy():GetPos() +operator:GetEnemy():OBBCenter()) -att.Pos
	-- bullet.Dir = att.Ang:Forward()
	bullet.Callback = function(attacker, tr, dmginfo)
		local laserhit = EffectData()
		laserhit:SetOrigin(tr.HitPos)
		laserhit:SetNormal(tr.HitNormal)
		laserhit:SetScale(25)
		util.Effect("AR2Impact", laserhit)
	end
	bullet.Spread = Vector(math.random(-45, 45), math.random(-45, 45), math.random(-45, 45))
	-- bullet.Spread = Vector(0.045, 0.045, 0)
	bullet.Tracer = 1
	bullet.TracerName = "AirboatGunTracer"
	bullet.Force = 3
	bullet.Damage = self.Operator:ScaleByDifficulty(7)
	bullet.AmmoType = "SMG1"
	turret:FireBullets(bullet)
	self.LastShotT = CurTime() +6
	self.Overheat = self.Overheat +1
	if self.Overheat >= 250 then
		self.OverheatRechargeT = CurTime() +6
		self.Overheat = 0
		for i = 1, 5 do
			timer.Simple(i, function()
				if IsValid(self) then
					sound.Play("ambient/alarms/warningbell1.wav", turret:GetPos(), 72, 100 *GetConVarNumber("host_timescale"))
				end
			end)
		end
		ParticleEffectAttach("vj_smoke_white_narrow", PATTACH_POINT_FOLLOW, turret, 1)
		turret.Loop = CreateSound(turret, "ambient/gas/steam2.wav")
		turret.Loop:SetSoundLevel(72)
		turret.Loop:Play()
	end
	ParticleEffectAttach("vj_muzzle_ar2_main", PATTACH_POINT_FOLLOW, turret, 1)
	-- ParticleEffectAttach("vj_rifle_full_blue", PATTACH_POINT_FOLLOW, turret, 1)
	turret:ResetSequence("fire")
	sound.Play("^weapons/ar1/ar1_dist2.wav", turret:GetPos(), 90, 100 +(self.Overheat /4) *GetConVarNumber("host_timescale"))
end

function ENT:OnRemove()
	local turret = self.Emplacement
	if IsValid(turret) then
		if turret.Loop then
			turret.Loop:Stop()
		end
		turret:StopParticles()
	end
	if IsValid(self.Operator) then
		self:UnMan()
	end
	self:StopParticles()
end

local math_angDif = math.AngleDifference
local math_angApproach = math.Approach
function ENT:UpdatePoseParamTracking(resetPoses)
	if !IsValid(self.Operator) then return end
	local operator = self.Operator
	local turret = self.Emplacement
	local ene = operator:GetEnemy()
	local newPitch = 0
	local newYaw = 0
	if IsValid(ene) && !resetPoses then
		local myEyePos = operator:EyePos()
		local myAng = self:GetAngles()
		local enePos = operator:GetAimPosition(ene, myEyePos)
		local eneAng = (enePos -myEyePos):Angle()
		newPitch = math_angDif(eneAng.p, myAng.p) +10
		newYaw = math_angDif(eneAng.y, myAng.y) *1.05
		newRoll = math_angDif(eneAng.z, myAng.z)
	end

	operator:SetPoseParameter("aim_pitch", math_angApproach(operator:GetPoseParameter("aim_pitch"), newPitch, 10))
	operator:SetPoseParameter("aim_yaw", math_angApproach(operator:GetPoseParameter("aim_yaw"), newYaw, 10))
	turret:SetPoseParameter("aim_pitch", math_angApproach(turret:GetPoseParameter("aim_pitch"), newPitch, 10))
	turret:SetPoseParameter("aim_yaw", math_angApproach(turret:GetPoseParameter("aim_yaw"), newYaw, 10))
end