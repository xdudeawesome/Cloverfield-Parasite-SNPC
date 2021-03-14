
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Model = "models/w_adrenaline.mdl"

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = (tr.HitPos + tr.HitNormal * 16) -Vector( 0, 0, 17 )
	self.Spawn_angles = ply:GetAngles()
	self.Spawn_angles.pitch = 0
	self.Spawn_angles.roll = 0
	self.Spawn_angles.yaw = self.Spawn_angles.yaw + 180
	
	local ent = ents.Create( "item_antidote" )
	ent:SetPos( SpawnPos )
	ent:SetAngles( self.Spawn_angles )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self.Entity:PhysicsInitSphere( 4, "item" )
	self:SetTrigger(true)
	self:SetModel( self.Model )
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass( 1 )
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio( 0.1 )
	end
	
	self.parentent = ents.Create( "prop_physics" )
	self.parentent:SetModel( "models/items/boxsrounds.mdl" )
	self.parentent:SetPos( self:GetPos() )
	self.parentent:SetAngles( self:GetAngles() +Angle( 0, 90, 0 ) )
	self.parentent:SetColor(Color(255,255,255,0))
	self.parentent:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.parentent:DrawShadow( false )
	self.parentent:Spawn()
	self.parentent:Activate()
	self.parentent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	self:SetParent( self.parentent )
	self.initcur = CurTime() +0.1
end

function ENT:Think()
end

function ENT:Touch(ent)
	if ent:IsPlayer() and ent.poisoned and !self.pickedup and CurTime() > self.initcur then
		ent.poisoned = false
		self.pickedup = true
		ent:EmitSound( "items/smallmedkit1.wav", 100, 100 )
		ent:EmitSound( "HL1/fvox/antidote_shot.wav", 100, 100 )
		//self:FireOutput( "OnPlayerPickup" )("self,kill,0")
		self:Remove()
	end
end

function ENT:KeyValue( key, value )
	if !self.output then
		self.output = {}
	end

	if key == "OnPlayerPickup" then
		if !self.output[key] then self.output[key] = {} end
		table.insert( self.output[key], value )
	end
end

//function ENT:FireOutput( output_name )
//	if !self.output[output_name] then return end
//	for k, v in pairs( self.output[output_name] ) do
//		local output_exp = string.Explode( ",", v )
//		local output_ents = ents.FindByName( output_exp[1] )
//		local output = output_exp[2]
//		local output_params = output_exp[3]
//		local output_delay = output_exp[4]
//		local output_once = output_exp[5]
//		for k, v in pairs( output_ents ) do
//			v:Fire( output, output_params, tonumber(output_delay) )
//			//Msg( "Fired output to " .. v:GetName() .. ": Output: " .. output .. "; params: " .. output_params .. "; delay: " .. output_delay .. "\n" )
//		end
//		if output_once == "-1" then
//			self.newoutputs = {}
//			for k, v in pairs( self.output ) do
//				if v != output_exp[1] then
//					self.newoutputs[k] = v
//				end
//			end
//			self.output = self.newoutputs
//			self.newoutputs = nil
//		end
//	end
//end


function ENT:OnTakeDamage(dmg)
end

function ENT:OnRemove()
	if IsValid( self.parentent ) then
		self.parentent:Remove()
	end
end

