AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
	self:SetColor( 255, 255, 255, 0 )
	self:Fire( "Trigger", "", 0 )
end

function ENT:Think()
end 

function ENT:KeyValue( key, value )
	if !self.output then
		self.output = {}
	end
	if key == "OnTrigger" then
		table.insert( self.output, value )
	end
	if key == "spawnflags" then
		self.spawnflags = value
	end
end
ENT.Fired = 0
function ENT:AcceptInput( cvar_name, activator, caller )
	if( string.find( cvar_name,"Trigger" ) and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) ) then
		for k, v in pairs( self.output ) do
			local output_exp = string.Explode( ",", v )
			local output_ents = ents.FindByName( output_exp[1] )
			local output = output_exp[2]
			local output_params = output_exp[3]
			local output_delay = output_exp[4]
			local output_once = output_exp[5]
			for k, v in pairs( output_ents ) do
				timer.Create( tostring(self) .. "_outputdelaytimer" .. self.Fired, tonumber(output_delay), 1, function() if IsValid(v) then v:Fire( output, output_params, 0 ) end end )
				self.Fired = self.Fired +1
			end
			if output_once == "-1" then
				self.newoutputs = {}
				for k, v in pairs( self.output ) do
					if v != output_exp[1] then
						table.insert( self.newoutputs, v )
					end
				end
				self.output = self.newoutputs
				self.newoutputs = nil
			end
		end
		if self.spawnflags == 1 then
			self:Remove()
		end
	end
end