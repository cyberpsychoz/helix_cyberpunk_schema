AddCSLuaFile()

if game.SinglePlayer() then
	timer.Create("SINGLEPLAYERALERT", 1, 0, function()
			ErrorNoHalt( "YOU ARE USING SINGLEPLAYER!!!!!" )
	end)
	return;
end

// Taken from helix;
function R_Include(fileName, realm)
	if (!fileName) then
		error("Nothing to include")
	end
	if ((realm == "server" or fileName:find("sv_")) and SERVER) then
		return include(fileName)
	elseif (realm == "shared" or fileName:find("shared.lua") or fileName:find("sh_")) then
		if (SERVER) then
			AddCSLuaFile(fileName)
		end
		return include(fileName)
	elseif (realm == "client" or fileName:find("cl_")) then
		if (SERVER) then
			AddCSLuaFile(fileName)
		else
			return include(fileName)
		end
	end
end


function R_IncludeDir(directory, realm)
	for _, v in ipairs( file.Find("autorun/"..directory.."/*.lua", "LUA") ) do
		R_Include(directory.."/"..v, realm)
	end
end

function R_IncludeModule(directory)
		local dir = "autorun/" .. directory .. "/"
		local files, directories = file.Find(dir.."*", "LUA" );
		
		for k, v in ipairs(directories) do
				local subDir = dir .. v .. "/"
				for id, name in ipairs( file.Find(subDir.."*.lua", "LUA") ) do
						R_Include(subDir..name)
				end
		end

		for k, v in ipairs(files) do
			R_Include(dir..v)
		end
end;

R_IncludeDir("libraries");
R_IncludeModule("terminal")
R_IncludeModule("objs")