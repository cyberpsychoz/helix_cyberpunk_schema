local PANEL = {};

function PANEL:Init()
    self:SetFocusTopLevel( true )
    self:MakePopup()
    self:Adaptate(800, 500, 0.31, 0.3)
    gui.EnableScreenClicker(true);
    self:SetAlpha(0)
    self:AlphaTo(255, 0.3, 0, function(alpha, pnl)
        pnl:SetAlpha(255)
    end);
end;

function PANEL:Paint( w, h )
    Derma_DrawBGBlur( self, 0 )
    draw.RoundedBoxOutlined( 0, 0, 0, w, h, Color(5, 5, 5, 255), Color(25, 25, 25) )
    self:CreateCloseDebug()

	if input.IsKeyDown( KEY_TAB ) then
        self._textInput:RequestFocus()
    end;

	if !TERMINAL:Validate(LocalPlayer()) then
		self:CloseMe()
	end
end;

function PANEL:Populate()
	timer.Simple(0.5, function ()
		if self:IsValid() then
			self.allowedToClose = true
		end;
	end)
	
	self.history = self:Add('DScrollPanel')
    self.history:Dock(FILL)
	self.history:DockMargin(0, 0, 0, 0)

	local ConVas = self.history:GetCanvas()
	local ScrollBar = self.history:GetVBar()
	function ScrollBar:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 100)) end
	function ScrollBar.btnGrip:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 100)) end
	ScrollBar:SetHideButtons( true )

	if TERMINAL:Validate(LocalPlayer()) then
		if !TERMINAL:Validate(LocalPlayer()):GetFirstTime() then
			self:addCMD("Введите команду: -login username password для доступа к этому терминалу.", nil, nil, false)
		else
			self:addCMD("Введите команду: -login username password, чтобы создать имя пользователя и пароль для этого терминала.", nil, nil, false)
		end;
	end;

	self:addCMD("Нажмите Ctrl+E, чтобы выйти из этого терминала, или введите команду -exit", nil, nil, false)
	self:addCMD("ПОДСКАЗКА: Если вы хотите, чтобы сообщение было длиннее одного слова, добавьте \" в начале и в конце сообщения.", nil, nil, false)

	self.inputPlace = self:Add('Panel')
	self.inputPlace:Dock(BOTTOM)
	self.inputPlace:SetTall(25)

	self._infoInput = self.inputPlace:Add('DLabel')
	self._infoInput:SetFont('DebugFixed')
	self._infoInput:Dock(LEFT)
	self._infoInput:SetWide(40)
	self._infoInput:SetText(TERMINAL.CMDPREFIX)
	self._infoInput:DockMargin(10, 0, 0, 0)

	self._textInput = self.inputPlace:Add('DTextEntry')
	self._textInput:SetFont('DebugFixed')
	self._textInput:Dock(FILL)
	self._textInput:SetText('')
	self._textInput:DockMargin(0, 5, 0, 5)
	self._textInput.Paint = function(s, w, h)
		s:DrawTextEntryText( Color(255, 255, 255), Color(100, 100, 100), Color(255 ,255, 255) )
	end;
	
	local index = #TERMINAL.termHistory;
	function self._textInput:OnKeyCode(key)
		if TERMINAL.termHistory && #TERMINAL.termHistory >= 1 && (key == KEY_UP || key == KEY_DOWN) then
			local history = TERMINAL.termHistory;
			if key == KEY_UP then
				index = index + 1;
			elseif key == KEY_DOWN then 
				index = index - 1;
			end
			if index < 0 then
				index = #history;
			elseif index > #history then
				index = 1
			end
			if history[index] then
				self:SetText(history[index]['text'])
			end
		end;
	end;
	self._textInput:RequestFocus()

	self._textInput.OnEnter = function(input)
		local text = input:GetText();
		local term = TERMINAL:Validate(LocalPlayer());
		if !term then return end;
		local authorized = term:GetLogin()
		local callback, command, noEcho, Log = TERMINAL:exec(text, self, authorized, term:GetIndex());
		self:addCMD(text, Color(255, 255, 255), nil, authorized && ((Log && callback) or (!Log && !callback)))
		TERMINAL.termHistory[#TERMINAL.termHistory + 1] = {text = text}
		history = TERMINAL.termHistory;
    	input:SetText("")
		input:RequestFocus()
		ScrollBar:AnimateTo( ConVas:GetTall() + 900, 1, 0, -1 )
		if command then
			if callback then return end;
			if !noEcho && term:GetLogin() && !callback then
				self:addCMD('Команда "'..command..'" не найдена. Используйте '..TERMINAL.PREFIX..'help чтобы увидеть все команды.', nil, nil, true)
			end
		end
	end
	
end;

function PANEL:addCMD(text, color, prefix, needlog)
	local cmd = self.history:Add('TerminalCMD');
	cmd:SetCMD(text, color, prefix, needlog);
end;

function PANEL:OnRemove()
	local terminal = TERMINAL:Validate(LocalPlayer());
	TERMINAL.termHistory = {};
	netstream.Start('terminal:closeInterface', terminal);
end

vgui.Register( "Terminal", PANEL, "EditablePanel" )

local PANEL = {}

function PANEL:Init()
	self:SetFont('DebugFixed')
	self:SetText( "" )
	self:Dock( TOP )
	self:SetWrap(true)
	self:SetAutoStretchVertical(true)
	self:DockMargin( 10, 5, 7, 2 )
end;

function PANEL:SetCMD(text, color, prefix, needLog)
	if !prefix then prefix = TERMINAL.CMDPREFIX end
	if !color then color = Color(255, 255, 255) end;
	if !needLog then needLog = false end;
	local terminal = TERMINAL:Validate(LocalPlayer());
	self:SetText( prefix .. " " .. text || prefix .. " ::ERROR::" )
	self:SetTextColor( color || Color(255, 255, 255) )
	if terminal && needLog then
		netstream.Start('terminal:logUP', text, color, prefix, terminal:GetIndex())
	end;
    self:SetTall( 40 * (1 * self:GetLinesOfContent()) + 25 )
end;

function PANEL:GetLinesOfContent()
    local amount = string.len(self:GetText())
    return 1 + math.Round(amount/90)
end;

vgui.Register( "TerminalCMD", PANEL, "DLabel" )