// File with database info.

local query = sql.Query;

function TERMINAL:CreateDatabase()
	query([[
		CREATE TABLE IF NOT EXISTS 
		terminal_reports(
		`id` INTEGER NOT NULL, 
		`info` TEXT NOT NULL, 
		PRIMARY KEY (`id`)
		);
		CREATE TABLE IF NOT EXISTS
	 	terminal_list(
		`id` INTEGER NOT NULL, 
		`username` TEXT, 
		`password` TEXT, 
		`logs` TEXT, 
		`history` TEXT, 
		`position` TEXT, 
		`angles` TEXT, 
		`turned` INTEGER,
		`sensor` INTEGER,
		`memory` TEXT,
		`maxMemory` INTEGER,
		`memAmount` INTEGER, 
		`map` TEXT,
		PRIMARY KEY (`id`)
		);
		CREATE TABLE IF NOT EXISTS
		sensors_list(
		`id` INTEGER NOT NULL,
		`group` INTEGER,
		`position` TEXT, 
		`angles` TEXT, 
		`logs` TEXT,
		`map` TEXT,
		PRIMARY KEY (`id`)
		);
		CREATE TABLE IF NOT EXISTS
		wanted_list(
			`id` INTEGER NOT NULL,
			`reason` TEXT,
			PRIMARY KEY (`id`)
		);
		CREATE TABLE IF NOT EXISTS
		sensors_groups(
			`id` INTEGER NOT NULL,
			`logs` TEXT,
			PRIMARY KEY (`id`)
		);
	]])

end;

function TERMINAL:SaveData(tbl, array, checkStr)
	if array && checkStr then
		if self:DB_available(tbl, "id", checkStr) then
			query( FormUpdateQuery(tbl, array) )
		else
			query( FormInsertQuery(tbl, array) )
		end;
	end;
end;

function FormInsertQuery(tbl, array)
	local indexes, values, index = "", "", 1;
	for k, v in pairs(array) do
		indexes = indexes .. "`" .. k .. "`" .. (index != table.Count(array) && ", " || "")
		values = values .. "'" .. ((isbool(v) && (v && 1 || 0)) or v) .. "'" .. (index != table.Count(array) && ", " || "")
		index = index + 1;
	end
	return "INSERT INTO " .. tbl .. "(" .. indexes .. ") values(" .. values .. ");";
end;

function FormUpdateQuery(tbl, array)
	local update, index = "", 1;
	local id = array.id
	for k, v in pairs(array) do
		update = update .. "`" .. k .. "` = '" .. ((isbool(v) && (v && 1 || 0)) or v) .. "'" .. (index != table.Count(array) && ", " || "")
		index = index + 1;
	end;

	return "UPDATE " .. tbl .. " SET " .. update .. " where id = " .. id .. ";"
end;

function TERMINAL:LoadData()
	local terminals = self:DB_getall('terminal_list')
	local sensors = self:DB_getall('sensors_list')
	local wanted = self:DB_getall('wanted_list')

	if terminals then
		for k, v in pairs(terminals) do
			if v.map == game.GetMap() then
				local entity = ents.Create('terminal');
				entity:SetPos(util.StringToType(v.position, "Vector"))
				entity:SetAngles(util.StringToType(v.angles, "Angle"))
				entity:SetState(tobool(v.turned))
				entity:SetIndex(v.id)
				self.terminals[v.id] = {
					username = v.username,
					password = v.password,
					logs = util.JSONToTable(v.logs),
					history = util.JSONToTable(v.history),
					sensor = v.sensor
				}
				entity.MemoryAmount 	= tonumber(v.memAmount)
				entity.MaxMemory		= tonumber(v.maxMemory)
				entity.Memory 			= util.JSONToTable(v.memory)
				entity:Spawn();
				if tobool(v.turned) then
					entity:TurnOn()
				end
				entity:Activate();
			end
		end;
	end;

	if sensors then
		for k, v in pairs(sensors) do
			if v.map == game.GetMap() then
				local entity = ents.Create('sensor');
				entity:SetPos(util.StringToType(v.position, "Vector"))
				entity:SetAngles(util.StringToType(v.angles, "Angle"))
				entity:SetIndex(v.id)
				entity:SetGroupIndex(v.group)
				if !v.group or v.group == "" then
					self.sensors[v.id] = util.JSONToTable(v.logs);
				elseif v.group != "" then
					local found = self:DB_available('sensors_groups', "id", v.group);
					self.sensors[v.id] = {};
					self.sensorsGroups[v.group] = (found.logs && util.JSONToTable(found.logs)) or {}
				end

				entity:Spawn();
				entity:Activate();
			end
		end;
	end;

	if wanted then
		for k, v in pairs(wanted) do
			self.wanted[v.uniqueID] = v.reason;
		end
	end
end;

function TERMINAL:SaveAll()
	local BUFFER, terminals, sensors 
	= {}, self.terminals, self.sensors

	for k, v in pairs( ents.FindByClass("terminal") ) do
		BUFFER = {
			id 				= v:GetIndex(),
			username 		= terminals[v:GetIndex()].username,
			password 		= terminals[v:GetIndex()].password,
			history 		= util.TableToJSON(terminals[v:GetIndex()].history),
			logs 			= util.TableToJSON(terminals[v:GetIndex()].logs),
			sensor 			= terminals[v:GetIndex()].sensor,
			position		= tostring(v:GetPos()),
			angles			= tostring(v:GetAngles()),
			turned			= v:GetState(),
			memory			= util.TableToJSON(v.Memory),
			maxMemory		= v.MaxMemory,
			memAmount		= v.MemoryAmount,
			map 			= game.GetMap()
		};
		self:SaveData("terminal_list", BUFFER, BUFFER.id)
	end;
	BUFFER = {};
	for k, v in pairs( ents.FindByClass("sensor") ) do
		BUFFER = {
			id 				= v:GetIndex(),
			logs 			= util.TableToJSON(sensors[v:GetIndex()]),
			position		= tostring(v:GetPos()),
			angles			= tostring(v:GetAngles()),
			group			= v:GetGroupIndex(),
			map 			= game.GetMap()
		};
		self:SaveData("sensors_list", BUFFER, BUFFER.id)
	end;
	BUFFER = {}
	for k, v in pairs( self.sensorsGroups ) do
		BUFFER = {
			id 				= k,
			logs 			= util.TableToJSON(v)
		}
		self:SaveData("sensors_groups", BUFFER, BUFFER.id)
	end;
	BUFFER = {}
	for k, v in pairs( self.wanted ) do
		BUFFER = {
			id 				= k,
			reason 			= v
		}
		self:SaveData("sensors_groups", BUFFER, BUFFER.id)
	end
end;

function TERMINAL:CheckData()
	local terminals = self:DB_getall('terminal_list')
	local sensors = self:DB_getall('sensors_list')
	local wanted = self:DB_getall('wanted_list')

	if terminals then
		for k, v in pairs(terminals) do
			if !self.terminals[v.uniqueID] && v.map == game.GetMap() then
				query("DELETE FROM terminal_list WHERE `uniqueID` = '"..v.id.."'")
			end
		end
	end;

	if sensors then
		for k, v in pairs(sensors) do
			if !self.sensors[v.uniqueID] && v.map == game.GetMap() then
				query("DELETE FROM sensors_list WHERE `uniqueID` = '"..v.id.."'")
			end
		end
	end;

	if wanted then
		for k, v in pairs(wanted) do
			if !self.wanted[v.uniqueID] then
				query("DELETE FROM wanted_list WHERE `uniqueID` = '"..v.id.."'")
			end
		end
	end;
end;

function TERMINAL:DB_getall(what)
	return query('SELECT * FROM '..what);
end;

function TERMINAL:DB_available(what, searchFor, index)
	return query("SELECT * FROM "..what.." WHERE "..searchFor.." = '"..index.."'");
end;