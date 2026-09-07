include("entities/npc_vj_hlr2_vortigaunt/init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2026 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/vj_hlr/hl2/vortigaunt_slave.mdl"

ENT.VJ_NPC_Class = {"CLASS_COMBINE"}
ENT.AlliedWithPlayerAllies = false

ENT.SoundTbl_FootStep = {"vj_hlr/src/npc/vort/vort_foot1.wav", "vj_hlr/src/npc/vort/vort_foot2.wav", "vj_hlr/src/npc/vort/vort_foot3.wav", "vj_hlr/src/npc/vort/vort_foot4.wav"}
ENT.SoundTbl_Alert = {
	"vj_hlr/src/npc/vort/vo/vortigese02.wav",
	"vj_hlr/src/npc/vort/vo/vortigese03.wav",
	"vj_hlr/src/npc/vort/vo/vortigese04.wav",
	"vj_hlr/src/npc/vort/vo/vortigese05.wav",
	"vj_hlr/src/npc/vort/vo/vortigese07.wav",
	"vj_hlr/src/npc/vort/vo/vortigese08.wav",
	"vj_hlr/src/npc/vort/vo/vortigese09.wav",
	"vj_hlr/src/npc/vort/vo/vortigese13.wav"
}
ENT.SoundTbl_BeforeMeleeAttack =
	"vj_hlr/src/npc/vort/vo/vort_attack21.wav"

ENT.SoundTbl_Pain = {
	"vo/npc/vortigaunt/vortigese03.wav",
	"vo/npc/vortigaunt/vortigese05.wav",
	"vo/npc/vortigaunt/vortigese07.wav"
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:OnCreateSound(sdData, sdFile)
	sdData:SetDSP(2)
end