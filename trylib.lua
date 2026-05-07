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
    bg       = Color3.fromRGB(0,   0,   0),
    sidebar  = Color3.fromRGB(6,   6,   6),
    surface  = Color3.fromRGB(12,  12,  12),
    element  = Color3.fromRGB(20,  20,  20),
    white    = Color3.fromRGB(255,255,255),
    hi       = Color3.fromRGB(220,220,220),
    mid      = Color3.fromRGB(130,130,130),
    low      = Color3.fromRGB(75,  75,  75),
    dim      = Color3.fromRGB(40,  40,  40),
    onBg     = Color3.fromRGB(215,215,215),
    offBg    = Color3.fromRGB(32,  32,  32),
    knob     = Color3.fromRGB(15,  15,  15),
    toastBg  = Color3.fromRGB(10,  10,  10),
    success  = Color3.fromRGB(80, 220,120),
    warn     = Color3.fromRGB(255,190, 60),
    err      = Color3.fromRGB(255, 60,  60),
    info     = Color3.fromRGB(170,170,170),
}

-- ═══════════════════════════════════════════════════════════════════════════
function lib:init(title, subtitle, logoAsset, visibleKey, deletePrevious)

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
    scrgui.Parent         = hui

    -- ── main window  820 × 440 ─────────────────────────────────────────
    local main = Frame(scrgui, {
        Name                 = "main",
        AnchorPoint          = Vector2.new(0.5, 0.5),
        Position             = UDim2.new(0.5, 0, 2, 0),
        Size                 = UDim2.new(0, 820, 0, 440),
        BackgroundColor3     = C.bg,
        BackgroundTransparency = 0,
        ClipsDescendants     = true,
        ZIndex               = 1,
    })
    Corner(main, 14)
    Stroke(main, C.white, 1, 0.93)


    -- ── drag (move o outer que contém tudo) ───────────────────────────────────
    local drag, dragStart, startPos
    main.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if (i.Position.Y - main.AbsolutePosition.Y) > 38 then return end
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

    -- ── titlebar  (38px) ───────────────────────────────────────────────────
    local titlebar = Frame(main, {
        Name                 = "titlebar",
        Size                 = UDim2.new(1, 0, 0, 38),
        BackgroundColor3     = C.white,
        BackgroundTransparency = 0.98,
        ZIndex               = 4,
    })
    -- bottom border
    Frame(titlebar, {
        Position             = UDim2.new(0,0,1,-1),
        Size                 = UDim2.new(1,0,0,1),
        BackgroundColor3     = C.white,
        BackgroundTransparency = 0.95,
        ZIndex               = 4,
    })

    -- logo na titlebar
    local logoImg = Image(titlebar, {
        Position          = UDim2.new(0, 14, 0.5, -10),
        Size              = UDim2.new(0, 20, 0, 20),
        Image             = logoAsset or "",
        ImageColor3       = C.white,
        ImageTransparency = logoAsset and 0.1 or 1,
        ScaleType         = Enum.ScaleType.Fit,
        ZIndex            = 4,
    })

    local txOff = logoAsset and 42 or 14

    Label(titlebar, {
        Position       = UDim2.new(0, txOff, 0, 5),
        Size           = UDim2.new(0, 260, 0, 16),
        Text           = string.upper(title or "VANTA"),
        TextColor3     = C.hi,
        TextSize       = 11,
        Font           = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 4,
    })

    Label(titlebar, {
        Position       = UDim2.new(0, txOff, 0, 22),
        Size           = UDim2.new(0, 260, 0, 12),
        Text           = subtitle or "",
        TextColor3     = C.low,
        TextSize       = 9,
        Font           = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 4,
    })

    -- keybind hint
    Label(titlebar, {
        Name           = "kbHint",
        Position       = UDim2.new(1,-138,0.5,-7),
        Size           = UDim2.new(0,90,0,14),
        Text           = visibleKey and ("toggle  [" .. tostring(visibleKey):gsub("Enum.KeyCode.","") .. "]") or "",
        TextColor3     = C.dim,
        TextSize       = 9,
        Font           = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex         = 4,
    })

    Corner(titlebar, 14)
    -- hiders dos cantos inferiores do titlebar (nao devem ser arredondados)
    Frame(titlebar, {
        Position             = UDim2.new(0,0,1,-14),
        Size                 = UDim2.new(0,14,0,14),
        BackgroundColor3     = C.bg,
        BackgroundTransparency = 0,
        ZIndex               = 5,
    })
    Frame(titlebar, {
        Position             = UDim2.new(1,-14,1,-14),
        Size                 = UDim2.new(0,14,0,14),
        BackgroundColor3     = C.bg,
        BackgroundTransparency = 0,
        ZIndex               = 5,
    })
    -- (botões de fechar/minimizar removidos — use visibleKey para toggle)

    -- ── sidebar  (168px wide) ──────────────────────────────────────────────
    local sidebar = Frame(main, {
        Name                 = "sidebar",
        Position             = UDim2.new(0,0,0,38),
        Size                 = UDim2.new(0,168,1,-62),
        BackgroundColor3     = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0,
        ClipsDescendants     = true,
        ZIndex               = 3,
    })
    Corner(sidebar, 14)
    -- hider do canto superior esquerdo da sidebar
    Frame(sidebar, {
        Position             = UDim2.new(0,0,0,0),
        Size                 = UDim2.new(0,14,0,14),
        BackgroundColor3     = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0,
        ZIndex               = 4,
    })
    -- right border
    Frame(sidebar, {
        Position             = UDim2.new(1,-1,0,0),
        Size                 = UDim2.new(0,1,1,0),
        BackgroundColor3     = C.white,
        BackgroundTransparency = 0.95,
        ZIndex               = 3,
    })

    -- search bar
    local searchFrame = Frame(sidebar, {
        Position             = UDim2.new(0,8,0,8),
        Size                 = UDim2.new(1,-16,0,26),
        BackgroundColor3     = C.white,
        BackgroundTransparency = 0.96,
        ZIndex               = 4,
    })
    Corner(searchFrame, 6)
    Stroke(searchFrame, C.white, 1, 0.92)

    Image(searchFrame, {
        Position          = UDim2.new(0,6,0.5,-6),
        Size              = UDim2.new(0,12,0,12),
        Image             = "rbxassetid://3926305904",   -- magnifier icon
        ImageColor3       = C.low,
        ImageTransparency = 0.4,
        ScaleType         = Enum.ScaleType.Fit,
        ZIndex            = 5,
    })

    local searchBox = Instance.new("TextBox")
    searchBox.Position            = UDim2.new(0,22,0,0)
    searchBox.Size                = UDim2.new(1,-28,1,0)
    searchBox.BackgroundTransparency = 1
    searchBox.BorderSizePixel     = 0
    searchBox.Font                = Enum.Font.Gotham
    searchBox.PlaceholderText     = "Search..."
    searchBox.PlaceholderColor3   = C.dim
    searchBox.Text                = ""
    searchBox.TextColor3          = C.mid
    searchBox.TextSize            = 10
    searchBox.ClearTextOnFocus    = false
    searchBox.TextXAlignment      = Enum.TextXAlignment.Left
    searchBox.ZIndex              = 5
    searchBox.Parent              = searchFrame

    -- sidebar scroll
    local sidebarScroll = Instance.new("ScrollingFrame")
    sidebarScroll.Name                = "sidebarScroll"
    sidebarScroll.Position            = UDim2.new(0,0,0,42)
    sidebarScroll.Size                = UDim2.new(1,0,1,-42)
    sidebarScroll.BackgroundTransparency = 1
    sidebarScroll.BorderSizePixel     = 0
    sidebarScroll.ScrollBarThickness  = 2
    sidebarScroll.ScrollBarImageColor3 = C.dim
    sidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebarScroll.CanvasSize          = UDim2.new(0,0,0,0)
    sidebarScroll.ZIndex              = 3
    sidebarScroll.Parent              = sidebar
    ListLayout(sidebarScroll, {Padding = UDim.new(0,1)})

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
        BackgroundColor3     = C.white,
        BackgroundTransparency = 0.96,
        ZIndex               = 4,
    })
    local dot = Frame(statusbar, {
        Position             = UDim2.new(0,14,0.5,-3),
        Size                 = UDim2.new(0,6,0,6),
        BackgroundColor3     = C.success,
        BackgroundTransparency = 0.4,
        ZIndex               = 4,
    })
    Corner(dot, 3)
    Label(statusbar, {
        Position       = UDim2.new(0,24,0,0),
        Size           = UDim2.new(0,60,1,0),
        Text           = "ACTIVE",
        TextColor3     = C.dim,
        TextSize       = 9,
        Font           = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 4,
    })

    -- ── toast holder ──────────────────────────────────────────────────────
    local toastHolder = Frame(scrgui, {
        Name                 = "toastHolder",
        AnchorPoint          = Vector2.new(1,0),
        Position             = UDim2.new(1,-14,0,14),
        Size                 = UDim2.new(0,260,1,-28),
        BackgroundTransparency = 1,
        ZIndex               = 30,
    })
    ListLayout(toastHolder, {
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding             = UDim.new(0,6),
    })

    -- ── state ─────────────────────────────────────────────────────────────
    local sections  = {}
    local workareas = {}
    local visible   = true
    local dbc       = false
    local toastIdx  = 0

    -- animate in
    tw(main, {Position = UDim2.new(0.5,0,0.5,0)}, 0.55, Enum.EasingStyle.Quart)

    -- ═════════════════════════════════════════════════════════════════════
    local window = {}

    -- ── ToggleVisible ─────────────────────────────────────────────────────
    function window:ToggleVisible()
        if dbc then return end
        visible = not visible
        dbc = true
        if visible then
            tw(main, {Position = UDim2.new(0.5,0,0.5,0)}, 0.45)
        else
            tw(main, {Position = main.Position + UDim2.new(0,0,2,0)}, 0.45)
        end
        task.delay(0.5, function() dbc = false end)
    end

    -- toggle via keybind
    if visibleKey then
        UserInputService.InputBegan:Connect(function(i, gp)
            if not gp and i.KeyCode == visibleKey then window:ToggleVisible() end
        end)
    end

    -- ── TempNotify (toast) ────────────────────────────────────────────────
    function window:TempNotify(toastTitle, message, notifType, duration)
        duration  = duration  or 4
        notifType = notifType or "info"
        toastIdx  = toastIdx  + 1

        local accent = ({
            success = C.success,
            warn    = C.warn,
            error   = C.err,
            info    = C.info,
        })[notifType] or C.info

        local icon = ({
            success = "✓",
            warn    = "!",
            error   = "✕",
            info    = "i",
        })[notifType] or "i"

        local toast = Frame(toastHolder, {
            Name             = "toast" .. toastIdx,
            Size             = UDim2.new(1,0,0,62),
            BackgroundColor3 = Color3.fromRGB(14,14,14),
            BackgroundTransparency = 0,
            ClipsDescendants = true,
            ZIndex           = 30,
            LayoutOrder      = toastIdx,
        })
        Corner(toast, 10)
        Stroke(toast, C.white, 1, 0.92)

        -- accent strip on left
        local strip = Frame(toast, {
            Size             = UDim2.new(0,3,1,0),
            BackgroundColor3 = accent,
            BackgroundTransparency = 0,
            ZIndex           = 31,
        })
        Corner(strip, 2)

        -- icon circle
        local iconCircle = Frame(toast, {
            Position         = UDim2.new(0,14,0.5,-12),
            Size             = UDim2.new(0,24,0,24),
            BackgroundColor3 = accent,
            BackgroundTransparency = 0.82,
            ZIndex           = 31,
        })
        Corner(iconCircle, 12)
        Label(iconCircle, {
            Size           = UDim2.new(1,0,1,0),
            Text           = icon,
            TextColor3     = accent,
            TextSize       = 12,
            Font           = Enum.Font.GothamBold,
            ZIndex         = 32,
        })

        -- title
        Label(toast, {
            Position       = UDim2.new(0,46,0,12),
            Size           = UDim2.new(1,-60,0,16),
            Text           = toastTitle or "",
            TextColor3     = C.hi,
            TextSize       = 12,
            Font           = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex         = 31,
        })

        -- message
        Label(toast, {
            Position       = UDim2.new(0,46,0,30),
            Size           = UDim2.new(1,-60,0,20),
            Text           = message or "",
            TextColor3     = C.low,
            TextSize       = 10,
            Font           = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped    = true,
            ZIndex         = 31,
        })

        -- progress bar na base
        local prog = Frame(toast, {
            Position         = UDim2.new(0,3,1,-2),
            Size             = UDim2.new(1,-3,0,2),
            BackgroundColor3 = accent,
            BackgroundTransparency = 0.6,
            ZIndex           = 32,
        })
        tw(prog, {Size = UDim2.new(0,0,0,2)}, duration, Enum.EasingStyle.Linear)

        -- botão fechar
        local closeBtn = Button(toast, {
            Position             = UDim2.new(1,-20,0,8),
            Size                 = UDim2.new(0,14,0,14),
            BackgroundTransparency = 1,
            Text                 = "✕",
            TextColor3           = C.dim,
            TextSize             = 9,
            Font                 = Enum.Font.Gotham,
            ZIndex               = 32,
        })

        toast.Position = UDim2.new(1,16,0,0)
        tw(toast, {Position = UDim2.new(0,0,0,0)}, 0.28, Enum.EasingStyle.Back)

        local dismissed = false
        local function dismiss()
            if dismissed then return end
            dismissed = true
            tw(toast, {Position = UDim2.new(1,16,0,0)}, 0.2)
            Debris:AddItem(toast, 0.3)
        end

        closeBtn.MouseButton1Click:Connect(dismiss)
        task.delay(duration, dismiss)
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
            TextColor3     = C.low,
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
            TextColor3     = C.low,
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
            TextColor3           = C.mid,
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
            TextColor3     = C.dim,
            TextSize       = 8,
            Font           = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex         = 3,
            LayoutOrder    = #sidebarScroll:GetChildren() + 1,
        })
        Padding(lbl, 0, 0, 14, 0)
    end

    -- ═════════════════════════════════════════════════════════════════════
    --  window:Section(name, iconAsset)
    -- ═════════════════════════════════════════════════════════════════════
    function window:Section(name, iconAsset)

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

        local activeBar = Frame(tabBtn, {
            Position             = UDim2.new(0,0,0.5,-9),
            Size                 = UDim2.new(0,2,0,18),
            BackgroundColor3     = C.white,
            BackgroundTransparency = 1,
            ZIndex               = 4,
        })
        Corner(activeBar, 2)

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
        workarea.Position            = UDim2.new(0,168,0,38)
        workarea.Size                = UDim2.new(1,-168,1,-62)
        workarea.BackgroundTransparency = 1
        workarea.BorderSizePixel     = 0
        workarea.ScrollBarThickness  = 3
        workarea.ScrollBarImageColor3 = Color3.fromRGB(45,45,45)
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

        function sec:Select()
            for _, t in ipairs(sections) do
                t.BackgroundTransparency = 1
                local l = t:FindFirstChildWhichIsA("TextLabel")
                if l then tw(l, {TextColor3 = C.low}, 0.12); l.Font = Enum.Font.Gotham end
                local ic = t:FindFirstChildWhichIsA("ImageLabel")
                if ic then tw(ic, {ImageColor3 = C.low, ImageTransparency = 0.5}, 0.12) end
                for _, ch in ipairs(t:GetChildren()) do
                    if ch:IsA("Frame") then tw(ch, {BackgroundTransparency = 1}, 0.12) end
                end
            end
            tw(tabBtn,  {BackgroundTransparency = 0.94}, 0.12)
            tw(tabLabel,{TextColor3 = C.hi},             0.12)
            tabLabel.Font = Enum.Font.GothamMedium
            if iconAsset then tw(tabIcon, {ImageColor3 = C.hi, ImageTransparency = 0}, 0.12) end
            tw(activeBar, {BackgroundTransparency = 0.4}, 0.12)
            for _, w in ipairs(workareas) do w.Visible = false end
            workarea.Visible = true
        end

        tabBtn.MouseButton1Click:Connect(function() sec:Select() end)
        tabBtn.MouseEnter:Connect(function()
            if workarea.Visible then return end
            tw(tabBtn,  {BackgroundTransparency = 0.96}, 0.1)
            tw(tabLabel,{TextColor3 = C.mid},            0.1)
            if iconAsset then tw(tabIcon, {ImageColor3 = C.mid, ImageTransparency = 0.3}, 0.1) end
        end)
        tabBtn.MouseLeave:Connect(function()
            if workarea.Visible then return end
            tw(tabBtn,  {BackgroundTransparency = 1},  0.1)
            tw(tabLabel,{TextColor3 = C.low},           0.1)
            if iconAsset then tw(tabIcon, {ImageColor3 = C.low, ImageTransparency = 0.5}, 0.1) end
        end)

        if #sections == 1 then sec:Select() end

        -- search filter
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = string.upper(searchBox.Text)
            for _, t in ipairs(sections) do
                local l = t:FindFirstChildWhichIsA("TextLabel")
                local n = l and string.upper(l.Text) or ""
                t.Visible = (q == "" or string.find(n, q, 1, true) ~= nil)
            end
        end)

        -- ══════════════════════════════════════════════════════════════════
        --  sec:Group(groupName, iconAsset)
        -- ══════════════════════════════════════════════════════════════════
        function sec:Group(groupName, iconAsset)

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
            Stroke(gboxOuter, C.white, 1, 0.91)

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
                TextColor3     = C.mid,
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
            local function baseRow(lbl, h)
                h = h or 30
                local row = Frame(body, {
                    Size             = UDim2.new(1,0,0,h),
                    BackgroundTransparency = 1,
                    ZIndex           = 5,
                    LayoutOrder      = #body:GetChildren(),
                })
                Frame(row, {
                    Position         = UDim2.new(0,0,1,-1),
                    Size             = UDim2.new(1,0,0,1),
                    BackgroundColor3 = C.white,
                    BackgroundTransparency = 0.97,
                    ZIndex           = 5,
                })
                Label(row, {
                    Position       = UDim2.new(0,0,0,0),
                    Size           = UDim2.new(0.55,0,1,0),
                    Text           = lbl or "",
                    TextColor3     = C.mid,
                    TextSize       = 11,
                    Font           = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex         = 6,
                })
                return row
            end

            local grp = {}

            -- ── Toggle ───────────────────────────────────────────────────
            function grp:Toggle(lbl, default, cb)
                local state = default == true
                local row = baseRow(lbl)

                local track = Button(row, {
                    Position             = UDim2.new(1,-34,0.5,-9),
                    Size                 = UDim2.new(0,34,0,18),
                    BackgroundColor3     = state and C.onBg or C.offBg,
                    Text                 = "",
                    ZIndex               = 7,
                })
                Corner(track, 9)
                local tstr = Stroke(track, C.white, 1, state and 0.1 or 0.88)

                local knob = Frame(track, {
                    Position         = state and UDim2.new(0,16,0,2) or UDim2.new(0,2,0,2),
                    Size             = UDim2.new(0,12,0,12),
                    BackgroundColor3 = state and C.knob or C.dim,
                    ZIndex           = 8,
                })
                Corner(knob, 6)

                local function flip()
                    state = not state
                    tw(track, {BackgroundColor3 = state and C.onBg or C.offBg}, 0.18)
                    tw(knob,  {Position = state and UDim2.new(0,16,0,2) or UDim2.new(0,2,0,2),
                               BackgroundColor3 = state and C.knob or C.dim}, 0.18)
                    if cb then cb(state) end
                end
                track.MouseButton1Click:Connect(flip)

                local o = {}
                function o:Set(v) if state ~= v then flip() end end
                function o:Get() return state end
                return o
            end

            -- ── Slider ───────────────────────────────────────────────────
            function grp:Slider(lbl, min, max, default, cb)
                min = min or 0; max = max or 100; default = default or min
                local val = default
                local row = baseRow(lbl, 34)

                -- valor fica à esquerda do track, sem sobreposição
                local valLbl = Label(row, {
                    Position       = UDim2.new(1,-100,0.5,-7),
                    Size           = UDim2.new(0,20,0,14),
                    Text           = tostring(val),
                    TextColor3     = C.dim,
                    TextSize       = 9,
                    Font           = Enum.Font.Code,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex         = 6,
                })

                local trackBg = Frame(row, {
                    Position         = UDim2.new(1,-74,0.5,-1),
                    Size             = UDim2.new(0,70,0,2),
                    BackgroundColor3 = C.white,
                    BackgroundTransparency = 0.9,
                    ZIndex           = 6,
                })
                Corner(trackBg, 1)

                local p0 = (val-min)/(max-min)
                local fill = Frame(trackBg, {
                    Size             = UDim2.new(p0,0,1,0),
                    BackgroundColor3 = C.white,
                    BackgroundTransparency = 0.2,
                    ZIndex           = 7,
                })
                Corner(fill, 1)

                local thumb = Frame(trackBg, {
                    AnchorPoint      = Vector2.new(0.5,0.5),
                    Position         = UDim2.new(p0,0,0.5,0),
                    Size             = UDim2.new(0,10,0,10),
                    BackgroundColor3 = C.white,
                    BackgroundTransparency = 0.2,
                    ZIndex           = 8,
                })
                Corner(thumb, 5)
                Stroke(thumb, C.white, 1, 0.05)

                local dslider = false
                local function upd(x)
                    local rel = math.clamp((x - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + rel*(max-min) + 0.5)
                    local p = (val-min)/(max-min)
                    tw(fill,  {Size     = UDim2.new(p,0,1,0)},   0.06)
                    tw(thumb, {Position = UDim2.new(p,0,0.5,0)}, 0.06)
                    valLbl.Text = tostring(val)
                    if cb then cb(val) end
                end
                trackBg.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dslider = true; upd(i.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dslider and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i.Position.X) end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dslider = false end
                end)

                local o = {}
                function o:Set(v)
                    val = math.clamp(v,min,max)
                    local p = (val-min)/(max-min)
                    fill.Size = UDim2.new(p,0,1,0)
                    thumb.Position = UDim2.new(p,0,0.5,0)
                    valLbl.Text = tostring(val)
                    if cb then cb(val) end
                end
                function o:Get() return val end
                return o
            end

            -- ── Dropdown ─────────────────────────────────────────────────
            function grp:Dropdown(lbl, options, default, cb)
                local sel  = default or (options and options[1]) or ""
                local open = false
                local row  = baseRow(lbl)

                local btn = Button(row, {
                    Position             = UDim2.new(1,-90,0.5,-10),
                    Size                 = UDim2.new(0,86,0,20),
                    BackgroundColor3     = C.white,
                    BackgroundTransparency = 0.96,
                    Text                 = "",
                    ZIndex               = 7,
                })
                Corner(btn, 5)
                Stroke(btn, C.white, 1, 0.9)

                local btnLbl = Label(btn, {
                    Position       = UDim2.new(0,7,0,0),
                    Size           = UDim2.new(1,-18,1,0),
                    Text           = sel,
                    TextColor3     = C.mid,
                    TextSize       = 10,
                    Font           = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex         = 8,
                })
                Label(btn, {
                    Position       = UDim2.new(1,-13,0.5,-5),
                    Size           = UDim2.new(0,10,0,10),
                    Text           = "▾",
                    TextColor3     = C.dim,
                    TextSize       = 10,
                    ZIndex         = 8,
                })

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
                        sel = opt; btnLbl.Text = opt
                        panel.Visible = false; open = false
                        if cb then cb(opt) end
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
                function o:Set(v) sel = v; btnLbl.Text = v; if cb then cb(v) end end
                function o:Get() return sel end
                return o
            end

            -- ── MultiDropdown ─────────────────────────────────────────────
            function grp:MultiDropdown(lbl, options, defaults, cb)
                local sel  = {}
                for _, v in ipairs(defaults or {}) do sel[v] = true end
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
                    Position             = UDim2.new(1,-90,0.5,-10),
                    Size                 = UDim2.new(0,86,0,20),
                    BackgroundColor3     = C.white,
                    BackgroundTransparency = 0.96,
                    Text                 = "",
                    ZIndex               = 7,
                })
                Corner(btn, 5)
                Stroke(btn, C.white, 1, 0.9)

                local btnLbl = Label(btn, {
                    Position       = UDim2.new(0,7,0,0),
                    Size           = UDim2.new(1,-28,1,0),
                    Text           = labelTxt(),
                    TextColor3     = C.mid,
                    TextSize       = 10,
                    Font           = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex         = 8,
                })

                local badge = Label(btn, {
                    Position             = UDim2.new(1,-22,0.5,-7),
                    Size                 = UDim2.new(0,14,0,14),
                    Text                 = tostring(count()),
                    TextColor3           = C.mid,
                    TextSize             = 9,
                    Font                 = Enum.Font.Code,
                    BackgroundColor3     = C.white,
                    BackgroundTransparency = 0.88,
                    ZIndex               = 8,
                })
                Corner(badge, 3)

                Label(btn, {
                    Position       = UDim2.new(1,-10,0.5,-5),
                    Size           = UDim2.new(0,8,0,10),
                    Text           = "▾",
                    TextColor3     = C.dim,
                    TextSize       = 10,
                    ZIndex         = 8,
                })

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

                    local chk = Frame(ob, {
                        Position         = UDim2.new(0,0,0.5,-6),
                        Size             = UDim2.new(0,12,0,12),
                        BackgroundColor3 = on and C.white or C.element,
                        BackgroundTransparency = on and 0.2 or 0,
                        ZIndex           = 22,
                    })
                    Corner(chk, 3)
                    Stroke(chk, C.white, 1, on and 0.1 or 0.85)

                    local optLbl = Label(ob, {
                        Position       = UDim2.new(0,18,0,0),
                        Size           = UDim2.new(1,-18,1,0),
                        Text           = opt,
                        TextColor3     = on and C.hi or C.low,
                        TextSize       = 10,
                        Font           = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex         = 22,
                    })

                    ob.MouseEnter:Connect(function() tw(ob, {BackgroundTransparency = 0.94}, 0.1) end)
                    ob.MouseLeave:Connect(function() tw(ob, {BackgroundTransparency = 1},    0.1) end)
                    ob.MouseButton1Click:Connect(function()
                        sel[opt] = not sel[opt]
                        local s = sel[opt]
                        tw(chk,    {BackgroundColor3 = s and C.white or C.element,
                                    BackgroundTransparency = s and 0.2 or 0}, 0.12)
                        tw(optLbl, {TextColor3 = s and C.hi or C.low}, 0.12)
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

            -- ── Button ───────────────────────────────────────────────────
            function grp:Button(lbl, cb)
                local row = baseRow(lbl)
                local btn = Button(row, {
                    Position             = UDim2.new(1,-62,0.5,-10),
                    Size                 = UDim2.new(0,58,0,20),
                    BackgroundColor3     = C.white,
                    BackgroundTransparency = 0.92,
                    Text                 = lbl,
                    TextColor3           = C.mid,
                    TextSize             = 10,
                    Font                 = Enum.Font.Gotham,
                    ZIndex               = 7,
                })
                Corner(btn, 5)
                Stroke(btn, C.white, 1, 0.87)
                btn.MouseEnter:Connect(function() tw(btn, {BackgroundTransparency = 0.80, TextColor3 = C.hi}, 0.12) end)
                btn.MouseLeave:Connect(function() tw(btn, {BackgroundTransparency = 0.92, TextColor3 = C.mid}, 0.12) end)
                btn.MouseButton1Click:Connect(function()
                    tw(btn, {BackgroundTransparency = 0.65}, 0.06)
                    task.delay(0.12, function() tw(btn, {BackgroundTransparency = 0.92}, 0.1) end)
                    if cb then coroutine.wrap(cb)() end
                end)
            end

            -- ── Label ────────────────────────────────────────────────────
            function grp:Label(text)
                Label(body, {
                    Size           = UDim2.new(1,0,0,26),
                    Text           = text or "",
                    TextColor3     = C.low,
                    TextSize       = 10,
                    Font           = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex         = 5,
                    LayoutOrder    = #body:GetChildren(),
                })
            end

            -- ── Paragraph ────────────────────────────────────────────────
            function grp:Paragraph(text)
                local lbl = Label(body, {
                    Size           = UDim2.new(1,0,0,0),
                    AutomaticSize  = Enum.AutomaticSize.Y,
                    Text           = text or "",
                    TextColor3     = C.dim,
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
            function grp:TextField(lbl, placeholder, cb)
                local row = baseRow(lbl, 34)

                local inputFrame = Frame(row, {
                    Position             = UDim2.new(1,-108,0.5,-11),
                    Size                 = UDim2.new(0,104,0,22),
                    BackgroundColor3     = C.white,
                    BackgroundTransparency = 0.96,
                    ZIndex               = 7,
                })
                Corner(inputFrame, 5)
                local istr = Stroke(inputFrame, C.white, 1, 0.9)

                local tb = Instance.new("TextBox")
                tb.Position              = UDim2.new(0,6,0,0)
                tb.Size                  = UDim2.new(1,-12,1,0)
                tb.BackgroundTransparency = 1
                tb.BorderSizePixel       = 0
                tb.Font                  = Enum.Font.Gotham
                tb.PlaceholderText       = placeholder or "Type..."
                tb.PlaceholderColor3     = C.dim
                tb.Text                  = ""
                tb.TextColor3            = C.mid
                tb.TextSize              = 10
                tb.ClearTextOnFocus      = false
                tb.TextXAlignment        = Enum.TextXAlignment.Left
                tb.ZIndex                = 8
                tb.Parent                = inputFrame

                tb.Focused:Connect(function()   istr.Transparency = 0.78 end)
                tb.FocusLost:Connect(function()
                    istr.Transparency = 0.9
                    if cb then cb(tb.Text) end
                end)

                local o = {}
                function o:Get() return tb.Text end
                function o:Set(v) tb.Text = v end
                return o
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
                    TextColor3     = C.mid,
                    TextSize       = 9,
                    Font           = Enum.Font.Code,
                    ZIndex         = 8,
                })

                -- clique no badge: entra em modo de captura
                kbf.MouseButton1Click:Connect(function()
                    waiting = true
                    kbLbl.Text       = "..."
                    kbLbl.TextColor3 = C.hi
                end)

                -- escuta global: captura nova tecla OU dispara o callback
                UserInputService.InputBegan:Connect(function(i, gp)
                    if gp then return end
                    if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
                    if waiting then
                        -- modo captura: salva nova tecla
                        waiting          = false
                        key              = i.KeyCode
                        kbLbl.Text       = tostring(key):gsub("Enum.KeyCode.","")
                        kbLbl.TextColor3 = C.mid
                    elseif i.KeyCode == key then
                        -- tecla correta pressionada: dispara callback
                        if cb then cb(key) end
                    end
                end)

                local o = {}
                function o:Get() return key end
                function o:Set(k) key=k; kbLbl.Text=tostring(k):gsub("Enum.KeyCode.","") end
                return o
            end

            -- ── SectionLabel (inside group) ───────────────────────────────
            function grp:SectionLabel(name)
                Label(body, {
                    Size           = UDim2.new(1,0,0,20),
                    Text           = string.upper(name or ""),
                    TextColor3     = C.dim,
                    TextSize       = 8,
                    Font           = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex         = 5,
                    LayoutOrder    = #body:GetChildren(),
                })
            end

            return grp
        end -- sec:Group

        return sec
    end -- window:Section

    return window
end -- lib:init

return lib
