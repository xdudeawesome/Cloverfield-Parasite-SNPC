
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
include('schedules.lua')
include('tasks.lua')

// Variables

ENT.m_fMaxYawSpeed 				= 200 // Max turning speed
ENT.m_iClass					= CLASS_NONE // NPC Class

ENT.wander = 1	// If set to 1, the NPC will wander around randomly if it doesn't see an enemy. 
ENT.pain = 1
ENT.CheckWorld = false
ENT.scripted = true

ENT.SpawnRagdollOnDeath = true
ENT.FadeOnDeath = false
ENT.BloodType = "red"
ENT.Pain = true
//ENT.PainSound = "npc/houndeye/he_pain"
ENT.PainSoundCount = 5
//ENT.DeathSound = "npc/houndeye/he_die"
ENT.DeathSoundCount = 3
ENT.DeathSkin = false
ENT.ScaleDmg = false
ENT.RemoveOnDeath = false
ENT.PrintDeathDecal = false

ENT.Sounds = {}

ENT.alert_allow = true
ENT.closest_range = 9999
ENT.damage_count = 0
ENT.res_time = 0
ENT.WaterMonster = false

ENT.possess_viewpos = Vector( -80, 0, 58 )
ENT.possess_addang = Vector(0,0,55)
ENT.possess_viewmode = 1

ENT.possess_viewdistance = 120
ENT.possess_viewheight = 50

ENT.enemy_memory = {}

AccessorFunc( ENT, "m_iClass", 			"NPCClass" )
AccessorFunc( ENT, "m_fMaxYawSpeed", 	"MaxYawSpeed" )

local schdHurt = ai_schedule.New( "Hurt" ) 
schdHurt:EngTask( "TASK_SMALL_FLINCH", 0 ) 

local schdHide = ai_schedule.New( "Hide" ) 
schdHide:EngTask( "TASK_FIND_COVER_FROM_ENEMY", 0 ) 
schdHide:EngTask( "TASK_STOP_MOVING", 0 ) 
schdHide:AddTask( "StoppedHiding", 0 ) 

function ENT:Possess_SetViewVector()
	local Vec_a = self.possess_viewent:GetPos() *(self.master:GetAimVector( )*12)
	local Vec_b = self.possess_viewent:GetForward()
	self.master.aimvector = (Vec_a -Vec_b):Angle()
end

function ENT:PossessView()
	if self.master:KeyDown( 2 ) then
		self:EndPossession()
		return false
	end
	if self.master:KeyDown( 131072 ) and ( !self.allowswitchdelay or CurTime() > self.allowswitchdelay ) then
		self.allowswitchdelay = CurTime() +3
		//self.master:PrintMessage( "Switched viewmode!" )
		if self.possess_viewmode == 1 then
			self.possess_viewmode = 2
			local viewent_pos = self:LocalToWorld( self.possess_viewpos )
			self.possess_viewent:SetPos( viewent_pos )
			self.possess_viewent:SetAngles((self:GetPos() -viewent_pos +self.possess_addang):Angle())
		else
			self.possess_viewmode = 1
			self.master:SetEyeAngles( self.possess_viewent:GetAngles() +Vector(0,180,0) )
		end
		//self.master:EmitSound( beepsound, 100, 100 )
	else
		self.allowswitchdelay = CurTime()
	end
	
	if self.possess_viewmode == 1 then
		local ang = self.master:GetAimVector( ):Angle() +Angle(180,0,180)
		local pos = self:GetPos() +self.master:GetAimVector( ) *self.possess_viewdistance +Vector(0,0,self.possess_viewheight)
		self.possess_viewent:SetAngles( ang )
		
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = pos
		tracedata.filter = self
		local trace = util.TraceLine(tracedata) 
		if trace.HitWorld then
			self.possess_viewent:SetPos( trace.HitPos +trace.HitNormal *12 )
		else
			self.possess_viewent:SetPos( pos )
		end
	else
		local pos = self:LocalToWorld( self.possess_viewpos )
		
		local tracedata = {}
		tracedata.start = self:GetPos()
		tracedata.endpos = pos
		tracedata.filter = self
		local trace = util.TraceLine(tracedata) 
		if trace.HitWorld then
			self.possess_viewent:SetPos( trace.HitPos +trace.HitNormal *12 )
		else
			self.possess_viewent:SetPos( pos )
		end
	end
	return true
end

function ENT:PossessMovement( movedist )
	local function MoveToTargetPos( pos, walk )
		local movetarget = ents.Create( "info_target" )
		movetarget:SetPos( pos )
		movetarget:Spawn()
		movetarget:Activate()
		self:SetTarget( movetarget )
		local schdPossessForward = ai_schedule.New( "Possess_moveforward" )
		schdPossessForward:EngTask( "TASK_GET_PATH_TO_TARGET", 0 )
		if !walk then
			schdPossessForward:EngTask( "TASK_RUN_PATH_TIMED", 1 )
		else
			schdPossessForward:EngTask( "TASK_WALK_PATH_TIMED", 1 )
		end
		self:StartSchedule( schdPossessForward )
		movetarget:Fire( "Kill", "", 1 )
	end
	if self.master:KeyDown( 8 ) then
		local targetpos 
		local trace = {}
		trace.start = self:GetPos()
		if self.possess_viewmode == 1 then
			local Pos_a = self.possess_viewent:GetPos()
			Pos_a.z = 0
			Pos_a.x = Pos_a.x *10
			Pos_a.y = Pos_a.y *10
			local Pos_b = self:GetPos() +Vector(0,0,10)
			Pos_b.z = 0
			Pos_b.x = Pos_b.x *10
			Pos_b.y = Pos_b.y *10
			local normal = (Pos_a -Pos_b):GetNormal()
			trace.endpos = (self:GetPos() +normal *movedist) +Vector(0,0,10)
		else
			trace.endpos = self:LocalToWorld( Vector( movedist, 0, 10 ) )
		end
		trace.filter = self
		
		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then
			targetpos = tr.HitPos
		else
			if self.possess_viewmode == 1 then
				local Pos_a = self.possess_viewent:GetPos()
				Pos_a.z = 0
				Pos_a.x = Pos_a.x
				Pos_a.y = Pos_a.y
				local Pos_b = self:GetPos() +Vector(0,0,10)
				Pos_b.z = 0
				Pos_b.x = Pos_b.x
				Pos_b.y = Pos_b.y
				local normal = (Pos_b -Pos_a):GetNormal()
				targetpos = self:GetPos() +normal *movedist
			else
				targetpos = self:GetPos() +self:GetForward() *movedist
			end
		end
		if self.possess_viewmode == 2 then
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self:GetRight() *-1 *50
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self:GetRight() *50
			end
		else
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self.possess_viewent:GetRight() *-1 *120
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self.possess_viewent:GetRight() *120
			end
		end
		local walk = false
		if self.master:KeyDown( 262144 ) then walk = true end
		MoveToTargetPos( targetpos, walk )
	elseif self.possess_viewmode == 1 and self.master:KeyDown( 16 ) then
		local targetpos 
		local trace = {}
		trace.start = self:GetPos()
		if self.possess_viewmode == 1 then
			local trace_x = self.master:GetAimVector().x *2
			local trace_y = self.master:GetAimVector().y *2
			trace.endpos = self:LocalToWorld( Vector( trace_x, trace_y, 10 ) )
		else
			trace.endpos = self:LocalToWorld( Vector( -movedist, 0, 10 ) )
		end
		trace.filter = self
		
		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then
			targetpos = tr.HitPos
		else
			if self.possess_viewmode == 1 then
				targetpos = self:GetPos() +self.master:GetAimVector() *200
			else
				targetpos = self:GetPos() +self:GetForward() *-1 *movedist
			end
		end
		if self.possess_viewmode == 2 then
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self:GetRight() *-1 *50
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self:GetRight() *50
			end
		else
			if self.master:KeyDown( 512 ) then
				targetpos = targetpos +self.possess_viewent:GetRight() *-1 *120
			elseif self.master:KeyDown( 1024 ) then
				targetpos = targetpos +self.possess_viewent:GetRight() *120
			end
		end
		local walk = false
		if self.master:KeyDown( 262144 ) then walk = true end
		MoveToTargetPos( targetpos, walk )
	elseif self.master:KeyDown( 512 ) then
		if self.possess_viewmode == 1 then
			local walk = false
			if self.master:KeyDown( 262144 ) then walk = true end
			MoveToTargetPos( self:GetPos() +self.possess_viewent:GetRight() *-1 *120, walk )
		else
			MoveToTargetPos( self:GetPos() +self:GetRight() *-1 *1.3 +self:GetForward() *4 )
		end
	elseif self.master:KeyDown( 1024 ) then
		if self.possess_viewmode == 1 then
			local walk = false
			if self.master:KeyDown( 262144 ) then walk = true end
			MoveToTargetPos( self:GetPos() +self.possess_viewent:GetRight() *120, walk )
		else
			MoveToTargetPos( self:GetPos() +self:GetRight() *1.3 +self:GetForward() *4 )
		end
	end
end

function ENT:InitSounds()
	self.Sounds = {}
	for k, v in pairs(self.DSounds) do
		self.Sounds[k] = v
	end
	self.DSounds = nil
	for k, v in pairs(self.Sounds) do
		self.Sounds[k] = {}
		for l, w in pairs(v) do
			table.insert(self.Sounds[k], CreateSound( self, w ))
		end
	end
end

function ENT:EndPossession()
	self.possessed = false
	
	self:SetNetworkedBool( 10, false )
	self:SetNetworkedEntity( 11, NULL )
	
	self.possession_allowdelay = nil
	if self.master and IsValid( self.master ) then self.master:GetTable().frozen = false; self.master.aimvector = nil; self.master:Spawn(); self.master:SetViewEntity( self.master ) end
	if self.possess_viewent and IsValid( self.possess_viewent ) then self.possess_viewent:Remove() end
	self.master = nil
end

function ENT:Task_StoppedHiding()
	self:TaskComplete()
end

function ENT:TaskStart_StoppedHiding()
	self:TaskComplete()
	if self.hidecur and CurTime() < self.hidecur then
		self:StartSchedule( schdHide )
	else
		self.hiding = false
	end
end

function ENT:DoSchedule( schedule )
	if ( self:TaskFinished() ) then
		self:NextTask( schedule )
	end
  
	if ( self.CurrentTask ) then
		self:RunTask( self.CurrentTask )
	end
end

function ENT:OnTaskComplete()
	self.bTaskComplete = true
	//self:DoSchedule(self.CurrentSchedule)
end

function ENT:ValidateMemory()
	if !self.enemy_memory then return false end
	local new_memory = {}
	for k, v in pairs( self.enemy_memory ) do
		if IsValid( v ) and v:Health() > 0 and self:Disposition( v ) == 1 and ( !v:IsPlayer() or ( v:IsPlayer() and GetConVarNumber("ai_ignoreplayers") != 1 ) ) then
			table.insert( new_memory, v )
		end
	end
	self.enemy_memory = new_memory
	return true
end

function ENT:OnCondition( iCondition )
	if self.efficient then return end
	//Msg( self, " Condition: ", iCondition, " - ", self:ConditionName(iCondition), "\n" )
	if !self.val_cur then self.val_cur = CurTime() +0.2 end
	if self.val_cur < CurTime() then
		self:ValidateMemory()
		self.val_cur = nil
	end
	if( ( ( !self:HasCondition( 8 ) and self:HasCondition( 7 ) ) or ( self:HasCondition( 8 ) and self:HasCondition( 7 ) ) ) or ( self.enemy_memory and table.Count( self.enemy_memory ) > 0 ) ) then
		self.FoundEnemy = true
		self.FoundEnemy_fear = false
		timer.Destroy( "wandering_timer" .. self.Entity:EntIndex( ) )
		self.timer_created = false
	elseif( self:HasCondition( 8 ) and !self:HasCondition( 13 ) ) then
		self.FoundEnemy_fear = true
		timer.Destroy( "wandering_timer" .. self.Entity:EntIndex( ) )
		self.timer_created = false
	elseif( self.FoundEnemy_fear and self:HasCondition( 13 ) ) then
		self.FoundEnemy_fear = false
	elseif( ( !self.enemy_memory or table.Count( self.enemy_memory ) == 0 ) and ( self:HasCondition( 13 ) and self:HasCondition( 31 ) ) or ( !self:HasCondition( 8 ) and !self:HasCondition( 7 ) and !self.enemy_occluded ) ) then
		self.FoundEnemy = false
	end
	
	if( !self.alert_allow and !self.FoundEnemy and !timer.Exists( "self.alert_allow_timer" .. self:EntIndex() ) ) then
		timer.Create( "self.alert_allow_timer" .. self:EntIndex(), 3, 1, function() self.alert_allow = true end )
	elseif( self.FoundEnemy ) then
		timer.Destroy( "self.alert_allow_timer" .. self:EntIndex() )
	end
	
	if( self:HasCondition( 13 ) ) then
		self.enemy_occluded = true
		timer.Destroy( "self.enemy_occluded_timer" .. self:EntIndex() )
	elseif( !timer.Exists( "self.enemy_occluded_timer" .. self:EntIndex() ) ) then
		timer.Create( "self.enemy_occluded_timer" .. self:EntIndex(), 1.5, 1, function() self.enemy_occluded = false end )
	end
	
	if iCondition == 26 and !self:HasCondition( 10 ) then
		self:SetCondition( 10 )
	end
	
	/*if iCondition == 26 then
		self.hadnewenemy = true
		self.hadenemydelay = CurTime() +1
	end
	if self.hadenemydelay and CurTime() > self.hadenemydelay then
		self.hadnewenemy = false
		self.hadenemydelay = nil
	end*/
end

function ENT:DEV_PRINT(msg)
	for k, v in pairs(player:GetAll()) do
		v:PrintMessage(HUD_PRINTTALK, msg)
	end
end

function ENT:DEV_PRINTINFO()
	Msg( "Enemy memory:\n" )
	PrintTable(self.enemy_memory)
	Msg( "Current enemy: " .. tostring(self.enemy) .. "\n" )
	if !self.squadtbl then return end
	Msg( "Squad members:\n" )
	PrintTable(self.squadtbl)
end

function ENT:CheckEnemy( rel )
	if rel == 1 then
		if IsValid( self.enemy ) and self.enemy:Health() > 0 and self:Visible(self.enemy) and ( !self.WaterMonster or ( self.WaterMonster and self.enemy:WaterLevel() > 1 ) ) then
			return true
		elseif self.enemy then
			self.enemy = NULL
			return false
		end
		return false
	end
	if IsValid( self.enemy_fear ) and self.enemy_fear:Health() > 0 and self:Visible(self.enemy_fear) and ( !self.WaterMonster or ( self.WaterMonster and self.enemy_fear:WaterLevel() > 1 ) ) then
		return true
	elseif self.enemy_fear then
		self.enemy_fear = NULL
		return false
	end
end

function ENT:CheckForEnemiesInRange()
	for k, v in pairs(ents.FindInSphere(self:GetPos(),84)) do
		if v && v:IsValid() && v != self && ( v:IsNPC() or ( v:IsPlayer() and v:Alive() and convar_ignoreply != 1 and !self.ignoreplys ) ) && e:Health() > 0 then
			if( self.FoundEnemy && self:Disposition( e ) == 1 ) then
			
			end
		end
	end
end

function ENT:GetCenter( ent )
	local pos = ent:OBBCenter()
	local ang = ent:GetAngles()
	local pos_center = ent:GetPos() + ang:Up() * pos.z + ang:Forward() * pos.x + ang:Right() * pos.y
	return pos_center
end

function ENT:GetEnemies()
	local convar_ignoreply = GetConVarNumber("ai_ignoreplayers")
	local tbl = {}
	local enemies = ents.FindByClass("npc_*")
	table.Add(enemies,ents.FindByClass("monster_*"))
	table.Add(enemies,player:GetAll())
	for k, v in pairs(enemies) do
		local ang = self:GetAngles().y -(v:GetPos() -self:GetPos()):Angle().y
		if ang < 0 then ang = ang +360 end
		local disposition = self:Disposition(v)
		if IsValid(v) and ((v:IsNPC() and v != self) or (v:IsPlayer() and convar_ignoreply == 0 and !self.ignoreplys)) and v:Health() > 0 /*and self:Visible(v)*/ and (disposition == 1 or disposition == 2) and ( !self.WaterMonster or ( self.WaterMonster and v:WaterLevel() > 1 ) ) and ((ang <= 90 and ang >= 0) or (ang <= 360 and ang >= 270)) then
			table.insert(tbl,v)
		end
	end
	return tbl
end

function ENT:UpdateMemory(tbl)
	for k, v in pairs( tbl ) do
		if IsValid( v ) and !table.HasValue( self.enemy_memory, v ) then
			table.insert( self.enemy_memory, v )
		end
	end
end

function ENT:FindInCone_V12( searchDist )
	local convar_ignoreply = GetConVarNumber("ai_ignoreplayers")
	local closestDist = searchDist
	//conetable = {}
	
	local function GetEnemy( tbl )
		for k, v in pairs( tbl ) do
			if self.triggertarget and v:IsPlayer() then
				if self.triggercondition == "7" or self.triggercondition == "8" or self.triggercondition == "9" or self.triggercondition == "10" then	// temporary trigger for the 'hear' condition
					self:GotTriggerCondition()
				elseif self.triggercondition == "11" and ( !self.enemy or !IsValid( self.enemy ) ) then
					self:GotTriggerCondition()
				end
			end
			//table.insert( conetable, v )
			local d = v:GetPos():Distance(self:GetPos())
			if d < closestDist then
				if( self.FoundEnemy && self:Disposition( v ) == 1 ) then
					if self.triggertarget and self.triggercondition == "1" and v:IsPlayer() then
						self:GotTriggerCondition()
					end
					if ( !self.enemy or !IsValid( self.enemy ) ) and ( !self.enemy_memory or table.Count( self.enemy_memory ) == 0 ) then
						if( self.Sounds["Alert"] and #self.Sounds["Alert"] > 0 and !self.following ) then //and self:HasCondition( 7 ) and !self:HasCondition( 8 )
							//self:EmitSound( self.alertsound .. math.random(1,self.alertsound_amount) .. ".wav" )
							self:PlayRandomSound("Alert")
						end
						if self.alertanim then self:PlayAlertAnim() end
					end
					closestDist = d
					self.enemy_fear = NULL
					self.enemy = v
					self.schedule_runtarget_pos = v:GetPos( )	
				elseif( self.FoundEnemy_fear && self:Disposition( v ) == 2 ) then
					self.enemy = NULL
					self.enemy_fear = v
				end
				if( self:Disposition( v ) == 2 and self:HasCondition( 7 ) and self:HasCondition( 8 ) ) then
					table.insert( self.table_fear, v )
					self:AddEntityRelationship( v, 3, 10 )
				end
			end
		end
	end
	local enemies = self:GetEnemies()
	GetEnemy( enemies )
	if ( !self.enemy or !IsValid( self.enemy ) ) and self.enemy_memory then
		self:ValidateMemory()
		GetEnemy( self.enemy_memory )
	end
	
	if self.squad and self.squadtbl and enemies then
		for k, v in pairs( self.squadtbl ) do
			local squad_member = v
			for k, v in pairs( enemies ) do
				if squad_member.enemy_memory and !table.HasValue( squad_member.enemy_memory, v ) then
					table.insert( squad_member.enemy_memory, v )
				end
			end
		end
	end
	return enemies
end

function ENT:GetPositionAnomaly(class)
	if class == "monster_bullchicken" or class == "monster_houndeye" or class == "monster_panthereye" or class == "npc_antlion" or class == "npc_antlion_worker" then return Vector(0,0,-12) end
	if class == "monster_headcrab" or class == "monster_babycrab" or class == "monster_snark" or class == "monster_penguin" or class == "npc_stukabat" or class == "npc_headcrab" or class == "npc_headcrab_fast" or class == "npc_headcrab_black" or class == "npc_headcrab_poison" or class == "npc_fastzombie_torso" or class == "npc_zombie_torso" or class == "npc_cscanner" or class == "npc_manhack" or class == "npc_mortarsynth" or class == "monster_alien_babyvoltigore" then return Vector(0,0,-40) end
	return Vector(0,0,0)
end

function ENT:AttackMelee(schd, dist, dmg, killicon, viewpunch_a, delay_a, delay_end, hitsound_a, tbl_ct, dontcheckang ) //tbl_ct = {delay_b(float), hitsound_b(string), viewpunch_b, delay_c(float), hitsound_c(string), viewpunch_c}
	self.attacking = true
	self.idle = false
	self:StartSchedule( schd )

	local attack_count = 0
	local function Attack()
		attack_count = attack_count +1
		if !IsValid(self) then return end
		local pos = self:GetPos()
		local hit
		for k, v in pairs(ents.FindInSphere(pos, dist)) do
			if IsValid(v) and ((v:IsPlayer() and v:Alive()) or !v:IsPlayer()) and v != self and (v:GetClass() == "prop_*" or self:Disposition( v ) == 1 or self:Disposition( v ) == 2) then
				local ang = self:GetAngles().y -(v:GetPos() -self:GetPos()):Angle().y
				if ang < 0 then ang = ang +360 end
				if dontcheckang or ((ang <= 90 and ang >= 0) or (ang <= 360 and ang >= 270)) then
					hit = true
					local inflictor
					if v:IsNPC() and v:Health() -dmg <= 0 then
						local killicon_ent = ents.Create( "sent_killicon" )
						killicon_ent:SetKeyValue( "classname", "sent_killicon_" .. killicon )
						killicon_ent:Spawn()
						killicon_ent:Activate()
						killicon_ent:Fire( "kill", "", 0.1 )
						inflictor = self.killicon_ent
					else
						inflictor = self
					end
					v:TakeDamage( dmg, self, inflictor )  
					if v:IsPlayer() then
						if attack_count == 1 then
							v:ViewPunch( viewpunch_a )
						elseif attack_count == 2 then
							v:ViewPunch( tbl_ct[3] )
						else
							v:ViewPunch( tbl_ct[6] )
						end
					end
					
					if( v:GetClass() == "npc_turret_floor" and !table.HasValue( turret_index_table, v:EntIndex() ) ) then
						table.insert( turret_index_table, v:EntIndex() )
						v:Fire( "selfdestruct", "", 0 )
						v:GetPhysicsObject():ApplyForceCenter( Vector( 6000, 0, 9000 ) ) 
						local function entity_index_remove()
							table.remove( turret_index_table )
						end
						timer.Create( "entity_index_remove_timer" .. self.Entity:EntIndex( ), 4.4, 1, entity_index_remove )
					end
				end
			end
		end
		if hit then
			if attack_count == 1 then
				if hitsound_a != "" then self:EmitSound( hitsound_a, 100, 100) end
			elseif attack_count == 2 then
				if hitsound_b != "" then self:EmitSound( tbl_ct[2], 100, 100) end
			else
				if hitsound_c != "" then self:EmitSound( tbl_ct[5], 100, 100) end
			end
		else
			self:EmitSound( "npc/zombie/claw_miss" ..math.random(1,2).. ".wav", 80, 100)
		end
		if !tbl_ct or (#tbl_ct /3 +1 == attack_count) then
			local function AttackEnd()
				if !IsValid(self) then return end
				self.attacking = false
				self.idle = false
			end
			if delay_end != 0 then timer.Simple(delay_end, AttackEnd) else AttackEnd() end
		end
	end
	timer.Simple(delay_a, Attack)
	if !tbl_ct then return end
	if tbl_ct[1] then
		timer.Simple(tbl_ct[1], Attack)
	end
	if tbl_ct[4] then
		timer.Simple(tbl_ct[4], Attack)
	end
end

function ENT:StopSounds()
	for k, v in pairs(self.Sounds) do
		if k != "Death" then
			for l, w in pairs(v) do
				w:Stop()
			end
		end
	end
end

function ENT:SoundsChangePitch(pitch)
	for k, v in pairs(self.Sounds) do
		for l, w in pairs(v) do
			w:ChangePitch(pitch)
		end
	end
end

function ENT:PlayRandomSound(sound)
	local rand = math.random(1,#self.Sounds[sound])
	self.Sounds[sound][rand]:Stop()
	if !self.sounds_pitch then
		self.Sounds[sound][rand]:Play()
	else
		self.Sounds[sound][rand]:PlayEx( 1, self.sounds_pitch )
	end
end

function ENT:GetSpawnflag( value )
	local spawnflags = { 131072, 65536, 32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1 }
	if !table.HasValue( spawnflags, value ) then return false end
	if value == 16 then
		self.efficient = true
	end
	
	if value == 64 then
		self.ignoreplys = true
	end
	return true
end

/*function ENT:ResetScheduleState()
	//Msg( "Changing state... \n" )
	//self:StartSchedule( schdResetSchedule )
	self:SetSchedule( 6 )//SCHED_AISCRIPT )
	self:SelectSchedule()
	self.res_time = CurTime() +1
end*/

function ENT:DropHealthkit()
	local healthkit = ents.Create( "item_healthvial" )
	healthkit:SetPos( self:GetPos() )
	healthkit:Spawn()
	healthkit:Activate()
end

function ENT:SetUpEnemies( tbl_exceptions )
	local cst_hate = {}
	local cst_like = {}
	local cst_fear = {}
	for k, v in pairs(HLR_NPC_RELATIONSHIPS) do
		if k == self:GetClass() then
			for k, v in pairs(v) do
				if v[1] == "Like" or v[1] == "Neutral" then
					table.insert(cst_like,v[2])
				elseif v[1] == "Hate" then
					table.insert(cst_hate,v[2])
				else table.insert(cst_fear,v[2]) end
			end
		end
	end
	
	local tbl_combine = { "npc_combine_s", "npc_hunter", "npc_rollermine", "npc_turret_floor", "npc_metropolice", "npc_clawscanner", "npc_cscanner", "npc_manhack", "npc_mortarsynth" }
	local tbl_headcrabs = { "npc_headcrab", "npc_headcrab_black", "npc_headcrab_poison", "npc_headcrab_fast", "monster_babycrab", "monster_headcrab", "monster_bigmomma" }
	local tbl_zombies = { "npc_fastzombie_torso", "npc_fastzombie",  "npc_poisonzombie", "npc_zombie", "npc_zombie_torso", "npc_zombine", "monster_zombie", "monster_gonome", "monster_zombie_soldier", "monster_zombie_barney" }
	local tbl_racex = { "monster_pitdrone", "monster_alien_voltigore", "monster_shocktrooper", "monster_shockroach", "monster_geneworm", "monster_alien_babyvoltigore", "monster_pitworm" }
	local tbl_allies = { "monster_barney", "npc_gman", "monster_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_breen", "npc_dog", "npc_eli", "npc_fisherman", "monster_scientist", "monster_sitting_scientist", "npc_kleiner", "npc_magnusson", "npc_mossman" }
	local tbl_other = { "npc_bullseye", "npc_antlion", "npc_antlion_worker", "npc_antlionguard", "npc_stalker", "monster_alien_controller", "monster_alien_grunt", "monster_alien_slave", "monster_human_grunt", "monster_human_assassin", "monster_sentry", "monster_hwgrunt", "monster_bullchicken", "monster_gargantua", "monster_houndeye", "monster_ichthyosaur", "monster_archer", "monster_panthereye", "monster_snark", "monster_parasite", "monster_nihilanth", "npc_stukabat", "monster_penguin", "npc_dobermann"	}
	local player = "player"
	local npcs = {}
	table.Add(npcs,tbl_combine)
	table.Add(npcs,tbl_headcrabs)
	table.Add(npcs,tbl_zombies)
	table.Add(npcs,tbl_racex)
	table.Add(npcs,tbl_allies)
	table.Add(npcs,tbl_other)
	table.insert(npcs,player)
	
	table.Add(npcs,cst_hate)
	
	self.enemyTable = {}
	for k, v in pairs(npcs) do
		if (!tbl_exceptions or !table.HasValue(tbl_exceptions,v) or table.HasValue(cst_hate,v)) and !table.HasValue(cst_like,v) then
			table.insert( self.enemyTable, v )
		end
	end
end

function ENT:ValidateRelationships()
	if self.enemyTable then
		for k, v in pairs( self.enemyTable ) do
			local enemyTable_enemies = ents.FindByClass( v )
			for k, v in pairs( enemyTable_enemies ) do
				if( !table.HasValue( self.enemyTable_enemies_e, v ) and !v.controlled ) then
					table.insert( self.enemyTable_enemies_e, v )
					if( !v:IsPlayer() ) then
						v:AddEntityRelationship( self, 1, 10 )
					end
					self:AddEntityRelationship( v, 1, 10 )
				end
			end
		end
	end
	if self.enemyTable_fear then
		for k, v in pairs( self.enemyTable_fear ) do
			local enemyTable_enemies_fr = ents.FindByClass( v )
			for k, v in pairs( enemyTable_enemies_fr ) do
				if( !table.HasValue( self.enemyTable_enemies_e, v ) and !v.controlled ) then
					table.insert( self.enemyTable_enemies_e, v )
					v:AddEntityRelationship( self, 1, 10 )
					self:AddEntityRelationship( v, 2, 10 )
				end
			end
		end
	end
	if !self.enemyTable_LI then return end
	for k, v in pairs( self.enemyTable_LI ) do
		local enemyTable_enemies_li = ents.FindByClass( v )
		for k, v in pairs( enemyTable_enemies_li ) do
			if( !table.HasValue( self.enemyTable_enemies_e, v ) ) then
				table.insert( self.enemyTable_enemies_e, v )
				v:AddEntityRelationship( self, 3, 10 )
				self:AddEntityRelationship( v, 3, 10 )
			end
		end
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

function ENT:GetKeyValue( target, key )
	for k, v in pairs( target:GetKeyValues() ) do
		if k == key then
			self.keyvalue = v
		end
	end

	return self.keyvalue
end

function ENT:KeyValue( key, value )
	if( key == "wander" and value == "1" ) then
		self.wander = 1
	elseif( key == "wander" ) then
		self.wander = 0
	end
	
	if( key == "health" ) then
		self.health = value
	end
	
	if( key == "squadname" or key == "netname" ) then
		self.squad = value
		self:SetupSquad()
	end
	
	if( key == "spawnflags" ) then
		self.spawnflags = tonumber(value)
		self:CheckSpawnflags()
	end
	
	if key == "TriggerTarget" then
		self.triggertarget = value
	end
	
	if key == "TriggerCondition" then
		self.triggercondition = value
	end
end

function ENT:GotTriggerCondition()
	if self.conditionacquired then return false end
	self.conditionacquired = true

	local targets = ents.FindByName( self.triggertarget )
	for k, v in pairs( targets ) do
		if IsValid( v ) then
			local target_class = v:GetClass()
			if target_class == "func_platrot" or target_class == "func_train" or target_class == "ambient_generic" or target_class == "func_door" then
				v:Fire( "Toggle", "", 0 )
			elseif target_class == "func_breakable" then
				v:Fire( "break", "", 0 )
			else
				v:Fire( "Trigger", "", 0 )
			end
		end
	end
	return true
end

function ENT:Fade()
	self.alpha = 255
	local function change_alpha()
		if !IsValid( self ) then timer.Destroy( "alpha_timer" .. self:EntIndex() ); return end
		if self.alpha > 0 then
			self:SetColor(Color( 255, 255, 255, self.alpha ))
			self.alpha = self.alpha -3
		else
			timer.Destroy( "alpha_timer" .. self:EntIndex() )
			self:Remove()
		end
	end
	timer.Create( "alpha_timer" .. self:EntIndex(), 0.05, 0, change_alpha )
end

function ENT:SpawnBloodDecal( decal, filter_tbl )
	local tracedata = {}
	tracedata.start = self:GetPos()
	tracedata.endpos = self:GetPos() -Vector( 0, 0, 8 )
	tracedata.filter = filter_tbl
	local trace = util.TraceLine(tracedata)
	if trace.HitWorld then
		util.Decal(decal,trace.HitPos +trace.HitNormal,trace.HitPos -trace.HitNormal)  
	end 
end

function ENT:SpawnBloodEffect( bloodtype, dmgPos )
	if dmgPos == Vector( 0, 0, 0 ) then return false end
	local bloodeffect = ents.Create( "info_particle_system" )
	if bloodtype == "red" then self.bloodeffecttype = "blood_impact_red_01" elseif bloodtype == "yellow" then self.bloodeffecttype = "blood_impact_yellow_01" else self.bloodeffecttype = "blood_impact_green_01" end
	
	bloodeffect:SetKeyValue( "effect_name", self.bloodeffecttype )
	bloodeffect:SetPos( dmgPos ) 
	bloodeffect:Spawn()
	bloodeffect:Activate() 
	bloodeffect:Fire( "Start", "", 0 )
	bloodeffect:Fire( "Kill", "", 0.1 )
	self.bloodeffecttype = nil
	return true
end

function ENT:SpawnRagdoll( damage_force, body )
	local forcepos = self:LocalToWorld( self:OBBCenter() )

	if not util.IsValidRagdoll( self.Model ) then return nil end

	local ragdoll = ents.Create( "prop_ragdoll" )

	ragdoll:SetModel( self:GetModel() )
	ragdoll:SetPos( self:GetPos() )
	ragdoll:SetAngles( self:GetAngles() )
	if body then
		ragdoll:SetKeyValue( "body", body )
	end
	ragdoll:Spawn()

			
	if not ragdoll:IsValid() then return nil end

	local entvel
	local entphys = self:GetPhysicsObject()
	if entphys:IsValid() then
		entvel = entphys:GetVelocity()
	else
		entvel = self:GetVelocity()
	end


	for i=1,128 do
		local bone = ragdoll:GetPhysicsObjectNum( i )
		if IsValid( bone ) then
			local bonepos, boneang = self:GetBonePosition( ragdoll:TranslatePhysBoneToBone( i ) )

			bone:SetPos( bonepos )
			bone:SetAngles( boneang )

			bone:ApplyForceOffset( damage_force /3, forcepos )
			bone:AddVelocity( entvel )
		end
	end
	ragdoll:SetSkin( self:GetSkin() )
	ragdoll:SetColor( self:GetColor() )
	ragdoll:SetMaterial( self:GetMaterial() )
	if self:IsOnFire() then ragdoll:Ignite( math.Rand( 8, 10 ), 0 ) end
	local cvar_keepragdolls = GetConVarNumber("ai_keepragdolls")
	if( cvar_keepragdolls == 0 ) then
		ragdoll:SetCollisionGroup( 1 )//COLLISION_GROUP_DEBRIS )
		ragdoll:Fire( "FadeAndRemove", "", 0.2 )
	else
		ragdoll:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE_DEBRIS )
	end
	undo.ReplaceEntity( self, ragdoll )
	cleanup.ReplaceEntity( self, ragdoll )
	
	gamemode.Call( "CreateEntityRagdoll", self, ragdoll )
end

function ENT:DmgAdd(dmg)
end

/*---------------------------------------------------------
   Name: OnTakeDamage
   Desc: Entity takes damage
---------------------------------------------------------*/
function ENT:OnTakeDamage(dmg)
	self:SpawnBloodEffect( self.BloodType, dmg:GetDamagePosition() )
	if self.IgnoreRagdollDamage and dmg:GetAttacker():GetClass() == "prop_ragdoll" then dmg:SetDamage(0) end
	if self.dead then return end
	if self.ScaleDmg then dmg:ScaleDamage(self.ScaleDmg); gamemode.Call( "ScaleNPCDamage", self, 1, dmg ) end
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self.triggertarget and self.triggercondition == "2" then
		self:GotTriggerCondition()
	elseif self.starthealth and self:Health() <= (self.starthealth /2) then
		self:GotTriggerCondition()
	end

	local damage = dmg:GetDamage()
	if !self.inflictor then
		self.inflictor = dmg:GetInflictor()
	end
	if !self.attacker then
		self.attacker = dmg:GetAttacker()
	end
	
	self:DmgAdd(dmg)
	//if self.RunMeleeDistance and self:CheckEnemy( 1 ) and self.enemy:GetPos():Distance( self:GetPos() ) < self.RunMeleeDistance and self.enemy:GetPos():Distance( self:GetPos() ) > self.MeleeDistance then
	//	self.hidecur = CurTime() +4
	//	self.hiding = true
	//end
	
	if( self:Health() > 0 ) then
		if( damage <= 25 ) then
			self:SetCondition( 17 )
		else
			self:SetCondition( 18 )
		end
		
		if( IsValid( self.inflictor ) and self.inflictor:GetClass() == "prop_physics" ) then
			self:SetCondition( 19 )
		end
	
		self.damage_count = self.damage_count +1
		if( self.damage_count == 6 ) then
			self:SetCondition( 20 )
		end
		timer.Create( "damage_count_reset_timer" .. self.Entity:EntIndex( ), 1.5, 1, function() self.damage_count = 0 end )
	end
	
	if( ( self.damage_count == 6 or self:HasCondition( 18 ) ) and !self.attacking and self.pain and self.Sounds["Pain"] and #self.Sounds["Pain"] > 0 ) then
		self:StartSchedule( schdHurt )
		//self:EmitSound( self.PainSound ..math.random(1,self.PainSoundCount) .. ".wav", 500, 100)
		
		self:PlayRandomSound("Pain")
	end
	
	if !self.enemy and self.enemy_memory and ( !self.WaterMonster or ( self.WaterMonster and self.attacker:WaterLevel() > 0 ) ) then
		local convar_ignoreply = GetConVarNumber("ai_ignoreplayers")
		if !table.HasValue( self.enemy_memory, self.attacker ) and IsValid( self.attacker ) and ( !self.attacker:IsPlayer() or ( self.attacker:IsPlayer() and convar_ignoreply != 1 and !self.ignoreplys ) ) and self:Disposition( self.attacker ) == 1 then table.insert( self.enemy_memory, self.attacker ) end
	end
	
	if IsValid(self.attacker) then
		self:UpdateEnemyMemory( self.attacker, self.attacker:GetPos() )
	end
	self.idle = 0

	if ( self:Health() <= 0 and !self.dead ) then //run on death
		self.dead = true
		self:EndPossession()
		if self.triggertarget and self.triggercondition == "4" then self:GotTriggerCondition() end
		if self.DeathSkin then self:SetSkin( self.DeathSkin ) end
		gamemode.Call( "OnNPCKilled", self, self.attacker, self.inflictor )
		if self.Sounds["Death"] and #self.Sounds["Death"] > 0 then
			self:PlayRandomSound("Death")
		end

		if self.attacker:IsPlayer() then
			self.attacker:AddFrags( 1 )
		end
		
		if( self.attacker:GetClass() != "npc_barnacle" and !dmg:IsDamageType( DMG_DISSOLVE ) ) then
			if self.SpawnRagdollOnDeath then self:SpawnRagdoll( dmg:GetDamageForce() ) end
			if self.WaterMonster and !self.SpawnRagdollOnDeath then self:DeathFloat() end
			if self.drophealthkit then self:DropHealthkit() end
			if self.PrintDeathDecal then self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self:GetPos().z +4 ) ); self:SpawnBloodDecal( "YellowBlood", self ) end
			self:SetNPCState( NPC_STATE_DEAD )
			if self.DeathSequence then self:SetSchedule( SCHED_DIE_RAGDOLL ) end
			if !self.FadeOnDeath and !self.SpawnRagdollOnDeath and GetConVarNumber("ai_keepragdolls") == 0 then self:Fade() end
			if self.SpawnRagdollOnDeath or self.RemoveOnDeath then self:Remove() end
		elseif( dmg:IsDamageType( DMG_DISSOLVE ) ) then
			self:SetNPCState( NPC_STATE_DEAD )
			self:SetSchedule( SCHED_DIE_RAGDOLL )
		end
	elseif( self:Health() > 0 ) then
		self.inflictor = nil
		self.attacker = nil
	end
end

function ENT:DeathFloat()
end

function ENT:SetupSquad()
	self.squadtbl = {}
	local npcs = ents.FindByClass( "monster_*" )
	for k, v in pairs( npcs ) do
		if v != self and v.squad and v.squad == self.squad then
			table.insert( self.squadtbl, v )
			if v.squadtbl then table.insert( v.squadtbl, self ) end
		end
	end
end

/*function ENT:CheckSquad()
	local class_members = ents.FindByClass( self:GetClass() )
	for k, v in pairs( class_members ) do
		if v.squad and v.squad == self.squad then
			if v.enemy_memory then
				for k, v in pairs( v.enemy_memory ) do
					if IsValid( v ) and !table.HasValue( self.enemy_memory, v ) then
						table.insert( self.enemy_memory, v )
					end
				end
			end
		end
	end
	if self.squad then
		if self.enemy_memory then
			
		end
	end
end*/

function ENT:AcceptInput( cvar_name, activator, caller )
	//Msg( "cvar_name == " .. cvar_name .. "\n" )
	if cvar_name == "setsquad" then
		timer.Simple( 0.01, function() self.squad = self:GetKeyValue( self, "squadname" ); self:SetupSquad(); end )
		self.squadtable = {}
	end
	if( string.find( cvar_name,"followtarget_" ) and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) and !self.following ) then
		self.follow_target_string = string.Replace(cvar_name,"followtarget_","") 
		if( self.follow_target_string != "!self" and !string.find( cvar_name,"followtarget_!player" ) ) then
			self.follow_target_t = ents.FindByName( self.follow_target_string )
		elseif( self.follow_target_string == "!self" ) then
			if IsValid( caller ) then
				self.follow_target = caller
			end
		elseif( string.find( cvar_name,"followtarget_!player" ) ) then
			if( self.follow_target_string == "!player" ) then
				self.follow_closest_range = 9999
				for k, v in pairs( player:GetAll() ) do
					self.follow_closest = v:GetPos():Distance( self:GetPos() )
					if( self.follow_closest < self.follow_closest_range ) then
						self.follow_closest_range = v:GetPos():Distance( self:GetPos() )
						self.follow_target = v
					end
				end
			else
				self.follow_target_userid = string.Replace(cvar_name,"followtarget_!player","") 
				for k, v in pairs( player:GetAll() ) do
					if( tostring(v:UserID( )) == self.follow_target_userid ) then
						self.follow_target = v
					end
				end
			end
		end
		
		if( self.follow_target or ( self.follow_target_t and table.Count( self.follow_target_t ) == 1 ) ) then
			self.following = true
			if !IsValid( self.follow_target ) and self.follow_target_t then
				for k, v in pairs( self.follow_target_t ) do
					if( v != self ) then
						self.follow_target = v
					else
						self.following = false
						caller:PrintMessage( HUD_PRINTCONSOLE, "Can't follow itself! \n" )
					end
				end
			end
			
			if( self.follow_target:IsPlayer() or self.follow_target:IsNPC() ) then
				self.following_disp = self:Disposition( self.follow_target )
				self:AddEntityRelationship( self.follow_target, 3, 10 )
			end
		elseif( self.follow_target_t and table.Count( self.follow_target_t ) > 1 ) then
			self.following = true
			self.follow_closest_range = 9999
			for k, v in pairs( self.follow_target_t ) do
				self.follow_closest = v:GetPos():Distance( self:GetPos() )
				if( self.follow_closest < self.follow_closest_range ) then
					if( v != self ) then
						self.follow_closest_range = v:GetPos():Distance( self:GetPos() )
						self.follow_target = v
					end
				end
			end
				
			if( self.follow_target:IsPlayer() or self.follow_target:IsNPC() ) then
				self.following_disp = self:Disposition( self.follow_target )
				self:AddEntityRelationship( self.follow_target, 3, 10 )
			end
		elseif caller:IsPlayer() then
			caller:PrintMessage( HUD_PRINTCONSOLE, "No entity called '" .. self.follow_target_string .. "' found! \n" )
		end
	end
	
	if( cvar_name == "stopfollowtarget" and self.following and ( ( caller:IsPlayer() and caller:IsAdmin() ) or !caller:IsPlayer() ) ) then
		self.following = false
		if self.following_disp then
			self:AddEntityRelationship( self.follow_target, self.following_disp, 10 )
		end
		timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
		self:StartSchedule( schdReset )
		self.follow_target = NULL
	end
end

function ENT:TaskStart_ScriptedReachedTarget()
	self:TaskComplete()
	
	/*if !self.playingpreanim then
		local function CheckMovementActivity()
			if !self then timer.Destroy( "CheckMovementActivityTimer" .. self:EntIndex() ) return end
			if self:GetActivity() == 1 then
				timer.Destroy( "CheckMovementActivityTimer" .. self:EntIndex() )
				if self.sequence and IsValid( self.sequence ) then self.sequence:TaskDone( "MoveToPosition" ) end
			end
		end
		timer.Create( "CheckMovementActivityTimer" .. self:EntIndex(), 0.1, 0, CheckMovementActivity )
	else*/
		//self.playingpreanim = false
		//if self.sequence and IsValid( self.sequence ) then self.sequence:TaskDone( "MoveToPosition" ) end
	//end
end

function ENT:Task_ScriptedReachedTarget()
	self:TaskComplete()
end

function ENT:TaskStart_ScriptedFacedTarget()
	self:TaskComplete()
	if self.sequence and IsValid( self.sequence ) then self.sequence:TaskDone( "MoveToPosition" ) end
end

function ENT:Task_ScriptedFacedTarget()
	self:TaskComplete()
end

function ENT:TaskStart_ScriptedPlayedPost()
	self:TaskComplete()
	if self.sequence and IsValid( self.sequence ) and !self.sequence.InPostAnimation then self.sequence:TaskDone( "PlayPostAnimation" ) end
end

function ENT:Task_ScriptedPlayedPost()
	self:TaskComplete()
end

function ENT:TaskStart_ScriptedPlayedSequence()
	self:TaskComplete()
	if self.sequence and IsValid( self.sequence ) and !self.sequence.InMainAnimation then self.sequence:TaskDone( "PlayMainAnimation" ) end
end

function ENT:Task_ScriptedPlayedSequence()
	self:TaskComplete()
end

function ENT:TaskStart_ScriptedPlayedPre()
	self:TaskComplete()

	if self.sequence and IsValid( self.sequence ) and !self.sequence.InPreAnimation then self.sequence:TaskDone( "PlayPreAnimation" ) end
end

function ENT:Task_ScriptedPlayedPre()
	self:TaskComplete()
end


function ENT:SpeakSentence( spksentence, speaker, listener, sradius, volume, attenuation, once, interrupt, concurrent, toactivator )
	local sentence = ents.Create( "scripted_sentence" )
	sentence:SetPos( self:GetPos() )
	sentence:SetKeyValue( "sentence", spksentence )
	if speaker:GetName() == "" then
		self.sentence_ent = speaker:GetClass()
	else
		self.sentence_ent = speaker:GetName()
	end
	sentence:SetKeyValue( "entity", self.sentence_ent )

	if listener:GetName() != "" and !listener:IsPlayer() then
		self.sentence_listener = listener:GetName()
	elseif listener:IsPlayer() then
		self.sentence_listener = "player"
	else
		self.sentence_listener = listener:GetClass()
	end
	sentence:SetKeyValue( "listener", self.sentence_listener )
	sentence:SetKeyValue( "radius", sradius )
	sentence:SetKeyValue( "volume", volume )
	sentence:SetKeyValue( "attenuation", attenuation )
	self.sentence_spawnflags = 0
	if once then
		self.sentence_spawnflags = self.sentence_spawnflags +1
	end
	if interrupt then
		self.sentence_spawnflags = self.sentence_spawnflags +4
	end
	if concurrent then
		self.sentence_spawnflags = self.sentence_spawnflags +8
	end
	if toactivator then
		self.sentence_spawnflags = self.sentence_spawnflags +16
	end
	sentence:SetKeyValue( "spawnflags", self.sentence_spawnflags )
	
	sentence:Spawn()
	sentence:Activate()
	sentence:Fire( "BeginSentence", "", 0.1 )
	self.sentence_spawnflags = nil
end

/*---------------------------------------------------------
   Name: Use
---------------------------------------------------------*/
function ENT:Use( activator, caller, type, value )
end


/*---------------------------------------------------------
   Name: StartTouch
---------------------------------------------------------*/
function ENT:StartTouch( entity )
end


/*---------------------------------------------------------
   Name: EndTouch
---------------------------------------------------------*/
function ENT:EndTouch( entity )
end


/*---------------------------------------------------------
   Name: Touch
---------------------------------------------------------*/
function ENT:Touch( entity )
end

/*---------------------------------------------------------
   Name: GetRelationship
		Return the relationship between this NPC and the 
		passed entity. If you don't return anything then
		the default disposition will be used.
---------------------------------------------------------*/
function ENT:GetRelationship( entity )
	
	//return D_NU;

end

/*---------------------------------------------------------
   Name: ExpressionFinished
		Called when an expression has finished. Duh.
---------------------------------------------------------*/
function ENT:ExpressionFinished( strExp )

end


/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:Think()

end




/*---------------------------------------------------------
   Name: GetAttackSpread
		How good is the NPC with this weapon? Return the number
		of degrees of inaccuracy for the NPC to use.
---------------------------------------------------------*/
function ENT:GetAttackSpread( Weapon, Target )
	return 0.1
end





