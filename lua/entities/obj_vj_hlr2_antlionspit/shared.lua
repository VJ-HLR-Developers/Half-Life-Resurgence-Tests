ENT.Type = "anim"
ENT.Base = "obj_vj_projectile_base"
ENT.PrintName = "Toxic Spit"
ENT.Author = "DrVrej"
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"

if (CLIENT) then
	VJ.AddKillIcon("obj_vj_hlr2_antlionspit", ENT.PrintName, VJ.KILLICON_PROJECTILE)
end