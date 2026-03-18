-- ════════════════════════════════════════════════════════════════
--  MatchaLib — Utility Library for Matcha LuaVM
--  Usage:
--    loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU-USER/SEU-REPO/main/MatchaLib.lua"))()
--    local O = MatchaLib.Offsets       -- offsets table
--    MatchaLib.LookAt(hrp, targetPos)
--    MatchaLib.TeleportTo(hrp, pos)
--    local enemy = MatchaLib.GetClosestEnemy(maxDist)
-- ════════════════════════════════════════════════════════════════

MatchaLib = {}

-- ════════════════════════════════════════════════════════════════
--  OFFSETS (auto-fetch, fallback hardcoded)
--  Update the URL below whenever Roblox updates.
-- ════════════════════════════════════════════════════════════════

local OFFSETS_URL = "https://imtheo.lol/Offsets/version-ae421f0582e54718/Offsets.json"

local function fetchOffsets()
    local ok, raw = pcall(function()
        return game:HttpGet(OFFSETS_URL)
    end)
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

local primOffset = MatchaLib.Offsets.BasePart  and MatchaLib.Offsets.BasePart.Primitive  or 328
local rotOffset  = MatchaLib.Offsets.Primitive and MatchaLib.Offsets.Primitive.Rotation   or 192

-- ════════════════════════════════════════════════════════════════
--  INTERNAL HELPERS
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

-- ════════════════════════════════════════════════════════════════
--  PUBLIC API
-- ════════════════════════════════════════════════════════════════

-- Rotaciona o HRP para olhar para targetPos usando CFrame + memory_write
-- Uso: MatchaLib.LookAt(hrp, enemy.HumanoidRootPart.Position)
function MatchaLib.LookAt(hrp, targetPos)
    local flat = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
    pcall(function() hrp.CFrame = CFrame.lookAt(hrp.Position, flat) end)

    local addr = tonumber(hrp.Address)
    if not addr or addr == 0 then return end
    if addr ~= _cachedHrpAddr then
        local prim = memory_read("uintptr_t", addr + primOffset)
        if not prim or prim == 0 then return end
        _cachedPrim    = prim
        _cachedHrpAddr = addr
    end
    local mat  = getLookAtMatrix(hrp.Position, targetPos)
    local base = _cachedPrim + rotOffset
    for i = 0, 8 do
        memory_write("float", base + i*4, mat[i+1])
    end
end

-- Teleporta o HRP para uma posição
-- Uso: MatchaLib.TeleportTo(hrp, Vector3.new(x, y, z))
function MatchaLib.TeleportTo(hrp, pos)
    pcall(function() hrp.Position = pos end)
end

-- Teleporta e olha para um alvo ao mesmo tempo (usado no Auto Mob)
-- yOff = altura relativa ao alvo, xOff = distância atrás do alvo
-- Uso: MatchaLib.TrackTarget(hrp, enemyHRP, -10, 5)
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

-- Retorna a distância 3D entre dois Vector3
-- Uso: local dist = MatchaLib.Dist(posA, posB)
function MatchaLib.Dist(a, b)
    local d = a - b
    return math.sqrt(d.X^2 + d.Y^2 + d.Z^2)
end

-- Retorna o HRP do LocalPlayer (procura em workspace.Characters e em Character)
-- Uso: local hrp = MatchaLib.GetMyHRP()
function MatchaLib.GetMyHRP()
    local lp = game.Players.LocalPlayer
    -- tenta workspace.Characters primeiro (jogos customizados)
    local chars = workspace:FindFirstChild("Characters")
    if chars then
        local char = chars:FindFirstChild(lp.Name)
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            if hrp then return hrp end
        end
    end
    -- fallback padrão do Roblox
    local char = lp.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

-- Retorna o HRP do inimigo mais próximo dentro de maxDist
-- Procura em workspace.Characters excluindo o LocalPlayer
-- Uso: local enemyHRP = MatchaLib.GetClosestEnemy(20)
function MatchaLib.GetClosestEnemy(maxDist)
    local myHRP = MatchaLib.GetMyHRP()
    if not myHRP then return nil end

    local chars = workspace:FindFirstChild("Characters")
    if not chars then return nil end

    local best, bestDist = nil, maxDist or math.huge
    local myName = game.Players.LocalPlayer.Name

    for _, char in ipairs(chars:GetChildren()) do
        if char.Name == myName then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        if not hrp then continue end
        local dist = MatchaLib.Dist(hrp.Position, myHRP.Position)
        if dist < bestDist then best = hrp; bestDist = dist end
    end

    return best
end

-- Verifica se dois HRPs estão um de costas para o outro via dot product
-- Retorna "facing", "back" ou "side"
-- Uso: local state = MatchaLib.GetFacingState(myHRP, enemyHRP)
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

-- Retorna o set de nomes de todos os players (para filtrar NPCs)
-- Uso: local players = MatchaLib.GetPlayerSet()
function MatchaLib.GetPlayerSet()
    local set = {}
    for _, p in ipairs(game.Players:GetPlayers()) do set[p.Name] = true end
    return set
end

-- Simula um clique de mouse na posição (x, y)
-- Uso: MatchaLib.Click(500, 300)
function MatchaLib.Click(x, y)
    mousemoveabs(x, y); task.wait(0.05)
    mouse1press();      task.wait(0.05)
    mouse1release()
end

-- Pressiona e solta uma tecla
-- Uso: MatchaLib.PressKey(0x45) -- E
function MatchaLib.PressKey(keycode, holdTime)
    keypress(keycode)
    task.wait(holdTime or 0.05)
    keyrelease(keycode)
end

print("MatchaLib loaded | primOffset="..primOffset.." rotOffset="..rotOffset)
