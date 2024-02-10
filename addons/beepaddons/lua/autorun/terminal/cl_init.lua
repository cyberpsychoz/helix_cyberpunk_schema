if SERVER then return end;
TERMINAL = TERMINAL or {}

TERMINAL.termHistory = TERMINAL.termHistory or {};
TERMINAL.sensorsList = TERMINAL.sensorsList or {}

hook.Add( "PreDrawHalos", "TERMINAL::drawHalos", function()
	if TERMINAL.sensorsList then
		halo.Add( TERMINAL.sensorsList, Color(255, 100, 100), 1, 1, 6, true, true )
	end;
end )

netstream.Hook("terminal:interface", function()
	local term = TERMINAL:Validate(LocalPlayer());
	if term && term:GetUsed() then return end;
	if !(TERMINAL.interface && TERMINAL.interface:IsValid()) then
		TERMINAL.interface = vgui.Create("Terminal");
		TERMINAL.interface:Populate()
	end;
end)

netstream.Hook('terminal:accessGranted', function(logs, history)
	if (TERMINAL.interface && TERMINAL.interface:IsValid()) then
		TERMINAL.interface:addCMD("Доступ получен!", Color(14, 177, 14), nil, false);
		TERMINAL.termHistory = history;
		for k, v in pairs(logs) do
			TERMINAL.interface:addCMD(v.text, v.color, v.prefix, false);
		end
	end;
end);

netstream.Hook('terminal:AddClientsideAnwser', function(text, color, prefix, noLog)
	if (TERMINAL.interface && TERMINAL.interface:IsValid()) then
		TERMINAL.interface:addCMD(text, color, prefix, tobool(noLog));
	end;
end);

netstream.Hook('terminal:sendNotification', function() // function to send notification, if player don't know how to activate the terminal.
	chat.AddText(Color(155, 155, 226), "Для включения / выключения терминала нажмите <"..input.LookupBinding( "+speed", true ).."+"..input.LookupBinding( "+use", true )..">.\n")
end);

netstream.Hook('terminal:Inform', function(notification)
	chat.AddText(Color(155, 155, 226), notification)
end);

netstream.Hook('terminal::playerDeath', function() 
	if (TERMINAL.interface && TERMINAL.interface:IsValid()) then
		TERMINAL.interface:CloseMe()
	end;
end);