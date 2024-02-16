
local PANEL = {}

local deathScreens = {
    {path = "backs/death.png", weight = 50},   -- Этот экран показывается чаще
    {path = "backs/death1.png", weight = 50},   -- Этот экран показывается реже
	{path = "backs/death2.png", weight = 50},
	{path = "backs/death3.png", weight = 50},
	{path = "backs/death4.png", weight = 1}, -- r
	{path = "backs/death5.png", weight = 50},
	{path = "backs/death6.png", weight = 1}, -- r
	{path = "backs/death7.png", weight = 1}, -- r
	{path = "backs/death8.png", weight = 1}, -- r
	{path = "backs/death9.png", weight = 50},
	{path = "backs/death10.png", weight = 50},
	{path = "backs/death11.png", weight = 50},
	{path = "backs/death12.png", weight = 50},
	{path = "backs/death13.png", weight = 50},
}

function ChooseDeathScreen()
    local totalWeight = 0

    -- Считаем общий вес всех экранов смерти
    for _, screen in ipairs(deathScreens) do
        totalWeight = totalWeight + screen.weight
    end

    -- Генерируем случайное число в диапазоне от 1 до общего веса
    local randomNumber = math.random(1, totalWeight)

    -- Выбираем экран смерти, учитывая вес каждого элемента списка
    local accumulatedWeight = 0
    for _, screen in ipairs(deathScreens) do
        accumulatedWeight = accumulatedWeight + screen.weight
        if randomNumber <= accumulatedWeight then
            return screen.path
        end
    end
end

function PANEL:Init()
	local scrW, scrH = ScrW(), ScrH()

	self:SetSize(scrW, scrH)
	self:SetPos(0, 0)

	-- Установка текста
	local text = string.utf8upper(L("youreDead"))
	surface.SetFont("ixMenuButtonHugeFont")
	local textW, textH = surface.GetTextSize(text)

	self.label = self:Add("DLabel")
	self.label:SetPaintedManually(true)
	self.label:SetPos(scrW * 0.5 - textW * 0.5, scrH * 0.5 - textH * 0.5)
	self.label:SetFont("ixMenuButtonHugeFont")
	self.label:SetText(text)
	self.label:SizeToContents()

	-- Добавление изображения
	local imgPath = ChooseDeathScreen()  -- Выбор случайного экрана смерти с учетом весов
    local img = self:Add("DImage")
    img:SetPos(0, 0)
    img:SetZPos(-1)
    img:SetSize(scrW, scrH)
    img:SetImage(imgPath)

	self.progress = 0

	self:CreateAnimation(ix.config.Get("spawnTime", 5), {
		bIgnoreConfig = true,
		target = {progress = 1},

		OnComplete = function(animation, panel)
			if (!panel:IsClosing()) then
				panel:Close()
			end
		end
	})
end

--function PANEL:Think()
--	self.label:SetAlpha(((self.progress - 0.3) / 0.3) * 255)
--end

function PANEL:IsClosing()
	return self.bIsClosing
end

function PANEL:Close()
	self.bIsClosing = true

	self:CreateAnimation(2, {
		index = 2,
		bIgnoreConfig = true,
		target = {progress = 0},

		OnComplete = function(animation, panel)
			panel:Remove()
		end
	})
end

function PANEL:Paint(width, height)
	derma.SkinFunc("PaintDeathScreenBackground", self, width, height, self.progress)
		self.label:PaintManual()
	derma.SkinFunc("PaintDeathScreen", self, width, height, self.progress)
end

vgui.Register("ixDeathScreen", PANEL, "Panel")