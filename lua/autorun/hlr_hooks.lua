if( SERVER ) then
	AddCSLuaFile( "autorun/hlr_hooks.lua" );
	AddCSLuaFile( "autorun/client/hlr_cl_HUD.lua" );
end

function GetEntKeyValues( ent, key, value )
	if !ents_kvtable then ents_kvtable = {} end

	if !ents_kvtable["ent_" .. tostring(ent) .. "_kvtable"] then ents_kvtable["ent_" .. tostring(ent) .. "_kvtable"] = {} end//ent_kvtable end
	if !ents_kvtable["ent_" .. tostring(ent) .. "_kvtable"][key] then
		ents_kvtable["ent_" .. tostring(ent) .. "_kvtable"][key] = value
	else
		if type(ents_kvtable["ent_" .. tostring(ent) .. "_kvtable"][key]) != "table" then
			local f_out = ents_kvtable["ent_" .. tostring(ent) .. "_kvtable"][key]
			ents_kvtable["ent_" .. tostring(ent) .. "_kvtable"][key] = { f_out }
		end
		table.insert( ents_kvtable["ent_" .. tostring(ent) .. "_kvtable"][key], value )
	end
end
hook.Add( "EntityKeyValue", "GetKeyVal", GetEntKeyValues ); 

function PreventSpawn( Player )
	if Player:GetTable().frozen then
		local target = ents.FindByClass( "monster_bullchicken" )[1]
		if Player.aimvector then
			Player:SetEyeAngles( Player.aimvector )
		end
		Player:KillSilent()
		Player.aimvector = nil
		return false
	end
end
hook.Add("PlayerSpawn", "PreventSpawn", PreventSpawn)

HumanGibs = {}

	table.insert( HumanGibs, "models/gibs/antlion_gib_medium_2.mdl" )
	table.insert( HumanGibs, "models/gibs/Antlion_gib_Large_1.mdl" )
	//table.insert( HumanGibs, "models/gibs/gunship_gibs_eye.mdl" )
	table.insert( HumanGibs, "models/gibs/Strider_Gib4.mdl" )
	table.insert( HumanGibs, "models/gibs/HGIBS.mdl" )
	table.insert( HumanGibs, "models/gibs/HGIBS_rib.mdl" )
	table.insert( HumanGibs, "models/gibs/HGIBS_scapula.mdl" )
	table.insert( HumanGibs, "models/gibs/HGIBS_spine.mdl" )


	for k, v in pairs( HumanGibs ) do
		util.PrecacheModel( v )
	end
