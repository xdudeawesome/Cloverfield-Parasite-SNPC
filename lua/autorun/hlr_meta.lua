if( SERVER ) then
	AddCSLuaFile( "autorun/hlr_meta.lua" );
end

local meta = FindMetaTable( "Entity" );
if( !meta ) then
	return;
end

//
// Gib the player
//
function meta:Gib()

	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetNormal( self:GetPos() -Vector( 0, 0, 12 ) )
	util.Effect( "gib_player", effectdata )

end

/*------------------------------------
   GetCustomAmmo
------------------------------------*/
function meta:GetCustomAmmo( name )
	return self:GetNetworkedInt( "ammo_" .. name );

end

/*------------------------------------
    SetCustomAmmo
------------------------------------*/
function meta:SetCustomAmmo( name, num )
	return self:SetNetworkedInt( "ammo_" .. name, num );
end

/*------------------------------------
    AddCustomAmmo
------------------------------------*/
function meta:AddCustomAmmo( name, num )

	return self:SetCustomAmmo( name, self:GetCustomAmmo( name ) + num );

end

local meta = FindMetaTable( "Player" );
if( !meta ) then
	return;
end

/*------------------------------------
   GetPanelScale
------------------------------------*/
function meta:GetPanelScale()
	local scale_w = 1
	local scale_h = 1
	if ScrW() == 1024 then
		scale_w = 1.5625
		scale_h = 1.58
	elseif ScrW() == 1152 then
		scale_w = 1.35
		scale_h = 1.45
	elseif ScrW() == 1280 then
		scale_w = 1.25
		if ScrH() == 960 then
			scale_h = 1.27
		else
			scale_h = 1.225
		end
	end
	return {scale_w,scale_h}
end

function meta:PossessNPC(npc, igncontrol)
	local function Possess( ent, NPC )
		ent.possessed = true
		ent.master = self
		
		ent:SetNetworkedBool( 10, true )
		ent:SetNetworkedEntity( 11, self )
		
		if NPC then
			local possess_ent = ents.Create( "sent_possess" )
			possess_ent.target = ent
			possess_ent.master = self
			possess_ent:Spawn()
			possess_ent:Activate()
		end
		
		local viewent_pos = ent:LocalToWorld( ent.possess_viewpos )
		local viewent = ents.Create( "sent_killicon" )
		viewent:SetPos( viewent_pos )
		viewent:SetAngles( (ent:GetPos() -viewent_pos +ent.possess_addang):Angle() )
		viewent:SetParent( ent )
		viewent:Spawn()
		viewent:Activate()
		ent.possess_viewent = viewent

		self:SetViewEntity( viewent )
		self:GetTable().frozen = true
		self:KillSilent()
	end

	if npc.possessed then self:PrintMessage( HUD_PRINTTALK, "You can't possess this NPC! It's already possessed by " .. npc.master:GetName() .. "!\n" ); return false
	elseif npc.controlled and !igncontrol then self:PrintMessage( HUD_PRINTTALK, "You can't possess this NPC! It's being controlled by someone else!\n" ); return false end
	local possess_snpcs = { "monster_houndeye", "monster_bullchicken", "monster_alien_grunt", "monster_gargantua", "monster_cockroach", "monster_panthereye", "monster_alien_slave", "monster_headcrab", "monster_zombie", "monster_babycrab", "monster_human_grunt", "monster_human_assassin", "monster_parasite", "monster_bigmomma", "monster_ichthyosaur", "monster_hwgrunt", "npc_stukabat", "monster_zombie_barney", "monster_zombie_soldier", "monster_gonome", "monster_alien_babyvoltigore", "monster_alien_voltigore", "monster_babygarg", "monster_pitdrone" }
	local possess_npcs = { "npc_zombine", "npc_zombie", "npc_zombie_torso", "npc_fastzombie", "npc_fastzombie_torso", "npc_poisonzombie", "npc_headcrab", "npc_headcrab_black", "npc_headcrab_poison", "npc_headcrab_fast", "npc_antlionguard", "npc_antlion", "npc_antlion_worker", "npc_vortigaunt", "npc_strider" }
	
	local class = npc:GetClass()
	if table.HasValue( possess_snpcs, class ) then
		Possess( npc )
	elseif table.HasValue( possess_npcs, class ) then
		Possess( npc, true )
	elseif !table.HasValue( possess_snpcs, class ) and !table.HasValue( possess_npcs, targetnpc_class ) then
		self:PrintMessage( HUD_PRINTTALK, "You can't possess this NPC!" )
		return false
	end
	return true
end