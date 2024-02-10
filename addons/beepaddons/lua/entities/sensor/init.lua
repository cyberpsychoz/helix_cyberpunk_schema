include("shared.lua"); 
AddCSLuaFile("cl_init.lua"); 
AddCSLuaFile("shared.lua");

function ENT:Initialize()
	self:SetModel(self:GetDefaultModel())
	self:DrawShadow(true);
	self:SetSolid(SOLID_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetUseType(SIMPLE_USE);

	local physObj = self:GetPhysicsObject();
	if (IsValid(physObj)) then
		physObj:EnableMotion(false);
		physObj:Sleep();
	end;

	if self:GetIndex() == "" then
		self:SetIndex( os.time() + math.random(100, 1000))
	end;

	self:SetGrouped(self:GetGroupIndex() != "")

	if !TERMINAL.sensors[self:GetIndex()] then
		TERMINAL.sensors[self:GetIndex()] = {};
	end

	for k, v in pairs(ents.FindInBox(self:LocalToWorld(self:OBBMins()), self:LocalToWorld(self:OBBMaxs()))) do
		if (string.find(v:GetClass(), "prop") and v:GetModel() == self:GetDefaultModel()) then
			self:SetPos(v:GetPos());
			self:SetAngles(v:GetAngles());
			SafeRemoveEntity(v);

			return;
		end;
	end;
end;

function ENT:Think()
	local trace = self:SensorTrace()
	local entity = trace.Entity;

	if entity && entity != Entity(0) && entity != NULL then
		local name = entity:GetName();
		local class = entity:GetClass();
		local date = os.date( "%H:%M:%S - %d/%m/%Y", os.time() )
		local action = 
		entity:IsPlayer() && 
		((entity:IsSprinting() && "Running") or (entity:Crouching() && "Crouching") or (entity:GetVelocity().z > 0 && "Jumping") or "Walking") 
		or "Moving"
		self:SensorLog(
			(name:len() > 0 && name) or class .. " " .. entity:GetModel(), 
			date, 
			action
		)
	end
end

function ENT:SensorTrace()
	local tr = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos() + ( self:GetRight() * -150 ),
		filter = self,
	} )

	return tr;
end;

function ENT:SensorLog(name, time, action)
	if !self:GetGrouped() then
		TERMINAL.sensors[self:GetIndex()][name] = {
			text = name .. " | " .. time .. " | " .. action
		}
	else
		TERMINAL.sensorsGroups[self:GetGroupIndex()][name] = {
			text = name .. " | " .. time .. " | " .. action
		}
	end;
end

function ENT:OnRemove()
	local tempIndex = {}
	for k, v in pairs(TERMINAL.terminals) do
		if v.sensor == self:GetIndex() then
			TERMINAL.terminals[k]['sensor'] = "";
			table.insert(tempIndex, k)
		end
	end

	for k, v in pairs( ents.FindByClass("terminal") ) do
		if table.HasValue(tempIndex, v:GetIndex()) then
			v:SetSensor(false)
		end
	end
	TERMINAL.sensors[self:GetIndex()] = nil;
end;