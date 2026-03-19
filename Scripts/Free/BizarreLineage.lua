loadstring(game:HttpGet("https://pastebin.com/raw/bghZmR8D"))()

local Win = GalaxLib:CreateWindow({
    Title = "Bizarre Hub",
    Size = Vector2.new(625, 510),
    MenuKey = 0x70,
})

-- ── Dados ─────────────────────────────────────────────────────
local targetNames = {
    ["Stand Arrow"]               = Color3.fromRGB(255, 215, 0),
    ["Lucky Arrow"]               = Color3.fromRGB(200, 0, 255),
    ["Stone Mask"]                = Color3.fromRGB(163, 162, 165),
    ["Imperfect Aja"]             = Color3.fromRGB(255, 50, 50),
    ["Red Stone of Aja"]          = Color3.fromRGB(255, 0, 0),
    ["Rokakaka"]                  = Color3.fromRGB(218, 133, 156),
    ["DIO's Diary"]               = Color3.fromRGB(50, 50, 50),
    ["Stat Point Essence"]        = Color3.fromRGB(100, 255, 100),
    ["Stand Skin Essence"]        = Color3.fromRGB(0, 255, 255),
    ["Stand Stat Essence"]        = Color3.fromRGB(255, 100, 0),
    ["Stand Personality Essence"] = Color3.fromRGB(255, 255, 255),
    ["Stand Conjuration Essence"] = Color3.fromRGB(150, 0, 255),
}

local NpcOptions = {
    "???",
    "Akihiko",
    "Ancient Ghost",
    "Arch Mage",
    "Auguste Laurent",
    "Aya Tsuji",
    "Banker",
    "Boxing Coach",
    "Bruford",
    "Caesar Zeppeli",
    "Chumbo",
    "Clinician",
    "Corrupt Police Officer",
    "Cultist Leader",
    "DETERMINATION",
    "Dedequan",
    "Detective",
    "Doctor",
    "Dr. Bosconovitch",
    "Elder Vampire",
    "Gang Contractor",
    "Gardner Gwen",
    "Geordie Greep",
    "Gupta",
    "Gym Owner",
    "Hayato",
    "Hotel Manager",
    "Invisible Baby",
    "Jean Pierre Polnareff",
    "Joseph Joestar",
    "Josuke Higashikata",
    "Jotaro Kujo",
    "Kaiser",
    "Kakyoin",
    "Karate Sensei",
    "Kobayashi",
    "Koichi Hirose",
    "Kyle",
    "Lowly Thief",
    "Mafia Boss",
    "Manuscript 1",
    "Manuscript 2",
    "Manuscript 3",
    "Masuyo",
    "Meditation",
    "Mr. Rengatei",
    "Muhammad Avdol",
    "Nurse",
    "Okuyasu Nijimura",
    "Phantasm",
    "Police Officer",
    "Power Box",
    "Pucci",
    "Rahaj",
    "Receptionist",
    "Reimi",
    "Reina",
    "Ren",
    "Rhett",
    "Rohan Kishibe",
    "Rose",
    "Rudol von Stroheim",
    "Saitama",
    "Samurai Master",
    "Shadowy Figure",
    "Shigechi",
    "Shozuki",
    "Sick Girl",
    "Speedwagon Agent",
    "Speedwagon Researcher",
    "Speedwagon Scientist",
    "The Specialist",
    "Tonio Trussardi",
    "Toyohiro",
    "Travertine",
    "Yoshikage Kira",
    "Yukako Yamagishi",
    "Yuto Horigome",
    "Zuleima",
}

-- Bosses do Void Kill
local Bosses = {
    "DIO",
}

local optimizedBosses = {}
for _, bossName in ipairs(Bosses) do
    local words = {}
    for word in bossName:lower():gmatch("%a+") do table.insert(words, word) end
    table.insert(optimizedBosses, { original = bossName, words = words })
end

-- Inocentes (nunca serão atacados pelo Auto Raid)
local Innocents = {
    "Hostage",
}

local optimizedInnocents = {}
for _, innocentName in ipairs(Innocents) do
    local words = {}
    for word in innocentName:lower():gmatch("%a+") do table.insert(words, word) end
    table.insert(optimizedInnocents, { original = innocentName, words = words })
end

-- ── Tabelas de Teleporte ──────────────────────────────────────
local TpRaidNPCs = {
    { name = "Kira",   pos = Vector3.new(1025,      875.93, -652.89) },
    { name = "Chumbo", pos = Vector3.new(1075.07,   884.23,  207.34) },
    { name = "DIO",    pos = Vector3.new(2797.35,   950.71,  743.84) },
    { name = "Avdol",  pos = Vector3.new(334.18,    876.08, 1021.47) },
}

local TpGangZones = {
    -- usa workspace.Map.Gang Territories.<name>.Zone
    { name = "Morioh Center" },
    { name = "Port"          },
    { name = "Gas Station"   },
}

local TpRaceNPCs = {
    { name = "Hamon",         pos = Vector3.new(1749.23, 874.65, -101.98) },
    { name = "Cyborg",        pos = Vector3.new(435.83,  886.06, -345.48) },
    { name = "Elder Vampire", pos = Vector3.new(2655.92, 949.90,  789.73) },
}

local TpFightingNPCs = {
    { name = "Kendo",  pos = Vector3.new(2060.91, 874.65,  -47.55) },
    { name = "Karate", pos = Vector3.new(544.13,  886.06, -252.10) },
    { name = "Boxing", pos = Vector3.new(1109,    912,      11)    },
}

local TpWorldBosses = {
    { name = "Dr. Bosconovitch",          pos = Vector3.new(1671.93,  1005.69, 1637.73) },
    { name = "Zombie Rudol von Stroheim", pos = Vector3.new(1872.55,   956.80, 1886.28) },
    { name = "Okuyasu Nijimura Prime",    pos = Vector3.new(2332.47,   874.61,  323.02) },
    { name = "Akira Otoishi",             pos = Vector3.new(-1648.22,  893.65,  972.03) },
    { name = "Miyamoto Musashi",          pos = Vector3.new(476.21,    886.94,  -82.79) },
}

local TpMiscPlaces = {
    { name = "PVP Board",       pos = Vector3.new(2632.96, 874.66, -211.93) },
    { name = "Safe Spot",       pos = Vector3.new(1077.64, 936.01, -1391.41) },
    { name = "Quest Giver NPC", pos = Vector3.new(701.67,  894.56, -221.74)  },
}

-- Configurações do Void Dio (keepY)
local voidKeepY         = -410
local voidMoveRange     = 100
local voidMoveSpeed     = 520
local voidMotionOrigin  = nil

-- ── Estado global ─────────────────────────────────────────────
local activeESP          = {}
local selectedItems      = {}
local selectedMobs       = {}
local selectedNpc        = NpcOptions[1]

local heightOffsetValue  = 10
local heightDirection    = -1
local heightOffset       = heightOffsetValue * heightDirection
local xOffset            = 5   -- distância pra trás (mob/raid)

local currentMobTarget   = nil
local savedPosMob        = nil

local currentRaidTarget  = nil
local savedPosRaid       = nil

local meditateTarget     = nil
local pvpTarget          = nil
local selectedPvpPlayer  = nil
local savedPosPvp        = nil
local pvpHeightValue     = 10
local pvpHeightDirection = -1
local pvpHeightOffset    = pvpHeightValue * pvpHeightDirection
local pvpXOffset         = 5   -- distância pra trás (pvp)

_G.ESP_Enabled           = false
_G.AutoFarm_Enabled      = false
_G.AutoMob_Enabled       = false
_G.AutoRaid_Enabled      = false
_G.AutoAttack_Enabled    = false
_G.AutoStand_Enabled     = false
_G.FreezeAnim_Enabled    = false
_G.AutoMeditate_Enabled  = false
_G.MeditateInteracting   = false
_G.AutoPvp_Enabled       = false
_G.AutoPlay_Enabled      = false 
_G.AutoReplay_Enabled    = false 
_G.SafeMode              = true  -- Bloqueado até o jogo carregar

local _savedAnimate      = nil
local _savedAnimator     = nil
local _savedAnimParent   = nil
local _savedAnimrParent  = nil

-- ── Helper: recalcula offset final ───────────────────────────
local function updateOffset()
    heightOffset = heightOffsetValue * heightDirection
end

-- ── Rotação fixa — writes desrolados, sem loop, sem pcall ────
local primOffset = 328
local rotOffset  = 192

-- Matrizes pré-calculadas (row-major, 9 floats)
-- Cache de endereço primitivo por HRP (evita memory_read todo frame)
local _cachedPrim    = nil
local _cachedHrpAddr = nil

-- Calcula matriz de rotação lookAt (igual ao Jade) — aponta de verdade pro alvo
local function getLookAtMatrix(fromPos, toPos)
    local dx, dy, dz = toPos.X - fromPos.X, toPos.Y - fromPos.Y, toPos.Z - fromPos.Z
    local zx, zy, zz = -dx, -dy, -dz
    local zmag = math.sqrt(zx*zx + zy*zy + zz*zz)
    if zmag == 0 then return {1,0,0, 0,1,0, 0,0,1} end
    zx, zy, zz = zx/zmag, zy/zmag, zz/zmag
    local ux, uy, uz = 0, 1, 0
    if math.abs(zy) > 0.9999 then ux, uy, uz = 0, 0, 1 end
    local xx, xy, xz = uy*zz - uz*zy, uz*zx - ux*zz, ux*zy - uy*zx
    local xmag = math.sqrt(xx*xx + xy*xy + xz*xz)
    xx, xy, xz = xx/xmag, xy/xmag, xz/xmag
    local yx, yy, yz = zy*xz - zz*xy, zz*xx - zx*xz, zx*xy - zy*xx
    return {xx, yx, zx, xy, yy, zy, xz, yz, zz}
end

-- applyRot: CFrame.lookAt + memory writes com cache de endereço prim
local function applyRot(hrp, targetPos)
    -- CFrame primeiro (fallback visual)
    local flat = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
    pcall(function() hrp.CFrame = CFrame.lookAt(hrp.Position, flat) end)

    -- memory writes com cache — só relê prim se o HRP mudou
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
    memory_write("float", base,      mat[1])
    memory_write("float", base +  4, mat[2])
    memory_write("float", base +  8, mat[3])
    memory_write("float", base + 12, mat[4])
    memory_write("float", base + 16, mat[5])
    memory_write("float", base + 20, mat[6])
    memory_write("float", base + 24, mat[7])
    memory_write("float", base + 28, mat[8])
    memory_write("float", base + 32, mat[9])
end

-- ── Helper: verifica se é inocente ───────────────────────────
local function isInnocent(obj)
    local ok, dn = pcall(function() return obj:GetAttribute("DisplayName") end)
    local modelNameLower = obj.Name and obj.Name:lower() or ""

    for _, data in ipairs(optimizedInnocents) do
        if ok and dn and dn:lower() == data.original:lower() then return true end
        if modelNameLower == data.original:lower() then return true end
        local allMatch = true
        for _, word in ipairs(data.words) do
            if not modelNameLower:find(word, 1, true) then allMatch = false; break end
        end
        if allMatch then return true end
    end

    return false
end

-- ── Helpers gerais ────────────────────────────────────────────
local function findNpc(name)
    local function searchIn(folder)
        if not folder then return nil end
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") then
                local ok, dn = pcall(function() return obj:GetAttribute("DisplayName") end)
                if ok and dn == name then return obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart end
                if obj.Name == name then return obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart end
            end
        end
        return nil
    end

    return searchIn(game.Workspace:FindFirstChild("Npcs"))
        or searchIn(game.ReplicatedStorage:FindFirstChild("assets") and game.ReplicatedStorage.assets:FindFirstChild("npc_cache"))
end

local function getNearestSelectedObject()
    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearestObj = nil
    local minDistSq = math.huge

    for _, model in ipairs(workspace:GetChildren()) do
        if model.Name == "Model" then
            for _, obj in ipairs(model:GetChildren()) do
                if selectedItems[obj.Name] then
                    local dx = hrp.Position.X - obj.Position.X
                    local dy = hrp.Position.Y - obj.Position.Y
                    local dz = hrp.Position.Z - obj.Position.Z
                    local distSq = dx*dx + dy*dy + dz*dz
                    if distSq < minDistSq then
                        minDistSq = distSq
                        nearestObj = obj
                    end
                end
            end
        end
    end
    return nearestObj
end

local function createEspDrawing(name, color)
    local t = Drawing.new("Text")
    t.Text = "[ " .. name .. " ]"
    t.Color = color; t.Size = 16; t.Center = true; t.Outline = true; t.Visible = false
    local d = Drawing.new("Text")
    d.Color = Color3.fromRGB(255, 255, 255)
    d.Size = 13; d.Center = true; d.Outline = true; d.Visible = false
    return {t, d}
end

local function getHrp()
    return game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function findMeditateClone()
    local lp = game.Players.LocalPlayer
    local live = game.Workspace:FindFirstChild("Live")
    if not live then return nil end
    local nameLower = lp.Name:lower()
    for _, obj in ipairs(live:GetChildren()) do
        local objLower = obj.Name:lower()
        if objLower:find(nameLower, 1, true) and objLower:find("entity clone", 1, true) then return obj end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════════
--  TABS
-- ═══════════════════════════════════════════════════════════════

local VisualsTab = Win:AddTab("Visuals")
local EspSec     = VisualsTab:AddSection("Item ESP")

EspSec:AddToggle("Enable ESP", false, function(v)
    _G.ESP_Enabled = v
    if not v then
        for _, data in pairs(activeESP) do
            pcall(function() data[2]:Remove() end)
            pcall(function() data[3]:Remove() end)
        end
        activeESP = {}
    end
end)

local ExploitTab = Win:AddTab("Exploits")
local AutoSec = ExploitTab:AddSection("Auto")


-- ── Função de scan dinâmico de mobs ──────────────────────────
local function scanLiveMobs()
    local names = {}
    local seen  = {}
    local live  = game.Workspace:FindFirstChild("Live")
    if not live then return names end
    local playerSet = {}
    for _, p in ipairs(game.Players:GetPlayers()) do playerSet[p.Name] = true end

    for _, obj in ipairs(live:GetChildren()) do
        if obj:IsA("Model") and obj.Name ~= "Server" and not playerSet[obj.Name] then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- pega DisplayName se existir, senão limpa o Name igual ao Jade
                local ok, dn = pcall(function() return obj:GetAttribute("DisplayName") end)
                local label
                if ok and type(dn) == "string" and dn ~= "" then
                    label = dn
                else
                    label = obj.Name
                    -- formato ".NomeSemEspaco1a2b3c" → tira ponto inicial e sufixo aleatório de 6 chars
                    if label:sub(1,1) == "." and #label > 7 then
                        label = label:sub(2, -7)
                    end
                end
                -- ignora clones de player (ex: "Fulano entity clone")
                if not label:lower():find("entity clone") and not seen[label] then
                    seen[label] = true
                    table.insert(names, label)
                end
            end
        end
    end
    table.sort(names)
    return names
end

local mobDropdownRef = nil

local _initialMobs = scanLiveMobs()
mobDropdownRef = AutoSec:AddMultiDropdown("Mob Targets", _initialMobs, {}, {MaxVisible=5}, function(tbl)
    selectedMobs = {}
    for _, name in ipairs(tbl) do
        selectedMobs[name] = true
    end
end)

AutoSec:AddButton("Refresh Mob List", function()
    local newMobs = scanLiveMobs()
    if mobDropdownRef then
        mobDropdownRef:Refresh(newMobs, {})
    end
    Win:Notify("List updated!", tostring(#newMobs) .. " mobs found", 2)
end)

AutoSec:AddToggle("Auto Mob", false, function(v)
    local hrp = getHrp()
    if v then
        if hrp then savedPosMob = hrp.Position end
    else
        if hrp and savedPosMob then hrp.Position = savedPosMob end
        savedPosMob = nil
        currentMobTarget = nil
        _cachedHrpAddr = nil
    end
    _G.AutoMob_Enabled = v
end)

AutoSec:AddToggle("Auto Raid", false, function(v)
    local hrp = getHrp()
    if v then
        if hrp then savedPosRaid = hrp.Position end
    else
        if hrp and savedPosRaid then hrp.Position = savedPosRaid end
        savedPosRaid = nil
        currentRaidTarget = nil
        _cachedHrpAddr = nil
        voidMotionOrigin = nil
    end
    _G.AutoRaid_Enabled = v
end)

AutoSec:AddToggle("Auto Play", false, function(v) _G.AutoPlay_Enabled = v end)
AutoSec:AddToggle("Auto Replay", false, function(v) _G.AutoReplay_Enabled = v end)

AutoSec:AddToggle("Auto Attack", false, function(v) _G.AutoAttack_Enabled = v end)
AutoSec:AddToggle("Auto Stand", false, function(v) _G.AutoStand_Enabled = v end)

AutoSec:AddToggle("Auto Meditate", false, function(v)
    _G.AutoMeditate_Enabled = v
    _G.MeditateInteracting = false
    meditateTarget = nil
end)

local _savedAnimValues = {}
AutoSec:AddToggle("Freeze Animations", false, function(v)
    _G.FreezeAnim_Enabled = v
    local char = game.Players.LocalPlayer.Character
    if not char then return end

    if v then
        local animate = char:FindFirstChild("Animate")
        if animate then
            _savedAnimate    = animate
            _savedAnimParent = animate.Parent
            animate.Parent   = game
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                _savedAnimator    = animator
                _savedAnimrParent = animator.Parent
                animator.Parent   = game
            end
        end
    else
        if _savedAnimate and _savedAnimParent then _savedAnimate.Parent = _savedAnimParent end
        if _savedAnimator and _savedAnimrParent then _savedAnimator.Parent = _savedAnimrParent end
        _savedAnimate, _savedAnimator = nil, nil
        _savedAnimParent, _savedAnimrParent = nil, nil
    end
end)

local ConfigSec = ExploitTab:AddSection("Height Config")

ConfigSec:AddDropdown("Direction", {"Down", "Up"}, "Down", {MaxVisible=2}, function(v)
    heightDirection = (v == "Up") and 1 or -1
    updateOffset()
end)

ConfigSec:AddSlider("Height Offset", {Min=0, Max=15, Default=10, Suffix=""}, function(v)
    heightOffsetValue = v
    updateOffset()
end)

ConfigSec:AddSlider("X Offset", {Min=0, Max=15, Default=5, Suffix=""}, function(v)
    xOffset = v
end)

-- ── Items Tab ─────────────────────────────────────────────────
local ItemsTab    = Win:AddTab("Items")
local ItemFarmSec = ItemsTab:AddSection("Auto Farm")

ItemFarmSec:AddMultiDropdown("Farm Items", (function()
    local t = {}
    for name in pairs(targetNames) do table.insert(t, name) end
    table.sort(t); return t
end)(), {}, {MaxVisible=6}, function(tbl)
    selectedItems = {}
    for _, name in ipairs(tbl) do selectedItems[name] = true end
end)

local farmUnderground = false
ItemFarmSec:AddToggle("Underground", false, function(v)
    farmUnderground = v
end)

ItemFarmSec:AddToggle("Auto Farm", false, function(v)
    local hrp = getHrp()
    if v then
        if hrp and _G.SafePlace_Enabled then
            farmSafePos = Vector3.new(hrp.Position.X, hrp.Position.Y + 3000, hrp.Position.Z)
        else
            farmSafePos = nil
        end
    else
        farmSafePos = nil
    end
    _G.AutoFarm_Enabled = v
end)

_G.AutoCollect_Enabled = false
ItemFarmSec:AddToggle("Auto Collect", false, function(v)
    _G.AutoCollect_Enabled = v
end)

local savedPosSafe = nil
_G.SafePlace_Enabled = false
ItemFarmSec:AddToggle("Safe Place", false, function(v)
    local hrp = getHrp()
    if v then
        if hrp then
            savedPosSafe = hrp.Position
            local skyPos = Vector3.new(hrp.Position.X, hrp.Position.Y + 3000, hrp.Position.Z)
            hrp.Position = skyPos
            -- se Auto Farm já está ligado, atualiza farmSafePos imediatamente
            if _G.AutoFarm_Enabled then
                farmSafePos = skyPos
            end
        end
    else
        -- desliga: volta pra posição salva e remove farmSafePos
        if hrp and savedPosSafe then hrp.Position = savedPosSafe end
        savedPosSafe = nil
        if _G.AutoFarm_Enabled then farmSafePos = nil end
    end
    _G.SafePlace_Enabled = v
end)

local ItemTpSec = ItemsTab:AddSection("Teleport")

ItemTpSec:AddMultiDropdown("Select Items", (function()
    local t = {}
    for name in pairs(targetNames) do table.insert(t, name) end
    table.sort(t); return t
end)(), {}, {MaxVisible=6}, function(tbl)
    selectedItems = {}
    for _, name in ipairs(tbl) do selectedItems[name] = true end
end)

ItemTpSec:AddButton("Teleport to Nearest Item", function()
    local hrp = getHrp()
    local obj = getNearestSelectedObject()
    if hrp and obj then
        hrp.Position = obj.Position + Vector3.new(0, 3, 0)
        Win:Notify("Success", "Teleported!", 2)
    else
        Win:Notify("Error", "No selected items found", 2)
    end
end)

-- ── Teleport Tab ───────────────────────────────────────────────
local TpTab = Win:AddTab("Teleport")

-- ── Helper de posição de instância ────────────────────────────
local function resolveWorldPosition(instance)
    if not instance then return nil end
    if instance:IsA("BasePart") then return instance.Position end
    if instance:IsA("Model") and instance.PrimaryPart then return instance.PrimaryPart.Position end
    local p = instance:FindFirstChildWhichIsA("BasePart")
    if p then return p.Position end
    for _, d in ipairs(instance:GetDescendants()) do
        if d:IsA("BasePart") then return d.Position end
    end
    return nil
end

-- ── NPCs ───────────────────────────────────────────────────────
local TpNpcSec = TpTab:AddSection("NPCs")
TpNpcSec:AddDropdown("Select NPC", NpcOptions, NpcOptions[1], {MaxVisible=5}, function(v) selectedNpc = v end)
TpNpcSec:AddButton("Teleport to NPC", function()
    local hrp = getHrp()
    if not hrp then return end
    local target = findNpc(selectedNpc)
    if target then hrp.Position = target.Position + Vector3.new(0, 3, 0) end
end)

-- ── Mission ────────────────────────────────────────────────────
local TpMissionSec = TpTab:AddSection("Mission")
TpMissionSec:AddButton("Teleport to Mission", function()
    local hrp = getHrp()
    if not hrp then return end
    local effects = game.Workspace:FindFirstChild("Effects")
    local questbrick = effects and effects:FindFirstChild("questbrick")
    local part = questbrick and (questbrick.PrimaryPart or questbrick:FindFirstChildOfClass("BasePart"))
    if part then hrp.Position = part.Position + Vector3.new(0, 3, 0) end
end)

-- ── Bus Stops ─────────────────────────────────────────────────
local TpBusSec = TpTab:AddSection("Bus Stops")

local busStopOptions = {}
for i = 1, 19 do table.insert(busStopOptions, tostring(i)) end
local selectedBusStop = "1"

TpBusSec:AddDropdown("Bus Stop", busStopOptions, "1", {MaxVisible=6}, function(v)
    selectedBusStop = v
end)

TpBusSec:AddButton("Teleport to Bus Stop", function()
    local hrp = getHrp()
    if not hrp then return end
    pcall(function()
        local map = game.Workspace:FindFirstChild("Map")
        local busStops = map and map:FindFirstChild("Bus Stops")
        local stop = busStops and busStops:FindFirstChild(selectedBusStop)
        if not stop then Win:Notify("Error", "Bus Stop not found", 2); return end
        local target
        if selectedBusStop == "17" or selectedBusStop == "18" or selectedBusStop == "19" then
            target = stop:FindFirstChild("Bus Parade Glass")
        else
            local parade = stop:FindFirstChild("New Bus Parade")
            target = parade and parade:FindFirstChild("Plane.002")
        end
        local pos = target and resolveWorldPosition(target)
        if pos then hrp.Position = Vector3.new(pos.X, pos.Y + 5, pos.Z) end
    end)
end)

-- ── Raid NPCs ─────────────────────────────────────────────────
local TpRaidSec = TpTab:AddSection("Raid NPCs")
local _raidNames = {}
for _, v in ipairs(TpRaidNPCs) do table.insert(_raidNames, v.name) end
local selectedRaid = _raidNames[1]

TpRaidSec:AddDropdown("Raid NPC", _raidNames, _raidNames[1], {MaxVisible=4}, function(v)
    selectedRaid = v
end)
TpRaidSec:AddButton("Teleport", function()
    local hrp = getHrp(); if not hrp then return end
    for _, v in ipairs(TpRaidNPCs) do
        if v.name == selectedRaid then hrp.Position = v.pos; break end
    end
end)

-- ── Gang Territories ──────────────────────────────────────────
local TpGangSec = TpTab:AddSection("Gang Territories")
local _gangNames = {}
for _, v in ipairs(TpGangZones) do table.insert(_gangNames, v.name) end
local selectedGang = _gangNames[1]

TpGangSec:AddDropdown("Territory", _gangNames, _gangNames[1], {MaxVisible=3}, function(v)
    selectedGang = v
end)
TpGangSec:AddButton("Teleport", function()
    local hrp = getHrp(); if not hrp then return end
    pcall(function()
        local map = game.Workspace:FindFirstChild("Map")
        local territories = map and map:FindFirstChild("Gang Territories")
        local territory = territories and territories:FindFirstChild(selectedGang)
        local zone = territory and territory:FindFirstChild("Zone")
        local pos = zone and resolveWorldPosition(zone)
        if pos then hrp.Position = Vector3.new(pos.X, pos.Y + 5, pos.Z) end
    end)
end)

-- ── Race NPCs ─────────────────────────────────────────────────
local TpRaceSec = TpTab:AddSection("Race NPCs")
local _raceNames = {}
for _, v in ipairs(TpRaceNPCs) do table.insert(_raceNames, v.name) end
local selectedRace = _raceNames[1]

TpRaceSec:AddDropdown("Race NPC", _raceNames, _raceNames[1], {MaxVisible=3}, function(v)
    selectedRace = v
end)
TpRaceSec:AddButton("Teleport", function()
    local hrp = getHrp(); if not hrp then return end
    for _, v in ipairs(TpRaceNPCs) do
        if v.name == selectedRace then hrp.Position = v.pos; break end
    end
end)

-- ── Fighting Style NPCs ───────────────────────────────────────
local TpFightSec = TpTab:AddSection("Fighting Style NPCs")
local _fightNames = {}
for _, v in ipairs(TpFightingNPCs) do table.insert(_fightNames, v.name) end
local selectedFighting = _fightNames[1]

TpFightSec:AddDropdown("Fighting Style", _fightNames, _fightNames[1], {MaxVisible=3}, function(v)
    selectedFighting = v
end)
TpFightSec:AddButton("Teleport", function()
    local hrp = getHrp(); if not hrp then return end
    for _, v in ipairs(TpFightingNPCs) do
        if v.name == selectedFighting then hrp.Position = v.pos; break end
    end
end)

-- ── World Bosses ──────────────────────────────────────────────
local TpBossSec = TpTab:AddSection("World Bosses")
local _bossNames = {}
for _, v in ipairs(TpWorldBosses) do table.insert(_bossNames, v.name) end
local selectedBoss = _bossNames[1]

TpBossSec:AddDropdown("World Boss", _bossNames, _bossNames[1], {MaxVisible=5}, function(v)
    selectedBoss = v
end)
TpBossSec:AddButton("Teleport", function()
    local hrp = getHrp(); if not hrp then return end
    for _, v in ipairs(TpWorldBosses) do
        if v.name == selectedBoss then hrp.Position = v.pos; break end
    end
end)

-- ── Misc ──────────────────────────────────────────────────────
local TpMiscSec = TpTab:AddSection("Misc")
local _miscNames = {}
for _, v in ipairs(TpMiscPlaces) do table.insert(_miscNames, v.name) end
local selectedMisc = _miscNames[1]

TpMiscSec:AddDropdown("Local", _miscNames, _miscNames[1], {MaxVisible=4}, function(v)
    selectedMisc = v
end)
TpMiscSec:AddButton("Teleport", function()
    local hrp = getHrp(); if not hrp then return end
    for _, v in ipairs(TpMiscPlaces) do
        if v.name == selectedMisc then hrp.Position = v.pos; break end
    end
end)

local RageTab = Win:AddTab("Rage")
local PvpSec  = RageTab:AddSection("Auto PvP")

local lp = game.Players.LocalPlayer
local pvpPlayerOptions = {}
for _, p in ipairs(game.Players:GetPlayers()) do
    if p.Name ~= lp.Name then table.insert(pvpPlayerOptions, p.Name) end
end

local pvpDropdownRef = PvpSec:AddDropdown("Select Player", pvpPlayerOptions, pvpPlayerOptions[1] or "", {MaxVisible=5}, function(v)
    selectedPvpPlayer = v
    pvpTarget = nil
end)
PvpSec:AddButton("Refresh Players", function()
    local lp2 = game.Players.LocalPlayer
    local newOpts = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p.Name ~= lp2.Name then table.insert(newOpts, p.Name) end
    end
    pvpDropdownRef:Refresh(newOpts, newOpts[1] or "")
    selectedPvpPlayer = newOpts[1] or nil
    pvpTarget = nil
    Win:Notify("Refreshed!", #newOpts .. " players found", 2)
end)
PvpSec:AddToggle("Auto PvP", false, function(v)
    local hrp = getHrp()
    if v then
        if hrp then savedPosPvp = hrp.Position end
    else
        if hrp and savedPosPvp then hrp.Position = savedPosPvp end
        savedPosPvp = nil
        pvpTarget = nil
        _cachedHrpAddr = nil
    end
    _G.AutoPvp_Enabled = v
end)

local PvpConfigSec = RageTab:AddSection("Height Config")
PvpConfigSec:AddDropdown("Direction", {"Down", "Up"}, "Down", {MaxVisible=2}, function(v)
    pvpHeightDirection = (v == "Up") and 1 or -1
    pvpHeightOffset = pvpHeightValue * pvpHeightDirection
end)
PvpConfigSec:AddSlider("Height Offset", {Min=0, Max=15, Default=10, Suffix=""}, function(v)
    pvpHeightValue = v
    pvpHeightOffset = pvpHeightValue * pvpHeightDirection
end)
PvpConfigSec:AddSlider("X Offset", {Min=0, Max=15, Default=5, Suffix=""}, function(v)
    pvpXOffset = v
end)

-- ── User ID Spoof ─────────────────────────────────────────────
local UserIdSec = RageTab:AddSection("User ID")
local spoofedUserId = nil

-- loop que mantém o valor sobrescrito todo frame
task.spawn(function()
    while true do
        task.wait()
        if spoofedUserId then
            pcall(function()
                local label = game.Players.LocalPlayer.PlayerGui.MainHud.topsection.second.userid
                label.Text = spoofedUserId
            end)
        end
    end
end)

UserIdSec:AddTextbox("Set User ID", "", function(v)
    if v == "" then
        spoofedUserId = nil
    else
        spoofedUserId = tostring(v)
    end
end)
UserIdSec:AddButton("Reset", function()
    spoofedUserId = nil
    pcall(function()
        local label = game.Players.LocalPlayer.PlayerGui.MainHud.topsection.second.userid
        label.Text = tostring(game.Players.LocalPlayer.UserId)
    end)
end)


-- ── Positions Tab ─────────────────────────────────────────────
-- Cada feature que usa clique de mouse tem uma posição customizável.
-- Clique em "Change", mova o mouse, aperte 1 → posição salva.
-- Se não definido, usa o fallback (AbsolutePosition da GUI).

local posCapturing = false

-- Defaults das posições (suas coordenadas pessoais)
local DEFAULT_POS = {
    play         = "1079,693",
    replay       = "1045,760",
    standSearch  = "748,331",
    standSlot    = "689,400",
    standUse     = "1384,586",
    standConfirm = "883,570",
    meditate     = "752,934",
}

local pos_play        = nil
local pos_replay      = nil
local pos_standSearch = nil
local pos_standSlot   = nil
local pos_standUse    = nil
local pos_standConfirm= nil
local pos_meditate    = nil

local function parsePos(str)
    if type(str) ~= "string" or str == "" then return nil end
    local x, y = str:match("^(%d+)%s*,%s*(%d+)$")
    if x and y then return {x = tonumber(x), y = tonumber(y)} end
    return nil
end

-- inicializa todas as posições depois que parsePos está definida
pos_play         = parsePos(DEFAULT_POS.play)
pos_replay       = parsePos(DEFAULT_POS.replay)
pos_standSearch  = parsePos(DEFAULT_POS.standSearch)
pos_standSlot    = parsePos(DEFAULT_POS.standSlot)
pos_standUse     = parsePos(DEFAULT_POS.standUse)
pos_standConfirm = parsePos(DEFAULT_POS.standConfirm)
pos_meditate     = parsePos(DEFAULT_POS.meditate)

local function capturePosition(label, tbRef, onSaved)
    if posCapturing then
        Win:Notify("Please wait", "A capture is already in progress", 2)
        return
    end
    posCapturing = true
    Win:Notify("Move mouse & press 1", "Capturing: " .. label, 5)
    task.spawn(function()
        while iskeypressed(0x31) do task.wait() end
        while not iskeypressed(0x31) do task.wait() end
        local mouse = game.Players.LocalPlayer:GetMouse()
        local x, y = math.floor(mouse.X), math.floor(mouse.Y)
        local str = x .. "," .. y
        tbRef:Set(str)   -- dispara o callback que atualiza pos_*
        posCapturing = false
        Win:Notify("Changed!", label .. ": " .. str, 3)
    end)
end

local PosTab = Win:AddTab("Positions")

-- ── Play ──────────────────────────────────────────────────────
local PosPlaySec = PosTab:AddSection("Auto Play")
local posPlayTb = PosPlaySec:AddTextbox("Quick Play", DEFAULT_POS.play, function(v)
    pos_play = parsePos(v)
end)
PosPlaySec:AddButton("Change", function()
    capturePosition("Quick Play", posPlayTb, function() end)
end)
PosPlaySec:AddButton("Reset", function()
    posPlayTb:Set(DEFAULT_POS.play)
    Win:Notify("Reset", "Quick Play back to default", 2)
end)

-- ── Replay ────────────────────────────────────────────────────
local PosReplaySec = PosTab:AddSection("Auto Replay")
local posReplayTb = PosReplaySec:AddTextbox("Retry Button", DEFAULT_POS.replay, function(v)
    pos_replay = parsePos(v)
end)
PosReplaySec:AddButton("Change", function()
    capturePosition("Retry Button", posReplayTb, function() end)
end)
PosReplaySec:AddButton("Reset", function()
    posReplayTb:Set(DEFAULT_POS.replay)
    Win:Notify("Reset", "Retry back to default", 2)
end)

-- ── Stand Roll ────────────────────────────────────────────────
local PosStandSec = PosTab:AddSection("Stand Roll")

local posSearchTb = PosStandSec:AddTextbox("Stand Search", DEFAULT_POS.standSearch, function(v)
    pos_standSearch = parsePos(v)
end)

local posSlotTb = PosStandSec:AddTextbox("Stand Slot", DEFAULT_POS.standSlot, function(v)
    pos_standSlot = parsePos(v)
end)

local posUseTb = PosStandSec:AddTextbox("Stand Use", DEFAULT_POS.standUse, function(v)
    pos_standUse = parsePos(v)
end)

local posConfirmTb = PosStandSec:AddTextbox("Stand Confirm", DEFAULT_POS.standConfirm, function(v)
    pos_standConfirm = parsePos(v)
end)

PosStandSec:AddButton("Change Search", function()
    capturePosition("Stand Search", posSearchTb, function() end)
end)
PosStandSec:AddButton("Change Slot", function()
    capturePosition("Stand Slot", posSlotTb, function() end)
end)
PosStandSec:AddButton("Change Use", function()
    capturePosition("Stand Use", posUseTb, function() end)
end)
PosStandSec:AddButton("Change Confirm", function()
    capturePosition("Stand Confirm", posConfirmTb, function() end)
end)
PosStandSec:AddButton("Reset All", function()
    posSearchTb:Set(DEFAULT_POS.standSearch)
    posSlotTb:Set(DEFAULT_POS.standSlot)
    posUseTb:Set(DEFAULT_POS.standUse)
    posConfirmTb:Set(DEFAULT_POS.standConfirm)
    Win:Notify("Reset", "Stand Roll back to default", 2)
end)

-- ── Meditate ──────────────────────────────────────────────────
local PosMeditateSec = PosTab:AddSection("Auto Meditate")
local posMeditateTb = PosMeditateSec:AddTextbox("Dialogue Button", DEFAULT_POS.meditate, function(v)
    pos_meditate = parsePos(v)
end)
PosMeditateSec:AddButton("Change", function()
    capturePosition("Meditate Dialogue", posMeditateTb, function() end)
end)
PosMeditateSec:AddButton("Reset", function()
    pos_meditate = nil
    posMeditateTb:Set("")
    Win:Notify("Reset", "Meditate back to default", 2)
end)

-- ── Stand Tab ─────────────────────────────────────────────────
local StandTab      = Win:AddTab("Stand")
local StandInfoSec  = StandTab:AddSection("Stand Info")

local HttpService = game:GetService("HttpService")

local function getStandData()
    local pd = game.Players.LocalPlayer:FindFirstChild("PlayerData")
    if pd then
        local sd = pd:FindFirstChild("SlotData")
        if sd then
            local standVal = sd:FindFirstChild("Stand")
            if standVal and standVal:IsA("StringValue") then
                local str = standVal.Value
                if str and str ~= "" and str ~= "None" then
                    local ok, decoded = pcall(function() return HttpService:JSONDecode(str) end)
                    if ok and type(decoded) == "table" then return decoded end
                end
            end
        end
    end
    return nil
end

local grades = { [1]="D", [2]="C", [3]="B", [4]="A", [5]="S" }
local function getGrade(val) return grades[tonumber(val)] or tostring(val or 0) end

local standLabel1 = StandInfoSec:AddLabel("Stand: ---")
local standLabel2 = StandInfoSec:AddLabel("Trait: ---")
local standLabel3 = StandInfoSec:AddLabel("Speed: ---")
local standLabel4 = StandInfoSec:AddLabel("Spec: ---")
local standLabel5 = StandInfoSec:AddLabel("Str: ---")
local standLabel6 = StandInfoSec:AddLabel("Skin: ---")

local function updateStandLabels()
    local sd = getStandData()
    if sd and sd.Name then
        standLabel1:Set(string.format("Stand: %s", tostring(sd.Name)))
        standLabel2:Set(string.format("Trait: %s", tostring(sd.Trait or "None")))
        standLabel3:Set(string.format("Speed: %s", getGrade(sd.Speed)))
        standLabel4:Set(string.format("Spec: %s",  getGrade(sd.Specialty)))
        standLabel5:Set(string.format("Str: %s",   getGrade(sd.Strength)))
        standLabel6:Set(string.format("Skin: %s",  tostring(sd.Skin or "None")))
    else
        standLabel1:Set("Stand: None")
        standLabel2:Set("Trait: None")
        standLabel3:Set("Speed: -")
        standLabel4:Set("Spec: -")
        standLabel5:Set("Str: -")
        standLabel6:Set("Skin: None")
    end
end

StandInfoSec:AddButton("Refresh Info", function()
    updateStandLabels()
end)

-- Atualiza labels ao iniciar
task.spawn(function()
    task.wait(3)
    updateStandLabels()
end)

-- ── Auto Roll ─────────────────────────────────────────────────
local StandRollSec   = StandTab:AddSection("Auto Roll")

-- Lista de stands obtíveis via Stand Arrow (roll)
local StandList = {
    "Red Hot Chili Pepper",
    "Magician's Red",
    "The Hand",
    "Purple Haze",
    "Crazy Diamond",
    "Golden Experience",
    "Anubis",
    "Killer Queen",
    "Weather Report",
    "Stone Free",
    "Star Platinum",
    "The World",
    "King Crimson",
    "The World High Voltage",
    "Whitesnake",
}
table.sort(StandList)

local targetStands       = {}  -- set: { [standName] = true }
local stopOnAnySkin      = false
local standRollThread    = nil
local autoStandRollActive = false

StandRollSec:AddMultiDropdown("Target Stands", StandList, {}, {MaxVisible = 6}, function(tbl)
    targetStands = {}
    for _, name in ipairs(tbl) do
        targetStands[name] = true
    end
end)

StandRollSec:AddToggle("Stop on Any Skin", false, function(v)
    stopOnAnySkin = v
end)

local function useStandArrow()
    if Win._open then return false end

    keypress(0xC0); task.wait(0.05); keyrelease(0xC0)
    task.wait(3)

    if not isrbxactive() then return false end
    setrobloxinput(true)

    -- ── Search box ────────────────────────────────────────────
    local cx, cy
    if pos_standSearch then
        cx, cy = pos_standSearch.x, pos_standSearch.y
    else
        local gui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        local inv = gui and gui:FindFirstChild("Inventory")
        local cg  = inv and inv:FindFirstChild("CanvasGroup")
        local bf  = cg  and cg:FindFirstChild("backpack_frame")
        local sb  = bf  and bf:FindFirstChild("search")
        if not sb then return false end
        local absPos  = sb.AbsolutePosition
        local absSize = sb.AbsoluteSize
        cx = absPos.X + absSize.X/2
        cy = absPos.Y + absSize.Y/2 + 20
    end

    mousemoveabs(cx, cy); task.wait(0.3)
    mousemoverel(0, 2);   task.wait(0.3)
    mouse1click();        task.wait(0.4)

    setclipboard("stand arrow"); task.wait(0.1)
    keypress(0x11); keypress(0x56); task.wait(0.05)
    keyrelease(0x56); keyrelease(0x11); task.wait(0.4)

    -- ── Arrow slot ────────────────────────────────────────────
    if pos_standSlot then
        mousemoveabs(pos_standSlot.x, pos_standSlot.y); task.wait(0.3)
        mousemoverel(0, 2); task.wait(0.3)
        mouse1click(); task.wait(0.5)
    end

    -- ── Use button (só clica se posição estiver definida) ─────
    if pos_standUse then
        mousemoveabs(pos_standUse.x, pos_standUse.y); task.wait(0.3)
        mousemoverel(0, 2); task.wait(0.3)
        mouse1click()
    end

    task.wait(0.5)

    -- ── Confirm button (só clica se posição estiver definida) ─
    if pos_standConfirm then
        mousemoveabs(pos_standConfirm.x, pos_standConfirm.y); task.wait(0.3)
        mousemoverel(0, 2); task.wait(0.3)
        mouse1click()
    end

    return true
end

local autoRollToggleRef = nil

local function autoStandRollLoop()
    while autoStandRollActive do
        local oldData = getStandData()
        local oldName = oldData and oldData.Name or "None"

        local used = useStandArrow()
        if not used then task.wait(2); continue end

        local t0 = os.clock()
        local newData = nil
        while (os.clock() - t0 < 15) and autoStandRollActive do
            newData = getStandData()
            local newName = newData and newData.Name or "None"
            if newName ~= oldName then break end
            task.wait(0.5)
        end

        if not autoStandRollActive then break end

        if newData then
            updateStandLabels()
            local newName = newData.Name or "None"
            local hasSkin = newData.Skin and newData.Skin ~= "" and newData.Skin ~= "None"
            local isTarget = targetStands[newName] == true
            if isTarget or (stopOnAnySkin and hasSkin) then
                autoStandRollActive = false
                if autoRollToggleRef then pcall(function() autoRollToggleRef:Set(false) end) end
                Win:Notify("Auto Roll stopped!", "Stand: " .. tostring(newName), 5)
                break
            end
        end
        task.wait(2)
    end
end

local rollToggle = StandRollSec:AddToggle("Auto Roll", false, function(v)
    autoStandRollActive = v
    if v then
        if standRollThread then pcall(task.cancel, standRollThread) end
        standRollThread = task.spawn(autoStandRollLoop)
    else
        if standRollThread then pcall(task.cancel, standRollThread); standRollThread = nil end
    end
end)
autoRollToggleRef = rollToggle

-- ── Helper unificado: teleporta e aplica rotação ─────────────
-- yOff = altura, xOff = distância pra trás (sempre atrás do boneco, que olha pro alvo)
local function trackTarget(hrp, targetHrp, yOff, xOff)
    local tx, tz = targetHrp.Position.X, targetHrp.Position.Z
    local ox, oz = hrp.Position.X,       hrp.Position.Z
    local dx, dz = tx - ox, tz - oz
    local len = math.sqrt(dx*dx + dz*dz)
    local backX, backZ = 0, 0
    if len > 0.01 and xOff and xOff ~= 0 then
        backX = -(dx / len) * xOff
        backZ = -(dz / len) * xOff
    end
    hrp.Position = Vector3.new(tx + backX, targetHrp.Position.Y + yOff, tz + backZ)
    applyRot(hrp, targetHrp.Position)
end

-- ═══════════════════════════════════════════════════════════════
--  LOOPS (Com bloqueio Inteligente do Menu Game & Menu UI)
-- ═══════════════════════════════════════════════════════════════

task.spawn(function()
    while true do
        if _G.ESP_Enabled then
            for _, model in ipairs(workspace:GetChildren()) do
                if model.Name == "Model" then
                    for _, obj in ipairs(model:GetChildren()) do
                        if targetNames[obj.Name] and not activeESP[obj] then
                            local d = createEspDrawing(obj.Name, targetNames[obj.Name])
                            activeESP[obj] = {obj, d[1], d[2]}
                        end
                    end
                end
            end
            task.wait(5)
        else task.wait(1) end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not _G.ESP_Enabled then
            for _, data in pairs(activeESP) do
                pcall(function() data[2].Visible = false end)
                pcall(function() data[3].Visible = false end)
            end
            continue
        end
        local lp = game.Players.LocalPlayer
        if not lp then continue end
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local myPos = hrp.Position
        for item, data in pairs(activeESP) do
            local part, txtName, txtDist = data[1], data[2], data[3]
            if part and part.Parent and item and item.Parent then
                local pos, onScreen = WorldToScreen(part.Position)
                if onScreen then
                    local tp = part.Position
                    local dist = math.sqrt((myPos.X-tp.X)^2 + (myPos.Y-tp.Y)^2 + (myPos.Z-tp.Z)^2)
                    txtName.Position = Vector2.new(pos.X, pos.Y)
                    txtName.Visible = true
                    txtDist.Text = math.floor(dist) .. " studs"
                    txtDist.Position = Vector2.new(pos.X, pos.Y + 15)
                    txtDist.Visible = true
                else
                    txtName.Visible = false
                    txtDist.Visible = false
                end
            else
                txtName:Remove(); txtDist:Remove(); activeESP[item] = nil
            end
        end
    end
end)

local farmItemCache     = {}
local farmCacheLastTime = 0
local farmCacheTTL      = 1.5

local function refreshFarmCache()
    local now = os.clock()
    if now - farmCacheLastTime < farmCacheTTL then return end
    farmCacheLastTime = now
    farmItemCache = {}
    local ok, children = pcall(function() return workspace:GetChildren() end)
    if not ok then return end
    for _, child in ipairs(children) do
        if child.Name == "Model" then
            local okD, descs = pcall(function() return child:GetDescendants() end)
            if okD then
                for _, obj in ipairs(descs) do
                    if targetNames[obj.Name] then
                        table.insert(farmItemCache, obj)
                        if #farmItemCache >= 30 then return end
                    end
                end
            end
        end
        if #farmItemCache >= 30 then break end
    end
end

local function getNearestCachedItem(hrpPos)
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(farmItemCache) do
        if obj and obj.Parent then
            local ok, pos = pcall(function() return obj.Position end)
            if ok and pos then
                local dx = hrpPos.X - pos.X; local dy = hrpPos.Y - pos.Y; local dz = hrpPos.Z - pos.Z
                local d = dx*dx + dy*dy + dz*dz
                if d < bestDist then bestDist = d; best = obj end
            end
        end
    end
    return best
end

-- ═══════════════════════════════════════════════════════════════
--  FARM STATE MACHINE
--  _G.AutoFarmWorking = false → sem item, Safe Place segura no céu
--  _G.AutoFarmWorking = true  → item achado, Safe Place para,
--                               farm tpa, E + 3 segurados juntos
-- ═══════════════════════════════════════════════════════════════
_G.AutoFarmWorking = false


-- ── Farm principal ────────────────────────────────────────────
task.spawn(function()
    while true do
        task.wait(0.1)
        if not _G.AutoFarm_Enabled then
            _G.AutoFarmWorking = false
            continue
        end
        if _G.SafeMode then _G.AutoFarmWorking = false; task.wait(1); continue end

        local hrp = getHrp()
        if not hrp then _G.AutoFarmWorking = false; task.wait(1); continue end

        refreshFarmCache()
        local obj = getNearestCachedItem(hrp.Position)

        if obj and obj.Parent then
            _G.AutoFarmWorking = true
            local yOff = farmUnderground and -5 or 3
            if _G.AutoCollect_Enabled then
                keypress(69)
                local t0 = os.clock()
                while os.clock() - t0 < 1.8 and _G.AutoFarm_Enabled do
                    if obj and obj.Parent then
                        hrp.Position = obj.Position + Vector3.new(0, yOff, 0)
                        pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
                    end
                    task.wait()
                end
                keyrelease(69)
                task.wait(0.3)
            else
                hrp.Position = obj.Position + Vector3.new(0, yOff, 0)
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
                task.wait(0.1)
            end
        else
            -- ── sem item: Working off, Safe Place assume ──────
            _G.AutoFarmWorking = false
            if farmSafePos then
                hrp.Position = farmSafePos
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
            end
            task.wait(0.5)
        end
    end
end)

-- ── Auto Collect ──────────────────────────────────────────────
-- Só age quando Working = true (item próximo), segura 3 no mesmo timing do farm
task.spawn(function()
    while true do
        task.wait(0.1)
        if not _G.AutoCollect_Enabled then continue end
        if _G.SafeMode then continue end
        if Win._open then continue end
        if not _G.AutoFarmWorking then continue end

        keypress(0x33)
        task.wait(1.8)
        keyrelease(0x33)
        task.wait(0.3)
    end
end)

-- ── Safe Place via task.wait ─────────────────────────────────
task.spawn(function()
    while true do
        task.wait()
        if not _G.SafePlace_Enabled then continue end
        if _G.SafeMode then continue end
        if _G.AutoFarmWorking then continue end
        local hrp = getHrp()
        if not hrp or not savedPosSafe then continue end
        local skyY = savedPosSafe.Y + 3000
        hrp.Position = Vector3.new(savedPosSafe.X, skyY, savedPosSafe.Z)
        pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
    end
end)

-- Loop de tp unificado
task.spawn(function()
    while true do
        task.wait()
        if _G.SafeMode then continue end
        local hrp = getHrp()
        if not hrp then continue end
        if _G.AutoMob_Enabled and currentMobTarget then
            if not currentMobTarget.Parent then
                currentMobTarget = nil; _cachedHrpAddr = nil
            else
                trackTarget(hrp, currentMobTarget, heightOffset, xOffset)
            end
        elseif _G.AutoRaid_Enabled and currentRaidTarget then
            if not currentRaidTarget.Parent then
                currentRaidTarget = nil; _cachedHrpAddr = nil
            else
                trackTarget(hrp, currentRaidTarget, heightOffset, xOffset)
            end
        elseif _G.AutoPvp_Enabled and pvpTarget then
            if not pvpTarget.Parent then
                pvpTarget = nil; _cachedHrpAddr = nil
            else
                trackTarget(hrp, pvpTarget, pvpHeightOffset, pvpXOffset)
            end
        elseif _G.AutoMeditate_Enabled and meditateTarget and not _G.MeditateInteracting then
            if not meditateTarget.Parent then
                meditateTarget = nil; _cachedHrpAddr = nil
            else
                local cloneHrp = meditateTarget:FindFirstChild("HumanoidRootPart")
                if cloneHrp then trackTarget(hrp, cloneHrp, heightOffset, xOffset)
                else meditateTarget = nil end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not _G.AutoMob_Enabled then continue end
        if _G.SafeMode then task.wait(1); continue end
        local hrp = getHrp()
        if not hrp then continue end

        -- se já tem target válido, o loop unificado cuida do tp+rot
        if currentMobTarget and currentMobTarget.Parent then continue end

        currentMobTarget = nil
        local nearest = nil; local minDistSq = math.huge
        local playerSet = {}
        for _, p in ipairs(game.Players:GetPlayers()) do playerSet[p.Name] = true end

        for _, obj in ipairs(game.Workspace.Live:GetChildren()) do
            if obj:IsA("Model") and obj.Name ~= "Server" and not playerSet[obj.Name] then
                local ok, dn = pcall(function() return obj:GetAttribute("DisplayName") end)
                local label = (ok and type(dn) == "string" and dn ~= "") and dn or obj.Name
                if label:sub(1,1) == "." and #label > 7 then label = label:sub(2, -7) end
                if selectedMobs[label] == true then
                    local mobHrp = obj:FindFirstChild("HumanoidRootPart")
                    if mobHrp then
                        local dx = hrp.Position.X - mobHrp.Position.X
                        local dy = hrp.Position.Y - mobHrp.Position.Y
                        local dz = hrp.Position.Z - mobHrp.Position.Z
                        local dSq = dx*dx + dy*dy + dz*dz
                        if dSq < minDistSq then minDistSq = dSq; nearest = mobHrp end
                    end
                end
            end
        end
        if nearest then currentMobTarget = nearest end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not _G.AutoRaid_Enabled then continue end
        if _G.SafeMode then task.wait(1); continue end
        local hrp = getHrp()
        if not hrp then continue end

        -- auto-exec fix: set savedPosRaid if not set yet
        if not savedPosRaid then savedPosRaid = hrp.Position end

        -- trava no target atual enquanto vivo (evita scan toda iteração)
        if currentRaidTarget and currentRaidTarget.Parent then
            local hum = currentRaidTarget.Parent:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then continue end
            currentRaidTarget = nil; voidMotionOrigin = nil
        end

        local nearest = nil; local minDistSq = math.huge

        -- wait for Live to exist (auto-exec can be too fast)
        local live = game.Workspace:FindFirstChild("Live")
        if not live then task.wait(0.5); continue end

        for _, obj in ipairs(live:GetChildren()) do
            if obj:IsA("Model") and obj.Name ~= "Server" then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 and not game.Players:FindFirstChild(obj.Name) then
                    if isInnocent(obj) then continue end
                    local raidHrp = obj:FindFirstChild("HumanoidRootPart")
                    if raidHrp then
                        local dx = hrp.Position.X - raidHrp.Position.X
                        local dy = hrp.Position.Y - raidHrp.Position.Y
                        local dz = hrp.Position.Z - raidHrp.Position.Z
                        local dSq = dx*dx + dy*dy + dz*dz
                        if dSq < minDistSq then minDistSq = dSq; nearest = raidHrp end
                    end
                end
            end
        end

        if nearest then
            local obj = nearest.Parent
            if not obj or not obj.Parent then continue end

            -- verifica se é boss (void kill)
            local matchedBoss = false
            local ok, dn = pcall(function() return obj:GetAttribute("DisplayName") end)
            local modelNameLower = obj.Name and obj.Name:lower() or ""
            for _, bossData in ipairs(optimizedBosses) do
                if ok and dn and dn:lower() == bossData.original:lower() then matchedBoss = true; break end
                if modelNameLower == bossData.original:lower() then matchedBoss = true; break end
                local allMatch = true
                for _, word in ipairs(bossData.words) do
                    if not modelNameLower:find(word, 1, true) then allMatch = false; break end
                end
                if allMatch then matchedBoss = true; break end
            end

            if matchedBoss then
                -- boss: loop unificado NÃO deve fazer tp, void cuida aqui
                currentRaidTarget = nil
                if not voidMotionOrigin then
                    voidMotionOrigin = Vector3.new(hrp.Position.X, voidKeepY, hrp.Position.Z)
                end
                local angle = os.clock() * (voidMoveSpeed / voidMoveRange)
                local ox = math.cos(angle) * voidMoveRange
                local oz = math.sin(angle) * voidMoveRange
                hrp.Position = Vector3.new(voidMotionOrigin.X + ox, voidKeepY, voidMotionOrigin.Z + oz)
                pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
            else
                -- NPC normal: entrega ao loop unificado via trackTarget
                currentRaidTarget = nearest
                voidMotionOrigin = nil
            end
        else
            currentRaidTarget = nil
            hrp.Position = savedPosRaid
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if not _G.AutoAttack_Enabled then continue end
        if _G.SafeMode then task.wait(1); continue end
        if Win._open then continue end
        mouse1press()
        task.wait(0.1)
        mouse1release()
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if not _G.AutoStand_Enabled then continue end
        if _G.SafeMode then task.wait(1); continue end
        local lp = game.Players.LocalPlayer
        if not lp then task.wait(1); continue end
        local live = game.Workspace:FindFirstChild("Live")
        if not live then task.wait(1); continue end
        local charModel = live:FindFirstChild(lp.Name)
        if not charModel then task.wait(1); continue end
        local val = charModel:GetAttribute("SummonedStand") or ""
        if type(val) ~= "string" then val = tostring(val) end
        if #val < 2 then
            keypress(0x09); task.wait(0.1); keyrelease(0x09)
            task.wait(1) -- espera o atributo atualizar antes de checar de novo
        end
    end
end)

local meditateArenaFallback = Vector3.new(1075.60, 884.34, 89.38)
local function clickFirstChoice()
    if not pos_meditate then return end
    mousemoveabs(pos_meditate.x, pos_meditate.y); task.wait(0.05)
    for i = 1, 4 do
        local jx, jy = ((i % 2 == 0) and 2 or -2), ((i % 2 == 0) and 1 or -1)
        mousemoveabs(pos_meditate.x + jx, pos_meditate.y + jy); task.wait(0.03)
    end
    mousemoveabs(pos_meditate.x, pos_meditate.y); task.wait(0.05)
    mouse1press(); task.wait(0.08); mouse1release()
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not _G.AutoMeditate_Enabled then continue end
        if _G.SafeMode then meditateTarget = nil; task.wait(1); continue end
        local hrp = getHrp()
        if not hrp then continue end

        if meditateTarget and not meditateTarget.Parent then meditateTarget = nil end
        if not meditateTarget then meditateTarget = findMeditateClone() end

        if not meditateTarget then
            local theSelf = game.Workspace:FindFirstChild("Npcs") and game.Workspace.Npcs:FindFirstChild("The Self")
            local selfHrp = theSelf and (theSelf:FindFirstChild("HumanoidRootPart") or theSelf.PrimaryPart)

            if selfHrp then
                local selfPos = selfHrp.Position + Vector3.new(0, 3, 0)
                local t0 = os.clock()
                while os.clock() - t0 < 0.5 and _G.AutoMeditate_Enabled do
                    hrp.Position = selfPos
                    pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
                    task.wait()
                end
                keypress(69); task.wait(3); keyrelease(69)
                task.wait(0.3)
                clickFirstChoice()
                task.wait(1)
                meditateTarget = findMeditateClone()
            else
                -- fallback: ponto fixo da arena
                local t0 = os.clock()
                while os.clock() - t0 < 0.5 and _G.AutoMeditate_Enabled do
                    hrp.Position = meditateArenaFallback
                    pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
                    task.wait()
                end
                keypress(69); task.wait(3); keyrelease(69)
                task.wait(3)
            end
            continue
        end

        -- tem clone: trackTarget igual mob/raid
        local cloneHrp = meditateTarget:FindFirstChild("HumanoidRootPart")
        if cloneHrp then
            trackTarget(hrp, cloneHrp, heightOffset, xOffset)
        else
            meditateTarget = nil
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not _G.AutoPlay_Enabled then continue end
        if _G.SafeMode then continue end   -- boot cuida do clique no menu
        if Win._open then continue end

        local lp = game.Players.LocalPlayer
        if not lp then task.wait(1); continue end
        local playerGui = lp:FindFirstChild("PlayerGui")
        if not playerGui then continue end

        local mainMenu = playerGui:FindFirstChild("Main Menu")
        local buttons  = mainMenu and mainMenu:FindFirstChild("Buttons")
        local playBtn  = buttons and buttons:FindFirstChild("Quick Play")

        if playBtn then
            task.wait(1)
            local targetX, targetY
            if pos_play then
                targetX, targetY = pos_play.x, pos_play.y
            else
                local okPos, pos = pcall(function() return playBtn.AbsolutePosition end)
                local okSize, size = pcall(function() return playBtn.AbsoluteSize end)
                if not (okPos and okSize) then continue end
                targetX = pos.X + (size.X / 2)
                targetY = pos.Y + (size.Y / 10) + 36
            end

            mousemoveabs(targetX, targetY); task.wait(0.05)
            for i = 1, 4 do
                local jx = (i % 2 == 0) and 2 or -2
                local jy = (i % 2 == 0) and 1 or -1
                mousemoveabs(targetX + jx, targetY + jy); task.wait(0.03)
            end
            mousemoveabs(targetX, targetY); task.wait(0.05)
            mouse1press(); task.wait(0.08); mouse1release()
            _G.AutoPlay_Enabled = false
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not _G.AutoReplay_Enabled then continue end
        
        -- [NOVO] Suspende se a interface da GalaxLib está visível na tela
        if Win._open then continue end
        
        local lp = game.Players.LocalPlayer
        if not lp then task.wait(1); continue end
        local playerGui = lp:FindFirstChild("PlayerGui")
        if not playerGui then continue end

        local raidcomplete = playerGui:FindFirstChild("raidcomplete")
        local raid = raidcomplete and raidcomplete:FindFirstChild("raid")
        local retryBtn = raid and raid:FindFirstChild("retry")

        if retryBtn then
            local targetX, targetY
            if pos_replay then
                targetX, targetY = pos_replay.x, pos_replay.y
            else
                local okPos, pos = pcall(function() return retryBtn.AbsolutePosition end)
                local okSize, size = pcall(function() return retryBtn.AbsoluteSize end)
                if not (okPos and okSize) then continue end
                targetX = pos.X + (size.X / 2)
                targetY = pos.Y + (size.Y / 2)
            end

            mousemoveabs(targetX, targetY); task.wait(0.05)
            for i = 1, 4 do
                local jx = (i % 2 == 0) and 2 or -2
                local jy = (i % 2 == 0) and 1 or -1
                mousemoveabs(targetX + jx, targetY + jy); task.wait(0.03)
            end
            mousemoveabs(targetX, targetY); task.wait(0.05)
            mouse1press(); task.wait(0.08); mouse1release()
            task.wait(4)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not _G.AutoPvp_Enabled then continue end
        if _G.SafeMode then pvpTarget = nil; task.wait(1); continue end
        if not selectedPvpPlayer then continue end
        -- se já tem target válido, o loop unificado cuida do tp+rot
        if pvpTarget and pvpTarget.Parent then continue end
        pvpTarget = nil
        local live = game.Workspace:FindFirstChild("Live")
        if not live then continue end
        for _, obj in ipairs(live:GetChildren()) do
            if obj.Name == selectedPvpPlayer and obj:IsA("Model") then
                local targetHrp = obj:FindFirstChild("HumanoidRootPart")
                if targetHrp then pvpTarget = targetHrp; break end
            end
        end
    end
end)



-- ═══════════════════════════════════════════════════════════════
--  SISTEMA DE BOOT CENTRAL
--
--  Detecção por dois GUIs confiáveis:
--    MainHud  existe  + Main Menu não existe  → dentro do jogo
--    Main Menu existe + MainHud  não existe   → no menu (Quick Play)
--
--  Fluxo:
--   1. Espera PlayerGui carregar
--   2. Carrega APENAS a aba "Positions" da config manualmente
--   3. Se já está no jogo → espera 3s → carrega tudo → SafeMode = false
--   4. Se está no menu:
--      a. Lê o valor salvo de AutoPlay diretamente do JSON
--      b. Se AutoPlay ligado: espera 2s, fica clicando até entrar no jogo
--      c. Quando MainHud aparecer e Main Menu sumir → espera 3s → carrega tudo
-- ═══════════════════════════════════════════════════════════════

-- Lê o JSON da config e aplica APENAS os tabs listados em allowedTabs
local function loadConfigPartial(allowedTabs)
    local safeTitle = string.gsub(Win.Title, "[^%w%s]", "")
    local path = "Galax/Scripts/" .. safeTitle .. ".json"
    local ok, content = pcall(readfile, path)
    if not ok or type(content) ~= "string" or content == "" then return end
    local dok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(content)
    end)
    if not dok or type(data) ~= "table" then return end

    -- monta set de tabs permitidos
    local allowed = {}
    for _, name in ipairs(allowedTabs) do allowed[name] = true end

    for _, tab in ipairs(Win._tabs) do
        if tab._isSettings then continue end
        if not allowed[tab._name] then continue end  -- ← filtra aqui
        local tabData = data[tab._name]
        if type(tabData) ~= "table" then continue end
        for _, sec in ipairs(tab._sections) do
            local secData = tabData[sec._name]
            if type(secData) ~= "table" then continue end
            for _, w in ipairs(sec._widgets) do
                local val = secData[w.label]
                if val == nil then continue end
                pcall(function()
                    if w.type == "toggle" and type(val) == "table" then
                        if val.value ~= nil then w.value = val.value end
                        if val.keybind ~= nil then w.keybind = val.keybind end
                        pcall(w.cb, w.value)
                    elseif w.type == "multidropdown" and type(val) == "table" then
                        w.selected = {}
                        for _, opt in ipairs(val) do w.selected[opt] = true end
                        local out = {}
                        for _, o in ipairs(w.options) do
                            if w.selected[o] then out[#out+1] = o end
                        end
                        pcall(w.cb, out)
                    elseif w.type == "slider" or w.type == "dropdown"
                        or w.type == "textbox" or w.type == "keybind" then
                        w.value = val
                        pcall(w.cb, w.value)
                    elseif w.type == "colorpicker" and type(val) == "table" then
                        if val.R and val.G and val.B then
                            w.value = Color3.new(val.R, val.G, val.B)
                            pcall(w.cb, w.value)
                        end
                    end
                end)
            end
        end
    end
end

-- Lê o valor de AutoPlay diretamente do JSON sem aplicar nada mais
local function readAutoPlayFromConfig()
    local safeTitle = string.gsub(Win.Title, "[^%w%s]", "")
    local path = "Galax/Scripts/" .. safeTitle .. ".json"
    local ok, content = pcall(readfile, path)
    if not ok or type(content) ~= "string" or content == "" then return false end
    local dok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(content)
    end)
    if not dok or type(data) ~= "table" then return false end
    local v = data["Exploits"] and data["Exploits"]["Auto"] and data["Exploits"]["Auto"]["Auto Play"]
    return type(v) == "table" and v.value == true
end

local function getGuiState()
    local lp = game.Players.LocalPlayer
    if not lp then return "loading" end
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return "loading" end
    local hasMainHud  = pg:FindFirstChild("MainHud")  ~= nil
    local hasMainMenu = pg:FindFirstChild("Main Menu") ~= nil
    if hasMainHud and not hasMainMenu then return "ingame" end
    if hasMainMenu then return "menu" end  -- Main Menu presente = menu, independente de MainHud
    return "loading"
end

local function clickPlayButton()
    if Win._open then return end
    local lp = game.Players.LocalPlayer
    if not lp then return end
    local pg = lp:FindFirstChild("PlayerGui")
    if not pg then return end
    local mainMenu = pg:FindFirstChild("Main Menu")
    local buttons  = mainMenu and mainMenu:FindFirstChild("Buttons")
    local playBtn  = buttons and buttons:FindFirstChild("Quick Play")
    if not playBtn then return end

    local targetX, targetY
    if pos_play then
        targetX, targetY = pos_play.x, pos_play.y
    else
        local okPos, pos = pcall(function() return playBtn.AbsolutePosition end)
        local okSize, size = pcall(function() return playBtn.AbsoluteSize end)
        if not (okPos and okSize) then return end
        targetX = pos.X + (size.X / 2)
        targetY = pos.Y + (size.Y / 10) + 36
    end

    mousemoveabs(targetX, targetY); task.wait(0.05)
    for i = 1, 4 do
        local jx = (i % 2 == 0) and 2 or -2
        local jy = (i % 2 == 0) and 1 or -1
        mousemoveabs(targetX + jx, targetY + jy); task.wait(0.03)
    end
    mousemoveabs(targetX, targetY); task.wait(0.05)
    mouse1press(); task.wait(0.08); mouse1release()
end

task.spawn(function()
    -- 1. Espera PlayerGui existir
    repeat task.wait(0.5) until game.Players.LocalPlayer
        and game.Players.LocalPlayer:FindFirstChild("PlayerGui")

    -- 2. Carrega APENAS Positions — pos_* ficam prontos antes de qualquer clique
    loadConfigPartial({"Positions"})

    -- 3. Aguarda estado definido (sem transitório) — timeout de 10s assume ingame
    local state = getGuiState()
    local t0 = os.clock()
    while state == "loading" do
        task.wait(0.5)
        state = getGuiState()
        if os.clock() - t0 > 10 then state = "ingame"; break end
    end

    if state == "ingame" then
        task.wait(3)
        Win:LoadConfig(true, false)
        _G.SafeMode = false
        Win:Notify("Config loaded!", "Bizarre Hub", 3)

    elseif state == "menu" then
        _G.SafeMode = true
        local shouldAutoPlay = readAutoPlayFromConfig()

        if shouldAutoPlay then
            task.wait(2)
            while getGuiState() == "menu" do
                clickPlayButton()
                task.wait(2)
            end
        end

        -- Aguarda transição sumir — timeout de 15s
        local t1 = os.clock()
        while getGuiState() == "loading" do
            task.wait(0.5)
            if os.clock() - t1 > 15 then break end
        end

        task.wait(3)
        Win:LoadConfig(true, false)
        _G.SafeMode = false
        Win:Notify("Config loaded!", "Bizarre Hub", 3)
    end

    -- 4. Watchdog: detecta se voltou ao menu (kick, reconexão, etc.)
    while Win._running do
        task.wait(1)
        local s = getGuiState()
        if s == "menu" then
            _G.SafeMode = true
            local shouldAutoPlay = readAutoPlayFromConfig()
            while getGuiState() ~= "ingame" do
                if shouldAutoPlay and getGuiState() == "menu" then
                    clickPlayButton()
                end
                task.wait(2)
            end
            task.wait(3)
            Win:LoadConfig(true, false)
            _G.SafeMode = false
            Win:Notify("Config loaded!", "Bizarre Hub", 3)
        elseif s == "loading" then
            _G.SafeMode = true
        end
    end
end)

Win:Notify("Bizarre Hub", "Whymayko", 3)
