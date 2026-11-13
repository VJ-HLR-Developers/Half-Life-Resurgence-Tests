AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/gman.mdl"
ENT.StartHealth = 999999
ENT.HullType = HULL_HUMAN

ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"}
ENT.Behavior = VJ_BEHAVIOR_PASSIVE
ENT.Passive_RunOnTouch = false
ENT.DamageResponse = false
ENT.EnemyDetection = false
ENT.YieldToAlliedPlayers = false
ENT.HasOnPlayerSight = true
ENT.GodMode = true
ENT.BloodColor = VJ.BLOOD_COLOR_RED

ENT.HasMeleeAttack = false

ENT.DisableFootStepSoundTimer = true

-- ENT.SoundTbl_IdleDialogue = "vo/gman_misc/gman_riseshine.wav"
-- ENT.SoundTbl_FollowPlayer = {"vo/gman_misc/gman_02.wav", "vo/gman_misc/gman_03.wav"}
-- ENT.SoundTbl_UnFollowPlayer = "vo/gman_misc/gman_04.wav"

ENT.MainSoundPitch = 100

function ENT:Init()
	self:AddFlags(FL_NOTARGET)
	self.AnimTbl_Run = ACT_WALK

	self.NextDialogueTreeT = CurTime()
	self.NextTeleportT = CurTime() +5
end

local dur1 = SoundDuration("vo/gman_misc/gman_riseshine.wav")
local dur2 = SoundDuration("vo/gman_misc/gman_02.wav")
local dur3 = SoundDuration("vo/gman_misc/gman_03.wav")
local dur4 = SoundDuration("vo/gman_misc/gman_04.wav")
--
function ENT:FreemanSpeech(ent)
	if CurTime() > self.NextDialogueTreeT then
		self.Freeman = ent
		self.Dialogue1 = VJ.CreateSound(self, "vo/gman_misc/gman_riseshine.wav", 75)
		self:PlayAnim({"vjges_G_tiefidget", "vjges_G_lefthand_palmout", "vjges_G_lefthand_punct"}, false, false, false)
		timer.Simple(dur1, function()
			if IsValid(self) and IsValid(ent) then
				self.Dialogue2 = VJ.CreateSound(self, "vo/gman_misc/gman_02.wav", 75)
				self:PlayAnim({"vjges_G_tiefidget", "vjges_G_lefthand_palmout", "vjges_G_lefthand_punct"}, false, false, false)
				timer.Simple(dur2, function()
					if IsValid(self) and IsValid(ent) then
						self.Dialogue3 = VJ.CreateSound(self, "vo/gman_misc/gman_03.wav", 75)
						self:PlayAnim({"vjges_G_tiefidget", "vjges_G_lefthand_palmout", "vjges_G_lefthand_punct"}, false, false, false)
						timer.Simple(dur3, function()
							if IsValid(self) and IsValid(ent) then
								self.Dialogue4 = VJ.CreateSound(self, "vo/gman_misc/gman_04.wav", 75)
								self:PlayAnim({"vjges_G_tiefidget", "vjges_G_lefthand_palmout", "vjges_G_lefthand_punct"}, false, false, false)
								timer.Simple(dur4, function()
									if IsValid(self) and IsValid(ent) then
										self.Freeman = NULL
									end
								end)
							end
						end)
					end
				end)
			end
		end)
		self.NextDialogueTreeT = CurTime() +(dur1 +dur2 +dur3 +dur4) +math.Rand(5, 15)
	end
end

function ENT:OnMaintainRelationships(ent, calculatedDisp, entDist)
	if ent.VJ_HLR_Freeman then
		self:FreemanSpeech(ent)
	end
end

function ENT:OnPlayerSight(ent)
	self:FreemanSpeech(ent)
end

function ENT:OnThink()
	local freeman = self.Freeman
	if IsValid(freeman) then
		if freeman:GetPos():Distance(self:GetPos()) <= 300 then
			self:SetTurnTarget(freeman)
			self:SetState(VJ_STATE_ONLY_ANIMATION)
			self:SetEyeTarget(freeman:EyePos())
		else
			self:SetTurnTarget(vector_origin)
			self:SetState()
			self:SetTarget(freeman)
			self:SCHEDULE_GOTO_TARGET("TASK_WALK_PATH", function(y) y.TurnData = {Type = VJ.FACE_ENEMY} end)
		end
	else
		if self:GetState() == VJ_STATE_ONLY_ANIMATION then
			self:SetState()
			self:SetTurnTarget(vector_origin)
		end
	end
	if CurTime() > self.NextTeleportT and !IsValid(self.Freeman) and game.GetGlobalState("gordon_precriminal") == 0 then
		local tpPos = self:FindSpawnPos(self:GetPos())
		if #tpPos == 0 then return end
		tpPos = tpPos[math.random(1,#tpPos)]
		self:ClearGoal()
		self:ClearSchedule()
		self:SetPos(tpPos)
		self.NextTeleportT = CurTime() +math.Rand(15, 30)
	end
end

function ENT:FindSpawnPos(pos)
 	local goodPositions = {}
	local nodes = (VJ_Nodegraph and VJ_Nodegraph.Data and VJ_Nodegraph.Data.Nodes) or {}
	for _, node in ipairs(nodes) do
		if node.pos:Distance(pos) <= 4096 and node.pos:Distance(pos) >= 1024 then
			local isValid = true
			for _, v in ipairs(ents.GetAll()) do
				if (v:IsNPC() and v != self or (v:IsPlayer() and !VJ_CVAR_IGNOREPLAYERS)) and !v:IsFlagSet(FL_NOTARGET) then
					if v:VisibleVec(node.pos) or self:Visible(v) then
						isValid = false
						break
					end
				end
			end
			if isValid then
				table.insert(goodPositions, node.pos)
			end
		end
	end
	return goodPositions
end

function ENT:CustomOnRemove()
	VJ.STOPSOUND(self.Dialogue1)
	VJ.STOPSOUND(self.Dialogue2)
	VJ.STOPSOUND(self.Dialogue3)
	VJ.STOPSOUND(self.Dialogue4)
end