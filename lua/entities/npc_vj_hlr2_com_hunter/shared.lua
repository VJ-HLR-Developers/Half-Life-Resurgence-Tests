ENT.Base = "npc_vj_creature_base"
ENT.Type = "ai"
ENT.PrintName = ""
ENT.Author = ""
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
ENT.Category = "Half-Life Resurgence"

if CLIENT && GetConVar("vj_hlr2_combine_eyeglow"):GetInt() == 1 then
	local mat = Material("sprites/light_glow02_add")
	local size = 20
	local col = Color(131, 224, 255)
	local render_SetMaterial = render.SetMaterial
	local render_DrawSprite = render.DrawSprite
	function ENT:Draw()
		self:DrawModel()
		render_SetMaterial(mat)
		for i = 1, 2 do
			local att = self:GetAttachment(self:LookupAttachment(i == 2 && "bottom_eye" or "top_eye"))
			local glowOrigin = att.Pos +att.Ang:Forward() *-5
			render_DrawSprite(glowOrigin, size, size, col)
			render_DrawSprite(glowOrigin, size, size, col)
		end
	end
end
