ITEM.name = "CyberWeapons"
ITEM.description = "Оружие из киберпанка."
ITEM.category = "CyberWeapons"
ITEM.width = 2
ITEM.height = 2
ITEM.useSound = "items/ammo_pickup.wav"

if (CLIENT) then
    function ITEM:PaintOver(item, w, h)
        if (item:GetData("equip")) then
            surface.SetDrawColor(150, 0, 0)
            surface.DrawRect(w - 14, h - 14, 8, 8)
        end
    end
end

function ITEM:AddWeapon(client)
    local char = client:GetCharacter()
    local weaponData = {
        name = self.name,
        skill = self.weaponSkill,
        destination = self.weaponDestination,
        effect = self.weaponEffect,
        penetration = self.weaponPenetration,
        damage = self.weaponDamage
    }
    char:SetData("weapon", weaponData)
    self:SetData("equip", true)

    -- Небольшой дебаг
    local weaponchar = char:GetData("weapon", nil)
    --PrintTable(weaponchar)
    -- Другие действия при добавлении оружия
end

function ITEM:RemoveWeapon(client)
    local char = client:GetCharacter()
    char:SetData("weapon", nil)
    self:SetData("equip", false)

    -- Другие действия при удалении оружия
end

ITEM:Hook("drop", function(item)
    if (item:GetData("equip")) then
        local character = ix.char.loaded[item.owner]
        local client = character and character:GetPlayer() or item:GetOwner()
        item.player = client
        item:RemoveWeapon(item:GetOwner())
    end
end)

ITEM.functions.EquipUn = {
    name = "Убрать",
    tip = "equipTip",
    icon = "icons/boots2.png",
    OnRun = function(item)
        item:RemoveWeapon(item.player)
        return false
    end,
    OnCanRun = function(item)
        local client = item.player
        return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
            hook.Run("CanPlayerUnequipItem", client, item) != false
    end
}

ITEM.functions.Equip = {
    name = "Взять в руки",
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

        item:AddWeapon(item.player)
        return false
    end,
    OnCanRun = function(item)
        local client = item.player
        return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") != true and
            item:CanEquipWeapon() and hook.Run("CanPlayerEquipItem", client, item) != false
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
        self:RemoveWeapon(self.player)
        self.player = nil
    end
end

function ITEM:OnEquipped()
end

function ITEM:OnUnequipped()
end

function ITEM:CanEquipWeapon()
    return true
end
