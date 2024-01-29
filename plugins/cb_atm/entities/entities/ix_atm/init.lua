util.AddNetworkString("ixAtmDeposit")
util.AddNetworkString("ixAtmWithdraw")

include("shared.lua")
AddCSLuaFile("cl_init.lua")

net.Receive("ixAtmDeposit", function(_, client)
    local requested = net.ReadUInt(32)
    local character = client:GetCharacter()

    local wallet = character:GetMoney()
    local bank = character:GetBankMoney()

    if requested > wallet then
        return client:Notify("У вас недостаточно средств.")
    end

    character:TakeMoney(requested)
    character:SetBankMoney(bank + requested)
    client:Notify("Вы внесли " .. ix.currency.Get(requested) .. "!")
end)

net.Receive("ixAtmWithdraw", function(_, client)
    local requested = net.ReadUInt(32)
    local character = client:GetCharacter()

    local bank = character:GetBankMoney()

    if requested > bank then
        return client:Notify("На вашем счету недостаточно средств.")
    end

    character:GiveMoney(requested)
    character:SetBankMoney(bank - requested)
    client:Notify("Вы положили на счет" .. ix.currency.Get(requested) .. "!")
end)