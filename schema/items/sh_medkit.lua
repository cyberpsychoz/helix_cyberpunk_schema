ITEM.name = "Медицинский набор"
ITEM.description = "Последний шанс любого наемника, этот огромный медицинский набор наверня-ка спасет вам жизнь, рекомендуется использовать только если других выходов нету."
ITEM.model = "models/germandude/verbandkasten/german_verbandkasten_old.mdl"
ITEM.width = 3
ITEM.height = 2
ITEM.price = 450
ITEM.category = "Medicine"
ITEM.noBusiness = false

ITEM.functions.Use = {
    name = "Залечить раны себе",
    icon = "icons/energy-drink.png",
    OnRun = function(item)
        local client = item.player
        local medical = client:GetCharacter():GetSkill("medicine")
        
        if medical == nil or medical == 0 then
            ix.chat.Send(client, "me", "пытается зашить свои выпадающие кишки, но к сожалению вспоминает что совершенно ничего не понимает в медицине. Какая жалость.")
            client:TakeDamage(10)
        else
            client:SetHealth(math.min(client:Health() + medical, client:GetMaxHealth()))
            ix.chat.Send(client, "me", " достает медицинский набор, поспешно обрабатывая все свои раны настолько хорошо, насколько хватает его познаний в медицине.")
        end
        
        return true
    end,  
}

ITEM.functions.UseOnPlayer = {
    name = "Залечить раны оболочке напротив",
    icon = "icons/energy-drink.png",
    OnRun = function(item)
        local client = item.player
        local target = client:GetEyeTrace().Entity
        local medical = client:GetCharacter():GetSkill("medicine")
        
        -- Добавляем проверку, смотрит ли игрок на кого-либо
        if not IsValid(target) or not target:IsPlayer() then
            ix.chat.Send(client, "me", "достает медицинский набор, оглядываясь по сторонам, спустя несколько секунд убирая его обратно. Видимо крыша уже совсем потекла.")
            return false
        end
    
        if medical == nil or medical == 0 then
            ix.chat.Send(client, "me", "пытается зашить выпадающие кишки " .. target:Nick() .. ", но к сожалению вспоминает что совершенно ничего не понимает в медицине. Какая жалость.")
            target:TakeDamage(20)
        else
            target:SetHealth(math.min(target:Health() + medical, target:GetMaxHealth())) -- Увеличиваем здоровье цели на значение навыка медицины
            ix.chat.Send(client, "me", "достает медицинский набор, поспешно обрабатывая все раны " .. target:Nick() .. " настолько хорошо, насколько хватает его познаний в медицине.")
        end
        
        return true
    end,  
}
