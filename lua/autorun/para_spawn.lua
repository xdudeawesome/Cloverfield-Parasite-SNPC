if( SERVER ) then
	AddCSLuaFile( "autorun/para_spawn.lua" );
end

local Category = "Zombies + Enemy Aliens"

local NPC = { 	Name = "Parasite", 
				Class = "monster_parasite",
				Category = Category	}

list.Set( "NPC", NPC.Class, NPC )	
	
local Category = "Half-Life: Renaissance"

//local NPC = { 	Name = "Gonome", 
//				Class = "npc_gonome",
//				Category = Category	}
//
//list.Set( "NPC", NPC.Class, NPC )	
	
//local NPC = { 	Name = "Stukabat", 
//				Class = "monster_stukabat",
//				Category = Category	}
//
//list.Set( "NPC", NPC.Class, NPC )	
	
//local NPC = { 	Name = "Gargantua", 
//				Class = "npc_garg",
//				Category = Category	}
//
//list.Set( "NPC", NPC.Class, NPC )	
	
//local NPC = { 	Name = "Alien Grunt", 
//				Class = "npc_agrunt",
//				Category = Category	}
//
//list.Set( "NPC", NPC.Class, NPC )	
	