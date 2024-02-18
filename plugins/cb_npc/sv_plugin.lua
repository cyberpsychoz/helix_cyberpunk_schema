local PLUGIN = PLUGIN

-- АВТОСПАВНЕР, СДЕЛАЛ АРИСТ, ЛЮБЛЮ ЕГО ОБОЖАЮ БОЖЕ
local MSPlaces = {
	--class,position,amount,radius

   --ТРЕТИЙ ДИСТРИКТ
	{"ix_booster_low", Vector(2150.749756, -599.781738, -31.005354), 3, 75},
   {"ix_booster_low", Vector(2313.602539, -1231.421997, -31.005350), 2, 35},
   {"ix_booster_low", Vector(2239.761475, -1787.885132, -31.005352), 1, 35},

   --КАНАЛЫ
   {"ix_booster_low", Vector(-6471.33203125, 456.40084838867, -1090.4787597656), 3, 75},
   {"ix_booster_low", Vector(-7046.2368164063, 450.72973632813, -1090.1987304688), 3, 75},
   {"ix_booster_low", Vector(-6257.3784179688, 1520.1193847656, -1086.3587646484), 1, 1},
   {"ix_booster_low", Vector(-6229.3588867188, 2187.5766601563, -1115.3587646484), 1, 1},
   {"ix_booster_low", Vector(-6491.6689453125, 2546.3369140625, -1086.3587646484), 2, 50},
   {"ix_booster_low", Vector(-5400.6333007813, 2318.2023925781, -1086.3587646484), 3, 85},

   --БАР
   {"ix_fixer_low", Vector(5.6220879554749, -23.999099731445, -52.96875), 1, 1},

   --ВТОРОЙ ДИСТРИКТ
   {"ix_citizen", Vector(-889.75610351563, -212.51184082031, -55.96875), 1, 1},

   -- ГЛАВНАЯ ПЛОЩАДЬ
   {"ix_citizen", Vector(-5185.009766, 140.683655, -55.968750), 1, 50},
}

for k,v in ipairs(MSPlaces) do v.Active = {} end

local function MobSpawn()
	for k,mdata in ipairs(MSPlaces) do
	
		--cleanup dead-invalid
		local toremove = {}
		for k,v in ipairs(mdata.Active) do
			if !IsValid(v) then table.insert(toremove,v) end
		end
		for k,v in ipairs(toremove) do
			table.RemoveByValue(mdata.Active,v)
		end
		
		--spawn more
		if table.Count(mdata.Active) < mdata[3] then					
			for k1=0,(mdata[3]-table.Count(mdata.Active))-1 do
				timer.Simple(k1*2,function()
					local mob = ents.Create(mdata[1])
					local pos = mdata[2]+Vector(math.Rand(-mdata[4],mdata[4]),math.Rand(-mdata[4],mdata[4]),10)
					
					-- Check for other NPCs before spawning
					local tr = util.TraceHull({
						start = pos,
						endpos = pos,
						mins = mob:OBBMins(),
						maxs = mob:OBBMaxs(),
						mask = MASK_NPCSOLID
					})

					if not tr.Hit then
						mob:SetPos(pos)
						mob:SetAngles(Angle(0,math.Rand(-180,180),0))
						mob:Spawn()
						mob:Activate()
						table.insert(mdata.Active,mob)
					end
				end)
			end
		end
	end
end

timer.Create("arist_mobs", 10, 0, MobSpawn)

-- АНИМКИ
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