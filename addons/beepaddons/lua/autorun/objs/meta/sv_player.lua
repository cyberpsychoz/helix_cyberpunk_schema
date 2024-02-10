local user = FindMetaTable("Player")

function user:NOTIFY(message, type)
		netstream.Start(self, 'OBJs::Notify', message, type)
end;

function user:SyncObjective(id)
		local collection = OBJs:Check(id)
		if !collection then return end;
		local jobs = util.JSONToTable(collection.jobs)

		if table.HasValue(jobs, self:GetJobCategory()) then
				netstream.Start(self, 'OBJs::ReceiveObjective', OBJs.list[id], true, id)
		end;
end;

function user:FindInObjective(id)
		if !OBJs.list[id] then return false; end;

		return OBJs.jobs[self:GetJobCategory()][self];
end;

function user:SyncList()
		local collection = util.TableToJSON(OBJs.list)
		
		netstream.Start(self, 'OBJs::ReceiveRender', collection)
end;

function user:SendSound(str)
		netstream.Start(self, 'OBJs::receiveSound', str)
end;

if OBJs:Regime() == "debug" then
		function user:GetJobCategory()
				return "Test category"
		end
end;