AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2b/zombie.mdl"

function ENT:OnInit()
	self.SoundTbl_Idle = {"vj_hlr/gsrc/npc/zombie/zo_idle1.wav", "vj_hlr/gsrc/npc/zombie/zo_idle2.wav", "vj_hlr/gsrc/npc/zombie/zo_idle3.wav", "vj_hlr/gsrc/npc/zombie/zo_idle4.wav"}
	self.SoundTbl_Alert = {"vj_hlr/gsrc/npc/zombie/zo_alert10.wav", "vj_hlr/gsrc/npc/zombie/zo_alert20.wav", "vj_hlr/gsrc/npc/zombie/zo_alert30.wav"}
	self.SoundTbl_BeforeMeleeAttack = {"vj_hlr/gsrc/npc/zombie/zo_attack1.wav", "vj_hlr/gsrc/npc/zombie/zo_attack2.wav"}
	self.SoundTbl_Pain = {"vj_hlr/gsrc/npc/zombie/zo_pain1.wav", "vj_hlr/gsrc/npc/zombie/zo_pain2.wav"}
	self.SoundTbl_DeathFollow = {"vj_hlr/gsrc/npc/zombie/zo_pain1.wav", "vj_hlr/gsrc/npc/zombie/zo_pain2.wav"}

	self.HeadcrabClass = "npc_vj_hlr2b_headcrab"
end