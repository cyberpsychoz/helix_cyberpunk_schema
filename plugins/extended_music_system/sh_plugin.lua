local PLUGIN = PLUGIN

PLUGIN.name = "Extended Music System"
PLUGIN.description = "An extended music system ported from CC with some tweaks"
PLUGIN.author = "Ceryx"

ix.lang.AddTable("english", {
	ambient_music = "Ambient Music",

	optMusicVol = "Music Volume",
	optdMusicVol = "Choose your preferred volume of the ambient music"
})

CAMI.RegisterPrivilege({
	Name = "Helix - Music Player",
	MinAccess = "admin"
})

ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_hooks.lua")

ix.option.Add("musicVol", ix.type.number, 50, {
	category = "ambient_music",
	min = 0,
	max = 100,
	decimals = 0,
	OnChanged = function(oldValue, value)
		if (Schema.MusicPatch) then
			if (value == 0) then
				Schema:FadeOutMusic()
			else
				Schema.MusicPatch:ChangeVolume(value / 100)
			end
		end
	end
})

MUSIC_NOPLAY = 0
MUSIC_MENU = 1
MUSIC_AMBIENT = 2
MUSIC_COMBAT = 3
MUSIC_STINGER = 4

ix.Music = {

	{ "CyberpunkMusic/2049.mp3", 111, MUSIC_MENU, "2049" },
	{ "CyberpunkMusic/vangelis.mp3", 410, MUSIC_MENU, "Vangelis" },
	{ "CyberpunkMusic/OFortuna.mp3", 170, MUSIC_NOPLAY, "FORTUNA" },
	{ "CyberpunkMusic/vangelis-one-more-kiss-dear.mp3", 237, MUSIC_NOPLAY, "One more kiss" },
	{ "CyberpunkMusic/vangelis-blade-runner-end-titles.mp3", 280, MUSIC_AMBIENT, "End" },
	--{ "CyberpunkMusic/vangelis-blush-response.mp3", 345, MUSIC_AMBIENT, "Blush Responce" },
	{ "CyberpunkMusic/vangelis-damask-rose.mp3", 150, MUSIC_AMBIENT, "Damask Rose" },
	{ "CyberpunkMusic/vangelis-memories-of-green.mp3", 305, MUSIC_AMBIENT, "Memories of Green" },
	{ "CyberpunkMusic/Mesa.mp3", 291, MUSIC_AMBIENT, "Mesa 2049" },
	{ "CyberpunkMusic/2049_01.mp3", 80, MUSIC_AMBIENT, "Ghoose 2049" },
	{ "CyberpunkMusic/hyper-spoiler.mp3", 65, MUSIC_COMBAT, "Cyberpunk 1" },
	{ "CyberpunkMusic/p-t-adamczyk-scavengers.mp3", 65, MUSIC_COMBAT, "Cyberpunk 2" },
	{ "CyberpunkMusic/p-t-adamczyk-scavenger-hunt.mp3", 65, MUSIC_COMBAT, "Cyberpunk 3" },
	{ "CyberpunkMusic/p-t-adamczyk-the-rebel-path.mp3", 65, MUSIC_COMBAT, "Cyberpunk 4" },
	{ "CyberpunkMusic/hl2_song20_submix0.mp3", 65, MUSIC_COMBAT, "CP Violation" },
	{ "CyberpunkMusic/stingers/hl1_stinger_song7.mp3", 23, MUSIC_STINGER, "Apprehensive" },
	{ "CyberpunkMusic/stingers/hl1_stinger_song8.mp3", 9, MUSIC_STINGER, "Bass String" },
	{ "CyberpunkMusic/stingers/hl1_stinger_song16.mp3", 16, MUSIC_STINGER, "Scared Confusion" },
	{ "CyberpunkMusic/stingers/hl1_stinger_song27.mp3", 17, MUSIC_STINGER, "Dark Piano" }

}

function Schema:GetSongDuration(path)
	for _, v in pairs(ix.Music) do
		if (string.lower(v[1]) == string.lower(path)) then return v[2] end
	end

	return 0
end

function Schema:GetSongList(e)
	local tab = {}

	for _, v in pairs(ix.Music) do
		if (v[3] == e) then
			table.insert(tab, v[1])
		end
	end

	return tab
end

function Schema:GetSongName(e)
	for _, v in pairs(ix.Music) do
		if (v[1] == e) then return v[4] end
	end
end

function Schema:GetSongLength(e)
	for _, v in pairs(ix.Music) do
		if (v[1] == e) then return v[2] end
	end
end