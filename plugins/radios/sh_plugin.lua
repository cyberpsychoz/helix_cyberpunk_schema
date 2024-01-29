
PLUGIN.name = "Radios"
PLUGIN.author = "Bilwin"
PLUGIN.description = "Adds radio"
PLUGIN.schema = "Any"
PLUGIN.version = 1.0
PLUGIN.songs = {
    [''] = "Stop",
    ["CyberpunkMusic/wordl_on_fire.mp3"] = "122.2 FM",
    ["CyberpunkMusic/Alice_01.mp3"] = "123.2 FM",
    ["CyberpunkMusic/Alice_02.mp3"] = "124.2 FM",
    ["CyberpunkMusic/Alice_03.mp3"] = "125.2 FM",
    ["CyberpunkMusic/Alice_04.mp3"] = "126.2 FM",
    ["CyberpunkMusic/mehve.mp3"] = "127.2 FM",
    ["CyberpunkMusic/cybergrind.mp3"] = "CybergriNd FM",
    ["CyberpunkMusic/murdermind.mp3"] = "Murder 22",
    ["CyberpunkMusic/shottokill.mp3"] = "Chromatic-Wave FM",
    ["CyberpunkMusic/ultrachurch.mp3"] = "Radio Ultra",
    ["CyberpunkMusic/arasaka_combat.mp3"] = "Неизвестная волна",
    ["CyberpunkMusic/radio2.mp3"] = "Nevada",
    ["CyberpunkMusic/choosethegodtobless.mp3"] = "BADSTONE WASTELAND RADIO",
}

ix.util.Include("cl_hooks.lua")
ix.util.Include("sv_hooks.lua")