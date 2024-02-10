--[[
		Add a new type of objective to the list;
]]--
function OBJs:CreateType(name, data)
	if !self:ExistsType(name) then
			self.types[name] = data;
			self.types[name].options = util.TableToJSON(self.types[name].options or {})
	end;
end;

--[[
		Check if type exists
]]--
function OBJs:ExistsType(name)
		return self.types[name]
end

function OBJs:NOTIFY(message, type)
	local clr = Color(204, 185, 18);
	if type == "err" then
		clr = Color(255, 100, 100)
		surface.PlaySound("buttons/button10.wav")
	elseif type == "notify" then
		clr = Color(100, 100, 255)
		surface.PlaySound("buttons/blip1.wav")
	elseif type == "success" then
		clr = Color(100, 255, 100)
		surface.PlaySound("buttons/combine_button1.wav")
	elseif type == "missionfail" then
			LocalPlayer():ScreenFade( SCREENFADE.OUT, Color(0, 0, 0), 1, 4 )
			timer.Simple(4, function()
					LocalPlayer():ScreenFade( SCREENFADE.IN, Color(0, 0, 0), 1, 1 )
			end);
	end
	CENTER_NOTIFICATIONS:Send(message, clr, 5)
end
--[[
	Checks if task id exists;
]]--
function OBJs:Check(id)
		return util.JSONToTable(OBJs.list[id])
end;

function OBJs:Quest()
		return isstring(OBJs.task) && util.JSONToTable(OBJs.task) || {}
end;

function OBJs:Regime()
		return OBJs.REGIME;
end;