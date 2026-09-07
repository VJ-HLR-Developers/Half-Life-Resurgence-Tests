ENT.Base = "npc_vj_creature_base"
ENT.Type = "ai"
ENT.PrintName = ""
ENT.Author = ""
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
ENT.Category = "Half-Life Resurgence"

if !CLIENT then return end

local mat = Material("vj_hl/renderfx/render_advisor")
local cam_Start3D = cam.Start3D
local cam_End3D = cam.End3D
local EyePos, EyeAngles = EyePos, EyeAngles
local render_SetBlend = render.SetBlend
local render_MaterialOverride = render.Material
local IsValid = IsValid
local pairs = pairs
local ents_FindByClass = ents.FindByClass
function ENT:Initialize()
	local index = self:EntIndex()
	hook.Add("RenderScreenspaceEffects", "VJ_HLR_Advisor_FX" .. index, function()
		if IsValid(self) then
			if self:GetNW2Bool("PsionicEffect") then
				for _, prop in pairs(ents_FindByClass("prop_*")) do
					if prop:GetNW2Bool("BeingControlledByAdvisor") then
						cam_Start3D(EyePos(), EyeAngles())
							render_SetBlend(1)
							render_MaterialOverride(mat)
							prop:DrawModel()
							render_MaterialOverride(0)
							render_SetBlend(1)
						cam_End3D()
					end
				end
			end
		else
			hook.Remove("RenderScreenspaceEffects", "VJ_HLR_Advisor_FX" .. index)
		end
	end)
end

-- We aren't actually localizing it for VJ_HLR_AdvisorScreenFX, but for the HUDPaint lower.
-- It's just that if we are localizing it at all, why also not optimize it here as well?
local math_random = math.random

net.Receive("VJ_HLR_AdvisorScreenFX", function()
	local ply = net.ReadEntity()
	local dist = net.ReadFloat()

	ply.VJ_HLR_AdvisorScreenDist = dist -- Do something with this at some point
	ply.VJ_HLR_AdvisorScreenT = CurTime() +5
	local snd = CreateSound(ply, "vj_hlr/src/npc/advisor/advisorheadvx0" .. math_random(1, 6) .. ".wav")
	snd:SetSoundLevel(0)
	snd:Play()
	snd:ChangeVolume(65)
end)

local surface_SetTexture = surface.SetTexture
local surface_GetTextureID = surface.GetTextureID
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawTexturedRect = surface.DrawTexturedRect
-- Entities are loaded after postprocess. If you don't believe me, see
-- https://wiki.facepunch.com/gmod/Lua_Loading_Order#clientloadingorder
local DrawMotionBlur = DrawMotionBlur
local LocalPlayer = LocalPlayer
local Angle = Angle
hook.Add("HUDPaint", "VJ_HLR_AdvisorScreen", function()
	if LocalPlayer().VJ_HLR_AdvisorScreenT && LocalPlayer().VJ_HLR_AdvisorScreenT > CurTime() then
		surface_SetTexture(surface_GetTextureID("vj_hl/hl2/overlay/advisorblast"))
		surface_SetDrawColor(255, 255, 255, 255)
		surface_DrawTexturedRect(0, 0, ScrW(), ScrH())
		DrawMotionBlur(0.02, 1, 0.01)
		LocalPlayer():SetViewPunchAngles(Angle(math_random(-20, 20), math_random(-20, 20), math_random(-20, 20)))
	end
end)
