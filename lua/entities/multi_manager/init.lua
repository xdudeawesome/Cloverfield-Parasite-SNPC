AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
	self:SetColor( 255, 255, 255, 0 )
	self.a = self:EntIndex()
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
	
	if value == "0" then //IsValid( ents.FindByName( key )[1] ) // Value == 1??
		if !self.ent_tr_table then
			self.ent_tr_table = {}
		end
		table.insert( self.ent_tr_table, key )
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
			//	if output == "Open" then
					//v:Fire( output, output_params, tonumber(output_delay) )
					timer.Create( tostring(self) .. "_outputdelaytimer" .. self.Fired, tonumber(output_delay), 1, function() if IsValid(v) then v:Fire( output, output_params, 0 ) end end )
					self.Fired = self.Fired +1
					//Msg( "Fired output to " .. v:GetName() .. ": Output: " .. output .. "; params: " .. output_params .. "; delay: " .. output_delay .. "\n" )
			//	end
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
		if !self.ent_tr_table then return end
		for k, v in pairs( self.ent_tr_table ) do
			for k, v in pairs( ents.FindByName( v ) ) do
				if v and IsValid( v ) then
					if v:GetClass() == "func_platrot" or v:GetClass() == "func_train" or v:GetClass() == "ambient_generic" then
						v:Fire( "Toggle", "", 0 )	//Value delay?
					elseif v:GetClass() == "func_breakable" then
						v:Fire( "break", "", 0 )
					else
						v:Fire( "Trigger", "", 0 )
					end
				end
			end
		end
	end
end