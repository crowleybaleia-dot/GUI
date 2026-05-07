-- ╔══════════════════════════════════════════╗
-- ║           VANTA UI FRAMEWORK             ║
-- ║         dark · glassmorphism             ║
-- ╚══════════════════════════════════════════╝
--
-- Usage:
--   local lib = loadstring(...)()
--   local win = lib:init("MyHub", "v1.0", "rbxassetid://XXX", Enum.KeyCode.Insert, true)
--
--   local tab = win:Section("Combat", "rbxassetid://XXX")
--   local grp = tab:Group("Aimbot", "rbxassetid://XXX")
--
--   grp:Toggle("Enabled", false, function(v) end)
--   grp:Slider("Smoothness", 0, 100, 35, function(v) end)
--   grp:Dropdown("Target", {"Head","Torso","HRP"}, "Head", function(v) end)
--   grp:MultiDropdown("Layers", {"Box","Name","HP"}, {"Box"}, function(t) end)
--   grp:Button("Fire", function() end)
--   grp:Label("Some text")
--   grp:Paragraph("Long description here...")
--   grp:TextField("Name", "Enter...", function(v) end)
--   grp:ColorDot("Color", Color3.fromRGB(80,140,255), function(c) end)
--   grp:Keybind("Hold Key", Enum.KeyCode.C, function(k) end)
--   grp:SectionLabel("Sub Section")
--
--   win:TempNotify("Title", "Message", "success", 4)   -- type: success/warn/error/info
--   win:Notify("Title", "Body", "OK", "rbxassetid://XXX", callback)
--   win:Notify2("Title", "Body", "Yes", "No", "rbxassetid://XXX", cb1, cb2)
--   win:Divider("SYSTEM")
--   win:ToggleVisible()

local lib = {}

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Debris            = game:GetService("Debris")

-- ─── tween helper ──────────────────────────────────────────────────────────
local function tw(obj, props, t, style, dir)
    TweenService:Create(
        obj,
        TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

-- ─── instance shortcuts ────────────────────────────────────────────────────
local function applyProps(inst, props)
    for k, v in pairs(props or {}) do inst[k] = v end
    return inst
end

local function Frame(parent, props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    applyProps(f, props)
    f.Parent = parent
    return f
end

local function Label(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.Font = Enum.Font.Gotham
    applyProps(l, props)
    l.Parent = parent
    return l
end

local function Button(parent, props)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.Font = Enum.Font.Gotham
    applyProps(b, props)
    b.Parent = parent
    return b
end

local function Image(parent, props)
    local i = Instance.new("ImageLabel")
    i.BackgroundTransparency = 1
    i.BorderSizePixel = 0
    applyProps(i, props)
    i.Parent = parent
    return i
end

local function Corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function Stroke(parent, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = col or Color3.fromRGB(255,255,255)
    s.Thickness = thick or 1
    s.Transparency = trans or 0.92
    s.Parent = parent
    return s
end

local function ListLayout(parent, props)
    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    applyProps(l, props)
    l.Parent = parent
    return l
end

local function Padding(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent = parent
    return p
end

-- ─── palette ───────────────────────────────────────────────────────────────
local C = {
    bg       = Color3.fromRGB(26,  26,  26),   -- #1a1a1a fundo da janela
    sidebar  = Color3.fromRGB(17,  17,  17),   -- #111111 sidebar
    surface  = Color3.fromRGB(17,  17,  17),   -- #111111 surface/modal
    element  = Color3.fromRGB(17,  17,  17),   -- #111111 elementos
    white    = Color3.fromRGB(255, 255, 255),  -- #ffffff branco puro
    hi       = Color3.fromRGB(221, 221, 221),  -- #dddddd texto principal
    mid      = Color3.fromRGB(180, 180, 180),  -- cinza médio
    low      = Color3.fromRGB(102, 102, 102),  -- #666666 texto inativo
    dim      = Color3.fromRGB(85,  85,  85),   -- #555555 descrição/placeholder
    border   = Color3.fromRGB(42,  42,  42),   -- #2a2a2a bordas sutis
    accent   = Color3.fromRGB(179, 136, 255),  -- #b388ff roxo accent
    accentBg = Color3.fromRGB(30,  26,  42),   -- #1e1a2a fundo tab ativo
    onBg     = Color3.fromRGB(179, 136, 255),  -- #b388ff checkbox ON
    offBg    = Color3.fromRGB(17,  17,  17),   -- #111111 checkbox OFF
    knob     = Color3.fromRGB(17,  17,  17),   -- #111111
    toastBg  = Color3.fromRGB(17,  17,  17),   -- #111111
    success  = Color3.fromRGB(179, 136, 255),  -- accent
    warn     = Color3.fromRGB(179, 136, 255),  -- accent
    err      = Color3.fromRGB(179, 136, 255),  -- accent
    info     = Color3.fromRGB(179, 136, 255),  -- accent
}

-- ═══════════════════════════════════════════════════════════════════════════
function lib:init(title, subtitle, logoAsset, visibleKey, deletePrevious, logoSize, backgroundAsset)

    -- ── ScreenGui ──────────────────────────────────────────────────────────
    local hui = gethui()
    if hui:FindFirstChild("VantaUI") and deletePrevious then
        local old = hui.VantaUI
        local oldOuter = old:FindFirstChild("main")
        if oldOuter then
            tw(oldOuter, {Position = oldOuter.Position + UDim2.new(0,0,2,0)}, 0.4)
        end
        Debris:AddItem(old, 0.5)
    end

    local scrgui = Instance.new("ScreenGui")
    scrgui.Name           = "VantaUI"
    scrgui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    scrgui.ResetOnSpawn   = false
    scrgui.IgnoreGuiInset = true
    scrgui.Parent         = hui

    -- ── main window  820 × 440 ─────────────────────────────────────────
    local main = Frame(scrgui, {
        Name                 = "main",
        AnchorPoint          = Vector2.new(0.5, 0.5),
        Position             = UDim2.new(0.5, 0, 2, 0),
        Size                 = UDim2.new(0, 820, 0, 500),
        BackgroundColor3     = C.bg,
        BackgroundTransparency = 0,
        ClipsDescendants     = true,
        ZIndex               = 1,
    })
    Corner(main, 14)
    Stroke(main, C.border, 1, 0)

    -- background image layer
    if backgroundAsset and backgroundAsset ~= "" then
        local bgImg = Image(main, {
            Size              = UDim2.new(1,0,1,0),
            Image             = backgroundAsset,
            ScaleType         = Enum.ScaleType.Crop,
            ImageTransparency = 0.6,
            ZIndex            = 0,
        })
        Corner(bgImg, 14)
    end
    local drag, dragStart, startPos
    main.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if (i.Position.Y - main.AbsolutePosition.Y) > 60 then return end
        drag = true; dragStart = i.Position; startPos = main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then drag = false end
        end)
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                           startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    -- ── titlebar  (60px) ───────────────────────────────────────────────────
    local titlebar = Frame(main, {
        Name                 = "titlebar",
        Size                 = UDim2.new(1, 0, 0, 60),
        BackgroundColor3     = C.sidebar,
        BackgroundTransparency = 0,
        ZIndex               = 4,
    })
    -- bottom border
    Frame(titlebar, {
        Position             = UDim2.new(0,0,1,-1),
        Size                 = UDim2.new(1,0,0,1),
        BackgroundColor3     = C.border,
        BackgroundTransparency = 0,
        ZIndex               = 4,
    })

    -- ── TitleHolder (logo + título lado a lado via UIListLayout) ─────────────
    local iconSize = logoSize or UDim2.new(0, 92, 0, 92)

    local titleHolder = Frame(titlebar, {
        Position             = UDim2.new(0, -10, 0, 0),
        Size                 = UDim2.new(0, 300, 1, 0),
        BackgroundTransparency = 1,
        ZIndex               = 4,
    })
    local titleLayout = Instance.new("UIListLayout")
    titleLayout.FillDirection         = Enum.FillDirection.Horizontal
    titleLayout.HorizontalAlignment   = Enum.HorizontalAlignment.Left
    titleLayout.VerticalAlignment     = Enum.VerticalAlignment.Center
    titleLayout.Padding               = UDim.new(0, -10)
    titleLayout.SortOrder             = Enum.SortOrder.LayoutOrder
    titleLayout.Parent                = titleHolder

    -- ícone ou fallback letra
    if logoAsset and logoAsset ~= "" then
        Image(titleHolder, {
            Size              = iconSize,
            Image             = logoAsset,
            ImageColor3       = C.white,
            ImageTransparency = 0.1,
            ScaleType         = Enum.ScaleType.Fit,
            ZIndex            = 4,
            LayoutOrder       = 1,
        })
    else
        Label(titleHolder, {
            Size           = iconSize,
            Text           = string.upper((title or "V"):sub(1, 1)),
            TextColor3     = C.hi,
            TextSize       = iconSize.Y.Offset * 0.6,
            TextScaled     = false,
            Font           = Enum.Font.GothamBold,
            ZIndex         = 4,
            LayoutOrder    = 1,
        })
    end

    -- bloco de texto (title + subtitle empilhados)
    local textBlock = Frame(titleHolder, {
        Size                 = UDim2.new(0, 220, 1, 0),
        BackgroundTransparency = 1,
        ZIndex               = 4,
        LayoutOrder          = 2,
    })
    local textLayout = Instance.new("UIListLayout")
    textLayout.FillDirection       = Enum.FillDirection.Vertical
    textLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    textLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
    textLayout.Padding             = UDim.new(0, 2)
    textLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    textLayout.Parent              = textBlock

    Label(textBlock, {
        Size           = UDim2.new(1, 0, 0, 14),
        Text           = string.upper(title or "VANTA"),
        TextColor3     = C.hi,
        TextSize       = 11,
        Font           = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 4,
        LayoutOrder    = 1,
    })

    Label(textBlock, {
        Size           = UDim2.new(1, 0, 0, 11),
        Text           = subtitle or "",
        TextColor3     = C.hi,
        TextSize       = 9,
        Font           = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 4,
        LayoutOrder    = 2,
    })

    Corner(titlebar, 14)

    -- dots estilo macOS no canto superior direito
    local dotColors = {
        Color3.fromRGB(255, 95,  86),  -- vermelho
        Color3.fromRGB(255, 189, 46),  -- amarelo
        Color3.fromRGB(39,  201, 63),  -- verde
    }
    for i, col in ipairs(dotColors) do
        local d = Frame(titlebar, {
            Position         = UDim2.new(1, -14 - (i-1)*16, 0.5, -4),
            Size             = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = col,
            BackgroundTransparency = 0.2,
            ZIndex           = 6,
        })
        Corner(d, 4)
    end
    -- hiders dos cantos inferiores do titlebar (nao devem ser arredondados)
    Frame(titlebar, {
        Position             = UDim2.new(0,0,1,-14),
        Size                 = UDim2.new(0,14,0,14),
        BackgroundColor3     = C.sidebar,
        BackgroundTransparency = 0,
        ZIndex               = 5,
    })
    Frame(titlebar, {
        Position             = UDim2.new(1,-14,1,-14),
        Size                 = UDim2.new(0,14,0,14),
        BackgroundColor3     = C.sidebar,
        BackgroundTransparency = 0,
        ZIndex               = 5,
    })
    -- (botões de fechar/minimizar removidos — use visibleKey para toggle)

    -- ── sidebar  (168px wide) ──────────────────────────────────────────────
    local sidebar = Frame(main, {
        Name                 = "sidebar",
        Position             = UDim2.new(0,0,0,60),
        Size                 = UDim2.new(0,168,1,-84),
        BackgroundColor3     = C.sidebar,
        BackgroundTransparency = 0,
        ClipsDescendants     = true,
        ZIndex               = 3,
    })
    Corner(sidebar, 14)
    -- hider do canto superior esquerdo da sidebar
    Frame(sidebar, {
        Position             = UDim2.new(0,0,0,0),
        Size                 = UDim2.new(0,14,0,14),
        BackgroundColor3     = C.sidebar,
        BackgroundTransparency = 0,
        ZIndex               = 4,
    })
    -- right border
    Frame(sidebar, {
        Position             = UDim2.new(1,-1,0,0),
        Size                 = UDim2.new(0,1,1,0),
        BackgroundColor3     = C.border,
        BackgroundTransparency = 0,
        ZIndex               = 3,
    })

    -- ── sidebar header: avatar + hub name + game subtitle ─────────────────
    local sidebarHeader = Frame(sidebar, {
        Position             = UDim2.new(0,0,0,0),
        Size                 = UDim2.new(1,0,0,52),
        BackgroundTransparency = 1,
        ZIndex               = 4,
    })

    -- avatar circular com letra inicial
    local avatarCircle = Frame(sidebarHeader, {
        Position             = UDim2.new(0,10,0.5,-14),
        Size                 = UDim2.new(0,28,0,28),
        BackgroundColor3     = Color3.fromRGB(51,51,51),
        BackgroundTransparency = 0,
        ZIndex               = 5,
    })
    Corner(avatarCircle, 14)
    if logoAsset and logoAsset ~= "" then
        Image(avatarCircle, {
            Size              = UDim2.new(1,0,1,0),
            Image             = logoAsset,
            ScaleType         = Enum.ScaleType.Fit,
            ZIndex            = 6,
        })
    else
        Label(avatarCircle, {
            Size           = UDim2.new(1,0,1,0),
            Text           = string.upper((title or "V"):sub(1,1)),
            TextColor3     = C.mid,
            TextSize       = 12,
            Font           = Enum.Font.GothamBold,
            ZIndex         = 6,
        })
    end

    -- hub name
    Label(sidebarHeader, {
        Position       = UDim2.new(0,46,0,10),
        Size           = UDim2.new(1,-56,0,16),
        Text           = title or "VantaHub",
        TextColor3     = C.hi,
        TextSize       = 12,
        Font           = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 5,
    })

    -- game subtitle
    Label(sidebarHeader, {
        Position       = UDim2.new(0,46,0,28),
        Size           = UDim2.new(1,-56,0,12),
        Text           = subtitle or "",
        TextColor3     = C.low,
        TextSize       = 9,
        Font           = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 5,
    })

    -- linha separadora abaixo do header
    Frame(sidebarHeader, {
        Position             = UDim2.new(0,0,1,-1),
        Size                 = UDim2.new(1,0,0,1),
        BackgroundColor3     = C.border,
        BackgroundTransparency = 0,
        ZIndex               = 4,
    })

    -- sidebar scroll (começa após o header)
    local sidebarScroll = Instance.new("ScrollingFrame")
    sidebarScroll.Name                = "sidebarScroll"
    sidebarScroll.Position            = UDim2.new(0,0,0,52)
    sidebarScroll.Size                = UDim2.new(1,0,1,-88)
    sidebarScroll.BackgroundTransparency = 1
    sidebarScroll.BorderSizePixel     = 0
    sidebarScroll.ScrollBarThickness  = 2
    sidebarScroll.ScrollBarImageColor3 = C.dim
    sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebarScroll.CanvasSize          = UDim2.new(0,0,0,0)
    sidebarScroll.ZIndex              = 3
    sidebarScroll.Parent              = sidebar
    ListLayout(sidebarScroll, {Padding = UDim.new(0,1)})

    -- ── search bar real ───────────────────────────────────────────────────
    local searchHolder = Frame(sidebar, {
        Position             = UDim2.new(0, 0, 1, -36),
        Size                 = UDim2.new(1, 0, 0, 36),
        BackgroundColor3     = C.sidebar,
        BackgroundTransparency = 0,
        ZIndex               = 4,
    })
    Frame(searchHolder, {
        Position             = UDim2.new(0,0,0,0),
        Size                 = UDim2.new(1,0,0,1),
        BackgroundColor3     = C.border,
        BackgroundTransparency = 0,
        ZIndex               = 4,
    })
    local searchBg = Frame(searchHolder, {
        Position             = UDim2.new(0, 8, 0.5, -9),
        Size                 = UDim2.new(1, -16, 0, 18),
        BackgroundColor3     = C.border,
        BackgroundTransparency = 0,
        ZIndex               = 5,
    })
    Corner(searchBg, 4)
    -- search icon
    Image(searchBg, {
        Position          = UDim2.new(0, 4, 0.5, -6),
        Size              = UDim2.new(0, 12, 0, 12),
        Image             = "rbxassetid://3926305904",
        ImageRectOffset   = Vector2.new(964, 324),
        ImageRectSize     = Vector2.new(36, 36),
        ImageColor3       = C.dim,
        ZIndex            = 6,
    })
    local searchBox = Instance.new("TextBox")
    searchBox.Position            = UDim2.new(0, 20, 0, 0)
    searchBox.Size                = UDim2.new(1, -24, 1, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.BorderSizePixel     = 0
    searchBox.Font                = Enum.Font.Gotham
    searchBox.PlaceholderText     = "Search..."
    searchBox.PlaceholderColor3   = C.dim
    searchBox.Text                = ""
    searchBox.TextColor3          = C.hi
    searchBox.TextSize            = 9
    searchBox.ClearTextOnFocus    = false
    searchBox.TextXAlignment      = Enum.TextXAlignment.Left
    searchBox.ZIndex              = 6
    searchBox.Parent              = searchBg

    -- ── pill indicator (viaja entre os tabs) ──────────────────────────────
    local pill = Frame(sidebar, {
        Name                 = "pill",
        Position             = UDim2.new(0, 0, 0, 52),
        Size                 = UDim2.new(1, 0, 0, 32),
        BackgroundColor3     = C.accentBg,
        BackgroundTransparency = 0,
        ZIndex               = 2,
    })
    Corner(pill, 0)
    -- borda esquerda accent
    Frame(pill, {
        Position             = UDim2.new(0,0,0,0),
        Size                 = UDim2.new(0,2,1,0),
        BackgroundColor3     = C.accent,
        BackgroundTransparency = 0,
        ZIndex               = 3,
    })

    -- ── status bar  (24px) ────────────────────────────────────────────────
    local statusbar = Frame(main, {
        Position             = UDim2.new(0,0,1,-24),
        Size                 = UDim2.new(1,0,0,24),
        BackgroundColor3     = C.bg,
        BackgroundTransparency = 0.7,
        ZIndex               = 4,
    })
    Corner(statusbar, 14)
    -- hiders dos cantos superiores do statusbar
    Frame(statusbar, {
        Position             = UDim2.new(0,0,0,0),
        Size                 = UDim2.new(0,14,0,14),
        BackgroundColor3     = C.bg,
        BackgroundTransparency = 0,
        ZIndex               = 5,
    })
    Frame(statusbar, {
        Position             = UDim2.new(1,-14,0,0),
        Size                 = UDim2.new(0,14,0,14),
        BackgroundColor3     = C.bg,
        BackgroundTransparency = 0,
        ZIndex               = 5,
    })
    Frame(statusbar, {
        Size                 = UDim2.new(1,0,0,1),
        BackgroundColor3     = C.border,
        BackgroundTransparency = 0,
        ZIndex               = 4,
    })
    -- ── state ─────────────────────────────────────────────────────────────
    local sections     = {}
    local workareas    = {}
    local visible      = true
    local dbc          = false
    local toastQueue   = {}

    -- toast container (stacks toasts vertically, top-left)
    local toastContainer = Frame(scrgui, {
        Name             = "ToastContainer",
        Position         = UDim2.new(0, 12, 0, 12),
        Size             = UDim2.new(0, 300, 1, -24),
        BackgroundTransparency = 1,
        ZIndex           = 50,
    })
    ListLayout(toastContainer, {
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment   = Enum.VerticalAlignment.Top,
        Padding             = UDim.new(0, 4),
    })

    -- animate in: grow + fade in a partir de 60%
    main.Size = UDim2.new(0, 492, 0, 264)
    main.BackgroundTransparency = 1
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Visible = true
    tw(main, {Size = UDim2.new(0, 820, 0, 440), BackgroundTransparency = 0}, 0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    -- ═════════════════════════════════════════════════════════════════════
    local window = {}

    -- ── ToggleVisible ─────────────────────────────────────────────────────
    function window:ToggleVisible()
        if dbc then return end
        visible = not visible
        dbc = true
        if visible then
            main.Visible = true
            main.Size = UDim2.new(0, 492, 0, 264)
            main.BackgroundTransparency = 1
            tw(main, {Size = UDim2.new(0, 820, 0, 440), BackgroundTransparency = 0}, 0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        else
            tw(main, {Size = UDim2.new(0, 779, 0, 418), BackgroundTransparency = 1}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.delay(0.28, function() main.Visible = false end)
        end
        task.delay(0.4, function() dbc = false end)
    end

    -- toggle via keybind
    if visibleKey then
        UserInputService.InputBegan:Connect(function(i, gp)
            if not gp and i.KeyCode == visibleKey then window:ToggleVisible() end
        end)
    end

    -- ── TempNotify ────────────────────────────────────────────────────────
    function window:TempNotify(toastTitle, message, notifType, duration)
        duration = duration or 4

        local ts = game:GetService("TextService")
        local titleW = ts:GetTextSize(toastTitle or "", 10, Enum.Font.GothamMedium, Vector2.new(9999,28)).X
        local msgW   = ts:GetTextSize((message or "") .. "  ", 10, Enum.Font.Gotham, Vector2.new(9999,28)).X
        local fullW  = 10 + titleW + 18 + msgW + 10

        local toast = Frame(toastContainer, {
            Name                   = "VantaToast",
            Size                   = UDim2.new(0, 0, 0, 28),
            BackgroundColor3       = Color3.fromRGB(14, 14, 14),
            BackgroundTransparency = 0,
            ClipsDescendants       = true,
            ZIndex                 = 50,
        })
        Corner(toast, 5)
        Stroke(toast, C.white, 1, 0.88)
        table.insert(toastQueue, toast)

        Label(toast, {
            Position       = UDim2.new(0, 10, 0, 0),
            Size           = UDim2.new(0, titleW, 1, 0),
            Text           = toastTitle or "",
            TextColor3     = C.hi,
            TextSize       = 10,
            Font           = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex         = 51,
        })
        Label(toast, {
            Position       = UDim2.new(0, 10 + titleW + 4, 0, 0),
            Size           = UDim2.new(0, 10, 1, 0),
            Text           = "·",
            TextColor3     = C.hi,
            TextSize       = 10,
            Font           = Enum.Font.Gotham,
            ZIndex         = 51,
        })
        Label(toast, {
            Position       = UDim2.new(0, 10 + titleW + 18, 0, 0),
            Size           = UDim2.new(0, msgW, 1, 0),
            Text           = (message or "") .. "  ",
            TextColor3     = C.hi,
            TextSize       = 10,
            Font           = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex         = 51,
        })

        pcall(function()
            toast:TweenSize(UDim2.new(0, fullW, 0, 28), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)
        end)

        task.delay(duration, function()
            if not toast.Parent then return end
            pcall(function()
                toast:TweenSize(UDim2.new(0, 0, 0, 28), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
            end)
            Debris:AddItem(toast, 0.35)
            task.delay(0.35, function()
                for i, t in ipairs(toastQueue) do
                    if t == toast then table.remove(toastQueue, i) break end
                end
            end)
        end)
    end

    -- ── Notify (1-button modal) ───────────────────────────────────────────
    function window:Notify(t1, t2, btnTxt, iconAsset, callback)
        local overlay = Frame(main, {
            Size                 = UDim2.new(1,0,1,0),
            BackgroundColor3     = Color3.new(0,0,0),
            BackgroundTransparency = 0.45,
            ZIndex               = 10,
        })
        Corner(overlay, 14)

        local modal = Frame(overlay, {
            AnchorPoint          = Vector2.new(0.5,0.5),
            Position             = UDim2.new(0.5,0,0.5,0),
            Size                 = UDim2.new(0,280,0,206),
            BackgroundColor3     = C.surface,
            BackgroundTransparency = 0.05,
            ZIndex               = 11,
        })
        Corner(modal, 12)
        Stroke(modal, C.white, 1, 0.9)

        local yOff = 20
        if iconAsset then
            Image(modal, {
                Position   = UDim2.new(0.5,-24,0,16),
                Size       = UDim2.new(0,48,0,48),
                Image      = iconAsset,
                ImageColor3 = C.mid,
                ScaleType  = Enum.ScaleType.Fit,
                ZIndex     = 12,
            })
            yOff = 74
        end

        Label(modal, {
            Position       = UDim2.new(0,16,0,yOff),
            Size           = UDim2.new(1,-32,0,22),
            Text           = t1 or "",
            TextColor3     = C.hi,
            TextSize       = 13,
            Font           = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex         = 12,
        })
        Label(modal, {
            Position       = UDim2.new(0,16,0,yOff+26),
            Size           = UDim2.new(1,-32,0,56),
            Text           = t2 or "",
            TextColor3     = C.hi,
            TextSize       = 10,
            Font           = Enum.Font.Gotham,
            TextWrapped    = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex         = 12,
        })

        local ok = Button(modal, {
            Position             = UDim2.new(0,16,1,-50),
            Size                 = UDim2.new(1,-32,0,34),
            BackgroundColor3     = C.white,
            BackgroundTransparency = 0.1,
            Text                 = btnTxt or "OK",
            TextColor3           = C.bg,
            TextSize             = 12,
            Font                 = Enum.Font.GothamMedium,
            ZIndex               = 12,
        })
        Corner(ok, 7)
        ok.MouseButton1Click:Connect(function()
            overlay:Destroy()
            if callback then callback() end
        end)
    end

    -- ── Notify2 (2-button modal) ──────────────────────────────────────────
    function window:Notify2(t1, t2, b1txt, b2txt, iconAsset, cb1, cb2)
        local overlay = Frame(main, {
            Size                 = UDim2.new(1,0,1,0),
            BackgroundColor3     = Color3.new(0,0,0),
            BackgroundTransparency = 0.45,
            ZIndex               = 10,
        })
        Corner(overlay, 14)

        local modal = Frame(overlay, {
            AnchorPoint          = Vector2.new(0.5,0.5),
            Position             = UDim2.new(0.5,0,0.5,0),
            Size                 = UDim2.new(0,280,0,226),
            BackgroundColor3     = C.surface,
            BackgroundTransparency = 0.05,
            ZIndex               = 11,
        })
        Corner(modal, 12)
        Stroke(modal, C.white, 1, 0.9)

        local yOff = 20
        if iconAsset then
            Image(modal, {
                Position   = UDim2.new(0.5,-24,0,14),
                Size       = UDim2.new(0,48,0,48),
                Image      = iconAsset,
                ImageColor3 = C.mid,
                ScaleType  = Enum.ScaleType.Fit,
                ZIndex     = 12,
            })
            yOff = 70
        end

        Label(modal, {
            Position       = UDim2.new(0,16,0,yOff),
            Size           = UDim2.new(1,-32,0,22),
            Text           = t1 or "",
            TextColor3     = C.hi,
            TextSize       = 13,
            Font           = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex         = 12,
        })
        Label(modal, {
            Position       = UDim2.new(0,16,0,yOff+26),
            Size           = UDim2.new(1,-32,0,56),
            Text           = t2 or "",
            TextColor3     = C.hi,
            TextSize       = 10,
            Font           = Enum.Font.Gotham,
            TextWrapped    = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex         = 12,
        })

        local btn1 = Button(modal, {
            Position             = UDim2.new(0,16,1,-98),
            Size                 = UDim2.new(1,-32,0,34),
            BackgroundColor3     = C.white,
            BackgroundTransparency = 0.1,
            Text                 = b1txt or "Confirm",
            TextColor3           = C.bg,
            TextSize             = 12,
            Font                 = Enum.Font.GothamMedium,
            ZIndex               = 12,
        })
        Corner(btn1, 7)

        local btn2 = Button(modal, {
            Position             = UDim2.new(0,16,1,-54),
            Size                 = UDim2.new(1,-32,0,34),
            BackgroundColor3     = C.white,
            BackgroundTransparency = 0.97,
            Text                 = b2txt or "Cancel",
            TextColor3     = C.hi,
            TextSize             = 12,
            Font                 = Enum.Font.Gotham,
            ZIndex               = 12,
        })
        Corner(btn2, 7)
        Stroke(btn2, C.white, 1, 0.88)

        btn1.MouseButton1Click:Connect(function() overlay:Destroy(); if cb1 then cb1() end end)
        btn2.MouseButton1Click:Connect(function() overlay:Destroy(); if cb2 then cb2() end end)
    end

    -- ── Divider (sidebar section label) ───────────────────────────────────
    function window:Divider(name)
        local lbl = Label(sidebarScroll, {
            Size           = UDim2.new(1,0,0,22),
            Text           = string.upper(name or ""),
            TextColor3     = C.accent,
            TextSize       = 8,
            Font           = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex         = 3,
            LayoutOrder    = #sidebarScroll:GetChildren() + 1,
        })
        Padding(lbl, 0, 0, 14, 0)
    end

    -- ═════════════════════════════════════════════════════════════════════
    --  window.CreatePage({ Page_Name, Page_Title, iconAsset })
    -- ═════════════════════════════════════════════════════════════════════
    function window.CreatePage(opts)
        local name      = opts.Page_Name or opts.Page_Title or "Page"
        local iconAsset = opts.Icon or nil

        -- sidebar tab
        local tabBtn = Button(sidebarScroll, {
            Name                 = "tab_" .. name,
            Size                 = UDim2.new(1,0,0,32),
            BackgroundColor3     = C.white,
            BackgroundTransparency = 1,
            Text                 = "",
            ZIndex               = 3,
            LayoutOrder          = #sidebarScroll:GetChildren() + 1,
        })

        -- ícone do sidebar (sempre criado; invisível se sem asset)
        local tabIcon = Image(tabBtn, {
            Position          = UDim2.new(0, 14, 0.5, -8),
            Size              = UDim2.new(0, 16, 0, 16),
            Image             = iconAsset or "",
            ImageColor3       = C.low,
            ImageTransparency = iconAsset and 0.5 or 1,
            ScaleType         = Enum.ScaleType.Fit,
            ZIndex            = 4,
        })

        local tabLabel = Label(tabBtn, {
            Position       = UDim2.new(0, iconAsset and 36 or 14, 0, 0),
            Size           = UDim2.new(1, -(iconAsset and 50 or 28), 1, 0),
            Text           = name,
            TextColor3     = C.low,
            TextSize       = 11,
            Font           = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex         = 4,
        })

        -- workarea scroll (sits on top of content area position)
        local workarea = Instance.new("ScrollingFrame")
        workarea.Name                = "wa_" .. name
        workarea.Position            = UDim2.new(0,168,0,60)
        workarea.Size                = UDim2.new(1,-168,1,-84)
        workarea.BackgroundTransparency = 1
        workarea.BorderSizePixel     = 0
        workarea.ScrollBarThickness  = 3
        workarea.ScrollBarImageColor3 = Color3.fromRGB(45,45,45)
        workarea.ScrollBarImageTransparency = 1
        workarea.AutomaticCanvasSize = Enum.AutomaticSize.Y
        workarea.CanvasSize          = UDim2.new(0,0,0,0)
        workarea.ZIndex              = 2
        workarea.Visible             = false
        workarea.Parent              = main
        ListLayout(workarea, {Padding = UDim.new(0,8)})
        Padding(workarea, 12, 12, 14, 14)

        table.insert(sections, tabBtn)
        table.insert(workareas, workarea)

        -- ── sec object ───────────────────────────────────────────────────
        local sec = {}

        function sec.Select()
            for _, t in ipairs(sections) do
                t.BackgroundTransparency = 1
                local l = t:FindFirstChildWhichIsA("TextLabel")
                if l then tw(l, {TextColor3 = C.low}, 0.18); l.Font = Enum.Font.Gotham end
                local ic = t:FindFirstChildWhichIsA("ImageLabel")
                if ic then tw(ic, {ImageColor3 = C.low, ImageTransparency = 0.5}, 0.18) end
            end

            -- pill viaja até a posição do tab ativo
            local targetY = 52 + tabBtn.AbsolutePosition.Y - sidebarScroll.AbsolutePosition.Y + sidebarScroll.CanvasPosition.Y
            tw(pill, {Position = UDim2.new(0, 0, 0, targetY)}, 0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            -- ativa o tab atual
            tw(tabLabel, {TextColor3 = C.accent}, 0.18)
            tabLabel.Font = Enum.Font.GothamMedium
            if iconAsset then tw(tabIcon, {ImageColor3 = C.accent, ImageTransparency = 0}, 0.18) end

            for _, w in ipairs(workareas) do w.Visible = false end

            -- workarea original: scale + fade
            local basePos  = UDim2.new(0, 168, 0, 60)
            local baseSize = UDim2.new(1, -168, 1, -84)
            local scaleOff = 8

            workarea.Position = UDim2.new(0, 168 + scaleOff, 0, 60 + scaleOff)
            workarea.Size     = UDim2.new(1, -168 - scaleOff*2, 1, -84 - scaleOff*2)
            workarea.Visible  = true

            local overlay = Frame(main, {
                Position             = UDim2.new(0, 168, 0, 60),
                Size                 = UDim2.new(1, -168, 1, -84),
                BackgroundColor3     = C.bg,
                BackgroundTransparency = 0,
                ZIndex               = 50,
            })

            tw(workarea, {Position = basePos, Size = baseSize}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            tw(overlay,  {BackgroundTransparency = 1},          0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            Debris:AddItem(overlay, 0.22)
        end

        tabBtn.MouseButton1Click:Connect(function() sec.Select() end)
        tabBtn.MouseEnter:Connect(function()
            if workarea.Visible then return end
            tw(tabBtn,  {BackgroundTransparency = 0.94}, 0.1)
            tw(tabLabel,{TextColor3 = C.hi},             0.1)
            if iconAsset then tw(tabIcon, {ImageColor3 = C.mid, ImageTransparency = 0.3}, 0.1) end
        end)
        tabBtn.MouseLeave:Connect(function()
            if workarea.Visible then return end
            tw(tabBtn,  {BackgroundTransparency = 1},   0.1)
            tw(tabLabel,{TextColor3 = C.low},            0.1)
            if iconAsset then tw(tabIcon, {ImageColor3 = C.low, ImageTransparency = 0.5}, 0.1) end
        end)

        if #sections == 1 then sec.Select() end

        -- search filter: filtra tabs e elementos dentro dos groups
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = searchBox.Text:lower()
            if q == "" then
                tabBtn.Visible = true
                -- mostrar todos elementos dentro do workarea
                for _, grpOuter in ipairs(workarea:GetChildren()) do
                    if grpOuter:IsA("Frame") then
                        grpOuter.Visible = true
                        local gbox = grpOuter:FindFirstChildWhichIsA("Frame")
                        if gbox then
                            local body = gbox:FindFirstChild("body")
                            if body then
                                for _, row in ipairs(body:GetChildren()) do
                                    if not row:IsA("UIListLayout") and not row:IsA("UIPadding") then
                                        row.Visible = true
                                    end
                                end
                            end
                        end
                    end
                end
                return
            end
            -- verifica se o tab name bate
            local tabMatch = name:lower():find(q, 1, true) ~= nil
            -- verifica elementos dentro dos groups
            local anyMatch = tabMatch
            for _, grpOuter in ipairs(workarea:GetChildren()) do
                if grpOuter:IsA("Frame") then
                    local grpMatch = grpOuter.Name:lower():find(q, 1, true) ~= nil
                    local gbox = grpOuter:FindFirstChildWhichIsA("Frame")
                    local anyRowMatch = grpMatch
                    if gbox then
                        local body = gbox:FindFirstChild("body")
                        if body then
                            for _, row in ipairs(body:GetChildren()) do
                                if not row:IsA("UIListLayout") and not row:IsA("UIPadding") then
                                    local rowMatch = false
                                    for _, child in ipairs(row:GetDescendants()) do
                                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                                            if child.Text:lower():find(q, 1, true) then
                                                rowMatch = true
                                                break
                                            end
                                        end
                                    end
                                    row.Visible = grpMatch or rowMatch
                                    if rowMatch then anyRowMatch = true end
                                end
                            end
                        end
                    end
                    grpOuter.Visible = anyRowMatch
                    if anyRowMatch then anyMatch = true end
                end
            end
            tabBtn.Visible = anyMatch
        end)

        -- ══════════════════════════════════════════════════════════════════
        --  sec.CreateSection(sectionName, iconAsset)
        -- ══════════════════════════════════════════════════════════════════
        function sec.CreateSection(groupName, iconAsset)

            -- wrapper externo: só corner + stroke, sem filhos de conteúdo
            local gboxOuter = Frame(workarea, {
                Name                 = "grp_" .. groupName,
                Size                 = UDim2.new(1,0,0,0),
                AutomaticSize        = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ZIndex               = 3,
                LayoutOrder          = #workarea:GetChildren(),
            })
            Corner(gboxOuter, 9)
            Stroke(gboxOuter, C.border, 1, 0)

            -- frame interno com a cor de fundo, ClipsDescendants pra cortar os filhos nos cantos
            local gbox = Frame(gboxOuter, {
                Size                 = UDim2.new(1,0,0,0),
                AutomaticSize        = Enum.AutomaticSize.Y,
                BackgroundColor3     = C.white,
                BackgroundTransparency = 0.975,
                ClipsDescendants     = true,
                ZIndex               = 3,
            })
            Corner(gbox, 9)

            -- header
            local header = Frame(gbox, {
                Size                 = UDim2.new(1,0,0,28),
                BackgroundColor3     = C.white,
                BackgroundTransparency = 0.98,
                ZIndex               = 4,
            })
            -- linha separadora
            Frame(header, {
                Position             = UDim2.new(0,0,1,-1),
                Size                 = UDim2.new(1,0,0,1),
                BackgroundColor3     = C.white,
                BackgroundTransparency = 0.95,
                ZIndex               = 5,
            })

            if iconAsset then
                Image(header, {
                    Position          = UDim2.new(0,10,0.5,-7),
                    Size              = UDim2.new(0,14,0,14),
                    Image             = iconAsset,
                    ImageColor3       = C.low,
                    ImageTransparency = 0.5,
                    ScaleType         = Enum.ScaleType.Fit,
                    ZIndex            = 5,
                })
            end

            Label(header, {
                Position       = UDim2.new(0, iconAsset and 30 or 10, 0, 0),
                Size           = UDim2.new(1, -(iconAsset and 40 or 20), 1, 0),
                Text           = string.upper(groupName or ""),
                TextColor3     = C.hi,
                TextSize       = 9,
                Font           = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex         = 5,
            })

            -- body
            local body = Frame(gbox, {
                Name             = "body",
                Position         = UDim2.new(0,0,0,28),
                Size             = UDim2.new(1,0,0,0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ZIndex           = 4,
            })
            ListLayout(body)
            Padding(body, 4, 6, 10, 10)

            -- ── base row ─────────────────────────────────────────────────
            local function baseRow(lbl, h, desc)
                -- se tiver descrição, altura maior e layout vertical
                local hasDesc = desc and desc ~= ""
                h = h or (hasDesc and 42 or 30)
                local row = Frame(body, {
                    Size             = UDim2.new(1,0,0,h),
                    BackgroundTransparency = 1,
                    ZIndex           = 5,
                    LayoutOrder      = #body:GetChildren(),
                })

                if hasDesc then
                    -- label principal
                    Label(row, {
                        Position       = UDim2.new(0,0,0,6),
                        Size           = UDim2.new(0.6,0,0,14),
                        Text           = lbl or "",
                        TextColor3     = C.hi,
                        TextSize       = 11,
                        Font           = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex         = 6,
                    })
                    -- descrição secundária
                    Label(row, {
                        Position       = UDim2.new(0,0,0,22),
                        Size           = UDim2.new(0.75,0,0,12),
                        Text           = desc,
                        TextColor3     = C.dim,
                        TextSize       = 9,
                        Font           = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex         = 6,
                    })
                else
                    Label(row, {
                        Position       = UDim2.new(0,0,0,0),
                        Size           = UDim2.new(0.55,0,1,0),
                        Text           = lbl or "",
                        TextColor3     = C.hi,
                        TextSize       = 11,
                        Font           = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex         = 6,
                    })
                end
                return row
            end

            local grp = {}

            -- ── Toggle ───────────────────────────────────────────────────
            -- API: grp.CreateToggle({ Title, Default, Desc, Keybind, Textbox, TextboxPlaceholder, TextboxDefault, TextboxCallback }, cb)
            function grp.CreateToggle(opts, cb)
                local lbl     = opts.Title or ""
                local default = opts.Default
                local desc    = opts.Desc
                local keybind = opts.Keybind
                local hasTb   = opts.Textbox == true
                local tbPlch  = opts.TextboxPlaceholder or "Enter value..."
                local tbDef   = opts.TextboxDefault or ""
                local tbCb    = opts.TextboxCallback

                local state   = default == true
                local key     = keybind or nil
                local waiting = false
                local row     = baseRow(lbl, nil, desc)

                -- checkbox
                local box = Button(row, {
                    Position             = UDim2.new(1, -20, 0.5, -7),
                    Size                 = UDim2.new(0, 14, 0, 14),
                    BackgroundColor3     = state and C.onBg or C.offBg,
                    BackgroundTransparency = 0,
                    Text                 = "",
                    ZIndex               = 7,
                })
                Corner(box, 3)
                local boxStroke = Stroke(box, state and C.accent or C.dim, 1, 0)

                local checkLbl = Label(box, {
                    Size           = UDim2.new(1,0,1,0),
                    Text           = "✓",
                    TextColor3     = Color3.fromRGB(17,17,17),
                    TextSize       = 10,
                    Font           = Enum.Font.GothamBold,
                    ZIndex         = 8,
                    Visible        = state,
                })

                local function flip()
                    state = not state
                    tw(box, {BackgroundColor3 = state and C.onBg or C.offBg}, 0.14)
                    tw(boxStroke, {Color = state and C.accent or C.dim}, 0.14)
                    checkLbl.Visible = state
                    if cb then cb(state) end
                end
                box.MouseButton1Click:Connect(flip)

                -- textbox inline (à esquerda do checkbox)
                if hasTb then
                    local tbBg = Frame(row, {
                        AnchorPoint          = Vector2.new(1, 0.5),
                        Position             = UDim2.new(1, -38, 0.5, 0),
                        Size                 = UDim2.new(0, 60, 0, 18),
                        BackgroundColor3     = C.border,
                        BackgroundTransparency = 0,
                        ZIndex               = 7,
                    })
                    Corner(tbBg, 4)
                    Stroke(tbBg, C.accent, 1, 0.7)

                    local tb = Instance.new("TextBox")
                    tb.Position              = UDim2.new(0, 5, 0, 0)
                    tb.Size                  = UDim2.new(1, -10, 1, 0)
                    tb.BackgroundTransparency = 1
                    tb.BorderSizePixel       = 0
                    tb.Font                  = Enum.Font.Gotham
                    tb.PlaceholderText       = tbPlch
                    tb.PlaceholderColor3     = C.dim
                    tb.Text                  = tbDef
                    tb.TextColor3            = C.hi
                    tb.TextSize              = 9
                    tb.ClearTextOnFocus      = false
                    tb.TextXAlignment        = Enum.TextXAlignment.Left
                    tb.ZIndex                = 8
                    tb.Parent                = tbBg

                    tb.FocusLost:Connect(function(entered)
                        if entered and tbCb then tbCb(tb.Text) end
                    end)
                end

                -- keybind badge (à esquerda do checkbox, ou à esquerda do textbox)
                if keybind then
                    local keyName = tostring(key):gsub("Enum.KeyCode.","")
                    local kbOffX  = hasTb and -104 or -38

                    local kbLbl = Label(row, {
                        AnchorPoint    = Vector2.new(1, 0.5),
                        Position       = UDim2.new(1, kbOffX, 0.5, 0),
                        Size           = UDim2.new(0, 60, 0, 18),
                        Text           = "[" .. keyName .. "]",
                        TextColor3     = C.hi,
                        TextSize       = 9,
                        Font           = Enum.Font.Code,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        BackgroundTransparency = 1,
                        ZIndex         = 7,
                    })

                    local kbBtn = Button(row, {
                        AnchorPoint          = Vector2.new(1, 0.5),
                        Position             = UDim2.new(1, kbOffX, 0.5, 0),
                        Size                 = UDim2.new(0, 60, 0, 18),
                        BackgroundTransparency = 1,
                        Text                 = "",
                        ZIndex               = 8,
                    })

                    kbBtn.MouseButton1Click:Connect(function()
                        waiting        = true
                        kbLbl.Text     = "[...]"
                    end)

                    UserInputService.InputBegan:Connect(function(i, gp)
                        if gp then return end
                        if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
                        if waiting then
                            waiting       = false
                            key           = i.KeyCode
                            kbLbl.Text    = "[" .. tostring(key):gsub("Enum.KeyCode.","") .. "]"
                        elseif i.KeyCode == key then
                            flip()
                        end
                    end)
                end

                local o = {}
                function o:Set(v) if state ~= v then flip() end end
                function o:Get() return state end
                return o
            end
            -- legacy alias
            grp.Toggle = function(self, lbl, default, cb, keybind, desc)
                return grp.CreateToggle({Title=lbl, Default=default, Desc=desc, Keybind=keybind}, cb)
            end

            -- ── Slider ───────────────────────────────────────────────────
            -- API: grp.CreateSlider({ Title, Min, Max, Default, Precise }, cb)
            function grp.CreateSlider(opts, cb)
                local lbl     = opts.Title or ""
                local min     = opts.Min or 0
                local max     = opts.Max or 100
                local default = opts.Default or min
                local precise = opts.Precise == true
                local val     = default

                local slFrame = Frame(body, {
                    Size                 = UDim2.new(1,0,0,50),
                    BackgroundTransparency = 1,
                    ZIndex               = 5,
                    LayoutOrder          = #body:GetChildren(),
                })

                local bg1 = Frame(slFrame, {
                    AnchorPoint          = Vector2.new(0.5,0.5),
                    Position             = UDim2.new(0.5,0,0.5,0),
                    Size                 = UDim2.new(1,-10,1,0),
                    BackgroundColor3     = C.element,
                    BackgroundTransparency = 0,
                    ZIndex               = 6,
                })
                Corner(bg1, 4)

                Label(bg1, {
                    Position       = UDim2.new(0,10,0,0),
                    Size           = UDim2.new(1,-170,0,25),
                    Text           = lbl,
                    TextColor3     = C.hi,
                    TextSize       = 11,
                    Font           = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex         = 7,
                })

                local bg2 = Frame(bg1, {
                    AnchorPoint          = Vector2.new(1,0),
                    Position             = UDim2.new(1,-5,0,5),
                    Size                 = UDim2.new(0,150,0,20),
                    BackgroundColor3     = C.border,
                    BackgroundTransparency = 0,
                    ZIndex               = 7,
                })
                Corner(bg2, 4)

                local valBox = Instance.new("TextBox")
                valBox.Size                  = UDim2.new(1,0,1,0)
                valBox.BackgroundTransparency = 1
                valBox.BorderSizePixel       = 0
                valBox.Font                  = Enum.Font.GothamMedium
                valBox.Text                  = precise and tostring(val) or tostring(math.floor(val))
                valBox.TextColor3            = C.hi
                valBox.TextSize              = 10
                valBox.ClearTextOnFocus      = false
                valBox.TextXAlignment        = Enum.TextXAlignment.Center
                valBox.ZIndex                = 8
                valBox.Parent                = bg2

                -- track uses relative sizing via Scale
                local trackBg = Frame(slFrame, {
                    AnchorPoint          = Vector2.new(0.5,0.5),
                    Position             = UDim2.new(0.5,0,0.5,14),
                    Size                 = UDim2.new(1,-20,0,6),
                    BackgroundColor3     = C.border,
                    BackgroundTransparency = 0,
                    ZIndex               = 7,
                })
                Corner(trackBg, 3)

                local p0 = (val-min)/(max-min)
                local fill = Frame(trackBg, {
                    Size             = UDim2.new(p0, 0, 1, 0),
                    BackgroundColor3 = C.accent,
                    BackgroundTransparency = 0,
                    ZIndex           = 8,
                })
                Corner(fill, 3)

                local slBtn = Button(trackBg, {
                    Size                 = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text                 = "",
                    ZIndex               = 9,
                })

                local mouse = game.Players.LocalPlayer:GetMouse()
                local moveConn, releaseConn

                local function round(v)
                    return precise and (math.floor(v * 100 + 0.5) / 100) or math.floor(v + 0.5)
                end

                local function setVal(v)
                    val = math.clamp(round(v), min, max)
                    local p = (val-min)/(max-min)
                    fill.Size = UDim2.new(p, 0, 1, 0)
                    valBox.Text = tostring(val)
                    if cb then cb(val) end
                end

                local function calcFromMouse()
                    local tw = trackBg.AbsoluteSize.X
                    local ox = mouse.X - trackBg.AbsolutePosition.X
                    local ratio = math.clamp(ox / tw, 0, 1)
                    return min + (max - min) * ratio
                end

                slBtn.MouseEnter:Connect(function() tw(fill, {BackgroundColor3 = C.accentBg}, 0.15) end)
                slBtn.MouseLeave:Connect(function() tw(fill, {BackgroundColor3 = C.accent}, 0.15) end)

                slBtn.MouseButton1Down:Connect(function()
                    setVal(calcFromMouse())
                    moveConn = mouse.Move:Connect(function()
                        setVal(calcFromMouse())
                    end)
                    releaseConn = UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then
                            setVal(calcFromMouse())
                            if moveConn then moveConn:Disconnect() end
                            if releaseConn then releaseConn:Disconnect() end
                        end
                    end)
                end)

                valBox.FocusLost:Connect(function()
                    local v = tonumber(valBox.Text)
                    if v then setVal(v)
                    else valBox.Text = tostring(val) end
                end)

                local o = {}
                function o:Set(v) setVal(v) end
                function o:Get() return val end
                return o
            end
            -- legacy alias
            grp.Slider = function(self, lbl, min, max, default, cb)
                return grp.CreateSlider({Title=lbl, Min=min, Max=max, Default=default}, cb)
            end

            -- ── Dropdown ─────────────────────────────────────────────────
            function grp.CreateDropdown(opts, cb)
                local lbl     = opts.Title or ""
                local options = opts.List or opts.Options or {}
                local default = opts.Default or (options and options[1]) or ""
                local sel  = default
                local open = false

                -- frame externo, largura total, vai direto pro body
                local ddFrame = Frame(body, {
                    Size                 = UDim2.new(1,0,0,25),
                    BackgroundTransparency = 1,
                    ZIndex               = 5,
                    LayoutOrder          = #body:GetChildren(),
                })

                -- background 1: centralizado, cor element
                local bg1 = Frame(ddFrame, {
                    AnchorPoint          = Vector2.new(0.5,0.5),
                    Position             = UDim2.new(0.5,0,0.5,0),
                    Size                 = UDim2.new(1,-10,1,0),
                    BackgroundColor3     = C.element,
                    BackgroundTransparency = 0,
                    ClipsDescendants     = true,
                    ZIndex               = 6,
                })
                Corner(bg1, 4)

                -- background 2: barra interna (linha completa, fundo levemente diferente)
                local bg2 = Frame(bg1, {
                    Size                 = UDim2.new(1,0,1,0),
                    BackgroundColor3     = C.border,
                    BackgroundTransparency = 0.5,
                    ZIndex               = 7,
                })
                Corner(bg2, 4)

                -- label "Titulo: Valor"
                local btnLbl = Label(bg2, {
                    Position       = UDim2.new(0,10,0,0),
                    Size           = UDim2.new(1,-30,1,0),
                    Text           = lbl .. ": " .. sel,
                    TextColor3     = C.hi,
                    TextSize       = 11,
                    Font           = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex         = 8,
                })

                -- seta (imagem igual ao Feral)
                local arrow = Instance.new("ImageLabel")
                arrow.BackgroundTransparency = 1
                arrow.AnchorPoint = Vector2.new(1,0.5)
                arrow.Position = UDim2.new(1,-6,0.5,0)
                arrow.Size = UDim2.new(0,15,0,15)
                arrow.Image = "rbxassetid://6954383209"
                arrow.ImageColor3 = C.dim
                arrow.ZIndex = 8
                arrow.Parent = bg2

                -- botão transparente sobre tudo
                local ddBtn = Button(bg2, {
                    Size                 = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text                 = "",
                    ZIndex               = 9,
                })

                -- painel de opções
                local panel = Frame(gbox, {
                    Size             = UDim2.new(1,0,0,0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundColor3 = C.toastBg,
                    BackgroundTransparency = 0,
                    ZIndex           = 20,
                    Visible          = false,
                    ClipsDescendants = true,
                })
                Corner(panel, 5)
                Stroke(panel, C.border, 1, 0)
                ListLayout(panel)
                Padding(panel, 4, 4, 0, 0)

                for _, opt in ipairs(options or {}) do
                    local ob = Button(panel, {
                        Size                 = UDim2.new(1,0,0,24),
                        BackgroundColor3     = C.white,
                        BackgroundTransparency = 1,
                        Text                 = opt,
                        TextColor3           = opt == sel and C.hi or C.low,
                        TextSize             = 10,
                        Font                 = opt == sel and Enum.Font.GothamMedium or Enum.Font.Gotham,
                        ZIndex               = 21,
                    })
                    Padding(ob, 0, 0, 8, 8)
                    ob.MouseEnter:Connect(function() tw(ob, {BackgroundTransparency = 0.94}, 0.1) end)
                    ob.MouseLeave:Connect(function() tw(ob, {BackgroundTransparency = 1},    0.1) end)
                    ob.MouseButton1Click:Connect(function()
                        sel = opt
                        btnLbl.Text = lbl .. ": " .. opt
                        panel.Visible = false; open = false
                        if cb then cb(opt) end
                    end)
                end

                ddBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        local relY = ddFrame.AbsolutePosition.Y - gbox.AbsolutePosition.Y + 25
                        panel.Position = UDim2.new(0,0,0,relY)
                    end
                    panel.Visible = open
                end)

                local o = {}
                function o:Set(v) sel = v; btnLbl.Text = lbl .. ": " .. v; if cb then cb(v) end end
                function o:Get() return sel end
                return o
            end
            grp.Dropdown = function(self, lbl, options, default, cb)
                return grp.CreateDropdown({Title=lbl, List=options, Default=default}, cb)
            end

            -- ── MultiDropdown ─────────────────────────────────────────────
            function grp.CreateMultiDropdown(opts, cb)
                local lbl      = opts.Title or ""
                local options  = opts.List or opts.Options or {}
                local defaults = opts.Defaults or {}
                local sel  = {}
                for _, v in ipairs(defaults) do sel[v] = true end
                local open = false
                local row  = baseRow(lbl)

                local function count()
                    local n = 0; for _ in pairs(sel) do n+=1 end; return n
                end
                local function labelTxt()
                    local n = count(); local tot = #(options or {})
                    if n == 0 then return "None" elseif n == tot then return "All"
                    else return n .. " selected" end
                end

                local btn = Button(row, {
                    Position             = UDim2.new(1,-130,0.5,-11),
                    Size                 = UDim2.new(0,126,0,22),
                    BackgroundColor3     = C.white,
                    BackgroundTransparency = 0.96,
                    Text                 = "",
                    ZIndex               = 7,
                })
                Corner(btn, 5)
                Stroke(btn, C.white, 1, 0.9)

                local btnLbl = Label(btn, {
                    Position       = UDim2.new(0,8,0,0),
                    Size           = UDim2.new(1,-38,1,0),
                    Text           = labelTxt(),
                    TextColor3     = C.hi,
                    TextSize       = 10,
                    Font           = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex         = 8,
                })

                local badge = Label(btn, {
                    Position             = UDim2.new(1,-28,0.5,-7),
                    Size                 = UDim2.new(0,14,0,14),
                    Text                 = tostring(count()),
                    TextColor3           = C.hi,
                    TextSize             = 9,
                    Font                 = Enum.Font.Code,
                    BackgroundColor3     = C.white,
                    BackgroundTransparency = 0.88,
                    ZIndex               = 8,
                })
                Corner(badge, 3)

                local panel = Frame(gbox, {
                    Size             = UDim2.new(1,0,0,0),
                    AutomaticSize    = Enum.AutomaticSize.Y,
                    BackgroundColor3 = C.toastBg,
                    BackgroundTransparency = 0.05,
                    ZIndex           = 20,
                    Visible          = false,
                    ClipsDescendants = true,
                })
                Corner(panel, 7)
                Stroke(panel, C.white, 1, 0.88)
                ListLayout(panel)
                Padding(panel, 4, 4, 0, 0)

                for _, opt in ipairs(options or {}) do
                    local on  = sel[opt] == true
                    local ob  = Button(panel, {
                        Size                 = UDim2.new(1,0,0,24),
                        BackgroundColor3     = C.white,
                        BackgroundTransparency = 1,
                        Text                 = "",
                        ZIndex               = 21,
                    })
                    Padding(ob, 0, 0, 8, 8)

                    local optLbl = Label(ob, {
                        Position       = UDim2.new(0,0,0,0),
                        Size           = UDim2.new(1,0,1,0),
                        Text           = opt,
                        TextColor3     = on and C.hi or C.low,
                        TextSize       = 10,
                        Font           = on and Enum.Font.GothamMedium or Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex         = 22,
                    })

                    ob.MouseEnter:Connect(function() tw(ob, {BackgroundTransparency = 0.94}, 0.1) end)
                    ob.MouseLeave:Connect(function() tw(ob, {BackgroundTransparency = 1},    0.1) end)
                    ob.MouseButton1Click:Connect(function()
                        sel[opt] = not sel[opt]
                        local s = sel[opt]
                        tw(optLbl, {TextColor3 = s and C.hi or C.low}, 0.12)
                        optLbl.Font = s and Enum.Font.GothamMedium or Enum.Font.Gotham
                        btnLbl.Text = labelTxt()
                        badge.Text  = tostring(count())
                        if cb then cb(sel) end
                    end)
                end

                btn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        local relY = row.AbsolutePosition.Y - gbox.AbsolutePosition.Y + 28
                        panel.Position = UDim2.new(0,0,0,relY)
                    end
                    panel.Visible = open
                end)

                local o = {}
                function o:Get()
                    local out = {}
                    for k,v in pairs(sel) do if v then table.insert(out,k) end end
                    return out
                end
                function o:Set(tbl)
                    sel = {}; for _,v in ipairs(tbl) do sel[v] = true end
                    btnLbl.Text = labelTxt(); badge.Text = tostring(count())
                end
                return o
            end
            grp.MultiDropdown = function(self, lbl, options, defaults, cb)
                return grp.CreateMultiDropdown({Title=lbl, List=options, Defaults=defaults}, cb)
            end

            -- ── Button ───────────────────────────────────────────────────
            function grp.CreateButton(opts, cb)
                local lbl = opts.Title or ""
                local btn = Button(body, {
                    Size                 = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3     = C.white,
                    BackgroundTransparency = 0.92,
                    Text                 = lbl,
                    TextColor3           = C.hi,
                    TextSize             = 11,
                    Font                 = Enum.Font.GothamMedium,
                    ZIndex               = 7,
                    LayoutOrder          = #body:GetChildren(),
                })
                Corner(btn, 5)
                Stroke(btn, C.white, 1, 0.87)
                btn.MouseEnter:Connect(function() tw(btn, {BackgroundTransparency = 0.80}, 0.12) end)
                btn.MouseLeave:Connect(function() tw(btn, {BackgroundTransparency = 0.92}, 0.12) end)
                btn.MouseButton1Click:Connect(function()
                    tw(btn, {BackgroundTransparency = 0.65}, 0.06)
                    task.delay(0.12, function() tw(btn, {BackgroundTransparency = 0.92}, 0.1) end)
                    if cb then coroutine.wrap(cb)() end
                end)
            end
            grp.Button = function(self, lbl, cb)
                return grp.CreateButton({Title=lbl}, cb)
            end

            -- ── Label ────────────────────────────────────────────────────
            function grp.CreateLabel(opts)
                local text = type(opts) == "table" and (opts.Title or opts.Text or "") or tostring(opts)
                Label(body, {
                    Size           = UDim2.new(1,0,0,26),
                    Text           = text,
                    TextColor3     = C.hi,
                    TextSize       = 10,
                    Font           = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex         = 5,
                    LayoutOrder    = #body:GetChildren(),
                })
            end
            grp.Label = function(self, text) return grp.CreateLabel(text) end

            -- ── Paragraph ────────────────────────────────────────────────
            function grp:Paragraph(text)
                local lbl = Label(body, {
                    Size           = UDim2.new(1,0,0,0),
                    AutomaticSize  = Enum.AutomaticSize.Y,
                    Text           = text or "",
                    TextColor3     = C.hi,
                    TextSize       = 10,
                    Font           = Enum.Font.Gotham,
                    TextWrapped    = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LineHeight     = 1.5,
                    ZIndex         = 5,
                    LayoutOrder    = #body:GetChildren(),
                })
                Padding(lbl, 2, 4, 0, 0)
            end

            -- ── TextField ────────────────────────────────────────────────
            function grp.CreateTextfield(opts, cb)
                local lbl         = type(opts) == "table" and (opts.Title or "") or tostring(opts)
                local placeholder = (type(opts) == "table" and opts.Placeholder) or "Type..."
                local tfFrame = Frame(body, {
                    Size                 = UDim2.new(1,0,0,60),
                    BackgroundTransparency = 1,
                    ZIndex               = 5,
                    LayoutOrder          = #body:GetChildren(),
                })

                local bg1 = Frame(tfFrame, {
                    AnchorPoint          = Vector2.new(0.5,0.5),
                    Position             = UDim2.new(0.5,0,0.5,0),
                    Size                 = UDim2.new(1,-10,1,0),
                    BackgroundColor3     = C.element,
                    BackgroundTransparency = 0,
                    ZIndex               = 6,
                })
                Corner(bg1, 4)

                Label(bg1, {
                    Position       = UDim2.new(0,10,0,0),
                    Size           = UDim2.new(1,-10,0.5,0),
                    Text           = lbl or "",
                    TextColor3     = C.hi,
                    TextSize       = 11,
                    Font           = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex         = 7,
                })

                local bg2 = Frame(bg1, {
                    AnchorPoint          = Vector2.new(1,0),
                    Position             = UDim2.new(1,-5,0,33),
                    Size                 = UDim2.new(1,-10,0,22),
                    BackgroundColor3     = C.border,
                    BackgroundTransparency = 0,
                    ClipsDescendants     = true,
                    ZIndex               = 7,
                })
                Corner(bg2, 4)

                local highlight = Frame(bg2, {
                    Position             = UDim2.new(0,0,1,-2),
                    Size                 = UDim2.new(1,0,0,4),
                    BackgroundColor3     = C.accent,
                    BackgroundTransparency = 1,
                    ZIndex               = 9,
                })
                Corner(highlight, 2)

                local tb = Instance.new("TextBox")
                tb.Position              = UDim2.new(0,5,0,0)
                tb.Size                  = UDim2.new(1,-10,1,0)
                tb.BackgroundTransparency = 1
                tb.BorderSizePixel       = 0
                tb.Font                  = Enum.Font.Gotham
                tb.PlaceholderText       = placeholder or "Type..."
                tb.PlaceholderColor3     = C.dim
                tb.Text                  = ""
                tb.TextColor3            = C.hi
                tb.TextSize              = 10
                tb.ClearTextOnFocus      = false
                tb.TextXAlignment        = Enum.TextXAlignment.Left
                tb.ZIndex                = 8
                tb.Parent                = bg2

                tb.Focused:Connect(function()
                    tw(highlight, {BackgroundTransparency = 0}, 0.15)
                end)
                tb.FocusLost:Connect(function()
                    tw(highlight, {BackgroundTransparency = 1}, 0.15)
                    if cb then cb(tb.Text) end
                end)

                local o = {}
                function o:Get() return tb.Text end
                function o:Set(v) tb.Text = v end
                return o
            end
            grp.TextField = function(self, lbl, placeholder, cb)
                return grp.CreateTextfield({Title=lbl, Placeholder=placeholder}, cb)
            end

            -- ── ColorDot ─────────────────────────────────────────────────
            function grp:ColorDot(lbl, color, cb)
                local row = baseRow(lbl)
                color = color or Color3.fromRGB(80,140,255)

                local dot = Button(row, {
                    Position         = UDim2.new(1,-18,0.5,-8),
                    Size             = UDim2.new(0,16,0,16),
                    BackgroundColor3 = color,
                    Text             = "",
                    ZIndex           = 7,
                })
                Corner(dot, 8)
                Stroke(dot, C.white, 1, 0.85)
                dot.MouseButton1Click:Connect(function() if cb then cb(color) end end)

                local o = {}
                function o:Set(c) color = c; dot.BackgroundColor3 = c end
                function o:Get() return color end
                return o
            end

            -- ── Keybind ──────────────────────────────────────────────────
            function grp:Keybind(lbl, default, cb)
                local key     = default or Enum.KeyCode.Unknown
                local waiting = false
                local row     = baseRow(lbl)

                local kbf = Button(row, {
                    Position             = UDim2.new(1,-74,0.5,-10),
                    Size                 = UDim2.new(0,70,0,20),
                    BackgroundColor3     = C.white,
                    BackgroundTransparency = 0.94,
                    Text                 = "",
                    ZIndex               = 7,
                })
                Corner(kbf, 4)
                Stroke(kbf, C.white, 1, 0.88)

                local kbLbl = Label(kbf, {
                    Size           = UDim2.new(1,0,1,0),
                    Text           = tostring(key):gsub("Enum.KeyCode.",""),
                    TextColor3     = C.hi,
                    TextSize       = 9,
                    Font           = Enum.Font.Code,
                    ZIndex         = 8,
                })

                kbf.MouseButton1Click:Connect(function()
                    waiting = true
                    kbLbl.Text       = "..."
                    kbLbl.TextColor3 = C.hi
                end)

                UserInputService.InputBegan:Connect(function(i, gp)
                    if gp then return end
                    if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if waiting then
                        waiting          = false
                        key              = i.KeyCode
                        kbLbl.Text       = tostring(key):gsub("Enum.KeyCode.","")
                        kbLbl.TextColor3     = C.hi
                    elseif i.KeyCode == key then
                        if cb then cb(key) end
                    end
                end)

                local o = {}
                function o:Get() return key end
                function o:Set(k) key=k; kbLbl.Text=tostring(k):gsub("Enum.KeyCode.","") end
                return o
            end
            -- table API alias
            grp.CreateKeybind = function(opts, cb)
                local lbl     = opts.Title or ""
                local default = opts.Default or Enum.KeyCode.Unknown
                return grp:Keybind(lbl, default, cb)
            end

            -- ── SectionLabel (inside group) ───────────────────────────────
            function grp:SectionLabel(name)
                local secContainer = Frame(body, {
                    Size        = UDim2.new(1,0,0,28),
                    BackgroundTransparency = 1,
                    ZIndex      = 5,
                    LayoutOrder = #body:GetChildren(),
                })

                Label(secContainer, {
                    Size           = UDim2.new(1,0,0,18),
                    Position       = UDim2.new(0,0,0,4),
                    Text           = string.upper(name or ""),
                    TextColor3     = C.accent,
                    TextSize       = 9,
                    Font           = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex         = 6,
                })

                local line = Frame(secContainer, {
                    Position         = UDim2.new(0,0,1,-2),
                    Size             = UDim2.new(1,0,0,1),
                    BackgroundColor3 = C.accent,
                    BackgroundTransparency = 0,
                    ZIndex           = 6,
                })
                local grad = Instance.new("UIGradient")
                grad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,   1),
                    NumberSequenceKeypoint.new(0.2, 0),
                    NumberSequenceKeypoint.new(0.8, 0),
                    NumberSequenceKeypoint.new(1,   1),
                })
                grad.Parent = line
            end

            return grp
        end -- sec.CreateSection

        -- legacy alias: sec:Group → sec.CreateSection
        sec.Group = function(self, groupName, iconAsset)
            return sec.CreateSection(groupName, iconAsset)
        end

        return sec
    end -- window.CreatePage

    -- legacy alias: window:Section → window.CreatePage
    window.Section = function(self, name, iconAsset)
        return window.CreatePage({ Page_Name = name, Icon = iconAsset })
    end

    return window
end -- lib:init

return lib
