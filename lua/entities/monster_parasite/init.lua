AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')

////// DONT CHANGE ANYTHING BELOW THIS!!!
ENT.Model = "models/Zombie/para.mdl"
ENT.MeleeDistance		= 110

ENT.SpawnRagdollOnDeath = true
ENT.FadeOnDeath = false
ENT.BloodType = "green"
ENT.Pain = false

ENT.DSounds = {}
ENT.DSounds["Attack"] = {"npc/parasite/claw_strike1.wav", "npc/parasite/claw_strike2.wav", "npc/parasite/claw_strike3.wav"}
ENT.DSounds["ClawMiss"] = {"npc/parasite/claw_miss1.wav", "npc/parasite/claw_miss2.wav"}
ENT.DSounds["Alert"] = {"npc/parasite/pa_alert1.wav", "npc/parasite/pa_alert2.wav", "npc/parasite/leap1.wav", "npc/parasite/wake1.wav", "npc/parasite/fz_frenzy1.wav"}
ENT.DSounds["Death"] = {"npc/parasite/fz_scream1.wav"}
ENT.DSounds["Idle"] = {"npc/parasite/idle1.wav", "npc/parasite/idle2.wav", "npc/parasite/idle3.wav"}

local schdChase = ai_schedule.New( "Chase Enemy" ) //creates the schedule used on this npc
schdChase:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdChase:EngTask( "TASK_RUN_PATH_TIMED", 0.2 )
schdChase:EngTask( "TASK_WAIT", 0.2 ) 

local schdFollow = ai_schedule.New( "Follow friend" )
schdFollow:EngTask( "TASK_GET_PATH_TO_ENEMY", 0 )
schdFollow:EngTask( "TASK_RUN_PATH_WITHIN_DIST", 125 ) 

local schdWait = ai_schedule.New( "Wait" )
schdWait:EngTask( "TASK_WAIT_FOR_MOVEMENT", 0 )

local schdMeleeAttack = ai_schedule.New( "Melee Attack Enemy" ) 
schdMeleeAttack:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack:AddTask( "PlaySequence", { Name = "BR2_Attack", Speed = 1 } )

local schdMeleeAttack_Poison = ai_schedule.New( "Poison Melee Attack Enemy" ) 
schdMeleeAttack_Poison:EngTask( "TASK_STOP_MOVING", 0 )
schdMeleeAttack_Poison:AddTask( "PlaySequence", { Name = "BR2_Attack", Speed = 0.3 } )
//schdMeleeAttack:EngTask( "TASK_PLAY_SEQUENCE_FACE_ENEMY", ACT_MELEE_ATTACK1 )

local schdWandering = ai_schedule.New( "Wander" ) 
schdWandering:AddTask( "wandering" )
schdWandering:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 384 )
schdWandering:EngTask( "TASK_WALK_PATH", 0 ) 

local schdHide = ai_schedule.New( "Hide" ) 
schdHide:EngTask( "TASK_FIND_COVER_FROM_ENEMY", 0 ) 

local schdReset = ai_schedule.New( "Reset" ) 
schdReset:EngTask( "TASK_RESET_ACTIVITY", 0 ) 

local schdAlert = ai_schedule.New( "Alert1" ) 
schdAlert:EngTask( "TASK_STOP_MOVING", 0 )
schdAlert:EngTask( "TASK_STOP_MOVING", 0 )
schdAlert:AddTask( "PlaySequence", { Name = "BR2_Roar", Speed = 1 } )

local schdMoveToWall = ai_schedule_slv.New( "Move to wall" )
schdMoveToWall:EngTask( "TASK_GET_PATH_TO_TARGET", 0 )
schdMoveToWall:EngTask( "TASK_RUN_PATH_TIMED", 0.2 )
schdMoveToWall:EngTask( "TASK_WAIT_FOR_MOVEMENT" ) 
schdMoveToWall:AddTask( "ReachedWall" ) 

local schdClimbMount = ai_schedule_slv.New( "Climb mount" ) 
schdClimbMount:EngTask( "TASK_STOP_MOVING", 0 )
schdClimbMount:AddTask( "PlaySequence", { Name = "climbmount", Speed = 1 } )
//schdClimbMount:AddTask( "PlaySequence", { Name = "climbloop", Speed = 1 } )
schdClimbMount:AddTask( "Climbing" )

local schdClimbDismount = ai_schedule_slv.New( "Climb Dismount" ) 
schdClimbDismount:EngTask( "TASK_PLAY_SEQUENCE", ACT_CLIMB_DISMOUNT )
//schdClimbDismount:AddTask( "PlaySequence", { Name = "climbdismount", Speed = 1 } )
schdClimbDismount:EngTask( "TASK_WAIT_FOR_MOVEMENT" ) 
schdClimbDismount:AddTask( "Climbing_dismounted" )

local schdFaceTarget = ai_schedule_slv.New( "Face target" ) 
schdFaceTarget:EngTask( "TASK_FACE_TARGET", 0 )
schdFaceTarget:EngTask( "TASK_WAIT_FOR_MOVEMENT" ) 
schdFaceTarget:AddTask( "FacedTarget" )

local schdClimb = ai_schedule_slv.New( "Climb" ) 
schdClimb:EngTask( "TASK_PLAY_SEQUENCE", ACT_CLIMB_UP )

local schdIdle = ai_schedule.New( "Idle" ) 
schdIdle:EngTask( "TASK_PLAY_SEQUENCE", ACT_IDLE )


function ENT:TaskStart_Climbing_dismounted()
	self:TaskComplete()
	self.moving = false
	self:SetPos( self:LocalToWorld( Vector( 80, 0, 18 ) ) )
	self:StartSchedule( schdIdle )
	self:SetMoveType( MOVETYPE_STEP )
end 

function ENT:Task_Climbing_dismounted()
	self:TaskComplete()
end

function ENT:TaskStart_Climbing()
	self:TaskComplete()
	self:SetMoveType( MOVETYPE_FLY )
	self:SetLocalVelocity( self:GetUp() *100 )
	self:StartSchedule( schdClimb )
	self.climbing = true
end 

function ENT:Task_Climbing()
	self:TaskComplete()
end

function ENT:TaskStart_ReachedWall()
	self:TaskComplete()
	self.movetarget.oldpos = self.movetarget:GetPos()
	self.movetarget:SetPos( self.movetarget.newpos )
	self.movetarget.newpos = nil
	self:StartSchedule( schdFaceTarget )
end 

function ENT:Task_ReachedWall()
	self:TaskComplete()
end

function ENT:TaskStart_FacedTarget()
	self:TaskComplete()
	self:StartSchedule( schdClimbMount )
	self.movetarget:Remove()
end 

function ENT:Task_FacedTarget()
	self:TaskComplete()
end

function ENT:Initialize()
	if( turret_index_table == nil ) then
		turret_index_table = {}
	end
	self.table_fear = {}

	self:SetModel( self.Model )

	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();

	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )

	self:CapabilitiesAdd( CAP_MOVE_GROUND )
	self:CapabilitiesAdd( CAP_MOVE_JUMP )
	self:CapabilitiesAdd( CAP_OPEN_DOORS )
	self:CapabilitiesAdd( CAP_INNATE_RANGE_ATTACK1 )
	self:CapabilitiesAdd( CAP_FRIENDLY_DMG_IMMUNE )
	self:CapabilitiesAdd( CAP_SQUAD )
	//self.customcaps = { "CAP_HEAR" }
	self:SetMaxYawSpeed( 5000 )


	if !self.health then
		self:SetHealth(sk_parasite_health_value)
	end
	
	if self.triggertarget and self.triggercondition == "3" then self.starthealth = self:Health() end
	
	self.alertanim = true
	
	self:SetUpEnemies()
	self.enemyTable_fear = { "npc_combinedropship", "npc_combinegunship", "npc_helicopter", "npc_strider", "npc_sniper" }
	
	self.enemyTable_enemies_e = {}
	
	self:InitSounds()
	
	self:SetSchedule( 1 )
	self.init = true
end

function ENT:PlayAlertAnim()
	self:StartSchedule( schdAlert )
	self.Attack_allow = false
	timer.Create( "alert_reset_timer" .. self:EntIndex(), 2, 1, function() self.Attack_allow = true end )
end

function ENT:Think()
	if self.climbing then
		local trace = {}
		trace.start = self:LocalToWorld( Vector( 0, 0, 55 ) )
		trace.endpos = self:LocalToWorld( Vector( 30, 0, 55 ) )
		trace.filter = self

		local tr = util.TraceLine( trace ) 
		if tr.HitWorld then
			self:StartSchedule( schdClimb )
		else
			self.climbing = false
			self:StartSchedule( schdClimbDismount )
		end
	end

	if GetConVarNumber("ai_disabled") == 1 or self.efficient then return end
	self:ValidateRelationships()
	
	if self.possessed then
		if !self:PossessView() then return end
		self:Possess_SetViewVector()
		if !self.melee_attacking and !self.moving and ( !self.possession_allowdelay or ( self.possession_allowdelay and CurTime() > self.possession_allowdelay ) ) then
			self.possession_allowdelay = nil
			self:PossessMovement( 230 )
			if !self.master then return end
			if self.master:KeyDown( 1 ) then
				if !self.master:KeyDown( 4 ) then
					self:Attack_Melee( true )
				else
					self:Attack_Melee( true, true )
				end
			elseif self.master:KeyDown( 2048 ) then
				local trace = {}
				trace.start = self:GetPos() +Vector( 0, 0, 20 )
				trace.endpos = self:LocalToWorld( Vector( 500, 0, 0 ) )
				trace.filter = self

				local tr = util.TraceLine( trace ) 
				if tr.HitWorld and (tr.HitNormal.x == 1 or tr.HitNormal.x == -1 or tr.HitNormal.y == 1 or tr.HitNormal.y == -1) then
					self.movetarget = ents.Create( "info_target" )
					self.movetarget:SetPos( self:LocalToWorld( Vector( self:GetPos():Distance( tr.HitPos ) -10, 0, 0 ) ) )
					self.movetarget:Spawn()
					self.movetarget:Activate()
					self.movetarget.newpos = self:LocalToWorld( Vector( self:GetPos():Distance( tr.HitPos ) +45, 0, 0 ) )
					self:SetTarget( self.movetarget )
					self:StartSchedule( schdMoveToWall )
					self.moving = true
				end
			end
		end
	end
	
	if self.possessed then return end
	local grenades = ents.FindByClass( "npc_grenade_frag" )
	for k,v in pairs(grenades) do
		local grenade_dist = v:GetPos():Distance( self:GetPos() )
		if( !self.ghide and grenade_dist < 256 and !self.FoundEnemy ) then
			self:SetEnemy( v, true )
			self:UpdateEnemyMemory( v, v:GetPos() )
			self:StartSchedule( schdHide )
			self.ghide = true
			self:SetEnemy( NULL )
			timer.Create( "self.ghide_reset_timer" .. self.Entity:EntIndex( ), 1, 1, function() self.ghide = false end )
		end
	end
end

function ENT:Poisoned( ent )
	ent:EmitSound( "npc/bullsquid/acid1.wav", 100, 100 )
	
	for i = 0, 6 do
		local acid = ents.Create( "info_particle_system" )
		acid:SetKeyValue( "effect_name", "antlion_spit" )
		acid:SetPos( self:LocalToWorld( Vector( 18, 0, self:OBBCenter().z ) )  )
		acid:Spawn()
		acid:Activate() 
		acid:Fire( "Start", "", 0 )
		acid:Fire( "Kill", "", 0.1 )
	end

	if ent.poisoned then return end
	ent.poisoned = true
	local poison = ents.Create( "parasite_poison" )
	poison.Owner = self
	poison.poisonent = ent
	poison:Spawn()
	poison:Activate()
end

function ENT:Attack_Melee( poss, poison )
	self.melee_attacking = true
	self.idle = 0
	if poison then
		self:StartSchedule( schdMeleeAttack_Poison )
		self.Sounds["Attack"][1]:ChangePitch( 50 )
		self.Sounds["Attack"][2]:ChangePitch( 50 )
		self.Sounds["Attack"][3]:ChangePitch( 50 )
	else
		self.Sounds["Attack"][1]:ChangePitch( 100 )
		self.Sounds["Attack"][2]:ChangePitch( 100 )
		self.Sounds["Attack"][3]:ChangePitch( 100 )
		self:StartSchedule( schdMeleeAttack )
	end

	local function attack_dmg()
		local self_pos = self:GetPos()
		local victim = ents.FindInSphere( self_pos, self.MeleeDistance )
		local hit
		for k, v in pairs(victim) do
			if( ( ( ( v:IsPlayer() and v:Alive() ) or v:IsNPC() ) and ( self:Disposition( v ) == 1 or self:Disposition( v ) == 2 ) ) or v:GetClass() == "prop_physics" ) then
				//if( v:GetClass() != "prop_physics" ) then
				//	v:EmitSound( "npc/zombie/claw_strike" ..math.random(1,3).. ".wav", 100, 100)
				//end
				if v:IsNPC() and v:Health() - sk_parasite_slash_value <= 0 then
					self.killicon_ent = ents.Create( "sent_killicon" )
					self.killicon_ent:SetKeyValue( "classname", "sent_killicon_parasite" )
					self.killicon_ent:Spawn()
					self.killicon_ent:Activate()
					self.killicon_ent:Fire( "kill", "", 0.1 )
					self.attack_inflictor = self.killicon_ent
				else
					self.attack_inflictor = self
				end
				local class_disallow = { "npc_turret_floor", "monster_sentry", "monster_cockroach", "npc_hunter", "npc_rollermine", "npc_clawscanner", "npc_cscanner", "npc_manhack", "npc_dog", "monster_gargantua", "monster_bigmomma", "npc_combinedropship", "npc_combinegunship", "npc_helicopter", "npc_strider" }
				v:TakeDamage( sk_parasite_slash_value, self, self.attack_inflictor )
				if poison and !table.HasValue( class_disallow, v:GetClass() ) then
					self:Poisoned( v )
				end
				
				self.attack_inflictor = nil
				if v:IsPlayer() then
					v:ViewPunch( Angle( 15, math.Rand(-5,5), 0 ) ) 
				end
				hit = true
				
				if( v:GetClass() == "npc_turret_floor" and !table.HasValue( turret_index_table, v:EntIndex() ) ) then
					table.insert( turret_index_table, v:EntIndex() )
					v:Fire( "selfdestruct", "", 0 )
					v:GetPhysicsObject():ApplyForceCenter( Vector( 6000, 0, 9000 ) ) 
					local function entity_index_remove()
						table.remove( turret_index_table )
					end
					timer.Create( "entity_index_remove_timer" .. self.Entity:EntIndex( ), 4, 1, entity_index_remove )
				end
			end
		end
		if hit then
			self:PlayRandomSound("Attack")
		else
			self:PlayRandomSound("ClawMiss")
		end
		if poss then if poison then self.possession_allowdelay = CurTime() +1 else self.possession_allowdelay = CurTime() +0.7 end end
		timer.Create( "atk_r_select_sched" .. self:EntIndex(), 0.3, 1, function() self.melee_attacking = false end )
	end
	local delay
	if !poison then
		delay = 0.3
	else
		delay = 0.8
	end
	timer.Create( "melee_attack_dmgdelay_timer" .. self.Entity:EntIndex( ), delay, 1, attack_dmg )
end


function ENT:TaskStart_wandering()
	self:PlayRandomSound("Idle")
	self:TaskComplete()
end 

function ENT:Task_wandering()
	if( self.FoundEnemy ) then
		self:TaskComplete()
	end
end

/*---------------------------------------------------------
 Name: SelectSchedule
//-------------------------------------------------------*/
function ENT:SelectSchedule()
	if self.efficient then return end
	local convar_ai = GetConVarNumber("ai_disabled")
	if( /*( self.FoundEnemy or self.FoundEnemy_fear ) and*/ !self.melee_attacking and !self.possessed and convar_ai == 0 and !self.moving ) then
		local Pos = self.Entity:GetPos()
		if !self.searchdelay then
			self.searchdelay = CurTime() +0.15
		end
		local enemy_tbl
		if self.searchdelay < CurTime() then
			enemy_tbl = self:FindInCone_V12( 9999 )
			self.searchdelay = nil
		end
		if enemy_tbl then self:UpdateMemory(enemy_tbl) end
		if self.enemy then self:CheckEnemy( 1 ) end
		if self.enemy_fear then self:CheckEnemy( 3 ) end
		if( self.enemy and IsValid( self.enemy ) and self.enemy:GetPos():Distance( self:GetPos() ) <= self.closest_range ) then
			if( self.enemy:GetPos():Distance( Pos ) < self.MeleeDistance and self:HasCondition( 10 ) and !self:HasCondition( 42 ) ) then
				if( self.enemy:IsNPC() ) then
					self.SetEnemy( self.enemy )
				end
				if self.schedule_runtarget_pos then
					self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
				end
				local rand = math.random(1,4)
				local poison
				if rand == 4 then
					poison = true
				else
					poison = false
				end
				self:Attack_Melee( false, poison )
			elseif( ( self.following and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) < 800 ) or !self.following ) then
				if !self.moving and (self.enemy:GetPos().z -self:GetPos().z) > 20 then
					local trace = {}
					trace.start = self:GetPos() +Vector( 0, 0, 20 )
					trace.endpos = self:LocalToWorld( Vector( 4000, 0, 0 ) )
					trace.filter = self
					local tr = util.TraceLine( trace ) 
					if tr.HitWorld and (tr.HitNormal.x == 1 or tr.HitNormal.x == -1 or tr.HitNormal.y == 1 or tr.HitNormal.y == -1) then
						local function CheckHeight( startpos, normal )
							self.addheight = 10
							for i = 0,100 do
								self.addheight = self.addheight +10
								local trace = {}
								trace.start = startpos +Vector(0,0,self.addheight)
								trace.endpos = startpos +Vector(0,0,self.addheight) +(normal *-1 *2)
								trace.filter = self
								local tr = util.TraceLine( trace ) 
								if !tr.HitWorld and self.addheight > 30 then
									local trace = {}
									trace.start = startpos +Vector(0,0,self.addheight) +(normal *-1 *2)
									trace.endpos = self.enemy:GetPos()
									local tr = util.TraceLine( trace ) 
									if tr.Entity == self.enemy then
										self.addheight = nil
										return true
									end
								elseif !tr.HitWorld and self.addheight <= 30 then self.addheight = nil; return false end
							end
							self.addheight = nil
							return false
						end
							if CheckHeight( tr.HitPos, tr.HitNormal ) then
								self.movetarget = ents.Create( "info_target" )
								self.movetarget:SetPos( self:LocalToWorld( Vector( self:GetPos():Distance( tr.HitPos ) -10, 0, 0 ) ) )
								self.movetarget:Spawn()
								self.movetarget:Activate()
								self.movetarget.newpos = self:LocalToWorld( Vector( self:GetPos():Distance( tr.HitPos ) +45, 0, 0 ) )
								self:SetTarget( self.movetarget )
								self:StartSchedule( schdMoveToWall )
								self.moving = true
							end
						//end
					end
				end
				if !self.moving then
					timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
					self:SetEnemy( self.enemy, true )
					if self.schedule_runtarget_pos then
						self:UpdateEnemyMemory( self.enemy, self.schedule_runtarget_pos )
					end
					self:StartSchedule( schdChase )
				end
			end
		elseif( ( !self.enemy or !IsValid(self.enemy) ) and self.enemy_fear and IsValid(self.enemy_fear) and self:HasCondition( 8 ) and !self:HasCondition( 7 ) ) then
			if( self.enemy_fear:IsNPC() ) then
				self:SetEnemy( self.enemy_fear )
			end
			self:UpdateEnemyMemory( self.enemy_fear, self.enemy_fear:GetPos() )
			self:StartSchedule( schdHide ) 
		else
			self.closest_range = 9999
		end
		
	self:SetEnemy( NULL )	
	elseif( self.idle == 0 and convar_ai == 0 ) then
		self.idle = 1
		self:SetSchedule( SCHED_IDLE_STAND )
		self:SelectSchedule()
	elseif( !self.FoundEnemy and !self.FoundEnemy_fear and table.Count( self.table_fear ) > 0 ) then
		local enemies = ents.FindByClass( "npc_*" ) 
		table.Add( enemies, ents.FindByClass( "monster_*" ) )
		table.Add( enemies, player.GetAll() )
		for i, v in ipairs(enemies) do
			if( v:Health() > 0 and self:Disposition( v ) == 3 and !self:HasCondition( 7 ) ) then
				if( table.HasValue( self.table_fear, v ) ) then
					self:AddEntityRelationship( v, 2, 10 )
					local table_en_li = {}
					local en_li = v
					for k, v in pairs( self.table_fear ) do
						if( v != en_li ) then
							table.insert( table_en_li, v )
						end
					end
					self.table_fear = table_en_li
				end
			end
		end
	end
	
	if( self.following and !self.possessed ) then
		if IsValid( self.follow_target ) then
			if( self:Disposition( self.follow_target ) != 3 ) then
				self:AddEntityRelationship( self.follow_target, 3, 10 )
			end
			
			if( self:GetPos():Distance( self.follow_target ) > 175 and ( ( IsValid( self.enemy ) and self.enemy != self.follow_target and self.enemy:GetPos():Distance( self.follow_target:GetPos() ) > 800 ) or !IsValid( self.enemy ) ) and !self.melee_attacking and convar_ai == 0 ) then
						self:SetEnemy( self.follow_target, true )
						self:UpdateEnemyMemory( self.follow_target, self.follow_target:GetPos() )
						self:StartSchedule( schdFollow )
						timer.Create( "self_select_schedule_timer" .. self:EntIndex(), 1, 1, function() self:StartSchedule( schdReset ) end )
			elseif( self.enemy == self.follow_target ) then
				self.enemy = NULL
			end
		else
			self.following = false
			self.follow_target = NULL
		end
	end
	
	local function wandering_schd()
		local convar_ai = GetConVarNumber("ai_disabled")
		if( convar_ai == 0 ) then
			self:StartSchedule( schdWandering )
		end
		timer.Create( "timer_created_timer" .. self.Entity:EntIndex( ), 5, 1, function() self.timer_created = false end )
	end
	
	
	if( self.wander == 1 and !self.following and !self.possessed and !self.FoundEnemy and convar_ai == 0 and !self.melee_attacking ) then
		if( !self.timer_created ) then
			self.timer_created = true
			timer.Create( "wandering_timer" .. self.Entity:EntIndex( ), math.random(10,14), 1, wandering_schd )
		end
	end
end 

/*---------------------------------------------------------
Name: OnRemove
Desc: Called just before entity is deleted
//-------------------------------------------------------*/
function ENT:OnRemove()
	self:StopSounds()
	if self.movetarget and IsValid( self.movetarget ) then self.movetarget:Remove() end
	self:EndPossession()
	timer.Destroy( "melee_attack_dmgdelay_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "self.enemy_occluded_timer" .. self:EntIndex() )
	timer.Destroy( "self.alert_allow_timer" .. self:EntIndex() )
	timer.Destroy( "self_select_schedule_timer" .. self:EntIndex() )
	timer.Destroy( "damage_count_reset_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "entity_index_remove_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "attack_end_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "attack_blastdelay_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "wandering_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "houndeye_setskin_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "timer_created_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "self.ghide_reset_timer" .. self.Entity:EntIndex( ) )
	timer.Destroy( "attacking_reset_timer" .. self:EntIndex() )
	timer.Destroy( "MadIdle_delay_timer" .. self:EntIndex() )
	timer.Destroy( "madidleb_timer_a" .. self:EntIndex() )
	timer.Destroy( "madidleb_timer_b" .. self:EntIndex() )
end