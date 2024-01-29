local PLUGIN = PLUGIN

concommand.Add("conflict_dev_npc_printsequences", function(ply)
   if not ( ply:IsDeveloper() ) then return end
   
   local ent = ply:GetEyeTraceNoCursor().Entity
   
   if ( ent and IsValid(ent) and ent:IsNPC() ) then
      for i = 0, ent:GetSequenceCount() do
         print(i.." - "..ent:GetSequenceName(i))
      end
   end
end)

ix.command.Add("NPCForceAnim", {
   description = "Force an NPC to play an animation.",
   arguments = {ix.type.string, bit.bor(ix.type.number, ix.type.optional), bit.bor(ix.type.number, ix.type.optional)},
   OnRun = function(_, ply, anim, time, timereset)
      local ent = ply:GetEyeTraceNoCursor().Entity
      
      if ( ent and IsValid(ent) and ent:IsNPC() ) then
         if ( time ) then
            timer.Simple(time or 2, function()
               ent:ResetSequence(tostring(anim))
            end)
            
            timer.Simple(timereset or 1, function()
               ent:ExitScriptedSequence()
            end)
         else
            ent:ResetSequence(tostring(anim))
            timer.Simple(10, function()
               ent:ExitScriptedSequence()
            end)
         end
      end
   end
   
})