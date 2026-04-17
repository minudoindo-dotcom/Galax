--[[
    ██████╗  █████╗ ██╗      █████╗ ██╗  ██╗    ██╗   ██╗██╗
    ██╔════╝ ██╔══██╗██║     ██╔══██╗╚██╗██╔╝    ██║   ██║██║
    ██║  ███╗███████║██║     ███████║ ╚███╔╝     ██║   ██║██║
    ██║   ██║██╔══██║██║     ██╔══██║ ██╔██╗     ██║   ██║██║
    ╚██████╔╝██║  ██║███████╗██║  ██║██╔╝ ██╗    ╚██████╔╝██║
     ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚═╝

    GalaxUI v3.0 — External UI Library for Matcha LuaVM
    Sidebar-based, dark-blue identity, fully modular.

    USAGE:
    local GalaxUI = loadstring(game:HttpGet("url"))()
    local win = GalaxUI:CreateWindow({ Title="My Hub", MenuKey=0x2D })
    local page = win:AddPage("Combat")
    local left = page:AddSection("Aimbot", 1)
    left:AddToggle("Enable", true, function(v) end, 0x56, "Toggle aim")
    left:AddSlider("FOV", {Min=30,Max=180,Default=90,Suffix="°"}, function(v) end)
    left:AddKeybind("Key", 0x46, function(kc) end)
    left:AddDropdown("Bone", {"Head","Neck"}, "Head", function(v) end)
    left:AddColorPicker("Color", Color3.fromRGB(10,132,255), function(c) end)
    left:AddButton("Reset", function() end)
    left:AddProgressBar("HP", {Value=87,Max=100})
    left:AddSeparator("Advanced")
    left:AddGroupbox("Extra"):AddToggle("Sub", false, function(v) end)
    win:Notify("Loaded!", "Hub", 3)
]]--

local GalaxUI = {}
GalaxUI.Updates = {}

-- ══════════════════════════════════════════════════════════════
--  1. SUPPORTERS
-- ══════════════════════════════════════════════════════════════
local _Supporters = {
    { text = "[Diamond] Akemi - $17.99",             color = Color3.fromRGB(160, 210, 255) },
    { text = "[Diamond] Corey - 1K",                 color = Color3.fromRGB(160, 210, 255) },
    { text = "[Diamond] Anis3504 - 1K",              color = Color3.fromRGB(160, 210, 255) },
    { text = "[Gold] erdene - 500",                  color = Color3.fromRGB(255, 200, 50)  },
    { text = "[Gold] infinite - Dev 500",            color = Color3.fromRGB(255, 200, 50)  },
    { text = "[Silver] Shelovedami - 300",           color = Color3.fromRGB(200, 200, 210) },
    { text = "[Bronze] Nullxietys - 100",            color = Color3.fromRGB(200, 140, 90)  },
    { text = "[Bronze] _swishh. - 100",              color = Color3.fromRGB(200, 140, 90)  },
}

-- ══════════════════════════════════════════════════════════════
--  2. UTILITIES
-- ══════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

local function clamp(x,a,b) return x<a and a or (x>b and b or x) end
local function lerp(a,b,t) return a+(b-a)*t end
local function lerpC(c1,c2,t) return Color3.new(lerp(c1.R,c2.R,t),lerp(c1.G,c2.G,t),lerp(c1.B,c2.B,t)) end
local function easeOut(t) return 1-(1-clamp(t,0,1))^3 end
local function tintColor(base,accent,amount)
    return Color3.new(
        clamp(base.R+(accent.R-base.R)*amount,0,1),
        clamp(base.G+(accent.G-base.G)*amount,0,1),
        clamp(base.B+(accent.B-base.B)*amount,0,1))
end
local function hsvToRgb(h,s,v)
    if s==0 then return Color3.new(v,v,v) end
    local i=math.floor(h*6); local f=h*6-i
    local p,q,r2=v*(1-s),v*(1-f*s),v*(1-(1-f)*s); i=i%6
    if i==0 then return Color3.new(v,r2,p) elseif i==1 then return Color3.new(q,v,p)
    elseif i==2 then return Color3.new(p,v,r2) elseif i==3 then return Color3.new(p,q,v)
    elseif i==4 then return Color3.new(r2,p,v) else return Color3.new(v,p,q) end
end
local function rgbToHsv(c)
    local r,g,b=c.R,c.G,c.B; local mx=math.max(r,g,b); local mn=math.min(r,g,b); local d=mx-mn; local h=0
    if d~=0 then
        if mx==r then h=((g-b)/d)%6 elseif mx==g then h=(b-r)/d+2 else h=(r-g)/d+4 end; h=h/6
    end
    return h, mx==0 and 0 or d/mx, mx
end
local function wrapText(str,maxW,sz)
    local cw=(sz or 13)*0.54; local mc=math.max(1,math.floor(maxW/cw)); local lines={}
    local rem=str
    while #rem>0 do
        if #rem<=mc then table.insert(lines,rem); break end
        local cut=mc; local sp=rem:sub(1,cut):match(".*()%s")
        if sp and sp>1 then cut=sp-1 end
        table.insert(lines,rem:sub(1,cut)); rem=rem:sub(cut+1):match("^%s*(.*)") or ""
    end; return lines
end
local function mpos() return Vector2.new(mouse.X, mouse.Y) end
local function over(pos,size) local m=mpos(); return m.X>=pos.X and m.X<=pos.X+size.X and m.Y>=pos.Y and m.Y<=pos.Y+size.Y end
local function getScreen() local cam=workspace.CurrentCamera; return (cam and cam.ViewportSize) and cam.ViewportSize or Vector2.new(1920,1080) end

-- ══════════════════════════════════════════════════════════════
--  3. THEMES — Galax identity with accent tinting
-- ══════════════════════════════════════════════════════════════
local Themes = {
    Galax = {
        bg=Color3.fromRGB(8,8,16), topbar=Color3.fromRGB(13,13,22), sidebar=Color3.fromRGB(10,10,20),
        section=Color3.fromRGB(15,15,26), accent=Color3.fromRGB(10,132,255),
        border=Color3.fromRGB(28,28,44), border2=Color3.fromRGB(52,52,75),
        text=Color3.fromRGB(235,235,240), sub=Color3.fromRGB(108,108,120),
        danger=Color3.fromRGB(255,69,58), success=Color3.fromRGB(48,209,88),
    },
    Gamesense = {
        bg=Color3.fromRGB(0,0,0), topbar=Color3.fromRGB(16,16,16), sidebar=Color3.fromRGB(8,8,8),
        section=Color3.fromRGB(20,20,20), accent=Color3.fromRGB(114,178,21),
        border=Color3.fromRGB(36,36,36), border2=Color3.fromRGB(55,55,55),
        text=Color3.fromRGB(144,144,144), sub=Color3.fromRGB(59,59,59),
        danger=Color3.fromRGB(220,70,70), success=Color3.fromRGB(80,200,60),
    },
    Dracula = {
        bg=Color3.fromRGB(24,25,38), topbar=Color3.fromRGB(30,31,46), sidebar=Color3.fromRGB(26,27,40),
        section=Color3.fromRGB(33,34,50), accent=Color3.fromRGB(189,147,249),
        border=Color3.fromRGB(60,62,80), border2=Color3.fromRGB(80,82,106),
        text=Color3.fromRGB(248,248,242), sub=Color3.fromRGB(98,114,164),
        danger=Color3.fromRGB(255,85,85), success=Color3.fromRGB(80,250,123),
    },
    Nord = {
        bg=Color3.fromRGB(29,33,40), topbar=Color3.fromRGB(34,38,46), sidebar=Color3.fromRGB(31,35,42),
        section=Color3.fromRGB(36,41,50), accent=Color3.fromRGB(136,192,208),
        border=Color3.fromRGB(52,58,72), border2=Color3.fromRGB(68,76,96),
        text=Color3.fromRGB(236,239,244), sub=Color3.fromRGB(129,161,193),
        danger=Color3.fromRGB(191,97,106), success=Color3.fromRGB(163,190,140),
    },
    Catppuccin = {
        bg=Color3.fromRGB(24,24,37), topbar=Color3.fromRGB(28,28,42), sidebar=Color3.fromRGB(26,26,39),
        section=Color3.fromRGB(30,30,46), accent=Color3.fromRGB(137,180,250),
        border=Color3.fromRGB(68,71,90), border2=Color3.fromRGB(88,91,112),
        text=Color3.fromRGB(205,214,244), sub=Color3.fromRGB(166,173,200),
        danger=Color3.fromRGB(243,139,168), success=Color3.fromRGB(166,227,161),
    },
    Synthwave = {
        bg=Color3.fromRGB(15,5,30), topbar=Color3.fromRGB(20,8,38), sidebar=Color3.fromRGB(17,6,34),
        section=Color3.fromRGB(25,10,45), accent=Color3.fromRGB(255,60,180),
        border=Color3.fromRGB(60,25,80), border2=Color3.fromRGB(90,40,110),
        text=Color3.fromRGB(255,220,255), sub=Color3.fromRGB(180,120,200),
        danger=Color3.fromRGB(255,80,80), success=Color3.fromRGB(100,255,160),
    },
    Sunset = {
        bg=Color3.fromRGB(18,8,5), topbar=Color3.fromRGB(24,12,8), sidebar=Color3.fromRGB(20,10,6),
        section=Color3.fromRGB(30,14,8), accent=Color3.fromRGB(255,120,40),
        border=Color3.fromRGB(60,30,15), border2=Color3.fromRGB(90,50,25),
        text=Color3.fromRGB(255,235,210), sub=Color3.fromRGB(180,130,90),
        danger=Color3.fromRGB(255,70,50), success=Color3.fromRGB(100,200,80),
    },
}
local C = {}; for k,v in pairs(Themes.Galax) do C[k]=v end
local CT = {} -- tinted colors
local function updateTint()
    CT.bg      = tintColor(C.bg,      C.accent, 0.06)
    CT.topbar  = tintColor(C.topbar,  C.accent, 0.07)
    CT.sidebar = tintColor(C.sidebar, C.accent, 0.06)
    CT.section = tintColor(C.section, C.accent, 0.08)
    CT.border  = tintColor(C.border,  C.accent, 0.05)
    CT.border2 = tintColor(C.border2, C.accent, 0.04)
    CT.accent  = C.accent; CT.text = C.text; CT.sub = C.sub
    CT.danger  = C.danger; CT.success = C.success
end; updateTint()

local ThemeNames = {"Galax","Gamesense","Dracula","Nord","Catppuccin","Synthwave","Sunset"}
local function applyTheme(name) local src=Themes[name]; if not src then return end; for k,v in pairs(src) do C[k]=v end; updateTint() end

-- ══════════════════════════════════════════════════════════════
--  4. FONTS & KEY NAMES
-- ══════════════════════════════════════════════════════════════
local F_REG=Drawing.Fonts.System; local F_BOLD=Drawing.Fonts.SystemBold; local F_MONO=Drawing.Fonts.Monospace
local FontNames={"System","SystemBold","UI","Monospace","Minecraft","Pixel","Fortnite"}
local FontMap={System=Drawing.Fonts.System,SystemBold=Drawing.Fonts.SystemBold,UI=Drawing.Fonts.UI,Monospace=Drawing.Fonts.Monospace,Minecraft=Drawing.Fonts.Minecraft,Pixel=Drawing.Fonts.Pixel,Fortnite=Drawing.Fonts.Fortnite}
local CurFont = F_REG
local function applyFont(n) if FontMap[n] then CurFont=FontMap[n]; F_REG=CurFont end end
local FWF={[Drawing.Fonts.System]=0.60,[Drawing.Fonts.SystemBold]=0.63,[Drawing.Fonts.UI]=0.54,[Drawing.Fonts.Monospace]=0.62,[Drawing.Fonts.Minecraft]=0.60,[Drawing.Fonts.Pixel]=0.54,[Drawing.Fonts.Fortnite]=0.58}
local function textW(s,sz) return #(s or "")*(sz or 12)*(FWF[CurFont] or 0.60) end

local KeyNames={}
do
    local r={[0x08]="BACK",[0x09]="TAB",[0x0D]="ENTER",[0x10]="SHIFT",[0x11]="CTRL",[0x12]="ALT",[0x14]="CAPS",[0x1B]="ESC",[0x20]="SPACE",
        [0x21]="PGUP",[0x22]="PGDN",[0x23]="END",[0x24]="HOME",[0x25]="LEFT",[0x26]="UP",[0x27]="RIGHT",[0x28]="DOWN",[0x2D]="INS",[0x2E]="DEL",
        [0xBA]=";",[0xBB]="=",[0xBC]=",",[0xBD]="-",[0xBE]=".",[0xBF]="/",[0xC0]="`",[0xDB]="[",[0xDC]="\\",[0xDD]="]",[0xDE]="'"}
    for k,v in pairs(r) do KeyNames[k]=v end
    for i=65,90 do KeyNames[i]=string.char(i) end
    for i=0,9  do KeyNames[0x30+i]=tostring(i) end
    for i=1,12 do KeyNames[0x6F+i]="F"..i end
end
local function keyName(kc) return KeyNames[kc] or ("0x"..string.format("%X",kc or 0)) end

-- ══════════════════════════════════════════════════════════════
--  5. INPUT SYSTEM
-- ══════════════════════════════════════════════════════════════
local Input={_prev={},click=false,held=false,rclick=false}
function Input:update()
    local m1=ismouse1pressed(); local m2=ismouse2pressed()
    self.click=m1 and not(self._prev.m1 or false); self.held=m1
    self.rclick=m2 and not(self._prev.m2 or false)
    self._prev.m1=m1; self._prev.m2=m2
end
function Input:keyClick(kc)
    local cur=iskeypressed(kc); local prv=self._prev[kc] or false
    self._prev[kc]=cur; return cur and not prv
end
function Input:keyHeld(kc) return iskeypressed(kc) end

-- ══════════════════════════════════════════════════════════════
--  6. NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════
local _notifList={}
local function GalaxNotify(title,text,duration)
    duration=duration or 3
    task.spawn(function()
        local NW,NH=260,56; local id={}
        local dBg=Drawing.new("Square"); local dGlow=Drawing.new("Square")
        local dAccL=Drawing.new("Square"); local dPBg=Drawing.new("Square")
        local dPFill=Drawing.new("Square"); local dTitle=Drawing.new("Text"); local dBody=Drawing.new("Text")
        dBg.Filled=true; dBg.Corner=10; dBg.ZIndex=2000
        dGlow.Filled=false; dGlow.Corner=10; dGlow.ZIndex=2001; dGlow.Transparency=0.6
        dAccL.Filled=true; dAccL.Corner=2; dAccL.ZIndex=2002
        dPBg.Filled=true; dPBg.Corner=2; dPBg.ZIndex=2001; dPBg.Color=Color3.fromRGB(25,25,40)
        dPFill.Filled=true; dPFill.Corner=2; dPFill.ZIndex=2002
        dTitle.Font=F_BOLD; dTitle.Size=13; dTitle.ZIndex=2003; dTitle.Outline=false; dTitle.Text=tostring(title)
        dBody.Font=F_REG; dBody.Size=11; dBody.ZIndex=2003; dBody.Outline=false; dBody.Color=Color3.fromRGB(160,160,180); dBody.Text=tostring(text)
        local function showAll(v) dBg.Visible=v; dGlow.Visible=v; dAccL.Visible=v; dPBg.Visible=v; dPFill.Visible=v; dTitle.Visible=v; dBody.Visible=v end
        showAll(false); table.insert(_notifList,{id=id})
        local function getIdx() for i,v in ipairs(_notifList) do if v.id==id then return i end end; return 1 end
        local function setPos(cy)
            local scr=getScreen(); local cx=scr.X/2-NW/2
            dBg.Color=CT.bg; dBg.Size=Vector2.new(NW,NH); dBg.Position=Vector2.new(cx,cy)
            dGlow.Size=Vector2.new(NW,NH); dGlow.Position=Vector2.new(cx,cy); dGlow.Color=CT.accent
            dAccL.Size=Vector2.new(NW-20,2); dAccL.Position=Vector2.new(cx+10,cy); dAccL.Color=CT.accent
            dPBg.Size=Vector2.new(NW-20,3); dPBg.Position=Vector2.new(cx+10,cy+NH-7)
            dTitle.Position=Vector2.new(cx+NW/2,cy+14); dTitle.Center=true; dTitle.Color=CT.accent
            dBody.Position=Vector2.new(cx+NW/2,cy+30); dBody.Center=true; showAll(true)
        end
        local function setFill(pct,cy) local scr=getScreen(); local cx=scr.X/2-NW/2; local fw=math.max(0,(NW-20)*pct); dPFill.Size=Vector2.new(fw,3); dPFill.Position=Vector2.new(cx+10,cy+NH-7); dPFill.Color=CT.accent end
        local function targetY() local scr=getScreen(); return scr.Y-30-((getIdx()-1)*(NH+8))-NH end
        local t0=os.clock(); local elapsed=0
        while elapsed<duration do
            task.wait(0.016); elapsed=os.clock()-t0
            local tIn=easeOut(clamp(elapsed/0.35,0,1)); local dest=targetY()
            local cy=lerp(dest+40,dest,tIn); setPos(cy); setFill(1-clamp(elapsed/duration,0,1),cy)
        end
        local t2_0=os.clock(); local exitFrom=targetY()
        while os.clock()-t2_0<0.25 do
            task.wait(0.016); local t2=os.clock()-t2_0; local tOut=easeOut(clamp(t2/0.25,0,1))
            local cy=lerp(exitFrom,exitFrom+30,tOut); setPos(cy); setFill(0,cy)
            dBg.Color=Color3.new(CT.bg.R*(1-tOut),CT.bg.G*(1-tOut),CT.bg.B*(1-tOut))
        end
        for i,v in ipairs(_notifList) do if v.id==id then table.remove(_notifList,i); break end end
        showAll(false); dBg:Remove(); dGlow:Remove(); dAccL:Remove(); dPBg:Remove(); dPFill:Remove(); dTitle:Remove(); dBody:Remove()
    end)
end

-- ══════════════════════════════════════════════════════════════
--  7. CREATE WINDOW
-- ══════════════════════════════════════════════════════════════
function GalaxUI:CreateWindow(opts)
    opts=opts or {}
    local W_W = (opts.Size and opts.Size.X) or 580
    local W_H = (opts.Size and opts.Size.Y) or 420
    local TOP_H=38; local SB_W=192; local PAD=10; local CGAP=8
    local COL_W=math.floor((W_W-PAD*2-CGAP)/2); local IW=COL_W-20

    local WIN={
        Title=opts.Title or "Galax Hub", Size=Vector2.new(W_W,W_H),
        _minSize=Vector2.new(W_W,W_H), MenuKey=opts.MenuKey or 0x2D, User=opts.User or "user",
        _pos=Vector2.new(opts.X or 300, opts.Y or 150),
        _open=true, _running=true, _pages={}, _curPage=1,
        -- Drawing system (named cache)
        _d={}, _seen={},
        -- Sidebar
        _sbOpen=false, _sbW=0,
        -- State
        _drag=nil, _sliderDrag=nil, _listenKey=nil, _textboxTarget=nil,
        _ddTarget=nil, _ddOpenT=0, _cpTarget=nil, _cpOpenT=0,
        _cpDragSV=false, _cpDragH=false, _blockClicks=false,
        _blockInputsEnabled=true, _startMinimized=false,
        -- v3 additions
        _collapsed=false, _collapseAnim=1,
        _resizing=false, _resizeStart=nil,
        _tooltip=nil, _tooltipHoverTime=0, _tooltipHoverWid=nil,
        _scrollSpeed=0, _menuToggledAt=0, _pageChangeAt=0,
    }
    pcall(setrobloxinput, false)

    -- ── Drawing System ──────────────────────────────────────
    function WIN:_D(id,dtype,props)
        self._seen[id]=true; local d=self._d[id]
        if not d then d=Drawing.new(dtype); self._d[id]=d end
        for k,v in pairs(props) do d[k]=v end; d.Visible=true; return d
    end
    function WIN:_U(id) local d=self._d[id]; if d then d.Visible=false end end
    function WIN:_UPfx(pfx) for id,d in pairs(self._d) do if id:sub(1,#pfx)==pfx then d.Visible=false end end end
    function WIN:_BF() self._seen={} end
    function WIN:_FF() for id,d in pairs(self._d) do if not self._seen[id] then d.Visible=false end end end
    function WIN:_DestroyAll() for _,d in pairs(self._d) do d:Remove() end; self._d={}; self._seen={} end

    -- ── AddPage / AddSection / Widgets ──────────────────────
    function WIN:AddPage(name)
        local PAGE={_name=name,_sections={},_win=self,scroll=0,maxScroll=0,_scrollSmooth=0}

        function PAGE:AddSection(sname,col)
            local SEC={_name=sname,_col=col or 0,_widgets={},_win=self._win}
            local function reg(item) table.insert(SEC._widgets,item) end

            local function makeGroupReg(gItem)
                local GRP={}
                function GRP:AddToggle(l,d,cb,kb,tip)
                    local item={type="toggle",label=l,value=d or false,cb=cb or function()end,keybind=kb,kb_listening=false,kb_wasM1=false,tooltip=tip}
                    table.insert(gItem.children,item)
                    return{Get=function()return item.value end,Set=function(_,v)item.value=v;pcall(item.cb,v)end}
                end
                function GRP:AddSlider(l,o,cb) o=o or{}
                    local item={type="slider",label=l,min=o.Min or 0,max=o.Max or 100,value=o.Default or o.Min or 0,suffix=o.Suffix or"",cb=cb or function()end}
                    table.insert(gItem.children,item);pcall(item.cb,item.value)
                    return{Get=function()return item.value end,Set=function(_,v)item.value=clamp(v,item.min,item.max);pcall(item.cb,item.value)end}
                end
                function GRP:AddButton(l,cb,tip) table.insert(gItem.children,{type="button",label=l,cb=cb or function()end,tooltip=tip}); return{} end
                function GRP:AddLabel(t) local item={type="label",label=t or""}; table.insert(gItem.children,item); return{Get=function()return item.label end,Set=function(_,v)item.label=v end} end
                return GRP
            end

            function SEC:AddToggle(l,d,cb,kb,tip)
                local item={type="toggle",label=l,value=d or false,cb=cb or function()end,keybind=kb,kb_listening=false,kb_wasM1=false,tooltip=tip}
                reg(item); pcall(item.cb,item.value)
                return{Get=function()return item.value end,Set=function(_,v)item.value=v;pcall(item.cb,v)end}
            end
            function SEC:AddSlider(l,o,cb) o=o or{}
                local item={type="slider",label=l,min=o.Min or 0,max=o.Max or 100,value=o.Default or o.Min or 0,suffix=o.Suffix or"",cb=cb or function()end}
                reg(item); pcall(item.cb,item.value)
                return{Get=function()return item.value end,Set=function(_,v)item.value=clamp(v,item.min,item.max);pcall(item.cb,item.value)end}
            end
            function SEC:AddKeybind(l,d,cb)
                local item={type="keybind",label=l,value=d or 0,cb=cb or function()end,listening=false}
                reg(item); return{Get=function()return item.value end,Set=function(_,v)item.value=v;pcall(item.cb,v)end}
            end
            function SEC:AddDropdown(l,options,d,opts2,cb)
                if type(opts2)=="function" then cb=opts2; opts2={} end; opts2=opts2 or{}
                local item={type="dropdown",label=l,options=options or{},value=d or(options and options[1])or"",maxVisible=opts2.MaxVisible or 5,scroll=0,cb=cb or function()end}
                reg(item); pcall(item.cb,item.value)
                return{Get=function()return item.value end,Set=function(_,v)item.value=v;pcall(item.cb,v)end,
                    Refresh=function(_,no,nd)item.options=no or{};item.scroll=0;item.value=nd or(no and no[1])or"";pcall(item.cb,item.value)end}
            end
            function SEC:AddMultiDropdown(l,options,d,opts2,cb)
                if type(opts2)=="function" then cb=opts2;opts2={} end; opts2=opts2 or{}
                local sel={}; if d then for _,v in ipairs(d) do sel[v]=true end end
                local item={type="multidropdown",label=l,options=options or{},selected=sel,maxVisible=opts2.MaxVisible or 5,scroll=0,cb=cb or function()end}
                reg(item)
                local function gl() local o={}; for _,op in ipairs(item.options) do if item.selected[op] then o[#o+1]=op end end; return o end
                pcall(item.cb,gl())
                return{Get=function()return gl()end,Set=function(_,t)item.selected={};if t then for _,v in ipairs(t) do item.selected[v]=true end end;pcall(item.cb,gl())end,
                    Refresh=function(_,no,nd)item.options=no or{};item.selected={};item.scroll=0;if nd then for _,v in ipairs(nd) do item.selected[v]=true end end;pcall(item.cb,gl())end}
            end
            function SEC:AddColorPicker(l,d,cb)
                local h,s,v=0,1,1; if d then h,s,v=rgbToHsv(d) end
                local item={type="colorpicker",label=l,h=h,s=s,v=v,value=d or Color3.new(1,0,0),cb=cb or function()end,dragSV=false,dragH=false}
                reg(item); pcall(item.cb,item.value)
                return{Get=function()return item.value end,Set=function(_,c)item.value=c;local hh,ss,vv=rgbToHsv(c);item.h=hh;item.s=ss;item.v=vv;pcall(item.cb,c)end}
            end
            function SEC:AddCheckbox(l,d,cb)
                local item={type="checkbox",label=l,value=d or false,cb=cb or function()end}
                reg(item); pcall(item.cb,item.value)
                return{Get=function()return item.value end,Set=function(_,v)item.value=v;pcall(item.cb,v)end}
            end
            function SEC:AddStepper(l,o,cb) o=o or{}
                local item={type="stepper",label=l,min=o.Min or 0,max=o.Max or 100,value=o.Default or o.Min or 0,cb=cb or function()end}
                reg(item); pcall(item.cb,item.value)
                return{Get=function()return item.value end,Set=function(_,v)item.value=clamp(v,item.min,item.max);pcall(item.cb,item.value)end}
            end
            function SEC:AddButton(l,cb,style,tip)
                reg({type="button",label=l,cb=cb or function()end,style=style,tooltip=tip}); return{}
            end
            function SEC:AddTextbox(l,d,cb)
                local item={type="textbox",label=l,value=d or"",cb=cb or function()end,cursor=0}
                reg(item); return{Get=function()return item.value end,Set=function(_,v)item.value=v;item.cursor=#v;pcall(item.cb,v)end}
            end
            function SEC:AddLabel(t)
                local item={type="label",label=t or""}; reg(item)
                return{Get=function()return item.label end,Set=function(_,v)item.label=v end}
            end
            function SEC:AddProgressBar(l,o,cb) o=o or{}
                local item={type="progressbar",label=l,value=o.Value or 0,max=o.Max or 100,barColor=o.Color,cb=cb or function()end}
                reg(item)
                return{Get=function()return item.value end,Set=function(_,v)item.value=clamp(v,0,item.max);pcall(item.cb,item.value)end,SetMax=function(_,m)item.max=m end}
            end
            function SEC:AddSeparator(t) reg({type="separator",label=t or nil}); return{} end
            function SEC:AddGroupbox(name)
                local item={type="groupbox",label=name,children={}}; reg(item); return makeGroupReg(item)
            end

            table.insert(PAGE._sections,SEC); return SEC
        end
        table.insert(self._pages,PAGE); return PAGE
    end

    -- ── Config System ───────────────────────────────────────
    function WIN:GetConfigData()
        local data={}
        for _,pg in ipairs(self._pages) do
            if pg._isSettings or pg._isInfo then continue end
            data[pg._name]={}
            for _,sec in ipairs(pg._sections) do
                data[pg._name][sec._name]={}
                for _,w in ipairs(sec._widgets) do
                    if w.type=="toggle" or w.type=="checkbox" then data[pg._name][sec._name][w.label]={value=w.value,keybind=w.keybind}
                    elseif w.type=="slider" or w.type=="dropdown" or w.type=="textbox" or w.type=="keybind" or w.type=="stepper" then data[pg._name][sec._name][w.label]=w.value
                    elseif w.type=="multidropdown" then local s={}; for _,o in ipairs(w.options) do if w.selected[o] then s[#s+1]=o end end; data[pg._name][sec._name][w.label]=s
                    elseif w.type=="colorpicker" then data[pg._name][sec._name][w.label]={R=w.value.R,G=w.value.G,B=w.value.B}
                    elseif w.type=="progressbar" then data[pg._name][sec._name][w.label]=w.value
                    elseif w.type=="groupbox" then for _,cw in ipairs(w.children) do
                        if cw.type=="toggle" then data[pg._name][sec._name][cw.label]={value=cw.value,keybind=cw.keybind}
                        elseif cw.type=="slider" then data[pg._name][sec._name][cw.label]=cw.value end
                    end end
                    end
                end
            end
        end; return data
    end
    function WIN:SaveConfig()
        local ok=pcall(function() local j=game:GetService("HttpService"):JSONEncode(self:GetConfigData()); pcall(makefolder,"Galax"); pcall(makefolder,"Galax/Scripts"); writefile("Galax/Scripts/"..string.gsub(self.Title,"[^%w%s]","")..".json",j) end)
        self:Notify(ok and "Saved!" or "Save failed", ok and "Config" or "Error", 3)
    end
    function WIN:LoadConfig(silent)
        local ok2,ct=pcall(readfile,"Galax/Scripts/"..string.gsub(self.Title,"[^%w%s]","")..".json")
        if not ok2 or type(ct)~="string" or ct=="" then if not silent then self:Notify("No config found.","Config",3) end; return false end
        local dk,data=pcall(function() return game:GetService("HttpService"):JSONDecode(ct) end)
        if not dk or type(data)~="table" then return false end
        for _,pg in ipairs(self._pages) do
            if pg._isSettings or pg._isInfo then continue end
            local pd=data[pg._name]; if type(pd)~="table" then continue end
            for _,sec in ipairs(pg._sections) do local sd=pd[sec._name]; if type(sd)~="table" then continue end
                for _,w in ipairs(sec._widgets) do local val=sd[w.label]; if val==nil then continue end
                    pcall(function()
                        if (w.type=="toggle" or w.type=="checkbox") and type(val)=="table" then
                            if val.value~=nil then w.value=val.value end; if val.keybind~=nil then w.keybind=val.keybind end; pcall(w.cb,w.value)
                        elseif w.type=="colorpicker" and type(val)=="table" and val.R then
                            w.value=Color3.new(val.R,val.G,val.B); w.h,w.s,w.v=rgbToHsv(w.value); pcall(w.cb,w.value)
                        elseif w.type=="multidropdown" and type(val)=="table" then
                            w.selected={}; for _,o in ipairs(val) do w.selected[o]=true end
                            local out={}; for _,o in ipairs(w.options) do if w.selected[o] then out[#out+1]=o end end; pcall(w.cb,out)
                        elseif w.type=="slider" or w.type=="dropdown" or w.type=="textbox" or w.type=="keybind" or w.type=="stepper" then
                            w.value=val; pcall(w.cb,w.value)
                        end
                    end)
                    if w.type=="groupbox" then for _,cw in ipairs(w.children) do local cv=sd[cw.label]; if cv~=nil then pcall(function()
                        if cw.type=="toggle" and type(cv)=="table" then if cv.value~=nil then cw.value=cv.value end; pcall(cw.cb,cw.value)
                        elseif cw.type=="slider" then cw.value=cv; pcall(cw.cb,cw.value) end
                    end) end end end
                end
            end
        end
        if not silent then self:Notify("Config loaded!","Config",3) end; return true
    end
    function WIN:SaveSettings()
        local data={theme="Galax",menuKey=self.MenuKey,startMin=self._startMinimized,blockInputs=self._blockInputsEnabled,font="System"}
        pcall(makefolder,"Galax"); pcall(makefolder,"Galax/Settings")
        pcall(writefile,"Galax/Settings/GalaxUI.json",game:GetService("HttpService"):JSONEncode(data))
    end
    function WIN:LoadSettings()
        local ok,ct=pcall(readfile,"Galax/Settings/GalaxUI.json")
        if not ok or type(ct)~="string" or ct=="" then return end
        local dk,data=pcall(function() return game:GetService("HttpService"):JSONDecode(ct) end)
        if not dk or type(data)~="table" then return end
        if data.theme then applyTheme(data.theme) end
        if data.menuKey then self.MenuKey=data.menuKey end
        if data.startMin then self._startMinimized=data.startMin; self._open=false; pcall(setrobloxinput,true) end
        if data.font then applyFont(data.font) end
        if data.blockInputs~=nil then self._blockInputsEnabled=data.blockInputs end
    end

    -- ── Built-in Pages ──────────────────────────────────────
    function WIN:_buildSettings()
        local PG={_name="Settings",_sections={},_win=self,_isSettings=true,scroll=0,maxScroll=0,_scrollSmooth=0}
        local SM={_name="Menu",_widgets={},_win=self}
        table.insert(SM._widgets,{type="s_keybind",label="Toggle Key",listening=false})
        table.insert(SM._widgets,{type="s_toggle",label="Start Minimized",value=false})
        table.insert(SM._widgets,{type="s_toggle",label="Block Inputs",value=true})
        table.insert(SM._widgets,{type="s_kill",label="Kill Script"})
        table.insert(PG._sections,SM)
        local ST={_name="Theme",_widgets={},_win=self}
        table.insert(ST._widgets,{type="dropdown",label="Theme",options=ThemeNames,value="Galax",maxVisible=5,scroll=0,cb=function(v)applyTheme(v);self:SaveSettings()end})
        table.insert(ST._widgets,{type="dropdown",label="Font",options=FontNames,value="System",maxVisible=5,scroll=0,cb=function(v)applyFont(v);self:SaveSettings()end})
        table.insert(PG._sections,ST)
        local SC={_name="Config",_widgets={},_win=self}
        table.insert(SC._widgets,{type="s_btn",label="Save Config",style="success",cb=function()self:SaveConfig()end})
        table.insert(SC._widgets,{type="s_btn",label="Load Config",style="ac",cb=function()self:LoadConfig(false)end})
        table.insert(PG._sections,SC)
        table.insert(self._pages,PG)
    end
    function WIN:_buildInfoTab()
        local PG={_name="Info",_sections={},_win=self,_isInfo=true,scroll=0,maxScroll=0,_scrollSmooth=0}
        local SU={_name="Updates",_widgets={},_win=self}
        if #GalaxUI.Updates==0 then table.insert(SU._widgets,{type="label",label="No updates yet."})
        else for _,l in ipairs(GalaxUI.Updates) do table.insert(SU._widgets,{type="label",label=tostring(l)}) end end
        table.insert(PG._sections,SU)
        local SS={_name="Supporters",_widgets={},_win=self}
        if #_Supporters==0 then table.insert(SS._widgets,{type="label",label="No supporters yet."})
        else for _,s in ipairs(_Supporters) do table.insert(SS._widgets,{type="supporter_label",text=s.text,color=s.color}) end end
        table.insert(PG._sections,SS)
        table.insert(self._pages,1,PG); self._curPage=1
    end

    function WIN:Notify(msg,title,dur) GalaxNotify(title or self.Title,msg,dur or 3) end
    function WIN:Unload() self._running=false end

    -- ── Widget Height ───────────────────────────────────────
    local function wH(item)
        if item.type=="label" then local ln=wrapText(item.label,IW,12); return math.max(18,#ln*15+4)
        elseif item.type=="supporter_label" then return 20
        elseif item.type=="toggle" then return 24
        elseif item.type=="checkbox" then return 22
        elseif item.type=="slider" then return 32
        elseif item.type=="keybind" then return 22
        elseif item.type=="dropdown" or item.type=="multidropdown" then return 44
        elseif item.type=="colorpicker" then return 24
        elseif item.type=="stepper" then return 26
        elseif item.type=="button" or item.type=="s_btn" then return 26
        elseif item.type=="textbox" then return 42
        elseif item.type=="progressbar" then return 28
        elseif item.type=="separator" then return item.label and 18 or 10
        elseif item.type=="groupbox" then local h=24; for _,ch in ipairs(item.children) do h=h+wH(ch)+5 end; return h+6
        elseif item.type=="s_keybind" then return 22
        elseif item.type=="s_toggle" then return 24
        elseif item.type=="s_kill" then return 26
        end; return 18
    end

    -- ── Widget Renderer ─────────────────────────────────────
    function WIN:_renderWidget(item,wid,wx,wy,iw,minY,maxY)
        local h=wH(item); if wy+h<minY or wy>maxY then return h end
        local FONT=CurFont
        local function chkTip(tip,pos,sz)
            if not tip then return end
            if over(pos,sz) then
                if self._tooltipHoverWid~=wid then self._tooltipHoverWid=wid; self._tooltipHoverTime=os.clock() end
                if os.clock()-self._tooltipHoverTime>0.5 then local mp=mpos(); self._tooltip={text=tip,x=mp.X+10,y=mp.Y-18} end
            elseif self._tooltipHoverWid==wid then self._tooltipHoverWid=nil; self._tooltip=nil end
        end

        -- ── TOGGLE (pill switch) ────────────────────────────
        if item.type=="toggle" then
            local sw_w,sw_h=34,19; local tpos=Vector2.new(wx+iw-sw_w,wy)
            -- Keybind badge
            if item.keybind~=nil then
                local kbStr=item.kb_listening and "..." or keyName(item.keybind)
                local kbW=textW("TGL",9)+8; local kbtW=textW(kbStr,10)+10
                local kbX=tpos.X-kbtW-kbW-8
                self:_D(wid.."_kb1","Square",{Position=Vector2.new(kbX,wy+1),Size=Vector2.new(kbW,18),Filled=true,Color=CT.section,ZIndex=7})
                self:_D(wid.."_kb1b","Square",{Position=Vector2.new(kbX,wy+1),Size=Vector2.new(kbW,18),Filled=false,Color=CT.border,Thickness=1,ZIndex=8})
                self:_D(wid.."_kb1t","Text",{Position=Vector2.new(kbX+kbW/2,wy+10),Text="TGL",Size=9,Font=F_MONO,Color=CT.accent,Center=true,Outline=false,ZIndex=9})
                local btX=kbX+kbW+2
                self:_D(wid.."_kb2","Square",{Position=Vector2.new(btX,wy+1),Size=Vector2.new(kbtW,18),Filled=true,Color=CT.section,ZIndex=7})
                self:_D(wid.."_kb2b","Square",{Position=Vector2.new(btX,wy+1),Size=Vector2.new(kbtW,18),Filled=false,Color=item.kb_listening and CT.accent or CT.border,Thickness=1,ZIndex=8})
                self:_D(wid.."_kb2t","Text",{Position=Vector2.new(btX+kbtW/2,wy+10),Text=kbStr,Size=10,Font=F_MONO,Color=item.kb_listening and CT.accent or CT.sub,Center=true,Outline=false,ZIndex=9})
                local m1=Input.held
                if m1 and not item.kb_wasM1 and not self._blockClicks and over(Vector2.new(btX,wy+1),Vector2.new(kbtW,18)) then item.kb_listening=true end
                item.kb_wasM1=m1
                if item.kb_listening then for kc=1,255 do if kc~=0x01 and kc~=0x02 and Input:keyClick(kc) then
                    if kc~=0x1B then item.keybind=kc end; item.kb_listening=false; break
                end end end
                if item.keybind and item.keybind~=0 and not item.kb_listening then
                    if Input:keyClick(item.keybind) then item.value=not item.value; pcall(item.cb,item.value) end
                end
            end
            -- Label
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx,wy+5),Text=item.label,Size=12,Font=FONT,Color=item.value and CT.text or CT.sub,Outline=false,ZIndex=7})
            -- Pill switch
            self:_D(wid.."_trk","Square",{Position=tpos,Size=Vector2.new(sw_w,sw_h),Filled=true,Color=item.value and CT.accent or CT.border2,ZIndex=7,Corner=10})
            local kx=item.value and tpos.X+sw_w-12 or tpos.X+6
            self:_D(wid.."_knb","Circle",{Position=Vector2.new(kx,tpos.Y+sw_h/2),Radius=6,Filled=true,Color=Color3.new(1,1,1),ZIndex=8})
            chkTip(item.tooltip,Vector2.new(wx,wy),Vector2.new(iw,22))
            if Input.click and not self._blockClicks and over(Vector2.new(wx,wy),Vector2.new(iw,22)) then
                local clickedKb=false
                if item.keybind~=nil then local kbX2=tpos.X-textW(keyName(item.keybind),10)-10-textW("TGL",9)-10; if mpos().X>=kbX2 and mpos().X<tpos.X then clickedKb=true end end
                if not clickedKb then item.value=not item.value; pcall(item.cb,item.value) end
            end

        -- ── CHECKBOX ────────────────────────────────────────
        elseif item.type=="checkbox" then
            local val=item.value
            self:_D(wid.."_box","Square",{Position=Vector2.new(wx,wy),Size=Vector2.new(15,15),Filled=true,Color=val and CT.accent or CT.border2,ZIndex=7,Corner=4})
            self:_D(wid.."_boxb","Square",{Position=Vector2.new(wx,wy),Size=Vector2.new(15,15),Filled=false,Color=val and CT.accent or CT.border2,Thickness=1,ZIndex=8,Corner=4})
            if val then
                self:_D(wid.."_ck1","Line",{From=Vector2.new(wx+2,wy+7),To=Vector2.new(wx+6,wy+12),Thickness=1.5,Color=Color3.new(1,1,1),ZIndex=9})
                self:_D(wid.."_ck2","Line",{From=Vector2.new(wx+6,wy+12),To=Vector2.new(wx+13,wy+3),Thickness=1.5,Color=Color3.new(1,1,1),ZIndex=9})
            else self:_U(wid.."_ck1"); self:_U(wid.."_ck2") end
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx+20,wy+1),Text=item.label,Size=12,Font=FONT,Color=CT.text,Outline=false,ZIndex=7})
            if Input.click and not self._blockClicks and over(Vector2.new(wx,wy),Vector2.new(200,16)) then item.value=not item.value; pcall(item.cb,item.value) end

        -- ── SLIDER ──────────────────────────────────────────
        elseif item.type=="slider" then
            local valStr=tostring(math.floor(item.value))..item.suffix
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx,wy),Text=item.label,Size=12,Font=FONT,Color=CT.text,Outline=false,ZIndex=7})
            self:_D(wid.."_val","Text",{Position=Vector2.new(wx+iw-30,wy),Text=valStr,Size=11,Font=F_MONO,Color=CT.accent,Outline=false,ZIndex=7})
            local ty=wy+17; local pct=clamp((item.value-item.min)/(item.max-item.min),0,1)
            self:_D(wid.."_trk","Square",{Position=Vector2.new(wx,ty),Size=Vector2.new(iw,4),Filled=true,Color=CT.border2,ZIndex=7,Corner=2})
            self:_D(wid.."_fill","Square",{Position=Vector2.new(wx,ty),Size=Vector2.new(iw*pct,4),Filled=true,Color=CT.accent,ZIndex=8,Corner=2})
            self:_D(wid.."_knb","Circle",{Position=Vector2.new(wx+iw*pct,ty+2),Radius=6,Filled=true,Color=Color3.new(1,1,1),ZIndex=9})
            if Input.click and not self._blockClicks and over(Vector2.new(wx,ty-5),Vector2.new(iw,14)) then self._sliderDrag=item end
            if self._sliderDrag==item then
                if Input.held then local p=clamp((mpos().X-wx)/iw,0,1); item.value=math.floor(item.min+(item.max-item.min)*p+0.5); pcall(item.cb,item.value)
                else self._sliderDrag=nil end
            end

        -- ── KEYBIND ─────────────────────────────────────────
        elseif item.type=="keybind" then
            local kbStr=item.listening and "..." or keyName(item.value)
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx,wy+3),Text=item.label,Size=10,Font=FONT,Color=CT.sub,Outline=false,ZIndex=7})
            local kbW=textW("TGL",9)+8; local btW=textW(kbStr,10)+12
            local bx=wx+iw-btW-kbW-4
            self:_D(wid.."_b1","Square",{Position=Vector2.new(bx,wy),Size=Vector2.new(kbW,18),Filled=true,Color=CT.section,ZIndex=7}); self:_D(wid.."_b1b","Square",{Position=Vector2.new(bx,wy),Size=Vector2.new(kbW,18),Filled=false,Color=CT.border,Thickness=1,ZIndex=8})
            self:_D(wid.."_b1t","Text",{Position=Vector2.new(bx+kbW/2,wy+9),Text="TGL",Size=9,Font=F_MONO,Color=CT.accent,Center=true,Outline=false,ZIndex=9})
            local b2x=bx+kbW+2
            self:_D(wid.."_b2","Square",{Position=Vector2.new(b2x,wy),Size=Vector2.new(btW,18),Filled=true,Color=CT.section,ZIndex=7}); self:_D(wid.."_b2b","Square",{Position=Vector2.new(b2x,wy),Size=Vector2.new(btW,18),Filled=false,Color=item.listening and CT.accent or CT.border,Thickness=1,ZIndex=8})
            self:_D(wid.."_b2t","Text",{Position=Vector2.new(b2x+btW/2,wy+9),Text=kbStr,Size=10,Font=F_MONO,Color=item.listening and CT.accent or CT.sub,Center=true,Outline=false,ZIndex=9})
            if Input.click and not self._blockClicks and over(Vector2.new(b2x,wy),Vector2.new(btW,18)) then item.listening=true; self._listenKey=item end
            if item.listening and self._listenKey==item then for kc=1,255 do if kc~=0x01 and kc~=0x02 and Input:keyClick(kc) then
                if kc~=0x1B then item.value=kc; pcall(item.cb,kc) end; item.listening=false; self._listenKey=nil; break
            end end end

        -- ── DROPDOWN ────────────────────────────────────────
        elseif item.type=="dropdown" then
            if not item._id then item._id={} end
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx,wy),Text=item.label,Size=12,Font=FONT,Color=CT.text,Outline=false,ZIndex=7})
            local dy=wy+16; local dh=22
            local isOpen=(self._ddTarget and self._ddTarget._id==item._id)
            self:_D(wid.."_bg","Square",{Position=Vector2.new(wx,dy),Size=Vector2.new(iw,dh),Filled=true,Color=Color3.fromRGB(10,10,18),ZIndex=7,Corner=5})
            self:_D(wid.."_bd","Square",{Position=Vector2.new(wx,dy),Size=Vector2.new(iw,dh),Filled=false,Color=isOpen and CT.accent or CT.border,Thickness=1,ZIndex=8,Corner=5})
            self:_D(wid.."_val","Text",{Position=Vector2.new(wx+iw/2,dy+11),Text=item.value,Size=11,Font=FONT,Color=CT.text,Center=true,Outline=false,ZIndex=9})
            self:_D(wid.."_arr","Text",{Position=Vector2.new(wx+iw-10,dy+11),Text=isOpen and "^" or "v",Size=10,Font=FONT,Color=isOpen and CT.accent or CT.sub,Center=true,Outline=false,ZIndex=9})
            if Input.click and not self._blockClicks and over(Vector2.new(wx,dy),Vector2.new(iw,dh)) then
                if isOpen then self._ddTarget=nil else self._ddTarget=item; self._ddOpenT=os.clock(); self._cpTarget=nil end
            end
            if isOpen then self._blockClicks=true; self._deferredDrop={wid,item,wx,dy+dh+2,iw,false} end

        -- ── MULTIDROPDOWN ───────────────────────────────────
        elseif item.type=="multidropdown" then
            if not item._id then item._id={} end
            local selList={}; for _,o in ipairs(item.options) do if item.selected[o] then selList[#selList+1]=o end end
            local dispStr=#selList==0 and "None" or(#selList.."/"..#item.options.." selected")
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx,wy),Text=item.label,Size=12,Font=FONT,Color=CT.text,Outline=false,ZIndex=7})
            local dy=wy+16; local dh=22
            local isOpen=(self._ddTarget and self._ddTarget._id==item._id)
            self:_D(wid.."_bg","Square",{Position=Vector2.new(wx,dy),Size=Vector2.new(iw,dh),Filled=true,Color=Color3.fromRGB(10,10,18),ZIndex=7,Corner=5})
            self:_D(wid.."_bd","Square",{Position=Vector2.new(wx,dy),Size=Vector2.new(iw,dh),Filled=false,Color=isOpen and CT.accent or CT.border,Thickness=1,ZIndex=8,Corner=5})
            self:_D(wid.."_val","Text",{Position=Vector2.new(wx+iw/2,dy+11),Text=dispStr,Size=11,Font=FONT,Color=CT.text,Center=true,Outline=false,ZIndex=9})
            if Input.click and not self._blockClicks and over(Vector2.new(wx,dy),Vector2.new(iw,dh)) then
                if isOpen then self._ddTarget=nil else self._ddTarget=item; self._ddOpenT=os.clock(); self._cpTarget=nil end
            end
            if isOpen then self._blockClicks=true; self._deferredDrop={wid,item,wx,dy+dh+2,iw,true} end

        -- ── COLOR PICKER ────────────────────────────────────
        elseif item.type=="colorpicker" then
            local swW=36
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx,wy+4),Text=item.label,Size=12,Font=FONT,Color=CT.text,Outline=false,ZIndex=7})
            local swX=wx+iw-swW
            self:_D(wid.."_sw","Square",{Position=Vector2.new(swX,wy),Size=Vector2.new(swW,19),Filled=true,Color=item.value,ZIndex=7,Corner=5})
            self:_D(wid.."_swb","Square",{Position=Vector2.new(swX,wy),Size=Vector2.new(swW,19),Filled=false,Color=(self._cpTarget==item) and CT.accent or CT.border2,Thickness=1,ZIndex=8,Corner=5})
            if Input.click and not self._blockClicks and over(Vector2.new(swX,wy),Vector2.new(swW,19)) then
                if self._cpTarget==item then self._cpTarget=nil else
                    self._cpTarget=item; self._cpOpenT=os.clock(); self._ddTarget=nil end
            end
            if self._cpTarget==item then self._blockClicks=true; self._deferredCP={wid,item,swX+swW-180,wy+25,180} end

        -- ── STEPPER ─────────────────────────────────────────
        elseif item.type=="stepper" then
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx,wy+5),Text=item.label,Size=12,Font=FONT,Color=CT.text,Outline=false,ZIndex=7})
            local bx=wx+iw-66
            self:_D(wid.."_bg","Square",{Position=Vector2.new(bx,wy),Size=Vector2.new(66,22),Filled=true,Color=Color3.fromRGB(12,12,20),ZIndex=7,Corner=5})
            self:_D(wid.."_bd","Square",{Position=Vector2.new(bx,wy),Size=Vector2.new(66,22),Filled=false,Color=CT.border,Thickness=1,ZIndex=8,Corner=5})
            self:_D(wid.."_s1","Line",{From=Vector2.new(bx+22,wy),To=Vector2.new(bx+22,wy+22),Thickness=1,Color=CT.border,ZIndex=8})
            self:_D(wid.."_s2","Line",{From=Vector2.new(bx+44,wy),To=Vector2.new(bx+44,wy+22),Thickness=1,Color=CT.border,ZIndex=8})
            self:_D(wid.."_m","Text",{Position=Vector2.new(bx+11,wy+11),Text="-",Size=13,Font=FONT,Color=CT.sub,Center=true,Outline=false,ZIndex=9})
            self:_D(wid.."_v","Text",{Position=Vector2.new(bx+33,wy+11),Text=tostring(item.value),Size=11,Font=F_MONO,Color=CT.text,Center=true,Outline=false,ZIndex=9})
            self:_D(wid.."_p","Text",{Position=Vector2.new(bx+55,wy+11),Text="+",Size=13,Font=FONT,Color=CT.sub,Center=true,Outline=false,ZIndex=9})
            if Input.click and not self._blockClicks then
                if over(Vector2.new(bx,wy),Vector2.new(22,22)) then item.value=math.max(item.min,item.value-1); pcall(item.cb,item.value) end
                if over(Vector2.new(bx+44,wy),Vector2.new(22,22)) then item.value=math.min(item.max,item.value+1); pcall(item.cb,item.value) end
            end

        -- ── BUTTON ──────────────────────────────────────────
        elseif item.type=="button" then
            local bpos=Vector2.new(wx,wy); local bsz=Vector2.new(iw,22); local hov=over(bpos,bsz)
            local bg,tx2,bd
            local st=item.style
            if st=="ac" or st=="accent" then
                bg=Color3.new(CT.accent.R*0.15,CT.accent.G*0.15,CT.accent.B*0.15); tx2=CT.accent; bd=CT.accent
            elseif st=="danger" then bg=Color3.fromRGB(55,15,13); tx2=CT.danger; bd=Color3.fromRGB(100,28,24)
            elseif st=="success" then bg=Color3.fromRGB(10,48,20); tx2=CT.success; bd=Color3.fromRGB(18,76,32)
            else bg=hov and Color3.fromRGB(28,28,46) or CT.section; tx2=CT.text; bd=CT.border2 end
            self:_D(wid.."_bg","Square",{Position=bpos,Size=bsz,Filled=true,Color=bg,ZIndex=7,Corner=7})
            self:_D(wid.."_bd","Square",{Position=bpos,Size=bsz,Filled=false,Color=bd,Thickness=1,ZIndex=8,Corner=7})
            self:_D(wid.."_t","Text",{Position=bpos+Vector2.new(iw/2,11),Text=item.label,Size=11,Font=FONT,Color=tx2,Center=true,Outline=false,ZIndex=9})
            chkTip(item.tooltip,bpos,bsz)
            if Input.click and not self._blockClicks and hov then pcall(item.cb) end

        -- ── TEXTBOX ─────────────────────────────────────────
        elseif item.type=="textbox" then
            if not item.cursor then item.cursor=#item.value end
            local focused=(self._textboxTarget==item)
            local display; if focused then
                local l=item.value:sub(1,item.cursor); local r=item.value:sub(item.cursor+1)
                display=l..(math.floor(os.clock()*2.5)%2==0 and"|"or"")..r
            else display=item.value=="" and item.label or item.value end
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx,wy),Text=item.label,Size=12,Font=FONT,Color=CT.sub,Outline=false,ZIndex=7})
            local ty=wy+15
            self:_D(wid.."_bg","Square",{Position=Vector2.new(wx,ty),Size=Vector2.new(iw,22),Filled=true,Color=CT.section,ZIndex=7,Corner=5})
            self:_D(wid.."_bd","Square",{Position=Vector2.new(wx,ty),Size=Vector2.new(iw,22),Filled=false,Color=focused and CT.accent or CT.border,Thickness=1,ZIndex=8,Corner=5})
            self:_D(wid.."_tx","Text",{Position=Vector2.new(wx+6,ty+4),Text=display,Size=12,Font=FONT,Color=(item.value~="" or focused) and CT.text or CT.sub,Outline=false,ZIndex=9})
            if Input.click and not self._blockClicks then
                if over(Vector2.new(wx,ty),Vector2.new(iw,22)) then self._textboxTarget=item; item.cursor=#item.value
                elseif self._textboxTarget==item then self._textboxTarget=nil end
            end
            if focused then for kc=8,122 do if Input:keyClick(kc) then
                if kc==0x08 and item.cursor>0 then item.value=item.value:sub(1,item.cursor-1)..item.value:sub(item.cursor+1); item.cursor=item.cursor-1; pcall(item.cb,item.value)
                elseif kc==0x2E and item.cursor<#item.value then item.value=item.value:sub(1,item.cursor)..item.value:sub(item.cursor+2); pcall(item.cb,item.value)
                elseif kc==0x25 then item.cursor=math.max(0,item.cursor-1)
                elseif kc==0x27 then item.cursor=math.min(#item.value,item.cursor+1)
                elseif kc==0x24 then item.cursor=0
                elseif kc==0x23 then item.cursor=#item.value
                elseif kc==0x0D then self._textboxTarget=nil
                elseif kc==0x20 then item.value=item.value:sub(1,item.cursor).." "..item.value:sub(item.cursor+1); item.cursor=item.cursor+1; pcall(item.cb,item.value)
                elseif kc>=0x30 and kc<=0x5A then local ch=KeyNames[kc]; if ch and #ch==1 then
                    local sh=Input:keyHeld(0x10) or Input:keyHeld(0xA0); local c=sh and ch:upper() or ch:lower()
                    item.value=item.value:sub(1,item.cursor)..c..item.value:sub(item.cursor+1); item.cursor=item.cursor+1; pcall(item.cb,item.value)
                end end
            end end end

        -- ── PROGRESS BAR ────────────────────────────────────
        elseif item.type=="progressbar" then
            local pct=item.max>0 and clamp(item.value/item.max,0,1) or 0
            local col=item.barColor or CT.success
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx,wy),Text=item.label,Size=12,Font=FONT,Color=CT.text,Outline=false,ZIndex=7})
            self:_D(wid.."_v","Text",{Position=Vector2.new(wx+iw-26,wy),Text=math.floor(pct*100).."%",Size=11,Font=F_MONO,Color=col,Outline=false,ZIndex=7})
            self:_D(wid.."_trk","Square",{Position=Vector2.new(wx,wy+16),Size=Vector2.new(iw,4),Filled=true,Color=CT.border2,ZIndex=7,Corner=2})
            self:_D(wid.."_fill","Square",{Position=Vector2.new(wx,wy+16),Size=Vector2.new(iw*pct,4),Filled=true,Color=col,ZIndex=8,Corner=2})

        -- ── SEPARATOR ───────────────────────────────────────
        elseif item.type=="separator" then
            if item.label then
                local tw=textW(item.label,10)+8; local lw=(iw-tw)/2; local ly=wy+8
                self:_D(wid.."_l1","Line",{From=Vector2.new(wx,ly),To=Vector2.new(wx+lw-2,ly),Thickness=1,Color=CT.border,ZIndex=7})
                self:_D(wid.."_t","Text",{Position=Vector2.new(wx+iw/2,wy+2),Text=item.label,Size=10,Font=FONT,Color=CT.sub,Center=true,Outline=false,ZIndex=7})
                self:_D(wid.."_l2","Line",{From=Vector2.new(wx+lw+tw,ly),To=Vector2.new(wx+iw,ly),Thickness=1,Color=CT.border,ZIndex=7})
            else self:_D(wid.."_ln","Line",{From=Vector2.new(wx,wy+4),To=Vector2.new(wx+iw,wy+4),Thickness=1,Color=CT.border,ZIndex=7}) end

        -- ── GROUPBOX ────────────────────────────────────────
        elseif item.type=="groupbox" then
            local gbP=8; local chH=0; for _,ch in ipairs(item.children) do chH=chH+wH(ch)+5 end; local totH=24+chH+6
            self:_D(wid.."_bg","Square",{Position=Vector2.new(wx-4,wy),Size=Vector2.new(iw+8,totH),Filled=true,Color=tintColor(CT.section,CT.accent,0.03),ZIndex=6,Corner=8})
            self:_D(wid.."_bd","Square",{Position=Vector2.new(wx-4,wy),Size=Vector2.new(iw+8,totH),Filled=false,Color=CT.border,Thickness=1,ZIndex=6,Corner=8})
            self:_D(wid.."_hd","Text",{Position=Vector2.new(wx+2,wy+4),Text=item.label,Size=11,Font=FONT,Color=CT.accent,Outline=false,ZIndex=7})
            self:_D(wid.."_hl","Line",{From=Vector2.new(wx,wy+18),To=Vector2.new(wx+iw,wy+18),Thickness=1,Color=CT.border,ZIndex=7})
            local cy=wy+22; for ci,ch in ipairs(item.children) do
                local chh=self:_renderWidget(ch,wid.."_g"..ci,wx+gbP,cy,iw-gbP*2,minY,maxY); cy=cy+chh+5
            end

        -- ── LABEL ───────────────────────────────────────────
        elseif item.type=="label" then
            local lines=wrapText(item.label,iw,12)
            for li,ln in ipairs(lines) do self:_D(wid.."_l"..li,"Text",{Position=Vector2.new(wx,wy+(li-1)*15+2),Text=ln,Size=12,Font=FONT,Color=CT.sub,Outline=false,ZIndex=7}) end
            for li=#lines+1,10 do self:_U(wid.."_l"..li) end
        elseif item.type=="supporter_label" then
            self:_D(wid.."_t","Text",{Position=Vector2.new(wx,wy+2),Text=item.text,Size=12,Font=FONT,Color=item.color,Outline=false,ZIndex=7})

        -- ── SETTINGS WIDGETS ────────────────────────────────
        elseif item.type=="s_keybind" then
            local kbStr=item.listening and"..."or keyName(self.MenuKey); local kbW=textW(kbStr,10)+14
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx,wy+3),Text=item.label,Size=12,Font=FONT,Color=CT.text,Outline=false,ZIndex=7})
            local bx=wx+iw-kbW
            self:_D(wid.."_bg","Square",{Position=Vector2.new(bx,wy),Size=Vector2.new(kbW,18),Filled=true,Color=CT.section,ZIndex=7}); self:_D(wid.."_bd","Square",{Position=Vector2.new(bx,wy),Size=Vector2.new(kbW,18),Filled=false,Color=item.listening and CT.accent or CT.border,Thickness=1,ZIndex=8})
            self:_D(wid.."_t","Text",{Position=Vector2.new(bx+kbW/2,wy+9),Text=kbStr,Size=10,Font=F_MONO,Color=item.listening and CT.accent or CT.sub,Center=true,Outline=false,ZIndex=9})
            if Input.click and not self._blockClicks and over(Vector2.new(bx,wy),Vector2.new(kbW,18)) then item.listening=true end
            if item.listening then for kc=1,255 do if kc~=0x01 and kc~=0x02 and Input:keyClick(kc) then
                if kc~=0x1B then self.MenuKey=kc; self:SaveSettings() end; item.listening=false; break
            end end end
        elseif item.type=="s_toggle" then
            local val=item.value; local sw_w,sw_h=34,19; local tpos=Vector2.new(wx+iw-sw_w,wy)
            self:_D(wid.."_lbl","Text",{Position=Vector2.new(wx,wy+4),Text=item.label,Size=12,Font=FONT,Color=val and CT.text or CT.sub,Outline=false,ZIndex=7})
            self:_D(wid.."_trk","Square",{Position=tpos,Size=Vector2.new(sw_w,sw_h),Filled=true,Color=val and CT.accent or CT.border2,ZIndex=7,Corner=10})
            self:_D(wid.."_knb","Circle",{Position=Vector2.new(val and tpos.X+sw_w-12 or tpos.X+6,tpos.Y+sw_h/2),Radius=6,Filled=true,Color=Color3.new(1,1,1),ZIndex=8})
            if Input.click and not self._blockClicks and over(Vector2.new(wx,wy),Vector2.new(iw,22)) then
                item.value=not item.value
                if item.label=="Start Minimized" then self._startMinimized=item.value
                elseif item.label=="Block Inputs" then self._blockInputsEnabled=item.value; if not item.value then pcall(setrobloxinput,true) end end
                self:SaveSettings()
            end
        elseif item.type=="s_kill" then
            local bpos=Vector2.new(wx,wy); local bsz=Vector2.new(iw,22); local hov=over(bpos,bsz)
            self:_D(wid.."_bg","Square",{Position=bpos,Size=bsz,Filled=true,Color=hov and Color3.fromRGB(55,15,13) or CT.section,ZIndex=7,Corner=7})
            self:_D(wid.."_bd","Square",{Position=bpos,Size=bsz,Filled=false,Color=CT.danger,Thickness=1,ZIndex=8,Corner=7})
            self:_D(wid.."_t","Text",{Position=bpos+Vector2.new(iw/2,11),Text=item.label,Size=11,Font=FONT,Color=CT.danger,Center=true,Outline=false,ZIndex=9})
            if Input.click and not self._blockClicks and hov then self:Notify("Script killed.",self.Title,2); self._running=false end
        elseif item.type=="s_btn" then
            local bpos=Vector2.new(wx,wy); local bsz=Vector2.new(iw,22); local hov=over(bpos,bsz)
            local st=item.style; local bg,tx2,bd
            if st=="success" then bg=hov and Color3.fromRGB(15,55,25) or Color3.fromRGB(10,48,20); tx2=CT.success; bd=Color3.fromRGB(18,76,32)
            else bg=hov and Color3.fromRGB(20,35,70) or CT.section; tx2=CT.accent; bd=CT.accent end
            self:_D(wid.."_bg","Square",{Position=bpos,Size=bsz,Filled=true,Color=bg,ZIndex=7,Corner=7})
            self:_D(wid.."_bd","Square",{Position=bpos,Size=bsz,Filled=false,Color=bd,Thickness=1,ZIndex=8,Corner=7})
            self:_D(wid.."_t","Text",{Position=bpos+Vector2.new(iw/2,11),Text=item.label,Size=11,Font=FONT,Color=tx2,Center=true,Outline=false,ZIndex=9})
            if Input.click and not self._blockClicks and hov then pcall(item.cb) end
        end
        return h
    end

    -- ── Dropdown Popup Renderer ─────────────────────────────
    function WIN:_renderDDPopup(wid,item,lx,ly,lw,isMulti)
        local age=os.clock()-self._ddOpenT; local optH=20
        local maxV=item.maxVisible or 5; local total=#item.options
        item.scroll=clamp(item.scroll or 0,0,math.max(0,total-maxV))
        local vc=math.min(maxV,total); local lh=vc*optH+6
        local popOp=clamp(age/0.12,0,1)
        self:_D(wid.."_dlbg","Square",{Position=Vector2.new(lx,ly),Size=Vector2.new(lw,lh),Filled=true,Color=Color3.fromRGB(10,10,20),ZIndex=60,Transparency=popOp,Corner=5})
        self:_D(wid.."_dlbd","Square",{Position=Vector2.new(lx,ly),Size=Vector2.new(lw,lh),Filled=false,Color=CT.accent,Thickness=1,ZIndex=61,Transparency=popOp,Corner=5})
        for vi=1,vc do
            local oi=vi+(item.scroll or 0); local opt=item.options[oi]; if not opt then break end
            local oy=ly+(vi-1)*optH+3; local hov=over(Vector2.new(lx,oy),Vector2.new(lw,optH))
            if isMulti then
                local sel=item.selected[opt]==true
                if hov then self:_D(wid.."_dhi"..vi,"Square",{Position=Vector2.new(lx,oy),Size=Vector2.new(lw,optH),Filled=true,Color=Color3.fromRGB(20,20,35),ZIndex=61,Transparency=popOp}) else self:_U(wid.."_dhi"..vi) end
                self:_D(wid.."_dcb"..vi,"Square",{Position=Vector2.new(lx+6,oy+5),Size=Vector2.new(10,10),Filled=true,Color=sel and CT.accent or CT.section,ZIndex=62,Transparency=popOp,Corner=3})
                self:_D(wid.."_dot"..vi,"Text",{Position=Vector2.new(lx+22,oy+3),Text=opt,Size=12,Font=CurFont,Color=sel and CT.accent or CT.text,Outline=false,ZIndex=62,Transparency=popOp})
                if hov and Input.click and age>0.15 then
                    item.selected[opt]=not sel; local out={}; for _,o in ipairs(item.options) do if item.selected[o] then out[#out+1]=o end end; pcall(item.cb,out)
                end
            else
                local sel=(opt==item.value)
                if hov or sel then self:_D(wid.."_dhi"..vi,"Square",{Position=Vector2.new(lx,oy),Size=Vector2.new(lw,optH),Filled=true,Color=sel and Color3.fromRGB(10,40,80) or Color3.fromRGB(20,20,35),ZIndex=61,Transparency=popOp}) else self:_U(wid.."_dhi"..vi) end
                self:_D(wid.."_dot"..vi,"Text",{Position=Vector2.new(lx+8,oy+3),Text=opt,Size=12,Font=CurFont,Color=sel and CT.accent or CT.text,Outline=false,ZIndex=62,Transparency=popOp})
                if hov and Input.click and age>0.15 then item.value=opt; pcall(item.cb,opt); self._ddTarget=nil end
            end
        end
        for vi=vc+1,maxV+2 do self:_U(wid.."_dhi"..vi); self:_U(wid.."_dot"..vi); self:_U(wid.."_dcb"..vi) end
        if Input.click and age>0.15 and not over(Vector2.new(lx,ly),Vector2.new(lw,lh)) then self._ddTarget=nil end
    end

    -- ── Color Picker Popup Renderer ─────────────────────────
    function WIN:_renderCPPopup(wid,item,px,py,pw)
        local age=os.clock()-self._cpOpenT; local popOp=clamp(age/0.12,0,1)
        local palH=72; local hueH=10; local preH=14; local totH=palH+hueH+6+preH+8
        self:_D(wid.."_cpbg","Square",{Position=Vector2.new(px-4,py-4),Size=Vector2.new(pw+8,totH+8),Filled=true,Color=Color3.fromRGB(10,10,20),ZIndex=60,Transparency=popOp,Corner=8})
        self:_D(wid.."_cpbd","Square",{Position=Vector2.new(px-4,py-4),Size=Vector2.new(pw+8,totH+8),Filled=false,Color=CT.border2,Thickness=1,ZIndex=61,Transparency=popOp,Corner=8})
        local cols,rows=14,12; local cw2,rh=pw/cols,palH/rows
        for ci=0,cols-1 do for ri=0,rows-1 do
            self:_D(wid.."_sv"..ci.."_"..ri,"Square",{Position=Vector2.new(px+ci*cw2,py+ri*rh),Size=Vector2.new(cw2+0.5,rh+0.5),Filled=true,Color=hsvToRgb(item.h,(ci+0.5)/cols,1-(ri+0.5)/rows),ZIndex=62,Transparency=popOp})
        end end
        self:_D(wid.."_cpbb","Square",{Position=Vector2.new(px,py),Size=Vector2.new(pw,palH),Filled=false,Color=CT.border2,Thickness=1,ZIndex=63,Transparency=popOp})
        local cX2=px+item.s*pw; local cY2=py+(1-item.v)*palH
        self:_D(wid.."_ch","Line",{From=Vector2.new(px,cY2),To=Vector2.new(px+pw,cY2),Thickness=1,Color=Color3.new(1,1,1),ZIndex=64,Transparency=popOp})
        self:_D(wid.."_cv","Line",{From=Vector2.new(cX2,py),To=Vector2.new(cX2,py+palH),Thickness=1,Color=Color3.new(1,1,1),ZIndex=64,Transparency=popOp})
        local hueY=py+palH+4; local segs=20
        for hi=0,segs-1 do self:_D(wid.."_hu"..hi,"Square",{Position=Vector2.new(px+hi*(pw/segs),hueY),Size=Vector2.new(pw/segs+0.5,hueH),Filled=true,Color=hsvToRgb(hi/segs,1,1),ZIndex=62,Transparency=popOp}) end
        self:_D(wid.."_hbd","Square",{Position=Vector2.new(px,hueY),Size=Vector2.new(pw,hueH),Filled=false,Color=CT.border2,Thickness=1,ZIndex=63,Transparency=popOp})
        local hcX2=px+item.h*pw
        self:_D(wid.."_hcr","Square",{Position=Vector2.new(hcX2-2,hueY-1),Size=Vector2.new(4,hueH+2),Filled=false,Color=Color3.new(1,1,1),Thickness=1,ZIndex=64,Transparency=popOp})
        local col=hsvToRgb(item.h,item.s,item.v); local preY=hueY+hueH+4; local preW2=math.floor(pw*0.42)
        self:_D(wid.."_pre","Square",{Position=Vector2.new(px,preY),Size=Vector2.new(preW2,preH),Filled=true,Color=col,ZIndex=62,Corner=3,Transparency=popOp})
        self:_D(wid.."_preb","Square",{Position=Vector2.new(px,preY),Size=Vector2.new(preW2,preH),Filled=false,Color=CT.border2,Thickness=1,ZIndex=63,Corner=3,Transparency=popOp})
        local hex=string.format("#%02X%02X%02X",math.floor(col.R*255),math.floor(col.G*255),math.floor(col.B*255))
        self:_D(wid.."_hex","Text",{Position=Vector2.new(px+preW2+6,preY+1),Text=hex,Size=10,Font=F_MONO,Color=CT.sub,Outline=false,ZIndex=63,Transparency=popOp})
        if over(Vector2.new(px,py),Vector2.new(pw,palH)) and Input.click then self._cpDragSV=true end
        if over(Vector2.new(px,hueY),Vector2.new(pw,hueH)) and Input.click then self._cpDragH=true end
        if not Input.held then self._cpDragSV=false; self._cpDragH=false end
        if self._cpDragSV then local m=mpos(); item.s=clamp((m.X-px)/pw,0,1); item.v=1-clamp((m.Y-py)/palH,0,1); item.value=hsvToRgb(item.h,item.s,item.v); pcall(item.cb,item.value) end
        if self._cpDragH then item.h=clamp((mpos().X-px)/pw,0,1); item.value=hsvToRgb(item.h,item.s,item.v); pcall(item.cb,item.value) end
        local age2=os.clock()-self._cpOpenT
        if Input.click and age2>0.15 and not self._cpDragSV and not self._cpDragH and not over(Vector2.new(px-4,py-4),Vector2.new(pw+8,totH+8)) then self._cpTarget=nil end
    end

    -- ── Main Render ─────────────────────────────────────────
    function WIN:_render()
        local pos=self._pos; local sz=self.Size; local t=os.clock()
        W_W=sz.X; W_H=sz.Y; COL_W=math.floor((W_W-PAD*2-CGAP)/2); IW=COL_W-20
        self._blockClicks=false; self._deferredDrop=nil; self._deferredCP=nil
        self._tooltip=nil; self._tooltipHoverWid=nil
        updateTint()

        if not self._open then self:_UPfx("m_"); return end

        -- Collapse anim
        local colT=self._collapsed and 0 or 1
        self._collapseAnim=lerp(self._collapseAnim,colT,0.15)
        if math.abs(self._collapseAnim-colT)<0.01 then self._collapseAnim=colT end
        local colA=self._collapseAnim
        local contentH=math.floor((W_H-TOP_H)*colA)
        local totalH=TOP_H+contentH

        local menuAge=t-(self._menuToggledAt or 0); local menuOp=clamp(menuAge/0.2,0,1)

        self:_BF()

        -- ── TOPBAR ──────────────────────────────────────
        self:_D("m_bg","Square",{Position=pos,Size=Vector2.new(W_W,totalH),Filled=true,Color=CT.bg,ZIndex=1,Transparency=menuOp,Corner=13})
        self:_D("m_bg2","Square",{Position=pos+Vector2.new(0,13),Size=Vector2.new(W_W,totalH-13),Filled=true,Color=CT.bg,ZIndex=1,Transparency=menuOp})
        self:_D("m_top","Square",{Position=pos,Size=Vector2.new(W_W,TOP_H),Filled=true,Color=CT.topbar,ZIndex=2,Transparency=menuOp,Corner=13})
        self:_D("m_top2","Square",{Position=pos+Vector2.new(0,13),Size=Vector2.new(W_W,TOP_H-13),Filled=true,Color=CT.topbar,ZIndex=2,Transparency=menuOp})
        self:_D("m_topln","Line",{From=pos+Vector2.new(0,TOP_H),To=pos+Vector2.new(W_W,TOP_H),Thickness=1,Color=CT.border,ZIndex=3,Transparency=menuOp})

        -- Dots
        local dy=pos.Y+TOP_H/2
        self:_D("m_dr","Circle",{Position=Vector2.new(pos.X+20,dy),Radius=5,Filled=true,Color=Color3.fromRGB(255,95,86),ZIndex=4,Transparency=menuOp})
        self:_D("m_dy","Circle",{Position=Vector2.new(pos.X+36,dy),Radius=5,Filled=true,Color=Color3.fromRGB(255,189,46),ZIndex=4,Transparency=menuOp})
        self:_D("m_dg","Circle",{Position=Vector2.new(pos.X+52,dy),Radius=5,Filled=true,Color=Color3.fromRGB(39,201,63),ZIndex=4,Transparency=menuOp})
        -- Dot clicks
        if Input.click then
            if over(Vector2.new(pos.X+15,dy-5),Vector2.new(10,10)) then self:Notify("Script killed.",self.Title,2); self._running=false end
            if over(Vector2.new(pos.X+31,dy-5),Vector2.new(10,10)) then self._collapsed=not self._collapsed end
            if over(Vector2.new(pos.X+47,dy-5),Vector2.new(10,10)) then self._collapsed=false end
        end
        -- User
        self:_D("m_user","Text",{Position=Vector2.new(pos.X+68,dy-5),Text=self.User,Size=12,Font=F_BOLD,Color=CT.text,Outline=false,ZIndex=4,Transparency=menuOp})
        -- Hamburger / X
        local bx=pos.X+W_W-26; local by=dy
        if self._sbOpen then
            self:_D("m_hb1","Line",{From=Vector2.new(bx+1,by-5),To=Vector2.new(bx+16,by+5),Thickness=1.5,Color=CT.sub,ZIndex=4,Transparency=menuOp})
            self:_D("m_hb2","Line",{From=Vector2.new(bx+1,by+5),To=Vector2.new(bx+16,by-5),Thickness=1.5,Color=CT.sub,ZIndex=4,Transparency=menuOp})
            self:_U("m_hb3")
        else
            self:_D("m_hb1","Line",{From=Vector2.new(bx,by-5),To=Vector2.new(bx+17,by-5),Thickness=1.5,Color=CT.sub,ZIndex=4,Transparency=menuOp})
            self:_D("m_hb2","Line",{From=Vector2.new(bx,by),To=Vector2.new(bx+17,by),Thickness=1.5,Color=CT.sub,ZIndex=4,Transparency=menuOp})
            self:_D("m_hb3","Line",{From=Vector2.new(bx,by+5),To=Vector2.new(bx+17,by+5),Thickness=1.5,Color=CT.sub,ZIndex=4,Transparency=menuOp})
        end
        if Input.click and over(Vector2.new(pos.X+W_W-40,pos.Y),Vector2.new(40,TOP_H)) then
            self._sbOpen=not self._sbOpen; self._ddTarget=nil; self._cpTarget=nil
        end

        -- Drag
        if Input.click and over(pos,Vector2.new(W_W-45,TOP_H)) and not self._drag and not self._resizing then self._drag=mpos()-pos end
        if not Input.held then self._drag=nil end
        if self._drag then self._pos=mpos()-self._drag; pos=self._pos end

        -- Don't render content if collapsed
        if colA<0.02 then self:_UPfx("m_sb_"); self:_UPfx("m_pg_"); self:_FF(); return end

        -- ── RESIZE ──────────────────────────────────────
        if not self._collapsed and colA>0.9 then
            local gpos=pos+Vector2.new(W_W-14,totalH-14)
            self:_D("m_g1","Line",{From=gpos+Vector2.new(4,12),To=gpos+Vector2.new(12,4),Thickness=1,Color=CT.sub,ZIndex=10,Transparency=menuOp*0.6})
            self:_D("m_g2","Line",{From=gpos+Vector2.new(8,12),To=gpos+Vector2.new(12,8),Thickness=1,Color=CT.sub,ZIndex=10,Transparency=menuOp*0.6})
            if Input.click and over(gpos,Vector2.new(14,14)) and not self._drag then
                self._resizing=true; self._resizeStart={mouse=mpos(),size=Vector2.new(W_W,W_H)} end
        else self:_U("m_g1"); self:_U("m_g2") end
        if not Input.held then self._resizing=false end
        if self._resizing and self._resizeStart then
            local delta=mpos()-self._resizeStart.mouse
            self.Size=Vector2.new(math.max(self._minSize.X,self._resizeStart.size.X+delta.X),math.max(self._minSize.Y,self._resizeStart.size.Y+delta.Y))
            sz=self.Size; W_W=sz.X; W_H=sz.Y; COL_W=math.floor((W_W-PAD*2-CGAP)/2); IW=COL_W-20
        end

        -- ── SIDEBAR ─────────────────────────────────────
        local sbTarget=self._sbOpen and SB_W or 0
        self._sbW=self._sbW+(sbTarget-self._sbW)*0.12; local sw=math.floor(self._sbW)
        if sw>=1 then
            local sx=pos.X+W_W-sw; local sy=pos.Y+TOP_H; local sh=contentH
            self:_D("m_sb_bg","Square",{Position=Vector2.new(sx,sy),Size=Vector2.new(sw,sh),Filled=true,Color=CT.sidebar,ZIndex=20,Transparency=menuOp*0.96})
            if sw>4 then self:_D("m_sb_ln","Line",{From=Vector2.new(sx,sy),To=Vector2.new(sx,sy+sh),Thickness=1,Color=CT.border2,ZIndex=21,Transparency=menuOp}) else self:_U("m_sb_ln") end
            if sw>70 then
                local tx2=sx+7; local tw=sw-14; local th=30; local ty=sy+8
                for i,pg in ipairs(self._pages) do
                    if pg._isSettings then continue end
                    local act=(self._curPage==i); local hov=over(Vector2.new(tx2,ty),Vector2.new(tw,th))
                    if act then self:_D("m_sb_t"..i.."bg","Square",{Position=Vector2.new(tx2,ty),Size=Vector2.new(tw,th),Filled=true,Color=CT.accent,ZIndex=22,Transparency=menuOp*0.14,Corner=8})
                    elseif hov then self:_D("m_sb_t"..i.."bg","Square",{Position=Vector2.new(tx2,ty),Size=Vector2.new(tw,th),Filled=true,Color=CT.border,ZIndex=22,Transparency=menuOp*0.50,Corner=8})
                    else self:_U("m_sb_t"..i.."bg") end
                    self:_D("m_sb_t"..i.."bd","Square",{Position=Vector2.new(tx2,ty),Size=Vector2.new(tw,th),Filled=false,Color=Color3.new(1,1,1),Thickness=1,ZIndex=23,Transparency=menuOp*0.08,Corner=8})
                    self:_D("m_sb_t"..i.."tx","Text",{Position=Vector2.new(tx2+tw/2,ty+th/2),Text=pg._name,Size=12,Font=CurFont,Color=act and CT.accent or CT.text,Center=true,Outline=false,ZIndex=24,Transparency=menuOp})
                    if hov and Input.click then self._curPage=i; self._sbOpen=false; self._pageChangeAt=t; self._ddTarget=nil; self._cpTarget=nil end
                    ty=ty+th+5
                end
                -- Settings at bottom
                for i,pg in ipairs(self._pages) do if pg._isSettings then
                    local sty=sy+sh-th-8; local act=(self._curPage==i); local hov=over(Vector2.new(tx2,sty),Vector2.new(tw,th))
                    if act then self:_D("m_sb_set_bg","Square",{Position=Vector2.new(tx2,sty),Size=Vector2.new(tw,th),Filled=true,Color=CT.accent,ZIndex=22,Transparency=menuOp*0.14,Corner=8})
                    elseif hov then self:_D("m_sb_set_bg","Square",{Position=Vector2.new(tx2,sty),Size=Vector2.new(tw,th),Filled=true,Color=CT.border,ZIndex=22,Transparency=menuOp*0.50,Corner=8})
                    else self:_U("m_sb_set_bg") end
                    self:_D("m_sb_set_ln","Line",{From=Vector2.new(tx2,sty-6),To=Vector2.new(tx2+tw,sty-6),Thickness=1,Color=CT.border2,ZIndex=22,Transparency=menuOp})
                    self:_D("m_sb_set_tx","Text",{Position=Vector2.new(tx2+tw/2,sty+th/2),Text="Settings",Size=12,Font=CurFont,Color=act and CT.accent or CT.text,Center=true,Outline=false,ZIndex=24,Transparency=menuOp})
                    if hov and Input.click then self._curPage=i; self._sbOpen=false; self._pageChangeAt=t end
                end end
            end
        else self:_UPfx("m_sb_") end

        -- ── PAGE CONTENT ────────────────────────────────
        local page=self._pages[self._curPage]; if not page then self:_FF(); return end
        local pageAge=t-(self._pageChangeAt or 0); local pgOp=clamp(pageAge/0.25,0,1)*menuOp*colA
        -- Smooth scroll
        if not page._scrollSmooth then page._scrollSmooth=page.scroll end
        page._scrollSmooth=lerp(page._scrollSmooth,page.scroll,0.18)
        local sScroll=page._scrollSmooth

        local contTop=TOP_H+8; local maxViewY=TOP_H+contentH-4
        local colYL,colYR=0,0; local autoCol=1

        for si,sec in ipairs(page._sections) do
            local col=(sec._col==1 or sec._col==2) and sec._col or autoCol
            autoCol=autoCol==1 and 2 or 1
            local sx=col==1 and PAD or(PAD*2+COL_W); local sy=col==1 and colYL or colYR
            local sid="m_pg_"..si
            -- Section height
            local secH=32; for _,w in ipairs(sec._widgets) do secH=secH+wH(w)+5 end; secH=secH+8

            local renderY=pos.Y+contTop+sy-sScroll
            local secTopY=math.max(renderY,pos.Y+contTop); local secBotY=math.min(renderY+secH,pos.Y+maxViewY)
            local clmpH=secBotY-secTopY

            if clmpH>0 then
                self:_D(sid.."_bg","Square",{Position=Vector2.new(pos.X+sx,secTopY),Size=Vector2.new(COL_W,clmpH),Filled=true,Color=CT.section,ZIndex=4,Transparency=pgOp*0.45,Corner=10})
                self:_D(sid.."_bd","Square",{Position=Vector2.new(pos.X+sx,secTopY),Size=Vector2.new(COL_W,clmpH),Filled=false,Color=CT.border,Thickness=1,ZIndex=5,Transparency=pgOp*0.80,Corner=10})
            else self:_U(sid.."_bg"); self:_U(sid.."_bd") end

            if renderY+15>=pos.Y+contTop and renderY<pos.Y+maxViewY then
                self:_D(sid.."_hdr","Text",{Position=Vector2.new(pos.X+sx+12,renderY+8),Text=sec._name:upper(),Size=10,Font=F_BOLD,Color=CT.sub,Outline=false,ZIndex=6,Transparency=pgOp})
                self:_D(sid.."_hln","Line",{From=Vector2.new(pos.X+sx+10,renderY+23),To=Vector2.new(pos.X+sx+COL_W-10,renderY+23),Thickness=1,Color=CT.border,ZIndex=6,Transparency=pgOp})
            else self:_U(sid.."_hdr"); self:_U(sid.."_hln") end

            local wY=renderY+32; local innerX=pos.X+sx+10
            for wi,w in ipairs(sec._widgets) do
                local consumed=self:_renderWidget(w,sid.."_w"..wi,innerX,wY,IW,pos.Y+contTop,pos.Y+maxViewY)
                wY=wY+consumed+5
            end
            if col==1 then colYL=colYL+secH+10 else colYR=colYR+secH+10 end
        end

        -- ── SCROLL ──────────────────────────────────────
        local totalChH=math.max(colYL,colYR)
        page.maxScroll=math.max(0,totalChH-(maxViewY-contTop))
        if not self._ddTarget and not self._cpTarget then
            if iskeypressed(0x26) then self._scrollSpeed=math.min(self._scrollSpeed+1.5,40); page.scroll=math.max(0,page.scroll-self._scrollSpeed)
            elseif iskeypressed(0x28) then self._scrollSpeed=math.min(self._scrollSpeed+1.5,40); page.scroll=math.min(page.maxScroll,page.scroll+self._scrollSpeed)
            else self._scrollSpeed=0 end
        end

        -- ── DEFERRED POPUPS ─────────────────────────────
        if self._deferredDrop then self:_renderDDPopup(table.unpack(self._deferredDrop)) end
        if self._deferredCP then self:_renderCPPopup(table.unpack(self._deferredCP)) end

        -- ── TOOLTIP ─────────────────────────────────────
        if self._tooltip then
            local tp=self._tooltip; local tw2=textW(tp.text,12)+14; local scr=getScreen()
            local px=math.min(tp.x,scr.X-tw2-4); local py=math.max(tp.y,4)
            self:_D("m_tt_bg","Square",{Position=Vector2.new(px,py),Size=Vector2.new(tw2,20),Filled=true,Color=CT.section,ZIndex=300,Corner=6})
            self:_D("m_tt_bd","Square",{Position=Vector2.new(px,py),Size=Vector2.new(tw2,20),Filled=false,Color=CT.accent,Thickness=1,ZIndex=301,Corner=6})
            self:_D("m_tt_tx","Text",{Position=Vector2.new(px+7,py+3),Text=tp.text,Size=12,Font=CurFont,Color=CT.text,Outline=false,ZIndex=302})
        else self:_U("m_tt_bg"); self:_U("m_tt_bd"); self:_U("m_tt_tx") end

        self:_FF()
    end

    -- ── Main Loop ───────────────────────────────────────────
    task.spawn(function()
        WIN:_buildInfoTab(); WIN:_buildSettings()
        task.wait(0.2); WIN:LoadSettings()
        while WIN._running do
            task.wait()
            local rbx=isrbxactive()
            if not rbx then if WIN._open and WIN._blockInputsEnabled then pcall(setrobloxinput,true) end; continue end
            Input:update()
            if Input:keyClick(WIN.MenuKey) then
                WIN._open=not WIN._open; WIN._menuToggledAt=os.clock()
                if WIN._blockInputsEnabled then pcall(setrobloxinput,not WIN._open) end
                if not WIN._open then WIN._ddTarget=nil; WIN._textboxTarget=nil; WIN._listenKey=nil; WIN._cpTarget=nil; WIN._sbOpen=false end
            end
            if WIN._open and WIN._blockInputsEnabled then pcall(setrobloxinput,false) end
            WIN:_render()
        end
        pcall(setrobloxinput,true); WIN:_DestroyAll()
    end)
    return WIN
end

return GalaxUI
