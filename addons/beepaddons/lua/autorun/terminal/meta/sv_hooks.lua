hook.Add( "PlayerDeath", "terminal::playerDeath", function( victim, inflictor, attacker )
    netstream.Start(victim, 'terminal::playerDeath')
end )

hook.Add( "PlayerDisconnected", "terminal::playerDisconnected", function( player )
    if player:GetNWEntity("Terminal") then
		TERMINAL:InterfaceCallback(player)
	end;
end )

hook.Add( "InitPostEntity", "terminal::Init", function()
    TERMINAL:CreateDatabase()
	TERMINAL:LoadData()
end)

hook.Add( "ShutDown", "terminal::ShutDown", function()
    TERMINAL:SaveAll();
	TERMINAL:CheckData();
end)

hook.Add( "PlayerSpawn", "terminal::PlayerSpawn", function ( player )
	player:SetNWEntity("Terminal", nil)
end )