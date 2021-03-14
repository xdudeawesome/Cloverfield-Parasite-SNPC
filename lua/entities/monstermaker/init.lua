AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


function ENT:Initialize()
	self:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
	self:SetColor( 255, 255, 255, 0 )
end

function ENT:Think()
	if self.live_children_t then
		self.live_children_t_n = {}
		for k, v in pairs( self.live_children_t ) do
			if !v:IsValid() or v:Health() <= 0 then
			self.MaxLiveChildren = self.MaxLiveChildren +1
			return end
			table.insert( self.live_children_t_n, v )
		end
		self.live_children_t = self.live_children_t_n
	end
	self.MaxNPCCount = tonumber( self.MaxNPCCount )
	self.MaxLiveChildren = tonumber( self.MaxLiveChildren )
end 

function ENT:KeyValue( key, value )
	self[key] = value
end

function ENT:AcceptInput( cvar_name, activator, caller )
	if( string.find( cvar_name,"Enable" ) and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) ) then
		self.StartDisabled = 0
	end
	
	if( string.find( cvar_name,"Disable" ) and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) ) then
		self.StartDisabled = 1
	end

	if( string.find( cvar_name,"Spawn" ) and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) ) then
		if self.MaxNPCCount > 0 and self.MaxLiveChildren > 0 then
			self.MaxNPCCount = self.MaxNPCCount -1
			self.MaxLiveChildren = self.MaxLiveChildren -1
			local monster = ents.Create( self.monstertype )
			monster:SetPos( self:GetPos() )
			monster:SetAngles( self:GetAngles() )
			monster:Spawn()
			monster:Activate()
			if !self.live_children_t then
				self.live_children_t = {}
			end
		end
	end
end