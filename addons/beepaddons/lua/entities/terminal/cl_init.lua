include("shared.lua");
local glowMaterial = Material("sprites/glow04_noz")

local monWidth, monHeight = 139, 93;

function ENT:Draw()
	self:DrawModel();
	local	pos = self:GetPos();
	local 	ang = self:GetAngles();

	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 180 )
	
	// details render.
	cam.Start3D()
	render.SetMaterial(glowMaterial);
		if self:GetNumState() == 2 then
			self.badClr 		= Color(255, 100, 100, 255)
			self.goodClr 		= self.badClr;
			self.Sensor 	= self.badClr;
		elseif self:GetNumState() > 3 then
			self.badClr = Color(255, 100, 100, 255)
			if !self.clrTimer or CurTime() >= self.clrTimer then
				self.goodClr = Color(87, math.random(190, 255), 95)
				self.Sensor = Color(236, math.random(204, 255), 18, 255)
				self.clrTimer = CurTime() + 0.5;
			end;
		end

		if self:GetNumState() > 2 then
			render.DrawSprite(pos + (self:GetUp() * 40) + (self:GetForward() * -10) + (self:GetRight() * 2), 5, 5, (self:GetMemoryCard() && self.Sensor) or self.badClr);	
			render.DrawSprite(pos + (self:GetUp() * 40) + (self:GetForward() * -10) + (self:GetRight() * 5), 5, 5, (self:GetSensor() && self.Sensor) or self.badClr);	
			render.DrawSprite(pos + (self:GetUp() * 40) + (self:GetForward() * -10) + (self:GetRight() * 8), 5, 5, self.goodClr);
		end;	
	cam.End3D();

	cam.Start3D2D( pos + ang:Up() * 0 + ang:Forward() * -20.5 + ang:Right() * -55, ang + Angle(0, 0, -28), 0.11 )
		if !self:GetState() && self:GetNumState() == 2 then
			surface.SetDrawColor(0, 0, 255, 255);
		else	
			surface.SetDrawColor(0, 0, 0, 255);
		end;
		
    	surface.DrawRect(10, 6, monWidth, monHeight)
		self:ScreenPaint(1, 12) // for the first screen.

		surface.DrawRect(173, 6, monWidth, monHeight)
		self:ScreenPaint(2, 175) // for the second screen.
	cam.End3D2D()
end;

function ENT:Initialize()
	self.badClr = Color(255, 100, 100, 0);
	self.goodClr = Color(62, 133, 62, 0)

	self.Sensor = Color(236, 204, 18, 0)

	local uniqueID = "terminal:timer" .. self:EntIndex()
	self.fakeLogs = {
		"Command pending...",
		"Testing things...",
		"Alert! Error found at line: 35",
		"Analysis of commands...",
		"Logs refreshed...",
		"Moving file to folders..."
	};
	self.screenBuffer = {
		{}, // first screen;
		{} // second screen;
	}
	timer.Create(uniqueID, 1, 0, function()
		if !timer.Exists(uniqueID) or !self:IsValid() then
			timer.Remove(uniqueID)
			return;
		end
		if self:GetState() && self:GetNumState() > 1 then
			self:ScreenWork(1) // for the first screen.
			self:ScreenWork(2) // for the second screen.
		end;
	end);
end

function ENT:ScreenWork(index)
	local randomed = math.random(1, #self.fakeLogs)
	local linesAmount = 11;
	local maxLen = 31;

	local text = self.fakeLogs[randomed];
	local nextIndex = self.screenBuffer[index];
	if text:len() >= maxLen then
		text = text:sub(1, maxLen) .. "..."
	end
	self.screenBuffer[index][#nextIndex + 1] = text
	if #nextIndex > linesAmount then
		self.screenBuffer[index][1] = nil;
		local subIndex = 1;
		for k, v in pairs(nextIndex) do
			self.screenBuffer[index][subIndex] = v;
			self.screenBuffer[index][k] = nil;
			subIndex = subIndex + 1;
		end
	end
	
end;

function ENT:ScreenPaint(tblIndex, x)
	if self:GetState() then
		for i = 1, #self.screenBuffer[tblIndex] do
			local element = self.screenBuffer[tblIndex][i]
			local textX, textY = surface.GetTextSize(element)
			draw.SimpleText( element, "CONSOLE", x, (i-1) * textY + 8, Color(255, 255, 255) )
		end
	end;
end;

// // При включении: должен проигрываться звук запуска, подготовки и само включение.
// // При запуске экраны становятся синими на секунду, появляется характерный щелчок и звук включения.
// // При подготовке запускается небольшой тихий гул, лампочки начинают циклично менять цвет.
// // При включении запускается терминал, лампочки(все, кроме последней) становятся зелеными. Последняя лампочка периодически меняет цвет на пол секунды.
// Сделать неболшьой источник света от терминала.

// При нажатии кнопки "использовать" открывается экран. Сделать для этого звук.
// Сделать звук для отправки сообщения.
// Сделать звук для закрытия панели.
// Сделать звуковой отклик при отправке сообщения.
// Панель должна закрываться на E