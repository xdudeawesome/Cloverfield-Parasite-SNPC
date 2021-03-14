
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
	self.damagecount = 0
	self.damagedelay = CurTime() +1.2
	if !self.poisonent:IsPlayer() then return end
	self.poisonent:EmitSound( "HL1/fvox/blood_toxins.wav", 100, 100 )
	self.innsuf_med = CurTime() +5	
end

function ENT:Explode( ent )
	self:Remove()
	ent:Gib()
	if ent:IsPlayer() then ent:KillSilent() else ent:Remove() end // takedamage, then kill?
end

function ENT:SpawnBloodEffect( bloodtype, Pos )
	local bloodeffect = ents.Create( "info_particle_system" )
	if bloodtype == "red" then self.bloodeffecttype = "blood_impact_red_01" elseif bloodtype == "yellow" then self.bloodeffecttype = "blood_impact_yellow_01" else self.bloodeffecttype = "blood_impact_green_01" end
	
	bloodeffect:SetKeyValue( "effect_name", self.bloodeffecttype )
	bloodeffect:SetPos( Pos ) 
	bloodeffect:Spawn()
	bloodeffect:Activate() 
	bloodeffect:Fire( "Start", "", 0 )
	bloodeffect:Fire( "Kill", "", 0.1 )
	self.bloodeffecttype = nil
	return true
end

function ENT:Think()
	if self.depleted or !self.poisonent or !IsValid( self.poisonent ) or !self.poisonent.poisoned or self.poisonent:Health() <= 0 then self:Remove() end
	if CurTime() > self.damagedelay then
		if self.innsuf_med and CurTime() > self.innsuf_med then self.innsuf_med = false; self.poisonent:EmitSound( "HL1/fvox/innsuficient_medical.wav", 100, 100 ) end
		self.damagecount = self.damagecount +1
		self.damagedelay = CurTime() +1.2
		if (self.poisonent:Health() -8) > 0 then
			self.poisonent:TakeDamage( 8, self, self.Owner )
			local bloodtype
			if self.poisonent.BloodType then
				bloodtype = self.poisonent.BloodType
			else
				bloodtype = "red"
			end
			local Pos = self.poisonent:LocalToWorld( self.poisonent:OBBCenter() )
			self:SpawnBloodEffect( bloodtype, Pos )
			if self.poisonent:IsPlayer() then self.poisonent:EmitSound( "player/pl_pain" .. math.random(5,7) .. ".wav", 100, 100 ) end
		else
			local inflictor = self
			local attacker
			if IsValid( self.Owner ) then
				attacker = self.Owner
			else
				attacker = self
			end
			//gamemode.Call( "OnNPCKilled", self.poisonent, attacker, inflictor )
			self:Explode( self.poisonent )
			util.BlastDamage( inflictor, attacker, self.poisonent:GetPos(), 128, 33 )
		end
		if self.damagecount >= 9 then self:Remove() end
	end
end


function ENT:KeyValue( key, value )
end



function ENT:OnTakeDamage(dmg)
end

function ENT:OnRemove()
	if self.poisonent and IsValid( self.poisonent ) then self.poisonent.poisoned = false end
end

