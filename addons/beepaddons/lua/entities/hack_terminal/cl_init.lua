include("shared.lua");

function ENT:Draw()
	self:DrawModel();
end;

local alpha = 150;
local sw, sh = ScrW(), ScrH()
hook.Add("HUDPaint", "OBJs::TerminalHUDPaint", function() 
		local ply = LocalPlayer()

		if !malwareInstall then return end;
		
		surface.SetDrawColor(0, 0, 0, alpha)
  	surface.DrawRect(sw * 0.478 - (100 * 0.5), sh * 0.9, 100 * 2.57, 10)
		surface.SetDrawColor(189, 136, 22, alpha)
		surface.DrawRect(sw * 0.48 - (100 * 0.5), sh * 0.903, malwareInstall * 2.5, 5)

		timer.Simple(1, function()
				if !malwareInstall || malwareInstall == 0 || malwareInstall == 100 then
						alpha = math.Approach(alpha, 0, FrameTime() * 700)
				else
						alpha = math.Approach(alpha, 150, FrameTime() * 700)
				end
		end)
end);

hook.Add("PlayerButtonDown", "OBJs::KeyDownHack", function(user, key)
    if (key == KEY_E) then
			local trace = user:GetEyeTraceNoCursor()
			local quest = OBJs:Quest()
			local entity = trace.Entity;
			local uniqueID = "term: "..entity:EntIndex()
			if entity:GetClass() != "hack_terminal" then return end;
			if !quest["Name"] || OBJs.bufferedID != entity:GetOBJid() then return end;
			local increment = entity:GetMalwared() && 25 || 10;
			local distance = LocalPlayer():GetPos():Distance(entity:GetPos())
			if TerminalHackCooldown && CurTime() <= TerminalHackCooldown then
				return
			end;
			if distance > 64 then return end;

      timer.Create(uniqueID, 1, 0, function()
					local trace = user:GetEyeTraceNoCursor()
					local entity = trace.Entity;
					local distance = LocalPlayer():GetPos():Distance(entity:GetPos())

					if entity:GetClass() != "hack_terminal" || distance > 64 then 
						malwareInstall = 0;
						timer.Remove(uniqueID) 
						return 
					end;
					if !malwareInstall || malwareInstall == 0 then 
						print(entity:GetMalwared())
						if !entity:GetMalwared() then
							netstream.Start('OBJs::terminalPreHacking', entity:EntIndex())
						end;
						malwareInstall = 0; 
					end;
					malwareInstall = math.Clamp(malwareInstall + increment, 0, 100)

					if malwareInstall == 100 then
							netstream.Start('OBJs::terminalHacked', entity:EntIndex(), OBJs.bufferedID)
							malwareInstall = nil;

							TerminalHackCooldown = CurTime() + 2;
					end
			end)
    end
end)

hook.Add("PlayerButtonUp", "OBJs::KeyUPHack", function(user, key)
	if (key == KEY_E) then
			local trace = user:GetEyeTraceNoCursor()
			local quest = OBJs:Quest()
			local entity = trace.Entity;
			local uniqueID = "term: "..entity:EntIndex()
			if entity:GetClass() != "hack_terminal" then return end
			if !quest["Name"] || OBJs.bufferedID != entity:GetOBJid() then return end;
			local distance = LocalPlayer():GetPos():Distance(entity:GetPos())
			-- if distance > 64 then return end;

      if (timer.Exists(uniqueID)) then
						timer.Simple(2, function()
							malwareInstall = 0;
						end)
					timer.Remove(uniqueID)
      end
    end
end)