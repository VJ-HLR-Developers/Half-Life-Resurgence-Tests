AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/advisor_ep2.mdl"
ENT.StartHealth = 1000
ENT.HullType = HULL_LARGE
ENT.VJ_ID_Boss = true
ENT.MovementType = VJ_MOVETYPE_AERIAL
ENT.Aerial_FlyingSpeed_Calm = 340
ENT.Aerial_FlyingSpeed_Alerted = 470
ENT.AA_MoveAccelerate = 3
ENT.AA_MoveDecelerate = 2
ENT.Aerial_AnimTbl_Calm = ACT_IDLE
ENT.Aerial_AnimTbl_Alerted = ACT_IDLE_ANGRY
ENT.TurningUseAllAxis = true
ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.BloodColor = VJ.BLOOD_COLOR_YELLOW

ENT.HasMeleeAttack = true
ENT.AnimTbl_MeleeAttack = ACT_MELEE_ATTACK1
ENT.MeleeAttackDistance = 105
ENT.MeleeAttackDamageDistance = 145
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDamage = 55

ENT.ConstantlyFaceEnemy = true
ENT.ConstantlyFaceEnemy_IfVisible = true
ENT.ConstantlyFaceEnemy_IfAttacking = false
ENT.ConstantlyFaceEnemy_Postures = "Both"
ENT.ConstantlyFaceEnemy_MinDistance = 7500
ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "advisor.camera",
	FirstP_Offset = Vector(8,0,4)
}
ENT.LimitChaseDistance = true
ENT.LimitChaseDistance_Max = 4000
ENT.LimitChaseDistance_Min = 0

ENT.CanFlinch = true
ENT.AnimTbl_Flinch = ACT_BIG_FLINCH

ENT.HasSoundTrack = true
ENT.SoundTbl_SoundTrack = "music/vlvx_song23ambient.mp3"
ENT.SoundTbl_Breath = "ambient/atmosphere/city_beacon_loop1.wav"
ENT.SoundTbl_Idle = "vj_hlr/src/npc/advisor/advisor_speak01.wav"
ENT.SoundTbl_BeforeMeleeAttack = "vj_hlr/src/npc/advisor/advisorattack03.wav"
ENT.SoundTbl_Pain = "vj_hlr/src/npc/advisor/pain.wav"
ENT.SoundTbl_Death = "vj_hlr/src/npc/advisor/advisor_scream.wav"
ENT.BreathSoundLevel = 60

ENT.MaxLevitatedProps = 20
ENT.LevitationRadius = 1100
ENT.LevitationScanInterval = 0.5
ENT.LevitationSpeed = 650
ENT.LevitationRotationSpeed = 25
ENT.LevitationOrbitSpeed = 0.15
ENT.PhysicsThrowCount = 3
ENT.PhysicsThrowSpeed = 2400
ENT.PhysicsThrowSteering = true
ENT.AttackCooldown = 3.5
ENT.ShieldMaxHealth = 400
ENT.ShieldRegenDelay = 8
ENT.ShieldBlastThreshold = 35
ENT.HasPsychicPull = true -- Tongue Attack
ENT.PsychicPullRange = 1600
ENT.PsychicPullSpeed = 1750
ENT.PsychicPullDuration = 6
ENT.PsychicPullCooldown = 12
ENT.PsychicPullFirstDelay = 5
ENT.PsychicPullApproachRange = 1700
ENT.HasAvalanche = true -- Slams downward and unleashes all the props it currently has at its enemy
ENT.HasSpitAttack = true
ENT.HasRetreat = true
ENT.RetreatDamageThreshold = 260
ENT.HasSummonAttack = false
ENT.Spawnables = {
	{ent="npc_vj_hlr2_com_strider",offset=0},
	{ent="npc_vj_hlr2_com_mortar",offset=50},
	{ent="npc_vj_hlr2_com_crab",offset=0},
	{ent="npc_vj_hlr2_com_hunter",offset=0},
	{ent="npc_vj_hlr2_com_soldier",offset=0,weapons={"weapon_vj_smg1","weapon_vj_ar2"}},
	{ent="npc_vj_hlr2_com_shotgunner",offset=0,weapons={"weapon_vj_spas12"}},
	{ent="npc_vj_hlr2_com_elite",offset=0,weapons={"weapon_vj_ar2","weapon_vj_hlr2_reager"}}
}
ENT.MaxSummons = 3
ENT.SummonCooldown = 25
ENT.HasScreenFX = true
ENT.HasProjectileDefense = true
ENT.ProjectileDefenseRadius = 900
ENT.ProjectileDefenseInterval = 0.08
ENT.GrenadeReturnSpeed = 1800
ENT.ProjectileDeflectSpeed = 2000
---------------------------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("VJ.HLR.AdvisorScreenFX")
--
local function targetAlive(ent,allowBullseye) // Avoid doing a bunch of checks else where in the code
	if !IsValid(ent) or IsValid(ent) && (allowBullseye && (ent.IsVJBaseBullseye or ent:GetClass() == "obj_vj_bullseye")) then
        return false
    end
	if ent:IsPlayer() then
        return ent:Alive()
    end
	return (ent:IsNPC() or ent:IsNextBot()) && ent:Health() > 0
end

local function getDir(vec,fallBack)
	return vec:Length() > 0.03162277660168379 && vec:GetNormalized() or fallBack or Vector(1,0,0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(-38,-38,-30),Vector(38,38,30))

	self.LevitatedProps = {}
	self.RecentThrownProps = {}
	self.DeflectedProjectiles = {}
	self.NextDefenseT = 0
	self.CurAttack = nil
	self.NextScanT = 0
	self.NextPhysicsT = 0
	self.NextBrainT = 0
	self.NextFXT = CurTime() +math.Rand(5,9)
	self.NextAttackT = CurTime() +math.Rand(2,4)
	self.NextPullT = CurTime() +self.PsychicPullFirstDelay
	self.NextApproachT = 0
	self.NextSummonT = CurTime() +12
	self.ShieldRecoverT = 0
	self.RetreatEndT = 0
	self.InvulnerableT = 0
	self.DamageHistory = {}
	self.Summons = {}
	self.PsionicAttacking = false

    self:SetPsionicEffect(false)
	self:SetPullTarget(NULL)
	self:ShieldCode(true,true)

    timer.Simple(0,function()
        if IsValid(self) then
            self:SetPos(self:GetPos() +Vector(0,0,100))
        end
    end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnMeleeAttack(status,enemy)
	if status == "PreInit" then
        return self.CurAttack != nil or CurTime() < self.RetreatEndT
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ShieldCode(enable,silent)
	if self.HasShield == enable && !silent then return end
	self.HasShield = enable
    self:SetAdvisorShield(enable)
	self.ShieldHealth = enable && self.ShieldMaxHealth or 0
	self.BloodParticle = enable && "hunter_shield_impact" or "vj_blood_impact_yellow"
	if enable then
		ParticleEffectAttach("advisor_psychic_shield_idle",PATTACH_ABSORIGIN_FOLLOW,self,0)
		if !silent then
            VJ.EmitSound(self,"ambient/energy/whiteflash.wav",85)
        end
	else
		self:StopParticles()
		ParticleEffect("vj_aurora_shockwave",self:WorldSpaceCenter(),Angle(),nil)
		VJ.EmitSound(self,"ambient/energy/whiteflash.wav",105)
		self.ShieldRecoverT = CurTime() +self.ShieldRegenDelay
		self:ReleaseProps()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDamaged(dmginfo,hitgroup,status)
	if status == "PreDamage" then
		if CurTime() < self.InvulnerableT then
            dmginfo:SetDamage(0)
            return
        end
		if self.HasShield then
			local dmg = dmginfo:GetDamage()
			self.ShieldHealth = self.ShieldHealth -(dmginfo:IsDamageType(DMG_BLAST) && dmg >= self.ShieldBlastThreshold && self.ShieldMaxHealth or dmg *(dmginfo:IsDamageType(DMG_BLAST) && 2 or 1))
			if self.ShieldHealth <= 0 then
                self:ShieldCode(false)
            end
			dmginfo:SetDamage(0)
			return
		end
		if dmginfo:GetDamage() > 0 && self.CurAttack && self.CurAttack.type == "pull" then
			self:FinishAttack(false)
		end
		dmginfo:SetDamage(math.min(dmginfo:GetDamage(),160))
	elseif status == "PostDamage" && self.HasRetreat && !self.Dead && dmginfo:GetDamage() > 0 && CurTime() >= self.RetreatEndT then
		local time = CurTime()
		local total = dmginfo:GetDamage()
		for i = #self.DamageHistory,1,-1 do
			if time -self.DamageHistory[i].time > 5 then
				table.remove(self.DamageHistory,i)
			else
				total = total +self.DamageHistory[i].damage
			end
		end
		self.DamageHistory[#self.DamageHistory +1] = {
            time = time,
            damage = dmginfo:GetDamage()
        }
		if total >= self.RetreatDamageThreshold then
			self.DamageHistory = {}
			self:FinishAttack(false)
			self.RetreatEndT = time +7
			self.InvulnerableT = time +3
			self.NextAttackT = self.RetreatEndT +1
			local enemy = self:GetEnemy()
			local away = IsValid(enemy) && getDir(self:GetPos() -enemy:GetPos(),-self:GetForward()) or -self:GetForward()
			self.RetreatPos = self:GetPos() +away *800 +Vector(0,0,300)
			self.NextRetreatMoveT = 0
			VJ.EmitSound(self,"vj_hlr/src/npc/advisor/pain.wav",95)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ReleaseProp(ent,delay)
	local data = self.LevitatedProps && self.LevitatedProps[ent]
	if !data then return end
	self.LevitatedProps[ent] = nil
	if !IsValid(ent) then return end
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableGravity(data.gravity)
		phys:EnableDrag(data.drag)
		phys:SetDamping(data.linearDamp,data.angularDamp)
		phys:Wake()
	end
	ent:SetCollisionGroup(data.collisionGroup)
	if IsValid(phys) then phys:RecheckCollisionFilter() end
	if ent.VJ_HLR_AdvisorOwner == self then
		ent.VJ_HLR_AdvisorOwner = nil
		ent.VJ_HLR_AdvisorProp = nil
		ent:SetNW2Bool("VJ.HLR.Advisor.Controlled",false)
		ent:SetNW2Entity("VJ.HLR.Advisor.Owner",NULL)
	end
	if delay && delay > 0 then
        self.RecentThrownProps[ent] = {
            untilT = CurTime() +delay
        }
        ent.VJ_HLR_AdvisorThrownUntil = CurTime() +delay
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ReleaseProps()
	if !self.LevitatedProps then return end
	for ent in pairs(self.LevitatedProps) do
		self:ReleaseProp(ent,2)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UpdateProps(scan,delta)
	local time = CurTime()
	local center = self:WorldSpaceCenter()
	local enemy = self:GetEnemy()
	local hasEnemy = targetAlive(enemy)

	for ent,data in pairs(self.RecentThrownProps) do
		if !IsValid(ent) then
            self.RecentThrownProps[ent] = nil
            continue
        end
		if data.untilT <= time then
			if ent:GetOwner() == self then
                ent:SetOwner(IsValid(data.owner) && data.owner or NULL)
            end
			self.RecentThrownProps[ent] = nil
		elseif data.goal && self.PhysicsThrowSteering then
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) && phys:GetVelocity():Length() >= 1000 then
				local vel = phys:GetVelocity() +getDir(data.goal -ent:WorldSpaceCenter()) *(2000 *delta)
				if vel:Length() > 3500 then
                    vel = vel:GetNormalized() *3500
                end
				phys:SetVelocity(vel)
			else
				data.goal = nil
			end
		end
	end

	if scan && self.HasShield then
		local count = table.Count(self.LevitatedProps)
		for ent in pairs(self.LevitatedProps) do
			if !IsValid(ent) or ent:GetPos():Distance(self:GetPos()) > self.LevitationRadius *1.4 then
				self:ReleaseProp(ent)
				count = count -1
			end
		end
		if count < self.MaxLevitatedProps then
			for _,ent in ipairs(ents.FindInSphere(self:GetPos(),self.LevitationRadius)) do
				if count >= self.MaxLevitatedProps then
                    break
                end
				if !IsValid(ent) or self.LevitatedProps[ent] or ent.VJ_HLR_AdvisorOwner or (ent.VJ_HLR_AdvisorThrownUntil && ent.VJ_HLR_AdvisorThrownUntil > time) then
                    continue
                end
				if ent:GetClass() != "prop_physics" && ent:GetClass() != "prop_physics_multiplayer" && ent:GetClass() != "prop_physics_override" && ent:GetClass() != "func_physbox" then
                    continue
                end
				if ent.IsPlayerHolding && ent:IsPlayerHolding() or constraint.HasConstraints(ent) then
                    continue
                end
				local phys = ent:GetPhysicsObject()
				if !IsValid(phys) or !phys:IsMotionEnabled() or phys:GetMass() < 1 or phys:GetMass() > 250 or !self:Visible(ent) then
                    continue
                end
				local linear,angular = phys:GetDamping()
				local slot = 1
				while true do
					local taken = false
					for _,data in pairs(self.LevitatedProps) do
						if data.slot == slot then
                            taken = true
                            break
                        end
					end
					if !taken then
                        break
                    end
					slot = slot +1
				end
				self.LevitatedProps[ent] = {
					slot = slot,
                    angle = phys:GetAngles(),
                    startT = time,
                    gravity = phys:IsGravityEnabled(),
                    drag = phys:IsDragEnabled(),
					linearDamp = linear,
                    angularDamp = angular,
                    collisionGroup = ent:GetCollisionGroup(),
					shadow = {
                        secondstoarrive = 0.3,
                        delta = 0.05,
                        maxspeed = self.LevitationSpeed,
                        maxspeeddamp = 700,
						maxangular = 3500,
                        maxangulardamp = 4500,
                        dampfactor = 0.85,
                        teleportdistance = 0
                    }
				}
				ent.VJ_HLR_AdvisorOwner = self
				ent.VJ_HLR_AdvisorProp = true
				ent:SetNW2Bool("VJ.HLR.Advisor.Controlled",true)
				ent:SetNW2Entity("VJ.HLR.Advisor.Owner",self)
				ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				phys:RecheckCollisionFilter()
				phys:EnableGravity(false)
				phys:EnableDrag(true)
				phys:SetDamping(math.max(linear,3),math.max(angular,12))
				phys:SetAngleVelocity(Vector(0,0,0))
				phys:Wake()
				count = count +1
			end
		end
	end

	if !self.HasShield then return end
	local pullActive = self.CurAttack && self.CurAttack.type == "pull"
	local forward = hasEnemy && getDir(enemy:WorldSpaceCenter() -center,self:GetForward()) or self:GetForward()
	local right = getDir(forward:Cross(Vector(0,0,1)),self:GetRight())
	local up = getDir(right:Cross(forward),Vector(0,0,1))
	for ent,data in pairs(self.LevitatedProps) do
		local phys = IsValid(ent) && ent:GetPhysicsObject()
		if !IsValid(phys) then
            self:ReleaseProp(ent)
            continue
        end
		if self.CurAttack && self.CurAttack.type == "avalanche" && self.CurAttack.stage == "shockwave" then
            continue
        end
		local slot = data.slot -1
		local pos
		if pullActive then
            // Move the formation behind the Advisor while pulling an enemy in, otherwise it looks derpy
			local spread = slot *2.39996
			pos = center -forward *330 +right *(math.cos(spread) *200) +up *(math.sin(spread) *145)
		elseif hasEnemy then
            // Shield formation
			local col,row = slot %5,math.floor(slot /5)
			pos = center +forward *(235 +row %2 *25) +right *((col -2) *85) +up *((row -1.5) *95)
		else
			local phase = slot *2.39996 +time *self.LevitationOrbitSpeed
			pos = center +Vector(math.cos(phase) *260,math.sin(phase) *260,(slot %4 -1.5) *75)
		end
		local angle = data.angle
		if self.LevitationRotationSpeed != 0 then
			angle = Angle(angle.p +(time -data.startT) *(self.LevitationRotationSpeed *0.55),angle.y +(time -data.startT) *self.LevitationRotationSpeed,angle.r +(time -data.startT) *(self.LevitationRotationSpeed *1.235))
		end
		local shadow = data.shadow
		shadow.pos = pos
		shadow.angle = angle
		shadow.delta = delta
		shadow.maxspeed = self.LevitationSpeed
		phys:ComputeShadowControl(shadow)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ThrowProp(ent,enemy)
	if !self.LevitatedProps[ent] or !targetAlive(enemy,self.VJ_IsBeingControlled) then return end
	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then
        self:ReleaseProp(ent)
        return
    end
	local pos = ent:WorldSpaceCenter()
	local aim = enemy:WorldSpaceCenter() +enemy:GetVelocity() *0.16
	if enemy:IsPlayer() && enemy:EyeAngles():Forward():Dot(getDir(self:GetPos() -enemy:EyePos())) < -0.5 then
		aim = aim +Vector(0,0,120) +self:GetRight() *math.Rand(-70,70)
	end
	self:ReleaseProp(ent,5)
	local old = self.RecentThrownProps[ent] or {}
	old.owner = ent:GetOwner()
	old.untilT = CurTime() +5
	ent.VJ_HLR_AdvisorThrownUntil = old.untilT
	old.goal = aim
	self.RecentThrownProps[ent] = old
	ent:SetOwner(self)
	phys:SetVelocity(getDir(aim -pos,self:GetForward()) *self.PhysicsThrowSpeed)
	phys:SetAngleVelocity(VectorRand() *180)
	phys:Wake()
	VJ.EmitSound(self,"vj_hlr/src/npc/advisor/advisorattack02.wav",95)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:StartAttack(atkType,enemy)
	if self.CurAttack or CurTime() < self.NextAttackT or CurTime() < self.RetreatEndT then
        return false
    end
	if !targetAlive(enemy,self.VJ_IsBeingControlled && atkType != "pull") then
        return false
    end
	local dist = self:GetPos():Distance(enemy:GetPos())
	local props = table.Count(self.LevitatedProps)
	if atkType == "throw" && props == 0 then
        return false
    end
	if atkType == "avalanche" && (!self.HasAvalanche or props < 4 or dist > 1300) then
        return false
    end
	if atkType == "spit" && (!self.HasSpitAttack or dist < 240 or dist > 2200) then
        return false
    end
	if atkType == "pull" then
		if !self.HasPsychicPull or dist < 85 or dist > self.PsychicPullRange or CurTime() < self.NextPullT then
            return false
        end
		if IsValid(enemy.VJ_HLR_AdvisorPullOwner) && enemy.VJ_HLR_AdvisorPullOwner != self then
            return false
        end
		if enemy:IsPlayer() && (enemy:InVehicle() or enemy:GetMoveType() != MOVETYPE_WALK) then
            return false
        end
	end

	self.CurAttack = {
        type = atkType,
        enemy = enemy,
        stage = "prepare",
        nextT = CurTime() +0.5,
        started = CurTime()
    }
	self.PsionicAttacking = true
    self:SetPsionicEffect(true)
	VJ.EmitSound(self,"vj_hlr/src/npc/advisor/advisorattack03.wav",95)

	if atkType == "pull" then
		self.CurAttack.nextT = CurTime() +0.35
		self.CurAttack.deadline = CurTime() +self.PsychicPullDuration
		self:PlayAnim(ACT_SPECIAL_ATTACK1,true,0.45,true)
	elseif atkType == "throw" then
		local options = {}
		local look = enemy:IsPlayer() && enemy:EyeAngles():Forward() or enemy:GetForward()
		for prop in pairs(self.LevitatedProps) do
			if IsValid(prop) then
				local phys = prop:GetPhysicsObject()
				local score = (look:Dot(getDir(prop:WorldSpaceCenter() -enemy:WorldSpaceCenter())) >= 0.85 && 500 or 0) +(IsValid(phys) && phys:GetMass() or 0) +math.Rand(-35,35)
				options[#options +1] = {
                    ent = prop,
                    score = score
                }
			end
		end
		table.sort(options,function(a,b)
            return a.score > b.score
        end)
		self.CurAttack.props = {}
		for _,entry in ipairs(options) do
			local separate = true
			for _,prop in ipairs(self.CurAttack.props) do
				if entry.ent:GetPos():Distance(prop:GetPos()) < 70 then
                    separate = false
                    break
                end
			end
			if separate then
                self.CurAttack.props[#self.CurAttack.props +1] = entry.ent
            end
			if #self.CurAttack.props >= self.PhysicsThrowCount then
                break
            end
		end
		if #self.CurAttack.props == 0 then
            self:FinishAttack(false)
            return false
        end
		self.CurAttack.index = 1
	elseif atkType == "avalanche" then
		self.CurAttack.nextT = CurTime() +0.7
		self.CurAttack.hit = {}
	end
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:FinishAttack(success)
	local attack = self.CurAttack
	if !attack then return end
	if attack.type == "pull" then
		local target = attack.enemy
		if IsValid(target) && target.VJ_HLR_AdvisorPullOwner == self then
			target.VJ_HLR_AdvisorPullOwner = nil
			if target:IsPlayer() then
				target:SetNW2Entity("VJ.HLR.Advisor.PullOwner",NULL)
				target:SetNW2Bool("VJ.HLR.Advisor.TongueHeld",false)
			else
				target:SetAbsVelocity(Vector(0,0,0))
				if attack.moveType then
                    target:SetMoveType(attack.moveType)
                end
			end
		end
        self:SetPullTarget(NULL)
		self.NextPullT = CurTime() +(success && self.PsychicPullCooldown or 5)
    end
    if attack.stage == "sucking" then
        self:SetState()
        self:ResetMoveCalc()
        self:AA_StopMoving()
        if self.CurrentSchedule then
            self.CurrentSchedule = nil
            self.CurrentTask = nil
            self.CurrentTaskID = nil
        end
        self.NextIdleStandTime = 0
        self.NextIdleTime = 0
        self.NextChaseTime = 0
        self.AnimLockTime = 0
        self.AttackType = VJ.ATTACK_TYPE_NONE
        self.AttackState = VJ.ATTACK_STATE_NONE
        self.AttackAnim = nil
        self.AttackAnimDuration = 0
        self.AttackAnimTime = 0
        self.NextDoAnyAttackT = 0
        self.IsAbleToMeleeAttack = true
        self.PauseAttacks = false
        self:ResetIdealActivity(ACT_IDLE)
	end
	self.CurAttack = nil
	self.PsionicAttacking = false
    self:SetPsionicEffect(false)
	self.NextAttackT = CurTime() +(success && self.AttackCooldown or 1.5) +math.Rand(0,1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:UpdateAttack()
	local atk = self.CurAttack
	if !atk then return end
	local time = CurTime()
	local target = atk.enemy
	if !targetAlive(target,self.VJ_IsBeingControlled && atk.type != "pull") or (atk.type != "pull" && time > atk.started +8) then
        self:FinishAttack(false)
        return
    end

	if atk.type == "throw" then
		if time < atk.nextT then
            return
        end
		local prop = atk.props[atk.index]
		if IsValid(prop) then
            self:ThrowProp(prop,target)
        end
		atk.index = atk.index +1
		atk.nextT = time +0.25
		if atk.index > #atk.props then
            self:FinishAttack(true)
        end
	elseif atk.type == "spit" then
		if time < atk.nextT then
            return
        end
		local start = self:GetPos() +self:GetForward() *75 +self:GetUp() *20
		local dir = getDir(target:WorldSpaceCenter() -start +target:GetVelocity() *0.25,self:GetForward())
		for i = 1,6 do
			local size = i == 1 && 3 or (i %2 == 0 && 2 or 1)
			local proj = ents.Create("obj_vj_hlr2_antlionspit")
			if !IsValid(proj) then break end
			proj.Size = size
			proj.Damage = size == 3 && 20 or (size == 2 && 10 or 5)
			proj.Advisor = self
			proj:SetPos(start +self:GetRight() *math.Rand(-16,16))
			proj:SetAngles(dir:Angle())
			proj:SetOwner(self)
			proj:Spawn()
			proj:Activate()
            local vel = self:CalculateProjectile("Curve", proj:GetPos(), (target:GetPos() +target:OBBCenter()) +(VectorRand() *0.07 *(size == 3 && 850 or math.Rand(750,900))), 1200)
            local phys = proj:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(vel)
            end
		end
		self:FinishAttack(true)
	elseif atk.type == "avalanche" then
		if atk.stage == "prepare" then
			if time < atk.nextT then
                return
            end
			atk.stage = "warning"
			atk.nextT = time +0.6
			VJ.EmitSound(self,"vj_hlr/src/npc/advisor/advisor_blast6.wav",100)
			local tr = util.TraceLine({
                start = self:GetPos(),
                endpos = self:GetPos() -Vector(0,0,800),
                filter = self,
                mask = MASK_SOLID
            })
			if tr.Hit then
                self:AA_MoveTo(tr.HitPos +Vector(0,0,150),false,"Alert",{IgnoreGround=true})
            end
		elseif atk.stage == "warning" then
			if time < atk.nextT then
                return
            end
			atk.stage = "shockwave"
			atk.nextT = time +1.3
			atk.lastT = time
			atk.waveFront = 0
			ParticleEffect("vj_aurora_shockwave",self:GetPos(),Angle(),nil)
			VJ.EmitSound(self,"vj_hlr/src/npc/advisor/advisor_blast6.wav",110)
		else
			atk.waveFront = atk.waveFront +1000 *math.Clamp(time -atk.lastT,0,0.1)
			atk.lastT = time
			for prop in pairs(self.LevitatedProps) do
				if !IsValid(prop) or atk.hit[prop] or prop:GetPos():Distance(self:GetPos()) > atk.waveFront then
                    continue
                end
				atk.hit[prop] = true
				local phys = prop:GetPhysicsObject()
				local pos = prop:WorldSpaceCenter()
				self:ReleaseProp(prop,5)
				if IsValid(phys) && pos:Distance(target:WorldSpaceCenter()) > 128 then
					local old = self.RecentThrownProps[prop] or {}
					old.owner = prop:GetOwner()
					old.untilT = time +5
					prop.VJ_HLR_AdvisorThrownUntil = old.untilT
					self.RecentThrownProps[prop] = old
					prop:SetOwner(self)
					phys:SetVelocity(getDir(target:WorldSpaceCenter() -pos,self:GetForward()) *2200 +Vector(0,0,-220))
					phys:SetAngleVelocity(VectorRand() *180)
				end
			end
			if time >= atk.nextT then
                self:FinishAttack(true)
            end
		end
	elseif atk.type == "pull" then
		if time > atk.deadline && atk.stage != "sucking" then
            self:FinishAttack(false)
            return
        end
		if atk.stage == "prepare" then
			if time < atk.nextT then
                return
            end
			if IsValid(target.VJ_HLR_AdvisorPullOwner) && target.VJ_HLR_AdvisorPullOwner != self then
                self:FinishAttack(false)
                return
            end
			atk.stage = "pulling"
			target.VJ_HLR_AdvisorPullOwner = self
			self:SetPullTarget(target)
			if target:IsPlayer() then
				target:SetNW2Entity("VJ.HLR.Advisor.PullOwner",self)
				target:SetNW2Bool("VJ.HLR.Advisor.TongueHeld",false)
                self:SetPullSpeed(self.PsychicPullSpeed)
				target:SetGroundEntity(NULL)
				target:ViewPunch(Angle(-6,math.Rand(-4,4),2))
			else
				atk.moveType = target:GetMoveType()
				target:SetMoveType(MOVETYPE_NONE)
				target:SetAbsVelocity(Vector(0,0,0))
			end
			VJ.EmitSound(self,"vj_hlr/src/npc/advisor/advisor_blast6.wav",85)
			return
		end

		local holdPos = self:GetTongueHoldPos(target)
		if !target:IsPlayer() && target:GetMoveType() != MOVETYPE_NONE then
            target:SetMoveType(MOVETYPE_NONE)
        end
		local delta = holdPos -target:GetPos()
		if atk.stage == "pulling" then
			if delta:Length() < 75 then
				atk.stage = "sucking"
				if target:IsPlayer() then
					target:SetNW2Bool("VJ.HLR.Advisor.TongueHeld",true)
				else
					target:SetPos(holdPos)
					target:SetAbsVelocity(Vector(0,0,0))
				end
				local _,dur = self:PlayAnim(ACT_SPECIAL_ATTACK2,true,false,true,0,{OnFinish=function(interrupted)
                    if self:GetActivity() != ACT_SPECIAL_ATTACK2 then return end
                    self:ResetAI()
                end})
                self:SetState(VJ_STATE_ONLY_ANIMATION_NOATTACK,dur)
                local oldSpeed = self:GetMaxYawSpeed()
                self:SetMaxYawSpeed(0)
                timer.Simple(dur,function()
                    if IsValid(self) then
                        self:SetState()
                        self:SetMaxYawSpeed(oldSpeed)
                    end
                end)
				atk.nextT = time +dur
				target:EmitSound("vj_hlr/src/npc/advisor/advisorheadvx01.wav",65)
			else
				if !target:IsPlayer() then
					local deltaT = math.Clamp(time -(atk.lastPullT or time -0.05),0.01,0.1)
					atk.lastPullT = time
					local step = delta:GetNormalized() *math.min(delta:Length(),self.PsychicPullSpeed *deltaT)
					local center = target:GetPos() +target:OBBCenter()
					local tr = util.TraceLine({
                        start = center,
                        endpos = center +step,
                        mask = MASK_SOLID_BRUSHONLY
                    })
					if !tr.StartSolid then
						local fraction = tr.Hit && math.max(tr.Fraction -0.02,0) or 1
						target:SetPos(target:GetPos() +step *fraction)
					end
					target:SetAbsVelocity(Vector(0,0,0))
				end
				if atk.lastDist && atk.lastDist <= delta:Length() +1 then
					atk.stuckT = atk.stuckT or time
					if time -atk.stuckT > 1.1 then
                        self:FinishAttack(false)
                        return
                    end
				else
					atk.stuckT = nil
				end
				atk.lastDist = delta:Length()
			end
		else
			if !target:IsPlayer() then
				target:SetPos(holdPos)
				target:SetAbsVelocity(Vector(0,0,0))
			end
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DefendProjectiles()
	if !self.HasProjectileDefense then return end
	local time = CurTime()
	local center = self:WorldSpaceCenter()
	local enemy = self:GetEnemy()
	for ent,data in pairs(self.DeflectedProjectiles) do
		if !IsValid(ent) or data.untilT <= time then
			self.DeflectedProjectiles[ent] = nil
		else
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
                phys:SetVelocity(data.velocity)
			else
                ent:SetAbsVelocity(data.velocity)
            end
		end
	end

	for _,ent in ipairs(ents.FindInSphere(center,self.ProjectileDefenseRadius)) do
		if !IsValid(ent) or ent == self or ent.VJ_HLR_AdvisorDeflected or ent.VJ_ST_Grabbed then
            continue
        end
		local class = ent:GetClass()
		local grenade = ent.VJ_ID_Grenade or class == "npc_grenade_frag" or class == "grenade_ar2" or class == "obj_vj_grenade"
		local rocket = class == "rpg_missile"
		local projectile = ent.IsVJBaseProjectile
		if !grenade && !rocket && !projectile then continue end

		local owner = ent:GetOwner()
		if IsValid(owner) && owner:IsWeapon() then
            owner = owner:GetOwner()
        end
		if IsValid(owner) && (owner == self or ((owner:IsNPC() or owner:IsNextBot() or owner:IsPlayer()) && self:CheckRelationship(owner) == D_LI)) then
            continue
        end
		local vel = ent:GetVelocity()
		local towards = getDir(center -ent:WorldSpaceCenter(),-self:GetForward())
		if !grenade && vel:Dot(towards) < 30 then continue end
		local tr = util.TraceLine({
            start = center,
            endpos = ent:WorldSpaceCenter(),
            filter = {self,ent},
            mask = MASK_SHOT
        })
		if tr.HitWorld then
            continue
        end
		if rocket then
			ent.VJ_HLR_AdvisorDeflected = true
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(40)
			dmginfo:SetDamageType(DMG_MISSILEDEFENSE)
			dmginfo:SetAttacker(self)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamagePosition(ent:WorldSpaceCenter())
			ent:TakeDamageInfo(dmginfo)
		elseif grenade or projectile then
			local destination = targetAlive(enemy) && enemy or (targetAlive(owner) && owner or nil)
			local direction = IsValid(destination) && getDir(destination:WorldSpaceCenter() -ent:WorldSpaceCenter(),-towards) or -towards
			if grenade then direction = getDir(direction +Vector(0,0,0.25),-towards) end
			local speed = grenade && self.GrenadeReturnSpeed or math.max(self.ProjectileDeflectSpeed,vel:Length() *1.1)
			local newVel = direction *speed
			local phys = ent:GetPhysicsObject()
			ent.VJ_HLR_AdvisorDeflected = true
			if IsValid(phys) then
				phys:Wake()
				phys:SetVelocity(newVel)
			else
				ent:SetAbsVelocity(newVel)
			end
			if projectile && !grenade then
				ent:SetAngles(newVel:Angle())
				ent:SetOwner(self)
				self.DeflectedProjectiles[ent] = {
                    velocity = newVel,
                    untilT = time +0.3
                }
			end
		end
		VJ.EmitSound(self,"vj_hlr/src/npc/advisor/advisorattack02.wav",85)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnAlly() // Old behavior, isn't in the official EP3 leaked code but I will keep it here in case jv base wants it as a feature
	if !self.HasSummonAttack then
        return
    end
	local active = 0
	for ent in pairs(self.Summons) do
		if !IsValid(ent) then
            self.Summons[ent] = nil
        else
            active = active +1
        end
	end
	if active >= self.MaxSummons then
        return
    end
	local enemy = self:GetEnemy()
	local pos = targetAlive(enemy) && enemy:GetPos() or self:GetPos()
	local tr = util.TraceLine({
        start = pos +VectorRand() *480 +Vector(0,0,240),
        endpos = pos +Vector(0,0,-1200),
        filter = {self,enemy},
        mask = MASK_SOLID
    })
	if !tr.Hit or tr.HitSky then
        return
    end
	local info = self.Spawnables[math.random(#self.Spawnables)]
	local npc = ents.Create(info.ent)
	if !IsValid(npc) then return end
	npc:SetPos(tr.HitPos +tr.HitNormal *(info.offset +30))
	npc:SetAngles(Angle(0,self:GetAngles().y,0))
	npc:Spawn()
	npc:Activate()
	if info.weapons && npc.Give then
        npc:Give(info.weapons[math.random(#info.weapons)])
    end
	self.Summons[npc] = true
	ParticleEffect("electrical_arc_01_system",npc:GetPos(),Angle(),nil)
	VJ.EmitSound(npc,"ambient/energy/whiteflash.wav",90)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnThinkActive()
	if self.Dead then
        return
    end
    if self.CurAttack && self.CurAttack.stage == "sucking" then
        self:SetLocalVelocity(vector_origin)
    end
	local time = CurTime()
	if self.HasShield && time >= self.NextDefenseT then
		self.NextDefenseT = time +self.ProjectileDefenseInterval
		self:DefendProjectiles()
	end
	local scan = time >= self.NextScanT
	if scan then
		self.NextScanT = time +self.LevitationScanInterval
		if !self.HasShield && time >= self.ShieldRecoverT then
            self:ShieldCode(true)
        end
	end
	if time >= self.NextPhysicsT then
		local delta = math.Clamp(time -(self.LastPhysicsT or time -0.05),0.01,0.1)
		self.LastPhysicsT = time
		self.NextPhysicsT = time +0.05
		self:UpdateProps(scan,delta)
		self:UpdateAttack()
	end
	if self.HasScreenFX && time >= self.NextFXT then
		self.NextFXT = time +math.Rand(7,12)
		for _,ply in ipairs(player.GetAll()) do
			if !ply:Alive() or ply:GetPos():Distance(self:GetPos()) > 2500 then
                continue
            end
			net.Start("VJ.HLR.AdvisorScreenFX")
				net.WriteEntity(self)
				net.WriteFloat(ply:GetPos():Distance(self:GetPos()))
			net.Send(ply)
		end
	end
	if time < self.RetreatEndT then
		if time >= (self.NextRetreatMoveT or 0) then
			self.NextRetreatMoveT = time +1
			self:AA_MoveTo(self.RetreatPos,false,"Alert",{IgnoreGround=true})
		end
		return
	end
	if self.CurAttack or time < self.NextAttackT then
        return
    end
	local enemy = self:GetEnemy()
	if self.VJ_IsBeingControlled && IsValid(self.VJ_TheController) then
		local ply = self.VJ_TheController
		local aimed = ply:GetEyeTrace().Entity
		local target = targetAlive(aimed) && aimed or enemy
		if ply:KeyDown(IN_ATTACK) then
            self:StartAttack("throw",target)
		elseif ply:KeyDown(IN_ATTACK2) then
            self:StartAttack("spit",target)
		elseif ply:KeyDown(IN_RELOAD) then
            self:StartAttack("avalanche",target)
		elseif ply:KeyDown(IN_USE) && targetAlive(aimed) then
            self:StartAttack("pull",aimed)
        end
		if ply:KeyDown(IN_JUMP) && time >= self.NextSummonT then
			self.NextSummonT = time +self.SummonCooldown
			self:SpawnAlly()
		end
		return
	end
	if time < self.NextBrainT or !targetAlive(enemy) then
        return
    end
	self.NextBrainT = time +0.25
	local filter = {self}
	for prop in pairs(self.LevitatedProps) do
        filter[#filter +1] = prop
    end
	if !self:Visible(enemy) then
        return
    end
	local dist = self:GetPos():Distance(enemy:GetPos())
	if self.HasPsychicPull && time >= self.NextPullT then
		if dist <= self.PsychicPullRange && dist >= 85 then
			if self:StartAttack("pull",enemy) then
                return
            end
		elseif dist <= self.PsychicPullApproachRange then
			if time >= self.NextApproachT then
				self.NextApproachT = time +1
				self:AA_MoveTo(enemy,false,"Alert",{IgnoreGround=true,FaceDestTarget=true,ChaseEnemy=true})
			end
			return
		end
	end
	local options = {} -- Lite version of my FF7 SNPCs behavior system, allows for more random attack decision making
	if next(self.LevitatedProps) then
        options[#options +1] = "throw"
    end
	if self.HasAvalanche && table.Count(self.LevitatedProps) >= 4 && dist <= 1300 then
        options[#options +1] = "avalanche"
    end
	if self.HasSpitAttack && dist >= 240 && dist <= 2200 then
        options[#options +1] = "spit"
    end
	if #options > 0 then
        self:StartAttack(options[math.random(#options)],enemy)
    end
	if self.HasSummonAttack && time >= self.NextSummonT then
		self.NextSummonT = time +self.SummonCooldown
		self:SpawnAlly()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnInput(key)
	if key == "melee" then
        self:ExecuteMeleeAttack()
    elseif key == "tongue" then
        // Spawn the tongue model
    elseif key == "tongue_kill" then
        local ent = self:GetPullTarget()
        if !IsValid(ent) then return end
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(math.max(1,math.ceil((ent.GetMaxHealth && ent:GetMaxHealth() or ent:Health()) *0.5)))
        dmginfo:SetDamageType(DMG_SHOCK)
        dmginfo:SetAttacker(self)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamagePosition(ent:EyePos())
        ent:TakeDamageInfo(dmginfo)
        self:FinishAttack(true)
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnDeath(dmginfo,hitgroup,status)
	if status != "Init" then
        return
    end
	self:FinishAttack(false)
	self:ReleaseProps()
    self:SetPullTarget(NULL)
	self:SetPsionicEffect(false)
	for ent,data in pairs(self.RecentThrownProps) do
		if IsValid(ent) && ent:GetOwner() == self then
            ent:SetOwner(IsValid(data.owner) && data.owner or NULL)
        end
	end
	self.RecentThrownProps = {}
	self.DeflectedProjectiles = {}
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnRemove()
	self:FinishAttack(false)
	self:ReleaseProps()
	for ent,data in pairs(self.RecentThrownProps or {}) do
		if IsValid(ent) && ent:GetOwner() == self then
            ent:SetOwner(IsValid(data.owner) && data.owner or NULL)
        end
	end
	self:SetPullTarget(NULL)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:ResetAI()
	self:SetState()
	self:ResetMoveCalc()
    self:AA_StopMoving()
	if self.CurrentSchedule then
		self.CurrentSchedule = nil
		self.CurrentTask = nil
		self.CurrentTaskID = nil
	end
	self.NextIdleStandTime = 0
	self.NextIdleTime = 0
	self.NextChaseTime = 0
	self.AnimLockTime = 0
	self.AttackType = VJ.ATTACK_TYPE_NONE
	self.AttackState = VJ.ATTACK_STATE_NONE
	self.AttackAnim = nil
	self.AttackAnimDuration = 0
	self.AttackAnimTime = 0
	self.NextDoAnyAttackT = 0
	self.IsAbleToMeleeAttack = true
	self.PauseAttacks = false

	self:FinishAttack(false)
    self.CurAttack = nil
	self:ReleaseProps()
	for ent,data in pairs(self.RecentThrownProps or {}) do
		if IsValid(ent) && ent:GetOwner() == self then
            ent:SetOwner(IsValid(data.owner) && data.owner or NULL)
        end
	end
	self:SetPullTarget(NULL)
    self:ResetIdealActivity(ACT_IDLE)
end