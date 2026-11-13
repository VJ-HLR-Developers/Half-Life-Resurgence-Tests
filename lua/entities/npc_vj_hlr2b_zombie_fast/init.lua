AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2b/zombie_fast.mdl"

function ENT:OnInit()
	self.SoundTbl_Idle = {"vj_hlr/src/npc/beta_zombiefast/breath1.wav", "vj_hlr/src/npc/beta_zombiefast/breath2.wav"}
	self.SoundTbl_DefBreath = {"vj_hlr/src/npc/beta_zombiefast/throat_loop1.wav", "vj_hlr/src/npc/beta_zombiefast/tremble_loop1.wav"}

	self.IsBeta = true
	self.HeadcrabClass = "npc_vj_hlr2b_headcrab_fast"
end