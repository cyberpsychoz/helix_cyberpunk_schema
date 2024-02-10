
netstream.Hook('OBJs::ReceiveRender', function(collection)
		collection = util.JSONToTable(collection);

		OBJs.list = collection;

		if OBJs.interface && OBJs.interface:IsValid() then
				OBJs.interface:RefreshInfo()
		end
end);

netstream.Hook('OBJs::CreateClientsideTimer', function(id)
		OBJs.bufferedID = id;
		NOT_10_SEC = false;

		timer.Create("objStart - " .. id, OBJs.timeToGetMsg, 1, function() 
				surface.PlaySound("pr/new_obj.wav")
			if OBJs.soundPlaying && OBJs.soundPlaying:IsValid() then
					OBJs.soundPlaying:Stop()
			end
			sound.PlayFile( "sound/pr/obj_music.mp3", "noblock", function( station, errCode, errStr )
						if ( IsValid( station ) ) then
								station:Play()
								station:EnableLooping( true )
								OBJs.soundPlaying = station;
						end
			end )
				
		end)
end);

netstream.Hook('OBJs::receiveSound', function(str)
		surface.PlaySound(str)
end);

netstream.Hook('OBJs::ClearObjective', function(id)
		OBJs.task = {};
		KIA = false

		-- if OBJs.soundPlaying:IsValid() then
		-- 	OBJs.soundPlaying:Stop()
		-- end
		
		local uniqueID = "Time: "..id
		if timer.Exists(uniqueID) then
				timer.Remove(uniqueID)
		end
end);

netstream.Hook('OBJs::ReceiveObjective', function(data, noUpdate, id)
		OBJs.task = data;

		local options = util.JSONToTable(OBJs:Quest().options)
		local uniqueID = "Time: "..id
		
		surface.PlaySound("pr/receiveing_new_obj.wav")
		if !timer.Exists(uniqueID) && options.time then
				timer.Create(uniqueID, 1, options.time, function()
						if !timer.Exists(uniqueID) || !OBJs:Quest()["Name"] then 
							timer.Remove(uniqueID)
							return 
						end;
				end)
		end;

		if !noUpdate then
				surface.PlaySound("pr/new_obj.wav")
				OBJs:NOTIFY("New Objective: ".. OBJs:Quest()["Name"], "notify")
		end;
end);

netstream.Hook('OBJs::Notify', function(message, type)
		OBJs:NOTIFY(message, type)
end);

netstream.Hook('OBJs::DeadHook', function(what)
		KIA = what;
end);

netstream.Hook('catpureUpdate', function()
		DrawBars = true

		surface.PlaySound("pr/cap_tick.wav")
end);

netstream.Hook('OBJs::SupressMsg', function(whois, text)
		if KIA then
			chat.AddText(Color(150, 150, 150), "[DEAD] "..whois..": ", Color(255, 255, 255), text);
		end;
end);

netstream.Hook('OBJs::SyncDeathCount', function(amount)
		ALIVEAMOUNT = amount;
end);