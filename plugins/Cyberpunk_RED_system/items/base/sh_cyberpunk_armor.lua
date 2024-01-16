ITEM.name = "Bulletproof Vest's"
ITEM.description = "Cyberpunk armor."
ITEM.model = "models/mass_effect_3/weapons/misc/ammobox1 small.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.armorclass = 0
ITEM.category = "Armor"

if (CLIENT) then
    function ITEM:PaintOver(item, w, h)
        if (item:GetData("equip")) then
            surface.SetDrawColor(150, 0, 0)
            surface.DrawRect(w - 14, h - 14, 8, 8)
        end
    end
end

function ITEM:AddArmor(client)
    local char = client:GetCharacter()
    --print("ПРОВЕРКА")
    char:SetData("armorclass", self.armorclass)
    self:SetData("equip", true)

    local groups = client:GetCharacter():GetData("groups", {})

    if (!table.IsEmpty(groups)) then
        client:GetCharacter():SetData("oldGroups" .. self.category, groups)
        client:GetCharacter():SetData("groups", {})
        client:ResetBodygroups()
    end

    if (isfunction(self.OnGetReplacement)) then
        -- Оставлено без изменений
    elseif (self.replacement or self.replacements) then
        -- Оставлено без изменений
    end

    if (self.newSkin) then
        -- Оставлено без изменений
    end

    local savedGroups = self:GetData("groups", {})

    if (!table.IsEmpty(savedGroups) and self:ShouldRestoreBodygroups()) then
        for k, v in pairs(savedGroups) do
            client:SetBodygroup(k, v)
        end
    elseif (istable(self.bodyGroups)) then
        for k, v in pairs(self.bodyGroups) do
            local index = client:FindBodygroupByName(k)

            if (index > -1) then
                client:SetBodygroup(index, v)
            end
        end
    end

    local materials = self:GetData("submaterial", {})

    if (!table.IsEmpty(materials) and self:ShouldRestoreSubMaterials()) then
        for k, v in pairs(materials) do
            if (isnumber(k) and isstring(v)) then
                client:SetSubMaterial(k - 1, v)
            end
        end
    end

    if (istable(self.attribBoosts)) then
        for k, v in pairs(self.attribBoosts) do
            client:GetCharacter():AddBoost(self.uniqueID, k, v)
        end
    end

    self:OnEquipped()
end

function ITEM:RemoveArmor(client)
    local char = client:GetCharacter()

    char:SetData("armorclass", 0)
    self:SetData("equip", false)

    local materials = {}

    for k, _ in ipairs(client:GetMaterials()) do
        if (client:GetSubMaterial(k - 1) != "") then
            materials[k] = client:GetSubMaterial(k - 1)
        end
    end

    if (!table.IsEmpty(materials)) then
        self:SetData("submaterial", materials)
    end

    for k, _ in ipairs(client:GetBodyGroups()) do
        local bodygroup = client:GetBodygroup(k - 1)

        if (bodygroup > 0) then
            groups[k] = bodygroup
        end
    end

    --if (!table.IsEmpty(groups)) then
    --    self:SetData("groups", groups)
    --end

    --client:ResetBodygroups()

    local character = client:GetCharacter()

    if (character:GetData("oldModel" .. self.category)) then
        character:SetModel(character:GetData("oldModel" .. self.category))
        character:SetData("oldModel" .. self.category, nil)
    end

    if (self.newSkin) then
        if (character:GetData("oldSkin" .. self.category)) then
            client:SetSkin(character:GetData("oldSkin" .. self.category))
            character:SetData("oldSkin" .. self.category, nil)
        else
            client:SetSkin(0)
        end
    end

    local savedGroups = character:GetData("oldGroups" .. self.category, {})

    if (!table.IsEmpty(savedGroups)) then
        for k, v in pairs(savedGroups) do
            client:SetBodygroup(k, v)
        end

        character:SetData("groups", character:GetData("oldGroups" .. self.category, {}))
        character:SetData("oldGroups" .. self.category, nil)
    end

    if (istable(self.attribBoosts)) then
        for k, _ in pairs(self.attribBoosts) do
            character:RemoveBoost(self.uniqueID, k)
        end
    end

    for k, _ in pairs(self:GetData("outfitAttachments", {})) do
        self:RemoveAttachment(k, client)
    end

    self:OnUnequipped()
end

ITEM:Hook("drop", function(item)
    if (item:GetData("equip")) then
        local character = ix.char.loaded[item.owner]
        local client = character and character:GetPlayer() or item:GetOwner()
        item.player = client
        item:RemoveArmor(item:GetOwner())

    end
end)

ITEM.functions.EquipUn = {
    name = "Unequip",
    tip = "equipTip",
    icon = "icons/boots2.png",
    OnRun = function(item)
        item:RemoveArmor(item.player)
        return false
    end,
    OnCanRun = function(item)
        local client = item.player
        return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
            hook.Run("CanPlayerUnequipItem", client, item) != false
    end
}

ITEM.functions.Equip = {
    name = "Equip",
    tip = "equipTip",
    icon = "icons/boots.png",
    OnRun = function(item)
        local client = item.player
        local char = client:GetCharacter()
        local items = char:GetInventory():GetItems()

        for _, v in pairs(items) do
            if (v.id != item.id) then
                local itemTable = ix.item.instances[v.id]

                if (itemTable.pacData and v.category == item.category and itemTable:GetData("equip")) then
                    client:NotifyLocalized(item.equippedNotify or "outfitAlreadyEquipped")
                    return false
                end
            end
        end

        item:AddArmor(item.player)
        --print(item.player)
        return false
    end,
    OnCanRun = function(item)
        local client = item.player
        return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
            item:CanEquipArmor() and hook.Run("CanPlayerEquipItem", client, item) != false
    end
}

function ITEM:CanTransfer(oldInventory, newInventory)
    if (newInventory and self:GetData("equip")) then
        return false
    end
    return true
end

function ITEM:OnRemoved()
    if (self.invID != 0 and self:GetData("equip")) then
        self.player = self:GetOwner()
        self:RemoveArmor(self.player)
        self.player = nil
    end
end

function ITEM:OnEquipped()
end

function ITEM:OnUnequipped()
end

function ITEM:CanEquipArmor()
    return true
end

function ITEM:ShouldRestoreBodygroups()
    return true
end

function ITEM:ShouldRestoreSubMaterials()
    return true
end
