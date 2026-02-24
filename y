--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                        SageUI Library                       ║
    ║             Modern Minimalist UI for Roblox                 ║
    ║                     Version 1.0.0                           ║
    ╚══════════════════════════════════════════════════════════════╝

    Paleta de Cores:
        Primária  → Verde Sage   : #87A878  (rgb(135, 168, 120))
        Secundária → Preto Puro  : #0A0A0A  (rgb(10, 10, 10))
        Superfície → Cinza Escuro: #111111  (rgb(17, 17, 17))
        Borda      → Sage escuro : #5C7A50  (rgb(92, 122, 80))
        Texto      → Branco Suave: #E8E8E8  (rgb(232, 232, 232))

    Funcionalidades:
        • Window    — janela arrastável com título e ícone
        • Tab       — sistema de abas com indicador ativo
        • Button    — botão com hover e ripple effect
        • Toggle    — interruptor animado on/off
        • Slider    — controle deslizante com valor numérico
        • Dropdown  — menu suspenso com múltiplas opções
        • TextBox   — campo de entrada de texto
        • Label     — rótulo de texto informativo
        • Separator — divisor visual de seções
        • Keybind   — captura de tecla de atalho
        • ColorPick — seletor de cor simplificado
        • Notify    — notificações flutuantes

    Uso básico:
        local SageUI = loadstring(game:HttpGet(...))()
        local Window = SageUI:CreateWindow({ Title = "Meu Script", Size = UDim2.new(0,520,0,400) })
        local Tab    = Window:AddTab({ Name = "Principal", Icon = "rbxassetid://..." })
        Tab:AddButton({ Name = "Executar", Callback = function() print("OK") end })
--]]

-- ─────────────────────────────────────────────────────────────────
--  SERVIÇOS
-- ─────────────────────────────────────────────────────────────────
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")
local CoreGui        = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ─────────────────────────────────────────────────────────────────
--  TEMA
-- ─────────────────────────────────────────────────────────────────
local Theme = {
    Primary     = Color3.fromRGB(135, 168, 120),   -- Verde Sage
    PrimaryDark = Color3.fromRGB(92,  122,  80),   -- Sage escuro (bordas/hover)
    PrimaryGlow = Color3.fromRGB(160, 195, 145),   -- Sage claro (destaque)
    Background  = Color3.fromRGB(10,   10,  10),   -- Preto puro
    Surface     = Color3.fromRGB(17,   17,  17),   -- Superfície
    Surface2    = Color3.fromRGB(24,   24,  24),   -- Superfície elevada
    Surface3    = Color3.fromRGB(32,   32,  32),   -- Card / Elemento
    Border      = Color3.fromRGB(40,   40,  40),   -- Borda padrão
    Text        = Color3.fromRGB(232, 232, 232),   -- Texto principal
    TextMuted   = Color3.fromRGB(140, 140, 140),   -- Texto secundário
    Success     = Color3.fromRGB(100, 200, 120),
    Warning     = Color3.fromRGB(220, 180,  60),
    Error       = Color3.fromRGB(210,  80,  80),
}

-- ─────────────────────────────────────────────────────────────────
--  UTILITÁRIOS
-- ─────────────────────────────────────────────────────────────────
local Util = {}

--- Cria um tween reutilizável
---@param instance Instance
---@param properties table
---@param duration number
---@param style Enum.EasingStyle|nil
---@param direction Enum.EasingDirection|nil
function Util.Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.2,
        style     or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(instance, info, properties)
    t:Play()
    return t
end

--- Cria e configura um elemento de GUI
---@param class string
---@param properties table
---@param parent Instance|nil
function Util.Create(class, properties, parent)
    local obj = Instance.new(class)
    for k, v in pairs(properties) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

--- Aplica um UICorner ao objeto
function Util.Corner(parent, radius)
    return Util.Create("UICorner", { CornerRadius = UDim.new(0, radius or 6) }, parent)
end

--- Aplica borda (UIStroke) ao objeto
function Util.Stroke(parent, color, thickness, transparency)
    return Util.Create("UIStroke", {
        Color        = color        or Theme.Border,
        Thickness    = thickness    or 1,
        Transparency = transparency or 0,
    }, parent)
end

--- Faz um elemento ser arrastável
function Util.MakeDraggable(titleBar, frame)
    local dragging, dragStart, startPos = false, nil, nil

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--- Efeito de hover simples
function Util.Hover(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        Util.Tween(button, { BackgroundColor3 = hoverColor }, 0.15)
    end)
    button.MouseLeave:Connect(function()
        Util.Tween(button, { BackgroundColor3 = normalColor }, 0.15)
    end)
end

-- ─────────────────────────────────────────────────────────────────
--  NOTIFICAÇÕES
-- ─────────────────────────────────────────────────────────────────
local NotifyHolder -- será criado junto com a ScreenGui principal

local function CreateNotifySystem(screenGui)
    NotifyHolder = Util.Create("Frame", {
        Name            = "SageNotifications",
        AnchorPoint     = Vector2.new(1, 1),
        Position        = UDim2.new(1, -16, 1, -16),
        Size            = UDim2.new(0, 300, 1, 0),
        BackgroundTransparency = 1,
        ZIndex          = 100,
    }, screenGui)

    local layout = Util.Create("UIListLayout", {
        FillDirection  = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        Padding        = UDim.new(0, 8),
        SortOrder      = Enum.SortOrder.LayoutOrder,
    }, NotifyHolder)
end

---@param options { Title:string, Message:string, Duration:number|nil, Type:string|nil }
local function Notify(options)
    if not NotifyHolder then return end

    local typeColors = {
        success = Theme.Success,
        warning = Theme.Warning,
        error   = Theme.Error,
        info    = Theme.Primary,
    }
    local accent = typeColors[options.Type or "info"] or Theme.Primary
    local dur    = options.Duration or 4

    local card = Util.Create("Frame", {
        Size                 = UDim2.new(1, 0, 0, 72),
        BackgroundColor3     = Theme.Surface2,
        BackgroundTransparency = 1,
        ClipsDescendants     = true,
        LayoutOrder          = tick(),
    }, NotifyHolder)
    Util.Corner(card, 8)
    Util.Stroke(card, Theme.Border, 1)

    -- Barra lateral colorida
    Util.Create("Frame", {
        Size             = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = accent,
    }, card)
    Util.Corner(Util.Create("Frame",{ Size=UDim2.new(0,4,1,0), BackgroundColor3=accent },card), 4)

    local accentBar = Util.Create("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        Position         = UDim2.new(0, 0, 0, 0),
    }, card)
    Util.Corner(accentBar, 4)

    Util.Create("TextLabel", {
        Text      = options.Title or "Aviso",
        Font      = Enum.Font.GothamBold,
        TextSize  = 13,
        TextColor3= Theme.Text,
        Position  = UDim2.new(0, 16, 0, 10),
        Size      = UDim2.new(1, -20, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
    }, card)

    Util.Create("TextLabel", {
        Text      = options.Message or "",
        Font      = Enum.Font.Gotham,
        TextSize  = 12,
        TextColor3= Theme.TextMuted,
        Position  = UDim2.new(0, 16, 0, 30),
        Size      = UDim2.new(1, -20, 0, 32),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped= true,
        BackgroundTransparency = 1,
    }, card)

    -- Barra de progresso
    local progressBg = Util.Create("Frame", {
        Position         = UDim2.new(0, 0, 1, -3),
        Size             = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = Theme.Surface3,
    }, card)
    local progressBar = Util.Create("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accent,
    }, progressBg)

    -- Animação de entrada
    Util.Tween(card, { BackgroundTransparency = 0 }, 0.3)
    Util.Tween(progressBar, { Size = UDim2.new(0, 0, 1, 0) }, dur, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

    task.delay(dur, function()
        Util.Tween(card, { BackgroundTransparency = 1 }, 0.4)
        task.wait(0.4)
        card:Destroy()
    end)
end

-- ─────────────────────────────────────────────────────────────────
--  BIBLIOTECA PRINCIPAL
-- ─────────────────────────────────────────────────────────────────
local SageUI  = {}
SageUI.__index = SageUI
SageUI.Theme   = Theme
SageUI.Notify  = Notify
SageUI.Version = "1.0.0"

---@param options { Title:string, Size:UDim2|nil, Position:UDim2|nil, Icon:string|nil }
function SageUI:CreateWindow(options)
    options = options or {}

    -- ── ScreenGui ─────────────────────────────────────────────────
    local screenGui = Util.Create("ScreenGui", {
        Name            = "SageUI_" .. (options.Title or "Window"),
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    })

    -- Tenta parear com CoreGui (executors); caso falhe, usa PlayerGui
    local ok = pcall(function() screenGui.Parent = CoreGui end)
    if not ok then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    CreateNotifySystem(screenGui)

    -- ── Container principal ────────────────────────────────────────
    local winSize = options.Size or UDim2.new(0, 540, 0, 420)
    local winPos  = options.Position or UDim2.new(0.5, -(winSize.X.Offset/2), 0.5, -(winSize.Y.Offset/2))

    local main = Util.Create("Frame", {
        Name             = "MainWindow",
        Size             = winSize,
        Position         = winPos,
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true,
    }, screenGui)
    Util.Corner(main, 10)
    Util.Stroke(main, Theme.PrimaryDark, 1.5)

    -- Sombra decorativa
    local shadow = Util.Create("ImageLabel", {
        AnchorPoint          = Vector2.new(0.5, 0.5),
        Position             = UDim2.new(0.5, 0, 0.5, 4),
        Size                 = UDim2.new(1, 24, 1, 24),
        BackgroundTransparency = 1,
        Image                = "rbxassetid://5554236805",
        ImageColor3          = Color3.new(0,0,0),
        ImageTransparency    = 0.5,
        ScaleType            = Enum.ScaleType.Slice,
        SliceCenter          = Rect.new(23,23,277,277),
        ZIndex               = -1,
    }, main)

    -- ── Barra de título ────────────────────────────────────────────
    local titleBar = Util.Create("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.Surface,
    }, main)

    -- Linha de destaque inferior da title bar
    Util.Create("Frame", {
        Position         = UDim2.new(0, 0, 1, -1),
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.PrimaryDark,
    }, titleBar)

    -- Ícone opcional
    if options.Icon and options.Icon ~= "" then
        Util.Create("ImageLabel", {
            Position             = UDim2.new(0, 12, 0.5, -10),
            Size                 = UDim2.new(0, 20, 0, 20),
            BackgroundTransparency = 1,
            Image                = options.Icon,
            ImageColor3          = Theme.Primary,
        }, titleBar)
    end

    -- Título
    local iconOffset = (options.Icon and options.Icon ~= "") and 38 or 12
    Util.Create("TextLabel", {
        Text      = options.Title or "SageUI",
        Font      = Enum.Font.GothamBold,
        TextSize  = 14,
        TextColor3= Theme.Text,
        Position  = UDim2.new(0, iconOffset, 0, 0),
        Size      = UDim2.new(1, -(iconOffset + 80), 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
    }, titleBar)

    -- Botão de fechar
    local closeBtn = Util.Create("TextButton", {
        Text             = "✕",
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        TextColor3       = Theme.TextMuted,
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, -10, 0.5, 0),
        Size             = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Theme.Surface2,
    }, titleBar)
    Util.Corner(closeBtn, 6)
    Util.Hover(closeBtn, Theme.Surface2, Theme.Error)
    closeBtn.MouseButton1Click:Connect(function()
        Util.Tween(main, { BackgroundTransparency = 1 }, 0.3)
        task.wait(0.3)
        screenGui:Destroy()
    end)

    -- Botão minimizar
    local minBtn = Util.Create("TextButton", {
        Text             = "−",
        Font             = Enum.Font.GothamBold,
        TextSize         = 16,
        TextColor3       = Theme.TextMuted,
        AnchorPoint      = Vector2.new(1, 0.5),
        Position         = UDim2.new(1, -44, 0.5, 0),
        Size             = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Theme.Surface2,
    }, titleBar)
    Util.Corner(minBtn, 6)
    Util.Hover(minBtn, Theme.Surface2, Theme.Warning)

    local minimized = false
    local contentRef
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if contentRef then
            if minimized then
                Util.Tween(main, { Size = UDim2.new(0, winSize.X.Offset, 0, 44) }, 0.25)
            else
                Util.Tween(main, { Size = winSize }, 0.25)
            end
        end
    end)

    Util.MakeDraggable(titleBar, main)

    -- ── Área de conteúdo ───────────────────────────────────────────
    local content = Util.Create("Frame", {
        Name             = "Content",
        Position         = UDim2.new(0, 0, 0, 44),
        Size             = UDim2.new(1, 0, 1, -44),
        BackgroundColor3 = Theme.Background,
    }, main)
    contentRef = content

    -- ── Barra de abas (lateral esquerda) ──────────────────────────
    local tabBar = Util.Create("Frame", {
        Name             = "TabBar",
        Size             = UDim2.new(0, 130, 1, 0),
        BackgroundColor3 = Theme.Surface,
    }, content)

    -- Linha divisória direita da tabBar
    Util.Create("Frame", {
        Position         = UDim2.new(1, -1, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Border,
    }, tabBar)

    local tabLayout = Util.Create("UIListLayout", {
        FillDirection  = Enum.FillDirection.Vertical,
        Padding        = UDim.new(0, 4),
        SortOrder      = Enum.SortOrder.LayoutOrder,
    }, tabBar)
    Util.Create("UIPadding", {
        PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
        PaddingLeft= UDim.new(0, 8), PaddingRight  = UDim.new(0, 8),
    }, tabBar)

    -- ── Container de páginas das abas ─────────────────────────────
    local tabPages = Util.Create("Frame", {
        Name             = "TabPages",
        Position         = UDim2.new(0, 130, 0, 0),
        Size             = UDim2.new(1, -130, 1, 0),
        BackgroundColor3 = Theme.Background,
    }, content)

    -- ─────────────────────────────────────────────────────────────
    --  OBJETO WINDOW
    -- ─────────────────────────────────────────────────────────────
    local Window    = {}
    local tabList   = {}
    local activeTab = nil

    --- Seleciona uma aba pelo nome
    local function SelectTab(name)
        for _, t in ipairs(tabList) do
            local isActive = (t.Name == name)
            -- Botão da aba
            Util.Tween(t.Button, {
                BackgroundColor3 = isActive and Theme.Surface3 or Color3.new(0,0,0),
                BackgroundTransparency = isActive and 0 or 1,
            }, 0.15)
            Util.Tween(t.ButtonText, { TextColor3 = isActive and Theme.Primary or Theme.TextMuted }, 0.15)
            -- Indicador
            Util.Tween(t.Indicator, { BackgroundTransparency = isActive and 0 or 1 }, 0.15)
            -- Página
            t.Page.Visible = isActive
        end
        activeTab = name
    end

    ---@param tabOptions { Name:string, Icon:string|nil }
    function Window:AddTab(tabOptions)
        tabOptions = tabOptions or {}
        local tName = tabOptions.Name or ("Tab " .. #tabList + 1)

        -- Botão da aba
        local btn = Util.Create("TextButton", {
            Name             = tName,
            Text             = "",
            Size             = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Surface3,
            BackgroundTransparency = 1,
            LayoutOrder      = #tabList,
        }, tabBar)
        Util.Corner(btn, 6)

        -- Indicador verde à esquerda
        local indicator = Util.Create("Frame", {
            Position         = UDim2.new(0, 0, 0.15, 0),
            Size             = UDim2.new(0, 3, 0.7, 0),
            BackgroundColor3 = Theme.Primary,
            BackgroundTransparency = 1,
        }, btn)
        Util.Corner(indicator, 4)

        -- Ícone da aba
        local iconOffset = 10
        if tabOptions.Icon and tabOptions.Icon ~= "" then
            Util.Create("ImageLabel", {
                Position             = UDim2.new(0, 10, 0.5, -9),
                Size                 = UDim2.new(0, 18, 0, 18),
                BackgroundTransparency = 1,
                Image                = tabOptions.Icon,
                ImageColor3          = Theme.TextMuted,
            }, btn)
            iconOffset = 34
        end

        local btnText = Util.Create("TextLabel", {
            Text      = tName,
            Font      = Enum.Font.Gotham,
            TextSize  = 12,
            TextColor3= Theme.TextMuted,
            Position  = UDim2.new(0, iconOffset, 0, 0),
            Size      = UDim2.new(1, -iconOffset, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
        }, btn)

        -- Página da aba (ScrollingFrame)
        local page = Util.Create("ScrollingFrame", {
            Name                       = tName .. "_Page",
            Size                       = UDim2.new(1, 0, 1, 0),
            BackgroundColor3           = Theme.Background,
            BorderSizePixel            = 0,
            ScrollBarThickness         = 4,
            ScrollBarImageColor3       = Theme.Primary,
            ScrollingDirection         = Enum.ScrollingDirection.Y,
            AutomaticCanvasSize        = Enum.AutomaticSize.Y,
            CanvasSize                 = UDim2.new(0, 0, 0, 0),
            Visible                    = false,
        }, tabPages)

        local pageLayout = Util.Create("UIListLayout", {
            FillDirection  = Enum.FillDirection.Vertical,
            Padding        = UDim.new(0, 6),
            SortOrder      = Enum.SortOrder.LayoutOrder,
        }, page)
        Util.Create("UIPadding", {
            PaddingTop    = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
            PaddingLeft   = UDim.new(0, 10), PaddingRight  = UDim.new(0, 14),
        }, page)

        local tabEntry = { Name = tName, Button = btn, ButtonText = btnText, Indicator = indicator, Page = page }
        table.insert(tabList, tabEntry)

        btn.MouseButton1Click:Connect(function() SelectTab(tName) end)

        -- Seleciona automaticamente a primeira aba
        if #tabList == 1 then SelectTab(tName) end

        -- ──────────────────────────────────────────────────────────
        --  OBJETO TAB  (retorno ao usuário)
        -- ──────────────────────────────────────────────────────────
        local Tab = {}
        local elementOrder = 0

        local function nextOrder()
            elementOrder = elementOrder + 1
            return elementOrder
        end

        -- ── Helpers internos ──────────────────────────────────────

        --- Cria um container de elemento padrão
        local function ElementCard(height)
            local card = Util.Create("Frame", {
                Size             = UDim2.new(1, 0, 0, height or 38),
                BackgroundColor3 = Theme.Surface2,
                LayoutOrder      = nextOrder(),
            }, page)
            Util.Corner(card, 6)
            return card
        end

        -- ── Button ────────────────────────────────────────────────
        ---@param opts { Name:string, Callback:function|nil, Description:string|nil }
        function Tab:AddButton(opts)
            opts = opts or {}
            local card = ElementCard(38)

            local btn2 = Util.Create("TextButton", {
                Text             = opts.Name or "Button",
                Font             = Enum.Font.GothamSemibold,
                TextSize         = 13,
                TextColor3       = Theme.Text,
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme.Surface2,
            }, card)
            Util.Corner(btn2, 6)

            -- Indicador primário à esquerda
            Util.Create("Frame", {
                Size             = UDim2.new(0, 3, 0.6, 0),
                Position         = UDim2.new(0, 0, 0.2, 0),
                BackgroundColor3 = Theme.Primary,
            }, btn2)
            Util.Corner(Util.Create("Frame",{
                Size=UDim2.new(0,3,0.6,0), Position=UDim2.new(0,0,0.2,0),
                BackgroundColor3=Theme.Primary
            }, btn2), 4)

            Util.Hover(btn2, Theme.Surface2, Theme.Surface3)

            btn2.MouseButton1Click:Connect(function()
                if opts.Callback then
                    local ok2, err = pcall(opts.Callback)
                    if not ok2 then warn("[SageUI] Button callback error:", err) end
                end
                -- Ripple flash
                Util.Tween(btn2, { BackgroundColor3 = Theme.PrimaryDark }, 0.08)
                task.wait(0.08)
                Util.Tween(btn2, { BackgroundColor3 = Theme.Surface2 }, 0.2)
            end)
        end

        -- ── Toggle ────────────────────────────────────────────────
        ---@param opts { Name:string, Default:boolean|nil, Callback:function|nil }
        function Tab:AddToggle(opts)
            opts = opts or {}
            local state = opts.Default or false
            local card  = ElementCard(38)

            Util.Create("TextLabel", {
                Text      = opts.Name or "Toggle",
                Font      = Enum.Font.Gotham,
                TextSize  = 13,
                TextColor3= Theme.Text,
                Position  = UDim2.new(0, 12, 0, 0),
                Size      = UDim2.new(1, -60, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
            }, card)

            local track = Util.Create("Frame", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -10, 0.5, 0),
                Size             = UDim2.new(0, 40, 0, 22),
                BackgroundColor3 = state and Theme.Primary or Theme.Surface3,
            }, card)
            Util.Corner(track, 11)
            Util.Stroke(track, Theme.Border, 1)

            local knob = Util.Create("Frame", {
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = UDim2.new(0, state and 20 or 2, 0.5, 0),
                Size             = UDim2.new(0, 18, 0, 18),
                BackgroundColor3 = state and Color3.new(1,1,1) or Theme.TextMuted,
            }, track)
            Util.Corner(knob, 9)

            local function SetState(val)
                state = val
                Util.Tween(track, { BackgroundColor3 = val and Theme.Primary or Theme.Surface3 }, 0.2)
                Util.Tween(knob,  { Position = UDim2.new(0, val and 20 or 2, 0.5, 0), BackgroundColor3 = val and Color3.new(1,1,1) or Theme.TextMuted }, 0.2)
                if opts.Callback then
                    local ok2, err = pcall(opts.Callback, val)
                    if not ok2 then warn("[SageUI] Toggle callback error:", err) end
                end
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    SetState(not state)
                end
            end)
            card.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    SetState(not state)
                end
            end)

            return { SetValue = SetState, GetValue = function() return state end }
        end

        -- ── Slider ────────────────────────────────────────────────
        ---@param opts { Name:string, Min:number, Max:number, Default:number|nil, Decimals:number|nil, Callback:function|nil }
        function Tab:AddSlider(opts)
            opts = opts or {}
            local min  = opts.Min     or 0
            local max  = opts.Max     or 100
            local decs = opts.Decimals or 0
            local cur  = math.clamp(opts.Default or min, min, max)

            local card = ElementCard(54)
            card.Size  = UDim2.new(1, 0, 0, 54)

            local nameLabel = Util.Create("TextLabel", {
                Text      = opts.Name or "Slider",
                Font      = Enum.Font.Gotham,
                TextSize  = 13,
                TextColor3= Theme.Text,
                Position  = UDim2.new(0, 12, 0, 6),
                Size      = UDim2.new(1, -60, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
            }, card)

            local valLabel = Util.Create("TextLabel", {
                Text      = tostring(cur),
                Font      = Enum.Font.GothamBold,
                TextSize  = 13,
                TextColor3= Theme.Primary,
                Position  = UDim2.new(1, -50, 0, 6),
                Size      = UDim2.new(0, 44, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1,
            }, card)

            local track = Util.Create("Frame", {
                Position         = UDim2.new(0, 12, 0, 34),
                Size             = UDim2.new(1, -24, 0, 6),
                BackgroundColor3 = Theme.Surface3,
            }, card)
            Util.Corner(track, 3)

            local fill = Util.Create("Frame", {
                Size             = UDim2.new((cur - min)/(max - min), 0, 1, 0),
                BackgroundColor3 = Theme.Primary,
            }, track)
            Util.Corner(fill, 3)

            local thumb = Util.Create("Frame", {
                AnchorPoint      = Vector2.new(0.5, 0.5),
                Position         = UDim2.new((cur - min)/(max - min), 0, 0.5, 0),
                Size             = UDim2.new(0, 14, 0, 14),
                BackgroundColor3 = Theme.PrimaryGlow,
            }, track)
            Util.Corner(thumb, 7)
            Util.Stroke(thumb, Theme.Background, 2)

            local function SetValue(val)
                val = math.clamp(val, min, max)
                val = math.round(val * 10^decs) / 10^decs
                cur = val
                local pct = (cur - min) / (max - min)
                Util.Tween(fill,  { Size     = UDim2.new(pct, 0, 1, 0) }, 0.05)
                Util.Tween(thumb, { Position = UDim2.new(pct, 0, 0.5, 0) }, 0.05)
                valLabel.Text = tostring(cur)
                if opts.Callback then
                    local ok2, err = pcall(opts.Callback, cur)
                    if not ok2 then warn("[SageUI] Slider callback error:", err) end
                end
            end

            local sliding = false
            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = (Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                    SetValue(min + math.clamp(rel, 0, 1) * (max - min))
                end
            end)

            return { SetValue = SetValue, GetValue = function() return cur end }
        end

        -- ── Dropdown ──────────────────────────────────────────────
        ---@param opts { Name:string, Options:table, Default:string|nil, Callback:function|nil }
        function Tab:AddDropdown(opts)
            opts = opts or {}
            local choices = opts.Options or {}
            local selected = opts.Default or (choices[1] or "")
            local isOpen   = false

            local card = ElementCard(38)

            Util.Create("TextLabel", {
                Text      = opts.Name or "Dropdown",
                Font      = Enum.Font.Gotham,
                TextSize  = 13,
                TextColor3= Theme.Text,
                Position  = UDim2.new(0, 12, 0, 0),
                Size      = UDim2.new(0.45, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
            }, card)

            local selectBtn = Util.Create("TextButton", {
                Text             = selected,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextColor3       = Theme.Primary,
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -10, 0.5, 0),
                Size             = UDim2.new(0.48, 0, 0, 26),
                BackgroundColor3 = Theme.Surface3,
            }, card)
            Util.Corner(selectBtn, 5)
            Util.Stroke(selectBtn, Theme.Border, 1)

            -- Seta indicadora
            Util.Create("TextLabel", {
                Text      = "▾",
                Font      = Enum.Font.GothamBold,
                TextSize  = 12,
                TextColor3= Theme.TextMuted,
                AnchorPoint= Vector2.new(1, 0.5),
                Position  = UDim2.new(1, -4, 0.5, 0),
                Size      = UDim2.new(0, 14, 0, 14),
                BackgroundTransparency = 1,
            }, selectBtn)

            -- Lista de opções (popup)
            local dropList = Util.Create("Frame", {
                Position         = UDim2.new(0, 0, 1, 4),
                Size             = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.Surface2,
                ClipsDescendants = true,
                Visible          = false,
                ZIndex           = 10,
            }, card)
            Util.Corner(dropList, 6)
            Util.Stroke(dropList, Theme.Border, 1)

            local listLayout = Util.Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding       = UDim.new(0, 2),
                SortOrder     = Enum.SortOrder.LayoutOrder,
            }, dropList)
            Util.Create("UIPadding",{PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4),PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4)},dropList)

            local itemH = 28
            for i, opt in ipairs(choices) do
                local item = Util.Create("TextButton", {
                    Text             = opt,
                    Font             = Enum.Font.Gotham,
                    TextSize         = 12,
                    TextColor3       = Theme.Text,
                    Size             = UDim2.new(1, 0, 0, itemH),
                    BackgroundColor3 = Theme.Surface2,
                    LayoutOrder      = i,
                    ZIndex           = 11,
                }, dropList)
                Util.Corner(item, 4)
                Util.Hover(item, Theme.Surface2, Theme.Surface3)

                item.MouseButton1Click:Connect(function()
                    selected       = opt
                    selectBtn.Text = opt
                    isOpen = false
                    Util.Tween(dropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                    task.wait(0.2)
                    dropList.Visible = false
                    card.ZIndex      = 1
                    if opts.Callback then
                        local ok2, err = pcall(opts.Callback, opt)
                        if not ok2 then warn("[SageUI] Dropdown callback error:", err) end
                    end
                end)
            end

            local totalH = #choices * (itemH + 2) + 8

            selectBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    dropList.Visible = true
                    card.ZIndex = 5
                    dropList.Size = UDim2.new(1, 0, 0, 0)
                    Util.Tween(dropList, { Size = UDim2.new(1, 0, 0, totalH) }, 0.2)
                else
                    Util.Tween(dropList, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                    task.wait(0.2)
                    dropList.Visible = false
                    card.ZIndex = 1
                end
            end)

            return {
                SetValue = function(v) selected = v; selectBtn.Text = v end,
                GetValue = function()  return selected end,
            }
        end

        -- ── TextBox ───────────────────────────────────────────────
        ---@param opts { Name:string, Default:string|nil, PlaceholderText:string|nil, Callback:function|nil }
        function Tab:AddTextBox(opts)
            opts = opts or {}
            local card = ElementCard(38)

            Util.Create("TextLabel", {
                Text      = opts.Name or "Input",
                Font      = Enum.Font.Gotham,
                TextSize  = 13,
                TextColor3= Theme.Text,
                Position  = UDim2.new(0, 12, 0, 0),
                Size      = UDim2.new(0.4, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
            }, card)

            local box = Util.Create("TextBox", {
                Text             = opts.Default or "",
                PlaceholderText  = opts.PlaceholderText or "Digite aqui...",
                PlaceholderColor3= Theme.TextMuted,
                Font             = Enum.Font.Gotham,
                TextSize         = 12,
                TextColor3       = Theme.Text,
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -10, 0.5, 0),
                Size             = UDim2.new(0.54, 0, 0, 26),
                BackgroundColor3 = Theme.Surface3,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
            }, card)
            Util.Corner(box, 5)
            Util.Stroke(box, Theme.Border, 1)
            Util.Create("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},box)

            box.Focused:Connect(function()
                Util.Tween(box, { BackgroundColor3 = Theme.Surface2 }, 0.15)
            end)
            box.FocusLost:Connect(function(enter)
                Util.Tween(box, { BackgroundColor3 = Theme.Surface3 }, 0.15)
                if opts.Callback then
                    local ok2, err = pcall(opts.Callback, box.Text, enter)
                    if not ok2 then warn("[SageUI] TextBox callback error:", err) end
                end
            end)

            return {
                SetValue = function(v) box.Text = v end,
                GetValue = function()  return box.Text end,
            }
        end

        -- ── Label ─────────────────────────────────────────────────
        ---@param opts { Text:string, Color:Color3|nil }
        function Tab:AddLabel(opts)
            opts = opts or {}
            local card = ElementCard(30)
            Util.Create("TextLabel", {
                Text      = opts.Text or "",
                Font      = Enum.Font.Gotham,
                TextSize  = 12,
                TextColor3= opts.Color or Theme.TextMuted,
                Position  = UDim2.new(0, 12, 0, 0),
                Size      = UDim2.new(1, -20, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped= true,
                BackgroundTransparency = 1,
            }, card)
            return card
        end

        -- ── Separator ─────────────────────────────────────────────
        ---@param opts { Text:string|nil }
        function Tab:AddSeparator(opts)
            opts = opts or {}
            local card = ElementCard(20)
            card.BackgroundTransparency = 1

            if opts.Text and opts.Text ~= "" then
                Util.Create("TextLabel", {
                    Text      = opts.Text,
                    Font      = Enum.Font.GothamBold,
                    TextSize  = 10,
                    TextColor3= Theme.Primary,
                    Size      = UDim2.new(1, -24, 1, 0),
                    Position  = UDim2.new(0, 12, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                }, card)
            end

            Util.Create("Frame", {
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = UDim2.new(0, 0, 0.5, 0),
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Border,
            }, card)
        end

        -- ── Keybind ───────────────────────────────────────────────
        ---@param opts { Name:string, Default:Enum.KeyCode|nil, Callback:function|nil }
        function Tab:AddKeybind(opts)
            opts = opts or {}
            local key     = opts.Default or Enum.KeyCode.Unknown
            local binding = false

            local card = ElementCard(38)
            Util.Create("TextLabel", {
                Text      = opts.Name or "Keybind",
                Font      = Enum.Font.Gotham,
                TextSize  = 13,
                TextColor3= Theme.Text,
                Position  = UDim2.new(0, 12, 0, 0),
                Size      = UDim2.new(0.55, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
            }, card)

            local keyBtn = Util.Create("TextButton", {
                Text             = key == Enum.KeyCode.Unknown and "Nenhum" or key.Name,
                Font             = Enum.Font.GothamBold,
                TextSize         = 11,
                TextColor3       = Theme.Primary,
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -10, 0.5, 0),
                Size             = UDim2.new(0, 72, 0, 26),
                BackgroundColor3 = Theme.Surface3,
            }, card)
            Util.Corner(keyBtn, 5)
            Util.Stroke(keyBtn, Theme.Border, 1)

            keyBtn.MouseButton1Click:Connect(function()
                binding      = true
                keyBtn.Text  = "..."
                keyBtn.TextColor3 = Theme.Warning
            end)

            UserInputService.InputBegan:Connect(function(inp, gpe)
                if not binding then
                    -- Executa callback se a tecla bater
                    if inp.KeyCode == key and opts.Callback then
                        pcall(opts.Callback)
                    end
                    return
                end
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    binding   = false
                    key       = inp.KeyCode
                    keyBtn.Text = key.Name
                    keyBtn.TextColor3 = Theme.Primary
                end
            end)

            return {
                GetKey   = function() return key end,
                SetKey   = function(k) key = k; keyBtn.Text = k.Name end,
            }
        end

        -- ── ColorPick (simplificado) ──────────────────────────────
        ---@param opts { Name:string, Default:Color3|nil, Callback:function|nil }
        function Tab:AddColorPicker(opts)
            opts = opts or {}
            local color = opts.Default or Theme.Primary
            local presets = {
                Color3.fromRGB(135,168,120), Color3.fromRGB(210,80,80),
                Color3.fromRGB(80,150,210),  Color3.fromRGB(220,180,60),
                Color3.fromRGB(180,100,220), Color3.fromRGB(232,232,232),
                Color3.fromRGB(100,200,120), Color3.fromRGB(60,60,60),
            }

            local card = ElementCard(38)
            card.Size  = UDim2.new(1, 0, 0, 38)

            Util.Create("TextLabel", {
                Text      = opts.Name or "Color",
                Font      = Enum.Font.Gotham,
                TextSize  = 13,
                TextColor3= Theme.Text,
                Position  = UDim2.new(0, 12, 0, 0),
                Size      = UDim2.new(0.45, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
            }, card)

            local preview = Util.Create("Frame", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -10, 0.5, 0),
                Size             = UDim2.new(0, 24, 0, 24),
                BackgroundColor3 = color,
            }, card)
            Util.Corner(preview, 6)
            Util.Stroke(preview, Theme.Border, 1)

            -- Mini palette
            local palette = Util.Create("Frame", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -42, 0.5, 0),
                Size             = UDim2.new(0, (#presets * 18) + 4, 0, 22),
                BackgroundColor3 = Theme.Surface3,
                Visible          = false,
                ZIndex           = 10,
            }, card)
            Util.Corner(palette, 5)

            for i, pc in ipairs(presets) do
                local dot = Util.Create("TextButton", {
                    Text             = "",
                    Position         = UDim2.new(0, (i-1)*18+2, 0.5, -8),
                    Size             = UDim2.new(0, 16, 0, 16),
                    BackgroundColor3 = pc,
                    ZIndex           = 11,
                }, palette)
                Util.Corner(dot, 4)
                dot.MouseButton1Click:Connect(function()
                    color           = pc
                    preview.BackgroundColor3 = pc
                    palette.Visible = false
                    if opts.Callback then pcall(opts.Callback, pc) end
                end)
            end

            preview.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    palette.Visible = not palette.Visible
                end
            end)

            return {
                GetValue = function() return color end,
                SetValue = function(c) color = c; preview.BackgroundColor3 = c end,
            }
        end

        return Tab
    end -- Window:AddTab

    return Window
end -- SageUI:CreateWindow

-- ─────────────────────────────────────────────────────────────────
--  RETORNO
-- ─────────────────────────────────────────────────────────────────
return SageUI

--[[
═══════════════════════════════════════════════════════════════════
  EXEMPLO DE USO COMPLETO
═══════════════════════════════════════════════════════════════════

local SageUI = loadstring(game:HttpGet("URL_DA_BIBLIOTECA"))()

-- Janela principal
local Win = SageUI:CreateWindow({
    Title    = "Meu Script",
    Size     = UDim2.new(0, 540, 0, 420),
    Icon     = "rbxassetid://10734912443",
})

-- Aba Principal
local Main = Win:AddTab({ Name = "Principal" })

Main:AddSeparator({ Text = "COMBATE" })

Main:AddToggle({
    Name     = "God Mode",
    Default  = false,
    Callback = function(val)
        print("GodMode:", val)
    end,
})

Main:AddSlider({
    Name     = "Velocidade",
    Min      = 16, Max = 300,
    Default  = 16,
    Callback = function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end,
})

Main:AddDropdown({
    Name     = "Arma",
    Options  = { "Pistola", "Rifle", "Shotgun" },
    Default  = "Pistola",
    Callback = function(opt)
        print("Selecionado:", opt)
    end,
})

Main:AddButton({
    Name     = "Teleportar",
    Callback = function()
        SageUI.Notify({ Title = "Sucesso", Message = "Teleportado!", Type = "success", Duration = 3 })
    end,
})

-- Aba de Configurações
local Settings = Win:AddTab({ Name = "Config" })

Settings:AddKeybind({
    Name     = "Ativar Fly",
    Default  = Enum.KeyCode.F,
    Callback = function()
        print("Fly ativado!")
    end,
})

Settings:AddColorPicker({
    Name     = "Cor do ESP",
    Default  = Color3.fromRGB(135, 168, 120),
    Callback = function(c)
        print("Cor escolhida:", c)
    end,
})

Settings:AddTextBox({
    Name            = "Nome do Jogador",
    PlaceholderText = "ex: Robloxian",
    Callback        = function(text, enter)
        if enter then print("Nome:", text) end
    end,
})

═══════════════════════════════════════════════════════════════════
]]
