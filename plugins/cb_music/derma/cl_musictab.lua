local PANEL = {}

function PANEL:Init()
	local parent = self:GetParent()

	self:SetWide(150)
	self:Dock(RIGHT)
	self:DockMargin(0, ScrH() * 0.05, 0, 0)

	self.VBar:SetWide(0)
end

vgui.Register("ixMusicPlayerPanel", PANEL, "DScrollPanel")

hook.Add("CreateMenuButtons", "ixMusPanel", function(tabs)
	if (CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Music Player", nil)) then
		tabs["Music Player"] = {
			Create = function(info, container)
				container.infoPanel = container:Add("ixMusicPlayerPanel")
				local musiclist = container:Add("DListView")
				musiclist:Dock(TOP)
				musiclist:SetSize(120, 500)
				musiclist:AddColumn("Song Type"):SetWidth(100)
				musiclist:AddColumn("Song Name"):SetWidth(220)
				musiclist:AddColumn("Length"):SetWidth(100)
				musiclist.Columns[1].Header:SetColor(Color(255, 255, 255, 255))
				musiclist.Columns[2].Header:SetColor(Color(255, 255, 255, 255))
				musiclist.Columns[3].Header:SetColor(Color(255, 255, 255, 255))

				function musiclist:Paint(w, h)

					surface.SetDrawColor(255, 255, 255, 25)
					surface.DrawRect(0, 0, w, h)

					surface.SetDrawColor(ix.config.Get("color"))
					surface.DrawOutlinedRect(0, 0, w, h)
					
				end

				local gcanvas_1 = musiclist.Columns[1].Header
				local gcanvas_2 = musiclist.Columns[2].Header
				local gcanvas_3 = musiclist.Columns[3].Header

				function gcanvas_1:Paint(w, h)
					surface.SetDrawColor(ix.config.Get("color"))
					surface.DrawRect(0, 0, w, h)
				end

				function gcanvas_2:Paint(w, h)
					surface.SetDrawColor(ix.config.Get("color"))
					surface.DrawRect(0, 0, w, h)
				end

				function gcanvas_3:Paint(w, h)
					surface.SetDrawColor(ix.config.Get("color"))
					surface.DrawRect(0, 0, w, h)
				end

				for k, v in pairs(ix.Music) do
					local type = "Main Menu"

					if (v[3] == MUSIC_NOPLAY) then
						type = "Never play"
					end

					if (v[3] == MUSIC_AMBIENT) then
						type = "Ambient"
					end

					if (v[3] == MUSIC_COMBAT) then
						type = "Combat"
					end

					if (v[3] == MUSIC_STINGER) then
						type = "Stinger"
					end

					musiclist:AddLine(type, v[4], string.ToMinutesSeconds(v[ 2 ])).Path = v[1]
				end

				local plyMusicBut = container:Add("DButton")
				plyMusicBut:SetText("Play(All)")
				plyMusicBut:SetColor(Color(255, 255, 255, 255))
				plyMusicBut:SetSize(0, 30)
				plyMusicBut:DockMargin(0, 12, 0, 0)
				plyMusicBut:Dock(TOP)

				function plyMusicBut:Paint( w, h )

					surface.SetDrawColor( 0, 0, 0, 255 )
					surface.DrawRect( 0, 0, w, h )

					surface.SetDrawColor( 0, 200, 0, 255 )
					surface.DrawOutlinedRect( 0, 0, w, h )
					
				end

				function plyMusicBut:DoClick()
					RunConsoleCommand("ix_playmusicall", musiclist:GetSelected()[1].Path)
					surface.PlaySound("buttons/button17.wav")
				end

				local stopMusicBut = container:Add("DButton")
				stopMusicBut:SetText("Stop(All)")
				stopMusicBut:SetColor(Color(255, 255, 255, 255))
				stopMusicBut:SetSize(0, 30)
				stopMusicBut:DockMargin(0, 12, 0, 0)
				stopMusicBut:Dock(TOP)

				function stopMusicBut:Paint( w, h )

					surface.SetDrawColor( 0, 0, 0, 255 )
					surface.DrawRect( 0, 0, w, h )

					surface.SetDrawColor( 200, 0, 0, 255 )
					surface.DrawOutlinedRect( 0, 0, w, h )
					
				end

				function stopMusicBut:DoClick()
					RunConsoleCommand("ix_stopmusic")
					surface.PlaySound("buttons/button18.wav")
				end

				local playSelfMusicBut = container:Add("DButton")
				playSelfMusicBut:SetText("Play(Self)")
				playSelfMusicBut:SetColor(Color(255, 255, 255, 255))
				playSelfMusicBut:SetSize(0, 30)
				playSelfMusicBut:DockMargin(0, 12, 0, 0)
				playSelfMusicBut:Dock(TOP)

				function playSelfMusicBut:Paint( w, h )

					surface.SetDrawColor( 0, 0, 0, 255 )
					surface.DrawRect( 0, 0, w, h )

					surface.SetDrawColor( 128, 0, 255, 255 )
					surface.DrawOutlinedRect( 0, 0, w, h )
					
				end

				function playSelfMusicBut:DoClick()
					Schema:PlayMusic(musiclist:GetSelected()[1].Path)
					surface.PlaySound("buttons/button17.wav")
				end

			end,
		}
	end
end)
