return {
    name = "Киберпсихоз",
    description = "От переизбытка имплантов у вас начинаются беды с башкой. Чумба, попей колесики.",
    canGetRandomly = false,
    immuneFactions = { FACTION_AUTORAVE },

    OnCall = function( pl )
        --print("БОЛЕЗНЬ КИБЕРПСИХОЗА ВЫЗВАНА ПРОВЕРКА")
        -- Задаем начальные значения атрибутов
        local originalEmp = pl:GetCharacter():GetAttribute("emp") or 0
        local originalCha = pl:GetCharacter():GetAttribute("cha") or 0
        local originalWil = pl:GetCharacter():GetAttribute("wil") or 0

        pl:_SetTimer( "diseaseCyberPsychosis::" .. pl:SteamID64(), 30, 0, function()
            -- Сбрасываем атрибуты до нуля
            pl:GetCharacter():SetAttrib("emp", 0)
            pl:GetCharacter():SetAttrib("cha", 0)
            pl:GetCharacter():SetAttrib("wil", 0)

            local phrases = {
                "Я СЕЙЧАС ПОУБИВАЮ ТУТ ВСЕХ НАХУЙ!",
                "УЙДИ НАХУЙ ИЗ МОЕЙ ГОЛОВЫ!",
                "Если бы у меня в руках был топор, я бы тебе в бошку его воткнул.",
                "Это все сон! Это все сон! Ха-ха-ха-ха!",
                "ПИДАРАСЫ ОТСТАНЬТЕ ОТ МЕНЯ!",
                "А-А-А-А МОЯ ГОЛОВА! МОЯ ГОЛОВА! Я ВИЖУ КАК ВЫТЕКАЕТ МОЙ МОЗГ, КТО-НИБУДЬ ПОМОГИТЕ!",
                "А-а-а... Ха-ха-ха... ХА-ХА-ХА-ХА!",
                "Это не я! Это не я! Перестань это делать!",
                "ВОТ УРОДА БЛЯТЬ! ПОШЛИ НА ХУЙ ВСЕ!",
                "СДОХНИ, ПАДАЛЬ!",
                "Это кто тут такой!? Я тебе щас пиздак расхуярю!",
                "БЛ-Я-ЯТЬ.. МЫШЦЫ ГОРЯТ.. СУКА-А!",
                "ДАВАЙ, СТРЕЛЯЙ! УЕБУ ЩАС, СУКА!",
                "Ты знаешь кто я такой!?",
                "ХА-АХА-ХА-ХА БЛЯТЬ.. ЧТО?! ЧТО!?",
                "ГДЕ Я? ПОЧЕМУ НА МНЕ КРОВЬ!?",
                "Бежать.. НЕТ, УБИВАТЬ! АРГХ-Х СУКА!",
                "АХВЩАРХ! ЫАЫА-А-А-А-А-А!",
                "ОТСОСИ!",
            }

            local randomPhrase = phrases[math.random(1, #phrases)]
            ix.chat.Send( pl, "y", randomPhrase )

            --[[for k, v in pairs( ents.FindInSphere(pl:GetPos(), 500) ) do
                if ( IsValid(v) and v:IsPlayer() and v:GetCharacter() and math.random(1, 20) > 17 ) then
                    ix.Diseases:InfectPlayer( v, "cyberPsychosis" )
                end
            end]]
        end )

        pl:_SetSimpleTimer( 60 * 15, function()
            -- Восстанавливаем атрибуты при окончании болезни
            pl:GetCharacter():SetAttrib("emp", originalEmp)
            pl:GetCharacter():SetAttrib("cha", originalCha)
            pl:GetCharacter():SetAttrib("wil", originalWil)

            ix.Diseases.Loaded["cyberpsychosis"].OnEnd(pl)
        end )
    end,

    OnEnd = function( pl )
        if pl:_TimerExists( "diseaseCyberPsychosis::" .. pl:SteamID64() ) then
            pl:_RemoveTimer( "diseaseCyberPsychosis::" .. pl:SteamID64() )
        end
    end
}
