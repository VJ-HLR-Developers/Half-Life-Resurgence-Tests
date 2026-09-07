ENT.Base = "npc_vj_creature_base"
ENT.Type = "ai"
ENT.PrintName = ""
ENT.Author = ""
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
ENT.Category = "Half-Life Resurgence"

if CLIENT && GetConVar("vj_hlr2_combine_eyeglow"):GetInt() == 1 then
	local mat = Material("sprites/light_glow02_add")
	local size = 6.5
	local col = Color(255, 163, 50)
	function ENT:Draw()
		self:DrawModel()
		render.SetMaterial(mat)
		for i = 1, 2 do
			local att = self:GetAttachment(self:LookupAttachment("eyes"))
			local glowOrigin = att.Pos +att.Ang:Forward() *3 +att.Ang:Right() *(i == 1 && 3.25 or -2.5) +att.Ang:Up() *(i == 1 && -0.1 or 2.4)
			render.DrawSprite(glowOrigin, size, size, col)
			render.DrawSprite(glowOrigin, size, size, col)
		end
	end
end