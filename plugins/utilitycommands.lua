
local PLUGIN = PLUGIN

PLUGIN.name = "Utility Commands"
PLUGIN.author = "dave"
PLUGIN.description = "Adds a variety of useful commands."
PLUGIN.license = [[
Copyright 2021 dave
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
PLUGIN.readme = [[
	ADDED COMMANDS:
	/RemoveAllEnts <string class> - Destroys all of the specified entity class (* compatible).
	/CleanUpItems <number time> <bool should send notice> - Destroys all items on the map after the specified amount of time (s).
	/ForceCleanUpItems <bool should send notice> - Immediately destroys all items on the map.
	/ARespawn <player target> - Automatically respawn a character. Leave field blank to respawn yourself.

]]

ix.command.Add("RemoveAllEnts", {
	description = "Destroys all of the specified entity class (* compatible).",
	arguments = {ix.type.string},
	superAdminOnly = true,
	OnRun = function(self, client, targets)

		for _, ent in ipairs(ents.FindByClass(targets)) do
			ent:Remove()
		end
		return "Removed."
		
	end
})

ix.command.Add("CleanUpItems", {
	description = "Destroys all items on the map after the specified amount of time (s).",
	arguments = {ix.type.number, ix.type.bool},
	superAdminOnly = true,
	OnRun = function(self, client, time, shouldNotice)

		if !isnumber(time) then return "Time must be a number!" end

		if shouldNotice then
			ix.chat.Send(client, "event", "[WARNING] All dropped items will be destroyed in "..time.." seconds.")

		end

		timer.Simple(time, function()
			for _, v in ipairs(ents.GetAll()) do
				if v:GetClass() == "ix_item" then 
					v:Remove()

				else continue end

			end
			
		end)
		
		return "Done."

	end
})

ix.command.Add("ForceCleanUpItems", {
	description = "Immediately destroys all items on the map.",
	arguments = {ix.type.bool},
	superAdminOnly = true,
	OnRun = function(self, client, shouldNotice)

		if shouldNotice then
			ix.chat.Send(client, "event", "[WARNING] All dropped items are being destroyed.")

		end

		for _, v in ipairs(ents.GetAll()) do
			if v:GetClass() == "ix_item" then 
				v:Remove()

			else continue end

		end

		return "Done."

	end
})

ix.command.Add("ARespawn", {
	description = "Automatically respawn a character. Leave field blank to respawn yourself.",
	arguments = {bit.bor(ix.type.player, ix.type.optional)},
	adminOnly = true,
	OnRun = function(self, client, ply)

		if !IsValid(ply) then
			if client:Alive() then
				return "You are not dead!"

			end

			client:SetNetVar("deathTime", CurTime() + .1)

		else
			if ply:Alive() then
				return "You are not dead!"

			end

			ply:SetNetVar("deathTime", CurTime() + .1)

		end

		return "Respawning..."

	end
})
