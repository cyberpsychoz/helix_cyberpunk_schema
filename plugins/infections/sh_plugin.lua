
PLUGIN.name = "Болезни современного мира"
PLUGIN.author = "Крыжовник"
PLUGIN.description = "Добавляет разнообразные болезни, от которых игроки будут СТРАДАТЬ БЛЯТЬ."

local ix = ix or {}
ix.Diseases = ix.Diseases or {}

ix.util.Include("sv_hooks.lua", "server")
ix.util.Include("sh_meta.lua", "shared")
ix.util.Include("sh_lang.lua", "shared")

--[[
    КОМАНДЫ ДЛЯ ЧАТА (МОГУТ НЕ ОТОБРАЖАТЬСЯ НО РАБОТАЮТ ВСЕГДА)
--]]

ix.command.Add("InfectPlayer", {
    description = "Устанавливает болезнь",
    adminOnly = true,
    arguments = {ix.type.player, ix.type.string},
    argumentNames = {"Target (Player)(SteamID or Name)", "Disease"},
    OnRun = function(self, pl, target, disease)
        if !target or !disease then return end
        if ( hook.Run( "CanPlayerGetDisease", target, disease ) or false ) then return end

        ix.Diseases:InfectPlayer(target, disease, true)
        ix.util.NotifyLocalized( "diseasesInfected", pl, target:Name(), disease )
    end
})

ix.command.Add("DisinfectPlayer", {
    description = "Удаляет болезнь для игрока",
    adminOnly = true,
    arguments = {ix.type.player, ix.type.string},
    argumentNames = {"Target (Player)(SteamID or Name)", "Disease"},
    OnRun = function(self, pl, target, disease)
        if !target or !disease then return end
        if ( hook.Run( "CanPlayerDisinfect", target, disease ) or false ) then return end

        ix.Diseases:DisinfectPlayer(target, disease)
        ix.util.NotifyLocalized( "diseasesDisinfected", pl, target:Name(), disease )
    end
})

ix.command.Add("RemoveAllDiseases", { -- С ЭТОЙ ХУЙНЕЙ ПООСТОРОЖНЕЙ
    description = "Удаляет все болезни для игрока",
    adminOnly = true,
    arguments = {ix.type.player},
    argumentNames = {"Target (Player)(SteamID or Name)"},
    OnRun = function(self, pl, target)
        if !target then return end

        ix.Diseases:RemoveAllDiseases(target)
        ix.util.NotifyLocalized( "diseasesFullyDisinfected", pl, target:Name() )
    end
})
