util.AddNetworkString("ixItemMenuGive")
util.AddNetworkString("ixItemMenuSpawn")

net.Receive("ixItemMenuGive", function(len, ply)
    if not ( IsValid(ply) and ply:Alive() and ply:GetCharacter() ) then
        return
    end

    if not ( ply:IsSuperAdmin() ) then
        return
    end

    local itemUniqueID = net.ReadString()
    local itemName = net.ReadString() or "unknown item name"
    local itemAmount = net.ReadUInt(5) or 1

    ply:GetCharacter():GetInventory():Add(itemUniqueID, itemAmount)

    ply:Notify("You spawned yourself '"..itemName.."'.")
end)

net.Receive("ixItemMenuSpawn", function(len, ply)
    if not ( IsValid(ply) and ply:Alive() and ply:GetCharacter() ) then
        return
    end

    if not ( ply:IsSuperAdmin() ) then
        return
    end

    local itemUniqueID = net.ReadString()
    local itemName = net.ReadString() or "unknown item name"
    local itemAmount = net.ReadUInt(5) or 1

    local trace = ply:GetEyeTrace()

    ix.item.Spawn(itemUniqueID, trace.HitPos)

    ply:Notify("You spawned '"..itemName.."' at your crosshair position.")
end)