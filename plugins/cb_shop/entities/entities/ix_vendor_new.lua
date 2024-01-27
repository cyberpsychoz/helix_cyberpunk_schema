local PLUGIN = PLUGIN

--[[
ENT.Type = "anim"
ENT.PrintName = "Vendor Remake"
ENT.Category = "Helix"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.bNoPersist = true
]]

AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName = "Продавец"
ENT.Category = "Cyberpunk RED"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.bNoPersist = true
ENT.Armor = 0
ENT.Evasion = 20

local models = {
	"models/humans/group01/male_77.mdl",
	"models/humans/group01/male_78.mdl",
	"models/humans/group01/male_80.mdl",
	"models/humans/group01/male_49.mdl",
	"models/cyberpunk/group01/female_13.mdl",
	"models/cyberpunk/group01/female_04.mdl",
	"models/humans/group01/male_127.mdl"
}

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "ID")
	self:NetworkVar("Bool", 0, "NoBubble")
	self:NetworkVar("String", 0, "DisplayName")
	self:NetworkVar("String", 1, "Description")
end

function ENT:Initialize()
	if (SERVER) then
		local randomModel = math.random(1, #models)
        self:SetModel(models[randomModel])
		self:SetHullType(HULL_HUMAN)
        self:SetHullSizeNormal()

        self:SetNPCState(NPC_STATE_IDLE)
        self:SetSolid(SOLID_BBOX)
        self:DropToFloor()

        self:SetHealth(125)
        --self:CapabilitiesAdd(CAP_MOVE_GROUND)

        self:SetMoveType(MOVETYPE_NONE)
        self:SetSchedule(SCHED_FORCED_GO_RUN)
        
        self:SetUseType(SIMPLE_USE)
        --self:CapabilitiesAdd(CAP_OPEN_DOORS)
        self:CapabilitiesAdd(CAP_ANIMATEDFACE)
        self:CapabilitiesAdd(CAP_TURN_HEAD)
        self:CapabilitiesAdd(CAP_USE)

		self.items = {}
		self.messages = {}
		self.factions = {}
		self.classes = {}
		self.inventory_size = {w = 1, h = 1}

		self:SetDisplayName("Безымянный торговец")
		self:SetDescription("Простой безымянный торговец в гражданской одежде, ничего примечательного.")

		self.receivers = {}

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end

	timer.Simple(1, function()
		if (IsValid(self)) then
			self:SetAnim()
		end
	end)
end

if (SERVER) then
	local PLUGIN = PLUGIN
	
	function ENT:SpawnFunction(client, trace)
		local angles = (trace.HitPos - client:GetPos()):Angle()
		angles.r = 0
		angles.p = 0
		angles.y = angles.y + 180

		local entity = ents.Create("ix_vendor_new")
		entity:SetPos(trace.HitPos)
		entity:SetAngles(angles)
		entity:Spawn()
		entity:BuildInventory()
		
		PLUGIN:SaveData()

		return entity
	end

	function ENT:OnTakeDamage(dmginfo)
        local attacker = dmginfo:GetAttacker()
        local damage = dmginfo:GetDamage()
        print(damage)
    
        self:SetHealth(self:Health() - damage)
        local phrases = {
            "Ой спасите, убивают!",
            "Нет! Уходи! Ай... Ай!",
            "Полиция! Полиция!",
            "Нет... Прошу...",
            "Я слишком молод чтобы умирать!",
            "Что ж за день такой, ай!",
            "Только не по лицу!",
            "А-а!... А!...",
            "Хватит, прошу! Хватит!",
            "Ай! Это будет долго заживать..."
        }
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                if math.random(0, 100) <= 35 then
                    local randomIndex = math.random(1, #phrases)
                    ply:SendLua(string.format([[chat.AddText(Color(191, 191, 191), "[Типичный уличный торг...] кричит: \"%s\"")]], phrases[randomIndex]))
                end
            end
        end
        if(self:Health() <= 0) then
            for _, ply in ipairs(player.GetAll()) do
                if ply:GetPos():DistToSqr(self:GetPos()) < 1000000 then
                    ply:SendLua([[chat.AddText(Color(191, 191, 191), "**[Типичный уличный торг...] роняет все свои товары, безжизненно падая на землю.")]])
                end
            end
            self:SetNoDraw(true)
            self:SetNotSolid(true)
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            self:DropToFloor()
            local ragdoll = ents.Create("prop_ragdoll")
            ragdoll:SetModel(self:GetModel()) 
            ragdoll:SetPos(self:GetPos())
            ragdoll:SetAngles(self:GetAngles())
            ragdoll:Spawn()
            ragdoll:Activate()
            self:Remove()
            timer.Simple(5, function()
                if IsValid(ragdoll) then
                    ragdoll:Remove()
                end
            end)
        end
    
        return false
    end
	
	function ENT:BuildInventory(callback, w, h)
		local invID = os.time() + self:EntIndex()
		
		if self:GetID() ~= 0 then
			invID = self:GetID()
		end
		
		local inventory = ix.inventory.Create(w or 1, h or 1, invID)
		
		inventory.vars.isNewVendor = true
		inventory.noSave = true
		
		if (callback) then
			callback(inventory)
		end

		self:SetInventory(inventory)
	end
	
	function ENT:SetInventory(inventory)
		if (inventory) then
			self:SetID(inventory:GetID())
			inventory.OnAuthorizeTransfer = function(inventory, client, oldInventory, item)
				if (IsValid(client) and IsValid(self) and inventory.vars and inventory.vars.isNewVendor) then
					return false
				end
			end
		end
	end
	
	function ENT:OnRemoveInventory()
		local index = self:GetID()
		
		if (!ix.shuttingDown and !self.ixIsSafe and ix.entityDataLoaded and index) then
			local inventory = ix.item.inventories[index]

			if (inventory) then
				ix.item.inventories[index] = nil
				self.items = {}

				hook.Run("VendorRemakeRemoved", self, inventory)
			end
		end
	end

	function ENT:OnRemove()
		self:OnRemoveInventory()
	end

	function ENT:Use(activator)		
		local inventory = self:GetInventory()

		if (inventory and (activator.ixNextOpen or 0) < CurTime()) then
			if (!self:CanAccess(activator) or hook.Run("CanPlayerUseVendor", activator) == false) then
				if (self.messages[VENDOR.NOTRADE]) then
					activator:ChatPrint(self:GetDisplayName()..": "..self.messages[VENDOR.NOTRADE])
				else
					activator:NotifyLocalized("vendorNoTrade")
				end

				return
			end
		
			if (self.messages[VENDOR.WELCOME]) then
				activator:ChatPrint(self:GetDisplayName()..": "..self.messages[VENDOR.WELCOME])
			end
			
			local items = {}

			-- Only send what is needed.
			for k, v in pairs(self.items) do
				if (!table.IsEmpty(v) and (CAMI.PlayerHasAccess(activator, "Helix - Manage Vendors", nil) or v[VENDOR.MODE])) then
					items[k] = v
				end
			end
			
			self.scale = self.scale or 0.5
			
			-- Open Inventory
			local character = activator:GetCharacter()
			if (character) then
				character:GetInventory():Sync(activator, true)
			end

			inventory:AddReceiver(activator)
			self.receivers[#self.receivers + 1] = activator
			activator.ixOpenVendorRemake = self
			inventory:Sync(activator)
			
			net.Start('ixVendorRemakeOpen')
				net.WriteEntity(self)
				net.WriteUInt(self.money or 0, 16)
				net.WriteTable(items)
			net.Send(activator)
			
			ix.log.Add(activator, "vendorRemakeUse", self:GetDisplayName())

			activator.ixNextOpen = CurTime() + 1
		end
	end
	
	function ENT:SetMoney(value)
		self.money = value

		net.Start("ixVendorRemakeMoney")
			net.WriteUInt(value and value or -1, 16)
		net.Send(self.receivers)
	end

	function ENT:GiveMoney(value)
		if (self.money) then
			self:SetMoney(self:GetMoney() + value)
		end
	end

	function ENT:TakeMoney(value)
		if (self.money) then
			self:GiveMoney(-value)
		end
	end

	function ENT:SetStock(uniqueID, value)
		if (!self.items[uniqueID][VENDOR.MAXSTOCK]) then
			return
		end

		self.items[uniqueID] = self.items[uniqueID] or {}
		self.items[uniqueID][VENDOR.STOCK] = math.min(value, self.items[uniqueID][VENDOR.MAXSTOCK])

		net.Start("ixVendorRemakeStock")
			net.WriteString(uniqueID)
			net.WriteUInt(value, 16)
		net.Send(self.receivers)
	end

	function ENT:AddStock(uniqueID, value)
		if (!self.items[uniqueID][VENDOR.MAXSTOCK]) then
			return
		end

		self:SetStock(uniqueID, self:GetStock(uniqueID) + (value or 1))
	end

	function ENT:TakeStock(uniqueID, value)
		if (!self.items[uniqueID][VENDOR.MAXSTOCK]) then
			return
		end

		self:AddStock(uniqueID, -(value or 1))
	end
else
	function ENT:CreateBubble()
		self.bubble = ClientsideModel("models/extras/info_speech.mdl", RENDERGROUP_OPAQUE)
		self.bubble:SetPos(self:GetPos() + Vector(0, 0, 84))
		self.bubble:SetModelScale(0.6, 0)
	end

	function ENT:Draw()
		local bubble = self.bubble

		if (IsValid(bubble)) then
			local realTime = RealTime()

			bubble:SetRenderOrigin(self:GetPos() + Vector(0, 0, 84 + math.sin(realTime * 3) * 0.05))
			bubble:SetRenderAngles(Angle(0, realTime * 100, 0))
		end

		self:DrawModel()
	end

	function ENT:Think()
		local noBubble = self:GetNoBubble()

		if (IsValid(self.bubble) and noBubble) then
			self.bubble:Remove()
		elseif (!IsValid(self.bubble) and !noBubble) then
			self:CreateBubble()
		end

		if ((self.nextAnimCheck or 0) < CurTime()) then
			self:SetAnim()
			self.nextAnimCheck = CurTime() + 60
		end

		self:SetNextClientThink(CurTime() + 0.25)

		return true
	end

	function ENT:OnRemove()
		if (IsValid(self.bubble)) then
			self.bubble:Remove()
		end
	end

	ENT.PopulateEntityInfo = true

	function ENT:OnPopulateEntityInfo(container)
		local name = container:AddRow("name")
		name:SetImportant()
		name:SetText(self:GetDisplayName())
		name:SizeToContents()

		local descriptionText = self:GetDescription()

		if (descriptionText != "") then
			local description = container:AddRow("description")
			description:SetText(self:GetDescription())
			description:SizeToContents()
		end
	end
end

function ENT:GetInventory()
	return ix.item.inventories[self:GetID()]
end

function ENT:GetMoney()
	return self.money
end

function ENT:CanAccess(client)
	local bAccess = false
	local uniqueID = ix.faction.indices[client:Team()].uniqueID

	if (self.factions and !table.IsEmpty(self.factions)) then
		if (self.factions[uniqueID]) then
			bAccess = true
		else
			return false
		end
	end

	if (bAccess and self.classes and !table.IsEmpty(self.classes)) then
		local class = ix.class.list[client:GetCharacter():GetClass()]
		local classID = class and class.uniqueID

		if (classID and !self.classes[classID]) then
			return false
		end
	end

	return true
end

function ENT:GetStock(uniqueID)
	if (self.items[uniqueID] and self.items[uniqueID][VENDOR.MAXSTOCK]) then
		return self.items[uniqueID][VENDOR.STOCK] or 0, self.items[uniqueID][VENDOR.MAXSTOCK]
	end
end

function ENT:GetPrice(uniqueID, selling)
	local price = ix.item.list[uniqueID] and self.items[uniqueID] and
		self.items[uniqueID][VENDOR.PRICE] or ix.item.list[uniqueID].price or 0

	if (selling) then
		price = math.floor(price * (self.scale or 0.5))
	end

	return price
end

function ENT:HasMoney(amount)
	-- Vendor not using money system so they can always afford it.
	if (!self.money) then
		return true
	end

	return self.money >= amount
end

function ENT:SetAnim()
	for k, v in ipairs(self:GetSequenceList()) do
		if (v:lower():find("idle") and v != "idlenoise") then
			return self:ResetSequence(k)
		end
	end

	if (self:GetSequenceCount() > 1) then
		self:ResetSequence(4)
	end
end

list.Set( "NPC", "ix_trader", {
    Name = "Уличный торговец",
    Class = "ix_trader",
    Category = "Cyberpunk RED"
})