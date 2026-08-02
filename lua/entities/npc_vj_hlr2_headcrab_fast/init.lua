AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/headcrab.mdl"

ENT.ControllerParams = {
	CameraMode = 1,
	ThirdP_Offset = Vector(),
	FirstP_Bone = "HCFast.Chest",
	FirstP_Offset = Vector(1, 0, 2),
}

ENT.FootstepSoundTimerRun = 0.1
ENT.FootstepSoundTimerWalk = 0.1

ENT.MainSoundPitch = 120
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Init()
	self:SetCollisionBounds(Vector(12, 12, 15), Vector(-12, -12, 0))
end