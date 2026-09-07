ENT.Base = "npc_vj_human_base"
ENT.Type = "ai"
ENT.PrintName = "G-Man"
ENT.Author = "Cpt. Hazama"
ENT.Contact = "http://steamcommunity.com/groups/vrejgaming"
ENT.Category = "Half-Life Resurgence"
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MatFootStepQCEvent(data)
	-- Return true to apply all changes done to the data table.
	-- Return false to prevent the sound from playing.
	-- Return nil or nothing to play the sound without altering it.
	return nil
end