ENT.Base = "npc_vj_creature_base"
ENT.Type = "ai"
ENT.PrintName = "Combine Advisor"
ENT.Author = "Half-Life Resurgence"
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
ENT.Category = "Half-Life Resurgence"

function ENT:SetupDataTables()
	self:NetworkVar("Bool","PsionicEffect")
	self:NetworkVar("Bool","AdvisorShield")
	self:NetworkVar("Entity","PullTarget")
	self:NetworkVar("Float","PullSpeed")
end

local zeroVelocity = Vector(0,0,0)
hook.Add("Move","VJ.HLR.AdvisorPsychicPull",function(ply,mv)
	local advisor = ply:GetNW2Entity("VJ.HLR.Advisor.PullOwner")
	if !IsValid(advisor) or advisor.VJ_HLR_Advisor or advisor:GetPullTarget() != ply or !ply:Alive() then
        return
    end
	local goal = advisor:GetTongueHoldPos(ply)
	local current = mv:GetOrigin()
	local delta = goal -current
	local held = ply:GetNW2Bool("VJ.HLR.Advisor.TongueHeld",false)
	local step = held && delta or (delta:Length() > 0.1 && delta:GetNormalized() *math.min(delta:Length(),advisor:GetPullSpeed() *engine.TickInterval()) or zeroVelocity)
	local center = current +ply:OBBCenter()
	local tr = util.TraceLine({
        start = center,
        endpos = center +step,
        mask = MASK_SOLID_BRUSHONLY
    })
	if !tr.StartSolid then
		mv:SetOrigin(current +step *(tr.Hit && math.max(tr.Fraction -0.02,0) or 1))
	end
	mv:SetVelocity(zeroVelocity)
	mv:SetForwardSpeed(0)
	mv:SetSideSpeed(0)
	mv:SetUpSpeed(0)
	return true
end)

function ENT:GetTongueHoldPos(target)
	local mouth = self:WorldSpaceCenter() +self:GetForward() *70
	local index = self:LookupAttachment("tongue_end")
	if index <= 0 then
        index = self:LookupAttachment("attach_mouth")
    end
	if index > 0 then
		local attachment = self:GetAttachment(index)
		if attachment then
            mouth = attachment.Pos
        end
	end
	return mouth +self:GetForward() *(target:IsPlayer() && 70 or math.Clamp(target:BoundingRadius() *0.8,50,120)) -target:OBBCenter()
end

if !CLIENT then return end

net.Receive("VJ_HLR_AdvisorScreenFX", function()
    local advisor = net.ReadEntity()
    local dist = net.ReadFloat()
    local ply = LocalPlayer()
    if !IsValid(ply) or !IsValid(advisor) or dist > 2600 then
        return
    end
    if VJ_CVAR_IGNOREPLAYERS then
        return
    end
    effectStartT = CurTime()
    effectEndT = effectStartT +math.Clamp(2.0 - dist *2200, 0.55, 1.9)
    ply:ViewPunch(Angle(math.Rand(-2.5, 2.5), math.Rand(-2.5, 2.5), 0))
    surface.PlaySound("vj_hlr/src/npc/advisor/advisorheadvx0" .. math.random(1, 6) .. ".wav")
end)

local shieldMat = Material("vj_hl/renderfx/render_advisor")
local beamMat = Material("cable/blue_elec")
local screenMat = Material("vj_hl/hl2/overlay/advisorblast")
local effectEndT = 0
local effectStartT = 0
hook.Add("PostDrawTranslucentRenderables", "VJ.HLR.AdvisorRender", function(depth, sky)
    if sky then
        return
    end
    local ply = LocalPlayer()
    if !IsValid(ply) then
        return
    end
    for _, advisor in ipairs(ents.FindByClass("npc_vj_hlr2_com_advisor*")) do
        if !IsValid(advisor) then
            continue
        end
        if advisor:GetAdvisorShield() then
            local drawn = 0
            for _, prop in ipairs(ents.FindInSphere(advisor:GetPos(), 1600)) do -- Terrible, I know; a for loop inside of a for loop. Jarvis, cancel me on Twitter
                if prop:GetNW2Entity("VJ.HLR.Advisor.Owner") != advisor then
                    continue
                end
                if !prop:GetNW2Bool("VJ.HLR.Advisor.Controlled") then
                    continue
                end
                render.SetBlend(0.22)
                render.MaterialOverride(shieldMat)
                prop:DrawModel()
                render.MaterialOverride(nil)
                render.SetBlend(1)
                drawn = drawn +1
                if drawn >= 32 then
                    break
                end
            end
        end
        local victim = advisor:GetPullTarget()
        if IsValid(victim) then
            local tongue = advisor:GetPos() +advisor:GetForward() *66
            local index = advisor:LookupAttachment("tongue_end")
            if index && index > 0 then
                local attachment = advisor:GetAttachment(index)
                if attachment then
                    tongue = attachment.Pos
                end
            end
            render.SetMaterial(beamMat)
            render.DrawBeam(tongue,victim:WorldSpaceCenter(),11 +math.sin(CurTime() *20) *2,0,1,Color(255,255,255,210))
        end
    end
end)

hook.Add("HUDPaint", "VJ.HLR.AdvisorScreen", function()
    if CurTime() >= effectEndT then
        return
    end
    local maxDuration = math.max(effectEndT -effectStartT, 0.01)
    local alpha = math.Clamp((effectEndT -CurTime()) *maxDuration, 0, 1) *180
    surface.SetMaterial(screenMat)
    surface.SetDrawColor(255,255,255,alpha)
    surface.DrawTexturedRect(0,0,ScrW(),ScrH())
end)

hook.Add("RenderScreenspaceEffects", "VJ.HLR.AdvisorBlur", function()
    if CurTime() < effectEndT then
        DrawMotionBlur(0.04,0.38,0.025)
    end
end)