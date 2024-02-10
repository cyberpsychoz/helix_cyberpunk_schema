--[[ 
	Adds a new objective to render list.
	@data - table with info.
	returns nil;
]]--
function OBJs:Add(data, edit)
		local id = edit > 0 && edit or #OBJs.list + 1
		data.id = id
		data = util.TableToJSON(data)
		OBJs.list[id] = data;

		self:SyncList();
end;

--[[
	Removes an objective from a list;
]]--
function OBJs:Remove(id)
		if self:Check(id).active then
			local jobs = util.JSONToTable(self:Check(id).jobs)

				for k, v in ipairs(player.GetAll()) do
						if v:IsValid() && table.HasValue(jobs, v:GetJobCategory()) then
								v.objectiveID = nil;
								netstream.Start(v, 'OBJs::ClearObjective', id)
								if v.KIA then 
									v.KIA = false 
									v:Spawn()
								end;
								if self.jobs[v:GetJobCategory()] then
										self.jobs[v:GetJobCategory()] = nil;
								end;
						end
				end;
		end
		hook.Call("OBJs::Remove", nil, id)
		self.list[id] = nil;

		local buffer = {}
		for k, v in pairs(self.list) do
				buffer[#buffer + 1] = v;
		end
		self.list = buffer;

		self:SyncList()

		timer.Simple(1, function()
				for k, v in pairs(OBJs.list) do
						local data = OBJs:Check(k)

						if data.queued then
								OBJs.actions["start"](user, k)
								if OBJs.list[k + 1] then
									local data = OBJs:Check(k + 1)
									data.queued = true;
									OBJs.list[k + 1] = util.TableToJSON(data);
							end
							OBJs:SyncList()
							return;
						end
				end
		end);
end;

--[[
	Synchronizes a render list with all admins;
]]--
function OBJs:SyncList()
		local collection = util.TableToJSON(self.list)

		for k, v in ipairs(player.GetAll()) do
				if v:IsAdmin() || v:IsSuperAdmin() then
						netstream.Start(v, 'OBJs::ReceiveRender', collection)
				end
		end
end;

function OBJs:SaveData(id, data)
		OBJs.list[id] = util.TableToJSON(data)
end;

--[[
	Sends an objective to the exact user on START;
]]--
function OBJs:SyncObjectives(id)
		local collection = self:Check(id)
		if !collection then return end;
		local jobs = util.JSONToTable(collection.jobs)

		for k, v in ipairs(player.GetAll()) do
			if table.HasValue(jobs, v:GetJobCategory()) then
					v.objectiveID = id;
					netstream.Start(v, 'OBJs::ReceiveObjective', self.list[id], false, id)
					
					netstream.Start(v, 'OBJs::SyncDeathCount', #OBJs:PlayersOnTask(id))
					if !self.jobs[v:GetJobCategory()] then
						self.jobs[v:GetJobCategory()] = {}
					end;
					self.jobs[v:GetJobCategory()][v] = v:Alive() && !v.KIA && "alive" or "dead"
			end
		end;
end;

function OBJs:CreateClientSideDelay(id)
		local collection = self:Check(id)
		if !collection then return end;
		local jobs = util.JSONToTable(collection.jobs)

		for k, v in ipairs(player.GetAll()) do
			if table.HasValue(jobs, v:GetJobCategory()) then
					netstream.Start(v, 'OBJs::CreateClientsideTimer', id)
			end
		end;
end;


-- Check if you can START an objective for the job category
function OBJs:IsJobsFree(jobs)
		jobs = util.JSONToTable(jobs);

		for k, v in ipairs(jobs) do
				if self.jobs[v] then
					return false;
				end
		end

		return true;
end

function OBJs:CheckAlive(id)
		local collection = self:Check(id)
		if !collection then return end;
		local jobs = util.JSONToTable(collection.jobs);
		local _jobs = {}
		
		for k, v in ipairs(jobs) do
				if OBJs.jobs[v] then
						for ply, status in pairs(OBJs.jobs[v]) do
								if status == "alive" then
										_jobs[#_jobs + 1] = ply:EntIndex();
								end;
						end 
				end
		end
		
		_jobs = util.TableToJSON(_jobs);

		return _jobs:len() != 2;
end;

function OBJs:PlayersOnTask(id)
	local check = self:Check(id)
	local plyList = {};

	if check then
			local jobs = util.JSONToTable(check.jobs)

				for k, v in ipairs(player.GetAll()) do
						if table.HasValue(jobs, v:GetJobCategory()) then
								plyList[#plyList + 1] = v;
						end
				end;
		end

		return plyList;
end;

function OBJs:PendingAdd()
		for i = 1, #OBJs.list do
				if timer.Exists(i .. " - objective start") then
					return true;
				end
		end

		return false;
end;