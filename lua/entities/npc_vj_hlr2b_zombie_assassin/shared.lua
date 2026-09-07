ENT.Base = "npc_vj_creature_base"
ENT.Type = "ai"
ENT.PrintName = "Zombie Assassin"
ENT.Author = "DrVrej"
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
ENT.Category = "Half-Life 2"

ENT.VJ_ID_Undead = true

if CLIENT then
    net.Receive("VJ_HLR2_ZombieAssassinScream", function()
        local ply = net.ReadEntity()

        ply.VJ_HLR2_ZombieAssassinScreamT = ply.VJ_HLR2_ZombieAssassinScreamT or 0
        ply.VJ_HLR2_ZombieAssassinRing = ply.VJ_HLR2_ZombieAssassinRing or CreateSound(ply, "vj_hlr/ringing.wav")

        local time = 8
        ply.VJ_HLR2_ZombieAssassinScreamT = CurTime() +time
        ply.VJ_HLR2_ZombieAssassinRing:Play()

        local hookName = "VJ_HLR2_ZombieAssassinScream_" .. ply:EntIndex()
        hook.Add("RenderScreenspaceEffects", hookName, function()
            if !IsValid(ply) or (IsValid(ply) && (ply:Health() <= 0 or ply.VJ_HLR2_ZombieAssassinScreamT < CurTime())) then
                hook.Remove("RenderScreenspaceEffects", hookName)
                ply.VJ_HLR2_ZombieAssassinRing:ChangeVolume(0)
                ply.VJ_HLR2_ZombieAssassinRing:Stop()
                ply:SetEyeAngles(Angle(ply:EyeAngles().p, ply:EyeAngles().y, 0))
                return
            end

            local remaining = ply.VJ_HLR2_ZombieAssassinScreamT -CurTime()
            local div = (remaining /time)

            local rand = Angle(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1)) *360 *div
            local LP = LerpAngle(FrameTime() *2, ply:EyeAngles(), ply:EyeAngles() +rand)
            LP[3] = ply:EyeAngles()[3]
            ply:SetEyeAngles(LP)

            ply.VJ_HLR2_ZombieAssassinRing:ChangeVolume(div)
            DrawMotionBlur(0.1, div *2, 0.01)
            DrawBloom(1 -div, 2, 9, 9, 3, 1, 1, 1, 1)
        end)
    end)
else
    util.AddNetworkString("VJ_HLR2_ZombieAssassinScream")
end