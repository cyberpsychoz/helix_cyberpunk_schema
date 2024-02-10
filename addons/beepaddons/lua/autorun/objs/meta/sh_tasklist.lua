OBJs:CreateType("capture_flag", {
	name = "Capture the flag",
	description = "Players must be within the radius of the flag to be captured. If the player is outside the radius, then the object gradually loses its capture percentage. During the capture, the pedestal generates an NPC around it, a task configuration. When spawning an NPC, you need to make sure that it will not be placed in an obstacle or blockage.",
	options = {
		["Radius"] = {
			info = "number",
			min = 60,
			max = 600
		},
		["Point Amount"] = {
			info = "number",
			min = 60,
			max = 200,
		},
		["Multiplication"] = {
			info = "float",
			min = 1,
			max = 2
		},
		["Time for capture"] = {
			info = "time",
			min = 60,
			max = 360,
		},
		["NPC"] = {
			info = "npc"
		},
		["NPC spawn chance"] = {
			info = "number",
			min = 50,
			max = 100,
		},
		["NPC spawn amount"] = {
			info = "number",
			min = 5,
			max = 20,
		},
		["Reinforcements"] = {
			info = "reinforcement"
		},
		["NPC capture check contest"] = {
			info = "number",
			min = 5,
			max = 10,
		},
		["Positions list for NPC"] = {
			info = "position_list",
		},
		["Weapon for NPC"] = {
			info = "weapons"
		}
	},
	entity = false, 
	placeholder = "models/jellyton/bf2/misc/props/command_post.mdl",
	BG = "02", 
	OnStart 	= function(id) 
		local data = OBJs:Check(id);
		local exType = OBJs:ExistsType(data.type);

		if data then
				data.capture = 1;
				data.npcAmount = 0;
				data.npcCaptureContest = 0;
		end

		local ent = ents.Create("prop_dynamic")
		ent:SetModel(exType.placeholder)
		ent:SetPos(data.Hit)
		ent:Spawn()
		ent:SetBodyGroups(exType.BG)

		data._entity = ent:EntIndex()

		OBJs:SaveData(id, data)
	end, 
	OnCheck 	= function(id) 
		local data = OBJs:Check(id);
		local options = util.JSONToTable(data.options);
		local pos = data.Hit
		local sphere = ents.FindInSphere(pos, options["Radius"])
		local npc = util.JSONToTable(options["NPC"])
		local positions = util.JSONToTable(options["Positions list for NPC"])

		if npc && #npc > 0 then
				if math.random(100) < options["NPC spawn chance"] && (data.npcAmount < options["NPC spawn amount"]) then
					data.npcAmount = data.npcAmount + 1;

					local newPC = ents.Create(npc[math.random(1, #npc)])
					if #positions > 0 then
						newPC:SetPos( Vector(positions[math.random(1, #positions)]) )
					else
						newPC:SetPos(pos)
					end;
					newPC:Spawn()
					if newPC && newPC:IsValid() then
						newPC:Give(options["Weapon for NPC"])
						timer.Simple(0.5, function()
							newPC:SetSaveValue("m_vecLastPosition", pos)
							newPC:SetSchedule(SCHED_FORCED_GO_RUN)
						end);
					end;
				end;
		end

		for k, v in pairs(ents.FindInSphere(pos, options["Radius"]+60)) do
				if v:IsNPC() && table.HasValue(npc, v:GetClass()) then 
					data.capture = math.Clamp(data.capture - 1, 0, options["Point Amount"]);
					if data.capture == 0 then
							data.npcCaptureContest = data.npcCaptureContest + 1;
							if data.npcCaptureContest >= options["NPC capture check contest"] then
									for k, v in pairs(OBJs:PlayersOnTask(id)) do
											v:SendSound("pr/cap_lost.wav")
									end
									return "fail"
							end
					end
					
					OBJs:SaveData(id, data)
					return 
				end;
		end;

		for k, v in ipairs(sphere) do
			if v:IsPlayer() && v:Alive() && !v.KIA then
				if data.npcCaptureContest > 0 then data.npcCaptureContest = 0; end;

				data.capture = data.capture + 1 * options["Multiplication"];
				netstream.Start(v, 'catpureUpdate')
				v:SyncObjective(id);
			end
		end
		OBJs:SaveData(id, data)
		if data.capture >= options["Point Amount"] then
			for k, v in pairs(OBJs:PlayersOnTask(id)) do
					v:SendSound("pr/cap_taken_"..math.random(1, 2)..".wav")
			end
		end
		return data.capture >= options["Point Amount"] && "succ" or false
	end,
	OnSuccess = function(id)
			local data = OBJs:Check(id);
			if IsEntity(Entity(data._entity)) && Entity(data._entity) then
					Entity(data._entity):Remove();
			end
	end,
	OnFail 		= function(id)
			local data = OBJs:Check(id);
			if IsEntity(Entity(data._entity)) && Entity(data._entity) then
					Entity(data._entity):Remove();
			end
	end,
})

OBJs:CreateType("defend_target", {
	name = "Defend the target",
	description = "Protect npc / vehicle / prop / player / entity. Dealing damage to an object causes health lose. If health reaches a critical level, then the object is considered lost, and the task is considered failed.",
	options = {
		["Health"] = {
			info = "number",
			min = 100,
			max = 1000
		},
		["Defend time"] = {
			info = "time",
			min = 60,
			max = 360
		},
	},
	entity = true,
	OnStart 	= function(id) 
		local data = OBJs:Check(id);
		local options = util.JSONToTable(data.options);
		
		if IsEntity(Entity(data.Hit)) then
			if Entity(data.Hit).Health then
				Entity(data.Hit):SetHealth(options["Health"])
				Entity(data.Hit):SetMaxHealth(options["Health"])
			else
				Entity(data.Hit).heal = options["Health"]
				Entity(data.Hit).maxheal = options["Health"]
			end
		end
	end,
	OnCheck 	= function(id) 
		local data = OBJs:Check(id);
		local entity = IsEntity(Entity(data.Hit)) && Entity(data.Hit)
		if entity == NULL then return "fail" end;
		local hasHealth = entity.Health && entity:Health() > 0 || entity.heal && entity.heal > 0;
		if entity && hasHealth then
			return false;
		elseif entity && !hasHealth then
			return "fail"
		end
	end,
	OnSuccess = function(id)
			local uniqueID = "Time: " .. id
		 	if timer.Exists(uniqueID) then
				 timer.Remove(uniqueID)
		 	end 
	end,
	OnEnd 		= function(id)
	end,
	OnFail 		= function(id)
	end,
})

OBJs:CreateType("defend_area", {
	name = "Defend the area",
	description = "Defending a territory is similar to defending a flag, but that territory needs to be defended for a certain amount of time.",
	options = {
		["Radius"] = {
			info = "number",
			min = 60,
			max = 600
		},
		["Defend time"] = {
			info = "time",
			min = 60,
			max = 300,
		},
		["NPC"] = {
			info = "npc"
		},
		["NPC spawn chance"] = {
			info = "number",
			min = 50,
			max = 100,
		},
		["NPC spawn amount"] = {
			info = "number",
			min = 5,
			max = 20,
		},
		["Reinforcements"] = {
			info = "reinforcement"
		},
		["NPC capture check contest"] = {
			info = "number",
			min = 5,
			max = 100,
		},
		["Positions list for NPC"] = {
			info = "position_list",
		},
		["Weapon for NPC"] = {
			info = "weapons"
		}
	},
	entity = false,
	OnStart 	= function(id) 
		local data = OBJs:Check(id);
		local options = util.JSONToTable(data.options);
		if data then
				data.time = options["time"];
				data.captureContest = 0;
				data.npcAmount = 0;
		end
		OBJs:SaveData(id, data)
	end,
	OnCheck 	= function(id) 	
		local data = OBJs:Check(id);
		local options = util.JSONToTable(data.options);
		local pos = data.Hit
		local sphere = ents.FindInSphere(pos, options["Radius"])
		local npc = util.JSONToTable(options["NPC"])
		local positions = util.JSONToTable(options["Positions list for NPC"])
		
		if data then
				data.time = data.time - 1;
		end

		if npc && #npc > 0 then
				if math.random(100) < options["NPC spawn chance"] && (data.npcAmount < options["NPC spawn amount"]) then
					data.npcAmount = data.npcAmount + 1;

					local newPC = ents.Create(npc[math.random(1, #npc)])
					if #positions > 0 then
						newPC:SetPos( Vector(positions[math.random(1, #positions)]) )
					else
						newPC:SetPos(pos)
					end;
					newPC:Spawn()
					newPC:Give(options["Weapon for NPC"])
					timer.Simple(0.5, function()
						newPC:SetSaveValue("m_vecLastPosition", pos)
						newPC:SetSchedule(SCHED_FORCED_GO_RUN)
					end);
				end;
		end

		for k, v in pairs(ents.FindInSphere(pos, options["Radius"]+60)) do
				if v:IsNPC() && table.HasValue(npc, v:GetClass()) then 
						data.npcCaptureContest = data.npcCaptureContest + 1;
						if data.npcCaptureContest >= options["NPC capture check contest"] then
								return "fail"
						end

						OBJs:SaveData(id, data)
						return;
				end
		end;

		data.npcCaptureContest = 0;
		OBJs:SaveData(id, data)

		return data.time == 1 && "succ" or false;
	end,
	OnSuccess = function(id) 
	end,
	OnFail 		= function(id)
	end,
})

OBJs:CreateType("shutdown_system", {
	name = "Shutdown the system",
	description = "Install a malware on a entity and wait until the objective time reaches zero. Other players can deactivate an installed malware",
	options = {
		["Shutdown time"] = {
			info = "time",
			min = 10,
			max = 300,
		},
	},
	placeholder = "models/kingpommes/starwars/misc/palp_panel1.mdl",
	entity = false,
	OnStart 	= function(id)
		local data = OBJs:Check(id);
		local options = util.JSONToTable(data.options);

		local ent = ents.Create("hack_terminal")
		ent:SetPos(data.Hit)
		ent:Spawn()
		ent:SetOBJid(id);

		data._entity = ent:EntIndex()
		data.time = options["time"];

		OBJs:SaveData(id, data) 
	end,
	OnCheck 	= function(id)
		local data = OBJs:Check(id);
		data.time = data.time - 1;
		OBJs:SaveData(id, data)
		
		return Entity(data._entity):GetMalwared() && data.time == 1 && "succ" or false;
	end,
	OnSuccess = function(id)
			local data = OBJs:Check(id);
			if IsEntity(Entity(data._entity)) && Entity(data._entity) then
					Entity(data._entity):Remove();
			end
	end,
	OnFail 		= function(id)
			local data = OBJs:Check(id);
			if IsEntity(Entity(data._entity)) && Entity(data._entity) then
					Entity(data._entity):Remove();
			end
	end,
})

OBJs:CreateType("reach_position", {
	name = "Reach the area",
	description = "Reach a certain area with all living forces.",
	options = {
		["Radius"] = {
			info = "number",
			min = 60,
			max = 600
		},
		["Reach time"] = {
			info = "time",
			min = 60,
			max = 300,
		},
	},
	entity = false,
	OnStart 	= function(id) 
	end,
	OnCheck 	= function(id) 
		local data = OBJs:Check(id);
		local options = util.JSONToTable(data.options);
		local jobs = util.JSONToTable(data.jobs)
		local radius = ents.FindInSphere(data.Hit, options["Radius"])

		local checkTable = {}
		local JobsCollection = {}
		
		for k, v in pairs(jobs) do
				if OBJs.jobs[v] then
						for ply, status in pairs(OBJs.jobs[v]) do
								if status == "alive" then
									JobsCollection[#JobsCollection + 1] = ply:EntIndex();
								end;
						end 
				end
		end
		
		for k, v in ipairs(radius) do
				if v:IsPlayer() && !v.KIA && table.HasValue(jobs, v:GetJobCategory()) && v:FindInObjective(id) then
						if OBJs.jobs[v:GetJobCategory()][v] && OBJs.jobs[v:GetJobCategory()][v] == "alive" then
								checkTable[#checkTable + 1] = k
						end
				end
		end
		
		checkTable = util.TableToJSON(checkTable);
		JobsCollection = util.TableToJSON(JobsCollection);

		return checkTable:len() > 2 && JobsCollection:len() > 2 && checkTable == JobsCollection && "succ" or false
	end,	
	OnSuccess = function(id) 
	end,
	OnFail 		= function(id)
	end,
})

OBJs:CreateType("destroy_objective", {
	name = "Destroy an objective",
	description = "Drop the targets health to zero to success the mission.",
	options = {
		["Health"] = {
			info = "number",
			min = 100,
			max = 1000
		},
		["Kill time"] = {
			info = "time",
			min = 60,
			max = 360
		},
	},
	entity = true,
	OnStart 	= function(id) 
		local data = OBJs:Check(id);
		local options = util.JSONToTable(data.options);
		local entity = Entity(data.Hit)
		
		if IsEntity(entity) then
			if entity.Health then
				entity:SetHealth(options["Health"])
				entity:SetMaxHealth(options["Health"])
			else
				entity.heal = options["Health"]
				entity.maxheal = options["Health"]
			end
		end

	end,
	OnCheck 	= function(id) 
		local data = OBJs:Check(id);
		local entity = IsEntity(Entity(data.Hit)) && Entity(data.Hit)
		if entity == NULL then return "succ" end;
		local hasHealth = entity && entity.Health && entity:Health() > 0 || entity.heal && entity.heal > 0;
		if entity && hasHealth then
			return false;
		elseif entity && !hasHealth then
			return "succ"
		end
	end,
	OnSuccess = function(id) 
		local data = OBJs:Check(id);
		local entity = Entity(data.Hit)
		
		if entity != NULL && IsEntity(entity) then
				entity:Remove();
		end;
	end,
	OnFail 		= function(id)
	end,
})

OBJs:CreateType("extraction", {
	name = "Extraction",
	description = "Extract the package to the area.",
	options = {
		["Radius"] = {
			info = "number",
			min = 60,
			max = 600
		},
		["Position for package"] = {
			info = "position"
		},
		["Package model"] = {
			info = "text"
		},
		["Time to extract"] = {
			info = "time",
			min = 60,
			max = 300,
		},
	},
	entity = false,
	OnStart 	= function(id)
			local data = OBJs:Check(id);
			local options = util.JSONToTable(data.options);

			local mdl = options["Package model"]:len() > 0 && options["Package model"] or "models/props_junk/watermelon01.mdl"

			local Extract = ents.Create("prop_physics")
			Extract:SetModel(mdl)
			Extract:SetPos(options["Position for package"])
			Extract:Spawn()

			Extract.extract = true;
			Extract.id = id;

			if data then
					data.package = Extract:EntIndex()
			end
			OBJs:SaveData(id, data)
	end,
	OnCheck 	= function(id) 
			local data = OBJs:Check(id);
			local options = util.JSONToTable(data.options);

			for k, v in pairs(ents.FindInSphere(data.Hit, options["Radius"])) do
				if v.extract && v.id == id then
						v:Remove();
						return "succ"
				end
			end
	end,
	OnSuccess = function(id)
		local data = OBJs:Check(id);
		if data && data.package then
				local ent = Entity(data.package);
				if IsEntity(ent) && ent:IsValid() then
					ent:Remove()
				end
		end
	end,
	OnFail 		= function(id)
	end,
})