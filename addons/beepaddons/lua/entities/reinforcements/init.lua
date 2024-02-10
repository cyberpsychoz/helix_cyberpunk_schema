include("shared.lua"); 
AddCSLuaFile("cl_init.lua"); 
AddCSLuaFile("shared.lua");

function ENT:Initialize()
	self:DrawShadow(false);
	self:SetSolid(SOLID_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetCollisionGroup(11)

	self.OBJCalled = false;

	local physObj = self:GetPhysicsObject();
	if (IsValid(physObj)) then
		physObj:EnableMotion(false);
		physObj:Sleep();
	end;
end;

function ENT:Use(act)
	local id = self:GetOBJid();

	if self.SpawnCooldown && CurTime() < self.SpawnCooldown then
		return;
	end

	if id == 0 then return end;
	local objective = OBJs:Check(id);
	if !objective || self.OBJCalled then 
		act:NOTIFY("You can't call new reinforcements right now.", "err")
		return 
	end;

	local jobs = util.JSONToTable(objective.jobs);
	local _jobs = {}
		
	for k, v in ipairs(jobs) do
			if OBJs.jobs[v] then
					for ply, status in pairs(OBJs.jobs[v]) do
							if status == "dead" then
									OBJs.jobs[v][ply] = "alive"
									ply.KIA = false;
									netstream.Start(ply, 'OBJs::DeadHook', false)
									user:SendSound("pr/reinf.wav")
									ply:Spawn();
									self.OBJCalled = true;
							end;
					end 
			end
	end

	if self.OBJCalled then
			self:EmitSound("pr/call_reinforcements_"..math.random(1, 2) .. ".wav")
			local amount = OBJs:PlayersOnTask(act.objectiveID);
			for k, v in ipairs(amount) do
					netstream.Start(v, 'OBJs::SyncDeathCount', #amount)
			end
	end

	self.SpawnCooldown = CurTime() + 5;

end;