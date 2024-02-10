include("shared.lua"); 
AddCSLuaFile("cl_init.lua"); 
AddCSLuaFile("shared.lua");

function ENT:Initialize()
	self:SetModel("models/slasherin/last year/props/retro-pack/sm_slideprojector_01c.mdl")
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
		self:SetIndex(os.time() + math.random(100, 1000))
	end;
	
	local findTerminal = TERMINAL.terminals[self:GetIndex()];
	
	if !findTerminal then
		TERMINAL.terminals[self:GetIndex()] = {
			username = "",
			password = "",
			logs = {},
			history = {},
			sensor = ""
		}
	end;
	
	self:SetFirstTime(TERMINAL.terminals[self:GetIndex()]['username'] == "" && TERMINAL.terminals[self:GetIndex()]['password'] == "")
	self:SetLogin(false);
	self:SetUsed(false)

	// memory cards:
	self.MemoryAmount 	= self.MemoryAmount or 0;
	self.MaxMemory		= self.MaxMemory or 0;
	self.Memory 		= self.Memory or {};
	self:SetMemoryCard(self.MaxMemory != 0);

	// sensors shared: 
	self:SetSensor(TERMINAL.terminals[self:GetIndex()]['sensor'] != "")

	// details:
	self:SetState(false);
	self:SetNumState(0)

	self.light = ents.Create("light_dynamic")
	self.light:Spawn()
	self.light:Activate()
	self.light:SetPos( self:GetPos() + (self:GetUp() * 50) + (self:GetForward() * -20) + (self:GetRight() * 0) )
	self.light:SetKeyValue("distance", 0)
	self.light:SetKeyValue("brightness", 0.1)
	self.light:SetKeyValue("_light", "255 255 255")
	self.light:Fire("TurnOn")
	self.light:SetParent( self )
			self.LoopingSound = CreateSound(self, "ambient/levels/canals/manhack_machine_loop1.wav")

	for k, v in pairs(ents.FindInBox(self:LocalToWorld(self:OBBMins()), self:LocalToWorld(self:OBBMaxs()))) do
		if (string.find(v:GetClass(), "prop") and v:GetModel() == self:GetDefaultModel()) then
			self:SetPos(v:GetPos());
			self:SetAngles(v:GetAngles());
			SafeRemoveEntity(v);

			return;
		end;
	end;
end;

function ENT:StartTouch(entity)
	local class = entity:GetClass()
	if class == 'memory_card' && self.MemoryAmount == 0 then
		self:EmitSound("physics/plastic/plastic_box_impact_bullet5.wav")
		self.MemoryAmount = entity.MemoryAmount
		self.MaxMemory = entity.MaxMemory
		self.Memory = entity.Memory
		self:SetMemoryCard(true)
		entity:Remove();
	end
end

function ENT:Use(act)
	if !self:GetUsed() then
		if !self:GetState() && !act:KeyDown(IN_SPEED) then
			if !act.terminalNotification or CurTime() >= act.terminalNotification then
				netstream.Start(act, 'terminal:sendNotification'); 
				// function to send notification, if player don't know how to activate the terminal.
				// see response at: cl_init.lua
				act.terminalNotification = CurTime() + 10;
			end;
		end
		if act:KeyDown(IN_SPEED) then
			if !self:GetState() then
				self:TurnOn();
			elseif self:GetState() then
				self:TurnOff();
			end;
			return;
		end;		
		if self:GetState() then
			act:SetNWEntity("Terminal", self)
			timer.Simple((!self.alreadyOpened && 0.51 or 0), function() 
				netstream.Start( act, "terminal:interface" )
				self:SetUsed(true);
				self.alreadyOpened = true
			end);
		end;
	end;
end;

function ENT:OnRemove()
	TERMINAL.terminals[self:GetIndex()] = nil;
	if self.LoopingSound then
		self.LoopingSound:Stop();
	end;
end;

function ENT:TurnOn()
	local uniqueID = "terminal:initiate_details" .. self:EntIndex()
	if timer.Exists(uniqueID) || self:GetState() then return end;
	self:EmitSound("buttons/button7.wav")

	timer.Create(uniqueID, 0.65, 4, function() -- 0.35
		if !timer.Exists(uniqueID) or !self:IsValid() then timer.Remove(uniqueID) return; end;
		local numState = self:GetNumState()
		self:SetNumState(numState + 1)
		if numState == 1 then
			self.light:SetKeyValue("_light", "100 100 255")
			self.light:SetKeyValue("distance", 200)
		end
		if numState == 2 then			
			self:EmitSound("buttons/button19.wav")
			self.light:SetKeyValue("_light", "255 190 190")
			self.light:SetKeyValue("distance", 100)
		end
		if numState == 3 then			
			self:EmitSound("buttons/lightswitch2.wav")
			self.LoopingSound:Play();
			self:SetState(true);
			self.light:SetKeyValue("_light", "200 255 200")
			self.light:SetKeyValue("distance", 100)
		end
	end);
end;

function ENT:TurnOff()
	self:SetState(false);
	self:SetNumState(0);
	self:EmitSound("buttons/button16.wav")
	self.light:SetKeyValue("distance", 0)
	self.LoopingSound:Stop();
end

-- lua_run for k, v in pairs( ents.FindByClass('terminal') ) do v:SetFirstTime(false) end
