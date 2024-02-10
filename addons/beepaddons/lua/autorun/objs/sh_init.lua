AddCSLuaFile()

hook.Add( "Initialize", "OBJs::precacheModels", function()
		for k, v in pairs(OBJs.types) do
			if v && v.placeholder && v.placeholder != "" then
					util.PrecacheModel( v.placeholder )
			end
		end
end )

hook.Add( "EntityFireBullets", "OBJs::Fire", function( ent, data )
	if ent:IsPlayer() && ent.KIA then
		return false
	end;
end )