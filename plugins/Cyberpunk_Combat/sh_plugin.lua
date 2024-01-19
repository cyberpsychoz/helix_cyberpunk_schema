local PLUGIN = PLUGIN

PLUGIN.name = "Cyberpunk RED Battle System"
PLUGIN.author = "Крыжовник"
PLUGIN.description = "ПОЖАЛУЙСТА"

properties.Add("target_capture", {
    MenuLabel = "Захват цели",
    Order = 1000,
    MenuIcon = "materials/icons/eye.png",

    Filter = function(self, ent, ply)
        return IsValid(ent)
    end,

    Action = function(self, ent)
        self:MsgStart()
            net.WriteEntity(ent)
        self:MsgEnd()
    end,

    Receive = function(self, length, ply)
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end
        ply:GetCharacter():SetData("target", ent)
    end
})

ix.config.Add("Turn Based Combat On/Off", true, "Включает и выключает пошаговый бой.", nil, {
	category = "Turn Based Combat System"
})

ix.config.Add("radius", 1200, "Базовый радиус, в котором другие NPC/игроки присоединятся к боевому столкновению.", nil, {
	data = { min = 100, max = 2000 },
	category = "Turn Based Combat System"
})

ix.config.Add("movementradius", 5, "Как далеко игрок может отойти от места начала своего хода, прежде чем потеряет AP, это действует как множитель расстояния. На это влияет: Атлетика.", nil, {
	data = { min = 1, max = 2000 },
	category = "Turn Based Combat System"
})

ix.config.Add("warmuptimer", 5, "Количество времени до фактического начала боя. Дает сделать выбор цели.", nil, {
	data = { min = 1, max = 60 },
	category = "Turn Based Combat System"
})

ix.config.Add("playeractionpoints", 3, "Количество действий, которые игрок может предпринять в течение этого хода. Зависит от: Реакция, Ловкость.", nil, {
	data = { min = 1, max = 100 },
	category = "Turn Based Combat System"
})

ix.config.Add("playertimeammount", 60, "Количество времени, которое есть у игрока до того, как он включит его.", nil, {
	data = { min = 1, max = 180 },
	category = "Turn Based Combat System"
})

ix.config.Add("npctimeammount", 5, "Количество времени, которое есть у NPC в бою.", nil, {
	data = { min = 1, max = 60 },
	category = "Turn Based Combat System"
})


PLUGIN.TotalCombats = PLUGIN.TotalCombats or {  }

PLUGIN.Data = {  }

PLUGIN.IgnoredNPCs = { -- NPCs that you don't enter turn based conbat with, most flying NPCs should be added due to them not liking to freeze when not there turn is active
	['npc_turret_floor'] = true,
	['npc_rollermine'] = true,
	['npc_manhack'] = true,
	['npc_clawscanner'] = true,
	['npc_cscanner'] = true,
	['npc_crow'] = true,
	['npc_pigeon'] = true,
	['npc_seagull'] = true,
	['npc_grenade_frag'] = true,
	['npc_combine_camera'] = true,
	['npc_stalker'] = true,
	['npc_helicopter'] = true,
	['worldspawn'] = true,
	['env_fire'] = true,
}

function PLUGIN:StartCommand( ply, cmd )
	if ply:GetNWBool( "IsInCombat", false ) then
		if ply:GetNWBool( "WarmUp", false) or !ply:GetNWBool( "MyTurn", false) then
			cmd:ClearMovement() 
			cmd:ClearButtons()
		end
	end
end

function PLUGIN:BeginWarmUp( entity )
    self.Data[1] = "WarmUp" -- current state
    self.Data[2] = ix.config.Get("warmuptimer", 5) + CurTime() -- timer for warmup, and turns
    self.Data[3] = 0 -- player counter
    self.Data[4] = 0 -- NPC counter
    self.Data[5] = 6 -- turn pointer
    if entity:GetClass() == "player" then
        entity:SetNWBool( "IsInCombat", true )
        entity:SetNWBool( "WarmUpBegin", true )
        --entity:SetMaterial("models/shiny") -- just for testing
        entity:SetNWBool( "WarmUp", true) 
        table.insert( self.Data, entity )
    elseif entity:IsNPC() then
        entity:SetNWBool( "IsInCombat", true )
        --entity:SetMaterial("models/shiny") -- just for testing
        entity:SetNWBool( "WarmUp", true)
        entity:SetNWBool("MyTurn", false)
        table.insert( self.Data, entity )
    end
end

if (SERVER) then
    hook.Add( "PlayerButtonDown", "StartCombatOnJ", function( ply, button )
        if ( button == KEY_J ) and not ply:GetNWBool("IsInCombat") then
            --print("ПРОВЕРКА ХУКА, ХУКА БОЯ!")
            --ply:ChatPrint("ПРОВЕРКА")
            --PLUGIN:BeginWarmUp(ply)
            for k, v in pairs(ents.GetAll()) do
                if v:GetClass() == "player" or v:IsNPC() and PLUGIN.IgnoredNPCs[v:GetClass( )] == nil then
                    timer.Simple( 0.01, function()
                        local trace = util.TraceLine{
                            start = ply:EyePos(),
                            endpos = v:EyePos(),
                            mask  = MASK_SOLID_BRUSHONLY,
                        }
                        if !trace.Hit then
                            if ply:EyePos():Distance( v:EyePos() ) <= ix.config.Get("radius", 500) then
                                PLUGIN:BeginWarmUp( v )
                            end
                        end
                    end)
                end
            end
        end
    end)

	-- АТАКА
	hook.Add("PlayerButtonDown", "DamageTargetOnKeyPress", function(ply, button)
		if button == KEY_H then
			local target = ply:GetCharacter():GetData("target")
			if IsValid(target) then
				local isNPC = target:IsNPC()  -- Проверяем, является ли цель NPC
				local evasionSkill = isNPC and target.Evasion or ply:GetCharacter():GetSkill("evasion")  -- Получаем соответствующий навык уклонения
	
				local weapon = ply:GetCharacter():GetData("weapon")
				local dmgskill = 0
				local totaldamage = 0
				if weapon then
					dmgskill = isNPC and weapon.damage or ply:GetCharacter():GetSkill(weapon.skill) + weapon.damage
					totaldamage = math.random(0, dmgskill)
					local weaponRange = weapon.destination or 100
					local targetPos = target:GetPos()
					local plyPos = ply:GetPos()
					local direction = (targetPos - plyPos):GetNormalized()
					local trace = util.TraceLine({
						start = plyPos,
						endpos = plyPos + direction * weaponRange,
						filter = ply
					})
					if trace.Hit and trace.Entity != target then
						ply:SendLua(string.format([[chat.AddText(Color(194, 103, 103), "Цель сейчас находится за укрытием!")]]))
						return
					elseif not trace.Hit then
						ply:SendLua(string.format([[chat.AddText(Color(194, 103, 103), "Ваше оружие имеет недостаточный радиус для поражения цели!")]]))
						return
					end
				else
					ply:SendLua(string.format([[chat.AddText(Color(194, 103, 103), "У вас нет оружия, вы атакуете голыми руками!")]]))
					return
				end
	
				if weapon.skill == "pistols" or weapon.skill == "rifles" or weapon.skill == "energy_weapons" then
					if ply:GetNWBool("IsInCombat", false) then
						if ply:GetNWBool("MyTurn", false) then
							local AP = ply:GetNWInt("AP", 0)
							if AP > 0 then
								local attackerShootingSkill = ply:GetCharacter():GetSkill("shooting")
								local targetEvasionSkill = evasionSkill
								local randomHit = math.random(0, attackerShootingSkill)
								local randomMiss = math.random(0, targetEvasionSkill)
								if randomHit >= randomMiss then
									local targetArmorClass = isNPC and target.Armor or target:GetData("armorclass")
									local weaponPenetration = weapon.penetration
									if weaponPenetration > targetArmorClass then
										if isNPC then
											ix.chat.Send(ply, "me", " атакует " .. target.PrintName .. " c помощью " .. weapon.name .. " и наносит ему " .. totaldamage .. ".")
										else
											ix.chat.Send(ply, "me", " атакует " .. target:GetName() .. " c помощью " .. weapon.name .. " и наносит ему " .. totaldamage .. ".")
										end
										target:TakeDamage(totaldamage, ply, ply)
										ply:SetNWInt("AP", AP - 1)
									else
										if isNPC then
											ix.chat.Send(ply, "me", " атакует " .. target.PrintName .. " c помощью " .. weapon.name .. " и пуля рикошетит!")
										else
											ix.chat.Send(ply, "me", " атакует " .. target:GetName() .. " c помощью " .. weapon.name .. " и пуля рикошетит!")
										end
										ply:SetNWInt("AP", AP - 1)
									end
								else
									if isNPC then
										ix.chat.Send(ply, "me", " атакует " .. target.PrintName .. " c помощью " .. weapon.name .. " и промахивается!")
									else
										ix.chat.Send(ply, "me", " атакует " .. target:GetName() .. " c помощью " .. weapon.name .. " и промахивается!")
									end
									ply:SetNWInt("AP", AP - 1)
								end								
							else
								ply:SendLua(string.format([[chat.AddText(Color(194, 103, 103), "Недостаточно очков действия для атаки!")]]))
								return
							end
						else
							ply:SendLua(string.format([[chat.AddText(Color(194, 103, 103), "Сейчас не ваш ход для атаки!")]]))
						end
					else
						ply:SendLua(string.format([[chat.AddText(Color(194, 103, 103), "Вы не можете атаковать, пока не находитесь в бою!")]]))
					end
				else
					ply:SendLua(string.format([[chat.AddText(Color(194, 103, 103), "Пока что вы не можете использовать оружие ближнего боя!")]]))
				end
			else
				ply:SendLua(string.format([[chat.AddText(Color(194, 103, 103), "Невозможно нанести урон по неопознанной цели!")]]))
			end
		end
	end)	
	
	function PLUGIN:ResetCombatStatus(client)
		timer.Simple( 0.1, function()
			client:SetNWBool( "WarmUpBegin", false )
			client:SetNWBool( "MyTurn", false )
			client:SetNWBool( "IsInCombat", false )
			client:SetNWBool( "WarmUp", false)
			client:SetNWFloat( "Timeramount", 0 )
			client:SetNWBool("TryingToLeave", false)
			client:SetNWBool("PlayerTurnCheck", false)
			client:SetNWBool("TryingToLeave", false)			
		end)
	end
	
	function PLUGIN:PlayerSpawn(client)
		if !table.IsEmpty(self.TotalCombats) then 
			for k, v in pairs(self.TotalCombats) do
				for k2, v2 in pairs(v) do
					if IsEntity( v2 ) then
						if IsValid( v2 ) then
							if v2 == client then
								table.remove( v, k2 )
								table.insert( v, k2 , NULL  )
							end
						end
					end
				end
			end
		end
		self:ResetCombatStatus(client)
	end

	function PLUGIN:PlayerDeath(client)
		if !table.IsEmpty(self.TotalCombats) then 
			for k, v in pairs(self.TotalCombats) do
				for k2, v2 in pairs(v) do
					if IsEntity( v2 ) then
						if IsValid( v2 ) then
							if v2 == client then
								table.remove( v, k2 )
								table.insert( v, k2 , NULL )
							end
						end
					end
				end
			end
		end
		self:ResetCombatStatus(client)
	end

    --[[
	function PLUGIN:EntityTakeDamage( target, dmg ) -- make this work better, IE ignore NPCs that are on the ignore list
		target:SetNWBool("TryingToLeave", false)
		if ix.config.Get("Turn Based Combat On/Off", true) then
			if (self.IgnoredNPCs[dmg:GetInflictor():GetClass( )] == nil) == (self.IgnoredNPCs[target:GetClass( )] == nil) then
				-- adds the NPC/player to the combat if they shoot at a player/npc already in that combat
				if !dmg:GetInflictor():GetNWBool( "IsInCombat", false ) then
					if !table.IsEmpty(self.TotalCombats) then
						for k, v in pairs(self.TotalCombats) do
							for k2, v2 in pairs(v) do
								if target == v2 then
									if dmg:GetInflictor():GetClass() == "player" and dmg:GetInflictor():Alive() then
										dmg:GetInflictor():SetNWBool( "WarmUpBegin", true )
										--ent:SetMaterial("models/shiny") -- just for testing
										dmg:GetInflictor():SetNWBool( "WarmUp", true) 
										dmg:GetInflictor().btimer = false
										table.insert( v, #v, dmg:GetInflictor() )
										if v[1] == "Combat" then
											dmg:GetInflictor():SetNWBool( "WarmUpBegin", false )
										end
										dmg:GetInflictor():SetNWBool( "IsInCombat", true )
										break
									elseif dmg:GetInflictor():IsNPC() then
										--dmg:GetInflictor():SetMaterial("models/shiny") -- just for testing
										dmg:GetInflictor():SetNWBool( "WarmUp", true)
										dmg:GetInflictor():SetNWBool("MyTurn", false)
										table.insert( v, #v, dmg:GetInflictor() )
										dmg:GetInflictor():GetNWBool("MyTurn", false)
										dmg:GetInflictor():SetNWBool( "IsInCombat", true )
										break
									end
								end
							end
						end
					end
				end
				
				-- prevents damage from being taken if the player isn't in combat
				if !dmg:GetInflictor():GetNWBool( "IsInCombat", false ) and (dmg:GetInflictor():IsNPC() or dmg:GetInflictor():GetClass() == "player") then
					dmg:SetDamage( 0 )
				end

				if !target:GetNWBool( "IsInCombat", false ) then
					if !(target:IsNPC() and dmg:GetInflictor():IsNPC()) then
						if target:GetClass() == "player" or target:IsNPC() then
							for k, v in pairs(ents.GetAll()) do
								if v:GetClass() == "player" or v:IsNPC() and self.IgnoredNPCs[v:GetClass( )] == nil then
									timer.Simple( 0.01, function()
										local trace = util.TraceLine{
											start = target:EyePos(),
											endpos = v:EyePos(),
											mask  = MASK_SOLID_BRUSHONLY,
										}
										if !trace.Hit then
											if target:EyePos():Distance( v:EyePos() ) <= ix.config.Get("radius", 500) then
												self:BeginWarmUp( v )
											end
										end
									end)
								end
							end
						end
					end
				elseif target:GetNWBool( "IsInCombat", false ) and !dmg:GetInflictor():GetNWBool( "IsInCombat", false ) then
					self:AutoJoinCombat( dmg:GetInflictor() )
				end
			end
		end
	end]]
	
	function PLUGIN:AutoJoinCombat( ent )
		if ix.config.Get("Turn Based Combat On/Off", true) then
			if !ent:GetNWBool( "IsInCombat", false ) then
				if self.IgnoredNPCs[ent:GetClass()] == nil then
					if IsValid( ent ) then
						timer.Simple( 0.01, function()
							if !table.IsEmpty(self.TotalCombats) then -- just for server starts
								for k, v in pairs(self.TotalCombats) do 
									for k2, v2 in pairs(v) do
										if IsEntity( v2 ) then
											if IsValid( v2 ) then
												local trace = util.TraceLine{
													start = ent:EyePos(),
													endpos = v2:EyePos(),
													mask  = MASK_SOLID_BRUSHONLY,
												}
												if !trace.Hit then
													if ent:EyePos():Distance( v2:EyePos() ) <= ix.config.Get("radius", 500) then
														if ent:GetClass() == "player" and ent:Alive() then
															ent:SetNWBool( "WarmUpBegin", true )
															--ent:SetMaterial("models/shiny") -- just for testing
															ent:SetNWBool( "WarmUp", true) 
															ent.btimer = false
															table.insert( v, #v, ent )
															if v[1] == "Combat" then
																ent:SetNWBool( "WarmUpBegin", false )
															end
															ent:SetNWBool( "IsInCombat", true )
															break
														elseif ent:IsNPC() then
															--ent:SetMaterial("models/shiny") -- just for testing
															ent:SetNWBool( "WarmUp", true)
															ent:SetNWBool("MyTurn", false)
															table.insert( v, #v, ent )
															ent:GetNWBool("MyTurn", false)
															ent:SetNWBool( "IsInCombat", true )
															break
														end
													end
												end
											end
										end
									end
								end
							end
						end)
					end
				end
			end
		end
	end
	
	function PLUGIN:PlayerTick( player, mv )
		self:AutoJoinCombat( player )
	end
	
	function PLUGIN:OnEntityCreated( entity )
		if entity:IsNPC() then
			self:AutoJoinCombat( entity )
		end
	end

	function PLUGIN:Think()
		timer.Simple( 0.01, function()
			for k, v in pairs(ents.GetAll()) do
				if v:IsNPC() then 
					if v:IsMoving() then
						self:AutoJoinCombat( v )
					end
				end
			end
			-- Multidimential table setup
			if !table.IsEmpty(self.Data) then -- A TON OF BULLSHIT JUST TO GET MULTIDIMENTIONAL TABLES TO BE CREATED
				local NewTable = {}
				for i, v in pairs( self.Data ) do
					NewTable[ #NewTable + 1 ] = v
				end
				table.Empty(self.Data)
				self.TotalCombats[ #self.TotalCombats + 1 ] = NewTable
			end

			-- A work around for players getting bugged into constantly being in combat
			if table.IsEmpty(self.TotalCombats) then 
				for k, v in pairs(player.GetAll()) do
					self:ResetCombatStatus(v)
				end
			end

			if !table.IsEmpty(self.TotalCombats) then -- just for server starts
				if ix.config.Get("Turn Based Combat On/Off", true) then
					for k, v in pairs(self.TotalCombats) do -- Goes through the every single combat encounter table
						-- Warmup Timer
						if v[1] == "WarmUp" then
							if v[2] < CurTime() then
								v[1] = "Combat"
								v[#v + 1] = "."
								self:BeginCombat( v )
							end
						end
						
						
						-- Player and NPC counter
						v[3] = 0
						v[4] = 0
						for k2, v2 in pairs(v) do
							if IsEntity( v2 ) then
								if IsValid( v2 ) then
									if IsEntity( v2 ) then
										if v2:GetClass() == "player" then
											v[3] = v[3] + 1
											v2:SetNWFloat("Timeramount", v[2])
										elseif v2:IsNPC() then
											v[4] = v[4] + 1
										end
									end
								end
							end
						end
						for k2, v2 in pairs(v) do
							if IsEntity( v2 ) then
								if IsValid( v2 ) then
									if v2:GetClass() == "player" then
										v2:SetNWInt("CombatNPCCount", v[4])
										v2:SetNWInt("CombatPlayerCount", v[3])
									else
										if !v2:GetNWBool("MyTurn", false) then -- freeze NPCs
											v2:SetCondition( 67 )
										else -- unfreeze NPCs
											v2:SetCondition( 68 )
										end
									end
								--else
								--	table.remove( v, k2 )
								end
							end
						end
						
						-- Remove dups
						timer.Simple( 0.1, function()
							for k2, v2 in pairs(v) do
								for k3, v3 in pairs(v) do
									if v2 == v3 and !(k2 == k3) and IsEntity( v2 ) and IsEntity( v3 ) then
										table.remove( v, k3 )
									end
								end
							end
						end)
						
						-- the end condition/table remover
						timer.Simple( 0.1, function()
							if ((v[4] == 0 and v[3] <= 1) or (v[4] >= 0 and v[3] == 0)) or v[1] == "End Combat" then
								for k2, v2 in pairs(v) do
									if IsEntity( v2 ) then
										if IsValid( v2 ) then
											if v2:GetClass() == "player" then
												self:ResetCombatStatus(v2)
											else
												timer.Simple( 1, function()
													v2:SetCondition( 68 )
													v2:SetNWBool( "IsInCombat", false )
													--v2:SetMaterial("") -- just for testing
													v2:SetNWBool( "MyTurn", true )
													v2:SetNWBool( "WarmUp", false)
												end)
											end
										end
									end
								end
								table.remove( self.TotalCombats, k )
							end	
						end)

						-- Turn based combat
						if v[1] == "Combat" then
							if IsEntity(v[v[5]]) and IsValid( v[v[5]] ) then
								if v[v[5]]:GetClass() == "player" then
									-- the code that allows the player to do their turn
									
									-- at the start of the players turn ran once
                                    local ply = v[v[5]]
                                    local char = ply:GetCharacter()
									if v[2] - ix.config.Get("playertimeammount", 10) + 0.1 >= CurTime() then 
										v[v[5]]:SetNWInt("AP", ix.config.Get("playeractionpoints", 3) + char:GetAttribute("ref", 0))
										v[v[5]]:SetNWVector( "StartPos", v[v[5]]:GetPos() )
										v[v[5]]:SetNWFloat("TurnTimer", v[2])
										
										-- Checks for if the player tried to leave there last turn and checks if all players in combat want to end combat
										if v[v[5]]:GetNWBool("PlayerTurnCheck", true) and v[v[5]]:GetNWBool("TryingToLeave", false) then 
											for k2, v2 in pairs(v) do
												if IsEntity( v2 ) and v2:IsPlayer() then
													if v2:GetNWBool("TryingToLeave", false) then
														v[1] = "End Combat"
													else
														v[1] = "Combat"
														break
													end
												end 
											end
										else 
											v[v[5]]:SetNWBool("PlayerTurnCheck", false)	
										end	
									end
									
                                    --local test= v[v[5]]
                                    --local char = test:GetCharacter()
									-- The lose of AP when the player moves
									if v[v[5]]:GetNWVector( "StartPos", v[v[5]]:GetPos() ):Distance( v[v[5]]:GetPos() ) > (ix.config.Get("movementradius", 10) + char:GetSkill("athletic", 0)) * v[v[5]]:GetNWInt("AP", ix.config.Get("playeractionpoints", 3) + char:GetAttribute("ref", 0)) then
										local trace = util.TraceLine( {
											start = v[v[5]]:GetPos()+Vector(0,0,30),
											endpos = v[v[5]]:GetPos()-Vector(0,0,10000),
											filter = v[v[5]]
										})
										
										v[v[5]]:SetNWVector( "StartPos", trace.HitPos )
										v[v[5]]:SetNWInt("AP", v[v[5]]:GetNWInt("AP", 3) - 1)
									end
									
									-- skip your turn with walk
									if v[v[5]]:KeyPressed( IN_WALK ) and IsValid(v[v[5]]) and v[v[5]]:Alive() and IsValid(v[v[5]]:GetActiveWeapon()) then
										-- if the player uses AP then skips it's not considered tryingtoleave
										if v[v[5]]:GetNWInt("AP", 3) == ix.config.Get("playeractionpoints", 3) then
											v[v[5]]:SetNWBool("TryingToLeave", true)
										end 
										v[v[5]]:SetNWInt("AP", 0)
									end
									
									-- if player fires/holds trigger they lose AP for each second
									if v[v[5]]:KeyPressed( IN_ATTACK ) then
										v[v[5]]:SetNWInt("AP", v[v[5]]:GetNWInt("AP", 3) - 1)
										v[v[5]]:SetNWFloat("TimeBetweenShots", CurTime() + 1)
									end
									
									if v[v[5]]:KeyDown( IN_ATTACK ) and IsValid(v[v[5]]) and v[v[5]]:Alive() and IsValid(v[v[5]]:GetActiveWeapon()) then
										timer.Simple( 0.01, function()
											if v[v[5]]:GetNWFloat("TimeBetweenShots", 0) <= CurTime() then
												v[v[5]]:SetNWInt("AP", v[v[5]]:GetNWInt("AP", 3) - 1)
												v[v[5]]:SetNWFloat("TimeBetweenShots", CurTime() + 1)
											end
										end)
									end
									

									--ran constantly in the turn
									--timer.Simple( 0.11, function()
										v[v[5]]:SetNWBool( "MyTurn", true )
										v[v[5]]:SetNWBool( "WarmUp", false )
									--end)	
									
									-- ran at the end of the players turn
									if v[2] < CurTime() or v[v[5]]:GetNWInt("AP", 0) <= 0 then -- The timer to count how long the player has till their turn is up
										if v[v[5]]:GetNWInt("AP", 0) == (ix.config.Get("playeractionpoints", 3) + char:GetAttribute("ref", 0)) then
											v[v[5]]:SetNWBool("TryingToLeave", true)
										end

										if IsValid(v[v[5] + 1]) then
											if v[v[5] + 1]:IsNPC() then
												v[2] = ix.config.Get("npctimeammount", 5) + CurTime()
											else
												v[2] = ix.config.Get("playertimeammount", 10) + CurTime()
											end
										else
											if v[6]:IsNPC() and IsValid(v[6]) then
												v[2] = ix.config.Get("npctimeammount", 5) + CurTime()
											else
												v[2] = ix.config.Get("playertimeammount", 10) + CurTime()
											end
										end
										if v[v[5]]:GetNWBool("TryingToLeave", false) then
											v[v[5]]:SetNWBool("PlayerTurnCheck", true)
										end	
										v[v[5]]:SetNWBool( "MyTurn", false )
										v[5] = v[5] + 1
									end
								elseif v[v[5]]:IsNPC() then
									-- the code that allows the NPC to do their turn
									
									v[v[5]]:SetNWBool( "MyTurn", true )
									
									
									if v[2] < CurTime() then -- The timer to count how long the NPC has till their turn is up
										if IsValid(v[v[5] + 1]) then
											if v[v[5] + 1]:IsNPC() then
												v[2] = ix.config.Get("npctimeammount", 5) + CurTime()
											else
												v[2] = ix.config.Get("playertimeammount", 10) + CurTime()
											end
										else
											if v[6]:IsNPC() and IsValid(v[6]) then
												v[2] = ix.config.Get("npctimeammount", 5) + CurTime()
											else
												v[2] = ix.config.Get("playertimeammount", 10) + CurTime()
											end
										end
										v[v[5]]:SetNWBool( "MyTurn", false )
										v[5] = v[5] + 1
									end
								end
							elseif !IsEntity(v[v[5]]) then
								v[5] = 6
							else
								if IsValid(v[v[5] + 1]) then
									if v[v[5] + 1]:IsNPC() then
										v[2] = ix.config.Get("npctimeammount", 5) + CurTime()
									else
										v[2] = ix.config.Get("playertimeammount", 10) + CurTime()
									end
								end
								v[5] = v[5] + 1
							end
						end
					end
				end
			end
		end)
	end
	
	
	
	function PLUGIN:BeginCombat( tab )
		for k, v in pairs(tab) do
			if IsEntity( v ) then
				if IsValid( v ) and v:GetClass() == "player" then
					v:SetNWBool( "WarmUpBegin", false )
				end
			end
		end
		tab[2] = ix.config.Get("playertimeammount", 10) + CurTime()
	end
end

if (CLIENT) then
	local w, h = ScrW(), ScrH()
	surface.CreateFont( "TBCWarmUpFont", {
	font = "Arial",
	extended = false,
	size = 20 * h/500,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = true,
	} )
	
	local w, h = ScrW(), ScrH()
	surface.CreateFont( "TBCSmallFont", {
	font = "Arial",
	extended = false,
	size = 14 * h/500,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = true,
	} )
	
	local w, h = ScrW(), ScrH()
	surface.CreateFont( "TBCTinyFont", {
	font = "Arial",
	extended = false,
	size = 7 * h/500,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = true,
	} )
	
	function PLUGIN:factorial(n)
		if (n <= 1) then
			return 1
		else
			return n + self:factorial(n - 1)
		end
	end
	
	function draw.Circle( x, y, radius, seg )
		local cir = {}

		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( i / seg ) * -360 )
			table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 ) -- This is needed for non absolute segment counts
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		surface.DrawPoly( cir )
	end
	
	
	function PLUGIN:PostDrawOpaqueRenderables( )
		if LocalPlayer() then
			local ply = LocalPlayer()
			local char = ply:GetCharacter()
			if ply:GetNWBool( "IsInCombat", false ) then
				if ply:GetNWBool( "MyTurn", false ) then
					local trace = util.TraceLine( {
						start = ply:GetPos()+Vector(0,0,30),
						endpos = ply:GetPos()-Vector(0,0,1000),
						filter = ply
					})
					
					cam.Start3D2D( ply:GetNWVector( "StartPos", ply:GetPos() ) + trace.HitNormal, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), 1 )
						
						surface.SetDrawColor( 0, 0, 0, 200)
						draw.NoTexture()
						draw.Circle( 0, 0, (ix.config.Get("movementradius", 10) + char:GetSkill("athletic", 0)) * self:factorial(ply:GetNWInt("AP", ix.config.Get("playeractionpoints", 3) + char:GetAttribute("ref", 0), 50 )), 25)
						
					cam.End3D2D()
					
					cam.Start3D2D( ply:GetNWVector( "StartPos", ply:GetPos() ) + trace.HitNormal, trace.HitNormal:Angle() + Angle( 90, 0, 0 ), 1 )
					
						surface.SetDrawColor( 94, 180, 255, 255)
						draw.NoTexture()
						draw.Circle( 0, 0, (ix.config.Get("movementradius", 10) + char:GetSkill("athletic", 0)) * ply:GetNWInt("AP", ix.config.Get("playeractionpoints", 3) + char:GetAttribute("ref", 0)), 25 )
						
					cam.End3D2D()
					
					
				end
			else
				for k, v in pairs(ents.GetAll()) do
					if v:IsNPC() or v:GetClass() == "player" then 
						if v:GetNWBool( "IsInCombat", false ) then
							render.SetColorMaterial()
							render.DrawSphere( v:GetNWVector( "StartPos", v:EyePos() ), ix.config.Get("radius", 500), 50, 50,Color(0,0,0,100))
						end
					end
				end
			end
		end
	end
	
	function PLUGIN:HUDPaint()
		local lclient = LocalPlayer() 
		
		if lclient:GetNWBool( "IsInCombat", false ) then
			if lclient:GetNWBool( "WarmUpBegin", false ) then
				draw.SimpleText("Выберите цель через контекстное меню! Бой начнется через: "..  math.Round(lclient:GetNWFloat("Timeramount", 0) - CurTime(), 1) .." секунд.", "TBCWarmUpFont", w/2, h/5, Color(47, 175, 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
				
				draw.SimpleText("НАЧАЛО БОЯ!", "TBCWarmUpFont", w/2, h/7, Color(47, 175, 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			if lclient:GetNWBool( "MyTurn", false ) then
				draw.SimpleText("Ваш ход", "TBCWarmUpFont", w/2, h/7, Color(191, 191, 191, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
				draw.SimpleText("[ЛОВКОСТЬ] Очки действий: ".. lclient:GetNWInt("AP", 3), "TBCSmallFont", w/2, h/1.25, Color(194, 191, 191), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				
				draw.SimpleText("[РЕАКЦИЯ] Времени осталось: "..  math.Round(lclient:GetNWFloat("TurnTimer", 0) - CurTime(), 1) .." секунд.", "TBCWarmUpFont", w/2, h/5, Color(191, 191, 191, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)	
			end
			
			local walkBind = input.LookupBinding("+walk") or "ALT"
			draw.SimpleText("ДЕЙСТВИЯ | Пропуск хода: " ..walkBind.. " | ЕСЛИ ВСЕ ИГРОКИ ПРОПУСКАЮТ ХОД, БОЙ ЗАКАНЧИВАЕТСЯ", "TBCTinyFont", w/2, h/1.02, Color(191, 191, 191, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			draw.SimpleText("Количество пустых оболочек в бою: "..lclient:GetNWInt("CombatNPCCount", 0).." | Количество живых оболочек в бою: "..lclient:GetNWInt("CombatPlayerCount", 0).." |", "TBCSmallFont", w/2, h/1.05, Color(191, 191, 191, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end