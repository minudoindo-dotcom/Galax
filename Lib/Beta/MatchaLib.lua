-- ════════════════════════════════════════════════════════════════
--  MatchaLib v2.0 — Utility Library for Matcha LuaVM
--  Author : Whymayko
--  GitHub : https://raw.githubusercontent.com/minudoindo-dotcom/Galax/refs/heads/main/Lib/Beta/MatchaLib.lua
--
--  Uso básico:
--    loadstring(game:HttpGet("URL_ACIMA"))()
--
--    -- Core
--    MatchaLib.TeleportTo(hrp, pos)
--    MatchaLib.LookAt(hrp, targetPos)
--    MatchaLib.TrackTarget(hrp, enemyHRP, yOff, xOff)
--
--    -- ESP standalone
--    local esp = MatchaLib.ESP.Create(part, {box=true, name=true, distance=true, line=true, color=Color3.fromRGB(255,0,0)})
--    MatchaLib.ESP.Update(esp, myPos)
--    MatchaLib.ESP.Destroy(esp)
--
--    -- Enemy API (alto nível)
--    local enemy = MatchaLib.Enemy.New(hrpPart)
--    enemy:TeleportTo()
--    enemy:LoopTeleport(yOff, xOff)
--    enemy:LookAt()
--    enemy:ESP({box=true, name=true, distance=true, line=false})
--    enemy:StopESP()
--    enemy:Dist()
--    enemy:IsAlive()
--    enemy:Destroy()
-- ════════════════════════════════════════════════════════════════

MatchaLib = {}

-- ════════════════════════════════════════════════════════════════
--  1. OFFSETS — auto-fetch, fallback hardcoded
--     Troque só a URL abaixo quando o Roblox atualizar.
-- ════════════════════════════════════════════════════════════════

local OFFSETS_URL = "https://imtheo.lol/Offsets/version-ae421f0582e54718/Offsets.json"

local function fetchOffsets()
    local ok, raw = pcall(game.HttpGet, game, OFFSETS_URL)
    if ok and raw and #raw > 10 then
        local jok, decoded = pcall(function()
            return game:GetService("HttpService"):JSONDecode(raw)
        end)
        if jok and decoded and decoded.Offsets then
            return decoded.Offsets
        end
    end
    -- fallback hardcoded (version-ae421f0582e54718)
    return {
        BasePart  = { Primitive = 328 },
        Primitive = { Rotation  = 192 },
    }
end

MatchaLib.Offsets = fetchOffsets()

local primOffset = (MatchaLib.Offsets.BasePart  and MatchaLib.Offsets.BasePart.Primitive)  or 328
local rotOffset  = (MatchaLib.Offsets.Primitive and MatchaLib.Offsets.Primitive.Rotation)   or 192

-- ════════════════════════════════════════════════════════════════
--  2. INTERNAL HELPERS
-- ════════════════════════════════════════════════════════════════

local _cachedPrim    = nil
local _cachedHrpAddr = nil

local function getLookAtMatrix(fromPos, toPos)
    local dx,dy,dz = toPos.X-fromPos.X, toPos.Y-fromPos.Y, toPos.Z-fromPos.Z
    local zx,zy,zz = -dx,-dy,-dz
    local zmag = math.sqrt(zx*zx+zy*zy+zz*zz)
    if zmag == 0 then return {1,0,0,0,1,0,0,0,1} end
    zx,zy,zz = zx/zmag,zy/zmag,zz/zmag
    local ux,uy,uz = 0,1,0
    if math.abs(zy) > 0.9999 then ux,uy,uz=0,0,1 end
    local xx,xy,xz = uy*zz-uz*zy, uz*zx-ux*zz, ux*zy-uy*zx
    local xmag = math.sqrt(xx*xx+xy*xy+xz*xz)
    xx,xy,xz = xx/xmag,xy/xmag,xz/xmag
    local yx,yy,yz = zy*xz-zz*xy, zz*xx-zx*xz, zx*xy-zy*xx
    return {xx,yx,zx,xy,yy,zy,xz,yz,zz}
end

local function newText(col, sz, bold)
    local t = Drawing.new("Text")
    t.Font    = bold and Drawing.Fonts.SystemBold or Drawing.Fonts.UI
    t.Size    = sz or 13
    t.Color   = col or Color3.new(1,1,1)
    t.Outline = true; t.Center = true; t.ZIndex = 10; t.Visible = false
    return t
end

local function newLine(col, thick)
    local l = Drawing.new("Line")
    l.Color = col or Color3.new(1,1,1); l.Thickness = thick or 1.5; l.Visible = false
    return l
end

local function newCornerBox(col)
    local lines = {}
    for i = 1, 8 do lines[i] = newLine(col, 1.5) end
    return lines
end

local function drawCornerBox(lines, x, y, hw, hh, len, col)
    for _,l in ipairs(lines) do l.Color = col end
    lines[1].From=Vector2.new(x-hw,y-hh); lines[1].To=Vector2.new(x-hw+len,y-hh)
    lines[2].From=Vector2.new(x-hw,y-hh); lines[2].To=Vector2.new(x-hw,y-hh+len)
    lines[3].From=Vector2.new(x+hw,y-hh); lines[3].To=Vector2.new(x+hw-len,y-hh)
    lines[4].From=Vector2.new(x+hw,y-hh); lines[4].To=Vector2.new(x+hw,y-hh+len)
    lines[5].From=Vector2.new(x+hw,y+hh); lines[5].To=Vector2.new(x+hw-len,y+hh)
    lines[6].From=Vector2.new(x+hw,y+hh); lines[6].To=Vector2.new(x+hw,y+hh-len)
    lines[7].From=Vector2.new(x-hw,y+hh); lines[7].To=Vector2.new(x-hw+len,y+hh)
    lines[8].From=Vector2.new(x-hw,y+hh); lines[8].To=Vector2.new(x-hw,y+hh-len)
    for _,l in ipairs(lines) do l.Visible = true end
end

local function hideCornerBox(lines)
    for _,l in ipairs(lines) do l.Visible = false end
end

-- ════════════════════════════════════════════════════════════════
--  3. CORE API
-- ════════════════════════════════════════════════════════════════

function MatchaLib.LookAt(hrp, targetPos)
    local flat = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
    pcall(function() hrp.CFrame = CFrame.lookAt(hrp.Position, flat) end)
    local addr = tonumber(hrp.Address)
    if not addr or addr == 0 then return end
    if addr ~= _cachedHrpAddr then
        local prim = memory_read("uintptr_t", addr + primOffset)
        if not prim or prim == 0 then return end
        _cachedPrim = prim; _cachedHrpAddr = addr
    end
    local mat  = getLookAtMatrix(hrp.Position, targetPos)
    local base = _cachedPrim + rotOffset
    for i = 0, 8 do memory_write("float", base + i*4, mat[i+1]) end
end

function MatchaLib.TeleportTo(hrp, pos)
    pcall(function() hrp.Position = pos end)
end

-- TP + LookAt — yOff = altura relativa, xOff = distância atrás do alvo
function MatchaLib.TrackTarget(hrp, targetHrp, yOff, xOff)
    local tx,tz = targetHrp.Position.X, targetHrp.Position.Z
    local dx,dz = tx-hrp.Position.X, tz-hrp.Position.Z
    local len   = math.sqrt(dx*dx+dz*dz)
    local bx,bz = 0,0
    if len > 0.01 and xOff and xOff ~= 0 then
        bx = -(dx/len)*xOff; bz = -(dz/len)*xOff
    end
    hrp.Position = Vector3.new(tx+bx, targetHrp.Position.Y+(yOff or 0), tz+bz)
    MatchaLib.LookAt(hrp, targetHrp.Position)
end

function MatchaLib.Dist(a, b)
    local d = a - b
    return math.sqrt(d.X^2 + d.Y^2 + d.Z^2)
end

function MatchaLib.GetMyHRP()
    local lp = game.Players.LocalPlayer
    local chars = workspace:FindFirstChild("Characters")
    if chars then
        local char = chars:FindFirstChild(lp.Name)
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            if hrp then return hrp end
        end
    end
    local char = lp.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

function MatchaLib.GetPlayerSet()
    local set = {}
    for _, p in ipairs(game.Players:GetPlayers()) do set[p.Name] = true end
    return set
end

-- Pega o inimigo mais próximo em workspace.Live (ou folder customizado)
function MatchaLib.GetClosestEnemy(maxDist, folder)
    local myHRP = MatchaLib.GetMyHRP()
    if not myHRP then return nil end
    local live = workspace:FindFirstChild(folder or "Live")
    if not live then return nil end
    local best, bestDist = nil, maxDist or math.huge
    local playerSet = MatchaLib.GetPlayerSet()
    for _, obj in ipairs(live:GetChildren()) do
        if playerSet[obj.Name] then continue end
        local hum = obj:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local d = MatchaLib.Dist(hrp.Position, myHRP.Position)
        if d < bestDist then best = hrp; bestDist = d end
    end
    return best
end

-- Direção relativa entre dois HRPs — "facing", "back" ou "side"
function MatchaLib.GetFacingState(myHRP, enemyHRP)
    local function readRot(part)
        local addr = tonumber(part.Address)
        if not addr or addr == 0 then return nil end
        local prim = memory_read("uintptr_t", addr + primOffset)
        if not prim or prim == 0 then return nil end
        local mat = {}
        for i=1,9 do mat[i]=memory_read("float", prim+rotOffset+((i-1)*4)) end
        return mat
    end
    local myMat = readRot(myHRP)
    local eMat  = readRot(enemyHRP)
    if not myMat or not eMat then return nil end
    local dot = myMat[3]*eMat[3] + myMat[9]*eMat[9]
    if dot < -0.7 then return "facing" end
    if dot >  0.7 then return "back"   end
    return "side"
end

function MatchaLib.PressKey(keycode, holdTime)
    keypress(keycode); task.wait(holdTime or 0.05); keyrelease(keycode)
end

function MatchaLib.Click(x, y)
    mousemoveabs(x, y); task.wait(0.05)
    mouse1press();      task.wait(0.05)
    mouse1release()
end

-- ════════════════════════════════════════════════════════════════
--  4. ESP MODULE — MatchaLib.ESP
--
--  cfg = {
--    box      : bool,
--    name     : bool,
--    distance : bool,
--    line     : bool,
--    color    : Color3,
--    hw, hh   : meias dimensões da box (default 22),
--    nameText : string personalizado,
--  }
-- ════════════════════════════════════════════════════════════════

MatchaLib.ESP = {}

function MatchaLib.ESP.Create(part, cfg)
    cfg = cfg or {}
    local col = cfg.color or Color3.fromRGB(255, 215, 0)
    return {
        part      = part,
        cfg       = cfg,
        box       = newCornerBox(col),
        label     = newText(col, 13),
        distLabel = newText(Color3.new(1,1,1), 13),
        tracer    = newLine(col, 1),
    }
end

function MatchaLib.ESP.Update(esp, myPos)
    local part = esp.part
    local cfg  = esp.cfg
    if not part or not part.Parent then
        MatchaLib.ESP.Hide(esp); return false
    end
    local col  = cfg.color or Color3.fromRGB(255, 215, 0)
    local tp   = part.Position
    local dist = math.floor(MatchaLib.Dist(tp, myPos))
    local pos, onScreen = WorldToScreen(tp)
    if not pos or not onScreen then MatchaLib.ESP.Hide(esp); return false end

    local x, y   = pos.X, pos.Y
    local hw, hh = cfg.hw or 22, cfg.hh or 22

    -- Box
    if cfg.box then drawCornerBox(esp.box, x, y, hw, hh, 8, col)
    else hideCornerBox(esp.box) end

    -- Name + distance inline acima da box
    local distStr = "["..dist.."m]"
    local topY    = y - hh - 14
    local label   = cfg.nameText or (part.Name or "?")
    if cfg.name then
        local GAP    = 10
        local nameW  = #label * 6
        local dW     = cfg.distance and (#distStr * 6) or 0
        local totalW = nameW + (cfg.distance and GAP or 0) + dW
        esp.label.Text     = label
        esp.label.Color    = col
        esp.label.Position = Vector2.new(x - totalW/2 + nameW/2, topY)
        esp.label.Visible  = true
        if cfg.distance then
            esp.distLabel.Text     = " "..distStr
            esp.distLabel.Position = Vector2.new(x - totalW/2 + nameW + GAP + dW/2, topY)
            esp.distLabel.Visible  = true
        else esp.distLabel.Visible = false end
    else
        esp.label.Visible = false
        if cfg.distance then
            esp.distLabel.Text     = distStr
            esp.distLabel.Position = Vector2.new(x, topY)
            esp.distLabel.Visible  = true
        else esp.distLabel.Visible = false end
    end

    -- Traceline
    if cfg.line then
        local scr = workspace.CurrentCamera.ViewportSize
        esp.tracer.From = Vector2.new(scr.X/2, scr.Y)
        esp.tracer.To   = Vector2.new(x, y)
        esp.tracer.Color   = col
        esp.tracer.Visible = true
    else esp.tracer.Visible = false end

    return true
end

function MatchaLib.ESP.Hide(esp)
    hideCornerBox(esp.box)
    esp.label.Visible = false; esp.distLabel.Visible = false; esp.tracer.Visible = false
end

function MatchaLib.ESP.Destroy(esp)
    for _,l in ipairs(esp.box) do l:Remove() end
    esp.label:Remove(); esp.distLabel:Remove(); esp.tracer:Remove()
end

-- ════════════════════════════════════════════════════════════════
--  5. ENEMY API — MatchaLib.Enemy
--
--  local enemy = MatchaLib.Enemy.New(hrpPart)
--  enemy:TeleportTo(yOff, xOff)
--  enemy:LoopTeleport(yOff, xOff)  -- retorna thread
--  enemy:StopLoopTeleport()
--  enemy:LookAt()
--  enemy:ESP({box=true, name=true, distance=true, line=false, color=Color3})
--  enemy:StopESP()
--  enemy:Dist()
--  enemy:IsAlive()
--  enemy:Destroy()
-- ════════════════════════════════════════════════════════════════

MatchaLib.Enemy = {}

function MatchaLib.Enemy.New(hrp)
    local self = {
        hrp         = hrp,
        _loopThread = nil,
        _esp        = nil,
        _espThread  = nil,
    }

    function self:TeleportTo(yOff, xOff)
        local myHRP = MatchaLib.GetMyHRP()
        if not myHRP then return end
        MatchaLib.TrackTarget(myHRP, self.hrp, yOff or -10, xOff or 5)
    end

    function self:LoopTeleport(yOff, xOff)
        if self._loopThread then pcall(task.cancel, self._loopThread) end
        self._loopThread = task.spawn(function()
            while self.hrp and self.hrp.Parent do
                local myHRP = MatchaLib.GetMyHRP()
                if myHRP then MatchaLib.TrackTarget(myHRP, self.hrp, yOff or -10, xOff or 5) end
                task.wait()
            end
        end)
        return self._loopThread
    end

    function self:StopLoopTeleport()
        if self._loopThread then pcall(task.cancel, self._loopThread); self._loopThread = nil end
    end

    function self:LookAt()
        local myHRP = MatchaLib.GetMyHRP()
        if myHRP then MatchaLib.LookAt(myHRP, self.hrp.Position) end
    end

    function self:ESP(cfg)
        cfg = cfg or {box=true, name=true, distance=true, line=false}
        if not self._esp then
            self._esp = MatchaLib.ESP.Create(self.hrp, cfg)
        else
            self._esp.cfg = cfg
        end
        if not self._espThread then
            self._espThread = task.spawn(function()
                while self._esp and self.hrp and self.hrp.Parent do
                    local myHRP = MatchaLib.GetMyHRP()
                    if myHRP then MatchaLib.ESP.Update(self._esp, myHRP.Position) end
                    task.wait(0.033)
                end
            end)
        end
    end

    function self:StopESP()
        if self._espThread then pcall(task.cancel, self._espThread); self._espThread = nil end
        if self._esp then MatchaLib.ESP.Destroy(self._esp); self._esp = nil end
    end

    function self:Dist()
        local myHRP = MatchaLib.GetMyHRP()
        if not myHRP then return math.huge end
        return MatchaLib.Dist(myHRP.Position, self.hrp.Position)
    end

    function self:IsAlive()
        if not self.hrp or not self.hrp.Parent then return false end
        local hum = self.hrp.Parent:FindFirstChildOfClass("Humanoid")
        return hum and hum.Health > 0 or false
    end

    function self:Destroy()
        self:StopLoopTeleport()
        self:StopESP()
        self.hrp = nil
    end

    return self
end
