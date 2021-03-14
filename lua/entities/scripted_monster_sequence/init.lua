AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

ENT.NPCMovedToPosition = false
ENT.checkdistance = true

function ENT:Initialize()
	self:SetModel( "models/props_junk/watermelon01_chunk02c.mdl" )
	self:SetColor( 255, 255, 255, 0 )
	
	if !self.movetype then self.movetype = "1" end
end

function ENT:SetFaceTarget()
	local facetarget = ents.Create( "info_target" )
	facetarget:SetPos( self:GetPos() +self:GetForward() *10 )
	facetarget:Spawn()
	facetarget:Activate()
	self.targetnpc:SetTarget( facetarget )
	facetarget:Fire( "kill", "", 1.2 )
end

function ENT:Think()
	if self.targetnpc and IsValid( self.targetnpc ) and self.retry and !self.targetnpc.InSequence then
		self.targetnpc:SetTarget( self )
		self:MoveToPosition()
		self.targetnpc.SSequence = self
		self.targetnpc.InSequence = true
		self.retry = false
	end

	if self.movetype == "5" and self.NPCFacedTarget then
		self.NPCMovedToPosition = true
		self.NPCFacedTarget = false
	end

	if self.sradius and self.start then
		self.sradius_npcdist = tonumber(self.sradius)
		for k, v in pairs( ents.FindInSphere( self:GetPos(), self.sradius ) ) do
			if IsValid( v ) and ( v:GetName() == self.targetnpc_stringname or v:GetClass() == self.targetnpc_stringname ) and v:Health() > 0 then
				if self:GetPos():Distance( v:GetPos() ) <= self.sradius_npcdist then
					self.sradius_npcdist = self:GetPos():Distance( v:GetPos() )
					self.sradius_targetnpc = v
				end
			end
		end
		if self.sradius_targetnpc then
			if self.onlymoveto then
				self:Action( true, self.sradius_targetnpc )
			else
				self:Action( false, self.sradius_targetnpc )
			end
		end
		self.sradius_targetnpc = nil
		self.sradius_npcdist = nil
	elseif self.startonspawn and self.start then
		local target = self:GetTarget( self.targetnpc_stringname )
		if IsValid( target ) and target:Health() > 0 then
			self.startonspawn = false
			self:Fire( "MoveToPosition", "", 0 )
		end
	end
	
	if self.NPCMovedToPosition and !self.onlymoveto then
		if !IsValid( self.targetnpc ) then self.NPCMovedToPosition = false; return end
		//if !self.checkdistance or ( self.checkdistance and self:GetPos():Distance( self.targetnpc:GetPos() ) < 20 ) then	// neccessary?
			self.NPCMovedToPosition = false
			if !self.actanim then
				self:FireOutput( "OnEndSequence" )
				self.targetnpc.InSequence = false
				if self.postanim_allow then
					self.actseqplayed = true
				elseif !self.repeatable then
					self:Remove()
				end
				return
			end
			self:SetFaceTarget()
			local schdActSeq = ai_schedule.New( "Play Act Sequence" )
			schdActSeq:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
			schdActSeq:EngTask( "TASK_FACE_TARGET", 0 )
			schdActSeq:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
			schdActSeq:AddTask( "PlaySequence", { Name = self.actanim, Speed = 1 } )
			schdActSeq:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
			schdActSeq:AddTask( "ScriptedPlayedSequence" )
			self.targetnpc:StartSchedule( schdActSeq )
			if !self.repeatable and !self.postanim_allow then self.waitforseqtoplay = true end
		//else
		//	Msg( "ENT " .. self:GetName() .. " didnt reach position;retry?? \n" )
		//end
	elseif self.NPCMovedToPosition and self.onlymoveto and self.preanim and self.preanim_allow then
		//self.preanim_allow = false
		self.preact = true	// Validate?
		local schdPreSeq = ai_schedule.New( "Play Pre Sequence" )
		schdPreSeq:AddTask( "PlaySequence", { Name = self.preanim, Speed = 1 } )
		schdPreSeq:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
		schdPreSeq:AddTask( "ScriptedPlayedPre" )
		self.targetnpc:StartSchedule( schdPreSeq )
		self.targetnpc.playingpreanim = true	// temporary bugfix for animation bug
	end
	if self.actseqplayed and self.postanim_allow then
		local schdPostSeq = ai_schedule.New( "Play Post Sequence" )
		schdPostSeq:AddTask( "PlaySequence", { Name = self.postanim, Speed = 1 } )
		schdPostSeq:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
		schdPostSeq:AddTask( "ScriptedPlayedPost" )
		self.targetnpc:StartSchedule( schdPostSeq )
		if !self.repeatable and !self.looppostanim then self:Remove() elseif self.looppostanim then
			//self.postanim_allow = false
			self.targetnpc.InSequence = false
		end
	elseif self.actseqplayed and !self.postanim_allow then
		self.targetnpc.InSequence = false
	end
end 

function ENT:GetClosest( tbl )
	self.sradius_npcdist = 99999
	for k, v in pairs( tbl ) do
		local dist = self:GetPos():Distance( v:GetPos() )
		if dist < self.sradius_npcdist then
			self.sradius_npcdist = dist
			self.sradius_targetnpc = v
		end
	end
	self.sradius_npcdist = nil
	if !self.sradius_targetnpc then return false end
	local target = self.sradius_targetnpc
	self.sradius_targetnpc = nil
	return target
end

function ENT:GetTarget( targetname )
	if string.find( targetname, "npc_" ) or string.find( targetname, "monster_" ) or targetname == "monster_generic" or targetname == "generic_actor" or targetname == "cycler" then
		return self:GetClosest( ents.FindByClass( targetname ) )
	else
		return self:GetClosest( ents.FindByName( targetname ) )
	end
end

function ENT:GetSpawnflag( value )
	local spawnflags = { 131072, 65536, 32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 }
	if !table.HasValue( spawnflags, value ) then return false end
	if value == 32 then
		self.nointerrupt = true
	end
	if value == 16 then
		self.startonspawn = true
		self.onlymoveto = true
		self.start = true
	end
	if value == 8 then
		self.leavecorpse = true
	end
	if value == 4 then
		self.repeatable = true
	end
	if value == 64 then
		self.overrideai = true
	end
	if value == 128 then
		self.dontteleport = true
	end
	if value == 256 then
		self.looppostanim = true
	end
	if value == 512 then
		self.priority = true
	end
	if value == 4096 then
		self.allowdeath = true
	end
	return true
end

function ENT:MoveToPosition()
	if self.movetype == "0" then
		self.NPCMovedToPosition = true
		self.checkdistance = false
	elseif self.movetype == "1" then
		if self:GetPos():Distance( self.targetnpc:GetPos() ) > 20 then
			local schdMove = ai_schedule.New( "Move to Sequence" )
			schdMove:EngTask( "TASK_GET_PATH_TO_TARGET", 0 )
			schdMove:EngTask( "TASK_WALK_PATH", 0 ) 
			//if self.targetnpc.playingpreanim then
				schdMove:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
			//end
			schdMove:AddTask( "ScriptedReachedTarget" )
						
			self.targetnpc:StartSchedule( schdMove )
		else self.NPCMovedToPosition = true end
	elseif self.movetype == "2" then
		if self:GetPos():Distance( self.targetnpc:GetPos() ) > 20 then
			local schdMove = ai_schedule.New( "Move to Sequence" )
			schdMove:EngTask( "TASK_GET_PATH_TO_TARGET", 0 )
			schdMove:EngTask( "TASK_RUN_PATH", 0 ) 
			//if self.targetnpc.playingpreanim then
				schdMove:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
			//end
			schdMove:AddTask( "ScriptedReachedTarget" )
						
			self.targetnpc:StartSchedule( schdMove )
		else self.NPCMovedToPosition = true end
	elseif self.movetype == "3" then
		// Custom Movement?
	elseif self.movetype == "4" then
		self.targetnpc:SetPos( self:GetPos() )
		self.targetnpc:SetAngles( self:GetAngles() )
		self.NPCMovedToPosition = true
		self.checkdistance = false
	else
		self.checkdistance = false
		local schdFaceTarget = ai_schedule.New( "Face Target" )
		schdFaceTarget:EngTask( "TASK_FACE_TARGET", 0 ) 
		schdFaceTarget:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )
		schdFaceTarget:AddTask( "ScriptedFacedTarget" )
		self.targetnpc:StartSchedule( schdFaceTarget )
	end
end

function ENT:CheckSpawnflags()
	local spawnflags = { 131072, 65536, 32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 }
	for k, v in pairs( spawnflags ) do
		if v <= self.spawnflags and !self.used then
			local value_a = v
			local value_b = self.spawnflags -v
			if table.HasValue( spawnflags, value_a ) then
				self:GetSpawnflag( value_a )
			end
			if self.spawnflags != v then
				if table.HasValue( spawnflags, value_b ) then
					self.used = true
					self:GetSpawnflag( value_b )
				else
					self.spawnflags = value_b
					self.used = false
					self:CheckSpawnflags()
				end
			else
				self.used = true
			end
		end
	end
end

function ENT:KeyValue( key, value )
	if key == "target" then
		self.target = value	// needed?
	end
	if key == "m_iszIdle" then
		self.preanim = value
		self.preanim_allow = true
	end
	if key == "m_iszEntry" then
		self.entryanim = value
	end
	if key == "m_iszPlay" then						//+
		self.actanim = value
	end
	if key == "m_iszPostIdle" then
		self.postanim = value
		self.postanim_allow = true
	end
	if key == "m_iszCustomMove" then
		self.custommove = value	// needed?
	end
	if key == "m_fMoveTo" then						//+
		self.movetype = value
	end
	if key == "m_iszEntity" then
		self.targetnpc_stringname = value
	end
	if key == "m_flRadius" and tonumber(value) > 0 then
		self.sradius = value
	end
	
	if !self.output then
		self.output = {}
	end
	
	if key == "OnEndSequence" or key == "OnBeginSequence" then
		if !self.output[key] then self.output[key] = {} end
		table.insert( self.output[key], value )
	end
	
	if( key == "spawnflags" ) then
		self.spawnflags = tonumber(value)
		self:CheckSpawnflags()
	end
end

function ENT:FireOutput( output_name )
	if !self.output[output_name] then if self.waitforseqtoplay then self:Remove() end return end
	for k, v in pairs( self.output[output_name] ) do
		//if k != output_name then return end
		local output_exp = string.Explode( ",", v )
		local output_ents = ents.FindByName( output_exp[1] )
		local output = output_exp[2]
		local output_params = output_exp[3]
		local output_delay = output_exp[4]
		local output_once = output_exp[5]
		for k, v in pairs( output_ents ) do
			v:Fire( output, output_params, tonumber(output_delay) )
			//Msg( "Fired output to " .. v:GetName() .. ": Output: " .. output .. "; params: " .. output_params .. "; delay: " .. output_delay .. "\n" )
		end
		if output_once == "-1" then
			self.newoutputs = {}
			for k, v in pairs( self.output ) do
				if v != output_exp[1] then
					self.newoutputs[k] = v
				end
			end
			self.output = self.newoutputs
			self.newoutputs = nil
		end
	end
	if self.waitforseqtoplay then self:Remove() end
end

function ENT:Action( onlymoveto, targetnpc )
	targetnpc:SetTarget( self )
	self.targetnpc = targetnpc
	self.onlymoveto = onlymoveto
	targetnpc.SSequence = self
	if self.sradius and !self.start then	// --> goto line 39(think)
		self.start = true
		return
	else
		targetnpc.InSequence = true
		self.start = false
		self:MoveToPosition()
	end
end

function ENT:AcceptInput( cvar_name, activator, caller )
	//if( string.find( cvar_name,"BeginSequence" ) and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) ) then
	//	Msg( "Got input: BeginSequence \n" )
	//end
	if( string.find( cvar_name,"BeginSequence" ) and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) ) then
		self:FireOutput( "OnBeginSequence" )
		//if self.sradius and !self.start and !self.preact then self.start = true/*; return*/ elseif self.sradius then self.start = false end
		//for k, v in pairs( self:GetTargets( self.targetnpc_stringname ) ) do
			local v = self:GetTarget( self.targetnpc_stringname )
			if IsValid( v ) and v:Health() > 0 and !v.InSequence then
				self:Action( false, v )
			elseif IsValid( v ) and v:Health() > 0 and v.InSequence then
				self.targetnpc = v
				self.onlymoveto = false
				self.retry = true
			end
		//end
	end
	if( string.find( cvar_name,"MoveToPosition" ) and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) ) then
		//if self.sradius and !self.start then self.start = true; return elseif self.sradius then self.start = false end
		//for k, v in pairs( self:GetTargets( self.targetnpc_stringname ) ) do
			local v = self:GetTarget( self.targetnpc_stringname )
			if IsValid( v ) and v:Health() > 0 and !v.InSequence then
				self:Action( true, v )
			elseif IsValid( v ) and v:Health() > 0 and v.InSequence then
				self.targetnpc = v
				self.onlymoveto = true
				self.retry = true
			end
		//end
	end
end
