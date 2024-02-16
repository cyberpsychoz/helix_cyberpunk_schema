ITEM.name = "Medicine"
ITEM.model = "models/props_junk/garbage_metalcan001a.mdl"
ITEM.description = "..."
ITEM.width = 1
ITEM.height = 1
ITEM.adminPills = false
ITEM.category = "Medicine"
ITEM.useSound = "items/medshot4.wav"
ITEM.healing = {}

ITEM.functions.Use = {
	name = "Принять",
	tip = "useTip",
	icon = "icons/energy-drink.png",
	OnRun = function(item)
		local client = item.player

		local cybertechSkill = client:GetCharacter():GetSkill("medicine", 0)
		local luckAttrib = client:GetCharacter():GetAttribute("luck", 0)
		local intAttrib = client:GetCharacter():GetAttribute("int", 0)
		local phyAttrib = client:GetCharacter():GetAttribute("phy", 0)


		local finalresult = math.random(0,luckAttrib) + math.random(0,intAttrib)
		local randomchance = math.random(0, item.chance) - phyAttrib

		if finalresult >= randomchance then
			client:EmitSound(item.useSound, 70)

			-- Проверяем, является ли таблетка административной
			if item.adminPills then
				-- Удаляем все болезни у целевого игрока
				ix.Diseases:RemoveAllDiseases(client)

				-- Возвращаем true, чтобы сообщить, что использование было успешным
				return true
			end

			-- Иначе, используем таблетку на целевом игроке
			ix.Diseases:DisinfectPlayer(client, item.healing)

			-- Возвращаем true, чтобы сообщить, что использование было успешным
			ix.chat.Send(client, "me", "попытался применить " ..  item.name .." на себе и успешно вылечил себя от болезни.")
			print("УСПЕШНО")
			return true
		else
			ix.chat.Send(client, "me", "попытался применить " ..  item.name .." на себе, но к сожалению что-то пошло не так и он сделал только хуже...")
			client:TakeDamage(item.chance)
			print("НЕ УСПЕШНО")
			return true
		end
	end,
}

ITEM.functions.UseOnPlayer = {
    name = "Помочь принять другому",
    tip = "useTip",
    icon = "icons/energy-drink.png",
    OnRun = function(item, caller, target)
		local client = item.player

        local trace = client:GetEyeTraceNoCursor()
        local target = trace.Entity

		local cybertechSkill = client:GetCharacter():GetSkill("medicine", 0)
		local luckAttrib = client:GetCharacter():GetAttribute("luck", 0)
		local intAttrib = client:GetCharacter():GetAttribute("int", 0)
		local targetPhyAttrib = target:GetCharacter():GetAttribute("phy", 0)
		
		local finalresult = math.random(0,luckAttrib) + math.random(0,intAttrib)

		local randomchance = math.random(0, item.chance) - targetPhyAttrib

		if IsValid(target) and target:IsPlayer() and target ~= client then
			if finalresult >= randomchance then
				client:EmitSound(item.useSound, 70)

				-- Проверяем, является ли таблетка административной
				if item.adminPills then
					-- Удаляем все болезни у целевого игрока
					ix.Diseases:RemoveAllDiseases(target)

					-- Возвращаем true, чтобы сообщить, что использование было успешным
					return true
				end

				-- Иначе, используем таблетку на целевом игроке
				ix.Diseases:DisinfectPlayer(target, item.healing)

				-- Возвращаем true, чтобы сообщить, что использование было успешным
				ix.chat.Send(client, "me", "попытался применить " ..  item.name .." на " .. target:GetName() .. " успешно вылечив его от болезни.")
				return true
			else
				ix.chat.Send(client, "me", "попытался применить " ..  item.name .." на " .. target:GetName() .. ", но к сожалению что-то пошло не так и он сделал только хуже...")
				target:TakeDamage(item.chance)
				return true
			end
		end
    end,
}