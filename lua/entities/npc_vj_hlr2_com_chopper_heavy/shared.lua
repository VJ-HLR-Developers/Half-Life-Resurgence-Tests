ENT.Base = "npc_vj_creature_base"
ENT.Type = "ai"
ENT.PrintName = ""
ENT.Author = ""
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
ENT.Category = "Half-Life Resurgence"

if CLIENT then
	function ENT:Think()
		self.RPM = self.RPM && self.RPM +(1500 *FrameTime()) or 0
		local Rot1 = Angle(self.RPM, 0, 0)
		local Rot2 = Angle(0, 0, self.RPM)
		local Rot3 = Angle(0, 0, self.RPM)
		Rot1:Normalize()
		Rot2:Normalize()
		Rot3:Normalize()
		self:ManipulateBoneAngles(2, -Rot1)
		self:ManipulateBoneAngles(3, -Rot2)
		self:ManipulateBoneAngles(5, -Rot3)
	end
end