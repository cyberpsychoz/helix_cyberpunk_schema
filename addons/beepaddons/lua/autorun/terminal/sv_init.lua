if !SERVER then return end
// -- net-s --
local query = sql.Query;

netstream.Hook('terminal:closeInterface', function (client, terminal)
	if client:GetNWEntity("Terminal") then
		TERMINAL:InterfaceCallback(client)
		client:SetNWEntity("Terminal", nil)
	end;
end)

netstream.Hook('terminal::updateHistory', function (client, cmd, id)
	local _terminal = TERMINAL:getTerminal(client, id);
	if !_terminal then return; end
	if cmd:len() < 1 || cmd:find("login") then return end;

	TERMINAL:History(id, cmd)
end)

netstream.Hook('terminal:checkAccess', function(client, argument, argAmount)
	local login, password = TERMINAL:CheckArgument(argument, argAmount);
	if !login then return end;

	TERMINAL:CheckAccess(client, login, password)
end)

netstream.Hook('terminal:logUP', function(client, text, color, prefix, id)
	local _terminal, tCheck = TERMINAL:getTerminal(client, id);
	if !_terminal then return; end

	TERMINAL:Log(text, color, prefix, tCheck:GetIndex())
end);

netstream.Hook('terminal:changePassword', function(client, argument, argAmount, id)
	local _terminal = TERMINAL:getTerminal(client, id);
	local oldPassword, newPassword = TERMINAL:CheckArgument(argument, argAmount);
	if !_terminal || !oldPassword then return; end

	TERMINAL:ChangePassword(client, oldPassword, newPassword)
end);

netstream.Hook('terminal::MESSAGES', function(client, operation, argument, argAmount, id)
	local _terminal = TERMINAL:getTerminal(client, id);
	local pcID, msg = TERMINAL:CheckArgument(argument, argAmount);
	if !_terminal || !pcID then return; end

	if operation == "pm" then
		if pcID && msg then
			if TERMINAL:Find(pcID) && pcID != id then
				TERMINAL:Log(id.." >> "..msg, Color(100, 255, 100), "MESSAGE FROM", pcID)
				TERMINAL:AddAnwser(client, id.." to "..pcID..": "..msg, Color(100, 255, 100), "[PM]", nil, "", true)
				TERMINAL:AddAnwser(client, "Сообщение отправлено на компьютер #"..pcID, Color(100, 255, 100))
			else
				TERMINAL:AddAnwser(client, "Компьютер не найден!", Color(255, 100, 100))
			end
		else
			TERMINAL:AddAnwser(client, "Формат команды: <id message>", Color(255, 100, 100))
		end;
	elseif operation == "transmit" then
		TERMINAL:AddAnwser(client, "Сообщение протранслировано!", Color(255, 50, 50), "")
		// pcID here is a message!
		for k, v in pairs(TERMINAL.terminals) do
			TERMINAL:Log(pcID, Color(255, 50, 50), "MESSAGE TRANSMISSION:", k)
		end
	end
end);

netstream.Hook('terminal::reportSuspect', function(client, argument, argAmount, id)
	local _terminal, tCheck = TERMINAL:getTerminal(client, id);
	argument = TERMINAL:CheckArgument(argument, argAmount);
	if !_terminal || !argument then return; end
	local uniqueID = "terminal:inform_" .. tCheck:EntIndex()

	if !timer.Exists(uniqueID) then
		for k, v in pairs( team.GetPlayers( TEAM_CITIZEN ) ) do // Police team goes here!
			netstream.Start(v, 'terminal:Inform', "<СООБЩЕНИЕ О ПОДОЗРЕНИИ ОТ #" .. id .. ">: " .. argument)
		end

		TERMINAL.SUSPECT = "<СООБЩЕНИЕ О ПОДОЗРЕНИИ ОТ #" .. id .. ">: " .. argument;
		query("INSERT INTO terminal_reports( `id`, `info` ) VALUES( NULL, '"..argument.."' )");

		timer.Create(uniqueID, 30, 1, function()
			if !timer.Exists(uniqueID) or !tCheck:IsValid() then timer.Remove(uniqueID) return; end;
			timer.Remove(uniqueID);
		end);
	else
		TERMINAL:AddAnwser(client, "Вы не можете отправлять отчеты в течении "..math.Round(timer.TimeLeft(uniqueID)) .. " секунд.", nil, "", true)
	end;
end);

netstream.Hook('terminal::checkSuspect', function(client, id)
	local _terminal = TERMINAL:getTerminal(client, id);
	if !_terminal then return; end

	TERMINAL:AddAnwser(client, TERMINAL.SUSPECT, Color(255, 200, 200), "", true)
end);

netstream.Hook('terminal:registerSensor', function(client, argument, argAmount, id)
	local _terminal, tCheck = TERMINAL:getTerminal(client, id);
	argument = TERMINAL:CheckArgument(argument, argAmount);
	if !_terminal || !argument then return; end

	if TERMINAL.sensors[argument] then
		TERMINAL:AddAnwser(client, "Сенсор: #" .. argument .." подключена.", Color(100, 255, 100), "", true)
		TERMINAL:InstallSensor(tCheck:GetIndex(), argument)
		tCheck:SetSensor(true)
	elseif TERMINAL.sensorsGroups[argument] then
		TERMINAL:AddAnwser(client, "Группа сенсоров #" .. argument .." подключена.", Color(100, 255, 100), "", true)
		TERMINAL:InstallSensor(tCheck:GetIndex(), argument)
		tCheck:SetSensor(true)
	else
		TERMINAL:AddAnwser(client, argument.." not found.", Color(255, 50, 50), "")
	end
end);

netstream.Hook('terminal:getSensorLogs', function(client, id)
	local _terminal, tCheck = TERMINAL:getTerminal(client, id);
	if !_terminal then return; end

	local index = 1;
	local sens = TERMINAL.terminals[tCheck:GetIndex()]['sensor']
	if sens != "" && (TERMINAL.sensors[sens] or TERMINAL.sensorsGroups[sens]) then
		TERMINAL:AddAnwser(client, "*** SENSOR/GROUP [".. sens .."] LOGS: ***", nil, "", true)
		for k, v in pairs(TERMINAL.sensors[sens] or TERMINAL.sensorsGroups[sens]) do
			TERMINAL:AddAnwser(client, "[" .. index .. "] " .. v['text'], nil, "", true)
			index = index + 1
		end
	end
end);

netstream.Hook('terminal::formSensorGroup', function(client, group, name)
	if client:IsAdmin() && table.Count(group) > 1 && name:gmatch("[%d]+")() then
		for uniqueID, entity in pairs(group) do
			if entity:IsValid() && entity:GetClass() == 'sensor' && !entity:GetGrouped() && entity:GetIndex() == uniqueID then
				TERMINAL.sensorsGroups[name] 	= {};
				TERMINAL.sensors[uniqueID] 	= {};
				for k, v in pairs(TERMINAL.terminals) do
					if v.sensor == entity:GetIndex() then
						TERMINAL.terminals[k]['sensor'] = name;
					end
				end
				entity:SetGroupIndex(name);
				entity:SetGrouped(true);
			end
		end
	end
end);

netstream.Hook('terminal::Memory', function(client, operation, id)
	local _terminal, tCheck = TERMINAL:getTerminal(client, id);
	if !_terminal then return; end

		if tCheck.MemoryAmount > 0 then
			if operation == "take" then
				local entity = ents.Create('memory_card');
				entity:SetPos(tCheck:GetPos() + (tCheck:GetForward() * -100))
				entity:Spawn();
				entity:Activate();
				entity.MemoryAmount = tCheck.MemoryAmount;
				entity.MemoryAmount = tCheck.MaxMemory;
				entity.Memory 		= tCheck.Memory;
				tCheck.MemoryAmount 	= 0;
				tCheck.MaxMemory		= 0;
				tCheck.Memory 			= {};
				tCheck:EmitSound("physics/plastic/plastic_box_impact_bullet5.wav")
				tCheck:SetMemoryCard(false)
				TERMINAL:AddAnwser(client, "Заберите карту памяти.", Color(50, 50, 255), "[MEMORY]", true)
			elseif operation == "active" then
				TERMINAL:AddAnwser(client, "Инициирована последовательность активации памяти...", Color(50, 50, 255), "[MEMORY]", true)
				local memory = tCheck.MemoryAmount;
				local index = 1;
				for k, v in pairs(TERMINAL.terminals[tCheck:GetIndex()]['logs']) do
					local text = v.text
					memory = math.max(memory-string.len(text)/2, 0)
					if memory > 0 then
						table.insert(tCheck.Memory, "["..index.."] "..text:sub(1, memory));
						index = index + 1;
					else 
						return;
					end;
				end
				TERMINAL:AddAnwser(client, "Последовательность активации памяти завершена! Готов к продолжению...", Color(50, 50, 255), "[MEMORY]", true)
			elseif operation == "clean" then
				TERMINAL:AddAnwser(client, "Инициирована последовательность стирания памяти...", Color(50, 50, 255), "[MEMORY]", true)
				tCheck.Memory = {};
				tCheck.MemoryAmount 	= tCheck.MaxMemory
			elseif operation == "read" then
				TERMINAL:AddAnwser(client, "Инициируется последовательность считывания данных из памяти...", Color(50, 50, 255), "[MEMORY]", true)
				TERMINAL:AddAnwser(client, "*** ЗАПУСК ЖУРНАЛА ПАМЯТИ ***", Color(50, 50, 255), "", false)
				for k, v in pairs(tCheck.Memory) do
					TERMINAL:AddAnwser(client, v, nil, "", false)
				end
				TERMINAL:AddAnwser(client, "*** ЗАВЕРШЕНИЕ ЗАПИСИ В ЖУРНАЛ ПАМЯТИ ***", Color(50, 50, 255), "", false)
			elseif operation == "readSensors" then
				TERMINAL:AddAnwser(client, "Инициирована последовательность активации журнала датчиков памяти...", Color(50, 50, 255), "[MEMORY]", true)
				local memory = tCheck.MemoryAmount;
				local sensorID = TERMINAL.terminals[tCheck:GetIndex()]['sensor'];

				if sensorID != "" && (TERMINAL.sensors[sensorID] || TERMINAL.sensorsGroups[sensorID]) then
					local sensor = (TERMINAL.sensors[sensorID] || TERMINAL.sensorsGroups[sensorID]);
					for k, v in pairs(sensor) do
						memory = math.max(memory-string.len((v && v.text) or v)/2, 0)
						if memory > 0 then
							table.insert(tCheck.Memory, ((v && v.text) or v):sub(1, memory));
						else 
							return;
						end;
					end
				else 
					TERMINAL:AddAnwser(client, "Действительный датчик не найден...", Color(50, 50, 255), "[MEMORY]", true)
				end

				TERMINAL:AddAnwser(client, "Последовательность активации журнала датчиков памяти завершена! Готов к продолжению...", Color(50, 50, 255), "[MEMORY]", true)
			end;
		else 
			TERMINAL:AddAnwser(client, "Карта памяти не найдена или недостаточно памяти.", Color(50, 50, 255), "[MEMORY]", true)
		end;
end);

netstream.Hook('terminal::CheckID', function(client, argument, argAmount, id)
	local _terminal, tCheck = TERMINAL:getTerminal(client, id);
	argument = TERMINAL:CheckArgument(argument, argAmount);
	if !_terminal || !argument then return; end
		print("got here")
		argument = tonumber(argument);
		local ply = {};
		local foundPly = player.GetByID(argument);
		if foundPly:GetNWInt("plyNameID") == argument then
			ply.id = foundPly:GetNWInt("plyNameID");
			ply.steamID = foundPly:SteamID64();
			ply.money = foundPly:GetNWInt("Money");
			ply.whiteList = team.GetName(foundPly.whitelist);
			ply.firstJoin = os.date("%H:%M:%S - %d/%m/%Y", foundPly:GetNWInt("FirstJoin"));
			ply.customName = foundPly:GetNWInt("plyCustomName");
			ply.frags = foundPly:Frags();
			ply.name = foundPly:GetName();
		end

		if ply.id then
			TERMINAL:AddAnwser(client, "*** ОБОЛОЧКА "..ply.name.." STATS ***", nil, "", true)
			for k, v in pairs(ply) do
				TERMINAL:AddAnwser(client, k .. " - " .. v, nil, "", true)
			end
		else 
			TERMINAL:AddAnwser(client, "Оболочка не найдена.", nil, "", true)
		end
end);

netstream.Hook('terminal::WantedList', function(client, argument, argAmount, operation, id)
	local _terminal, tCheck = TERMINAL:getTerminal(client, id);
	local ID, reason = TERMINAL:CheckArgument(argument, argAmount);
	if !_terminal || (!ID && operation != 'check') then 
		return; 
	end

		if operation == "add" then
			local someone = player.GetByID(ID);
			if someone && ID && reason then
				if !TERMINAL.wanted[ID] then
					TERMINAL.wanted[ID] = reason;
					TERMINAL:AddAnwser(client, "Оболочка добавлена в список розыска.", nil, "[WANTED]", true)
				else 
					TERMINAL:AddAnwser(client, "Оболочка уже объявлена в розыск. Причина:"..TERMINAL.wanted[ID], nil, "[WANTED]", true)
				end;
			else
				TERMINAL:AddAnwser(client, "Оболочка не найдена.", nil, "[WANTED]", true)
			end
		elseif operation == "delete" then 
			if TERMINAL.wanted[ID] then
				TERMINAL.wanted[ID] = nil;
				TERMINAL:AddAnwser(client, "Оболочка удалена из списка разыскиваемых.", nil, "[WANTED]", true)
			else
				TERMINAL:AddAnwser(client, "Оболочка не находится в розыске.", nil, "[WANTED]", true)
			end
		elseif operation == "check" then
			TERMINAL:AddAnwser(client, "[WANTED LIST]", nil, "", true)

			for k, v in pairs(TERMINAL.wanted) do
				TERMINAL:AddAnwser(client, "[ID: "..k.."] Причина: "..v, nil, "", true)
			end
		end
end);

// -- net-s --
