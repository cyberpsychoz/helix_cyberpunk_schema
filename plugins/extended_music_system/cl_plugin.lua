local PLUGIN = PLUGIN

function Schema:CanAutoPlayMusic()
	return LocalPlayer():Alive()
end

function Schema:CanPlayMusic()
	return ix.option.Get('musicVol', 50) > 0
end

function PLUGIN:OnCharacterMenuCreated(panel)
	if (IsValid(ix.gui.characterMenu)) then
		Schema.NextAutoMusic = CurTime() + 5
		Schema.MusicFinished = CurTime()
	end
end

function Schema:PlayMusic(s, fl)
	if (not Schema:CanPlayMusic()) then return end

	if (not fl) then
		fl = 1
	end

	if (not Schema.MusicFinished) then
		Schema.MusicFinished = 0
	end

	if (Schema.MusicPatch) then
		if (fl > 0 and not Schema.Fading and CurTime() < Schema.MusicFinished - 1) then
			Schema.MusicPatch:ChangeVolume(0, fl)
			Schema.MusicFadeTime = CurTime() + fl
			Schema.NextMusic = s
		else
			Schema.MusicFadeTime = CurTime()
			Schema.NextMusic = s
		end

		Schema.Fading = true
	else
		if (LocalPlayer() and LocalPlayer():IsValid()) then
			local vol = ix.option.Get('musicVol', 50) / 100
			Schema.MusicPatch = CreateSound(LocalPlayer(), s)
			Schema.MusicPatch:SetSoundLevel(0)
			Schema.MusicPatch:Play()
			Schema.MusicPatch:ChangeVolume(vol)
			Schema.MusicFinished = CurTime() + Schema:GetSongDuration(s)
			Schema.NextAutoMusic = CurTime() + Schema:GetSongDuration(s) + 5
			MsgC(Color(150, 150, 150), "Now playing ", Color(150, 220, 0), Schema:GetSongName(s), Color(150, 150, 150), "...\n")
		end
	end
end

function Schema:FadeOutMusic(fl)
	if (not fl) then
		fl = 1
	end

	if (Schema.MusicPatch and not Schema.Fading) then
		Schema.Fading = true

		if (fl > 0) then
			Schema.MusicPatch:ChangeVolume(0, fl)
			Schema.MusicFadeTime = CurTime() + fl
			Schema.MusicFinished = CurTime() + fl
		else
			Schema.MusicPatch = nil
		end
	end
end

function nAPlayMusic(l)
	local song = net.ReadString()
	Schema:PlayMusic(song)
end

net.Receive("nAPlayMusic", nAPlayMusic)

function nAStopMusic(l)
	Schema:FadeOutMusic()
end

net.Receive("nAStopMusic", nAStopMusic)

function Schema:MusicThink()
	if(not Schema.NextAutoMusic ) then
		Schema.NextAutoMusic = CurTime() + 5
	end

	if (not Schema.MusicFinished) then
		Schema.MusicFinished = 0
	end

	if (CurTime() > Schema.MusicFinished and Schema.MusicPatch) then
		Schema:FadeOutMusic()
	end

	if (Schema.MusicFadeTime and CurTime() >= Schema.MusicFadeTime and Schema.MusicPatch) then
		Schema.Fading = false
		Schema.MusicPatch = nil
		Schema.MusicFadeTime = nil
	end

	if (Schema.NextMusic and not Schema.MusicPatch) then
		Schema:PlayMusic(Schema.NextMusic)
		Schema.NextMusic = nil
	end

	if (not Schema.MusicPatch and CurTime() >= Schema.MusicFinished + 1 and (CurTime() >= Schema.NextAutoMusic) and Schema:CanAutoPlayMusic()) then
		local ambMusic = table.Random(Schema:GetSongList(MUSIC_AMBIENT))
		local menMusic = table.Random(Schema:GetSongList(MUSIC_MENU))

		if (not IsValid(ix.gui.characterMenu)) then
			Schema:PlayMusic(ambMusic)
		end

		if (IsValid(ix.gui.characterMenu) and ix.config.Get("music") == "") then
			Schema:PlayMusic(menMusic)
		end

	end
end

-- Must start in the client realm; DO NOT move this function to somewhere else!
function Schema:Think()
	Schema:MusicThink()
end