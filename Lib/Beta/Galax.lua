--[[
    GalaxLib v2.0 - UI Library for Matcha External
    Rewritten with Jade-style fade animations
    Made with love by Claude x Galax x Gemini

    USAGE:
    local Win = GalaxLib:CreateWindow({ Title="GalaxLib Test", Size=Vector2.new(560,420), MenuKey=0x70 })
    local Tab = Win:AddTab("Combat")
    local Sec = Tab:AddSection("Aimbot")

    Sec:AddToggle("Enable", false, function(v) end)
    Sec:AddToggle("Show FOV", false, function(v) end, 0x46)
    Sec:AddSlider("FOV Size", {Min=1, Max=360, Default=90, Suffix="°"}, function(v) end)
    Sec:AddDropdown("Mode", {"A","B","C"}, "A", {MaxVisible=4}, function(v) end)
    Sec:AddMultiDropdown("Flags", {"A","B","C"}, {}, {MaxVisible=4}, function(tbl) end)
    Sec:AddColorPicker("Color", Color3.fromRGB(255,0,0), function(c) end)
    Sec:AddKeybind("Trigger", 0x46, function() end)
    Sec:AddTextbox("Name", "default", function(v) end)
    Sec:AddButton("Reset", function() end)

    Win:Notify("Loaded successfully!", "Galax", 3)
]]

GalaxLib = {}
GalaxLib.Updates = {}

-- ── Supporters ───────────────────────────────────────────────
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


-- ── Themes ───────────────────────────────────────────────────
local Themes = {
    Galax = {
        Body=Color3.fromRGB(10,10,14), Surface0=Color3.fromRGB(18,18,24), Surface1=Color3.fromRGB(26,26,34),
        Border0=Color3.fromRGB(35,35,46), Border1=Color3.fromRGB(50,50,65),
        Accent=Color3.fromRGB(130,80,220), AccentDark=Color3.fromRGB(70,38,140),
        Text=Color3.fromRGB(240,240,245), SubText=Color3.fromRGB(110,110,130),
        Red=Color3.fromRGB(220,70,70), RedDark=Color3.fromRGB(90,22,22),
    },
    Gamesense = {
        Body=Color3.fromRGB(0,0,0), Surface0=Color3.fromRGB(26,26,26), Surface1=Color3.fromRGB(45,45,45),
        Border0=Color3.fromRGB(48,48,48), Border1=Color3.fromRGB(60,60,60),
        Accent=Color3.fromRGB(114,178,21), AccentDark=Color3.fromRGB(60,100,10),
        Text=Color3.fromRGB(144,144,144), SubText=Color3.fromRGB(59,59,59),
        Red=Color3.fromRGB(220,70,70), RedDark=Color3.fromRGB(90,22,22),
    },
    Dracula = {
        Body=Color3.fromRGB(24,25,38), Surface0=Color3.fromRGB(33,34,50), Surface1=Color3.fromRGB(44,44,60),
        Border0=Color3.fromRGB(68,71,90), Border1=Color3.fromRGB(86,90,112),
        Accent=Color3.fromRGB(189,147,249), AccentDark=Color3.fromRGB(100,70,180),
        Text=Color3.fromRGB(248,248,242), SubText=Color3.fromRGB(98,114,164),
        Red=Color3.fromRGB(255,85,85), RedDark=Color3.fromRGB(120,30,30),
    },
    Nord = {
        Body=Color3.fromRGB(29,33,40), Surface0=Color3.fromRGB(36,41,50), Surface1=Color3.fromRGB(46,52,64),
        Border0=Color3.fromRGB(59,66,82), Border1=Color3.fromRGB(76,86,106),
        Accent=Color3.fromRGB(136,192,208), AccentDark=Color3.fromRGB(67,103,120),
        Text=Color3.fromRGB(236,239,244), SubText=Color3.fromRGB(129,161,193),
        Red=Color3.fromRGB(191,97,106), RedDark=Color3.fromRGB(90,40,44),
    },
    Catppuccin = {
        Body=Color3.fromRGB(24,24,37), Surface0=Color3.fromRGB(30,30,46), Surface1=Color3.fromRGB(49,50,68),
        Border0=Color3.fromRGB(88,91,112), Border1=Color3.fromRGB(108,111,133),
        Accent=Color3.fromRGB(137,180,250), AccentDark=Color3.fromRGB(60,90,160),
        Text=Color3.fromRGB(205,214,244), SubText=Color3.fromRGB(166,173,200),
        Red=Color3.fromRGB(243,139,168), RedDark=Color3.fromRGB(120,50,70),
    },
    Synthwave = {
        Body=Color3.fromRGB(15,5,30), Surface0=Color3.fromRGB(25,10,45), Surface1=Color3.fromRGB(40,15,65),
        Border0=Color3.fromRGB(80,30,100), Border1=Color3.fromRGB(120,50,140),
        Accent=Color3.fromRGB(255,60,180), AccentDark=Color3.fromRGB(130,20,90),
        Text=Color3.fromRGB(255,220,255), SubText=Color3.fromRGB(180,120,200),
        Red=Color3.fromRGB(255,80,80), RedDark=Color3.fromRGB(100,20,20),
    },
    Sunset = {
        Body=Color3.fromRGB(18,8,5), Surface0=Color3.fromRGB(30,14,8), Surface1=Color3.fromRGB(48,22,12),
        Border0=Color3.fromRGB(80,40,20), Border1=Color3.fromRGB(110,60,30),
        Accent=Color3.fromRGB(255,120,40), AccentDark=Color3.fromRGB(140,55,10),
        Text=Color3.fromRGB(255,235,210), SubText=Color3.fromRGB(180,130,90),
        Red=Color3.fromRGB(255,70,50), RedDark=Color3.fromRGB(110,20,10),
    },
}
local T = {}
for k,v in pairs(Themes.Galax) do T[k]=v end
local ThemeNames = {"Galax","Gamesense","Dracula","Nord","Catppuccin","Synthwave","Sunset"}
local FontNames  = {"UI","System","SystemBold","Minecraft","Monospace","Pixel","Fortnite"}
local FontMap = {
    UI=Drawing.Fonts.UI, System=Drawing.Fonts.System, SystemBold=Drawing.Fonts.SystemBold,
    Minecraft=Drawing.Fonts.Minecraft, Monospace=Drawing.Fonts.Monospace,
    Pixel=Drawing.Fonts.Pixel, Fortnite=Drawing.Fonts.Fortnite,
}
local CurrentFont = Drawing.Fonts.UI
local function applyFont(name) if FontMap[name] then CurrentFont = FontMap[name] end end
local function applyTheme(name) local src=Themes[name]; if not src then return end; for k,v in pairs(src) do T[k]=v end end

-- ── Key Names ────────────────────────────────────────────────
local KeyNames = {}
do
    local raw = {[0x08]="BACK",[0x09]="TAB",[0x0D]="ENTER",[0x10]="SHIFT",[0x11]="CTRL",[0x12]="ALT",[0x14]="CAPS",[0x1B]="ESC",[0x20]="SPACE",[0x21]="PGUP",[0x22]="PGDN",[0x23]="END",[0x24]="HOME",[0x25]="LEFT",[0x26]="UP",
        [0x27]="RIGHT",[0x28]="DOWN",[0x2D]="INS",[0x2E]="DEL",[0x30]="0",[0x31]="1",[0x32]="2",[0x33]="3",[0x34]="4",[0x35]="5",[0x36]="6",[0x37]="7",[0x38]="8",[0x39]="9",
        [0xBA]=";",[0xBB]="=",[0xBC]=",",[0xBD]="-",[0xBE]=".",[0xBF]="/",[0xC0]="`",[0xDB]="[",[0xDC]="\\",[0xDD]="]",[0xDE]="'"}
    for k,v in pairs(raw) do KeyNames[k]=v end
    for i=65,90 do KeyNames[i]=string.char(i) end
    for i=1,12  do KeyNames[0x6F+i]="F"..i end
end
local function keyName(kc) return KeyNames[kc] or ("0x"..string.format("%X",kc or 0)) end

-- ── Utilities ────────────────────────────────────────────────
local function clamp(x,a,b) return x<a and a or (x>b and b or x) end
local function wrapText(str, maxW, sz)
    local charW = (sz or 13) * 0.54
    local maxChars = math.max(1, math.floor(maxW / charW))
    local lines = {}
    local remaining = str
    while #remaining > 0 do
        if #remaining <= maxChars then table.insert(lines, remaining); break end
        local cut = maxChars
        local space = remaining:sub(1, cut):match(".*()%s")
        if space and space > 1 then cut = space - 1 end
        table.insert(lines, remaining:sub(1, cut))
        remaining = remaining:sub(cut + 1):match("^%s*(.*)")
    end
    return lines
end
local FontWidthFactor = {
    [Drawing.Fonts.UI]=0.54,[Drawing.Fonts.System]=0.60,[Drawing.Fonts.SystemBold]=0.63,
    [Drawing.Fonts.Minecraft]=0.60,[Drawing.Fonts.Monospace]=0.62,[Drawing.Fonts.Pixel]=0.54,[Drawing.Fonts.Fortnite]=0.58,
}
local function textW(str,sz,font) return #(str or "")*(sz or 13)*(FontWidthFactor[font or CurrentFont] or 0.54) end
local function mpos()
    local lp=game:GetService("Players").LocalPlayer
    if lp then local m=lp:GetMouse(); if m then return Vector2.new(m.X,m.Y) end end
    return Vector2.new(0,0)
end
local function over(pos,size)
    local m=mpos(); return m.X>=pos.X and m.X<=pos.X+size.X and m.Y>=pos.Y and m.Y<=pos.Y+size.Y
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
    local r,g,b=c.R,c.G,c.B; local mx=math.max(r,g,b); local mn=math.min(r,g,b); local d=mx-mn
    local h=0
    if d~=0 then
        if mx==r then h=((g-b)/d)%6 elseif mx==g then h=(b-r)/d+2 else h=(r-g)/d+4 end; h=h/6
    end
    return h, mx==0 and 0 or d/mx, mx
end
local function pointOnRect(t,pos,sz)
    local p=(t%1)*(sz.X*2+sz.Y*2)
    if p<sz.X then return pos+Vector2.new(p,0)
    elseif p<sz.X+sz.Y then return pos+Vector2.new(sz.X,p-sz.X)
    elseif p<sz.X*2+sz.Y then return pos+Vector2.new(sz.X-(p-(sz.X+sz.Y)),sz.Y)
    else return pos+Vector2.new(0,sz.Y-(p-(sz.X*2+sz.Y))) end
end

-- ── Input Tracker ────────────────────────────────────────────
local Input={_prev={},click=false,held=false,rclick=false,scrollUp=false,scrollDown=false}
function Input:update()
    local m1=ismouse1pressed(); local m2=ismouse2pressed()
    self.click=m1 and not(self._prev.m1 or false); self.held=m1
    self.rclick=m2 and not(self._prev.m2 or false)
    self._prev.m1=m1; self._prev.m2=m2
    local wu=iskeypressed(0x26); local wd=iskeypressed(0x28)
    self.scrollUp=wu and not(self._prev.wu or false)
    self.scrollDown=wd and not(self._prev.wd or false)
    self._prev.wu=wu; self._prev.wd=wd
end
function Input:keyClick(kc)
    local cur=iskeypressed(kc); local prv=self._prev[kc] or false
    self._prev[kc]=cur; return cur and not prv
end
function Input:keyHeld(kc) return iskeypressed(kc) end

-- ============================================================
--  CREATE WINDOW
-- ============================================================
function GalaxLib:CreateWindow(opts)
    opts=opts or {}
    local WIN={
        Title=opts.Title or "Galax", Size=opts.Size or Vector2.new(560,420),
        _minSize=opts.Size or Vector2.new(560,420),
        MenuKey=opts.MenuKey or 0x70,
        _pos=Vector2.new(opts.X or 120,opts.Y or 100),
        _open=true, _running=true, _tabs={}, _openTab=nil,
        _startMinimized=false, _blockInputsEnabled=true,
        -- Drawing system (Jade-style)
        _drawings={}, _seen={},
        -- Fade timestamps removed
        -- Interaction state
        _drag=nil, _sliderDrag=nil, _keybindTarget=nil, _textboxTarget=nil,
        _openDropId=nil, _cpTarget=nil, _settingsListen=false,
        _dragTabScroll=false, _blockClicks=false,
        -- Deferred popup data
        _deferredDrop=nil, _deferredCP=nil,
        -- Snake animation
        _snakeLines={}, _snakeCount=18,
    }
    for i=1,WIN._snakeCount do
        local l=Drawing.new("Line"); l.Thickness=1.5; l.Visible=false; l.ZIndex=50
        WIN._snakeLines[i]=l
    end

    if isrbxactive() then setrobloxinput(false) end

    -- ── Jade-Style Drawing System ────────────────────────────
    function WIN:_Draw(id, dtype, props)
        self._seen[id]=true
        local d=self._drawings[id]
        if not d then d=Drawing.new(dtype); self._drawings[id]=d end
        for k,v in pairs(props) do d[k]=v end
        d.Visible=true; return d
    end
    function WIN:_Undraw(id) local d=self._drawings[id]; if d then d.Visible=false end end
    function WIN:_SetOpacity(id,op) local d=self._drawings[id]; if d then d.Transparency=op end end
    function WIN:_UndrawStartsWith(pfx)
        for id,d in pairs(self._drawings) do if id:sub(1,#pfx)==pfx then d.Visible=false end end
    end
    function WIN:_SetOpacityStartsWith(pfx,op)
        for id,d in pairs(self._drawings) do if id:sub(1,#pfx)==pfx then d.Transparency=op end end
    end
    function WIN:_RemoveStartsWith(pfx)
        for id,d in pairs(self._drawings) do
            if id:sub(1,#pfx)==pfx then d:Remove(); self._drawings[id]=nil end
        end
    end
    function WIN:_BeginFrame() self._seen={} end
    function WIN:_FlushFrame()
        for id,d in pairs(self._drawings) do if not self._seen[id] then d.Visible=false end end
    end
    function WIN:_DestroyAll()
        for _,d in pairs(self._drawings) do d:Remove() end; self._drawings={}; self._seen={}
    end

    -- ── AddTab / AddSection / Widgets ────────────────────────
    function WIN:AddTab(name)
        local TAB={_name=name,_sections={},_win=self,scroll=0,maxScroll=0}
        function TAB:AddSection(sname)
            local SEC={_name=sname,_widgets={},_win=self._win}
            local function reg(item) table.insert(SEC._widgets,item) end

            function SEC:AddToggle(label,default,cb,keybind)
                local item={type="toggle",label=label,value=default or false,cb=cb or function()end,keybind=keybind or nil,kb_listening=false,kb_wasM1=false}
                reg(item); pcall(item.cb, item.value)
                return{Get=function()return item.value end, Set=function(_,v)item.value=v; pcall(item.cb, v) end}
            end
            function SEC:AddSlider(label,o,cb)
                o=o or {}
                local item={type="slider",label=label,min=o.Min or 0,max=o.Max or 100,value=o.Default or o.Min or 0,suffix=o.Suffix or "",cb=cb or function()end}
                reg(item); pcall(item.cb, item.value)
                return{Get=function()return item.value end,Set=function(_,v)item.value=clamp(v,item.min,item.max); pcall(item.cb, item.value) end}
            end
            function SEC:AddButton(label,cb)
                reg({type="button",label=label,cb=cb or function()end}); return{}
            end
            function SEC:AddDropdown(label,options,default,opts2,cb)
                if type(opts2)=="function" then cb=opts2; opts2={} end; opts2=opts2 or {}
                local item={type="dropdown",label=label,options=options or {},value=default or (options and options[1]) or "",maxVisible=opts2.MaxVisible or 5,scroll=0,cb=cb or function()end}
                reg(item); pcall(item.cb, item.value)
                return{Get=function()return item.value end,Set=function(_,v)item.value=v; pcall(item.cb, v) end,
                    Refresh=function(_,newOpts,newDef) item.options=newOpts or {}; item.scroll=0; item.value=newDef or (newOpts and newOpts[1]) or ""; pcall(item.cb, item.value) end}
            end
            function SEC:AddMultiDropdown(label,options,default,opts2,cb)
                if type(opts2)=="function" then cb=opts2; opts2={} end; opts2=opts2 or {}
                local sel={}; if default then for _,v in ipairs(default) do sel[v]=true end end
                local item={type="multidropdown",label=label,options=options or {},selected=sel,maxVisible=opts2.MaxVisible or 5,scroll=0,cb=cb or function()end}
                reg(item)
                local function getList() local out={}; for _,o in ipairs(item.options) do if item.selected[o] then out[#out+1]=o end end; return out end
                pcall(item.cb, getList())
                return{Get=function()return getList()end,
                    Set=function(_,tbl) item.selected={}; if tbl then for _,v in ipairs(tbl) do item.selected[v]=true end end; pcall(item.cb, getList()) end,
                    Refresh=function(_,newOpts,newDef) item.options=newOpts or {}; item.selected={}; item.scroll=0; if newDef then for _,v in ipairs(newDef) do item.selected[v]=true end end; pcall(item.cb, getList()) end}
            end
            function SEC:AddColorPicker(label,default,cb)
                local h,s,v=0,1,1; if default then h,s,v=rgbToHsv(default) end
                local item={type="colorpicker",label=label,h=h,s=s,v=v,value=default or Color3.new(1,0,0),cb=cb or function()end,dragSV=false,dragH=false}
                reg(item); pcall(item.cb, item.value)
                return{Get=function()return item.value end, Set=function(_,c)item.value=c;local hh,ss,vv=rgbToHsv(c);item.h=hh;item.s=ss;item.v=vv; pcall(item.cb, c) end}
            end
            function SEC:AddKeybind(label,default,cb)
                local item={type="keybind",label=label,value=default or 0,cb=cb or function()end,listening=false}
                reg(item)
                return{Get=function()return item.value end,Set=function(_,v)item.value=v; pcall(item.cb, v) end}
            end
            function SEC:AddTextbox(label,default,cb)
                local item={type="textbox",label=label,value=default or "",cb=cb or function()end}
                reg(item)
                return{Get=function()return item.value end,Set=function(_,v)item.value=v; pcall(item.cb, v) end}
            end
            function SEC:AddLabel(text)
                local item={type="label",label=text or ""}; reg(item)
                return{Get=function()return item.label end,Set=function(_,v)item.label=v end}
            end
            table.insert(TAB._sections,SEC); return SEC
        end
        table.insert(self._tabs,TAB)
        if not self._openTab then self._openTab=TAB end
        return TAB
    end

    -- ── CONFIG SYSTEM ────────────────────────────────────────
    function WIN:GetConfigData()
        local data = {}
        for _, tab in ipairs(self._tabs) do
            if tab._isSettings or tab._isInfo then continue end
            data[tab._name] = {}
            for _, sec in ipairs(tab._sections) do
                data[tab._name][sec._name] = {}
                for _, w in ipairs(sec._widgets) do
                    if w.type == "toggle" then
                        data[tab._name][sec._name][w.label] = { value = w.value, keybind = w.keybind }
                    elseif w.type == "slider" or w.type == "dropdown" or w.type == "textbox" or w.type == "keybind" then
                        data[tab._name][sec._name][w.label] = w.value
                    elseif w.type == "multidropdown" then
                        local sel = {}
                        for _, opt in ipairs(w.options) do if w.selected[opt] then sel[#sel+1] = opt end end
                        data[tab._name][sec._name][w.label] = sel
                    elseif w.type == "colorpicker" then
                        data[tab._name][sec._name][w.label] = { R = w.value.R, G = w.value.G, B = w.value.B }
                    end
                end
            end
        end
        return data
    end

    function WIN:SaveConfig()
        local success = pcall(function()
            local json = game:GetService("HttpService"):JSONEncode(self:GetConfigData())
            pcall(makefolder, "Galax"); pcall(makefolder, "Galax/Scripts")
            writefile("Galax/Scripts/" .. string.gsub(self.Title, "[^%w%s]", "") .. ".json", json)
        end)
        self:Notify(success and "Saved to Galax/Scripts" or "Failed to save config!", success and "Config Saved" or "Config Error", success and 3 or 4)
    end

    function WIN:LoadConfig(silent, isAutoLoad)
        local safeTitle = string.gsub(self.Title, "[^%w%s]", "")
        local ok, content = pcall(readfile, "Galax/Scripts/" .. safeTitle .. ".json")
        if not ok or type(content) ~= "string" or content == "" then
            if not silent then self:Notify("No config found for this script.", "Config", 3) end; return false
        end
        local dok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(content) end)
        if not dok or type(data) ~= "table" then
            if not silent then self:Notify("Failed to parse config file.", "Config Error", 4) end; return false
        end
        for _, tab in ipairs(self._tabs) do
            if tab._isSettings or tab._isInfo then continue end
            local tabData = data[tab._name]
            if type(tabData) == "table" then
                for _, sec in ipairs(tab._sections) do
                    local secData = tabData[sec._name]
                    if type(secData) == "table" then
                        for _, w in ipairs(sec._widgets) do
                            local val = secData[w.label]
                            if val ~= nil then pcall(function()
                                if w.type == "toggle" and type(val) == "table" then
                                    if val.value ~= nil then w.value = val.value end
                                    if val.keybind ~= nil then w.keybind = val.keybind end
                                    pcall(w.cb, w.value)
                                elseif w.type == "colorpicker" and type(val) == "table" and val.R and val.G and val.B then
                                    w.value = Color3.new(val.R, val.G, val.B)
                                    w.h, w.s, w.v = rgbToHsv(w.value); pcall(w.cb, w.value)
                                elseif w.type == "multidropdown" and type(val) == "table" then
                                    w.selected = {}; for _, opt in ipairs(val) do w.selected[opt] = true end
                                    local out = {}; for _,o in ipairs(w.options) do if w.selected[o] then out[#out+1]=o end end
                                    pcall(w.cb, out)
                                elseif w.type == "slider" or w.type == "dropdown" or w.type == "textbox" or w.type == "keybind" then
                                    w.value = val; pcall(w.cb, w.value)
                                end
                            end) end
                        end
                    end
                end
            end
        end
        if isAutoLoad then self:Notify("Auto-loaded config successfully!", "Config System", 3)
        elseif not silent then self:Notify("Loaded config successfully!", "Config System", 3) end
        return true
    end

    function WIN:SaveSettings()
        local data = { theme="Galax", menuKey=self.MenuKey, startMin=self._startMinimized, blockInputs=self._blockInputsEnabled, font="UI", skipLoader=self._skipLoader or false }
        for _, tab in ipairs(self._tabs) do
            if tab._isSettings then
                for _, sec in ipairs(tab._sections) do for _, w in ipairs(sec._widgets) do
                    if w.type == "dropdown" and w.label == "Change your theme" then data.theme = w.value
                    elseif w.type == "dropdown" and w.label == "Font" then data.font = w.value end
                end end
            end
        end
        pcall(makefolder, "Galax"); pcall(makefolder, "Galax/Settings")
        pcall(writefile, "Galax/Settings/Galax.json", game:GetService("HttpService"):JSONEncode(data))
        -- Write dedicated SkipLoader file for the loaders to read
        local skipVal = self._skipLoader and "true" or "false"
        pcall(writefile, "Galax/Settings/SkipLoader.lua", "SkipLoader = " .. skipVal)
    end

    function WIN:LoadSettings()
        local ok, content = pcall(readfile, "Galax/Settings/Galax.json")
        if not ok or type(content) ~= "string" or content == "" then return end
        local dok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(content) end)
        if not dok or type(data) ~= "table" then return end
        if data.theme then applyTheme(data.theme) end
        if data.menuKey then self.MenuKey = data.menuKey end
        if data.startMin ~= nil then self._startMinimized = data.startMin; if data.startMin then self._open = false; pcall(setrobloxinput, true) end end
        if data.font then applyFont(data.font) end
        if data.blockInputs ~= nil then self._blockInputsEnabled = data.blockInputs; if not data.blockInputs then pcall(setrobloxinput, true) end end
        if data.skipLoader ~= nil then self._skipLoader = data.skipLoader end
        for _, tab in ipairs(self._tabs) do if tab._isSettings then
            for _, sec in ipairs(tab._sections) do for _, w in ipairs(sec._widgets) do
                if w.type == "dropdown" and w.label == "Change your theme" then w.value = data.theme or "Galax"
                elseif w.type == "dropdown" and w.label == "Font" then w.value = data.font or "UI"
                elseif w.type == "settings_toggle" and w.label == "Start Minimized" then w.value = data.startMin or false
                elseif w.type == "settings_toggle" and w.label == "Block Inputs" then w.value = data.blockInputs ~= false
                elseif w.type == "settings_toggle" and w.label == "Skip Loader" then w.value = data.skipLoader or false end
            end end
        end end
    end

    function WIN:_buildSettings()
        local STAB={_name="Settings",_sections={},_win=self,_isSettings=true,scroll=0,maxScroll=0}
        local SMENU={_name="Menu",_widgets={},_win=self}
        table.insert(SMENU._widgets,{type="settings_keybind",label="Toggle Key",listening=false})
        table.insert(SMENU._widgets,{type="settings_toggle",label="Start Minimized",value=false})
        table.insert(SMENU._widgets,{type="settings_toggle",label="Block Inputs",value=true})
        table.insert(SMENU._widgets,{type="settings_toggle",label="Skip Loader",value=false})
        table.insert(SMENU._widgets,{type="settings_kill",label="Kill Script"})
        table.insert(STAB._sections,SMENU)
        local STHEME={_name="Theme",_widgets={},_win=self}
        table.insert(STHEME._widgets,{type="dropdown",label="Change your theme",options=ThemeNames,value="Galax",maxVisible=5,scroll=0,cb=function(v)applyTheme(v); self:SaveSettings() end})
        table.insert(STHEME._widgets,{type="dropdown",label="Font",options=FontNames,value="UI",maxVisible=5,scroll=0,cb=function(v)applyFont(v); self:SaveSettings() end})
        table.insert(STAB._sections,STHEME)
        local SCONFIG={_name="Config",_widgets={},_win=self}
        table.insert(SCONFIG._widgets,{type="settings_save",label="Save Config",cb=function() self:SaveConfig() end})
        table.insert(SCONFIG._widgets,{type="settings_load",label="Load Config",cb=function() self:LoadConfig(false, false) end})
        table.insert(STAB._sections,SCONFIG)
        table.insert(self._tabs,STAB)
    end

    function WIN:_buildInfoTab()
        local ITAB={_name="Info",_sections={},_win=self,_isInfo=true,scroll=0,maxScroll=0}
        local SUPD={_name="Updates",_widgets={},_win=self}
        if #GalaxLib.Updates == 0 then table.insert(SUPD._widgets,{type="label",label="No updates yet."})
        else for _,line in ipairs(GalaxLib.Updates) do table.insert(SUPD._widgets,{type="label",label=tostring(line)}) end end
        table.insert(ITAB._sections,SUPD)
        local SSUP={_name="Supporters",_widgets={},_win=self}
        if #_Supporters == 0 then table.insert(SSUP._widgets,{type="label",label="No supporters yet. Be the first!"})
        else for _,s in ipairs(_Supporters) do table.insert(SSUP._widgets,{type="supporter_label",text=s.text,color=s.color}) end end
        table.insert(ITAB._sections,SSUP)
        table.insert(self._tabs,1,ITAB)
        if self._openTab == nil or self._openTab == self._tabs[2] then self._openTab = ITAB end
    end



    function WIN:Notify(msg,title,dur) notify(msg,title or self.Title,dur or 3) end
    function WIN:Unload() self._running=false end

    -- ── Widget Height ─────────────────────────────────────────
    local function getWidgetHeight(item, win)
        if item.type=="label" then
            local colW = (win.Size.X - 10*3) / 2; local innerW = colW - 16
            local lines = wrapText(item.label, innerW, 13)
            return math.max(20, #lines * 16 + 4)
        elseif item.type=="supporter_label" then return 22
        elseif item.type=="toggle" then return 22
        elseif item.type=="button" then return 28
        elseif item.type=="slider" then return 34
        elseif item.type=="dropdown" or item.type=="multidropdown" then return 42
        elseif item.type=="colorpicker" then return 24
        elseif item.type=="keybind" then return 24
        elseif item.type=="textbox" then return 44
        elseif item.type=="settings_keybind" then return 24
        elseif item.type=="settings_toggle" then return 22
        elseif item.type=="settings_kill" or item.type=="settings_save" or item.type=="settings_load" then return 28
        end; return 20
    end

    -- ── Deferred Dropdown Renderer ───────────────────────────
    function WIN:_renderDDList(wid,item,ddPos,ddSz,innerW,FONT,isMulti)
        local optH=20; local maxV=item.maxVisible; local total=#item.options
        item.scroll=clamp(item.scroll,0,math.max(0,total-maxV))
        local visCount=math.min(maxV,total)
        local listPos=ddPos+Vector2.new(0,ddSz.Y+2); local listH=visCount*optH+4
        local scrW=6; local scrPad=3; local hasScroll=(total>maxV)
        local optW=hasScroll and (innerW-scrW-scrPad*2) or innerW

        self:_Draw(wid.."_ddlist","Square",{Position=listPos,Size=Vector2.new(innerW,listH),Filled=true,Color=T.Surface0,ZIndex=60})
        self:_Draw(wid.."_ddlistb","Square",{Position=listPos,Size=Vector2.new(innerW,listH),Filled=false,Color=T.Border1,Thickness=1,ZIndex=61})

        if hasScroll then
            local barH=math.max(16, listH*(maxV/total)); local trackH=listH-barH
            local maxScroll=math.max(1,total-maxV)
            local barY=listPos.Y + trackH*(item.scroll/maxScroll)
            local barX=listPos.X+innerW-scrW-scrPad; local barPos=Vector2.new(barX, barY); local barSz=Vector2.new(scrW, barH)
            self:_Draw(wid.."_ddscrtrk","Square",{Position=Vector2.new(barX, listPos.Y),Size=Vector2.new(scrW, listH),Filled=true,Color=T.Surface1,ZIndex=61})
            local scrHov=over(barPos, barSz)
            self:_Draw(wid.."_ddscr","Square",{Position=barPos,Size=barSz,Filled=true,Color=(scrHov or (item._scrDrag or false)) and T.Text or T.Accent,ZIndex=62})
            if item._clicked and scrHov then item._scrDrag=true; item._scrDragStartY=mpos().Y; item._scrDragStartScroll=item.scroll end
            if not Input.held then item._scrDrag=false end
            if item._scrDrag and trackH>0 then
                local dy=mpos().Y-(item._scrDragStartY or 0)
                item.scroll=clamp((item._scrDragStartScroll or 0)+math.floor(dy*(maxScroll/trackH)+0.5),0,maxScroll)
            end
        end

        for vi=1,visCount do
            local oi=vi+item.scroll; local opt=item.options[oi]; if not opt then break end
            local opPos=listPos+Vector2.new(0,(vi-1)*optH+2); local opSz=Vector2.new(optW,optH); local opHov=over(opPos,opSz)
            if isMulti then
                local opSel=item.selected[opt]==true
                if opHov then self:_Draw(wid.."_ddhi_"..vi,"Square",{Position=opPos,Size=opSz,Filled=true,Color=T.Surface1,ZIndex=61})
                else self:_Undraw(wid.."_ddhi_"..vi) end
                local cbPos=opPos+Vector2.new(6,5); local cbSz=Vector2.new(10,10)
                self:_Draw(wid.."_mdcb_"..vi,"Square",{Position=cbPos,Size=cbSz,Filled=true,Color=opSel and T.Accent or T.Surface0,ZIndex=62})
                self:_Draw(wid.."_mdcbb_"..vi,"Square",{Position=cbPos,Size=cbSz,Filled=false,Color=T.Border1,Thickness=1,ZIndex=63})
                self:_Draw(wid.."_mdot_"..vi,"Text",{Position=opPos+Vector2.new(22,3),Text=opt,Size=13,Font=FONT,Color=opSel and T.Accent or T.Text,Outline=false,ZIndex=62})
                if item._clicked and opHov then
                    item.selected[opt]=not opSel
                    local out={}; for _,o in ipairs(item.options) do if item.selected[o] then out[#out+1]=o end end
                    pcall(item.cb, out)
                end
            else
                local opSel=(opt==item.value)
                if opHov or opSel then self:_Draw(wid.."_ddhi_"..vi,"Square",{Position=opPos,Size=opSz,Filled=true,Color=opSel and T.AccentDark or T.Surface1,ZIndex=61})
                else self:_Undraw(wid.."_ddhi_"..vi) end
                self:_Draw(wid.."_ddot_"..vi,"Text",{Position=opPos+Vector2.new(8,3),Text=opt,Size=13,Font=FONT,Color=opSel and T.Accent or T.Text,Outline=false,ZIndex=62})
                if item._clicked and opHov then item.value=opt; pcall(item.cb, opt); self._openDropId=nil end
            end
        end
        -- hide excess rows
        for vi=visCount+1,maxV+4 do
            self:_Undraw(wid.."_ddhi_"..vi); self:_Undraw(wid.."_ddot_"..vi)
            self:_Undraw(wid.."_mdcb_"..vi); self:_Undraw(wid.."_mdcbb_"..vi); self:_Undraw(wid.."_mdot_"..vi)
        end

    end

    -- ── Deferred ColorPicker Renderer ────────────────────────
    function WIN:_renderColorPicker(wid, item, wx, wy, innerW, FONT)
        local palW, palH = innerW, 80; local palPos = Vector2.new(wx, wy + 24)
        self:_Draw(wid.."_cpbg","Square",{Position=palPos-Vector2.new(4,4),Size=Vector2.new(palW+8,palH+20+8),Filled=true,Color=T.Surface0,ZIndex=60})
        self:_Draw(wid.."_cpbgb","Square",{Position=palPos-Vector2.new(4,4),Size=Vector2.new(palW+8,palH+20+8),Filled=false,Color=T.Border1,Thickness=1,ZIndex=61})
        local strips=14
        for si=1,strips do
            local vv=1-(si-1)/(strips-1)
            self:_Draw(wid.."_sv_"..si,"Square",{Position=palPos+Vector2.new(0,(si-1)*(palH/strips)),Size=Vector2.new(palW,palH/strips+1),Filled=true,Color=hsvToRgb(item.h,item.s,vv),ZIndex=62})
        end
        local cX=palPos.X+item.s*palW; local cY=palPos.Y+(1-item.v)*palH
        self:_Draw(wid.."_svch_h","Line",{From=Vector2.new(palPos.X,cY),To=Vector2.new(palPos.X+palW,cY),Thickness=1,Color=T.Text,ZIndex=64})
        self:_Draw(wid.."_svch_v","Line",{From=Vector2.new(cX,palPos.Y),To=Vector2.new(cX,palPos.Y+palH),Thickness=1,Color=T.Text,ZIndex=64})
        local hueH=10; local huePos=Vector2.new(wx,wy+24+palH+4); local hSegs=20
        for hi=1,hSegs do
            self:_Draw(wid.."_h_"..hi,"Square",{Position=huePos+Vector2.new((hi-1)*(innerW/hSegs),0),Size=Vector2.new(innerW/hSegs+1,hueH),Filled=true,Color=hsvToRgb((hi-1)/hSegs,1,1),ZIndex=62})
        end
        local hcX=huePos.X+item.h*innerW
        self:_Draw(wid.."_hcur","Square",{Position=Vector2.new(hcX-2,huePos.Y-1),Size=Vector2.new(4,hueH+2),Filled=false,Color=T.Text,Thickness=1,ZIndex=64})
        self:_Draw(wid.."_palb","Square",{Position=palPos,Size=Vector2.new(palW,palH),Filled=false,Color=T.Border1,Thickness=1,ZIndex=63})
        if Input.click and over(palPos,Vector2.new(palW,palH)) then item.dragSV=true end
        if Input.click and over(huePos,Vector2.new(innerW,hueH)) then item.dragH=true end
        if not Input.held then item.dragSV=false; item.dragH=false end
        if item.dragSV then local m=mpos(); item.s=clamp((m.X-palPos.X)/palW,0,1); item.v=1-clamp((m.Y-palPos.Y)/palH,0,1); item.value=hsvToRgb(item.h,item.s,item.v); pcall(item.cb, item.value) end
        if item.dragH then item.h=clamp((mpos().X-huePos.X)/innerW,0,1); item.value=hsvToRgb(item.h,item.s,item.v); pcall(item.cb, item.value) end

    end

    -- ── Widget Renderer ──────────────────────────────────────
    function WIN:_renderWidget(item,wid,wx,wy,innerW,FONT,minY,maxY)
        local wH = getWidgetHeight(item, self)
        if wy + wH < minY or wy > maxY then return wH end

        if item.type=="label" then
            local lines = wrapText(item.label, innerW, 13)
            for li, line in ipairs(lines) do
                self:_Draw(wid.."_lbl"..li,"Text",{Position=Vector2.new(wx, wy + (li-1)*16 + 2),Text=line,Size=13,Font=FONT,Color=T.SubText,Outline=false,ZIndex=6})
            end
            for li = #lines+1, 10 do self:_Undraw(wid.."_lbl"..li) end

        elseif item.type=="supporter_label" then
            self:_Draw(wid.."_slbl","Text",{Position=Vector2.new(wx,wy+2),Text=item.text,Size=13,Font=FONT,Color=item.color,Outline=false,ZIndex=6})

        elseif item.type=="toggle" then
            local bsz=Vector2.new(14,14); local bpos=Vector2.new(wx+innerW-14, wy)
            local kbW=0; local kbPos; local kbBadgeW=0
            if item.keybind ~= nil then
                local kbStr = item.kb_listening and "[ ... ]" or ("["..keyName(item.keybind).."]")
                local kbFixedW = textW("["..keyName(item.keybind).."]",11)+8
                kbBadgeW = kbFixedW; kbPos = Vector2.new(bpos.X - kbBadgeW - 6, wy); kbW = kbBadgeW + 6
                self:_Draw(wid.."_kbbg","Square",{Position=kbPos,Size=Vector2.new(kbBadgeW,14),Filled=true,Color=item.kb_listening and T.AccentDark or T.Surface1,ZIndex=6})
                self:_Draw(wid.."_kbb","Square",{Position=kbPos,Size=Vector2.new(kbBadgeW,14),Filled=false,Color=item.kb_listening and T.Accent or T.Border0,Thickness=1,ZIndex=7})
                self:_Draw(wid.."_kbt","Text",{Position=kbPos+Vector2.new(kbBadgeW/2, 7),Text=kbStr,Size=11,Font=FONT,Color=item.kb_listening and T.Accent or T.SubText,Center=true,Outline=false,ZIndex=7})
                local m1 = Input.held
                if m1 and not item.kb_wasM1 and not self._blockClicks and over(kbPos, Vector2.new(kbBadgeW,14)) then item.kb_listening=true end
                item.kb_wasM1=m1
                if item.kb_listening then
                    for kc=1,255 do if kc~=0x01 and kc~=0x02 and Input:keyClick(kc) then
                        if kc~=0x1B then item.keybind=kc end; item.kb_listening=false; break
                    end end
                end
                if item.keybind and item.keybind~=0 and not item.kb_listening then
                    if Input:keyClick(item.keybind) then item.value=not item.value; pcall(item.cb, item.value) end
                end
            end
            self:_Draw(wid.."_box","Square",{Position=bpos,Size=bsz,Filled=true,Color=item.value and T.Accent or T.Surface1,ZIndex=6})
            self:_Draw(wid.."_boxb","Square",{Position=bpos,Size=bsz,Filled=false,Color=T.Border1,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_lbl","Text",{Position=Vector2.new(wx,wy+1),Text=item.label,Size=13,Font=FONT,Color=item.value and T.Text or T.SubText,Outline=false,ZIndex=6})
            if Input.click and not self._blockClicks and over(Vector2.new(wx,wy), Vector2.new(innerW, 16)) then
                local clickedBadge = false
                if item.keybind ~= nil and over(kbPos, Vector2.new(kbBadgeW, 14)) then clickedBadge = true end
                if not clickedBadge then item.value=not item.value; pcall(item.cb, item.value) end
            end

        elseif item.type=="button" then
            local bpos=Vector2.new(wx,wy); local bsz=Vector2.new(innerW,22); local hov=over(bpos,bsz)
            self:_Draw(wid.."_btn","Square",{Position=bpos,Size=bsz,Filled=true,Color=hov and T.AccentDark or T.Surface1,ZIndex=6})
            self:_Draw(wid.."_btnb","Square",{Position=bpos,Size=bsz,Filled=false,Color=hov and T.Accent or T.Border0,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_btnt","Text",{Position=bpos+Vector2.new(innerW/2, bsz.Y/2),Text=item.label,Size=13,Font=FONT,Color=T.Text,Center=true,Outline=false,ZIndex=7})
            if Input.click and not self._blockClicks and hov then pcall(item.cb) end

        elseif item.type=="slider" then
            local valStr=tostring(item.value)..item.suffix
            self:_Draw(wid.."_lbl","Text",{Position=Vector2.new(wx,wy),Text=item.label,Size=13,Font=FONT,Color=T.Text,Outline=false,ZIndex=6})
            self:_Draw(wid.."_val","Text",{Position=Vector2.new(wx+innerW-textW(valStr,12),wy),Text=valStr,Size=12,Font=FONT,Color=T.Accent,Outline=false,ZIndex=6})
            local trkPos=Vector2.new(wx,wy+17); local trkSz=Vector2.new(innerW,5)
            self:_Draw(wid.."_trk","Square",{Position=trkPos,Size=trkSz,Filled=true,Color=T.Surface1,ZIndex=6})
            local pct=clamp((item.value-item.min)/(item.max-item.min),0,1); local fillW=math.max(4,trkSz.X*pct)
            self:_Draw(wid.."_fill","Square",{Position=trkPos,Size=Vector2.new(fillW,trkSz.Y),Filled=true,Color=T.Accent,ZIndex=7})
            self:_Draw(wid.."_knob","Square",{Position=Vector2.new(trkPos.X+fillW-4,trkPos.Y-3),Size=Vector2.new(8,11),Filled=true,Color=T.Text,ZIndex=8})
            if Input.click and not self._blockClicks and over(trkPos-Vector2.new(0,5),trkSz+Vector2.new(0,12)) then self._sliderDrag=item end
            if self._sliderDrag==item then
                if Input.held then local p=clamp((mpos().X-trkPos.X)/trkSz.X,0,1); item.value=clamp(math.floor(item.min+(item.max-item.min)*p+0.5),item.min,item.max); pcall(item.cb, item.value)
                else self._sliderDrag=nil end
            end

        elseif item.type=="dropdown" then
            if not item._selfId then item._selfId={}; item._wasM1=false end
            local m1=Input.held; item._clicked = m1 and not item._wasM1
            local ddPos=Vector2.new(wx,wy+14); local ddSz=Vector2.new(innerW,22)
            local isOpen=(self._openDropId==item._selfId)
            local listH=(math.min(item.maxVisible,#item.options)*20+4); local listSz=Vector2.new(innerW,listH); local listPos=ddPos+Vector2.new(0,ddSz.Y+2)
            self:_Draw(wid.."_ddlbl","Text",{Position=Vector2.new(wx,wy),Text=item.label,Size=12,Font=FONT,Color=T.SubText,Outline=false,ZIndex=6})
            self:_Draw(wid.."_ddbg","Square",{Position=ddPos,Size=ddSz,Filled=true,Color=T.Surface1,ZIndex=6})
            self:_Draw(wid.."_ddb","Square",{Position=ddPos,Size=ddSz,Filled=false,Color=isOpen and T.Accent or T.Border0,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_ddval","Text",{Position=ddPos+Vector2.new(6,4),Text=item.value,Size=13,Font=FONT,Color=T.Text,Outline=false,ZIndex=7})
            local ax,ay=ddPos.X+ddSz.X-14,ddPos.Y+11
            if isOpen then self:_Draw(wid.."_ddarr","Triangle",{PointA=Vector2.new(ax,ay+3),PointB=Vector2.new(ax+7,ay+3),PointC=Vector2.new(ax+3.5,ay-4),Filled=true,Color=T.Accent,ZIndex=7})
            else self:_Draw(wid.."_ddarr","Triangle",{PointA=Vector2.new(ax,ay-4),PointB=Vector2.new(ax+7,ay-4),PointC=Vector2.new(ax+3.5,ay+3),Filled=true,Color=T.SubText,ZIndex=7}) end
            if item._clicked and not self._blockClicks then
                if over(ddPos,ddSz) then
                    if self._openDropId==item._selfId then self._openDropId=nil
                    elseif self._openDropId==nil then self._openDropId=item._selfId; self._cpTarget=nil; self._ddSpawnedAt=os.clock() end
                elseif isOpen and not over(listPos,listSz) then self._openDropId=nil end
            end
            if isOpen then
                if over(listPos, listSz) then self._blockClicks = true end
                self._deferredDrop = { wid, item, ddPos, ddSz, innerW, FONT, false }
            end
            item._wasM1=m1

        elseif item.type=="multidropdown" then
            if not item._selfId then item._selfId={}; item._wasM1=false end
            local m1=Input.held; item._clicked = m1 and not item._wasM1
            local ddPos=Vector2.new(wx,wy+14); local ddSz=Vector2.new(innerW,22)
            local isOpen=(self._openDropId==item._selfId)
            local listH=(math.min(item.maxVisible,#item.options)*20+4); local listSz=Vector2.new(innerW,listH); local listPos=ddPos+Vector2.new(0,ddSz.Y+2)
            local selList={}; for _,o in ipairs(item.options) do if item.selected[o] then selList[#selList+1]=o end end
            local dispStr=#selList==0 and "None" or (#selList.."/"..(#item.options).." selected")
            self:_Draw(wid.."_ddlbl","Text",{Position=Vector2.new(wx,wy),Text=item.label,Size=12,Font=FONT,Color=T.SubText,Outline=false,ZIndex=6})
            self:_Draw(wid.."_ddbg","Square",{Position=ddPos,Size=ddSz,Filled=true,Color=T.Surface1,ZIndex=6})
            self:_Draw(wid.."_ddb","Square",{Position=ddPos,Size=ddSz,Filled=false,Color=isOpen and T.Accent or T.Border0,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_ddval","Text",{Position=ddPos+Vector2.new(6,4),Text=dispStr,Size=13,Font=FONT,Color=T.Text,Outline=false,ZIndex=7})
            local ax,ay=ddPos.X+ddSz.X-14,ddPos.Y+11
            if isOpen then self:_Draw(wid.."_ddarr","Triangle",{PointA=Vector2.new(ax,ay+3),PointB=Vector2.new(ax+7,ay+3),PointC=Vector2.new(ax+3.5,ay-4),Filled=true,Color=T.Accent,ZIndex=7})
            else self:_Draw(wid.."_ddarr","Triangle",{PointA=Vector2.new(ax,ay-4),PointB=Vector2.new(ax+7,ay-4),PointC=Vector2.new(ax+3.5,ay+3),Filled=true,Color=T.SubText,ZIndex=7}) end
            if item._clicked and not self._blockClicks then
                if over(ddPos,ddSz) then
                    if self._openDropId==item._selfId then self._openDropId=nil
                    elseif self._openDropId==nil then self._openDropId=item._selfId; self._cpTarget=nil; self._ddSpawnedAt=os.clock() end
                elseif isOpen and not over(listPos,listSz) then self._openDropId=nil end
            end
            if isOpen then
                if over(listPos, listSz) then self._blockClicks = true end
                self._deferredDrop = { wid, item, ddPos, ddSz, innerW, FONT, true }
            end
            item._wasM1=m1

        elseif item.type=="colorpicker" then
            if not item._wasM1 then item._wasM1 = false end
            local m1 = Input.held; item._clicked = m1 and not item._wasM1
            local swPos=Vector2.new(wx,wy); local swColW=18; local swSz=Vector2.new(innerW,18)
            self:_Draw(wid.."_sw","Square",{Position=swPos,Size=Vector2.new(swColW,18),Filled=true,Color=item.value,ZIndex=6})
            self:_Draw(wid.."_swb","Square",{Position=swPos,Size=Vector2.new(swColW,18),Filled=false,Color=T.Border1,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_lbl","Text",{Position=swPos+Vector2.new(swColW+6,2),Text=item.label,Size=13,Font=FONT,Color=T.Text,Outline=false,ZIndex=6})
            local isOpen = (self._cpTarget==item)
            local cpTotalPos = Vector2.new(wx, wy + 24) - Vector2.new(4,4); local cpTotalSz = Vector2.new(innerW+8, 108)
            if item._clicked and not self._blockClicks then
                if over(swPos,swSz) then
                    if isOpen then self._cpTarget=nil else self._cpTarget=item; self._openDropId=nil; self._cpSpawnedAt=os.clock() end
                elseif isOpen and not over(cpTotalPos,cpTotalSz) then self._cpTarget=nil end
            end
            if self._cpTarget==item then
                if over(cpTotalPos, cpTotalSz) then self._blockClicks = true end
                self._deferredCP = { wid, item, wx, wy, innerW, FONT }
            end
            item._wasM1 = m1

        elseif item.type=="keybind" then
            local kbStr=item.listening and "[ ... ]" or ("[ "..keyName(item.value).." ]")
            local kbW=textW("[ "..keyName(item.value).." ]",12)+10; local kbPos=Vector2.new(wx+innerW-kbW,wy); local kbSz=Vector2.new(kbW,18)
            self:_Draw(wid.."_lbl","Text",{Position=Vector2.new(wx,wy+2),Text=item.label,Size=13,Font=FONT,Color=T.Text,Outline=false,ZIndex=6})
            self:_Draw(wid.."_kbbg","Square",{Position=kbPos,Size=kbSz,Filled=true,Color=item.listening and T.AccentDark or T.Surface1,ZIndex=6})
            self:_Draw(wid.."_kbb","Square",{Position=kbPos,Size=kbSz,Filled=false,Color=item.listening and T.Accent or T.Border0,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_kbtxt","Text",{Position=kbPos+Vector2.new(kbSz.X/2, kbSz.Y/2),Text=kbStr,Size=12,Font=FONT,Color=item.listening and T.Accent or T.SubText,Center=true,Outline=false,ZIndex=7})
            if Input.click and not self._blockClicks and over(kbPos,kbSz) then item.listening=true; self._keybindTarget=item end
            if item.listening and self._keybindTarget==item then
                for kc=1,255 do if kc~=0x01 and kc~=0x02 and Input:keyClick(kc) then
                    if kc~=0x1B then item.value=kc; pcall(item.cb, kc) end; item.listening=false; self._keybindTarget=nil; break
                end end
            end

        elseif item.type=="textbox" then
            local tbPos=Vector2.new(wx,wy+15); local tbSz=Vector2.new(innerW,22)
            local focused=(self._textboxTarget==item)
            local cursor=(focused and(math.floor(os.clock()*2)%2==0)) and "|" or ""
            local display=item.value..cursor; if display=="" then display=focused and cursor or item.label end
            self:_Draw(wid.."_lbl","Text",{Position=Vector2.new(wx,wy),Text=item.label,Size=12,Font=FONT,Color=T.SubText,Outline=false,ZIndex=6})
            self:_Draw(wid.."_tbbg","Square",{Position=tbPos,Size=tbSz,Filled=true,Color=T.Surface1,ZIndex=6})
            self:_Draw(wid.."_tbb","Square",{Position=tbPos,Size=tbSz,Filled=false,Color=focused and T.Accent or T.Border0,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_tbtxt","Text",{Position=tbPos+Vector2.new(6,4),Text=display,Size=13,Font=FONT,Color=(item.value~="" or focused) and T.Text or T.SubText,Outline=false,ZIndex=7})
            if Input.click and not self._blockClicks then
                if over(tbPos,tbSz) then self._textboxTarget=item elseif self._textboxTarget==item then self._textboxTarget=nil end
            end
            if focused then
                for kc=8,122 do if Input:keyClick(kc) then
                    if kc==0x08 then item.value=item.value:sub(1,-2); pcall(item.cb, item.value)
                    elseif kc==0x0D then self._textboxTarget=nil
                    elseif kc==0x20 then item.value=item.value.." "; pcall(item.cb, item.value)
                    elseif kc>=0x30 and kc<=0x5A then
                        local ch=KeyNames[kc]; if ch and #ch==1 then
                            local sh=Input:keyHeld(0x10) or Input:keyHeld(0xA0) or Input:keyHeld(0xA1)
                            item.value=item.value..(sh and ch:upper() or ch:lower()); pcall(item.cb, item.value)
                        end
                    end
                end end
            end

        elseif item.type=="settings_keybind" then
            local kbStr=item.listening and "[ ... ]" or ("[ "..keyName(self.MenuKey).." ]")
            local kbW=textW("[ "..keyName(self.MenuKey).." ]",12)+10; local kbPos=Vector2.new(wx+innerW-kbW,wy); local kbSz=Vector2.new(kbW,18)
            self:_Draw(wid.."_lbl","Text",{Position=Vector2.new(wx,wy+2),Text=item.label,Size=13,Font=FONT,Color=T.Text,Outline=false,ZIndex=6})
            self:_Draw(wid.."_kbbg","Square",{Position=kbPos,Size=kbSz,Filled=true,Color=item.listening and T.AccentDark or T.Surface1,ZIndex=6})
            self:_Draw(wid.."_kbb","Square",{Position=kbPos,Size=kbSz,Filled=false,Color=item.listening and T.Accent or T.Border0,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_kbtxt","Text",{Position=kbPos+Vector2.new(kbSz.X/2, kbSz.Y/2),Text=kbStr,Size=12,Font=FONT,Color=item.listening and T.Accent or T.SubText,Center=true,Outline=false,ZIndex=7})
            if Input.click and not self._blockClicks and over(kbPos,kbSz) then item.listening=true; self._settingsListen=true end
            if item.listening and self._settingsListen then
                for kc=1,255 do if kc~=0x01 and kc~=0x02 and Input:keyClick(kc) then
                    if kc~=0x1B then self.MenuKey=kc; self:SaveSettings(); self:Notify("Key: "..keyName(kc),self.Title,3) end
                    item.listening=false; self._settingsListen=false; break
                end end
            end

        elseif item.type=="settings_toggle" then
            local bsz=Vector2.new(14,14); local bpos=Vector2.new(wx+innerW-14, wy)
            self:_Draw(wid.."_box","Square",{Position=bpos,Size=bsz,Filled=true,Color=item.value and T.Accent or T.Surface1,ZIndex=6})
            self:_Draw(wid.."_boxb","Square",{Position=bpos,Size=bsz,Filled=false,Color=T.Border1,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_lbl","Text",{Position=Vector2.new(wx,wy+1),Text=item.label,Size=13,Font=FONT,Color=item.value and T.Text or T.SubText,Outline=false,ZIndex=6})
            if Input.click and not self._blockClicks and over(Vector2.new(wx,wy), Vector2.new(innerW,16)) then
                item.value = not item.value
                if item.label == "Start Minimized" then self._startMinimized = item.value
                elseif item.label == "Block Inputs" then self._blockInputsEnabled = item.value; if not item.value then setrobloxinput(true) end
                elseif item.label == "Skip Loader" then self._skipLoader = item.value end
                self:SaveSettings()
            end

        elseif item.type=="settings_kill" then
            local bpos=Vector2.new(wx,wy); local bsz=Vector2.new(innerW,22); local hov=over(bpos,bsz)
            self:_Draw(wid.."_btn","Square",{Position=bpos,Size=bsz,Filled=true,Color=hov and T.RedDark or T.Surface1,ZIndex=6})
            self:_Draw(wid.."_btnb","Square",{Position=bpos,Size=bsz,Filled=false,Color=hov and T.Red or T.Border0,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_btnt","Text",{Position=bpos+Vector2.new(innerW/2, bsz.Y/2),Text=item.label,Size=13,Font=FONT,Color=T.Red,Center=true,Outline=false,ZIndex=7})
            if Input.click and not self._blockClicks and hov then self:Notify("Script killed.",self.Title,2); self._running=false end

        elseif item.type=="settings_save" then
            local bpos=Vector2.new(wx,wy); local bsz=Vector2.new(innerW,22); local hov=over(bpos,bsz)
            self:_Draw(wid.."_btn","Square",{Position=bpos,Size=bsz,Filled=true,Color=hov and Color3.fromRGB(30,90,30) or T.Surface1,ZIndex=6})
            self:_Draw(wid.."_btnb","Square",{Position=bpos,Size=bsz,Filled=false,Color=hov and Color3.fromRGB(60,200,60) or T.Border0,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_btnt","Text",{Position=bpos+Vector2.new(innerW/2, bsz.Y/2),Text=item.label,Size=13,Font=FONT,Color=hov and Color3.fromRGB(60,200,60) or T.Text,Center=true,Outline=false,ZIndex=7})
            if Input.click and not self._blockClicks and hov then pcall(item.cb) end

        elseif item.type=="settings_load" then
            local bpos=Vector2.new(wx,wy); local bsz=Vector2.new(innerW,22); local hov=over(bpos,bsz)
            self:_Draw(wid.."_btn","Square",{Position=bpos,Size=bsz,Filled=true,Color=hov and Color3.fromRGB(30,50,90) or T.Surface1,ZIndex=6})
            self:_Draw(wid.."_btnb","Square",{Position=bpos,Size=bsz,Filled=false,Color=hov and Color3.fromRGB(60,100,200) or T.Border0,Thickness=1,ZIndex=7})
            self:_Draw(wid.."_btnt","Text",{Position=bpos+Vector2.new(innerW/2, bsz.Y/2),Text=item.label,Size=13,Font=FONT,Color=hov and Color3.fromRGB(60,100,200) or T.Text,Center=true,Outline=false,ZIndex=7})
            if Input.click and not self._blockClicks and hov then pcall(item.cb) end
        end
        return wH
    end

    -- ── Main Render (Jade-style fade) ──────────────────────────
    function WIN:_render()
        local pos=self._pos; local sz=self.Size; local t=os.clock(); local FONT=CurrentFont
        self._blockClicks = false; self._deferredDrop = nil; self._deferredCP = nil

        if not self._open then
            self:_UndrawStartsWith("m_")
            for i=1,self._snakeCount do self._snakeLines[i].Visible = false end
            return
        end
        local menuOp = 1; local secOp = 1

        -- ── BEGIN FRAME ──────────────────────────────────────
        self:_BeginFrame()

        -- ── DRAGGING ─────────────────────────────────────────
        if Input.click and over(pos,Vector2.new(sz.X,38)) and not self._drag then self._drag=mpos()-pos end
        if not Input.held then self._drag=nil end
        if self._drag then self._pos=mpos()-self._drag; pos=self._pos end

        -- ── MENU CHROME (with menu fade Transparency) ────────
        self:_Draw("m_bg","Square",{Position=pos,Size=sz,Filled=true,Color=T.Body,ZIndex=1,Transparency=menuOp})
        self:_Draw("m_b","Square",{Position=pos,Size=sz,Filled=false,Color=T.Border0,Thickness=1,ZIndex=2,Transparency=menuOp})
        local topH=38
        self:_Draw("m_top_bg","Square",{Position=pos,Size=Vector2.new(sz.X,topH),Filled=true,Color=T.Surface0,ZIndex=2,Transparency=menuOp})
        self:_Draw("m_top_line","Square",{Position=pos+Vector2.new(0,topH),Size=Vector2.new(sz.X,2),Filled=true,Color=T.Accent,ZIndex=3,Transparency=menuOp})
        self:_Draw("m_top_title","Text",{Position=pos+Vector2.new(12,11),Text=self.Title,Size=16,Font=FONT,Color=T.Accent,Outline=true,ZIndex=3,Transparency=menuOp})

        -- Watermark
        local wmStr=self.Title.."  |  "..keyName(self.MenuKey).." to toggle"
        self:_Draw("m_wm_bg","Square",{Position=pos-Vector2.new(0,21),Size=Vector2.new(textW(wmStr,12)+14,18),Filled=true,Color=T.Surface0,ZIndex=1,Transparency=menuOp})
        self:_Draw("m_wm_txt","Text",{Position=pos-Vector2.new(-5,17),Text=wmStr,Size=12,Font=FONT,Color=T.SubText,Outline=false,ZIndex=2,Transparency=menuOp})

        -- ── SNAKE ANIMATION ──────────────────────────────────
        local snkPos=pos+Vector2.new(0,topH+2); local snkSz=sz-Vector2.new(0,topH+2)
        for i=1,self._snakeCount do
            local ti=t*0.175-i*0.004; local sl=self._snakeLines[i]
            sl.From=pointOnRect(ti,snkPos,snkSz); sl.To=pointOnRect(ti+0.004,snkPos,snkSz)
            sl.Color=Color3.fromHSV((t*0.12+i*0.05)%1,0.75,1)
            sl.Transparency=((1-i/self._snakeCount)*0.78)
            sl.Visible=true; sl.ZIndex=50
        end

        -- ── DYNAMIC WIDTH (expand to fit all tabs) ──────────
        local neededW = 10
        for _, tab in ipairs(self._tabs) do neededW = neededW + textW(tab._name,13) + 24 + 5 end
        neededW = neededW + 5
        if neededW > self._minSize.X then
            self.Size = Vector2.new(neededW, self.Size.Y); sz = self.Size
        elseif self.Size.X ~= self._minSize.X then
            self.Size = Vector2.new(self._minSize.X, self.Size.Y); sz = self.Size
        end

        -- ── TAB BUTTONS ──────────────────────────────────────
        local tabY=topH+4; local tabH=26; local tabX=10
        for i,tab in ipairs(self._tabs) do
            local tw=textW(tab._name,13)+24; local tpos=pos+Vector2.new(tabX,tabY); local tsz=Vector2.new(tw,tabH)
            local isOpen=(self._openTab==tab)
            self:_Draw("m_tab_bg_"..i,"Square",{Position=tpos,Size=tsz,Filled=true,Color=isOpen and T.Surface1 or T.Surface0,ZIndex=13,Transparency=menuOp})
            self:_Draw("m_tab_txt_"..i,"Text",{Position=tpos+Vector2.new(tw/2, tabH/2),Text=tab._name,Size=13,Font=FONT,Color=isOpen and T.Text or T.SubText,Center=true,Outline=false,ZIndex=14,Transparency=menuOp})
            if isOpen then self:_Draw("m_tab_ul_"..i,"Square",{Position=tpos+Vector2.new(0,tabH-2),Size=Vector2.new(tw,2),Filled=true,Color=T.Accent,ZIndex=14,Transparency=menuOp})
            else self:_Undraw("m_tab_ul_"..i) end
            -- Only trigger tab change when switching to a DIFFERENT tab
            if Input.click and over(tpos,tsz) and self._openTab ~= tab then
                self._openTab=tab; self._openDropId=nil; self._textboxTarget=nil; self._cpTarget=nil
                self._tabChangeAt=t  -- Use current frame time for proper sync
                secOp = 0  -- Start section opacity at 0 for this frame
                -- Hide old section drawings instantly
                self:_UndrawStartsWith("m_sec_")
            end
            tabX=tabX+tw+5
        end

        if not self._openTab then self:_FlushFrame(); return end

        -- ── SECTION CONTENT (with section opacity + slide) ─────
        local contTop=topH+tabH+10; local padX=10
        local colW=(sz.X-padX*3)/2; local colYL=0; local colYR=0
        local minViewY = contTop; local maxViewY = sz.Y - 10
        local slideOffset = 0

        for si,sec in ipairs(self._openTab._sections) do
            local isLeft=(si%2==1)
            local sx=isLeft and padX or (padX*2+colW)
            local sy=isLeft and colYL or colYR
            local sid="m_sec_"..si

            local secH = 20
            for _,item in ipairs(sec._widgets) do secH = secH + getWidgetHeight(item, self) + 6 end
            secH = secH + 8

            local renderY = pos.Y + contTop + sy - self._openTab.scroll + slideOffset
            local secTopY = math.max(renderY, pos.Y + minViewY)
            local secBotY = math.min(renderY + secH, pos.Y + maxViewY)
            local clampedH = secBotY - secTopY

            if clampedH > 0 then
                self:_Draw(sid.."_bg","Square",{Position=Vector2.new(pos.X+sx, secTopY),Size=Vector2.new(colW,clampedH),Filled=true,Color=T.Surface0,ZIndex=4,Transparency=secOp})
                self:_Draw(sid.."_bgb","Square",{Position=Vector2.new(pos.X+sx, secTopY),Size=Vector2.new(colW,clampedH),Filled=false,Color=T.Border0,Thickness=1,ZIndex=5,Transparency=secOp})
            else self:_Undraw(sid.."_bg"); self:_Undraw(sid.."_bgb") end

            if renderY + 15 >= pos.Y + minViewY and renderY < pos.Y + maxViewY then
                self:_Draw(sid.."_hdr","Text",{Position=Vector2.new(pos.X+sx+6, renderY+4),Text=sec._name,Size=11,Font=FONT,Color=T.SubText,Outline=false,ZIndex=6,Transparency=secOp})
            else self:_Undraw(sid.."_hdr") end

            local wY = renderY + 20; local innerX = pos.X + sx + 8; local innerW = colW - 16
            for wi,item in ipairs(sec._widgets) do
                local consumed = self:_renderWidget(item, sid.."_w"..wi, innerX, wY, innerW, FONT, pos.Y + minViewY, pos.Y + maxViewY)
                wY = wY + consumed + 6
            end

            if isLeft then colYL = colYL + secH + 12 else colYR = colYR + secH + 12 end
        end

        -- ── SCROLL ───────────────────────────────────────────
        local totalContentH = math.max(colYL, colYR)
        self._openTab.maxScroll = math.max(0, totalContentH - (maxViewY - minViewY))
        if not self._openDropId and not self._cpTarget then
            if Input.scrollUp then self._openTab.scroll = math.max(0, self._openTab.scroll - 30)
            elseif Input.scrollDown then self._openTab.scroll = math.min(self._openTab.maxScroll, self._openTab.scroll + 30) end
        end
        if self._openTab.maxScroll > 0 then
            local sbW=4; local sbH=maxViewY-minViewY
            local sbX=pos.X+sz.X-sbW-2; local sbY=pos.Y+minViewY
            self:_Draw("m_sec_sb_trk","Square",{Position=Vector2.new(sbX,sbY),Size=Vector2.new(sbW,sbH),Filled=true,Color=T.Surface1,ZIndex=15,Transparency=secOp})
            local thumbH=math.max(20, sbH*(sbH/(sbH+self._openTab.maxScroll)))
            local thumbY=sbY+(sbH-thumbH)*(self._openTab.scroll/self._openTab.maxScroll)
            local sbHov=over(Vector2.new(sbX-2, thumbY), Vector2.new(sbW+4, thumbH))
            if Input.click and not self._blockClicks and sbHov then
                self._dragTabScroll=true; self._dragTabStartY=mpos().Y; self._dragTabStartScroll=self._openTab.scroll
            end
            if not Input.held then self._dragTabScroll=false end
            if self._dragTabScroll then
                local dy=mpos().Y-self._dragTabStartY; local scrollRatio=self._openTab.maxScroll/(sbH-thumbH)
                self._openTab.scroll=clamp(self._dragTabStartScroll+dy*scrollRatio, 0, self._openTab.maxScroll)
            end
            self:_Draw("m_sec_sb_thumb","Square",{Position=Vector2.new(sbX,thumbY),Size=Vector2.new(sbW,thumbH),Filled=true,Color=(sbHov or self._dragTabScroll) and T.Text or T.Accent,ZIndex=16,Transparency=secOp})
        else self:_Undraw("m_sec_sb_trk"); self:_Undraw("m_sec_sb_thumb") end

        -- ── DEFERRED RENDERING (popups) ──────────────────────
        if self._deferredDrop then self:_renderDDList(table.unpack(self._deferredDrop)) end
        if self._deferredCP then self:_renderColorPicker(table.unpack(self._deferredCP)) end

        -- ── FLUSH FRAME (AFTER popups to avoid flicker) ──────
        self:_FlushFrame()


    end

    -- ── MAIN LOOP ────────────────────────────────────────────
    task.spawn(function()
        WIN:_buildInfoTab()
        WIN:_buildSettings()
        task.wait(0.2)
        WIN:LoadSettings()
        while WIN._running do
            task.wait()
            local rbx = isrbxactive()
            if not rbx then
                if WIN._open and WIN._blockInputsEnabled then setrobloxinput(true) end
                continue
            end
            Input:update()
            if Input:keyClick(WIN.MenuKey) then
                WIN._open = not WIN._open
                WIN._menuToggledAt = os.clock()
                if WIN._blockInputsEnabled then setrobloxinput(not WIN._open) end
                if not WIN._open then
                    WIN._openDropId=nil; WIN._textboxTarget=nil
                    WIN._keybindTarget=nil; WIN._settingsListen=false; WIN._cpTarget=nil
                end
            end
            if WIN._open and WIN._blockInputsEnabled then setrobloxinput(false) end
            WIN:_render()
        end
        setrobloxinput(true); WIN:_DestroyAll()
        for i=1,WIN._snakeCount do WIN._snakeLines[i]:Remove() end
    end)

    return WIN
end

return GalaxLib
