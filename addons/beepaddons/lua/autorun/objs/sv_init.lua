if !SERVER then return end

hook.Add( "PlayerDeath", "OBJs::Death", function( victim, inflictor, attacker )
	local jobCat = victim:GetJobCategory()
		if #OBJs.list > 0 && OBJs.jobs[jobCat] then
			if OBJs.jobs[jobCat][victim] then
					victim.KIA = true
					OBJs.jobs[jobCat][victim] = "dead";
					netstream.Start(victim, 'OBJs::DeadHook', true)
					if !victim.objectiveID then return end;

				local amount = OBJs:PlayersOnTask(victim.objectiveID);
					for k, v in ipairs(amount) do
							netstream.Start(v, 'OBJs::SyncDeathCount', #amount - 1)
					end
			end
		end
end )

hook.Add("PlayerSpawn", "OBJs::Spawned", function(user, transition)
		if user.KIA then 
			user:GodEnable() 
			timer.Simple(0, function()
				user:StripWeapons();
				user:StripAmmo();
				user:Spectate(6)
			end);
		end;
		user:SetNoDraw(user.KIA)
		user:SetNotSolid(user.KIA)
		user:DrawWorldModel(!user.KIA)
		user:DrawShadow(!user.KIA)
		user:SetNoTarget(user.KIA)
end)

hook.Add( "PlayerShouldTakeDamage", "OBJs::DamageTake", function( user, attacker )
		return !user.KIA
end )

hook.Add("PlayerSay", "OBJs::Chat", function (user, text, team, dead)
		if user.KIA then
				for k, v in ipairs(player.GetAll()) do
						if v.KIA then
								netstream.Start(v, 'OBJs::SupressMsg', user:Name(), text)
						end
				end
				return false;
		end
end)

hook.Add("PlayerUse", "OBJs::Use", function(user, ent)
		return !user.KIA;
end)

hook.Add( "PlayerSpawnSWEP", "OBJs::BlockSwep", function( user, class, info )
	return !user.KIA;
end )

hook.Add( "PlayerSpawnSENT", "OBJs::BlockSent", function( user, class )
	return !user.KIA;
end )

hook.Add( "PlayerSpawnNPC", "OBJs::BlockNPC", function( user, type, wpn )
	return !user.KIA;
end )
hook.Add( "PlayerSpawnObject", "OBJs::BlockObject", function( user, model, skin )
	return !user.KIA;
end )

hook.Add( "EntityTakeDamage", "OBJs::EntTakeDMG", function( target, dmginfo )
		if target.Health then
				target:SetHealth(math.Clamp(target:Health() - dmginfo:GetDamage(), 0, target:GetMaxHealth()))
		end
		if target.heal then
				target.heal = math.Clamp(target.heal - dmginfo:GetDamage(), 0, target.maxheal);
		end
end )

hook.Add( "AllowPlayerPickup", "OBJs::PickUps", function( ply, ent )
    if ent.extract then
				return true;
		end
end )

hook.Add("OBJs::Start", "OBJs::Start", function(id)
		local data = OBJs:Check(id);
		if !data then return end;
		local typeExists = OBJs:ExistsType(data.type)
		if !typeExists then return end;
		local opts = util.JSONToTable(typeExists.options);
		local reinforcementOption;
		
		for k, v in pairs(opts) do
			if v.info == "reinforcement" then
				reinforcementOption = k;
				break;
			end
		end
		
		if !reinforcementOption then return end;
		local options = util.JSONToTable(data.options);
		options = util.JSONToTable(options[reinforcementOption]);
		
		local ent = ents.Create("reinforcements")
		ent:SetPos(Vector(options.position))
		ent:SetModel(options.model != "" && options.model or "models/kingpommes/starwars/misc/palp_panel1.mdl")
		ent:Spawn()
		ent:SetOBJid(id);

		data.reinforcementEnt = ent:EntIndex();

		OBJs:SaveData(id, data)
end)

hook.Add("OBJs::Remove", "OBJs::Remove", function(id)
		local data = OBJs:Check(id);
		if !data then return end;
		local ent = data.reinforcementEnt && Entity(data.reinforcementEnt) or false;
		if ent && IsEntity(ent) && ent:GetClass() == "reinforcements" then
				ent:Remove();
		end
end)

hook.Add( "PlayerInitialSpawn", "OBJs::PlayerSpawn", function( ply )
		if #OBJs.list > 0 then
				for i = 1, #OBJs.list do
						ply:SyncObjective(i)
				end
		end
		if ply:IsAdmin() || ply:IsSuperAdmin() then
				ply:SyncList();		
		end
end)

hook.Add("OBJs::Failed", "OBJs::FailedTask", function(id)
		for k, v in pairs(OBJs:PlayersOnTask(id)) do
				v:SendSound("pr/defeat.wav")
		end
end)