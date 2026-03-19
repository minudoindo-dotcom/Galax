-- ════════════════════════════════════════════════════════════════
--  Bizarre Hub
--  Author  : Whymayko
--  Lib     : GalaxLib (loaded below)
-- ════════════════════════════════════════════════════════════════

-- ── 1. LIBS ──────────────────────────────────────────────────────
loadstring(game:HttpGet("https://raw.githubusercontent.com/minudoindo-dotcom/Galax/refs/heads/main/Lib/Beta/Galax.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/minudoindo-dotcom/Galax/refs/heads/main/Lib/Beta/MatchaLib.lua"))()

-- MatchaLib já carregou offsets e expõe MatchaLib.Offsets
-- primOffset e rotOffset ficam disponíveis via MatchaLib internamente

-- ── 3. WINDOW ────────────────────────────────────────────────────
local Win = GalaxLib:CreateWindow({
    Title   = "Bizarre Hub",
    Size    = Vector2.new(625, 510),
    MenuKey = 0x70,
})

-- ════════════════════════════════════════════════════════════════
--  4. DATA TABLES
-- ════════════════════════════════════════════════════════════════

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
    "???","Akihiko","Ancient Ghost","Arch Mage","Auguste Laurent",
    "Aya Tsuji","Banker","Boxing Coach","Bruford","Caesar Zeppeli",
    "Chumbo","Clinician","Corrupt Police Officer","Cultist Leader",
    "DETERMINATION","Dedequan","Detective","Doctor","Dr. Bosconovitch",
    "Elder Vampire","Gang Contractor","Gardner Gwen","Geordie Greep",
    "Gupta","Gym Owner","Hayato","Hotel Manager","Invisible Baby",
    "Jean Pierre Polnareff","Joseph Joestar","Josuke Higashikata",
    "Jotaro Kujo","Kaiser","Kakyoin","Karate Sensei","Kobayashi",
    "Koichi Hirose","Kyle","Lowly Thief","Mafia Boss","Manuscript 1",
    "Manuscript 2","Manuscript 3","Masuyo","Meditation","Mr. Rengatei",
    "Muhammad Avdol","Nurse","Okuyasu Nijimura","Phantasm",
    "Police Officer","Power Box","Pucci","Rahaj","Receptionist",
    "Reimi","Reina","Ren","Rhett","Rohan Kishibe","Rose",
    "Rudol von Stroheim","Saitama","Samurai Master","Shadowy Figure",
    "Shigechi","Shozuki","Sick Girl","Speedwagon Agent",
    "Speedwagon Researcher","Speedwagon Scientist","The Specialist",
    "Tonio Trussardi","Toyohiro","Travertine","Yoshikage Kira",
    "Yukako Yamagishi","Yuto Horigome","Zuleima",
}

local Bosses = { "DIO" }
local optimizedBosses = {}
for _, bossName in ipairs(Bosses) do
    local words = {}
    for word in bossName:lower():gmatch("%a+") do table.insert(words, word) end
    table.insert(optimizedBosses, { original = bossName, words = words })
end

local Innocents = { "Hostage" }
local optimizedInnocents = {}
for _, name in ipairs(Innocents) do
    local words = {}
    for word in name:lower():gmatch("%a+") do table.insert(words, word) end
    table.insert(optimizedInnocents, { original = name, words = words })
end

local TpRaidNPCs = {
    { name = "Kira",   pos = Vector3.new(1025,    875.93, -652.89) },
    { name = "Chumbo", pos = Vector3.new(1075.07, 884.23,  207.34) },
    { name = "DIO",    pos = Vector3.new(2797.35, 950.71,  743.84) },
    { name = "Avdol",  pos = Vector3.new(334.18,  876.08, 1021.47) },
}
local TpGangZones = {
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
    { name = "Dr. Bosconovitch",          pos = Vector3.new(1671.93, 1005.69, 1637.73) },
    { name = "Zombie Rudol von Stroheim", pos = Vector3.new(1872.55,  956.80, 1886.28) },
    { name = "Okuyasu Nijimura Prime",    pos = Vector3.new(2332.47,  874.61,  323.02) },
    { name = "Akira Otoishi",             pos = Vector3.new(-1648.22, 893.65,  972.03) },
    { name = "Miyamoto Musashi",          pos = Vector3.new(476.21,   886.94,  -82.79) },
}
local TpMiscPlaces = {
    { name = "PVP Board",       pos = Vector3.new(2632.96, 874.66, -211.93)  },
    { name = "Safe Spot",       pos = Vector3.new(1077.64, 936.01, -1391.41) },
    { name = "Quest Giver NPC", pos = Vector3.new(701.67,  894.56, -221.74)  },
}

local voidKeepY        = -410
local voidMoveRange    = 100
local voidMoveSpeed    = 520
local voidMotionOrigin = nil

-- ════════════════════════════════════════════════════════════════
--  5. STATE
-- ════════════════════════════════════════════════════════════════

local activeESP          = {}
local selectedItems      = {}
local selectedMobs       = {}
local selectedNpc        = NpcOptions[1]

local heightOffsetValue  = 10
local heightDirection    = -1
local heightOffset       = heightOffsetValue * heightDirection
local xOffset            = 5

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
local pvpXOffset         = 5

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
_G.SafeMode              = true

local _cachedHrpAddr = nil  -- shim: cache real e interno na MatchaLib, esta var e usada apenas para resets locais
local _savedAnimator     = nil
local _savedAnimParent   = nil
local _savedAnimrParent  = nil

-- Items/Farm state
local farmUnderground    = false
local farmSafePos        = nil
local savedPosSafe       = nil
_G.AutoCollect_Enabled   = false
_G.SafePlace_Enabled     = false

-- PVE state
_G.AutoPVE_Enabled       = false
local _pveThread         = nil
local _pveTargets        = nil

local function updateOffset()
    heightOffset = heightOffsetValue * heightDirection
end

-- ════════════════════════════════════════════════════════════════
--  6. HELPERS (via MatchaLib onde possível)
-- ════════════════════════════════════════════════════════════════

-- Aliases curtos para uso interno
local function getHrp()       return MatchaLib.GetMyHRP() end
local function applyRot(h,t)  return MatchaLib.LookAt(h,t) end
local function trackTarget(hrp, targetHrp, yOff, xOff)
    return MatchaLib.TrackTarget(hrp, targetHrp, yOff, xOff)
end

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
    local hrp = getHrp()
    if not hrp then return nil end
    local nearestObj, minDistSq = nil, math.huge
    for _, model in ipairs(workspace:GetChildren()) do
        if model.Name == "Model" then
            for _, obj in ipairs(model:GetChildren()) do
                if selectedItems[obj.Name] then
                    local dx = hrp.Position.X-obj.Position.X
                    local dy = hrp.Position.Y-obj.Position.Y
                    local dz = hrp.Position.Z-obj.Position.Z
                    local dSq = dx*dx+dy*dy+dz*dz
                    if dSq < minDistSq then minDistSq=dSq; nearestObj=obj end
                end
            end
        end
    end
    return nearestObj
end

local function findMeditateClone()
    local lp   = game.Players.LocalPlayer
    local live = game.Workspace:FindFirstChild("Live")
    if not live then return nil end
    local nameLower = lp.Name:lower()
    for _, obj in ipairs(live:GetChildren()) do
        local objLower = obj.Name:lower()
        if objLower:find(nameLower,1,true) and objLower:find("entity clone",1,true) then return obj end
    end
    return nil
end

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

-- ════════════════════════════════════════════════════════════════
--  7. PVE HELPERS (declared before UI so AutoSec toggle can reference autoPveLoop)
-- ════════════════════════════════════════════════════════════════

local function getPveQuestType()
    local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local notifs = pg:FindFirstChild("Notifications")
    if not notifs then return nil end
    local holder = notifs:FindFirstChild("holder")
    if not holder then return nil end
    for _, child in ipairs(holder:GetChildren()) do
        local name = child.Name:lower()
        if name:find("exterminate") or name:find("defeat") then return "Exterminate" end
        if name:find("deliver") then return "Deliver" end
        if name:find("already in an active mission") then return "Active" end
    end
    return nil
end

local function pveTeleport(pos) MatchaLib.TeleportTo(getHrp(), pos) end
local function pveDist(a, b)   return MatchaLib.Dist(a, b) end
local function getPlayerSet()  return MatchaLib.GetPlayerSet() end

local function autoPveLoop()
    local QUEST_GIVER_POS = Vector3.new(701.67, 894.56, -221.74)
    while _G.AutoPVE_Enabled do
        _G.AutoRaid_Enabled = false; currentRaidTarget = nil; _cachedHrpAddr = nil
        pveTeleport(QUEST_GIVER_POS); task.wait(0.5)
        keypress(0x45); task.wait(1.5); keyrelease(0x45); task.wait(1)

        local t0 = os.clock()
        while os.clock() - t0 < 8 and _G.AutoPVE_Enabled do
            local qType = getPveQuestType()
            -- ja tem missao ativa — pula direto pro reset sem esperar 8s
            if qType == "Active" then break end
            if qType == "Deliver" then
                local effects    = workspace:FindFirstChild("Effects")
                local questGroup = effects and effects:FindFirstChild("questbrick")
                local questBrick = questGroup and (questGroup:FindFirstChild("questbrick") or questGroup)
                if questBrick and questBrick:IsA("BasePart") then
                    pveTeleport(questBrick.Position); task.wait(3)
                    keypress(0x45); task.wait(2); keyrelease(0x45); task.wait(1); break
                end
            elseif qType == "Exterminate" then
                local live = workspace:FindFirstChild("Live")
                local playerSet = getPlayerSet()
                local hrp = getHrp()
                local centerNpc, shortDist = nil, math.huge
                if live and hrp then
                    for _, npc in ipairs(live:GetChildren()) do
                        if not playerSet[npc.Name]
                        and npc:FindFirstChildWhichIsA("Highlight")
                        and npc:FindFirstChild("Humanoid")
                        and npc.Humanoid.Health > 0 then
                            local npcHrp = npc:FindFirstChild("HumanoidRootPart")
                            if npcHrp then
                                local d = pveDist(npcHrp.Position, hrp.Position)
                                if d < shortDist then shortDist=d; centerNpc=npc end
                            end
                        end
                    end
                end
                if centerNpc then
                    task.wait(1)
                    local centerPos = centerNpc:FindFirstChild("HumanoidRootPart") and centerNpc.HumanoidRootPart.Position
                    if centerPos then
                        _pveTargets = {}; local hasTargets = false
                        for _, npc in ipairs(live:GetChildren()) do
                            if not playerSet[npc.Name]
                            and npc:FindFirstChildWhichIsA("Highlight")
                            and npc:FindFirstChild("Humanoid")
                            and npc.Humanoid.Health > 0 then
                                local nHrp = npc:FindFirstChild("HumanoidRootPart")
                                if nHrp and pveDist(nHrp.Position, centerPos) <= 500 then
                                    _pveTargets[npc]=true; hasTargets=true
                                end
                            end
                        end
                        if hasTargets then
                            _G.AutoRaid_Enabled=true; savedPosRaid=getHrp() and getHrp().Position
                            while _G.AutoPVE_Enabled do
                                local stillAlive = false
                                for npc in pairs(_pveTargets) do
                                    if npc.Parent and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                                        local nHrp = npc:FindFirstChild("HumanoidRootPart")
                                        if nHrp then stillAlive=true; currentRaidTarget=nHrp; break end
                                    else _pveTargets[npc]=nil end
                                end
                                if not stillAlive then break end
                                task.wait(0.2)
                            end
                            _G.AutoRaid_Enabled=false; currentRaidTarget=nil
                            _pveTargets=nil; _cachedHrpAddr=nil; savedPosRaid=nil
                            task.wait(1); break
                        end
                    end
                end
            end
            task.wait(0.1)
        end

        if _G.AutoPVE_Enabled and getPveQuestType() == nil then
            keypress(0x1B); task.wait(0.1); keyrelease(0x1B); task.wait(0.3)
            keypress(0x52); task.wait(0.1); keyrelease(0x52); task.wait(0.3)
            keypress(0x0D); task.wait(0.1); keyrelease(0x0D); task.wait(3)
        end
        if _G.AutoPVE_Enabled then task.wait(2) end
    end
    _G.AutoRaid_Enabled=false; currentRaidTarget=nil; _pveTargets=nil; _cachedHrpAddr=nil
end

-- ════════════════════════════════════════════════════════════════
--  8. ESP CONFIG (declared before UI so toggles can reference it)
-- ════════════════════════════════════════════════════════════════

local _espCFG = {
    box        = true,
    name       = true,
    distance   = true,
    traceline  = false,
    renderWait = 0.033,
}

local _playerESP = {
    enable     = false,
    showName   = true,
    showDist   = true,
    showStand  = true,
    nameColor  = Color3.fromRGB(255, 255, 255),
    standColor = Color3.fromRGB(255, 200, 50),
    drawings   = {},
}

-- ════════════════════════════════════════════════════════════════
--  8. UI — TABS & SECTIONS
-- ════════════════════════════════════════════════════════════════

-- ── Visuals ──────────────────────────────────────────────────────
local VisualsTab   = Win:AddTab("Visuals")

local EspSec       = VisualsTab:AddSection("Item ESP")
EspSec:AddToggle("Enable ESP", false, function(v)
    _G.ESP_Enabled = v
    if not v then
        for item, esp in pairs(activeESP) do
            MatchaLib.ESP.Destroy(esp)
        end
        activeESP = {}
    end
end)
EspSec:AddToggle("Box",       true,  function(v) _espCFG.box       = v end)
EspSec:AddToggle("Name",      true,  function(v) _espCFG.name      = v end)
EspSec:AddToggle("Distance",  true,  function(v) _espCFG.distance  = v end)
EspSec:AddToggle("Traceline", false, function(v) _espCFG.traceline = v end)
EspSec:AddDropdown("ESP FPS", {"30","60","120","240"}, "30", function(v)
    _espCFG.renderWait = 1 / tonumber(v)
end)

local PlayerEspSec = VisualsTab:AddSection("Player ESP")
PlayerEspSec:AddToggle("Enable",   false, function(v) _playerESP.enable    = v end)
PlayerEspSec:AddToggle("Name",     true,  function(v) _playerESP.showName  = v end)
PlayerEspSec:AddToggle("Distance", true,  function(v) _playerESP.showDist  = v end)
PlayerEspSec:AddToggle("Stand",    true,  function(v) _playerESP.showStand = v end)
PlayerEspSec:AddColorPicker("Name Color",  Color3.fromRGB(255,255,255), function(c) _playerESP.nameColor  = c end)
PlayerEspSec:AddColorPicker("Stand Color", Color3.fromRGB(255,200,50),  function(c) _playerESP.standColor = c end)

-- Player ESP render loop
task.spawn(function()
    while true do
        task.wait(_espCFG.renderWait)
        if not _playerESP.enable then
            for _, b in pairs(_playerESP.drawings) do
                b.name.Visible=false; b.dist.Visible=false; b.stand.Visible=false
            end
            continue
        end
        local lp    = game.Players.LocalPlayer
        local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local myPos = myHrp and myHrp.Position
        local live  = workspace:FindFirstChild("Live")
        if not live then continue end
        local seen = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p == lp then continue end
            pcall(function()
                local char = live:FindFirstChild(p.Name)
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                if not hrp then return end
                local wpos = hrp.Position + Vector3.new(0, 3, 0)
                local okW, sp, onScreen = pcall(WorldToScreen, wpos)
                if not okW or not sp or not onScreen then return end
                seen[p.Name] = true
                local b = _playerESP.drawings[p.Name]
                if not b then
                    local name  = Drawing.new("Text")
                    name.Center=true; name.Outline=true
                    name.Font=Drawing.Fonts.SystemBold; name.Size=14
                    name.ZIndex=10; name.Visible=false
                    local dist  = Drawing.new("Text")
                    dist.Center=true; dist.Outline=true
                    dist.Font=Drawing.Fonts.UI; dist.Size=12
                    dist.Color=Color3.fromRGB(200,200,200); dist.ZIndex=10; dist.Visible=false
                    local stand = Drawing.new("Text")
                    stand.Center=true; stand.Outline=true
                    stand.Font=Drawing.Fonts.UI; stand.Size=12
                    stand.ZIndex=10; stand.Visible=false
                    b = {name=name, dist=dist, stand=stand}
                    _playerESP.drawings[p.Name] = b
                end
                if _playerESP.showName then
                    b.name.Text=p.Name; b.name.Color=_playerESP.nameColor
                    b.name.Position=Vector2.new(sp.X, sp.Y); b.name.Visible=true
                else b.name.Visible=false end
                local distY = sp.Y + (_playerESP.showName and 16 or 0)
                if _playerESP.showDist and myPos then
                    local d = math.floor(MatchaLib.Dist(hrp.Position, myPos))
                    b.dist.Text="["..d.."m]"; b.dist.Color=Color3.fromRGB(200,200,200)
                    b.dist.Position=Vector2.new(sp.X, distY); b.dist.Visible=true
                    distY = distY + 16
                else b.dist.Visible=false end
                if _playerESP.showStand then
                    local ok2, val = pcall(function() return char:GetAttribute("SummonedStand") end)
                    val = (ok2 and type(val)=="string" and #val>=2) and val or "No Stand"
                    b.stand.Text=val; b.stand.Color=_playerESP.standColor
                    b.stand.Position=Vector2.new(sp.X, distY); b.stand.Visible=true
                else b.stand.Visible=false end
            end)
        end
        for name, b in pairs(_playerESP.drawings) do
            if not seen[name] then
                b.name.Visible=false; b.dist.Visible=false; b.stand.Visible=false
            end
        end
    end
end)

-- ── Exploits ─────────────────────────────────────────────────────
local ExploitTab = Win:AddTab("Exploits")

local AutoSec    = ExploitTab:AddSection("Auto")

local mobDropdownRef = nil
local function scanLiveMobs()
    local names, seen = {}, {}
    local live = game.Workspace:FindFirstChild("Live")
    if not live then return names end
    local playerSet = {}
    for _, p in ipairs(game.Players:GetPlayers()) do playerSet[p.Name] = true end
    for _, obj in ipairs(live:GetChildren()) do
        if obj:IsA("Model") and obj.Name ~= "Server" and not playerSet[obj.Name] then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local ok, dn = pcall(function() return obj:GetAttribute("DisplayName") end)
                local label = (ok and type(dn)=="string" and dn~="") and dn or obj.Name
                if label:sub(1,1)=="." and #label>7 then label=label:sub(2,-7) end
                if not label:lower():find("entity clone") and not seen[label] then
                    seen[label]=true; table.insert(names, label)
                end
            end
        end
    end
    table.sort(names)
    return names
end

local _initialMobs = scanLiveMobs()
mobDropdownRef = AutoSec:AddMultiDropdown("Mob Targets", _initialMobs, {}, {MaxVisible=5}, function(tbl)
    selectedMobs = {}
    for _, name in ipairs(tbl) do selectedMobs[name] = true end
end)
AutoSec:AddButton("Refresh Mob List", function()
    local newMobs = scanLiveMobs()
    if mobDropdownRef then mobDropdownRef:Refresh(newMobs, {}) end
    Win:Notify("List updated!", tostring(#newMobs).." mobs found", 2)
end)
AutoSec:AddToggle("Auto Mob", false, function(v)
    local hrp = getHrp()
    if v then if hrp then savedPosMob=hrp.Position end
    else
        if hrp and savedPosMob then hrp.Position=savedPosMob end
        savedPosMob=nil; currentMobTarget=nil; _cachedHrpAddr=nil
    end
    _G.AutoMob_Enabled = v
end)
AutoSec:AddToggle("Auto Raid", false, function(v)
    local hrp = getHrp()
    if v then if hrp then savedPosRaid=hrp.Position end
    else
        if hrp and savedPosRaid then hrp.Position=savedPosRaid end
        savedPosRaid=nil; currentRaidTarget=nil; _cachedHrpAddr=nil; voidMotionOrigin=nil
    end
    _G.AutoRaid_Enabled = v
end)
AutoSec:AddToggle("Auto Play",    false, function(v) _G.AutoPlay_Enabled    = v end)
AutoSec:AddToggle("Auto Replay",  false, function(v) _G.AutoReplay_Enabled  = v end)
AutoSec:AddToggle("Auto Attack",  false, function(v) _G.AutoAttack_Enabled  = v end)
AutoSec:AddToggle("Auto Stand",   false, function(v) _G.AutoStand_Enabled   = v end)
AutoSec:AddToggle("Auto Meditate", false, function(v)
    _G.AutoMeditate_Enabled = v
    _G.MeditateInteracting  = false
    meditateTarget          = nil
end)
AutoSec:AddToggle("Auto PVE Mission", false, function(v)
    _G.AutoPVE_Enabled = v
    if v then
        if _pveThread then pcall(task.cancel, _pveThread) end
        _pveThread = task.spawn(autoPveLoop)
    else
        if _pveThread then pcall(task.cancel, _pveThread); _pveThread=nil end
        _G.AutoRaid_Enabled=false; currentRaidTarget=nil; _pveTargets=nil
        _cachedHrpAddr=nil; keyrelease(0x45)
    end
end)
AutoSec:AddToggle("Freeze Animations", false, function(v)
    _G.FreezeAnim_Enabled = v
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    if v then
        local animate = char:FindFirstChild("Animate")
        if animate then _savedAnimate=animate; _savedAnimParent=animate.Parent; animate.Parent=game end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then _savedAnimator=animator; _savedAnimrParent=animator.Parent; animator.Parent=game end
        end
    else
        if _savedAnimate   and _savedAnimParent  then _savedAnimate.Parent  = _savedAnimParent  end
        if _savedAnimator  and _savedAnimrParent then _savedAnimator.Parent = _savedAnimrParent end
        _savedAnimate=nil; _savedAnimator=nil; _savedAnimParent=nil; _savedAnimrParent=nil
    end
end)

local ConfigSec = ExploitTab:AddSection("Height Config")
ConfigSec:AddDropdown("Direction", {"Down","Up"}, "Down", {MaxVisible=2}, function(v)
    heightDirection = (v=="Up") and 1 or -1; updateOffset()
end)
ConfigSec:AddSlider("Height Offset", {Min=0,Max=15,Default=10,Suffix=""}, function(v)
    heightOffsetValue=v; updateOffset()
end)
ConfigSec:AddSlider("X Offset", {Min=0,Max=15,Default=5,Suffix=""}, function(v)
    xOffset=v
end)

-- ── Items ─────────────────────────────────────────────────────────
local ItemsTab    = Win:AddTab("Items")

local ItemFarmSec = ItemsTab:AddSection("Auto Farm")
ItemFarmSec:AddMultiDropdown("Farm Items", (function()
    local t={}; for name in pairs(targetNames) do table.insert(t,name) end; table.sort(t); return t
end)(), {}, {MaxVisible=6}, function(tbl)
    selectedItems={}; for _,name in ipairs(tbl) do selectedItems[name]=true end
end)
ItemFarmSec:AddToggle("Underground", false, function(v) farmUnderground=v end)
ItemFarmSec:AddToggle("Auto Farm", false, function(v)
    local hrp = getHrp()
    if v then
        farmSafePos = (hrp and _G.SafePlace_Enabled) and Vector3.new(hrp.Position.X,hrp.Position.Y+3000,hrp.Position.Z) or nil
    else
        farmSafePos = nil
    end
    _G.AutoFarm_Enabled = v
end)
ItemFarmSec:AddToggle("Auto Collect", false, function(v) _G.AutoCollect_Enabled = v end)
ItemFarmSec:AddToggle("Safe Place", false, function(v)
    local hrp = getHrp()
    if v then
        if hrp then
            savedPosSafe = hrp.Position
            local skyPos = Vector3.new(hrp.Position.X, hrp.Position.Y+3000, hrp.Position.Z)
            hrp.Position = skyPos
            if _G.AutoFarm_Enabled then farmSafePos = skyPos end
        end
    else
        if hrp and savedPosSafe then hrp.Position = savedPosSafe end
        savedPosSafe = nil
        if _G.AutoFarm_Enabled then farmSafePos = nil end
    end
    _G.SafePlace_Enabled = v
end)

local ItemTpSec = ItemsTab:AddSection("Teleport")
ItemTpSec:AddMultiDropdown("Select Items", (function()
    local t={}; for name in pairs(targetNames) do table.insert(t,name) end; table.sort(t); return t
end)(), {}, {MaxVisible=6}, function(tbl)
    selectedItems={}; for _,name in ipairs(tbl) do selectedItems[name]=true end
end)
ItemTpSec:AddButton("Teleport to Nearest Item", function()
    local hrp=getHrp(); local obj=getNearestSelectedObject()
    if hrp and obj then hrp.Position=obj.Position+Vector3.new(0,3,0); Win:Notify("Success","Teleported!",2)
    else Win:Notify("Error","No selected items found",2) end
end)

-- ── Teleport ──────────────────────────────────────────────────────
local TpTab = Win:AddTab("Teleport")

local TpNpcSec = TpTab:AddSection("NPCs")
TpNpcSec:AddDropdown("Select NPC", NpcOptions, NpcOptions[1], {MaxVisible=5}, function(v) selectedNpc=v end)
TpNpcSec:AddButton("Teleport to NPC", function()
    local hrp=getHrp(); if not hrp then return end
    local target=findNpc(selectedNpc)
    if target then hrp.Position=target.Position+Vector3.new(0,3,0) end
end)

local TpMissionSec = TpTab:AddSection("Mission")
TpMissionSec:AddButton("Teleport to Mission", function()
    local hrp=getHrp(); if not hrp then return end
    local effects=game.Workspace:FindFirstChild("Effects")
    local questbrick=effects and effects:FindFirstChild("questbrick")
    local part=questbrick and (questbrick.PrimaryPart or questbrick:FindFirstChildOfClass("BasePart"))
    if part then hrp.Position=part.Position+Vector3.new(0,3,0) end
end)

local TpBusSec        = TpTab:AddSection("Bus Stops")
local busStopOptions  = {}
for i=1,19 do table.insert(busStopOptions, tostring(i)) end
local selectedBusStop = "1"
TpBusSec:AddDropdown("Bus Stop", busStopOptions, "1", {MaxVisible=6}, function(v) selectedBusStop=v end)
TpBusSec:AddButton("Teleport to Bus Stop", function()
    local hrp=getHrp(); if not hrp then return end
    pcall(function()
        local map=game.Workspace:FindFirstChild("Map")
        local busStops=map and map:FindFirstChild("Bus Stops")
        local stop=busStops and busStops:FindFirstChild(selectedBusStop)
        if not stop then Win:Notify("Error","Bus Stop not found",2); return end
        local target
        if selectedBusStop=="17" or selectedBusStop=="18" or selectedBusStop=="19" then
            target=stop:FindFirstChild("Bus Parade Glass")
        else
            local parade=stop:FindFirstChild("New Bus Parade")
            target=parade and parade:FindFirstChild("Plane.002")
        end
        local pos=target and resolveWorldPosition(target)
        if pos then hrp.Position=Vector3.new(pos.X,pos.Y+5,pos.Z) end
    end)
end)

local TpRaidSec  = TpTab:AddSection("Raid NPCs")
local _raidNames = {}
for _,v in ipairs(TpRaidNPCs) do table.insert(_raidNames,v.name) end
local selectedRaid = _raidNames[1]
TpRaidSec:AddDropdown("Raid NPC", _raidNames, _raidNames[1], {MaxVisible=4}, function(v) selectedRaid=v end)
TpRaidSec:AddButton("Teleport", function()
    local hrp=getHrp(); if not hrp then return end
    for _,v in ipairs(TpRaidNPCs) do if v.name==selectedRaid then hrp.Position=v.pos; break end end
end)

local TpGangSec  = TpTab:AddSection("Gang Territories")
local _gangNames = {}
for _,v in ipairs(TpGangZones) do table.insert(_gangNames,v.name) end
local selectedGang = _gangNames[1]
TpGangSec:AddDropdown("Territory", _gangNames, _gangNames[1], {MaxVisible=3}, function(v) selectedGang=v end)
TpGangSec:AddButton("Teleport", function()
    local hrp=getHrp(); if not hrp then return end
    pcall(function()
        local map=game.Workspace:FindFirstChild("Map")
        local territories=map and map:FindFirstChild("Gang Territories")
        local territory=territories and territories:FindFirstChild(selectedGang)
        local zone=territory and territory:FindFirstChild("Zone")
        local pos=zone and resolveWorldPosition(zone)
        if pos then hrp.Position=Vector3.new(pos.X,pos.Y+5,pos.Z) end
    end)
end)

local TpRaceSec  = TpTab:AddSection("Race NPCs")
local _raceNames = {}
for _,v in ipairs(TpRaceNPCs) do table.insert(_raceNames,v.name) end
local selectedRace = _raceNames[1]
TpRaceSec:AddDropdown("Race NPC", _raceNames, _raceNames[1], {MaxVisible=3}, function(v) selectedRace=v end)
TpRaceSec:AddButton("Teleport", function()
    local hrp=getHrp(); if not hrp then return end
    for _,v in ipairs(TpRaceNPCs) do if v.name==selectedRace then hrp.Position=v.pos; break end end
end)

local TpFightSec  = TpTab:AddSection("Fighting Style NPCs")
local _fightNames = {}
for _,v in ipairs(TpFightingNPCs) do table.insert(_fightNames,v.name) end
local selectedFighting = _fightNames[1]
TpFightSec:AddDropdown("Fighting Style", _fightNames, _fightNames[1], {MaxVisible=3}, function(v) selectedFighting=v end)
TpFightSec:AddButton("Teleport", function()
    local hrp=getHrp(); if not hrp then return end
    for _,v in ipairs(TpFightingNPCs) do if v.name==selectedFighting then hrp.Position=v.pos; break end end
end)

local TpBossSec  = TpTab:AddSection("World Bosses")
local _bossNames = {}
for _,v in ipairs(TpWorldBosses) do table.insert(_bossNames,v.name) end
local selectedBoss = _bossNames[1]
TpBossSec:AddDropdown("World Boss", _bossNames, _bossNames[1], {MaxVisible=5}, function(v) selectedBoss=v end)
TpBossSec:AddButton("Teleport", function()
    local hrp=getHrp(); if not hrp then return end
    for _,v in ipairs(TpWorldBosses) do if v.name==selectedBoss then hrp.Position=v.pos; break end end
end)

local TpMiscSec  = TpTab:AddSection("Misc")
local _miscNames = {}
for _,v in ipairs(TpMiscPlaces) do table.insert(_miscNames,v.name) end
local selectedMisc = _miscNames[1]
TpMiscSec:AddDropdown("Local", _miscNames, _miscNames[1], {MaxVisible=4}, function(v) selectedMisc=v end)
TpMiscSec:AddButton("Teleport", function()
    local hrp=getHrp(); if not hrp then return end
    for _,v in ipairs(TpMiscPlaces) do if v.name==selectedMisc then hrp.Position=v.pos; break end end
end)

-- ── Rage ──────────────────────────────────────────────────────────
local RageTab = Win:AddTab("Rage")

local PvpSec          = RageTab:AddSection("Auto PvP")
local lp              = game.Players.LocalPlayer
local pvpPlayerOptions = {}
for _,p in ipairs(game.Players:GetPlayers()) do
    if p.Name ~= lp.Name then table.insert(pvpPlayerOptions, p.Name) end
end
local pvpDropdownRef = PvpSec:AddDropdown("Select Player", pvpPlayerOptions, pvpPlayerOptions[1] or "", {MaxVisible=5}, function(v)
    selectedPvpPlayer=v; pvpTarget=nil
end)
PvpSec:AddButton("Refresh Players", function()
    local lp2=game.Players.LocalPlayer
    local newOpts={}
    for _,p in ipairs(game.Players:GetPlayers()) do
        if p.Name~=lp2.Name then table.insert(newOpts,p.Name) end
    end
    pvpDropdownRef:Refresh(newOpts, newOpts[1] or "")
    selectedPvpPlayer=newOpts[1] or nil; pvpTarget=nil
    Win:Notify("Refreshed!", #newOpts.." players found", 2)
end)
PvpSec:AddToggle("Auto PvP", false, function(v)
    local hrp=getHrp()
    if v then if hrp then savedPosPvp=hrp.Position end
    else
        if hrp and savedPosPvp then hrp.Position=savedPosPvp end
        savedPosPvp=nil; pvpTarget=nil; _cachedHrpAddr=nil
    end
    _G.AutoPvp_Enabled=v
end)

local PvpConfigSec = RageTab:AddSection("Height Config")
PvpConfigSec:AddDropdown("Direction", {"Down","Up"}, "Down", {MaxVisible=2}, function(v)
    pvpHeightDirection=(v=="Up") and 1 or -1
    pvpHeightOffset=pvpHeightValue*pvpHeightDirection
end)
PvpConfigSec:AddSlider("Height Offset", {Min=0,Max=15,Default=10,Suffix=""}, function(v)
    pvpHeightValue=v; pvpHeightOffset=pvpHeightValue*pvpHeightDirection
end)
PvpConfigSec:AddSlider("X Offset", {Min=0,Max=15,Default=5,Suffix=""}, function(v) pvpXOffset=v end)

local UserIdSec    = RageTab:AddSection("User ID")
local spoofedUserId = nil
task.spawn(function()
    while true do
        task.wait()
        if spoofedUserId then
            pcall(function()
                local label=game.Players.LocalPlayer.PlayerGui.MainHud.topsection.second.userid
                label.Text=spoofedUserId
            end)
        end
    end
end)
UserIdSec:AddTextbox("Set User ID", "", function(v)
    spoofedUserId = (v=="") and nil or tostring(v)
end)
UserIdSec:AddButton("Reset", function()
    spoofedUserId=nil
    pcall(function()
        local label=game.Players.LocalPlayer.PlayerGui.MainHud.topsection.second.userid
        label.Text=tostring(game.Players.LocalPlayer.UserId)
    end)
end)

-- ── Positions ─────────────────────────────────────────────────────
local posCapturing = false
local DEFAULT_POS  = {
    play="1079,693", replay="1045,760", standSearch="748,331",
    standSlot="689,400", standUse="1384,586", standConfirm="883,570", meditate="752,934",
}
local pos_play, pos_replay, pos_standSearch = nil, nil, nil
local pos_standSlot, pos_standUse, pos_standConfirm, pos_meditate = nil, nil, nil, nil

local function parsePos(str)
    if type(str)~="string" or str=="" then return nil end
    local x,y=str:match("^(%d+)%s*,%s*(%d+)$")
    if x and y then return {x=tonumber(x),y=tonumber(y)} end
    return nil
end
pos_play=parsePos(DEFAULT_POS.play); pos_replay=parsePos(DEFAULT_POS.replay)
pos_standSearch=parsePos(DEFAULT_POS.standSearch); pos_standSlot=parsePos(DEFAULT_POS.standSlot)
pos_standUse=parsePos(DEFAULT_POS.standUse); pos_standConfirm=parsePos(DEFAULT_POS.standConfirm)
pos_meditate=parsePos(DEFAULT_POS.meditate)

local function capturePosition(label, tbRef)
    if posCapturing then Win:Notify("Please wait","A capture is already in progress",2); return end
    posCapturing=true; Win:Notify("Move mouse & press 1","Capturing: "..label,5)
    task.spawn(function()
        while iskeypressed(0x31) do task.wait() end
        while not iskeypressed(0x31) do task.wait() end
        local mouse=game.Players.LocalPlayer:GetMouse()
        local x,y=math.floor(mouse.X),math.floor(mouse.Y)
        local str=x..","..y; tbRef:Set(str)
        posCapturing=false; Win:Notify("Changed!",label..": "..str,3)
    end)
end

local PosTab = Win:AddTab("Positions")

local PosPlaySec = PosTab:AddSection("Auto Play")
local posPlayTb  = PosPlaySec:AddTextbox("Quick Play", DEFAULT_POS.play, function(v) pos_play=parsePos(v) end)
PosPlaySec:AddButton("Change", function() capturePosition("Quick Play", posPlayTb) end)
PosPlaySec:AddButton("Reset",  function() posPlayTb:Set(DEFAULT_POS.play) end)

local PosReplaySec = PosTab:AddSection("Auto Replay")
local posReplayTb  = PosReplaySec:AddTextbox("Retry Button", DEFAULT_POS.replay, function(v) pos_replay=parsePos(v) end)
PosReplaySec:AddButton("Change", function() capturePosition("Retry Button", posReplayTb) end)
PosReplaySec:AddButton("Reset",  function() posReplayTb:Set(DEFAULT_POS.replay) end)

local PosStandSec  = PosTab:AddSection("Stand Roll")
local posSearchTb  = PosStandSec:AddTextbox("Stand Search",  DEFAULT_POS.standSearch,  function(v) pos_standSearch=parsePos(v)  end)
local posSlotTb    = PosStandSec:AddTextbox("Stand Slot",    DEFAULT_POS.standSlot,    function(v) pos_standSlot=parsePos(v)    end)
local posUseTb     = PosStandSec:AddTextbox("Stand Use",     DEFAULT_POS.standUse,     function(v) pos_standUse=parsePos(v)     end)
local posConfirmTb = PosStandSec:AddTextbox("Stand Confirm", DEFAULT_POS.standConfirm, function(v) pos_standConfirm=parsePos(v) end)
PosStandSec:AddButton("Change Search",  function() capturePosition("Stand Search",  posSearchTb)  end)
PosStandSec:AddButton("Change Slot",    function() capturePosition("Stand Slot",    posSlotTb)    end)
PosStandSec:AddButton("Change Use",     function() capturePosition("Stand Use",     posUseTb)     end)
PosStandSec:AddButton("Change Confirm", function() capturePosition("Stand Confirm", posConfirmTb) end)
PosStandSec:AddButton("Reset All", function()
    posSearchTb:Set(DEFAULT_POS.standSearch); posSlotTb:Set(DEFAULT_POS.standSlot)
    posUseTb:Set(DEFAULT_POS.standUse); posConfirmTb:Set(DEFAULT_POS.standConfirm)
    Win:Notify("Reset","Stand Roll back to default",2)
end)

local PosMeditateSec = PosTab:AddSection("Auto Meditate")
local posMeditateTb  = PosMeditateSec:AddTextbox("Dialogue Button", DEFAULT_POS.meditate, function(v) pos_meditate=parsePos(v) end)
PosMeditateSec:AddButton("Change", function() capturePosition("Meditate Dialogue", posMeditateTb) end)
PosMeditateSec:AddButton("Reset",  function() pos_meditate=nil; posMeditateTb:Set("") end)

-- ── Stand ─────────────────────────────────────────────────────────
local StandTab     = Win:AddTab("Stand")
local HttpService  = game:GetService("HttpService")

local function getStandData()
    local pd=game.Players.LocalPlayer:FindFirstChild("PlayerData"); if not pd then return nil end
    local sd=pd:FindFirstChild("SlotData"); if not sd then return nil end
    local standVal=sd:FindFirstChild("Stand")
    if standVal and standVal:IsA("StringValue") then
        local str=standVal.Value
        if str and str~="" and str~="None" then
            local ok,decoded=pcall(function() return HttpService:JSONDecode(str) end)
            if ok and type(decoded)=="table" then return decoded end
        end
    end
    return nil
end

local grades = {[1]="D",[2]="C",[3]="B",[4]="A",[5]="S"}
local function getGrade(val) return grades[tonumber(val)] or tostring(val or 0) end

local StandInfoSec = StandTab:AddSection("Stand Info")
local standLabel1  = StandInfoSec:AddLabel("Stand: ---")
local standLabel2  = StandInfoSec:AddLabel("Trait: ---")
local standLabel3  = StandInfoSec:AddLabel("Speed: ---")
local standLabel4  = StandInfoSec:AddLabel("Spec: ---")
local standLabel5  = StandInfoSec:AddLabel("Str: ---")
local standLabel6  = StandInfoSec:AddLabel("Skin: ---")

local function updateStandLabels()
    local sd=getStandData()
    if sd and sd.Name then
        standLabel1:Set("Stand: "..tostring(sd.Name))
        standLabel2:Set("Trait: "..tostring(sd.Trait or "None"))
        standLabel3:Set("Speed: "..getGrade(sd.Speed))
        standLabel4:Set("Spec: " ..getGrade(sd.Specialty))
        standLabel5:Set("Str: "  ..getGrade(sd.Strength))
        standLabel6:Set("Skin: " ..tostring(sd.Skin or "None"))
    else
        standLabel1:Set("Stand: None"); standLabel2:Set("Trait: None")
        standLabel3:Set("Speed: -");    standLabel4:Set("Spec: -")
        standLabel5:Set("Str: -");      standLabel6:Set("Skin: None")
    end
end
StandInfoSec:AddButton("Refresh Info", function() updateStandLabels() end)
task.spawn(function() task.wait(3); updateStandLabels() end)

local StandRollSec       = StandTab:AddSection("Auto Roll")
local StandList = {
    "Anubis","Crazy Diamond","Golden Experience","King Crimson","Killer Queen",
    "Magician's Red","Purple Haze","Red Hot Chili Pepper","Star Platinum",
    "Stone Free","The Hand","The World","The World High Voltage","Weather Report","Whitesnake",
}
table.sort(StandList)

local targetStands        = {}
local stopOnAnySkin       = false
local standRollThread     = nil
local autoStandRollActive = false

StandRollSec:AddMultiDropdown("Target Stands", StandList, {}, {MaxVisible=6}, function(tbl)
    targetStands={}; for _,name in ipairs(tbl) do targetStands[name]=true end
end)
StandRollSec:AddToggle("Stop on Any Skin", false, function(v) stopOnAnySkin=v end)

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

-- ════════════════════════════════════════════════════════════════
--  9. SCRIPT LOGIC — LOOPS
-- ════════════════════════════════════════════════════════════════

-- ── ESP visual config ────────────────────────────────────────────

-- SCAN: cria ESP via MatchaLib para novos itens
task.spawn(function()
    while true do
        if _G.ESP_Enabled then
            for _, model in ipairs(workspace:GetChildren()) do
                if model.Name == "Model" then
                    for _, obj in ipairs(model:GetChildren()) do
                        if targetNames[obj.Name] and not activeESP[obj] then
                            activeESP[obj] = MatchaLib.ESP.Create(obj, {
                                box      = _espCFG.box,
                                name     = _espCFG.name,
                                distance = _espCFG.distance,
                                line     = _espCFG.traceline,
                                color    = targetNames[obj.Name],
                            })
                        end
                    end
                end
            end
            task.wait(5)
        else task.wait(1) end
    end
end)

-- RENDER: usa MatchaLib.ESP.Update por item
task.spawn(function()
    while true do
        task.wait(_espCFG.renderWait)
        if not _G.ESP_Enabled then
            for _, esp in pairs(activeESP) do MatchaLib.ESP.Hide(esp) end
            continue
        end
        local myPos = getHrp() and getHrp().Position
        if not myPos then continue end
        for item, esp in pairs(activeESP) do
            if not item or not item.Parent then
                MatchaLib.ESP.Destroy(esp); activeESP[item] = nil; continue
            end
            -- sincroniza cfg com toggles
            esp.cfg.box      = _espCFG.box
            esp.cfg.name     = _espCFG.name
            esp.cfg.distance = _espCFG.distance
            esp.cfg.line     = _espCFG.traceline
            MatchaLib.ESP.Update(esp, myPos)
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

        -- trava no target atual enquanto ele ainda estiver vivo
        if currentMobTarget and currentMobTarget.Parent then
            local hum = currentMobTarget.Parent:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then continue end
            currentMobTarget = nil; _cachedHrpAddr = nil
        end

        currentMobTarget = nil
        local nearest = nil; local minDistSq = math.huge
        local playerSet = {}
        for _, p in ipairs(game.Players:GetPlayers()) do playerSet[p.Name] = true end

        for _, obj in ipairs(game.Workspace.Live:GetChildren()) do
            if obj:IsA("Model") and obj.Name ~= "Server" and not playerSet[obj.Name] then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then continue end
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
        if not savedPosRaid then continue end

        -- trava no target atual enquanto ele ainda estiver vivo
        if currentRaidTarget and currentRaidTarget.Parent then
            local hum = currentRaidTarget.Parent:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then continue end
            currentRaidTarget = nil; _cachedHrpAddr = nil; voidMotionOrigin = nil
        end

        local nearest = nil; local minDistSq = math.huge

        for _, obj in ipairs(game.Workspace.Live:GetChildren()) do
            if obj:IsA("Model") and obj.Name ~= "Server" then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then continue end
                if game.Players:FindFirstChild(obj.Name) then continue end
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
                -- NPC normal: trava aqui até morrer
                currentRaidTarget = nearest
                voidMotionOrigin  = nil
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

    -- 2. Carrega APENAS Positions
    loadConfigPartial({"Positions"})

    -- 3. Aguarda estado definido — timeout de 10s assume ingame
    local state = getGuiState()
    local t0 = os.clock()
    while state == "loading" do
        task.wait(0.5)
        state = getGuiState()
        if os.clock() - t0 > 10 then state = "ingame"; break end
    end

    if state == "ingame" then
        task.wait(4)  -- tempo para GalaxLib inicializar
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

        -- Aguarda transição — timeout de 15s
        local t1 = os.clock()
        while getGuiState() == "loading" do
            task.wait(0.5)
            if os.clock() - t1 > 15 then break end
        end

        task.wait(4)
        Win:LoadConfig(true, false)
        _G.SafeMode = false
        Win:Notify("Config loaded!", "Bizarre Hub", 3)
    end

    -- 4. Watchdog
    while true do
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
            task.wait(4)
            Win:LoadConfig(true, false)
            _G.SafeMode = false
            Win:Notify("Config loaded!", "Bizarre Hub", 3)
        elseif s == "loading" then
            _G.SafeMode = true
        end
    end
end)

Win:Notify("Bizarre Hub", "Whymayko", 3)
