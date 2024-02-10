ENT.Type = "anim";
ENT.Author = "Ross";
ENT.PrintName = "Терминал";
ENT.Spawnable = true;
ENT.AdminSpawnable = true;
ENT.Category = 'Cyberpunk RED Terminals'

function ENT:GetDefaultModel()
	return '';
end;

function ENT:SetupDataTables()
	self:NetworkVar('String', 0, "Index")			// unique ID of every terminal.
	self:NetworkVar('Bool', 0, "Login") 			// to check if this terminal user is authed. Drops to false after every log out;
	self:NetworkVar('Bool', 1, "Used")				// to check if this terminal is in use.
	self:NetworkVar('Bool', 2, "FirstTime")			// to check if needed to create a user.
	self:NetworkVar('Bool', 4, "Sensor")			// to check if sensors is connected.
	self:NetworkVar('Bool', 5, "MemoryCard")			// to check if memory card is inserted.

	// detalization;
	self:NetworkVar("Int", 0, "NumState");
	self:NetworkVar("Bool", 3, "State");
end;