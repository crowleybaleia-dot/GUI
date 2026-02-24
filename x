--[[
    NexusHub — visual baseado no Arox Hub
    Cores: Verde Sage (#4CAF50) + Preto Puro
    Layout: sidebar esq (título + seções + tabs) | conteúdo dir (subtítulo + seções + componentes)
]]

local NexusHub = {}
NexusHub.__index = NexusHub

getgenv().Toggles = getgenv().Toggles or {}
getgenv().Options = getgenv().Options or {}

local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PL  = game:GetService("Players")

-- ════════════════════════════════════════════════════════
--  TEMA
-- ════════════════════════════════════════════════════════
local C = {
    -- fundo
    BgWindow    = Color3.fromRGB(0,   0,   0),    -- preto puro (janela)
    BgSidebar   = Color3.fromRGB(0,   0,   0),    -- preto puro (sidebar)
    BgContent   = Color3.fromRGB(6,   6,   8),    -- quase preto (conteúdo)
    BgSection   = Color3.fromRGB(0,   0,   0),    -- label de seção

    -- elementos
    TabActive   = Color3.fromRGB(20,  20,  22),   -- tab selecionada (fundo levemente mais claro)
    TabHover    = Color3.fromRGB(16,  16,  18),

    ItemHover   = Color3.fromRGB(14,  14,  16),

    ToggleOff   = Color3.fromRGB(50,  50,  58),
    ToggleOn    = Color3.fromRGB(76,  175, 80),   -- VERDE SAGE

    KeyBg       = Color3.fromRGB(28,  28,  34),

    SliderTrack = Color3.fromRGB(38,  38,  46),
    SliderFill  = Color3.fromRGB(76,  175, 80),   -- VERDE SAGE
    SliderKnob  = Color3.fromRGB(200, 200, 210),

    -- bordas
    Border      = Color3.fromRGB(30,  30,  36),
    BorderSide  = Color3.fromRGB(28,  28,  34),   -- divisor sidebar/content

    -- texto
    Text        = Color3.fromRGB(210, 210, 218),  -- texto principal
    TextSub     = Color3.fromRGB(150, 150, 162),  -- subtexto
    TextMuted   = Color3.fromRGB(85,  85,  100),  -- muted (seção header, ícones)
    TextAccent  = Color3.fromRGB(76,  175, 80),   -- verde sage

    -- accent
    Accent      = Color3.fromRGB(76,  175, 80),
    AccentDim   = Color3.fromRGB(50,  120, 53),

    White       = Color3.fromRGB(255, 255, 255),
}

-- ════════════════════════════════════════════════════════
--  UTILS
-- ════════════════════════════════════════════════════════
local function tw(o, p, t)
    TS:Create(o, TweenInfo.new(t or .14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
end

local function new(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props) do
        if k ~= "Parent" and k ~= "Ch" then
            o[k] = v
        end
    end
    if props.Ch then
        for _, c in ipairs(props.Ch) do c.Parent = o end
    end
    if props.Parent then o.Parent = props.Parent end
    return o
end

local function Corner(p, r)   return new("UICorner",  {Parent=p, CornerRadius=UDim.new(0, r or 4)}) end
local function Stroke(p, c, t) return new("UIStroke", {Parent=p, Color=c or C.Border, Thickness=t or 1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function Pad(p, l, r, t, b)
    return new("UIPadding", {
        Parent=p,
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r ~= nil and r or l or 0),
        PaddingTop    = UDim.new(0, t ~= nil and t or l or 0),
        PaddingBottom = UDim.new(0, b ~= nil and b or t or l or 0),
    })
end
local function VList(p, gap)
    return new("UIListLayout", {
        Parent=p, Padding=UDim.new(0, gap or 0),
        FillDirection=Enum.FillDirection.Vertical,
        SortOrder=Enum.SortOrder.LayoutOrder,
        HorizontalAlignment=Enum.HorizontalAlignment.Left,
        VerticalAlignment=Enum.VerticalAlignment.Top,
    })
end
local function HList(p, gap, ha, va)
    return new("UIListLayout", {
        Parent=p, Padding=UDim.new(0, gap or 0),
        FillDirection=Enum.FillDirection.Horizontal,
        SortOrder=Enum.SortOrder.LayoutOrder,
        HorizontalAlignment=ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment=va or Enum.VerticalAlignment.Center,
    })
end
local function SF(parent, size, pos)
    return new("ScrollingFrame", {
        Parent=parent,
        Size=size or UDim2.new(1,0,1,0),
        Position=pos or UDim2.new(0,0,0,0),
        BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=2, ScrollBarImageColor3=C.Accent,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
    })
end
local function Lbl(parent, text, size, color, font, xa)
    return new("TextLabel", {
        Parent=parent,
        BackgroundTransparency=1,
        Text=text, TextSize=size or 12,
        TextColor3=color or C.Text,
        Font=font or Enum.Font.Gotham,
        TextXAlignment=xa or Enum.TextXAlignment.Left,
        Size=UDim2.new(1,0,1,0),
    })
end

-- ════════════════════════════════════════════════════════
--  SECTION  (área de conteúdo, lado direito)
-- ════════════════════════════════════════════════════════
local Section = {}
Section.__index = Section

-- ─── Toggle  (igual Arox: "Label   [No Bind] [toggle]") ──
function Section:AddToggle(idx, info)
    info = info or {}
    local text    = info.Text    or idx
    local default = info.Default or false

    -- row container
    local row = new("Frame", {
        Parent=self._list,
        Size=UDim2.new(1,0,0,30),
        BackgroundTransparency=1,
    })

    -- label
    new("TextLabel", {
        Parent=row,
        Size=UDim2.new(1,-100,1,0),
        BackgroundTransparency=1,
        Text=text, TextSize=12,
        TextColor3=C.Text, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
    })

    -- right: [No Bind] [toggle]
    local right = new("Frame", {
        Parent=row,
        Size=UDim2.new(0,96,1,0),
        Position=UDim2.new(1,-96,0,0),
        BackgroundTransparency=1,
    })
    HList(right, 6, Enum.HorizontalAlignment.Right)

    -- No Bind pill
    local keyPill = new("TextButton", {
        Parent=right,
        Size=UDim2.new(0,52,0,20),
        BackgroundColor3=C.KeyBg,
        Text="No Bind", TextSize=10,
        TextColor3=C.TextMuted, Font=Enum.Font.Gotham,
        AutoButtonColor=false,
    })
    Corner(keyPill, 3)
    Stroke(keyPill, C.Border)

    -- toggle pill
    local TW, TH = 36, 18
    local track = new("Frame", {
        Parent=right,
        Size=UDim2.new(0,TW,0,TH),
        BackgroundColor3=default and C.ToggleOn or C.ToggleOff,
    })
    Corner(track, 99)

    local KS = TH - 6
    local knob = new("Frame", {
        Parent=track,
        Size=UDim2.new(0,KS,0,KS),
        Position=default and UDim2.new(1,-(KS+3),0.5,-KS/2) or UDim2.new(0,3,0.5,-KS/2),
        BackgroundColor3=C.White,
    })
    Corner(knob, 99)

    -- state
    local obj = {Value=default, _cbs={}, _keyBind=nil}
    local listening = false

    local function set(v, silent)
        obj.Value = v
        tw(track, {BackgroundColor3 = v and C.ToggleOn or C.ToggleOff})
        tw(knob,  {Position = v and UDim2.new(1,-(KS+3),0.5,-KS/2) or UDim2.new(0,3,0.5,-KS/2)})
        if not silent then for _,f in ipairs(obj._cbs) do f() end end
    end

    function obj:OnChanged(f) table.insert(self._cbs,f) end
    function obj:SetValue(v)  set(v) end
    getgenv().Toggles[idx] = obj

    -- click toggle
    new("TextButton",{Parent=track,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5})
        .MouseButton1Click:Connect(function() set(not obj.Value) end)

    -- keybind
    keyPill.MouseButton1Click:Connect(function()
        listening = true; keyPill.Text = "..."; keyPill.TextColor3 = C.Accent
    end)
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if listening then
            listening = false
            local nm = i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name
                or i.UserInputType == Enum.UserInputType.MouseButton2 and "MB2" or nil
            if nm then
                obj._keyBind = nm
                keyPill.Text = nm
                keyPill.TextColor3 = C.TextSub
            end
            return
        end
        if obj._keyBind then
            local nm = i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name
                or i.UserInputType == Enum.UserInputType.MouseButton2 and "MB2" or nil
            if nm == obj._keyBind then set(not obj.Value) end
        end
    end)

    return obj
end

-- ─── Slider  (igual Arox: ícone barra | label       val/max + track) ──
function Section:AddSlider(idx, info)
    info = info or {}
    local text     = info.Text     or idx
    local min      = info.Min      or 0
    local max      = info.Max      or 100
    local default  = math.clamp(info.Default or min, min, max)
    local rounding = info.Rounding or 0
    local suffix   = info.Suffix   or ""

    local wrap = new("Frame", {
        Parent=self._list,
        Size=UDim2.new(1,0,0,38),
        BackgroundTransparency=1,
    })

    -- linha superior: ícone + label + valor
    local topRow = new("Frame", {
        Parent=wrap,
        Size=UDim2.new(1,0,0,16),
        BackgroundTransparency=1,
    })

    -- ícone "▐▐" igual ao arox (barrinhas de gráfico)
    new("TextLabel", {
        Parent=topRow,
        Size=UDim2.new(0,14,1,0),
        BackgroundTransparency=1,
        Text="lll", TextSize=9,
        TextColor3=C.TextMuted, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
    })

    new("TextLabel", {
        Parent=topRow,
        Size=UDim2.new(1,-70,1,0),
        Position=UDim2.new(0,16,0,0),
        BackgroundTransparency=1,
        Text=text, TextSize=12,
        TextColor3=C.Text, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
    })

    -- valor "265/415" — bold antes da barra, muted depois
    local valFrame = new("Frame", {
        Parent=topRow,
        Size=UDim2.new(0,54,1,0),
        Position=UDim2.new(1,-54,0,0),
        BackgroundTransparency=1,
    })

    local valLbl = new("TextLabel", {
        Parent=valFrame,
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=tostring(default).."/"..tostring(max),
        TextSize=11,
        TextColor3=C.TextSub, Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Right,
    })

    -- track
    local track = new("Frame", {
        Parent=wrap,
        Size=UDim2.new(1,0,0,2),
        Position=UDim2.new(0,0,0,22),
        BackgroundColor3=C.SliderTrack,
    })
    Corner(track, 99)

    local fill = new("Frame", {
        Parent=track,
        Size=UDim2.new((default-min)/(max-min),0,1,0),
        BackgroundColor3=C.SliderFill,
    })
    Corner(fill, 99)

    -- knob pequeno (igual arox, discreto)
    local KR = 5
    local knob = new("Frame", {
        Parent=track,
        Size=UDim2.new(0,KR*2,0,KR*2),
        Position=UDim2.new((default-min)/(max-min),-KR,0.5,-KR),
        BackgroundColor3=C.SliderKnob,
        ZIndex=3,
    })
    Corner(knob, 99)

    local obj = {Value=default, _cbs={}}
    local function rnd(n) local m=10^rounding; return math.floor(n*m+.5)/m end

    local function setVal(val, silent)
        val = rnd(math.clamp(val, min, max))
        obj.Value = val
        local pct = (val-min)/(max-min)
        fill.Size = UDim2.new(pct,0,1,0)
        knob.Position = UDim2.new(pct,-KR,0.5,-KR)
        valLbl.Text = tostring(val)..suffix.."/"..tostring(max)
        if not silent then for _,f in ipairs(obj._cbs) do f() end end
    end

    function obj:OnChanged(f) table.insert(self._cbs,f) end
    function obj:SetValue(v)  setVal(v) end
    getgenv().Options[idx] = obj

    local dragging = false
    local function calcV(x)
        return min + math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1) * (max-min)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setVal(calcV(i.Position.X)) end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setVal(calcV(i.Position.X)) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    return obj
end

-- ─── Button ───────────────────────────────────────────────
function Section:AddButton(text, callback)
    local btn = new("TextButton", {
        Parent=self._list,
        Size=UDim2.new(1,0,0,26),
        BackgroundColor3=C.KeyBg,
        Text="", AutoButtonColor=false,
    })
    Corner(btn,4); Stroke(btn,C.Border)

    new("TextLabel", {
        Parent=btn,
        Size=UDim2.new(1,-16,1,0),
        Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,
        Text=text, TextSize=12,
        TextColor3=C.Text, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
    })

    btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=C.TabActive}) end)
    btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=C.KeyBg}) end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    local o = {_btn=btn, _sec=self}
    function o:AddButton(t2,c2) return self._sec:AddButton(t2,c2) end
    return o
end

-- ─── Input ────────────────────────────────────────────────
function Section:AddInput(idx, info)
    info = info or {}
    local text        = info.Text        or idx
    local default     = info.Default     or ""
    local placeholder = info.Placeholder or ""
    local numeric     = info.Numeric     or false
    local finished    = info.Finished    or false

    local wrap = new("Frame",{Parent=self._list,Size=UDim2.new(1,0,0,44),BackgroundTransparency=1})
    new("TextLabel",{Parent=wrap,Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=text,TextSize=10,TextColor3=C.TextMuted,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left})

    local box = new("TextBox",{
        Parent=wrap,Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,16),
        BackgroundColor3=C.KeyBg,Text=default,PlaceholderText=placeholder,
        TextColor3=C.Text,PlaceholderColor3=C.TextMuted,
        Font=Enum.Font.Gotham,TextSize=12,ClearTextOnFocus=false,
        TextXAlignment=Enum.TextXAlignment.Left,
    })
    Corner(box,4); Pad(box,8,8,0,0)
    local bs = Stroke(box,C.Border)
    box.Focused:Connect(function() tw(bs,{Color=C.Accent}) end)
    box.FocusLost:Connect(function() tw(bs,{Color=C.Border}) end)

    local obj = {Value=default,_cbs={}}
    local function fire() for _,f in ipairs(obj._cbs) do f() end end

    if finished then
        box.FocusLost:Connect(function(enter)
            if enter then
                if numeric then local n=tonumber(box.Text); box.Text=n and tostring(n) or obj.Value end
                obj.Value=box.Text; fire()
            end
        end)
    else
        box:GetPropertyChangedSignal("Text"):Connect(function()
            if numeric and box.Text~="" and not tonumber(box.Text) then box.Text=obj.Value; return end
            obj.Value=box.Text; fire()
        end)
    end

    function obj:OnChanged(f) table.insert(self._cbs,f) end
    function obj:SetValue(v) box.Text=tostring(v); obj.Value=tostring(v) end
    getgenv().Options[idx]=obj
    return obj
end

-- ─── Dropdown ─────────────────────────────────────────────
function Section:AddDropdown(idx, info)
    info=info or {}
    local text=info.Text or idx
    local values=info.Values or {}
    local multi=info.Multi or false
    local defVal=type(info.Default)=="string" and info.Default or (values[info.Default or 1] or "")

    local container=new("Frame",{Parent=self._list,Size=UDim2.new(1,0,0,42),BackgroundTransparency=1,ClipsDescendants=false,ZIndex=10})
    new("TextLabel",{Parent=container,Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=text,TextSize=10,TextColor3=C.TextMuted,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10})

    local header=new("TextButton",{Parent=container,Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,16),BackgroundColor3=C.KeyBg,Text="",AutoButtonColor=false,ZIndex=10})
    Corner(header,4); local hs=Stroke(header,C.Border)
    local selLbl=new("TextLabel",{Parent=header,Size=UDim2.new(1,-22,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Text=multi and "Select..." or defVal,TextSize=11,TextColor3=C.Text,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10})
    local arrow=new("TextLabel",{Parent=header,Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-20,0,0),BackgroundTransparency=1,Text="▾",TextSize=11,TextColor3=C.TextMuted,Font=Enum.Font.Gotham,ZIndex=10})

    local listF=new("Frame",{Parent=container,Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,42),BackgroundColor3=Color3.fromRGB(18,18,22),ClipsDescendants=true,ZIndex=20,Visible=false})
    Corner(listF,4); Stroke(listF,C.Border); Pad(listF,4,4,4,4); VList(listF,2)

    local obj={Value=multi and {} or defVal,_cbs={}}
    local isOpen=false
    local function updLbl()
        if multi then local s={}; for k,v in pairs(obj.Value) do if v then table.insert(s,k) end end; selLbl.Text=#s>0 and table.concat(s,", ") or "Select..." else selLbl.Text=obj.Value end
    end
    local function close()
        isOpen=false; tw(listF,{Size=UDim2.new(1,0,0,0)},.12); task.delay(.12,function() listF.Visible=false end)
        tw(arrow,{TextColor3=C.TextMuted}); tw(hs,{Color=C.Border}); container.Size=UDim2.new(1,0,0,42)
    end
    local function open()
        isOpen=true; listF.Visible=true; local h=math.min(#values*20+8,100)
        tw(listF,{Size=UDim2.new(1,0,0,h)},.12); container.Size=UDim2.new(1,0,0,42+h+4)
        tw(arrow,{TextColor3=C.Accent}); tw(hs,{Color=C.Accent})
    end
    for _,v in ipairs(values) do
        local item=new("TextButton",{Parent=listF,Size=UDim2.new(1,0,0,18),BackgroundColor3=Color3.fromRGB(18,18,22),Text="",AutoButtonColor=false,ZIndex=21})
        Corner(item,3)
        local chk=new("TextLabel",{Parent=item,Size=UDim2.new(0,14,1,0),Position=UDim2.new(0,2,0,0),BackgroundTransparency=1,Text="",TextSize=10,TextColor3=C.Accent,Font=Enum.Font.GothamBold,ZIndex=21})
        new("TextLabel",{Parent=item,Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=v,TextSize=11,TextColor3=C.Text,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=21})
        item.MouseEnter:Connect(function() tw(item,{BackgroundColor3=C.TabActive}) end)
        item.MouseLeave:Connect(function() tw(item,{BackgroundColor3=Color3.fromRGB(18,18,22)}) end)
        item.MouseButton1Click:Connect(function()
            if multi then obj.Value[v]=not obj.Value[v]; chk.Text=obj.Value[v] and "✓" or "" else obj.Value=v; close() end
            updLbl(); for _,f in ipairs(obj._cbs) do f() end
        end)
    end
    header.MouseButton1Click:Connect(function() if isOpen then close() else open() end end)
    function obj:OnChanged(f) table.insert(self._cbs,f) end
    function obj:SetValue(v) if multi then if type(v)=="table" then obj.Value=v end else obj.Value=v end; updLbl() end
    getgenv().Options[idx]=obj
    return obj
end

-- ─── KeyPicker ────────────────────────────────────────────
function Section:AddKeyPicker(idx, info)
    info=info or {}
    local text=info.Text or idx
    local default=info.Default or "F"
    local mode=info.Mode or "Toggle"

    local row=new("Frame",{Parent=self._list,Size=UDim2.new(1,0,0,26),BackgroundTransparency=1})
    new("TextLabel",{Parent=row,Size=UDim2.new(1,-68,1,0),BackgroundTransparency=1,Text=text,TextSize=12,TextColor3=C.Text,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left})
    local kBtn=new("TextButton",{Parent=row,Size=UDim2.new(0,60,0,20),Position=UDim2.new(1,-60,0.5,-10),BackgroundColor3=C.KeyBg,Text=default,TextSize=11,TextColor3=C.TextSub,Font=Enum.Font.GothamMedium,AutoButtonColor=false})
    Corner(kBtn,3); Stroke(kBtn,C.Border)

    local obj={Value=default,_cbs={},_clicking={}}
    local listening=false; local state=false
    kBtn.MouseButton1Click:Connect(function() listening=true; kBtn.Text="..."; kBtn.TextColor3=C.Accent end)
    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if listening then listening=false; if i.UserInputType==Enum.UserInputType.Keyboard then obj.Value=i.KeyCode.Name; kBtn.Text=i.KeyCode.Name; kBtn.TextColor3=C.TextSub end; return end
        if i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode.Name==obj.Value then if mode=="Toggle" then state=not state; for _,f in ipairs(obj._clicking) do f() end end end
    end)
    function obj:OnClick(f) table.insert(self._clicking,f) end
    function obj:GetState() return state end
    function obj:SetValue(v) if type(v)=="table" then obj.Value=v[1]; mode=v[2] or mode else obj.Value=v end; kBtn.Text=obj.Value end
    getgenv().Options[idx]=obj
    return obj
end

-- ─── ColorPicker ──────────────────────────────────────────
function Section:AddColorPicker(idx, info)
    info=info or {}
    local text=info.Text or idx
    local default=info.Default or Color3.new(1,1,1)
    local row=new("Frame",{Parent=self._list,Size=UDim2.new(1,0,0,26),BackgroundTransparency=1})
    new("TextLabel",{Parent=row,Size=UDim2.new(1,-44,1,0),BackgroundTransparency=1,Text=text,TextSize=12,TextColor3=C.Text,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left})
    local preview=new("TextButton",{Parent=row,Size=UDim2.new(0,34,0,18),Position=UDim2.new(1,-34,0.5,-9),BackgroundColor3=default,Text="",AutoButtonColor=false})
    Corner(preview,4); Stroke(preview,C.Border)
    local obj={Value=default,_cbs={}}
    local h,s,v2=Color3.toHSV(default)
    local open=false
    local picker=new("Frame",{Parent=row,Size=UDim2.new(0,150,0,0),Position=UDim2.new(1,-156,1,4),BackgroundColor3=Color3.fromRGB(18,18,22),ClipsDescendants=true,ZIndex=30,Visible=false})
    Corner(picker,6); Stroke(picker,C.Border); Pad(picker,6,6,6,6)
    local hueBar=new("Frame",{Parent=picker,Size=UDim2.new(1,0,0,10),BackgroundColor3=Color3.fromRGB(255,0,0),ZIndex=31})
    Corner(hueBar,3)
    new("UIGradient",{Parent=hueBar,Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(0.50,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})})
    local function apply() local col=Color3.fromHSV(h,s,v2); preview.BackgroundColor3=col; obj.Value=col; for _,f in ipairs(obj._cbs) do f() end end
    local dh=false
    hueBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=true; h=math.clamp((i.Position.X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1); apply() end end)
    UIS.InputChanged:Connect(function(i) if dh and i.UserInputType==Enum.UserInputType.MouseMovement then h=math.clamp((i.Position.X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1); apply() end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=false end end)
    preview.MouseButton1Click:Connect(function()
        open=not open; picker.Visible=open; tw(picker,{Size=UDim2.new(0,150,0,open and 30 or 0)},.14)
    end)
    function obj:OnChanged(f) table.insert(self._cbs,f) end
    function obj:SetValueRGB(col) obj.Value=col; preview.BackgroundColor3=col; h,s,v2=Color3.toHSV(col) end
    getgenv().Options[idx]=obj
    return obj
end

-- ─── Label / Divider ──────────────────────────────────────
function Section:AddLabel(text)
    new("TextLabel",{Parent=self._list,Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,Text=text,TextSize=11,TextColor3=C.TextMuted,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left})
end
function Section:AddDivider()
    new("Frame",{Parent=self._list,Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Border,BorderSizePixel=0})
end

-- ════════════════════════════════════════════════════════
--  TAB  (lado direito)
-- ════════════════════════════════════════════════════════
local Tab = {}
Tab.__index = Tab

function Tab:AddSection(title)
    local ord = self._order or 0

    -- section header label (igual arox: texto pequeno muted, SEM fundo)
    if title and title ~= "" then
        local hdr = new("TextLabel", {
            Parent=self._scroll,
            Size=UDim2.new(1,0,0,26),
            BackgroundTransparency=1,
            Text=title, TextSize=10,
            TextColor3=C.TextMuted, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            LayoutOrder=ord,
        })
        self._order = ord + 1
    end

    local wrap = new("Frame", {
        Parent=self._scroll,
        Size=UDim2.new(1,0,0,0),
        BackgroundTransparency=1,
        AutomaticSize=Enum.AutomaticSize.Y,
        LayoutOrder=self._order,
    })
    self._order = (self._order or 0) + 1
    VList(wrap, 2)

    return setmetatable({_list=wrap}, Section)
end

-- ════════════════════════════════════════════════════════
--  WINDOW
-- ════════════════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window:AddTab(name, icon)
    icon = icon or ""
    local idx = #self._tabs + 1

    -- botão na sidebar esquerda
    local btn = new("TextButton", {
        Parent=self._tabList,
        Size=UDim2.new(1,0,0,28),
        BackgroundColor3=Color3.fromRGB(0,0,0),
        Text="", AutoButtonColor=false,
        LayoutOrder=idx,
    })
    Corner(btn, 4)

    -- ícone
    new("TextLabel", {
        Parent=btn,
        Size=UDim2.new(0,20,1,0),
        Position=UDim2.new(0,6,0,0),
        BackgroundTransparency=1,
        Text=icon, TextSize=13,
        TextColor3=C.TextMuted, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Center,
    })

    local nameLbl = new("TextLabel", {
        Parent=btn,
        Size=UDim2.new(1,-30,1,0),
        Position=UDim2.new(0,28,0,0),
        BackgroundTransparency=1,
        Text=name, TextSize=12,
        TextColor3=C.TextMuted, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
    })

    -- frame de conteúdo
    local tabFrame = new("Frame", {
        Parent=self._contentArea,
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Visible=false,
    })

    local scroll = SF(tabFrame)
    VList(scroll, 2)
    Pad(scroll, 14, 14, 10, 10)

    local tabObj = setmetatable({_scroll=scroll, _order=0}, Tab)
    table.insert(self._tabs, {btn=btn, name=nameLbl, frame=tabFrame})

    btn.MouseButton1Click:Connect(function() self:_sel(idx) end)
    btn.MouseEnter:Connect(function()
        if self._active ~= idx then tw(btn,{BackgroundColor3=C.TabHover}) end
    end)
    btn.MouseLeave:Connect(function()
        if self._active ~= idx then tw(btn,{BackgroundColor3=Color3.fromRGB(0,0,0)}) end
    end)

    if #self._tabs == 1 then self:_sel(1) end
    return tabObj
end

function Window:_sel(idx)
    for i, t in ipairs(self._tabs) do
        local a = (i == idx)
        t.frame.Visible = a
        tw(t.btn,  {BackgroundColor3 = a and C.TabActive or Color3.fromRGB(0,0,0)})
        tw(t.name, {TextColor3 = a and C.Text or C.TextMuted})
    end
    self._active = idx
end

function Window:Unload()
    if self._gui then self._gui:Destroy() end
    NexusHub.Unloaded = true
    if self._unloadFn then self._unloadFn() end
end
function Window:OnUnload(f) self._unloadFn = f end

-- ════════════════════════════════════════════════════════
--  CreateWindow
-- ════════════════════════════════════════════════════════
function NexusHub:CreateWindow(opts)
    opts = opts or {}

    -- dimensões (iguais à referência Arox)
    local W     = opts.Width  or 540
    local H     = opts.Height or 480

    -- títulos
    local title    = opts.Title    or "Hub"          -- ex: "Arox"
    local subtitle = opts.Subtitle or "v1.0"          -- ex: "v1.0 Rewrite"
    local gameTag  = opts.Game     or ""              -- ex: "Deepwoken" (label de grupo)

    -- top-right icons (lista de strings, ex: {"🔍","🔔"})
    local topIcons = opts.TopIcons or {"🔍","🔔","●●●●"}

    local show   = opts.AutoShow ~= false
    local center = opts.Center   ~= false

    local pGui = PL.LocalPlayer:WaitForChild("PlayerGui")
    local gui  = new("ScreenGui", {
        Parent=pGui, Name="NexusHub",
        ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    })

    local pos = center and UDim2.new(.5,-W/2,.5,-H/2)
        or (opts.Position or UDim2.new(.1,0,.1,0))

    -- janela principal
    local main = new("Frame", {
        Parent=gui,
        Size=UDim2.new(0,W,0,H),
        Position=pos,
        BackgroundColor3=C.BgWindow,
        Visible=show,
    })
    Corner(main, 8)
    Stroke(main, C.Border)

    -- ── BARRA DE TÍTULO (topo) ─────────────────────────
    -- No Arox: sem barra separada visível — só o subtitle
    -- pequeno no canto superior dir + ícones
    local TOPBAR_H = 30
    local topBar = new("Frame", {
        Parent=main,
        Size=UDim2.new(1,0,0,TOPBAR_H),
        BackgroundColor3=C.BgWindow,
    })
    -- linha divisória embaixo do topbar
    new("Frame",{Parent=topBar,Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.Border,BorderSizePixel=0})

    -- subtitle (canto sup esquerdo, na área de conteúdo)
    new("TextLabel", {
        Parent=topBar,
        Size=UDim2.new(0,200,1,0),
        Position=UDim2.new(0,10,0,0),   -- será ajustado após sidebar
        BackgroundTransparency=1,
        Text=subtitle, TextSize=10,
        TextColor3=C.TextMuted, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
    })

    -- ícones topo direito
    local iconsFrame = new("Frame", {
        Parent=topBar,
        Size=UDim2.new(0,120,1,0),
        Position=UDim2.new(1,-124,0,0),
        BackgroundTransparency=1,
    })
    HList(iconsFrame, 6, Enum.HorizontalAlignment.Right)
    for _, ic in ipairs(topIcons) do
        new("TextLabel", {
            Parent=iconsFrame,
            Size=UDim2.new(0,20,1,0),
            BackgroundTransparency=1,
            Text=ic, TextSize=11,
            TextColor3=C.TextMuted, Font=Enum.Font.Gotham,
        })
    end

    -- drag pela topbar
    local drg,dS,dP = false,nil,nil
    topBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drg=true;dS=i.Position;dP=main.Position end
    end)
    UIS.InputChanged:Connect(function(i)
        if drg and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-dS
            main.Position=UDim2.new(dP.X.Scale,dP.X.Offset+d.X,dP.Y.Scale,dP.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drg=false end
    end)

    -- ── CORPO (abaixo da topbar) ───────────────────────
    local body = new("Frame", {
        Parent=main,
        Size=UDim2.new(1,0,1,-TOPBAR_H),
        Position=UDim2.new(0,0,0,TOPBAR_H),
        BackgroundTransparency=1,
        ClipsDescendants=true,
    })

    -- ── SIDEBAR ESQUERDA ──────────────────────────────
    -- Arox: ~165px, fundo preto, título do hub em cima,
    -- depois um grupo label ("Deepwoken") + tabs com ícone+nome,
    -- depois outro grupo ("UI Settings") + tabs
    local SW = 165

    local sidebar = new("Frame", {
        Parent=body,
        Size=UDim2.new(0,SW,1,0),
        BackgroundColor3=C.BgSidebar,
    })
    -- linha divisória direita da sidebar
    new("Frame",{Parent=sidebar,Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=C.Border,BorderSizePixel=0})

    -- Título do hub (ex: "Arox")
    local titleLbl = new("TextLabel", {
        Parent=sidebar,
        Size=UDim2.new(1,0,0,40),
        BackgroundTransparency=1,
        Text=title, TextSize=18,
        TextColor3=C.Text, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
    })
    Pad(titleLbl, 12, 12, 0, 0)

    -- scroll da sidebar (tabs)
    local sideScroll = SF(sidebar, UDim2.new(1,0,1,-46), UDim2.new(0,0,0,44))
    sideScroll.ScrollBarThickness = 0

    local sideContent = new("Frame", {
        Parent=sideScroll,
        Size=UDim2.new(1,0,0,0),
        BackgroundTransparency=1,
        AutomaticSize=Enum.AutomaticSize.Y,
    })
    VList(sideContent, 2)
    Pad(sideContent, 6, 6, 4, 4)

    -- helper: adicionar group label na sidebar (ex: "Deepwoken")
    local function sideGroupLabel(text)
        new("TextLabel", {
            Parent=sideContent,
            Size=UDim2.new(1,0,0,22),
            BackgroundTransparency=1,
            Text=text, TextSize=10,
            TextColor3=C.TextMuted, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
        })
    end

    -- bottom da sidebar: avatar/settings
    local sideBottom = new("Frame",{
        Parent=sidebar,
        Size=UDim2.new(1,0,0,36),
        Position=UDim2.new(0,0,1,-36),
        BackgroundTransparency=1,
    })
    local avatarBox=new("Frame",{Parent=sideBottom,Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,8,0.5,-12),BackgroundColor3=C.Accent})
    Corner(avatarBox,4)
    new("TextLabel",{Parent=avatarBox,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="☻",TextSize=14,TextColor3=C.White,Font=Enum.Font.GothamBold})
    new("Frame",{Parent=sideBottom,Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Border,BorderSizePixel=0})

    -- ── ÁREA DE CONTEÚDO (direita) ────────────────────
    local contentArea = new("Frame", {
        Parent=body,
        Size=UDim2.new(1,-SW,1,0),
        Position=UDim2.new(0,SW,0,0),
        BackgroundColor3=C.BgContent,
        ClipsDescendants=true,
    })

    -- ── BUILD WINDOW OBJ ──────────────────────────────
    local win = setmetatable({
        _gui=gui, _main=main,
        _tabList=sideContent,
        _contentArea=contentArea,
        _tabs={}, _active=0,
        _sideGroupLabel=sideGroupLabel,
    }, Window)

    return win
end

-- helper exposto: adicionar group label na sidebar
function Window:AddGroupLabel(text)
    self._sideGroupLabel(text)
end

return NexusHub
