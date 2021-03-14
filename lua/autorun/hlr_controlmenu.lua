function GetAllNPCClasses()
	local npcs = {"monster_alien_babyvoltigore", "monster_alien_controller", "monster_alien_grunt", "monster_alien_slave", "monster_alien_slave", "monster_alien_voltigore", "monster_archer", "monster_babycrab", "monster_babygarg", "monster_barney", "monster_bigmomma", "monster_bullchicken", "monster_cockroach", "monster_gargantua", "monster_gman", "monster_gonome", "monster_headcrab", "monster_houndeye", "monster_human_assassin", "monster_human_grunt", "monster_hwgrunt", "monster_ichthyosaur", "monster_nihilanth", "monster_panthereye", "monster_parasite", "monster_penguin", "monster_pitdrone", "monster_pitworm", "monster_scientist", "monster_shocktrooper", "monster_snark", "monster_zombie", "monster_zombie_barney", "monster_zombie_soldier", "npc_mortarsynth", "npc_stukabat"}
	local npcs_default = {"npc_alyx", "npc_antlion", "npc_antlionguard", "npc_barney", "npc_breen", "npc_citizen", "npc_clawscanner", "npc_combine_s", "npc_crow", "npc_cscanner", "npc_dog", "npc_eli", "npc_fastzombie", "npc_fastzombie_torso", "npc_gman", "npc_headcrab", "npc_headcrab_black", "npc_headcrab_poison", "npc_headcrab_fast", "npc_hunter", "npc_kleiner", "npc_magnusson", "npc_manhack", "npc_metropolice", "npc_monk", "npc_mossman", "npc_pigeon", "npc_poisonzombie", "npc_rollermine", "npc_seagull", "npc_stalker", "npc_vortigaunt", "npc_zombie", "npc_zombie_torso", "npc_zombine"}
	table.Add(npcs, npcs_default)
	return npcs
end

HLR_CONTROLMENU = {}
HLR_NPC_RELATIONSHIPS = {}

HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCSPAWNER = true
HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCCONTROLLER = true
HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCHEALTH = true
HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCMOVEMENT = true
HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCRELATIONSHIP = true

//local npcs = {"monster_alien_babyvoltigore", "monster_alien_controller", "monster_alien_grunt", "monster_alien_slave", "monster_alien_slave", "monster_alien_voltigore", "monster_archer", "monster_babycrab", "monster_babygarg", "monster_barney", "monster_bigmomma", "monster_bullchicken", "monster_cockroach", "monster_gargantua", "monster_gman", "monster_gonome", "monster_headcrab", "monster_houndeye", "monster_human_assassin", "monster_human_grunt", "monster_hwgrunt", "monster_ichthyosaur", "monster_nihilanth", "monster_panthereye", "monster_parasite", "monster_penguin", "monster_pitdrone", "monster_pitworm", "monster_scientist", "monster_shocktrooper", "monster_snark", "monster_zombie", "monster_zombie_barney", "monster_zombie_soldier", "npc_mortarsynth", "npc_stukabat"}
//local npcs_default = {"npc_alyx", "npc_antlion", "npc_antlionguard", "npc_barney", "npc_breen", "npc_citizen", "npc_clawscanner", "npc_combine_s", "npc_crow", "npc_cscanner", "npc_dog", "npc_eli", "npc_fastzombie", "npc_fastzombie_torso", "npc_gman", "npc_headcrab", "npc_headcrab_black", "npc_headcrab_poison", "npc_headcrab_fast", "npc_hunter", "npc_kleiner", "npc_magnusson", "npc_manhack", "npc_metropolice", "npc_monk", "npc_mossman", "npc_pigeon", "npc_poisonzombie", "npc_rollermine", "npc_seagull", "npc_stalker", "npc_vortigaunt", "npc_zombie", "npc_zombie_torso", "npc_zombine"}

local npcs = GetAllNPCClasses()
//table.Add(npcs,npcs_default)
if HLR_MENUPANEL_ADD_XYSTUS then
	table.Add(npcs,GetDansNPCs())
end

local function GetNPCName(class)
	local class_exp = string.Explode("_", class)
	if !class_exp[2] then return class end
	local name = class_exp[2]
	if class_exp[3] then name = name .. " " .. class_exp[3] end
	return name
end

AddCSLuaFile("autorun/hlr_controlmenu.lua")

if SERVER then
	function HLR_MENUPANEL_REL_CHOSECLASS1(ply, cmd, args)
		local class = args[1]
		HLR_MENUPANEL_REL_CLASS1 = class
	end
	concommand.Add("HLR_MENUPANEL_REL_CHOSECLASS1", HLR_MENUPANEL_REL_CHOSECLASS1)

	function HLR_MENUPANEL_REL_CHOSEREL(ply, cmd, args)
		local rls = args[1]
		HLR_MENUPANEL_REL_REL = rls
	end
	concommand.Add("HLR_MENUPANEL_REL_CHOSEREL", HLR_MENUPANEL_REL_CHOSEREL)

	function HLR_MENUPANEL_REL_CHOSECLASS2(ply, cmd, args)
		local class = args[1]
		HLR_MENUPANEL_REL_CLASS2 = class
	end
	concommand.Add("HLR_MENUPANEL_REL_CHOSECLASS2", HLR_MENUPANEL_REL_CHOSECLASS2)

	function HLR_MENUPANEL_REL_APPLYREL(ply, cmd, args)
		if !HLR_MENUPANEL_REL_CLASS1 or !HLR_MENUPANEL_REL_CLASS2 or !HLR_MENUPANEL_REL_REL then return end
		
		if !HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCRELATIONSHIP and !ply:IsAdmin() then
			ply:SendLua("GAMEMODE:AddNotify(\"Sorry, this tool is admin only!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
			return false
		end
		
		ply:SendLua("surface.PlaySound(\"buttons/button14.wav\")") 
		local class_src = HLR_MENUPANEL_REL_CLASS1
		local class_trg = HLR_MENUPANEL_REL_CLASS2
		local rel = HLR_MENUPANEL_REL_REL
		local function ApplyRel(class_src, class_trg)
			local function RemoveRelationship(dl)
				local tbl_new = {}
				for k, v in pairs(HLR_NPC_RELATIONSHIPS[class_src]) do
					if v[2] != dl then
						tbl_new[k] = v
					end
				end
				HLR_NPC_RELATIONSHIPS[class_src] = tbl_new
			end
			
			if !HLR_NPC_RELATIONSHIPS[class_src] then HLR_NPC_RELATIONSHIPS[class_src] = {} end
			for k, v in pairs(HLR_NPC_RELATIONSHIPS[class_src]) do
				for rel, class in pairs(v) do
					if class == class_trg then
						RemoveRelationship(class)
					end
				end
			end
			table.insert(HLR_NPC_RELATIONSHIPS[class_src], {rel,class_trg})
		end
		local all = npcs
		table.insert(all,"player")
		local source
		local target
		if class_src != "All" then source = {class_src} else source = npcs end
		if class_trg != "All" then target = {class_trg} else target = all end
		for k, source in pairs(source) do
			for k, target in pairs(target) do
				ApplyRel(source, target)
			end
		end
		
		local npcs = ents.FindByClass("monster_*")
		table.Add(npcs, ents.FindByClass("npc_*"))
		for k, v in pairs(npcs) do
			if v.scripted then
				v:SetUpEnemies()
			end
		end
	end
	concommand.Add("HLR_MENUPANEL_REL_APPLYREL", HLR_MENUPANEL_REL_APPLYREL)
	
	function HLR_MENUPANEL_REL_RESETREL(ply, cmd, args)
		if !HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCRELATIONSHIP and !ply:IsAdmin() then
			ply:SendLua("GAMEMODE:AddNotify(\"Sorry, this tool is admin only!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
			return false
		end
	
		ply:SendLua("surface.PlaySound(\"buttons/button14.wav\")") 
		HLR_NPC_RELATIONSHIPS = {}
		local npcs = ents.FindByClass("monster_*")
		table.Add(npcs, ents.FindByClass("npc_*"))
		for k, v in pairs(npcs) do
			if v.scripted then
				v:SetUpEnemies()
			end
		end
	end
	concommand.Add("HLR_MENUPANEL_REL_RESETREL", HLR_MENUPANEL_REL_RESETREL)
	
	function HLR_MENUPANEL_SPEC_NPCSOURCE_SELECT(ply, cmd, args)
		local tracedata = {}
		tracedata.start = ply:GetShootPos()
		tracedata.endpos = ply:GetShootPos() +ply:GetAimVector() *1000
		tracedata.filter = ply
		local trace = util.TraceLine(tracedata)
		local sound = "buttons/button10.wav"
		if IsValid(trace.Entity) and trace.Entity:IsNPC() then
			sound = "buttons/button14.wav"
			ply:SendLua("GAMEMODE:AddNotify(\"" .. "Selected NPC " .. tostring(trace.Entity) .. " as source\", NOTIFY_HINT, 5)") 
			HLR_MENUPANEL_SPEC_NPCSOURCE = trace.Entity
		end 
		ply:SendLua("surface.PlaySound( \"" .. sound .. "\" )") 
	end
	concommand.Add("HLR_MENUPANEL_SPEC_NPCSOURCE_SELECT", HLR_MENUPANEL_SPEC_NPCSOURCE_SELECT)
	
	function HLR_MENUPANEL_SPEC_NPCTARGET_SELECT(ply, cmd, args)
		local tracedata = {}
		tracedata.start = ply:GetShootPos()
		tracedata.endpos = ply:GetShootPos() +ply:GetAimVector() *1000
		tracedata.filter = ply
		local trace = util.TraceLine(tracedata)
		local sound = "buttons/button10.wav"
		if IsValid(trace.Entity) and trace.Entity:IsNPC() then
			sound = "buttons/button14.wav"
			ply:SendLua("GAMEMODE:AddNotify(\"" .. "Selected NPC " .. tostring(trace.Entity) .. " as target\", NOTIFY_HINT, 5)") 
			HLR_MENUPANEL_SPEC_NPCTARGET = trace.Entity
		end 
		ply:SendLua("surface.PlaySound( \"" .. sound .. "\" )") 
	end
	concommand.Add("HLR_MENUPANEL_SPEC_NPCTARGET_SELECT", HLR_MENUPANEL_SPEC_NPCTARGET_SELECT)
	
	function HLR_MENUPANEL_SPEC_NPCSOURCE_FOLLOW(ply, cmd, args)
		if !IsValid(HLR_MENUPANEL_SPEC_NPCSOURCE) or !IsValid(HLR_MENUPANEL_SPEC_NPCTARGET) then return end
		if !HLR_MENUPANEL_SPEC_NPCSOURCE.scripted then ply:SendLua("GAMEMODE:AddNotify(\"You can only make scripted NPCs follow others!\", NOTIFY_HINT, 5); surface.PlaySound(\"buttons/button10.wav\")"); return end
		local npc = HLR_MENUPANEL_SPEC_NPCSOURCE
		local target = HLR_MENUPANEL_SPEC_NPCTARGET
		npc.following_disp = npc:Disposition( target )
		npc:AddEntityRelationship( target, 3, 10 )
		npc.following = true
		npc.follow_target = target
	end
	concommand.Add("HLR_MENUPANEL_SPEC_NPCSOURCE_FOLLOW", HLR_MENUPANEL_SPEC_NPCSOURCE_FOLLOW)
	
	function HLR_MENUPANEL_SPEC_NPCSOURCE_POSSESS(ply, cmd, args)
		if !IsValid(HLR_MENUPANEL_SPEC_NPCSOURCE) then return end
		local npc = HLR_MENUPANEL_SPEC_NPCSOURCE
		ply:PossessNPC(npc)
		local text = "You are now possessing " .. tostring(npc)
		local sound = "buttons/button14.wav"
		ply:SendLua("GAMEMODE:AddNotify(\"" .. text .. "\", NOTIFY_HINT, 5); surface.PlaySound( \"" .. sound .. "\" )") 
		timer.Simple(2, function() if IsValid(ply) then ply:SendLua("GAMEMODE:AddNotify(\"To stop the possession, press your jump key!\", NOTIFY_HINT, 5)") end end)
	end
	concommand.Add("HLR_MENUPANEL_SPEC_NPCSOURCE_POSSESS", HLR_MENUPANEL_SPEC_NPCSOURCE_POSSESS)
	
	
	function HLR_MENUPANEL_NPCSPAWN_SETNPCCLASS(ply, cmd, args)
		HLR_MENUPANEL_NPCSPAWN_NPCCLASS = args[1]
	end
	concommand.Add("HLR_MENUPANEL_NPCSPAWN_SETNPCCLASS", HLR_MENUPANEL_NPCSPAWN_SETNPCCLASS)
	
	function HLR_MENUPANEL_NPCSPAWN_SETSQUADNAME(ply, cmd, args)
		HLR_MENUPANEL_NPCSPAWN_SQUADNAME = args[1]
	end
	concommand.Add("HLR_MENUPANEL_NPCSPAWN_SETSQUADNAME", HLR_MENUPANEL_NPCSPAWN_SETSQUADNAME)
	
	function HLR_MENUPANEL_NPCSPAWN_SETSPAWNDELAY(ply, cmd, args)
		HLR_MENUPANEL_NPCSPAWN_SPAWNDELAY = tonumber(args[1])
	end
	concommand.Add("HLR_MENUPANEL_NPCSPAWN_SETSPAWNDELAY", HLR_MENUPANEL_NPCSPAWN_SETSPAWNDELAY)
	
	function HLR_MENUPANEL_NPCSPAWN_SETMAXNPCS(ply, cmd, args)
		HLR_MENUPANEL_NPCSPAWN_MAXNPCS = tonumber(args[1])
	end
	concommand.Add("HLR_MENUPANEL_NPCSPAWN_SETMAXNPCS", HLR_MENUPANEL_NPCSPAWN_SETMAXNPCS)
	
	function HLR_MENUPANEL_NPCSPAWN_CREATESPAWNER(ply, cmd, args)
		if !HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCSPAWNER and !self:GetOwner():IsAdmin() then
			self:GetOwner():SendLua("GAMEMODE:AddNotify(\"Sorry, this tool is admin only!\", NOTIFY_HINT, 5);surface.PlaySound( \"buttons/button10.wav\" )") 
			return false
		end
	
		local class = HLR_MENUPANEL_NPCSPAWN_NPCCLASS
		local squad = HLR_MENUPANEL_NPCSPAWN_SQUADNAME
		local delay = HLR_MENUPANEL_NPCSPAWN_SPAWNDELAY
		local maxnpcs = HLR_MENUPANEL_NPCSPAWN_MAXNPCS
		if delay < 1 then delay = 1 end
		if maxnpcs == 0 then maxnpcs = 1 end
		if !class or !delay or !maxnpcs then return end
		local tracedata = {}
		tracedata.start = ply:GetShootPos()
		tracedata.endpos = ply:GetShootPos() +ply:GetAimVector() *1000
		tracedata.filter = ply
		local trace = util.TraceLine(tracedata)
		ply:SendLua("surface.PlaySound(\"buttons/button14.wav\")") 
		local pos = trace.HitPos +trace.HitNormal * 16
		
		local SpawnAngles = Angle(0,ply:GetAngles().y,0)
		
		local autospawn = ents.Create("npc_autospawn")
		autospawn:SetPos(pos)
		autospawn:SetAngles(SpawnAngles)
		autospawn.class = class
		autospawn.owner = ply
		autospawn.turnonkey = HLR_MENUPANEL_NPCSPAWN_NPCSPAWNERTURNONKEY
		autospawn.turnoffkey = HLR_MENUPANEL_NPCSPAWN_NPCSPAWNERTURNOFFKEY
		autospawn.spawndelay = delay
		autospawn.maxnpcs = maxnpcs
		autospawn.squad = squad
		autospawn:Spawn()
		autospawn:Activate()
		
		if HLR_MENUPANEL_NPCSPAWN_REMOVENPCS then autospawn.autoremove = true end
		
		if !HLR_MENUPANEL_NPCSPAWN_STARTON then
			autospawn:Fire("turnoff","",0)
		end
		
		undo.Create("NPC Spawner")
			undo.AddEntity(autospawn)
			undo.SetPlayer(ply)
		undo.Finish() 
		
		cleanup.Register( "npc_autospawn" )
		cleanup.Add( ply, "NPC Spawner", autospawn)  
	end
	concommand.Add("HLR_MENUPANEL_NPCSPAWN_CREATESPAWNER", HLR_MENUPANEL_NPCSPAWN_CREATESPAWNER)
	
	
	function HLR_MENUPANEL_NPCSPAWN_TURNON(ply, cmd, args)
		HLR_MENUPANEL_NPCSPAWN_NPCSPAWNERTURNONKEY = tonumber(args[1])
	end
	concommand.Add("HLR_MENUPANEL_NPCSPAWN_TURNON", HLR_MENUPANEL_NPCSPAWN_TURNON)
	
	function HLR_MENUPANEL_NPCSPAWN_TURNOFF(ply, cmd, args)
		HLR_MENUPANEL_NPCSPAWN_NPCSPAWNERTURNOFFKEY = tonumber(args[1])
	end
	concommand.Add("HLR_MENUPANEL_NPCSPAWN_TURNOFF", HLR_MENUPANEL_NPCSPAWN_TURNOFF)
	
	function HLR_MENUPANEL_NPCSPAWN_SETSTARTON(ply, cmd, args)
		HLR_MENUPANEL_NPCSPAWN_STARTON = util.tobool(args[1])
	end
	concommand.Add("HLR_MENUPANEL_NPCSPAWN_SETSTARTON", HLR_MENUPANEL_NPCSPAWN_SETSTARTON)
	
	
	function HLR_MENUPANEL_NPCSPAWN_SETREMOVENPCS(ply, cmd, args)
		HLR_MENUPANEL_NPCSPAWN_REMOVENPCS = util.tobool(args[1])
	end
	concommand.Add("HLR_MENUPANEL_NPCSPAWN_SETREMOVENPCS", HLR_MENUPANEL_NPCSPAWN_SETREMOVENPCS)
	
	function HLR_MENUPANEL_TOOLSCONTROL_NPCSPAWNER(ply, cmd, args)
		if !ply:IsAdmin() then return end
		HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCSPANWER = util.tobool(args[1])
	end
	concommand.Add("HLR_MENUPANEL_TOOLSCONTROL_NPCSPAWNER", HLR_MENUPANEL_TOOLSCONTROL_NPCSPAWNER)
	
	function HLR_MENUPANEL_TOOLSCONTROL_NPCCONTROLLER(ply, cmd, args)
		if !ply:IsAdmin() then return end
		HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCCONTROLLER = util.tobool(args[1])
	end
	concommand.Add("HLR_MENUPANEL_TOOLSCONTROL_NPCCONTROLLER", HLR_MENUPANEL_TOOLSCONTROL_NPCCONTROLLER)
	
	function HLR_MENUPANEL_TOOLSCONTROL_NPCHEALTH(ply, cmd, args)
		if !ply:IsAdmin() then return end
		HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCHEALTH = util.tobool(args[1])
	end
	concommand.Add("HLR_MENUPANEL_TOOLSCONTROL_NPCHEALTH", HLR_MENUPANEL_TOOLSCONTROL_NPCHEALTH)
	
	function HLR_MENUPANEL_TOOLSCONTROL_NPCMOVEMENT(ply, cmd, args)
		if !ply:IsAdmin() then return end
		HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCMOVEMENT = util.tobool(args[1])
	end
	concommand.Add("HLR_MENUPANEL_TOOLSCONTROL_NPCMOVEMENT", HLR_MENUPANEL_TOOLSCONTROL_NPCMOVEMENT)
	
	function HLR_MENUPANEL_TOOLSCONTROL_NPCRELATIONSHIP(ply, cmd, args)
		if !ply:IsAdmin() then return end
		HLR_MENUPANEL_TOOLSCONTROL_ALLOWNPCRELATIONSHIP = util.tobool(args[1])
	end
	concommand.Add("HLR_MENUPANEL_TOOLSCONTROL_NPCRELATIONSHIP", HLR_MENUPANEL_TOOLSCONTROL_NPCRELATIONSHIP)
	
	function TOOL_HLR_NPCCONROL_RELATIONSHIPS_SETPRIORITY(ply, cmd, args)
		TOOL_HLR_NPCCONROL_RELATIONSHIPS_PRIORITY = tonumber(args[1])
	end
	concommand.Add("TOOL_HLR_NPCCONROL_RELATIONSHIPS_SETPRIORITY", TOOL_HLR_NPCCONROL_RELATIONSHIPS_SETPRIORITY)
	
	function HLR_NPCCONTROL_RELATIONSHIPS_SETDISPOSITION(ply, cmd, args)
		HLR_NPCCONTROL_RELATIONSHIPS_DISPOSITION = args[1]
	end
	concommand.Add("HLR_NPCCONTROL_RELATIONSHIPS_SETDISPOSITION", HLR_NPCCONTROL_RELATIONSHIPS_SETDISPOSITION)
return end

function HLR_CONTROLMENU.NPCControlPanel(Panel)
	local label = {}
	label.Text = "Relationships:"
	Panel:AddControl("Label", label)

	label.Text = "Source NPC Class:"
	Panel:AddControl("Label", label)

	local options = npcs
	table.insert(options, "All")

	local listbox = {}
	listbox.Label = "Source NPC Class"
	listbox.MenuButton = 0
	listbox.Height = 150
	listbox.Options = {}
	for k, v in pairs(options) do
		listbox.Options[GetNPCName(v)] = {HLR_MENUPANEL_REL_CHOSECLASS1 = v}
	end
	Panel:AddControl("ListBox", listbox)
	
	label.Text = "Relationship:"
	Panel:AddControl("Label", label)
	
	local rls = {}
	table.insert(rls, "Like")
	table.insert(rls, "Hate")
	table.insert(rls, "Fear")
	table.insert(rls, "Neutral")
	local listbox = {}
	listbox.Label = "HLR_REL_REL"
	listbox.MenuButton = false
	listbox.Options = {}
	for k, v in pairs(rls) do
		listbox.Options[v] = {HLR_MENUPANEL_REL_CHOSEREL = v}
	end
	Panel:AddControl("ComboBox", listbox)
	
	local listbox = {}
	listbox.Label = "Target NPC Class"
	listbox.MenuButton = 0
	listbox.Height = 150
	listbox.Options = {}
	for k, v in pairs(options) do
		listbox.Options[GetNPCName(v)] = {HLR_MENUPANEL_REL_CHOSECLASS2 = v}
	end
	Panel:AddControl("ListBox", listbox)
	
	local button = {}
	button.Label = "Apply Relationship"
	button.Text = "Apply Relationship"
	button.Command = "HLR_MENUPANEL_REL_APPLYREL"
	Panel:AddControl("Button", button)
	
	local button = {}
	button.Label = "Reset Relationships"
	button.Text = "Reset Relationships"
	button.Command = "HLR_MENUPANEL_REL_RESETREL"
	Panel:AddControl("Button", button)
end

function HLR_CONTROLMENU.NPCControlPanelSpec(Panel)
	local button = {}
	button.Label = "Select NPC"
	button.Text = "Select NPC"
	button.Command = "HLR_MENUPANEL_SPEC_NPCSOURCE_SELECT"
	Panel:AddControl("Button", button)
	
	local textbox = {}
	textbox.Label = "Health"
	textbox.MaxLength = 5
	textbox.WaitForEnter = false
	textbox.Type = "Integer"
	textbox.Command = "HLR_MENUPANEL_SPEC_NPCSOURCE_SETHEALTH"
	Panel:AddControl("TextBox", textbox)
	
	local button = {}
	button.Label = "Apply Health"
	button.Text = "Apply Health"
	button.Command = "HLR_MENUPANEL_SPEC_NPCSOURCE_APPLYHEALTH"
	Panel:AddControl("Button", button)
	
	local button = {}
	button.Label = "Go to"
	button.Text = "Follow Target"
	button.Command = "HLR_MENUPANEL_SPEC_NPCSOURCE_FOLLOW"
	Panel:AddControl("Button", button)
	
	local button = {}
	button.Label = "Possess"
	button.Text = "Possess"
	button.Command = "HLR_MENUPANEL_SPEC_NPCSOURCE_POSSESS"
	Panel:AddControl("Button", button)
end

function HLR_CONTROLMENU.NPCControlAutoSpawn(Panel)
	local listbox = {}
	listbox.Label = "NPC"
	listbox.MenuButton = 0
	listbox.Height = 150
	listbox.Options = {}
	for k, v in pairs(npcs) do
		listbox.Options[GetNPCName(v)] = {HLR_MENUPANEL_NPCSPAWN_SETNPCCLASS = v}
	end
	
	Panel:AddControl("ListBox", listbox)
	
	local textbox = {}
	textbox.Label = "Squadname"
	textbox.MaxLength = 20
	textbox.WaitForEnter = false
	textbox.Type = "Float"
	textbox.Command = "HLR_MENUPANEL_NPCSPAWN_SETSQUADNAME"
	Panel:AddControl("TextBox", textbox)
	
	local slider = {}
	slider.Label = "Spawn delay"
	slider.min = 1
	slider.max = 180
	slider.Type = "Float"
	slider.Command = "HLR_MENUPANEL_NPCSPAWN_SETSPAWNDELAY"
	Panel:AddControl("Slider", slider)
	
	slider.Label = "Max NPCs at a time"
	slider.min = 1
	slider.max = 40
	slider.Type = "Integer"
	slider.Command = "HLR_MENUPANEL_NPCSPAWN_SETMAXNPCS"
	Panel:AddControl("Slider", slider)
	
	local numpad = {}
	numpad.Label = "#Turn On"
	numpad.Label2 = "#Turn Off"
	numpad.Command = "HLR_MENUPANEL_NPCSPAWN_TURNON"
	numpad.Command2 = "HLR_MENUPANEL_NPCSPAWN_TURNOFF"
	numpad.ButtonSize = 22
	Panel:AddControl("Numpad", numpad)
	
	local checkbox = {}
	checkbox.Label = "Start On"
	checkbox.Command = "HLR_MENUPANEL_NPCSPAWN_SETSTARTON"
	Panel:AddControl("CheckBox", checkbox)
	
	checkbox.Label = "Remove spawned NPCs on removal"
	checkbox.Command = "HLR_MENUPANEL_NPCSPAWN_SETREMOVENPCS"
	Panel:AddControl("CheckBox", checkbox)
	
	local button = {}
	button.Label = "Create NPC Spawner"
	button.Text = "Create NPC Spawner"
	button.Command = "HLR_MENUPANEL_NPCSPAWN_CREATESPAWNER"
	Panel:AddControl("Button", button)
end

function HLR_CONTROLMENU.NPCControlTools(Panel)
	local label = {}
	label.Text = "Select the tools which should be useable for everyone. Unselected tools are admin only:"
	Panel:AddControl("Label", label)
	
	local checkbox = {}
	checkbox.Label = "Automatic NPC Spawner"
	checkbox.Command = "HLR_MENUPANEL_TOOLSCONTROL_NPCSPAWNER"
	Panel:AddControl("CheckBox", checkbox)
	
	checkbox.Label = "Relationships"
	checkbox.Command = "HLR_MENUPANEL_TOOLSCONTROL_NPCRELATIONSHIP"
	Panel:AddControl("CheckBox", checkbox)
	
	checkbox.Label = "NPC Controller Stool"
	checkbox.Command = "HLR_MENUPANEL_TOOLSCONTROL_NPCCONTROLLER"
	Panel:AddControl("CheckBox", checkbox)
	
	checkbox.Label = "Health Stool"
	checkbox.Command = "HLR_MENUPANEL_TOOLSCONTROL_NPCHEALTH"
	Panel:AddControl("CheckBox", checkbox)
	
	checkbox.Label = "Movement Stool"
	checkbox.Command = "HLR_MENUPANEL_TOOLSCONTROL_NPCMOVEMENT"
	Panel:AddControl("CheckBox", checkbox)
end

function HLR_CONTROLMENU.PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Utilities", "NPC Control", "General NPC Control", "General NPC Control", "", "", HLR_CONTROLMENU.NPCControlPanel)
	//spawnmenu.AddToolMenuOption("Utilities", "NPC Control", "Specific NPC Control", "Specific NPC Control", "", "", HLR_CONTROLMENU.NPCControlPanelSpec)
	spawnmenu.AddToolMenuOption("Utilities", "NPC Control", "Automatic NPC Spawner", "Automatic NPC Spawner", "", "", HLR_CONTROLMENU.NPCControlAutoSpawn)
	spawnmenu.AddToolMenuOption("Utilities", "NPC Control", "Admin Tool Control", "Admin Tool Control", "", "", HLR_CONTROLMENU.NPCControlTools)
end
hook.Add("PopulateToolMenu", "HLR_CONTROLMENU.PopulateToolMenu", HLR_CONTROLMENU.PopulateToolMenu)
