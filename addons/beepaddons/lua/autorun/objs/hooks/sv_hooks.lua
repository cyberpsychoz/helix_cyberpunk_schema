netstream.Hook('OBJs::AddObjective', function(user, data, edit)
		if !user:IsAdmin() || !user:IsSuperAdmin() then return end;
		local obj_type = OBJs:ExistsType(data.type)
	
		if obj_type then
			local trace = user:GetEyeTraceNoCursor();
			
			if obj_type.entity && (trace.Entity == NULL || trace.Entity == Entity(0)) then
					user:NOTIFY("You need to choose an entity!", "err")
					return;
			end
			if data.jobs:len() == 2 then
					user:NOTIFY("You need to choose a jobs!", "err")
					return;
			end
			if edit ~= 0 then
					if !OBJs:Check(edit) then
						user:NOTIFY("Can't edit task #"..edit.." !", "err")
						return;
					end
			end
			
			data.Hit = obj_type.entity && trace.Entity:EntIndex() || trace.HitPos
			OBJs:Add(data, edit)

			if edit == 0 then 
				user:NOTIFY("Successfully added a new objective named ".. data.Name ..".", "success")
			else
				user:NOTIFY("Successfully edited an objective #"..edit..".", "success")
				if edit > 0 then
					local info = util.JSONToTable(OBJs.list[edit])
					info["Edited by"] = user:GetName()
					OBJs.list[edit] = util.TableToJSON(info)
				end
			end;
		end;
end);

netstream.Hook('OBJs::StartAction', function(user, action, id)
		if !user:IsAdmin() || !user:IsSuperAdmin() then return end;

		OBJs.actions[action](user, id);
end);

netstream.Hook('OBJs::terminalPreHacking', function(user, index)
		local trace = user:GetEyeTraceNoCursor()
		local entity = trace.Entity;
		local ent = IsEntity(Entity(index)) && Entity(index);
		if ent == NULL then return end;
		if entity:GetClass() != "hack_terminal" then return end;
		local distance = user:GetPos():Distance(entity:GetPos())
		if distance > 64 then return end;

		ent:EmitSound("pr/hacking.wav")
end);

netstream.Hook('OBJs::terminalHacked', function(user, index, id)
		local trace = user:GetEyeTraceNoCursor()
		local entity = trace.Entity;
		local ent = IsEntity(Entity(index)) && Entity(index);
		if ent == NULL then return end;
		if entity:GetClass() != "hack_terminal" then return end;
		if !user:FindInObjective(id) then return end;
		local distance = user:GetPos():Distance(entity:GetPos())
		if distance > 64 then return end;

		entity:SetMalwared(!entity:GetMalwared());
		entity:EmitSound("pr/sd_"..math.random(1,2)..".wav")
		entity.light:SetKeyValue("distance", entity:GetMalwared() && 400 || 0)
		entity.light:SetKeyValue("brightness", entity:GetMalwared() && 2 || 0)
end);