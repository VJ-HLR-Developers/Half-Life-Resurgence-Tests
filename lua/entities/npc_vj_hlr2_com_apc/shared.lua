ENT.Base = "npc_vj_tank_base"
ENT.Type = "ai"
ENT.PrintName = "Overwatch APC"
ENT.Author = "DrVrej"
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
ENT.Category = "Half-Life Resurgence"

function ENT:SetupDataTables()
	self:NetworkVar("Bool", "Driving")
	self:NetworkVar("Bool", "DrivingForward")
	self:NetworkVar("Float", "DriveSpeed")
	self:NetworkVar("Float", "DriverYaw")
	self:NetworkVar("Float", "DriverPitch")
end

if CLIENT then
    local wheelBones = {
        "APC.Wheel_FL_Rotate",
        "APC.Wheel_FR_Rotate",
        "APC.Wheel_RL_Rotate",
        "APC.Wheel_RR_Rotate",
    }
    function ENT:Draw()
        self:DrawModel()

		if IsValid(self.NPCModel) then
			local npc = self.NPCModel
			npc:SetPos(self:GetPos() +self:GetRight() *-1.5 +self:GetForward() *-30 +self:GetUp() *50)
			npc:SetAngles(self:GetAngles())
			npc:SetSequence("man_gun")

            npc:SetPoseParameter("head_yaw", self:GetDriverYaw())
            npc:SetPoseParameter("head_pitch", self:GetDriverPitch())
		else
			self.NPCModel = ClientsideModel("models/police.mdl")
		end

        self.WheelRot = self.WheelRot or 0
        self.WheelSpeed = self.WheelSpeed or 0

        local targetSpeed = 0
        if self:GetDriving() then
            targetSpeed = self:GetDriveSpeed() *(self:GetDrivingForward() && 1 or -1)
        end
        self.WheelSpeed = Lerp(FrameTime() *10, self.WheelSpeed, targetSpeed)
        self.WheelRot = self.WheelRot +(self.WheelSpeed *FrameTime() *0.2)
        for _, v in pairs(wheelBones) do
            local boneID = self:LookupBone(v)
            if boneID then
                self:ManipulateBoneAngles(boneID, Angle(0, 0, self.WheelRot))
            end
        end
    end

	function ENT:OnRemove()
		self.NPCModel:Remove()
	end
end