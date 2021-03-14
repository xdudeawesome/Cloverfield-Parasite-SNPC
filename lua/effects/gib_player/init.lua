

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	local Pos = data:GetOrigin()
	local Normal = data:GetNormal()
	
	// Make Bloodstream effects
	for i= 0, 16 do
	
		local effectdata = EffectData()
			effectdata:SetOrigin( Pos + i * Vector(0,0,4) )
			effectdata:SetNormal( Normal )
		util.Effect( "bloodstream", effectdata )
		
	end
	
	// Spawn Gibs
	for i = 0, 32 do
	
		local effectdata = EffectData()
			effectdata:SetOrigin( Pos + i * Vector(0,0,4) + VectorRand() * 8 )
			effectdata:SetNormal( Normal )
		util.Effect( "gib", effectdata )
		
	end
	
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	// Die instantly
	return false
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	// Do nothing - this effect is only used to spawn the particles in Init
	
end



