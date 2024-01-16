-- [[ COMMANDS ]] --

--[[
	CHAT: rollgeneric
	DESCRIPTION: Highlights generic rolls made with arbitrary dice and bonuses.
]]--

ix.chat.Register("rollgeneric", {
	format = "** %s выбросил %s %s", 
	color = Color(191, 191, 191),
	CanHear = ix.config.Get("chatRange", 280),
	deadCanChat = true,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		chat.AddText(self.color, string.format(self.format,
			speaker:GetName(), text, data.roll
		))
	end
})

--[[
	CHAT: roll20
	DESCRIPTION: Highlights rolls made with a d20.
]]--



ix.chat.Register("roll20", {
	format = "** %s выбросил %s навыка %s.",
	color = Color(191, 191, 191),
	CanHear = ix.config.Get("chatRange", 280),
	deadCanChat = true,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		chat.AddText(self.color, string.format(self.format,
			speaker:GetName(), text, data.rolltype
		))
	end
})

--[[
	CHAT: roll20attack
	DESCRIPTION: Highlights attack rolls made with a d20.
]]--

ix.chat.Register("roll20attack", {
	format = "** %s получил %s в броске на %s урона.", --"** %s has rolled %s on their Attack roll for %s %s damage."
	color = Color(191, 191, 191),
	CanHear = ix.config.Get("chatRange", 280),
	deadCanChat = true,
	OnChatAdd = function(self, speaker, text, bAnonymous, data)
		chat.AddText(data.color or self.color, string.format(self.format,
			speaker:GetName(), text, data.damage
		))
	end
})