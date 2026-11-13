AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2b/zombie_poison.mdl"

ENT.MeleeAttackDistance = 45
ENT.MeleeAttackDamageDistance = 150
ENT.MeleeAttackDamage = 25
ENT.MeleeAttackDamageType = bit.bor(DMG_POISON, DMG_ACID)

function ENT:OnInit()
	self.SoundTbl_MeleeAttackExtra = {"vj_hlr/gsrc/npc/bullchicken/bc_spithit1.wav", "vj_hlr/gsrc/npc/bullchicken/bc_spithit2.wav"}

	self.IsBeta = true
	self.HeadcrabClass = "npc_vj_hlr2b_headcrab_poison"
end