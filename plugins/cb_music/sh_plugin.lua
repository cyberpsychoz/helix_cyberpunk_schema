local PLUGIN = PLUGIN

PLUGIN.name = "Cyberpunk Ambient"
PLUGIN.description = "АЛЬГУМАЛЬБА"
PLUGIN.author = "Крыжовник"

ix.lang.AddTable("english", {
	ambient_music = "Ambient Music",

	optMusicVol = "Music Volume",
	optdMusicVol = "Choose your preferred volume of the ambient music"
})

ix.lang.AddTable("english", {
	ambient_music = "Фоновая музыка",

	optMusicVol = "Звук фоновой музыки",
	optdMusicVol = "Выберите предпочитаемую вами громкость эмбиентной музыки"
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

	{ "cyberpunkmusic/turned_around.mp3", 180, MUSIC_MENU, "Turned Around" },
	
	{ "cyberpunkmusic/the_promise.mp3", 180, MUSIC_NOPLAY, "The Promise" },
	{ "cyberpunkmusic/riot_control.mp3", 180, MUSIC_NOPLAY, "Riot Control" },
	{ "cyberpunkmusic/nue.mp3", 180, MUSIC_NOPLAY, "Nue" },
	{ "cyberpunkmusic/mynah.mp3", 180, MUSIC_NOPLAY, "Mynah" },
	{ "cyberpunkmusic/matryoshka.mp3", 180, MUSIC_NOPLAY, "Matryoshka" },
	{ "cyberpunkmusic/labyrinth.mp3", 180, MUSIC_NOPLAY, "Labyrinth" },
	{ "cyberpunkmusic/kolibri.mp3", 180, MUSIC_NOPLAY, "Kolibri" },
	{ "cyberpunkmusic/intensive_care.mp3", 180, MUSIC_NOPLAY, "Intensive Care" },
	{ "cyberpunkmusic/incinerator.mp3", 180, MUSIC_NOPLAY, "Incinerator" },
	{ "cyberpunkmusic/cant.mp3", 180, MUSIC_NOPLAY, "I cant stop now" },
	{ "cyberpunkmusic/blockwart.mp3", 180, MUSIC_NOPLAY, "Blockwart" },

	{ "cyberpunkmusic/ariane.mp3", 180, MUSIC_AMBIENT, "Ariane Theme" },
	{ "cyberpunkmusic/you_have_changed.mp3", 180, MUSIC_AMBIENT, "You Have Changed" },
	{ "cyberpunkmusic/warm_light.mp3", 180, MUSIC_AMBIENT, "Warm Light" },
	{ "cyberpunkmusic/visions.mp3", 180, MUSIC_AMBIENT, "Visions of Alina" },
	{ "cyberpunkmusic/train_ride.mp3", 180, MUSIC_AMBIENT, "Train Ride" },
	{ "cyberpunkmusic/red_gate.mp3", 180, MUSIC_AMBIENT, "The Red Gate" },
	{ "cyberpunkmusic/teeth.mp3", 180, MUSIC_AMBIENT, "Teeth" },
	{ "cyberpunkmusic/ritual.mp3", 180, MUSIC_AMBIENT, "Ritual" },
	{ "cyberpunkmusic/ritual_nowhere.mp3", 180, MUSIC_AMBIENT, "Ritual Nowhere" },
	{ "cyberpunkmusic/3000_cycles.mp3", 180, MUSIC_AMBIENT, "3000 Cycles" },
	{ "cyberpunkmusic/orrery.mp3", 180, MUSIC_AMBIENT, "Orrery" },
	{ "cyberpunkmusic/mnhr.mp3", 180, MUSIC_AMBIENT, "MNHR" },
	{ "cyberpunkmusic/memory.mp3", 180, MUSIC_AMBIENT, "Memory" },
	{ "cyberpunkmusic/falke_theme.mp3", 180, MUSIC_AMBIENT, "Falke Theme" },
	{ "cyberpunkmusic/liminality.mp3", 180, MUSIC_AMBIENT, "Liminality" },
	{ "cyberpunkmusic/home.mp3", 180, MUSIC_AMBIENT, "Home" },
	{ "cyberpunkmusic/ewige.mp3", 180, MUSIC_AMBIENT, "Ewige" },
	{ "cyberpunkmusic/eulenlieder.mp3", 180, MUSIC_AMBIENT, "Eulenlieder" },
	{ "cyberpunkmusic/eternity.mp3", 180, MUSIC_AMBIENT, "Eternity of a box" },
	{ "cyberpunkmusic/dream_dairy.mp3", 180, MUSIC_AMBIENT, "Dream Dairy" },
	{ "cyberpunkmusic/emptiness.mp3", 180, MUSIC_AMBIENT, "Emptiness" },
	{ "cyberpunkmusic/bodies.mp3", 180, MUSIC_AMBIENT, "Bodies" },
	{ "cyberpunkmusic/adler.mp3", 180, MUSIC_AMBIENT, "Adler" },
	
	{ "cyberpunkmusic/become.mp3", 180, MUSIC_COMBAT, "Become hole again" },
	{ "cyberpunkmusic/prison.mp3", 180, MUSIC_COMBAT, "Prison" },
	{ "cyberpunkmusic/hyper-spoiler.mp3", 65, MUSIC_COMBAT, "Cyberpunk 1" },
	{ "cyberpunkmusic/p-t-adamczyk-scavengers.mp3", 65, MUSIC_COMBAT, "Cyberpunk 2" },
	{ "cyberpunkmusic/p-t-adamczyk-scavenger-hunt.mp3", 65, MUSIC_COMBAT, "Cyberpunk 3" },
	{ "cyberpunkmusic/p-t-adamczyk-the-rebel-path.mp3", 65, MUSIC_COMBAT, "Cyberpunk 4" },
	{ "cyberpunkmusic/hell.mp3", 65, MUSIC_COMBAT, "Cyberpunk 5" },

	{ "cyberpunkmusic/rotfront_moon.mp3", 180, MUSIC_STINGER, "Rotfront Moon" },
	--{ "cyberpunkmusic/vangelis-blade-runner-end-titles.mp3", 280, MUSIC_STINGER, "End" },
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