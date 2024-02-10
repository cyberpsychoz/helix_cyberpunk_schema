--[[
		Module subaddon by Ross;
		Copyright > 13.06.2021;
]]--

CENTER_NOTIFICATIONS = CENTER_NOTIFICATIONS or {};
CENTER_NOTIFICATIONS.notification = {}

function CENTER_NOTIFICATIONS:Send(text, textClr, time)
		local len = #CENTER_NOTIFICATIONS.notification
		CENTER_NOTIFICATIONS.notification[len + 1] = {
			text = text or "No text?",
			color = textClr && Color(textClr.r, textClr.g, textClr.b, 0) or Color(255, 255, 255, 0),
			time = time or 5,
		}		
end;

local alpha = 0;
local boxAlpha = 0;
local fade = false;
local numNot = 0;

hook.Add("HUDPaint", "CENTER_NOTIFICATIONS::HudPaint", function()
		local len = #CENTER_NOTIFICATIONS.notification
		local sw, sh = ScrW(), ScrH()
		local rectPos = 0.45

		if len > 5 then
			CENTER_NOTIFICATIONS.notification = {}
			return;
		end

		if len > 0 && numNot > 0 then
			if !fade then
				alpha = math.Approach(alpha, 255, FrameTime() * 700)
				boxAlpha = math.Approach(boxAlpha, 150, FrameTime() * 700)
				CENTER_NOTIFICATIONS.notification[numNot]["color"].a = alpha
			elseif fade then 
				alpha = math.Approach(alpha, 0, FrameTime() * 700)
				boxAlpha = math.Approach(boxAlpha, 0, FrameTime() * 700)
				CENTER_NOTIFICATIONS.notification[numNot]["color"].a = alpha
			end
			
			local TEXT = CENTER_NOTIFICATIONS.notification[numNot].text
			surface.SetFont("FONT_bold")
			local w, h = surface.GetTextSize( TEXT );
			surface.SetDrawColor(70, 70, 70, boxAlpha)
			surface.DrawRect(sw * rectPos - (w * 0.29), sh * 0.2, w + (sw * 0.019), h + (sh * 0.005))
			draw.SimpleText( TEXT, "FONT_bold", sw * (rectPos + 0.01) - (w * 0.29), sh * 0.2, CENTER_NOTIFICATIONS.notification[numNot]["color"], TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end

		if len > 0 then
				if !fade && !clear then
						clear = CurTime() + 2
						numNot = #CENTER_NOTIFICATIONS.notification;
				elseif !fade && clear && CurTime() > clear then
						fade = true;
						clear = nil;

						timer.Simple(1, function()
								CENTER_NOTIFICATIONS.notification[len] = nil;
								numNot = #CENTER_NOTIFICATIONS.notification;
								fade = false;
						end)
				end
		end;
end);