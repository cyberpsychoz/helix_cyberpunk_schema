
local PLUGIN = PLUGIN;

PLUGIN.name = "Quester npc"
PLUGIN.author = "Ross"

ix.command.Add("SpawnTalker", {
	description = "SpawnTalker",
	superAdminOnly = true,
    OnRun = function(self, client)
        local trace = client:GetEyeTraceNoCursor()
        if trace.Hit then
            local talker = ents.Create('talker_npc')
            talker:SetPos(trace.HitPos)
            talker:Spawn()
        end;

        client:Notify('Talker spawned.')
	end
})

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")