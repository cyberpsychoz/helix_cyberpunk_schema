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
		physObj:EnableMotion(true);
		physObj:Wake();
	end;

	self.MemoryAmount 	= 1024;
	self.MaxMemory		= 1024;
	self.Memory 		= {};

	for k, v in pairs(ents.FindInBox(self:LocalToWorld(self:OBBMins()), self:LocalToWorld(self:OBBMaxs()))) do
		if (string.find(v:GetClass(), "prop") and v:GetModel() == self:GetDefaultModel()) then
			self:SetPos(v:GetPos());
			self:SetAngles(v:GetAngles());
			SafeRemoveEntity(v);

			return;
		end;
	end;
end;

function ENT:Use( act, caller )
	if ( self:IsPlayerHolding() ) then return end
	
	act:PickupObject( self )
end