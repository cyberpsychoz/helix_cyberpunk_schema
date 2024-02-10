include("shared.lua");
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");
local math = math;
local mc = math.Clamp;
local PLUGIN = PLUGIN;

function ENT:Initialize()
	
	self:DrawShadow(true);
	self:SetSolid(SOLID_BBOX);
	self:PhysicsInit(SOLID_BBOX);
	self:SetMoveType(MOVETYPE_NONE);
	self:SetUseType(SIMPLE_USE);

	local physObj = self:GetPhysicsObject();
	if (IsValid(physObj)) then physObj:EnableMotion(false); physObj:Sleep(); end;

	for k, v in pairs(ents.FindInBox(self:LocalToWorld(self:OBBMins()), self:LocalToWorld(self:OBBMaxs()))) do
		if (string.find(v:GetClass(), "prop") and v:GetModel() == model) then
			self:SetPos(v:GetPos());
			self:SetAngles(v:GetAngles());
			SafeRemoveEntity(v);
			return;
		end;
	end;

	-- self.parentPanel = ents.Create('prop_physics')
	-- self.parentPanel:SetModel('models/hunter/plates/plate1x1.mdl')
	-- self.parentPanel:Spawn()
	-- self.parentPanel:SetPos( self:GetPos() )

	-- self:DeleteOnRemove( self.parentPanel )

	-- self:SetParent(self.parentPanel)
	
	self:LoadAllData();
	self:DropToFloor()
end;

function ENT:OnOptionSelected(player, option, data)
	if ( option == "Talk" ) then
		netstream.Start(player, 'DialogueOpen', self:GetDialgoues(), self.informationTable, PLUGIN.QuestList)
	elseif option == "Options" then
		if (player:IsAdmin() or player:IsSuperAdmin()) then
			netstream.Start(player, 'SettingsOpen', self:GetDialgoues(), self.informationTable, PLUGIN.QuestList)
		end;
	end;
end;

function ENT:OnRemove()
	if self.informationTable && PLUGIN.DialoguesList[ tostring(self.informationTable['id']) ] then
		PLUGIN.DialoguesList[ tostring(self.informationTable['id']) ] = nil;
	end;
end;

-- functions
function ENT:LoadAllData()
	if !self.informationTable then
		self.informationTable = {
			name = 'John Doe',
			model = 'models/Humans/Group01/Male_01.mdl',
			sequence = 4,
			skin = 1,
			bodyString = "",
			id = os.time()
		}
	end;
	
	local infotable = self.informationTable;
	self:CreateDialogueLayout(infotable['id'])
	self:SetDefaultName( infotable['name'] );
	self:SetModel( infotable['model'] );
	self:SetSequence( infotable['sequence'] );
	self:SetBodyGroups( infotable['bodyString'] )
end;

function ENT:CreateDialogueLayout(id)
	local tbl = {
		callByDefault = {
			Dialogues = {},
			Anwsers = {}
		},
		Dialogues = {},
		Anwsers = {}
	};

	if self.informationTable && !PLUGIN.DialoguesList[id] then
		PLUGIN.DialoguesList[id] = tbl;
	end;
end;

function ENT:GetDialgoues()
	return PLUGIN.DialoguesList[ tonumber(self:GetDialogueID()) ]
end;

function ENT:GetDialogueID()
	return self.informationTable['id']
end;