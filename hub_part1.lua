-- DeltaHub PARTE 1: Animação + Cores + RGB
-- Depende: _G.DH já existir com TweenService, player, ScreenGui

local TS = _G.DH.TS
local player = _G.DH.player
local PRIMARY = _G.DH.PRIMARY

-- ======= SPLASH SCREEN =======
local splashDone = false
local LOGO_URL = "https://cdn.discordapp.com/attachments/1476345750924427421/1476345827739046010/nem_logo.png"
local PNG_PATH = "DeltaHub/PNGANIM.PNG"

local function doSplash(onDone)
    local Splash = Instance.new("ScreenGui")
    Splash.Name = "DeltaSplash"
    Splash.DisplayOrder = 99999
    Splash.ResetOnSpawn = false
    Splash.Parent = game:GetService("CoreGui")

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(8,8,14)
    bg.BorderSizePixel = 0
    bg.ZIndex = 1
    bg.Parent = Splash

    -- Barras RGB topo/base
    local function makeStrip(pos)
        local s = Instance.new("Frame")
        s.Size = UDim2.new(1,0,0,3)
        s.Position = pos
        s.BorderSizePixel = 0
        s.ZIndex = 10
        s.Parent = Splash
        return s
    end
    local topStrip = makeStrip(UDim2.new(0,0,0,0))
    local botStrip = makeStrip(UDim2.new(0,0,1,-3))

    -- Logo
    local logoImg = Instance.new("ImageLabel")
    logoImg.Size = UDim2.new(0,110,0,110)
    logoImg.Position = UDim2.new(0.5,-55,0,-0.6)  -- começa fora da tela
    logoImg.BackgroundTransparency = 1
    logoImg.ZIndex = 10
    logoImg.Parent = Splash

    local logoAsset = nil
    pcall(function()
        if not isfile(PNG_PATH) then
            local data = game:HttpGet(LOGO_URL, true)
            writefile(PNG_PATH, data)
        end
        logoAsset = getcustomasset(PNG_PATH)
    end)
    if logoAsset then
        logoImg.Image = logoAsset
    else
        logoImg.Image = ""
    end

    -- Textos
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0,300,0,40)
    titleLbl.Position = UDim2.new(0.5,-150,0.5,-5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "Delta Hub"
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 34
    titleLbl.TextColor3 = Color3.fromRGB(240,240,255)
    titleLbl.TextTransparency = 1
    titleLbl.ZIndex = 10
    titleLbl.Parent = Splash

    local betaLbl = Instance.new("TextLabel")
    betaLbl.Size = UDim2.new(0,200,0,22)
    betaLbl.Position = UDim2.new(0.5,-100,0.5,38)
    betaLbl.BackgroundTransparency = 1
    betaLbl.Text = "beta"
    betaLbl.Font = Enum.Font.Gotham
    betaLbl.TextSize = 16
    betaLbl.TextTransparency = 1
    betaLbl.ZIndex = 10
    betaLbl.Parent = Splash

    -- Linha RGB
    local rgbLine = Instance.new("Frame")
    rgbLine.Size = UDim2.new(0,0,0,2)
    rgbLine.Position = UDim2.new(0.5,0,0.5,60)
    rgbLine.BorderSizePixel = 0
    rgbLine.ZIndex = 10
    rgbLine.Parent = Splash

    -- Glow (efeito de explosão)
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(0,0,0,0)
    glow.Position = UDim2.new(0.5,0,0.5,-55)
    glow.Image = "rbxassetid://5028857472"
    glow.BackgroundTransparency = 1
    glow.ImageTransparency = 1
    glow.ZIndex = 9
    glow.Parent = Splash

    local hue = 0
    local rgbConn = game:GetService("RunService").RenderStepped:Connect(function(dt)
        hue = (hue + dt * 0.5) % 1
        local c = Color3.fromHSV(hue, 1, 1)
        topStrip.BackgroundColor3 = c
        botStrip.BackgroundColor3 = c
        rgbLine.BackgroundColor3 = c
        betaLbl.TextColor3 = c
    end)

    local tw = TweenService or game:GetService("TweenService")

    -- Fase 1: logo entra girando do topo
    local spin = Instance.new("UIRotation"); spin.Rotation = 0; spin.Parent = logoImg
    TS:Create(logoImg, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5,-55,0.5,-140)}):Play()
    local rotTween = TS:Create(spin, TweenInfo.new(1.2, Enum.EasingStyle.Quad),
        {Rotation = 360}):Play()
    task.wait(1.2)

    -- Para rotação
    TS:Create(spin, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Rotation = 0}):Play()
    task.wait(0.4)

    -- Glow explode
    glow.ImageTransparency = 0.2
    TS:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0,200,0,200), Position = UDim2.new(0.5,-100,0.5,-155), ImageTransparency = 1}):Play()
    task.wait(0.3)

    -- Linha RGB cresce
    TS:Create(rgbLine, TweenInfo.new(0.5, Enum.EasingStyle.Quad),
        {Size = UDim2.new(0,280,0,2), Position = UDim2.new(0.5,-140,0.5,60)}):Play()

    -- Título aparece
    TS:Create(titleLbl, TweenInfo.new(0.5, Enum.EasingStyle.Quad),
        {TextTransparency = 0}):Play()
    task.wait(0.4)

    -- Beta aparece
    TS:Create(betaLbl, TweenInfo.new(0.4, Enum.EasingStyle.Quad),
        {TextTransparency = 0}):Play()
    task.wait(2.5)

    -- Fade out tudo
    local fadeTargets = {bg, topStrip, botStrip, rgbLine, titleLbl, betaLbl, logoImg, glow}
    for _, obj in ipairs(fadeTargets) do
        local props = {}
        if obj:IsA("TextLabel") then props.TextTransparency = 1 end
        if obj:IsA("Frame") or obj:IsA("ImageLabel") then props.BackgroundTransparency = 1 end
        if obj:IsA("ImageLabel") then props.ImageTransparency = 1 end
        if next(props) then
            TS:Create(obj, TweenInfo.new(0.6, Enum.EasingStyle.Quad), props):Play()
        end
    end
    task.wait(0.7)

    rgbConn:Disconnect()
    Splash:Destroy()
    splashDone = true
    if onDone then onDone() end
end

-- ======= RGB CONTÍNUO (borda do hub) =======
local rgbHue = 0
local function startRGB()
    local border = _G.DH.border
    if not border then return end
    game:GetService("RunService").RenderStepped:Connect(function(dt)
        rgbHue = (rgbHue + dt * 0.5) % 1
        local c = Color3.fromHSV(rgbHue, 1, 1)
        border.Color = c
        if _G.DH.IYStroke then _G.DH.IYStroke.Color = c end
        if _G.DH.betaRGB then _G.DH.betaRGB.TextColor3 = c end
        if _G.DH.topBar then _G.DH.topBar.BackgroundColor3 = c end
    end)
end

_G.DH.doSplash = doSplash
_G.DH.startRGB = startRGB
