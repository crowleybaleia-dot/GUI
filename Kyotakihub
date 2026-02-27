--[[
    BarbiUI v3.2 — Violet Edition
    Redesign: accent roxo/violeta, topbar limpa, tipografia refinada
]]

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ══════════════════════════════════════════════════════════════════
-- TEMA
-- ══════════════════════════════════════════════════════════════════
local T = {
    -- Base: preto profundo
    GlassWin    = Color3.fromRGB( 8,  6, 14),
    GlassSide   = Color3.fromRGB( 6,  5, 11),
    GlassCard   = Color3.fromRGB(14, 11, 22),
    GlassElem   = Color3.fromRGB(22, 18, 34),
    GlassInput  = Color3.fromRGB(10,  8, 18),
    TWin        = 0.55,
    TSide       = 0.45,
    TCard       = 0.55,
    TElem       = 0.58,
    TInput      = 0.60,

    -- Accent: roxo/violeta
    Pink        = Color3.fromRGB(162,  89, 255),   -- accent principal
    PinkLight   = Color3.fromRGB(196, 148, 255),   -- accent claro (valores ativos)
    PinkDark    = Color3.fromRGB( 98,  46, 180),   -- accent escuro (badge, fill)
    PinkMute    = Color3.fromRGB(120,  65, 200),   -- accent intermediário

    -- Texto
    TxtPri      = Color3.fromRGB(240, 236, 255),
    TxtSec      = Color3.fromRGB(130, 115, 160),
    TxtMute     = Color3.fromRGB( 65,  55,  90),
    TxtAcct     = Color3.fromRGB(196, 148, 255),

    -- Status
    Success     = Color3.fromRGB( 52, 211, 153),
    Warning     = Color3.fromRGB(251, 191,  36),
    Error       = Color3.fromRGB(248, 113, 113),
    Info        = Color3.fromRGB(129, 140, 248),

    -- Bordas: violeta sutil
    BrdWin      = Color3.fromRGB(162,  89, 255),
    BrdCard     = Color3.fromRGB(120,  65, 200),
    BrdElem     = Color3.fromRGB( 90,  48, 160),
    BrdTWin     = 0.72,   -- mais sutil que antes
    BrdTCard    = 0.78,
    BrdTElem    = 0.72,

    -- Tipografia refinada
    FntBold     = Enum.Font.GothamBold,
    FntBody     = Enum.Font.Gotham,
    FntSemi     = Enum.Font.GothamSemibold,  -- novo: títulos de seção
    FntMono     = Enum.Font.Code,
}

-- ══════════════════════════════════════════════════════════════════
-- UTILITÁRIOS (idênticos — nenhuma mudança de lógica)
-- ══════════════════════════════════════════════════════════════════
local U = {}

function U.Tw(obj, props, t, sty, dir)
    if not obj or not obj.Parent then return end
    pcall(function()
        TweenService:Create(
            obj,
            TweenInfo.new(t or 0.25, sty or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
            props
        ):Play()
    end)
end

function U.New(cls, props)
    local ok, obj = pcall(Instance.new, cls)
    if not ok then return nil end
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then pcall(function() obj[k] = v end) end
    end
    if props and props.Parent then pcall(function() obj.Parent = props.Parent end) end
    return obj
end

function U.Corner(p, r)
    return U.New("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p })
end

function U.Stroke(p, col, th, tr)
    return U.New("UIStroke", { Color = col, Thickness = th or 1, Transparency = tr or 0, Parent = p })
end

function U.Pad(p, t, r, b, l)
    return U.New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 8),
        PaddingRight  = UDim.new(0, r or 8),
        PaddingBottom = UDim.new(0, b or 8),
        PaddingLeft   = UDim.new(0, l or 8),
        Parent        = p,
    })
end

function U.Ripple(btn, x, y)
    if not btn or not btn.AbsolutePosition then return end
    local lx = x - btn.AbsolutePosition.X - 8
    local ly = y - btn.AbsolutePosition.Y - 8
    local r = U.New("Frame", {
        BackgroundColor3       = Color3.new(1,1,1),
        BackgroundTransparency = 0.82,
        Position               = UDim2.new(0, lx, 0, ly),
        Size                   = UDim2.new(0, 16, 0, 16),
        ZIndex                 = (btn.ZIndex or 1) + 5,
        ClipsDescendants       = true,
        Parent                 = btn,
    })
    if r then
        U.Corner(r, 999)
        local s = btn.AbsoluteSize.X * 2.5
        U.Tw(r, { Size=UDim2.new(0,s,0,s), Position=UDim2.new(0.5,-s/2,0.5,-s/2), BackgroundTransparency=1 }, 0.5)
        task.delay(0.55, function() if r and r.Parent then r:Destroy() end end)
    end
end

function U.GetTime()
    local ok, t = pcall(os.time)
    if not ok then return "00:00:00" end
    local ok2, s = pcall(os.date, "%H:%M:%S", t)
    return ok2 and s or "00:00:00"
end

-- ══════════════════════════════════════════════════════════════════
-- NOTIFICAÇÕES
-- ══════════════════════════════════════════════════════════════════
local Notifs = { holder=nil, sg=nil, count=0 }

function Notifs:Init()
    if self.sg and self.sg.Parent then return end
    self.sg = U.New("ScreenGui", {
        Name="BarbiUI_Notifs", ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Global, IgnoreGuiInset=true,
        Parent=CoreGui,
    })
    self.holder = U.New("Frame", {
        BackgroundTransparency=1,
        Size=UDim2.new(0,310,1,0), Position=UDim2.new(1,-325,0,0),
        Parent=self.sg,
    })
    U.New("UIListLayout", { SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Bottom, Padding=UDim.new(0,6), Parent=self.holder })
    U.Pad(self.holder, 12, 0, 12, 0)
end

function Notifs:Send(cfg)
    self:Init()
    cfg = cfg or {}
    local title = cfg.Title or "Notify"
    local msg   = cfg.Message or ""
    local ntype = cfg.Type or "info"
    local dur   = cfg.Duration or 4
    local cols  = {info=T.Info, success=T.Success, warning=T.Warning, error=T.Error}
    local icons = {info="i", success="+", warning="!", error="×"}
    local col   = cols[ntype] or T.Info
    local icn   = icons[ntype] or "i"
    self.count  = self.count + 1

    local card = U.New("Frame", {
        BackgroundColor3=T.GlassCard, BackgroundTransparency=0.18,
        Size=UDim2.new(1,0,0,70), LayoutOrder=self.count,
        ClipsDescendants=true, Parent=self.holder,
    })
    U.Corner(card, 10)
    U.Stroke(card, col, 1, 0.55)
    U.New("Frame", {BackgroundColor3=col, Size=UDim2.new(0,2,1,0), Parent=card})
    local ib = U.New("Frame", {BackgroundColor3=col, BackgroundTransparency=0.75, Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,12,0.5,-13), Parent=card})
    U.Corner(ib, 999)
    U.New("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text=icn, TextColor3=col, Font=T.FntBold, TextSize=12, Parent=ib})
    U.New("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,48,0,8), Size=UDim2.new(1,-64,0,16), Text=title, TextColor3=T.TxtPri, Font=T.FntSemi, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, Parent=card})
    U.New("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,48,0,26), Size=UDim2.new(1,-64,0,30), Text=msg, TextColor3=T.TxtSec, Font=T.FntBody, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, Parent=card})
    local pgBg = U.New("Frame", {BackgroundColor3=T.GlassElem, BackgroundTransparency=0.3, Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2), Parent=card})
    local pgFill = U.New("Frame", {BackgroundColor3=col, Size=UDim2.new(1,0,1,0), Parent=pgBg})
    local closeBt = U.New("TextButton", {BackgroundTransparency=1, Position=UDim2.new(1,-20,0,5), Size=UDim2.new(0,14,0,14), Text="×", TextColor3=T.TxtMute, Font=T.FntBold, TextSize=13, ZIndex=5, Parent=card})

    card.Position = UDim2.new(1,15,0,0)
    card.BackgroundTransparency = 0.6
    U.Tw(card, {Position=UDim2.new(0,0,0,0), BackgroundTransparency=0.18}, 0.35, Enum.EasingStyle.Back)
    U.Tw(pgFill, {Size=UDim2.new(0,0,1,0)}, dur, Enum.EasingStyle.Linear)

    local gone = false
    local function Dismiss()
        if gone then return end; gone=true
        U.Tw(card, {Position=UDim2.new(1,15,0,0), BackgroundTransparency=1}, 0.25)
        task.delay(0.3, function() if card and card.Parent then card:Destroy() end end)
    end
    task.delay(dur, Dismiss)
    closeBt.MouseButton1Click:Connect(Dismiss)
end

-- ══════════════════════════════════════════════════════════════════
-- MÓDULO PRINCIPAL
-- ══════════════════════════════════════════════════════════════════
local BarbiUI   = {}
BarbiUI.__index = BarbiUI

function BarbiUI:Notify(cfg) Notifs:Send(cfg) end

-- ══════════════════════════════════════════════════════════════════
-- CRIAR JANELA
-- ══════════════════════════════════════════════════════════════════
function BarbiUI:CreateWindow(cfg)
    cfg    = cfg or {}
    local title  = cfg.Title  or "BarbiUI"
    local key    = cfg.Key    or Enum.KeyCode.RightShift
    local winW   = cfg.Width  or 920
    local winH   = cfg.Height or 560
    local bgImg  = cfg.Background or ""   -- << COLOQUE AQUI O ASSET ID DA SUA FOTO
    local titleH = 44
    local sideW  = 168

    local sg = U.New("ScreenGui", {
        Name="BarbiUI_"..title, ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Global,
        IgnoreGuiInset=true, Parent=CoreGui,
    })

    local blur = nil
    pcall(function()
        blur = Instance.new("BlurEffect")
        blur.Size = 0
        blur.Parent = game:GetService("Lighting")
    end)
    local function TwBlur(sz, t)
        if blur then pcall(function() U.Tw(blur, {Size=sz}, t or 0.3) end) end
    end

    -- ──────────────────────────────────────────────────────────────
    -- JANELA
    -- ──────────────────────────────────────────────────────────────
    local win = U.New("Frame", {
        Name                   = "Window",
        BackgroundColor3       = T.GlassWin,
        BackgroundTransparency = T.TWin,
        Size                   = UDim2.new(0, winW, 0, 0),
        Position               = UDim2.new(0.5, -winW/2, 0.5, -winH/2),
        ClipsDescendants       = false,
        Parent                 = sg,
    })
    U.Corner(win, 12)
    -- clipFrame: contém todos os elementos UI e garante cantos redondos perfeitos
    local clipFrame = U.New("Frame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        ClipsDescendants       = true,
        ZIndex                 = 2,
        Parent                 = win,
    })
    U.Corner(clipFrame, 12)

    -- Gradiente de fundo da janela
    if bgImg == "" then
        U.New("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(18, 12, 30)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,  7, 18)),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB( 5,  4, 10)),
            }),
            Rotation = 135, Parent = win,
        })
    end

    -- ── FOTO DE FUNDO ──
    -- Substitua bgImg pelo asset ID da sua imagem (ex: "rbxassetid://SEUID")
    if bgImg ~= "" then
        local bgFrame = U.New("ImageLabel", {
            BackgroundTransparency = 1,
            Image                  = bgImg,
            ImageTransparency      = 0.15,   -- ajuste de 0 (opaco) a 1 (invisível)
            ScaleType              = Enum.ScaleType.Crop,
            Size                   = UDim2.new(1, 0, 1, 0),
            ZIndex                 = 0,
            Parent                 = win,
        })
        -- Overlay escuro sobre a foto para manter legibilidade
        U.New("Frame", {
            BackgroundColor3       = Color3.fromRGB(5, 3, 10),
            BackgroundTransparency = 0.55,
            Size                   = UDim2.new(1, 0, 1, 0),
            ZIndex                 = 1,
            Parent                 = win,
        })
    end

    -- Sombra externa
    U.New("ImageLabel", {
        BackgroundTransparency=1,
        Image="rbxassetid://6014261993",
        ImageColor3=Color3.new(0,0,0), ImageTransparency=0.5,
        ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(49,49,450,450),
        Size=UDim2.new(1,60,1,60), Position=UDim2.new(0,-30,0,-30),
        ZIndex=-1, Parent=win,
    })

    -- ──────────────────────────────────────────────────────────────
    -- TOPBAR — redesign: limpa, status centralizado, controles discretos
    -- ──────────────────────────────────────────────────────────────
    local tb = U.New("Frame", {
        BackgroundColor3       = T.GlassSide,
        BackgroundTransparency = 0.08,
        Size                   = UDim2.new(1, 0, 0, titleH),
        ZIndex                 = 10,
        ClipsDescendants       = false,
        Parent                 = clipFrame,
    })
    -- sem UICorner no tb: win já faz o clip com ClipsDescendants
    -- Linha separadora fina na base do topbar
    U.New("Frame", {
        BackgroundColor3       = T.Pink,
        BackgroundTransparency = 0.82,
        Size                   = UDim2.new(1, 0, 0, 1),
        Position               = UDim2.new(0, 0, 1, -1),
        ZIndex                 = 11,
        Parent                 = tb,
    })

    -- ── LOGO (esquerda) ──
    -- Se cfg.Logo tiver um asset ID, exibe a imagem. Caso contrário, fallback para o "B".
    local logoImg = cfg.Logo or ""
    local logoF = U.New("Frame", {
        BackgroundColor3=T.Pink, BackgroundTransparency=logoImg~="" and 1 or 0.80,
        Size=UDim2.new(0,24,0,24), Position=UDim2.new(0,12,0.5,-12),
        ZIndex=12, Parent=tb,
    })
    U.Corner(logoF, 6)
    if logoImg ~= "" then
        -- LOGO CUSTOMIZADA: ImageLabel com sua imagem
        U.New("ImageLabel", {
            BackgroundTransparency=1,
            Image=logoImg,
            Size=UDim2.new(1,0,1,0),
            ScaleType=Enum.ScaleType.Fit,
            ZIndex=13, Parent=logoF,
        })
    else
        -- Fallback: letra B com borda
        U.Stroke(logoF, T.Pink, 1, 0.52)
        U.New("TextLabel", {
            BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
            Text="K", TextColor3=T.PinkLight,
            Font=T.FntBold, TextSize=13, ZIndex=13, Parent=logoF,
        })
    end

    -- Nome
    U.New("TextLabel", {
        BackgroundTransparency=1,
        Position=UDim2.new(0,42,0.5,-8), Size=UDim2.new(0,120,0,16),
        Text=string.upper(title),
        TextColor3=T.TxtPri,
        Font=T.FntSemi, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=11, Parent=tb,
    })

    -- Versão (tag discreta)
    local verTag = U.New("TextLabel", {
        BackgroundColor3=T.GlassElem, BackgroundTransparency=0.55,
        Position=UDim2.new(0,152,0.5,-7), Size=UDim2.new(0,28,0,14),
        Text="v3.2",
        TextColor3=T.TxtMute,
        Font=T.FntMono, TextSize=8,
        ZIndex=12, Parent=tb,
    })
    U.Corner(verTag, 4)
    U.Stroke(verTag, T.BrdElem, 1, T.BrdTElem)

    -- ── STATUS DOTS (centro, minimalistas) ──
    local statusHolder = U.New("Frame", {
        BackgroundTransparency=1,
        Position=UDim2.new(0.5,-130,0.5,-7), Size=UDim2.new(0,260,0,14),
        ZIndex=11, Parent=tb,
    })
    U.New("UIListLayout", {
        FillDirection=Enum.FillDirection.Horizontal,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        VerticalAlignment=Enum.VerticalAlignment.Center,
        Padding=UDim.new(0,18),
        Parent=statusHolder,
    })

    local function StatusPill(lbl, col)
        local con = U.New("Frame", {BackgroundTransparency=1, Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X, Parent=statusHolder})
        U.New("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,5), Parent=con})
        local dot = U.New("Frame", {BackgroundColor3=col, Size=UDim2.new(0,5,0,5), Parent=con})
        U.Corner(dot, 999)
        U.New("TextLabel", {
            BackgroundTransparency=1, Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
            Text=lbl, TextColor3=T.TxtMute,
            Font=T.FntMono, TextSize=8,
            Parent=con,
        })
        task.spawn(function()
            while dot and dot.Parent do
                U.Tw(dot, {BackgroundTransparency=0.75, Size=UDim2.new(0,4,0,4)}, 1.0)
                task.wait(1.0)
                U.Tw(dot, {BackgroundTransparency=0, Size=UDim2.new(0,5,0,5)}, 1.0)
                task.wait(1.0)
            end
        end)
    end

    StatusPill("INJECTED",  T.Success)
    StatusPill("BYPASSED",  T.Pink)
    StatusPill("ANTICHEAT", T.Warning)

    -- ── RELÓGIO (direita, antes dos botões) ──
    local clk = U.New("TextLabel", {
        BackgroundTransparency=1,
        Position=UDim2.new(1,-122,0.5,-7), Size=UDim2.new(0,60,0,14),
        Text=U.GetTime(),
        TextColor3=T.TxtMute,
        Font=T.FntMono, TextSize=8,
        TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=11, Parent=tb,
    })
    task.spawn(function() while clk and clk.Parent do clk.Text=U.GetTime() task.wait(1) end end)

    -- ── BOTÕES CONTROLE (círculos discretos, direita) ──
    local function CtrlBtn(sym, hov, xOff, cb)
        local b = U.New("TextButton", {
            BackgroundColor3=T.GlassElem, BackgroundTransparency=0.55,
            Position=UDim2.new(1,xOff,0.5,-10), Size=UDim2.new(0,20,0,20),
            Text=sym, TextColor3=T.TxtMute,
            Font=T.FntBold, TextSize=10,
            ZIndex=15, Parent=tb,
        })
        U.Corner(b, 999)
        b.MouseEnter:Connect(function()
            U.Tw(b, {BackgroundColor3=hov, TextColor3=Color3.new(1,1,1), BackgroundTransparency=0.1}, 0.15)
        end)
        b.MouseLeave:Connect(function()
            U.Tw(b, {BackgroundColor3=T.GlassElem, TextColor3=T.TxtMute, BackgroundTransparency=0.55}, 0.15)
        end)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    CtrlBtn("×", T.Error, -30, function()
        TwBlur(0, 0.3)
        U.Tw(win, {Size=UDim2.new(0,winW,0,0), BackgroundTransparency=1}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.38)
        sg:Destroy()
        if blur then pcall(function() blur:Destroy() end) end
    end)

    local minimized = false
    CtrlBtn("−", T.Warning, -56, function()
        minimized = not minimized
        if minimized then
            U.Tw(win, {Size=UDim2.new(0,winW,0,titleH)}, 0.3, Enum.EasingStyle.Quart)
        else
            U.Tw(win, {Size=UDim2.new(0,winW,0,winH)}, 0.4, Enum.EasingStyle.Back)
        end
    end)

    -- Drag
    local dragging, dStart, dSPos
    tb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=true; dStart=i.Position; dSPos=win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dStart
            win.Position = UDim2.new(dSPos.X.Scale, dSPos.X.Offset+d.X, dSPos.Y.Scale, dSPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    -- Toggle visibilidade
    local vis = true
    UserInputService.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == key then
            vis = not vis
            if vis then
                win.Visible = true
                win.Size = UDim2.new(0,winW,0,20)
                U.Tw(win, {Size=UDim2.new(0,winW,0,winH)}, 0.4, Enum.EasingStyle.Back)
                TwBlur(8, 0.3)
            else
                TwBlur(0, 0.3)
                U.Tw(win, {Size=UDim2.new(0,winW,0,20)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                task.wait(0.38)
                win.Visible = false
            end
        end
    end)

    -- ──────────────────────────────────────────────────────────────
    -- BODY
    -- ──────────────────────────────────────────────────────────────
    local body = U.New("Frame", {
        BackgroundTransparency = 1,
        Position         = UDim2.new(0, 0, 0, titleH),
        Size             = UDim2.new(1, 0, 1, -titleH),
        ClipsDescendants = false,
        Parent           = clipFrame,
    })

    -- ──────────────────────────────────────────────────────────────
    -- SIDEBAR
    -- ──────────────────────────────────────────────────────────────
    local sidebar = U.New("ScrollingFrame", {
        BackgroundColor3       = Color3.fromRGB(5, 4, 10),
        BackgroundTransparency = 0,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(0, sideW, 1, 0),
        ScrollBarThickness     = 2,
        ScrollBarImageColor3   = T.PinkMute,
        CanvasSize             = UDim2.new(0,0,0,0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ClipsDescendants       = true,
        Parent                 = body,
    })
    U.New("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,1), Parent=sidebar})
    U.Pad(sidebar, 10, 8, 12, 8)

    -- Label "NAVIGATION"
    U.New("TextLabel", {
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,16), Text="  NAVIGATION",
        TextColor3=T.TxtMute, Font=T.FntMono, TextSize=8,
        LetterSpacing = 6,
        TextXAlignment=Enum.TextXAlignment.Left,
        LayoutOrder=0, Parent=sidebar,
    })
    U.New("Frame", {
        BackgroundColor3=T.BrdCard, BackgroundTransparency=0.62,
        Size=UDim2.new(1,0,0,1), LayoutOrder=1, Parent=sidebar,
    })

    -- Indicador lateral ativo
    local indicator = U.New("Frame", {
        BackgroundColor3=T.Pink, Size=UDim2.new(0,2,0,22),
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,0,0,60),
        ZIndex=20, Parent=sidebar,
    })
    U.Corner(indicator, 4)
    -- Glow no indicador
    U.New("UIGradient", {
        Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.PinkLight), ColorSequenceKeypoint.new(1,T.Pink)}),
        Rotation=90, Parent=indicator,
    })

    -- Divisor sidebar/content
    U.New("Frame", {
        BackgroundColor3=T.BrdWin, BackgroundTransparency=0.82,
        Size=UDim2.new(0,1,1,0), Position=UDim2.new(0,sideW,0,0),
        ZIndex=5, Parent=body,
    })

    -- ──────────────────────────────────────────────────────────────
    -- CONTENT AREA
    -- ──────────────────────────────────────────────────────────────
    local contentArea = U.New("Frame", {
        BackgroundTransparency=1,
        Position=UDim2.new(0,sideW+1,0,0),
        Size=UDim2.new(1,-(sideW+1),1,0),
        ClipsDescendants=true,
        Parent=body,
    })

    -- ──────────────────────────────────────────────────────────────
    -- WINDOW OBJECT
    -- ──────────────────────────────────────────────────────────────
    local Win = {_tabs={}, _btns={}, _active=nil, _ord=2}

    function Win:AddTab(tc)
        tc = tc or {}
        local name  = tc.Name  or ("Tab "..#self._tabs+1)
        local badge = tc.Badge
        self._ord = self._ord + 1
        local lo  = self._ord

        -- Botão sidebar
        local btn = U.New("TextButton", {
            BackgroundColor3=T.GlassElem, BackgroundTransparency=1,
            Size=UDim2.new(1,0,0,32), Text="",
            LayoutOrder=lo, ClipsDescendants=true, Parent=sidebar,
        })
        U.Corner(btn, 6)

        -- Barra accent esquerda
        local acBar = U.New("Frame", {
            BackgroundColor3=T.Pink,
            Size=UDim2.new(0,2,0.45,0), Position=UDim2.new(0,4,0.275,0),
            BackgroundTransparency=0.6, Parent=btn,
        })
        U.Corner(acBar, 2)

        local nameLbl = U.New("TextLabel", {
            BackgroundTransparency=1,
            Position=UDim2.new(0,14,0.5,-7), Size=UDim2.new(1,-36,0,14),
            Text=name,
            TextColor3=T.TxtSec,
            Font=T.FntBody, TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=2, Parent=btn,
        })

        if badge then
            local bf = U.New("Frame", {
                BackgroundColor3=T.PinkDark,
                Position=UDim2.new(1,-26,0.5,-8), Size=UDim2.new(0,20,0,16),
                ZIndex=3, Parent=btn,
            })
            U.Corner(bf, 4)
            U.New("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text=tostring(badge), TextColor3=Color3.new(1,1,1), Font=T.FntBold, TextSize=8, ZIndex=4, Parent=bf})
        end

        -- Página de conteúdo
        local page = U.New("ScrollingFrame", {
            BackgroundTransparency=1,
            Size=UDim2.new(1,0,1,0),
            ScrollBarThickness=2, ScrollBarImageColor3=T.PinkMute,
            CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=false, Parent=contentArea,
        })
        U.Pad(page, 14, 14, 14, 14)
        U.New("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,10), Parent=page})

        -- Header da página
        local ph = U.New("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,28), LayoutOrder=0, Parent=page})
        U.New("TextLabel", {
            BackgroundTransparency=1, Size=UDim2.new(0.5,0,1,0),
            Text=name,
            TextColor3=T.TxtPri,
            Font=T.FntSemi, TextSize=15,
            TextXAlignment=Enum.TextXAlignment.Left,
            Parent=ph,
        })
        -- Subtítulo mono à direita do título
        U.New("TextLabel", {
            BackgroundTransparency=1,
            Position=UDim2.new(0.5,0,0.5,-6), Size=UDim2.new(0.5,0,0,12),
            Text="// "..string.lower(name).." config",
            TextColor3=T.TxtMute,
            Font=T.FntMono, TextSize=8,
            TextXAlignment=Enum.TextXAlignment.Left,
            Parent=ph,
        })
        U.New("Frame", {
            BackgroundColor3=T.Pink, BackgroundTransparency=0.82,
            Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1),
            Parent=ph,
        })

        -- Grid 2 colunas
        local grid = U.New("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, LayoutOrder=1, Parent=page})
        local colL = U.New("Frame", {BackgroundTransparency=1, Position=UDim2.new(0,0,0,0), Size=UDim2.new(0.5,-6,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=grid})
        U.New("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,8), Parent=colL})
        local colR = U.New("Frame", {BackgroundTransparency=1, Position=UDim2.new(0.5,6,0,0), Size=UDim2.new(0.5,-6,0,0), AutomaticSize=Enum.AutomaticSize.Y, Parent=grid})
        U.New("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,8), Parent=colR})
        local colIdx = 0

        -- Ativar tab
        local function Activate(instant)
            for _, it in ipairs(Win._btns) do
                U.Tw(it.btn, {BackgroundTransparency=1}, 0.18)
                U.Tw(it.lbl, {TextColor3=T.TxtSec}, 0.18)
                if it.bar then U.Tw(it.bar, {BackgroundTransparency=0.6}, 0.18) end
            end
            for _, pg in ipairs(Win._tabs) do pg.Visible=false end
            U.Tw(btn, {BackgroundTransparency=0.78, BackgroundColor3=T.GlassElem}, 0.18)
            U.Tw(nameLbl, {TextColor3=T.PinkLight}, 0.18)
            U.Tw(acBar, {BackgroundTransparency=0}, 0.18)
            local yp = btn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y + btn.AbsoluteSize.Y/2
            if instant then indicator.Position=UDim2.new(1,0,0,yp-11)
            else U.Tw(indicator, {Position=UDim2.new(1,0,0,yp-11)}, 0.28, Enum.EasingStyle.Quart) end
            page.Visible=true; Win._active=page
        end

        table.insert(Win._tabs, page)
        table.insert(Win._btns, {btn=btn, lbl=nameLbl, bar=acBar})
        btn.MouseEnter:Connect(function()
            if Win._active~=page then U.Tw(btn,{BackgroundTransparency=0.88,BackgroundColor3=T.GlassElem},0.15) end
        end)
        btn.MouseLeave:Connect(function()
            if Win._active~=page then U.Tw(btn,{BackgroundTransparency=1},0.15) end
        end)
        btn.MouseButton1Click:Connect(function()
            U.Ripple(btn,Mouse.X,Mouse.Y)
            Activate()
        end)
        if #Win._tabs==1 then task.defer(function() Activate(true) end) end

        -- ──────────────────────────────────────────────────────────
        -- TAB OBJECT
        -- ──────────────────────────────────────────────────────────
        local Tab = {}

        function Tab:AddSection(sname)
            colIdx = colIdx + 1
            local col = (colIdx%2==1) and colL or colR

            local card = U.New("Frame", {
                BackgroundColor3       = T.GlassCard,
                BackgroundTransparency = T.TCard,
                Size                   = UDim2.new(1,0,0,0),
                AutomaticSize          = Enum.AutomaticSize.Y,
                LayoutOrder            = colIdx,
                ClipsDescendants       = false,
                Parent                 = col,
            })
            U.Corner(card, 10)
            U.Stroke(card, T.BrdCard, 1, 0.55)
            U.New("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,0), Parent=card})
            U.Pad(card, 0, 10, 10, 10)

            -- Header da seção
            local sh = U.New("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,32), LayoutOrder=0, Parent=card})
            local sdot = U.New("Frame", {BackgroundColor3=T.Pink, Size=UDim2.new(0,5,0,5), Position=UDim2.new(0,0,0.5,-2.5), Parent=sh})
            U.Corner(sdot, 999)
            task.spawn(function()
                while sdot and sdot.Parent do
                    U.Tw(sdot, {BackgroundTransparency=0.7, Size=UDim2.new(0,3,0,3)}, 1.2)
                    task.wait(1.2)
                    U.Tw(sdot, {BackgroundTransparency=0, Size=UDim2.new(0,5,0,5)}, 1.2)
                    task.wait(1.2)
                end
            end)
            U.New("TextLabel", {
                BackgroundTransparency=1,
                Position=UDim2.new(0,12,0.5,-7), Size=UDim2.new(1,-12,0,14),
                Text=string.upper(sname),
                TextColor3=T.TxtAcct,
                Font=T.FntMono, TextSize=9,
                TextXAlignment=Enum.TextXAlignment.Left,
                Parent=sh,
            })
            U.New("Frame", {
                BackgroundColor3=T.Pink, BackgroundTransparency=0.88,
                Size=UDim2.new(1,20,0,1), Position=UDim2.new(0,-10,1,-1),
                Parent=sh,
            })

            local Sec  = {}
            local iOrd = 0

            local function Row(lbl, h)
                iOrd = iOrd + 1
                local r = U.New("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,h or 34), LayoutOrder=iOrd, Parent=card})
                U.New("TextLabel", {
                    BackgroundTransparency=1,
                    Position=UDim2.new(0,2,0.5,-7), Size=UDim2.new(0.55,-4,0,14),
                    Text=lbl,
                    TextColor3=T.TxtPri,
                    Font=T.FntBody, TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    Parent=r,
                })
                return r
            end

            -- ── TOGGLE ──
            function Sec:AddToggle(c)
                c = c or {}
                local row   = Row(c.Name or "Toggle")
                local state = c.Default or false
                local cb    = c.Callback or function() end

                local track = U.New("Frame", {
                    BackgroundColor3=T.GlassInput, BackgroundTransparency=T.TInput,
                    Position=UDim2.new(1,-50,0.5,-10), Size=UDim2.new(0,44,0,20),
                    Parent=row,
                })
                U.Corner(track, 999)
                U.Stroke(track, T.BrdElem, 1, T.BrdTElem)

                local fill = U.New("Frame", {
                    BackgroundColor3=T.Pink, Size=UDim2.new(0,0,1,0),
                    ClipsDescendants=true, Parent=track,
                })
                U.Corner(fill, 999)
                U.New("UIGradient", {
                    Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.PinkDark), ColorSequenceKeypoint.new(1,T.Pink)}),
                    Parent=fill,
                })

                local thumb = U.New("Frame", {
                    BackgroundColor3=Color3.new(1,1,1),
                    Position=UDim2.new(0,2,0.5,-7), Size=UDim2.new(0,14,0,14),
                    ZIndex=3, Parent=track,
                })
                U.Corner(thumb, 999)

                local function Upd(s, ani)
                    if s then
                        if ani then
                            U.Tw(fill,  {Size=UDim2.new(1,0,1,0)}, 0.2)
                            U.Tw(thumb, {Position=UDim2.new(1,-16,0.5,-7), BackgroundColor3=T.PinkLight}, 0.2)
                            U.Tw(track, {BackgroundColor3=T.PinkDark, BackgroundTransparency=0.12}, 0.2)
                        else
                            fill.Size=UDim2.new(1,0,1,0)
                            thumb.Position=UDim2.new(1,-16,0.5,-7)
                            thumb.BackgroundColor3=T.PinkLight
                            track.BackgroundColor3=T.PinkDark
                            track.BackgroundTransparency=0.12
                        end
                    else
                        if ani then
                            U.Tw(fill,  {Size=UDim2.new(0,0,1,0)}, 0.2)
                            U.Tw(thumb, {Position=UDim2.new(0,2,0.5,-7), BackgroundColor3=Color3.new(1,1,1)}, 0.2)
                            U.Tw(track, {BackgroundColor3=T.GlassInput, BackgroundTransparency=T.TInput}, 0.2)
                        else
                            fill.Size=UDim2.new(0,0,1,0)
                            thumb.Position=UDim2.new(0,2,0.5,-7)
                            thumb.BackgroundColor3=Color3.new(1,1,1)
                            track.BackgroundColor3=T.GlassInput
                            track.BackgroundTransparency=T.TInput
                        end
                    end
                end
                Upd(state, false)

                local hit = U.New("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", ZIndex=5, Parent=row})
                hit.MouseButton1Click:Connect(function()
                    state = not state; Upd(state, true); cb(state)
                end)

                local o={}
                function o:Set(v,s) state=v Upd(v,true) if not s then cb(v) end end
                function o:Get() return state end
                return o
            end

            -- ── SLIDER ──
            function Sec:AddSlider(c)
                c = c or {}
                local mn    = c.Min or 0
                local mx    = c.Max or 100
                local def   = c.Default or mn
                local cb    = c.Callback or function() end
                local sfx   = c.Suffix or ""
                local isInt = c.Integer or false

                iOrd = iOrd + 1
                local row = U.New("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,48), LayoutOrder=iOrd, Parent=card})
                U.New("TextLabel", {
                    BackgroundTransparency=1,
                    Position=UDim2.new(0,2,0,4), Size=UDim2.new(0.6,0,0,14),
                    Text=c.Name or "Slider",
                    TextColor3=T.TxtPri,
                    Font=T.FntBody, TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    Parent=row,
                })
                local vLbl = U.New("TextLabel", {
                    BackgroundTransparency=1,
                    Position=UDim2.new(0.6,0,0,4), Size=UDim2.new(0.4,-2,0,14),
                    Text=tostring(def)..sfx,
                    TextColor3=T.PinkLight,
                    Font=T.FntMono, TextSize=9,
                    TextXAlignment=Enum.TextXAlignment.Right,
                    Parent=row,
                })

                local track = U.New("Frame", {
                    BackgroundColor3=T.GlassInput, BackgroundTransparency=T.TInput,
                    Position=UDim2.new(0,2,0,28), Size=UDim2.new(1,-4,0,6),
                    Parent=row,
                })
                U.Corner(track, 999)

                local pct0 = (mx~=mn) and (def-mn)/(mx-mn) or 0
                local fillB = U.New("Frame", {BackgroundColor3=T.Pink, Size=UDim2.new(pct0,0,1,0), ClipsDescendants=true, Parent=track})
                U.Corner(fillB, 999)
                U.New("UIGradient", {
                    Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.PinkDark), ColorSequenceKeypoint.new(1,T.PinkLight)}),
                    Parent=fillB,
                })

                local thumb = U.New("Frame", {
                    BackgroundColor3=Color3.new(1,1,1),
                    AnchorPoint=Vector2.new(0.5,0.5),
                    Position=UDim2.new(pct0,0,0.5,0),
                    Size=UDim2.new(0,13,0,13), ZIndex=4, Parent=track,
                })
                U.Corner(thumb, 999)
                U.Stroke(thumb, T.Pink, 2)

                local val  = def
                local drag = false

                local function UpdSlider(v)
                    v = math.clamp(v, mn, mx)
                    if isInt then v = math.round(v) end
                    val = v
                    local p = (mx~=mn) and (v-mn)/(mx-mn) or 0
                    U.Tw(fillB, {Size=UDim2.new(p,0,1,0)}, 0.05)
                    U.Tw(thumb, {Position=UDim2.new(p,0,0.5,0)}, 0.05)
                    vLbl.Text = tostring(isInt and v or math.round(v*10)/10)..sfx
                    cb(v)
                end

                track.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then
                        drag=true
                        local p=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                        UpdSlider(mn+(mx-mn)*p)
                    end
                end)
                local mv = UserInputService.InputChanged:Connect(function(i)
                    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                        local p=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                        UpdSlider(mn+(mx-mn)*p)
                    end
                end)
                local ed = UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
                end)
                card.AncestryChanged:Connect(function()
                    if not card.Parent then mv:Disconnect() ed:Disconnect() end
                end)

                local o={}
                function o:Set(v) UpdSlider(v) end
                function o:Get() return val end
                return o
            end

            -- ── BUTTON ──
            function Sec:AddButton(c)
                c = c or {}
                iOrd = iOrd + 1
                local rH = c.Description and 52 or 34
                local row = U.New("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,rH), LayoutOrder=iOrd, Parent=card})
                local b = U.New("TextButton", {
                    BackgroundColor3=T.GlassElem, BackgroundTransparency=0.42,
                    Position=UDim2.new(0,2,0,c.Description and 4 or 5),
                    Size=UDim2.new(1,-4,0,24), Text="",
                    ClipsDescendants=true, Parent=row,
                })
                U.Corner(b, 6)
                U.Stroke(b, T.BrdCard, 1, T.BrdTCard)
                U.New("TextLabel", {
                    BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
                    Text=c.Name or "Button",
                    TextColor3=T.PinkLight,
                    Font=T.FntSemi, TextSize=10,
                    Parent=b,
                })
                if c.Description then
                    U.New("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,2,0,30), Size=UDim2.new(1,-4,0,14), Text=c.Description, TextColor3=T.TxtMute, Font=T.FntMono, TextSize=8, TextXAlignment=Enum.TextXAlignment.Center, Parent=row})
                end
                b.MouseEnter:Connect(function()
                    U.Tw(b,{BackgroundColor3=Color3.fromRGB(40,25,70), BackgroundTransparency=0.22},0.15)
                end)
                b.MouseLeave:Connect(function()
                    U.Tw(b,{BackgroundColor3=T.GlassElem, BackgroundTransparency=0.42},0.15)
                end)
                b.MouseButton1Click:Connect(function()
                    U.Ripple(b,Mouse.X,Mouse.Y)
                    U.Tw(b,{BackgroundColor3=T.Pink, BackgroundTransparency=0.12},0.06)
                    task.wait(0.09)
                    U.Tw(b,{BackgroundColor3=T.GlassElem, BackgroundTransparency=0.42},0.3)
                    ;(c.Callback or function()end)()
                end)
            end

            -- ── KEYBIND ──
            function Sec:AddBind(c)
                c = c or {}
                local row  = Row(c.Name or "Keybind")
                local bkey = c.Default
                local lst  = false
                local cb   = c.Callback or function() end

                local chip = U.New("TextButton", {
                    BackgroundColor3=T.GlassInput, BackgroundTransparency=T.TInput,
                    Position=UDim2.new(1,-76,0.5,-11), Size=UDim2.new(0,72,0,22),
                    Text=bkey and bkey.Name or "None",
                    TextColor3=bkey and T.PinkLight or T.TxtMute,
                    Font=T.FntMono, TextSize=9,
                    ClipsDescendants=true, Parent=row,
                })
                U.Corner(chip, 5)
                U.Stroke(chip, T.BrdElem, 1, T.BrdTElem)

                chip.MouseButton1Click:Connect(function()
                    if lst then return end
                    lst=true chip.Text="..." chip.TextColor3=T.Pink
                    local con; con=UserInputService.InputBegan:Connect(function(i,gp)
                        if gp then return end
                        if i.UserInputType==Enum.UserInputType.Keyboard then
                            if i.KeyCode==Enum.KeyCode.Escape then bkey=nil chip.Text="None" chip.TextColor3=T.TxtMute
                            else bkey=i.KeyCode chip.Text=i.KeyCode.Name chip.TextColor3=T.PinkLight end
                            lst=false con:Disconnect()
                        end
                    end)
                end)
                UserInputService.InputBegan:Connect(function(i,gp)
                    if not gp and bkey and i.KeyCode==bkey then cb() end
                end)

                local o={}
                function o:Set(v) bkey=v chip.Text=v and v.Name or "None" chip.TextColor3=v and T.PinkLight or T.TxtMute end
                function o:Get() return bkey end
                return o
            end

            -- ── DROPDOWN ──
            function Sec:AddDropdown(c)
                c = c or {}
                local row  = Row(c.Name or "Dropdown", 34)
                local opts = c.Options or {}
                local sel  = c.Default or opts[1]
                local cb   = c.Callback or function() end
                local open = false

                local db = U.New("TextButton", {
                    BackgroundColor3=T.GlassInput, BackgroundTransparency=T.TInput,
                    Position=UDim2.new(0.42,0,0.5,-11), Size=UDim2.new(0.58,-2,0,22),
                    Text="", ClipsDescendants=false, Parent=row,
                })
                U.Corner(db, 5)
                U.Stroke(db, T.BrdElem, 1, T.BrdTElem)
                local selLbl = U.New("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,7,0,0), Size=UDim2.new(1,-22,1,0), Text=tostring(sel or ""), TextColor3=T.TxtPri, Font=T.FntBody, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left, Parent=db})
                local chev = U.New("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(1,-16,0.5,-7), Size=UDim2.new(0,12,0,14), Text="v", TextColor3=T.PinkLight, Font=T.FntBold, TextSize=9, Parent=db})

                local dl = U.New("Frame", {
                    BackgroundColor3=T.GlassInput, BackgroundTransparency=0.10,
                    Position=UDim2.new(0,0,1,4), Size=UDim2.new(1,0,0,0),
                    ZIndex=100, ClipsDescendants=true, Visible=false, Parent=db,
                })
                U.Corner(dl, 7)
                U.Stroke(dl, T.BrdCard, 1, T.BrdTCard)
                U.New("UIListLayout", {SortOrder=Enum.SortOrder.LayoutOrder, Parent=dl})

                for i, opt in ipairs(opts) do
                    local ob = U.New("TextButton", {
                        BackgroundColor3=T.GlassElem, BackgroundTransparency=(opt==sel) and 0.5 or 1,
                        Size=UDim2.new(1,0,0,26), Text="", LayoutOrder=i, ZIndex=101, Parent=dl,
                    })
                    U.New("TextLabel", {BackgroundTransparency=1, Position=UDim2.new(0,9,0,0), Size=UDim2.new(1,-9,1,0), Text=tostring(opt), TextColor3=(opt==sel) and T.PinkLight or T.TxtPri, Font=T.FntBody, TextSize=9, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=102, Parent=ob})
                    ob.MouseEnter:Connect(function() U.Tw(ob,{BackgroundTransparency=0.55,BackgroundColor3=T.GlassElem},0.1) end)
                    ob.MouseLeave:Connect(function() U.Tw(ob,{BackgroundTransparency=opt==sel and 0.5 or 1},0.1) end)
                    ob.MouseButton1Click:Connect(function()
                        sel=opt selLbl.Text=tostring(opt) open=false
                        U.Tw(chev,{Rotation=0},0.2) U.Tw(dl,{Size=UDim2.new(1,0,0,0)},0.2)
                        task.wait(0.22) dl.Visible=false cb(sel)
                    end)
                end

                local th=#opts*26
                db.MouseButton1Click:Connect(function()
                    open=not open
                    if open then
                        dl.Visible=true dl.Size=UDim2.new(1,0,0,0)
                        U.Tw(dl,{Size=UDim2.new(1,0,0,th)},0.28,Enum.EasingStyle.Back)
                        U.Tw(chev,{Rotation=180},0.2)
                    else
                        U.Tw(chev,{Rotation=0},0.2)
                        U.Tw(dl,{Size=UDim2.new(1,0,0,0)},0.2)
                        task.wait(0.22) dl.Visible=false
                    end
                end)

                local o={}
                function o:Set(v) sel=v selLbl.Text=tostring(v) end
                function o:Get() return sel end
                return o
            end

            -- ── TEXTBOX ──
            function Sec:AddTextBox(c)
                c = c or {}
                local row     = Row(c.Name or "Input", 34)
                local cb      = c.Callback or function() end
                local numOnly = c.NumberOnly or false

                local box = U.New("TextBox", {
                    BackgroundColor3=T.GlassInput, BackgroundTransparency=T.TInput,
                    Position=UDim2.new(0.42,0,0.5,-11), Size=UDim2.new(0.58,-2,0,22),
                    Text=c.Default or "", PlaceholderText=c.Placeholder or "...",
                    TextColor3=T.TxtPri, PlaceholderColor3=T.TxtMute,
                    Font=T.FntMono, TextSize=9, ClearTextOnFocus=false, Parent=row,
                })
                U.Corner(box, 5)
                local bstr = U.Stroke(box, T.BrdElem, 1, T.BrdTElem)

                box.Focused:Connect(function()
                    U.Tw(bstr,{Color=T.Pink, Transparency=0.18},0.2)
                    U.Tw(box,{BackgroundColor3=Color3.fromRGB(28,16,52), BackgroundTransparency=0.22},0.2)
                end)
                box.FocusLost:Connect(function(enter)
                    U.Tw(bstr,{Color=T.BrdElem, Transparency=T.BrdTElem},0.2)
                    U.Tw(box,{BackgroundColor3=T.GlassInput, BackgroundTransparency=T.TInput},0.2)
                    if numOnly and not tonumber(box.Text) then box.Text="" end
                    if enter then cb(box.Text) end
                end)
                box:GetPropertyChangedSignal("Text"):Connect(function()
                    if numOnly then box.Text=box.Text:gsub("[^%d%.%-]","") end
                end)

                local o={}
                function o:Set(v) box.Text=tostring(v) end
                function o:Get() return box.Text end
                return o
            end

            -- ── COLOR PICKER ──
            function Sec:AddColorPicker(c)
                c = c or {}
                local row   = Row(c.Name or "Color", 34)
                local cb    = c.Callback or function() end
                local cur   = c.Default or Color3.fromRGB(162, 89, 255)
                local popen = false
                local hsv   = {}
                do local h,s,v=Color3.toHSV(cur) hsv.h,hsv.s,hsv.v=h,s,v end

                local sw = U.New("TextButton", {
                    BackgroundColor3=cur,
                    Position=UDim2.new(1,-36,0.5,-11), Size=UDim2.new(0,32,0,22),
                    Text="", Parent=row,
                })
                U.Corner(sw, 5)
                U.Stroke(sw, T.BrdElem, 1, T.BrdTElem)

                local function ToHex(col)
                    return string.format("#%02X%02X%02X", math.round(col.R*255), math.round(col.G*255), math.round(col.B*255))
                end
                local hexLbl = U.New("TextLabel", {
                    BackgroundTransparency=1,
                    Position=UDim2.new(1,-100,0.5,-7), Size=UDim2.new(0,58,0,14),
                    Text=ToHex(cur), TextColor3=T.TxtMute, Font=T.FntMono, TextSize=8,
                    Parent=row,
                })

                local panel = U.New("Frame", {
                    BackgroundColor3=T.GlassCard, BackgroundTransparency=0.08,
                    Size=UDim2.new(0,185,0,0),
                    ZIndex=200, Visible=false, ClipsDescendants=true,
                    Parent=contentArea,
                })
                U.Corner(panel, 10)
                U.Stroke(panel, T.BrdCard, 1, T.BrdTCard)
                U.Pad(panel, 10, 10, 10, 10)
                U.New("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder, Parent=panel})

                local function Rebuild()
                    cur = Color3.fromHSV(hsv.h, hsv.s, hsv.v)
                    sw.BackgroundColor3 = cur
                    hexLbl.Text = ToHex(cur)
                    cb(cur)
                end

                local sdefs = {
                    {lbl="H", key="h", c1=Color3.fromRGB(255,0,0),     c2=Color3.fromRGB(160,0,255)},
                    {lbl="S", key="s", c1=Color3.fromRGB(170,170,170), c2=Color3.fromRGB(162,89,255)},
                    {lbl="V", key="v", c1=Color3.fromRGB(0,0,0),       c2=Color3.fromRGB(255,255,255)},
                }

                for i, sd in ipairs(sdefs) do
                    local slDrag = false
                    local sr = U.New("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,26), LayoutOrder=i, Parent=panel})
                    U.New("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0,12,1,0), Text=sd.lbl, TextColor3=T.TxtMute, Font=T.FntMono, TextSize=9, Parent=sr})

                    local slTrk = U.New("Frame", {
                        BackgroundColor3=T.GlassInput, BackgroundTransparency=0.28,
                        Position=UDim2.new(0,16,0.5,-5), Size=UDim2.new(1,-16,0,10),
                        Parent=sr,
                    })
                    U.Corner(slTrk, 999)
                    U.New("UIGradient", {Color=ColorSequence.new({ColorSequenceKeypoint.new(0,sd.c1),ColorSequenceKeypoint.new(1,sd.c2)}), Parent=slTrk})

                    local slTh = U.New("Frame", {
                        BackgroundColor3=Color3.new(1,1,1),
                        AnchorPoint=Vector2.new(0.5,0.5),
                        Position=UDim2.new(hsv[sd.key],0,0.5,0),
                        Size=UDim2.new(0,12,0,12), ZIndex=201, Parent=slTrk,
                    })
                    U.Corner(slTh, 999)
                    U.Stroke(slTh, Color3.new(1,1,1), 2)

                    slTrk.InputBegan:Connect(function(inp)
                        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                            slDrag = true
                            local p = math.clamp((inp.Position.X-slTrk.AbsolutePosition.X)/slTrk.AbsoluteSize.X, 0, 1)
                            hsv[sd.key] = p
                            slTh.Position = UDim2.new(p,0,0.5,0)
                            Rebuild()
                        end
                    end)

                    local mv = UserInputService.InputChanged:Connect(function(inp)
                        if slDrag and inp.UserInputType==Enum.UserInputType.MouseMovement then
                            local p = math.clamp((inp.Position.X-slTrk.AbsolutePosition.X)/slTrk.AbsoluteSize.X, 0, 1)
                            hsv[sd.key] = p
                            slTh.Position = UDim2.new(p,0,0.5,0)
                            Rebuild()
                        end
                    end)

                    local ed = UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType==Enum.UserInputType.MouseButton1 then slDrag = false end
                    end)

                    panel.AncestryChanged:Connect(function()
                        if not panel.Parent then mv:Disconnect() ed:Disconnect() end
                    end)
                end

                sw.MouseButton1Click:Connect(function()
                    popen = not popen
                    if popen then
                        local ax = sw.AbsolutePosition.X - contentArea.AbsolutePosition.X
                        local ay = sw.AbsolutePosition.Y - contentArea.AbsolutePosition.Y
                        panel.Position = UDim2.new(0, math.clamp(ax-148,0,contentArea.AbsoluteSize.X-190), 0, ay+28)
                        panel.Visible = true
                        panel.Size = UDim2.new(0,185,0,0)
                        U.Tw(panel, {Size=UDim2.new(0,185,0,118)}, 0.3, Enum.EasingStyle.Back)
                    else
                        U.Tw(panel, {Size=UDim2.new(0,185,0,0)}, 0.22)
                        task.wait(0.25)
                        panel.Visible = false
                    end
                end)

                local o={}
                function o:Set(col)
                    cur=col sw.BackgroundColor3=col hexLbl.Text=ToHex(col)
                    local h,s,v=Color3.toHSV(col) hsv.h,hsv.s,hsv.v=h,s,v
                end
                function o:Get() return cur end
                return o
            end

            -- ── LABEL ──
            function Sec:AddLabel(text)
                iOrd=iOrd+1
                local r=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),LayoutOrder=iOrd,Parent=card})
                U.New("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,2,0,0),Size=UDim2.new(1,-4,1,0),Text=text,TextColor3=T.TxtSec,Font=T.FntMono,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Parent=r})
            end

            -- ── SEPARATOR ──
            function Sec:AddSeparator(lbl)
                iOrd=iOrd+1
                local r=U.New("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,20),LayoutOrder=iOrd,Parent=card})
                U.New("Frame",{BackgroundColor3=T.BrdCard,BackgroundTransparency=0.55,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0,1),Parent=r})
                if lbl then
                    local lb=U.New("Frame",{BackgroundColor3=T.GlassCard,BackgroundTransparency=T.TCard,AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,8,0.5,0),Size=UDim2.new(0,0,0,14),AutomaticSize=Enum.AutomaticSize.X,Parent=r})
                    U.Pad(lb,0,5,0,5)
                    U.New("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=lbl,TextColor3=T.PinkMute,Font=T.FntMono,TextSize=8,Parent=lb})
                end
            end

            return Sec
        end -- AddSection

        return Tab
    end -- AddTab

    -- Animação de entrada
    win.Size = UDim2.new(0, winW, 0, 0)
    task.wait(0.05)
    U.Tw(win, {Size=UDim2.new(0,winW,0,winH)}, 0.45, Enum.EasingStyle.Back)
    TwBlur(8, 0.45)

    return Win
end

return BarbiUI

--[[
══════════════════════════════════════════════════════
  COMO USAR A FOTO DE FUNDO:
  
  Na chamada CreateWindow, passe o parâmetro Background:
  
  local Window = BarbiUI:CreateWindow({
      Title      = "Kyotaki HUB",
      Key        = Enum.KeyCode.RightShift,
      Background = "rbxassetid://SEU_ID_AQUI",
  })
  
  O ImageTransparency padrão é 0.55 — ajuste na linha
  marcada com "-- ajuste de 0 (opaco) a 1 (invisível)"
══════════════════════════════════════════════════════
]]
