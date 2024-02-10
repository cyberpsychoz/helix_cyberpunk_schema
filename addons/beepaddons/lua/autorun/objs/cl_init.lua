if SERVER then return end;

hook.Add( "RenderScreenspaceEffects", "OBJs::RenderKIA", function()
		local ply = LocalPlayer()
		
		if ply && KIA then
			ColorModify = {}
			ColorModify["$pp_colour_brightness"] = 0;
			ColorModify["$pp_colour_contrast"] = 1;
			ColorModify["$pp_colour_colour"] = 0.3
			ColorModify["$pp_colour_addr"] = 0;
			ColorModify["$pp_colour_addg"] = 0;
			ColorModify["$pp_colour_addb"] = 0;
			ColorModify["$pp_colour_mulr"] = 0;
			ColorModify["$pp_colour_mulg"] = 0;
			ColorModify["$pp_colour_mulb"] = 0;

			DrawColorModify(ColorModify);
		end
end)

local alpha = 0;
StartedCapture = false;
hook.Add("HUDPaint", "OBJs::HudPaint", function() 
		local sw, sh = ScrW(), ScrH()
		local ply = LocalPlayer()

		if ply && KIA then
				draw.SimpleText( "You're killed in action.", "FONT_bold", sw * 0.42, sh * 0.2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
				draw.SimpleText( "Wait until the task ends or removed.", "FONT_regular", sw * 0.42, sh * 0.23, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end

		if OBJs.bufferedID && timer.Exists("objStart - " .. OBJs.bufferedID) then
				local str = "Receiving mission: " .. math.Round(timer.TimeLeft("objStart - " .. OBJs.bufferedID));
				surface.SetFont("FONT_bold")
				local w, h = surface.GetTextSize( str );
				surface.SetDrawColor(70, 70, 70, 150)
  	  	surface.DrawRect(sw * 0.41, sh * 0.15, sw * 0.17, h)
				draw.SimpleText( str, "FONT_bold", sw * 0.432, sh * 0.15, Color(135, 116, 151), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end

		local task = OBJs:Quest();
		local	capture = task.capture;
		if !task.options then return end;
		local opts = util.JSONToTable(task.options)

		if task then
				if input.IsKeyDown( KEY_LALT ) && timer.RepsLeft("Time: "..task.id) then
						draw.SimpleText(FormatTime(timer.RepsLeft("Time: "..task.id) - 1), "FONT_ALT", sw * 0.42, sh * 0.02, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						draw.SimpleText("Alive: " .. ALIVEAMOUNT, "FONT_ALT", sw * 0.5845, sh * 0.02, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
		end

		if !DrawBars || !capture && !opts["Point Amount"] then return end;
		
		if capture && capture != opts["Point Amount"] then
			surface.SetDrawColor(0, 0, 0, alpha)
  	  surface.DrawRect(sw * 0.478 - (opts["Point Amount"] * 0.5), sh * 0.05, opts["Point Amount"] * 2.55, 10)
			surface.SetDrawColor(255, 255, 255, alpha)
			surface.DrawRect(sw * 0.48 - (opts["Point Amount"] * 0.5), sh * 0.053, capture * 2.5, 4.5)
			timer.Simple(1, function()
					if task.capture == OBJs:Quest().capture then
							alpha = math.Approach(alpha, 0, FrameTime() * 700)
							if task.npcCaptureContest && task.npcCaptureContest > 0 && NotifiedContest then
								surface.PlaySound("pr/cap_exit_cont.wav")
								NotifiedContest = false;
							else
								if StartedCapture then
									surface.PlaySound("pr/cap_exit.wav")
									StartedCapture = false
								end	
							end
					else
							alpha = math.Approach(alpha, 150, FrameTime() * 700)		
											
							if task.npcCaptureContest && task.npcCaptureContest > 0 && !NotifiedContest then
								surface.PlaySound("pr/capture_enter_con.wav")
								NotifiedContest = true;
							else
								if !StartedCapture then
									surface.PlaySound("pr/cap_enter.wav")
									StartedCapture = true
								end	
							end
					end
			end)
		end;

end);

hook.Add( "PostDrawTranslucentRenderables", "objectives::drawTextObjective", function()
		local sw, sh = ScrW(), ScrH()
		local ply = LocalPlayer()
		local plyPos, trace = ply:GetPos(), ply:GetEyeTraceNoCursor()
		local task = OBJs:Quest();

		if task && task["Name"] then
				local typeExists = OBJs:ExistsType(task.type)
				local pos;
				if typeExists.entity then
						if !IsValid(Entity(task.Hit)) then return end;
						pos = Entity(task.Hit):GetPos();
				else
						pos = task.Hit;
				end
				local options = util.JSONToTable(task.options)

				cam.Start2D()
					OBJs:DrawTitles(pos, task["Name"])
					if task.id && timer.Exists("Time: "..task.id) then
							OBJs:DrawTime(pos + Vector(0, 0, 100), timer.RepsLeft("Time: "..task.id) - 1)
					end
				cam.End2D()
		end

		if #OBJs.list == 0 || !OBJs:ToolValidation() then return end;

		if (ply:IsAdmin() || ply:IsSuperAdmin()) then
			for k, v in ipairs(OBJs.list) do
				v = util.JSONToTable(v)
				local typeExists = OBJs:ExistsType(v.type)
					local pos;
					if typeExists.entity then
						if !IsValid(Entity(v.Hit)) then return end;
						pos = Entity(v.Hit):GetPos();
					else
						pos = v.Hit;
					end
					if IsEntity(v.Hit) && !Entity(v.Hit):IsValid() then return end;
					local options = util.JSONToTable(v.options)

					cam.Start2D()
						OBJs:DrawTitles(pos, v["Name"])
					cam.End2D()
					OBJs:DrawRadius(pos, options["Radius"])
				end
		end
end)

hook.Add( "PreDrawHalos", "objectives::drawHalo", function()
		local ply = LocalPlayer()
		local plyPos, trace = ply:GetPos(), ply:GetEyeTraceNoCursor()
		local sw, sh = ScrW(), ScrH()

		if OBJs:Quest()['Name'] then 
			local typeExists = OBJs:ExistsType(OBJs:Quest().type)
		
			if typeExists.entity then
					halo.Add({Entity(OBJs:Quest().Hit)}, Color(255, 100, 100), 1, 1, 1, true, false )
			end
		end;
		
		if #OBJs.list == 0 && !OBJs:ToolValidation() then return end;

		for k, v in pairs(OBJs.list) do
			v = util.JSONToTable(v)
			local typeExists = OBJs:ExistsType(v.type)
			local obj;
			if typeExists.entity then
				if Entity(v.Hit) != NULL && Entity(v.Hit):EntIndex() == v.Hit then
						halo.Add({Entity(v.Hit)}, Color(255, 100, 100), 1, 1, 6, true, false )
				end;
			else
				return;
			end
		end;
end )