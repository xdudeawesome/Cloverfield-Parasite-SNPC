
/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
local vOffset = data:GetOrigin() 
 	 
 	local NumParticles = 5	 
 	local emitter = ParticleEmitter( vOffset ) 
 	 
 		for i=0, NumParticles do 
			
			local particle1 = emitter:Add( "toxicsplat", vOffset ) 
 			if (particle1) then 
 				 
 				particle1:SetVelocity( VectorRand() * math.Rand(0, 200) ) 
 				 
 				particle1:SetLifeTime( 0 ) 
 				particle1:SetDieTime( math.Rand(0.3, 0.5) ) 
 				 
 				particle1:SetStartAlpha( math.Rand(100, 255) ) 
 				particle1:SetEndAlpha( 0 ) 
 				 
 				particle1:SetStartSize( 40 ) 
 				particle1:SetEndSize( 100 ) 
 				 
 				particle1:SetRoll( math.Rand(0, 360) ) 
 				 
 				particle1:SetAirResistance( 400 ) 
 				 
 				particle1:SetGravity( Vector( 0, 0, -200 ) ) 
 			 
 			end 
			
			local particle2 = emitter:Add( "toxicsplat", vOffset ) 
 			if (particle2) then 
 				 
 				particle2:SetVelocity( VectorRand() * math.Rand(0, 14) ) 
 				
 				particle2:SetLifeTime( 0 ) 
 				particle2:SetDieTime( math.Rand(0, 0.4) ) 
 				 
 				particle2:SetStartAlpha( 30 ) 
 				particle2:SetEndAlpha( 0 ) 
 				 
 				particle2:SetStartSize( 100 ) 
 				particle2:SetEndSize( 0 ) 
 				 
 				particle2:SetRoll( math.Rand(0, 360) ) 
 				particle2:SetRollDelta( math.Rand(-0.5, 0.5) ) 
 				 
 				particle2:SetAirResistance( 400 ) 
 				
 				particle2:SetGravity( Vector( 0, 0, 100 ) ) 
 			 
 			end 
 			 
 		end 
 		 
 	emitter:Finish() 
	
end


/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end
