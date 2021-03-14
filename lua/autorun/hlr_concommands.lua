if( SERVER ) then
	AddCSLuaFile( "autorun/hlr_concommands.lua" );
end

// PARASITE
function sk_parasite_health( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_parasite_health_value = v
		end
	end
end 
concommand.Add( "sk_parasite_health", sk_parasite_health )

sk_parasite_health_value = 70

function sk_parasite_slash_dmg( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_parasite_slash_value = v
		end
	end
end 
concommand.Add( "sk_parasite_dmg_slash", sk_parasite_slash_dmg )

sk_parasite_slash_value = 12

function sk_stukabat_health_old( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_stukabat_health_value = v
		end
	end
end 
concommand.Add( "sk_stukabat_health_old", sk_stukabat_health_old )

sk_stukabat_health_value_old = 160

function sk_stukabat_claw_dmg_old( player, command, arguments )
	if GetConVarNumber("sv_cheats") == 1 then
		for k,v in pairs( arguments ) do
			sk_stukabat_claw_value_old = v
		end
	end
end 
concommand.Add( "sk_stukabat_claw_dmg_old", sk_stukabat_claw_dmg_old )

sk_stukabat_claw_value_old = 38
