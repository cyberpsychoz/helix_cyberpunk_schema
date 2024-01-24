local PLUGIN = PLUGIN

util.AddNetworkString("nAPlayMusic")
util.AddNetworkString("nAStopMusic")

function PLUGIN:EntityTakeDamage(victim, inflictor)
	if (inflictor:GetAttacker():IsNPC() or inflictor:GetAttacker():IsPlayer() and victim:IsNPC() or victim:IsPlayer() and inflictor:GetAttacker() ~= victim) then
		if (not victim.NextCombatMusic) then
			victim.NextCombatMusic = CurTime()
		end

		if (not inflictor:GetAttacker().NextCombatMusic) then
			inflictor:GetAttacker().NextCombatMusic = CurTime()
		end

		if (victim:IsPlayer() and CurTime() >= victim.NextCombatMusic) then
			local music = table.Random(Schema:GetSongList(MUSIC_COMBAT))
			victim.NextCombatMusic = CurTime() + Schema:GetSongDuration(music)
			net.Start("nAPlayMusic")
			net.WriteString(music)
			net.Send(victim)
		end

		if (inflictor:GetAttacker():IsPlayer() and CurTime() >= inflictor:GetAttacker().NextCombatMusic) then
			local music = table.Random(Schema:GetSongList(MUSIC_COMBAT))
			inflictor:GetAttacker().NextCombatMusic = CurTime() + Schema:GetSongDuration(music)
			net.Start("nAPlayMusic")
			net.WriteString(music)
			net.Send(inflictor:GetAttacker())
		end
	end 
end

function PLUGIN:DoPlayerDeath(ply, attacker, dmg)
	local music = table.Random(Schema:GetSongList(MUSIC_STINGER))
	if (music) then
		net.Start("nAPlayMusic")
		net.WriteString(music)
		net.Send(ply)
	end
end

concommand.Add("ix_playmusicall", function(ply, cmd, args)
	if (ply:IsValid()) then
		if(not CAMI.PlayerHasAccess(ply, "Helix - Music Player", nil)) then return end
		if (#args == 0) then
			ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid Value")
			return
		end
		local arg = string.lower(args[ 1 ])
		local song = nil

		if (arg == "noplay" or arg == "music_noplay" or tonumber(arg) == 0) then
			song = MUSIC_NOPLAY
			arg = "noplay"
		elseif (arg == "ambient" or arg == "music_ambient" or tonumber(arg) == 1) then
			song = MUSIC_AMBIENT
			arg = "ambient"
		elseif (arg == "combat" or arg == "music_combat" or tonumber(arg) == 2) then
			song = MUSIC_COMBAT
			arg = "combat"
		elseif (arg == "stinger" or arg == "song_stinger" or tonumber(arg) == 3) then
			song = MUSIC_STINGER
			arg = "stinger"
		else
			song = arg
		end

		if (song) then
			local music = song

			if (type(song) == "number") then
				music = table.Random(Schema:GetSongList(song))
			end

			net.Start("nAPlayMusic")
			net.WriteString(music)
			net.Broadcast()
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid Value")
		end
	end
end)

concommand.Add("ix_stopmusic", function(ply, cmd, args)
	if (ply:IsValid()) then
		if(not CAMI.PlayerHasAccess(ply, "Helix - Music Player", nil)) then return end
		net.Start("nAStopMusic")
		net.Broadcast()
	end
end)