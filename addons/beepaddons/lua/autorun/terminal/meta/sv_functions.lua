function TERMINAL:Log(text, color, prefix, id)
	local length = #self.terminals[id]['logs'];
	self.terminals[id]['logs'][length + 1] = {
		text = text, color = color, prefix = prefix
	}
end

function TERMINAL:History(id, cmd)
	return table.insert(self.terminals[id]['history'], {text = cmd})
end;

function TERMINAL:Find(id)
	return self.terminals[id]
end

function TERMINAL:InstallSensor(ID, sensor)
	self.terminals[ID]['sensor'] = sensor;
end

function TERMINAL:ChangePassword(client, oldPassword, newPassword, login)
	local SVterminal = self:Validate(client);

	if SVterminal then
		local id = SVterminal:GetIndex();
		local pword = self.terminals[id]['password']
		if SVterminal:GetLogin() && oldPassword == pword then
			self.terminals[id]['password'] = newPassword
			if login then
				self.terminals[id]['username'] = login
			end
		end
	end
end

function TERMINAL:CheckAccess(client, login, password)
	--print("ПРОВЕРКА ФУНКЦИИ 1")
	local SVterminal = self:Validate(client);

	if SVterminal then
		local id = SVterminal:GetIndex();
		local uname = self.terminals[id]['username']
		local pword = self.terminals[id]['password']
		if !SVterminal:GetLogin() then
			if !SVterminal:GetFirstTime() && login == uname && password == pword then
				SVterminal:SetLogin(true);
				netstream.Start(client, 'terminal:accessGranted', self.terminals[id]['logs'], self.terminals[id]['history']);
			elseif SVterminal:GetFirstTime() && login:len() >= 3 && password:len() >= 8 then
				SVterminal:SetLogin(true);
				SVterminal:SetFirstTime(false)
				self:ChangePassword(client, pword, password, login)
				self:AddAnwser(client, "Пароль и логин успешно изменены!")
				--print("ПРОВЕРКА ФУНКЦИИ 2")
			end;
		end
	end
end

function TERMINAL:InterfaceCallback(client)
	local SVterminal = client:GetNWEntity("Terminal")
	SVterminal:SetUsed(false);
	SVterminal:SetLogin(false);
end

function TERMINAL:AddAnwser(client, text, color, prefix, noLog)
	netstream.Start(client, 'terminal:AddClientsideAnwser', text, color, prefix, noLog)
end

function TERMINAL:getTerminal(client, id)
	local _terminal = self:Validate(client);
	return _terminal && _terminal:GetLogin() && _terminal:GetIndex() == id, _terminal
end;

function TERMINAL:CheckArgument(argument, argAmount) // There can be only two arguments for now.
	if argument && argument:len() >= 1 && argAmount > 0 then
		local pattern = ""
		for i = 1, argAmount do
			pattern = pattern .. (i > 1 && "%s" or "") .. '"?([%w%d%s%?%!%\'%@%#%$%%%^%&%*%(%)%/%\\]*)"?'
		end
		return argument:match(pattern)
	end

	return false;
end;