if( SERVER ) then
	AddCSLuaFile( "autorun/hlr_concommands_op.lua" );
end

// GONOME
function sk_gonome_health_old( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_gonome_health_value_old = v
		end
	end
end 
concommand.Add( "sk_gonome_health_old", sk_gonome_health_old )

sk_gonome_health_value_old = 200

function sk_gonome_slash_dmg_old( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_gonome_slash_value_old = v
		end
	end
end 
concommand.Add( "sk_gonome_dmg_slash_old", sk_gonome_slash_dmg_old )

sk_gonome_slash_value_old = 18

function sk_gonome_jump_dmg_old( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_gonome_jump_value_old = v
		end
	end
end 
concommand.Add( "sk_gonome_dmg_jump_old", sk_gonome_jump_dmg_old )

sk_gonome_jump_value_old = 30

function sk_gonome_acid_dmg_old( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_gonome_acid_value = v
		end
	end
end 
concommand.Add( "sk_gonome_dmg_acid_old", sk_gonome_acid_dmg_old )

sk_gonome_acid_value_old = 25

function sk_gonome_claws_dmg_old( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_gonome_claws_value_old = v
		end
	end
end 
concommand.Add( "sk_gonome_dmg_claws_old", sk_gonome_claws_dmg_old )

sk_gonome_claws_value_old = 8
