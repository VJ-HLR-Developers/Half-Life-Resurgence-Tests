ENT.Base = "npc_vj_human_base"
ENT.Type = "ai"
ENT.PrintName = "Combine Assassin"
ENT.Author = "Cpt. Hazama"
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
ENT.Category = "Half-Life Resurgence"

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Cloaked")
	self:NetworkVar("Float", 0, "FireTime")
end

if CLIENT && GetConVar("vj_hlr2_combine_eyeglow"):GetInt() == 1 then
	local mat = Material("sprites/light_glow02_add")
	local size = 12
	local col = Color(255, 0, 0)

	ENT.HLR_UsesCloakSystem = true

	-- function ENT:Draw()
	-- 	self:DrawModel()
	--	local glowOrigin = self:GetAttachment(self:LookupAttachment("eyes")).Pos
	--	render.SetMaterial(mat)
	--	render.DrawSprite(glowOrigin, size, size, col)
	--	render.DrawSprite(glowOrigin, size, size, col)
	-- end
end