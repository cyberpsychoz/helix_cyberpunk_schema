OBJs.actions 	= 	OBJs.actions 	or {}
OBJs.jobs			=		OBJs.jobs			or {}
OBJs.actions["start"] = function(user, id)
		local task = OBJs:Check(id)
		local typeExists = OBJs:ExistsType(task.type)
		if task then
			if OBJs:PendingAdd() then
					user:NOTIFY("Someone is receiving the objective right now, wait.")
					return;
			end;
			if !OBJs:IsJobsFree(task.jobs) then return end;
				task.active = true;
				OBJs.list[id] = util.TableToJSON(task)
				local options = util.JSONToTable(task.options)
				OBJs:SyncList()
				OBJs:CreateClientSideDelay(id);
				
			timer.Create(id .. " - objective start", OBJs.timeToGetMsg, 1, function()
				if !OBJs:Check(id) then 
					return; 
				end;
				if OBJs:IsJobsFree(task.jobs) then
					OBJs:SyncObjectives(id)

					local uniqueID = id .. " - objective"
					if timer.Exists(uniqueID) then return end;

					if task.entity && IsEntity(Entity(task.Hit)) && !IsValid(Entity(task.Hit)) then
							OBJs:Remove(id)
							return;
					end

					hook.Call("OBJs::Start", nil, id)
					typeExists.OnStart(id) 
					if user && user:IsPlayer() then
						user:NOTIFY("The task is started!", "success")
					end;

					timer.Create(uniqueID, 1, options["time"] or 0, function()
						if !timer.Exists(uniqueID) then timer.Remove(uniqueID) return; end;

						hook.Call("OBJs::Check", nil, id)
						local onCheck = typeExists.OnCheck(id);

						if !OBJs:CheckAlive(id) || timer.RepsLeft(uniqueID) == 1 then
								typeExists.OnFail(id)
								hook.Call("OBJs::Failed", nil, id);
								
							for k, v in pairs(OBJs:PlayersOnTask(id)) do
									v:NOTIFY("Mission failed - No survivors", "missionfail")
							end

								OBJs:Remove(id)
								timer.Remove(uniqueID)
								return;
						end

						if onCheck == "succ" then
							hook.Call("OBJs::Success", nil, id)
							typeExists.OnSuccess(id)
							
							for k, v in pairs(OBJs:PlayersOnTask(id)) do
									v:NOTIFY("Mission success - All objectives are clear")
							end
							
							OBJs:Remove(id);
							timer.Remove(uniqueID)
							return;
						elseif onCheck == "fail" then
							typeExists.OnFail(id)
							hook.Call("OBJs::Failed", nil, id)
							for k, v in pairs(OBJs:PlayersOnTask(id)) do
									v:NOTIFY("Mission failed", "missionfail", "missionfail")
							end

							OBJs:Remove(id)
							timer.Remove(uniqueID)
							return;
						end
					end);					
				else
					if user then
						user:NOTIFY("This jobs is not ready to receive a new task for now.", "err")
					end;
				end
			end);

		end
end;
OBJs.actions["remove"] = function(user, id)
	if timer.Exists(id .. " - objective start") then return end;

		local task = OBJs:Check(id)
		if task then
				if task.active then
						local typeExists = OBJs:ExistsType(task.type)
						timer.Remove(id .. " - objective")
						hook.Call("OBJs::Failed", nil, id)
						typeExists.OnFail(id)
						user:NOTIFY("The task is removed and stopped.", "NOTIFY")
				end;

				OBJs:Remove(id)
					
				user:NOTIFY("The task is removed.", "NOTIFY")
		end
end;

OBJs.actions["up"] = function(user, id)
		local task = OBJs:Check(id)

		if task then
			local len = #OBJs.list;
			if len > 1 then
					local integ = 0;
					if id - 1 < 1 then
						integ = len;
					elseif id - 1 >= 1 then
							integ = id - 1;
					end;
					local copy = OBJs.list[id];
					if OBJs.list[integ].active then return end;
					if OBJs.list[integ].queued then OBJs.list[integ].queued = false copy.queued = true end;

					OBJs.list[id] = OBJs.list[integ]
					OBJs.list[integ] = copy;
			end
			OBJs:SyncList();
		end
end;

OBJs.actions["down"] = function(user, id)
		local task = OBJs:Check(id)

		if task then
			local len = #OBJs.list;
			if len > 1 then
					local integ = 0;
					if id + 1 > len then
						integ = len;
					elseif id + 1 <= len then
							integ = id + 1;
					end;
					local copy = OBJs.list[id];
					if OBJs.list[integ].active then return end;
					if OBJs.list[integ].queued then OBJs.list[integ].queued = false copy.queued = true end;
					
					OBJs.list[id] = OBJs.list[integ]
					OBJs.list[integ] = copy;
			end
			OBJs:SyncList();
		end
end;

OBJs.actions["startQueue"] = function(user)
		local queued = 1;
		if #OBJs.list <= 1 || OBJs.list[2] && OBJs:Check(2) && OBJs:Check(2).queued then return end;

		for k, v in ipairs(OBJs.list) do
				local data = util.JSONToTable(v);
				if !v.active then
					if k > 1 then
						queued = k;
						break;
					elseif k == 1 then
						OBJs.actions["start"](nil, 1)
					end;
				end
		end
		
		local got = util.JSONToTable(OBJs.list[queued]);
		got.queued = true;
		OBJs.list[queued] = util.TableToJSON(got);

		OBJs:SyncList();
end;

OBJs.actions["stopQueue"] = function(user)
	for k, v in ipairs(OBJs.list) do
				local data = util.JSONToTable(v);
				if data.queued then
						local info = OBJs:Check(k)
						info.queued = nil;
						OBJs.list[k] = util.TableToJSON(info);
						OBJs:SyncList()
						return;
				end
		end
end;

-- local test = {
-- 	[1] = "Hello",
-- 	[2] = "World",
-- 	[3] = "I'm here"
-- }

-- local littleCopy = test[1]
-- test[1] = test[3]
-- test[3] = littleCopy

-- local littleCopy = test[3]
-- test[3] = test[2]
-- test[2] = littleCopy

-- for i = #test, 1, -1 do
		
-- end


-- PrintTable(test)