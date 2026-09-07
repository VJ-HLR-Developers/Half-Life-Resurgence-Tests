ENT.Base = "npc_vj_creature_base"
ENT.Type = "ai"
ENT.PrintName = "Vortigaunt Slave"
ENT.Author = "Cpt. Hazama"
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
ENT.Category = "Half-Life 2"

if CLIENT && GetConVar("vj_hlr2_combine_eyeglow"):GetInt() == 1 then
	local mat = Material("sprites/light_glow02_add")
	local vecOrigin = Vector(9.5, 0, 0)
	local size = 35
	local col = Color(255, 123, 123)
	function ENT:Draw()
		self:DrawModel()
		local bone = self:LookupBone("ValveBiped.head")
		local pos, ang = self:GetBonePosition(bone)
		local glowOrigin = pos +ang:Forward() *vecOrigin.x +ang:Right() *vecOrigin.y +ang:Up() *vecOrigin.z
		render.SetMaterial(mat)
		render.DrawSprite(glowOrigin, size, size, col)
	end
end