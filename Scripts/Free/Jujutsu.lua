-- ════════════════════════════════════════════════════════════════
--  Jujutsu Hub (Somente Animações)
--  UI: GalaxLib
-- ════════════════════════════════════════════════════════════════

loadstring(game:HttpGet("https://raw.githubusercontent.com/minudoindo-dotcom/Galax/refs/heads/main/Lib/Beta/Galax.lua"))()

local Win = GalaxLib:CreateWindow({
    Title   = "Jujutsu Hub",
    Size    = Vector2.new(500, 520),
    MenuKey = 0x70,
})

local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local workspace   = game:GetService("Workspace")

local KEYS = { W = 0x57, A = 0x41, S = 0x53, D = 0x44, F = 0x46, R = 0x52, G = 0x47, THREE = 0x33 }
local VALID_QTE_KEYS     = { ["W"] = KEYS.W, ["A"] = KEYS.A, ["S"] = KEYS.S, ["D"] = KEYS.D }
local PERFECT_SWAP_MOVES = { "Swift Kick", "Brute Force", "Pebble Throw", "Elbow Drop" }
local ULT_SWAP_MOVES     = { "Idol's Debut", "Climax Jumping", "Dreams", "Brothers" }

local CONFIG = {
    autoQTE      = { enabled = false, postPressDelay = 0.30, deviation = 0 },
    ratioQTE     = { enabled = false, baseDelay = 0.60, minDelay = 0.40, healthFloor = 0.60 },
    charaQTE     = { enabled = false },
    perfectSwap  = { enabled = false, scanTimeout = 2.0 },
    esp          = { enabled = false, dummy = true, items = true,
                     colorDummy = {255, 100, 100}, colorItems = {100, 255, 100}, updateRate = 60 },
    domainVotes     = { enabled = false },
    domainHealthESP = { enabled = false, nearbyThreshold = 40 },
}

local QTEState      = { detectedKey = "", detectedTime = 0, displayDuration = 1.0 }
local RatioState    = { rWasPressed = false, isScanning = false, scanStartTime = 0,
                        trackedTarget = nil, trackedRatioValue = nil, qteDetectedTime = 0,
                        hasTriggered = false, targetHealthPercent = 1.0, calculatedDelay = 0.60,
                        lastTriggerTime = 0, triggerCooldown = 0.3 }
local CharaQTEState = { active = false }
local SwapState     = { rWasPressed = false, isScanning = false, scanStartTime = 0,
                        swapConfirmed = false, effectsSnapshot = {}, hasTriggeredM1 = false }
local ESPState      = { objects = {}, lastDiscovery = 0 }
local DomainState   = { isActive = false, trackedDomain = nil, gWasPressed = false,
                        waitingForChooseUI = false, waitStartTime = 0,
                        confessCount = 0, silenceCount = 0, denialCount = 0,
                        confessDrawing = nil, silenceDrawing = nil, denialDrawing = nil }
local DomainHealthESPState = { drawings = {} }

local currentPing   = 0
local running       = true

local lastAwakeningNotif      = 0
local notifCooldown           = 3
local charlesEquippedNotified = false
local headOfHeiEquippedNotified = false
local luckyCowardEquippedNotified = false
local charlesOnCooldown       = false
local headOfHeiEquipped       = false
local charlesEquipped         = false
local luckyCowardEquipped     = false
local charlesCooldownAddr     = nil
local charlesLastState        = false

-- ════════════════════════════════════════════════════════════════
--  OFFSETS  (Somente Animação e Interface)
-- ════════════════════════════════════════════════════════════════

local VISIBLE_OFFSET = 1461
local VALUE_OFFSET   = 208

local INST = {
    ClassDescriptor = 24,
    ClassName       = 8,
    Name            = 176,
}

local ANIM = {
    ActiveAnimations = 2152,
    Animation        = 208,
    AnimationId      = 208,
    NodeNext         = 16,
}

local HUM = {
    Health    = 404,
    MaxHealth = 436,
}

local CAM = {
    ViewportSize = 744,
}

-- ════════════════════════════════════════════════════════════════
--  ANIMATION ID TABLES (Atualizado para Melee1 apenas no Block)
-- ════════════════════════════════════════════════════════════════

local BlockMode = {
    ["127851700400958"] = true, ["95295463826732"]  = true, ["110146909061402"] = true, 
    ["96185406489877"]  = true, ["94588892125071"]  = true, ["75337033003776"]  = true, 
    ["109718372214725"] = true, ["126277739156443"] = true, ["71784337627181"]  = true, 
    ["98365018553171"]  = true, ["79568627671998"]  = true, ["96327114254575"]  = true, 
    ["85068785050521"]  = true, ["133936641185614"] = true, ["139280948741186"] = true, 
    ["106474043944206"] = true, ["104087365067491"] = true, ["123236749567737"] = true, 
    ["133240987753043"] = true, ["125689391910002"] = true, ["98783064085844"]  = true, 
    ["80504019426174"]  = true, ["101283990868172"] = true, ["77284264481284"]  = true, 
    ["84359513001979"]  = true, ["114913455544468"] = true, ["133447840605824"] = true, 
    ["114985590391235"] = true, ["111083699259354"] = true, ["75425383606016"]  = true, 
    ["115220151812065"] = true,
}

local DashMode = {
    ["102567076867813"]=true,["102698645310820"]=true,["134451575263988"]=true,
    ["70593304937741"]=true,["103513893010999"]=true,["140381676724931"]=true,
    ["111214152450580"]=true,["85003123457049"]=true,["136807071694451"]=true,
    ["99026585086806"]=true,["97396408415659"]=true,["97803359940506"]=true,
    ["127453446770583"]=true,["115543520504167"]=true,["110978068388232"]=true,
    ["130284226842903"]=true,["132855702748568"]=true,["134917827147266"]=true,
    ["140597320237985"]=true,["81708642912019"]=true,["99451940496871"]=true,
    ["130135202362252"]=true,["104148378077935"]=true,["124777463468279"]=true,
    ["86626502434817"]=true,["128267680345523"]=true,["129392532939530"]=true,
    ["120951759618134"]=true,["138169151223960"]=true,
}

local SkillBlockMode = {
    ["137865634124104"]=true,["137654778575373"]=true,["77200218033775"]=true,
    ["124901309160375"]=true,["82541714192027"]=true,["72063002791216"]=true,
    ["72467492674240"]=true,["108123475959041"]=true,["132653290201368"]=true,
    ["116432619539029"]=true,["89092734635186"]=true,["72475960800126"]=true,
    ["127171275866632"]=true,["100446064103831"]=true,["84039122607068"]=true,
    ["94720627091769"]=true,["111720035828971"]=true,["89652378115594"]=true,
    ["133869529005453"]=true,["135411487367370"]=true,["104824728032437"]=true,
    ["89582140026963"]=true,["88911658010897"]=true,["120136894011461"]=true,
    ["93901924492394"]=true,["105121164520635"]=true,["86045680364061"]=true,
    ["81210313723714"]=true,["130957217409359"]=true,["100811576955331"]=true,
    ["113359849246757"]=true,["139479927693015"]=true,["129678103897608"]=true,
    ["121550561336691"]=true,["115097960689033"]=true,["94347210073500"]=true,
    ["103013818601982"]=true,["79860101129549"]=true,["102053631728986"]=true,
    ["76957377224584"]=true,
}

-- ════════════════════════════════════════════════════════════════
--  COMBAT CONSTANTS
-- ════════════════════════════════════════════════════════════════

local KEY_F           = 0x46
local KEY_3           = 0x33
local KEY_G           = 0x47
local BLOCK_RANGE     = 8
local DASH_RANGE      = 15
local SKILL_RANGE     = 15
local BLOCK_HOLD_TIME = 0.25

_G.AutoBlock_Enabled        = false
_G.AutoBlockDash_Enabled    = false
_G.AutoSkillBlock_Enabled   = false
_G.AutoCounter_Enabled      = false
_G.AwakeningCounter_Enabled = false

-- ════════════════════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════════════════════

local function GetTime() return os.clock() end

local function SafeFind(parent, ...)
    if not parent then return nil end
    for _, name in ipairs({...}) do
        parent = parent:FindFirstChild(name)
        if not parent then return nil end
    end
    return parent
end

local function GetWorkspaceCharacter()
    local characters = workspace:FindFirstChild("Characters")
    return characters and characters:FindFirstChild(LocalPlayer.Name)
end

local function GetPlayerPosition()
    local char = GetWorkspaceCharacter()
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.Position
end

local function CalculateDistance(pos1, pos2)
    if not pos1 or not pos2 then return 0 end
    local dx, dy, dz = pos2.X - pos1.X, pos2.Y - pos1.Y, pos2.Z - pos1.Z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function getMagnitude(a, b)
    local diff = a - b
    return math.sqrt(diff.X^2 + diff.Y^2 + diff.Z^2)
end

local function GetMovesetAttr()
    local char = GetWorkspaceCharacter()
    return char and char:GetAttribute("Moveset")
end

local function HasMoveset(name) return GetMovesetAttr() == name end

local function HasMovesetMoves(moves)
    local char = GetWorkspaceCharacter()
    if not char then return false end
    local moveset = char:FindFirstChild("Moveset")
    if not moveset then return false end
    for _, move in ipairs(moves) do
        if moveset:FindFirstChild(move) then return true end
    end
    return false
end

local function GetPing()
    local ok, v = pcall(function()
        return game:GetService("Stats"):FindFirstChild("Network"):FindFirstChild("ServerStatsItem"):FindFirstChild("Data Ping").Value
    end)
    return (ok and tonumber(v)) or 0
end

local function isLocalPlayer(p)
    if p == LocalPlayer then return true end
    if p.UserId and LocalPlayer and p.UserId == LocalPlayer.UserId then return true end
    if p.Name and LocalPlayer and p.Name == LocalPlayer.Name then return true end
    if p.DisplayName and LocalPlayer and p.DisplayName == LocalPlayer.DisplayName then return true end
    return false
end

-- ════════════════════════════════════════════════════════════════
--  MEMORY HELPERS (ANIMATION ONLY)
-- ════════════════════════════════════════════════════════════════

local function readStr(addr)
    if not addr or addr <= 4096 then return nil end
    local ok, v = pcall(memory_read, "string", addr)
    return ok and v or nil
end

local function readPtr(addr)
    if not addr or addr <= 4096 then return nil end
    local ok, v = pcall(memory_read, "uintptr_t", addr)
    return (ok and v and v > 4096) and v or nil
end

local function getClass(addr)
    if not addr or addr <= 4096 then return nil end
    local desc = readPtr(addr + INST.ClassDescriptor)
    if not desc then return nil end
    local namePtr = readPtr(desc + INST.ClassName)
    return namePtr and readStr(namePtr) or nil
end

local function getAnimator(char)
    if not char or char.Address == 0 then return nil end
    local hum  = char:FindFirstChild("Humanoid")
    if not hum then return nil end
    local anim = hum:FindFirstChild("Animator")
    return anim and tonumber(anim.Address) or nil
end

local function checkAnim(track, mode)
    local anim = readPtr(track + ANIM.Animation)
    if not anim or getClass(anim) ~= "Animation" then return nil end
    local idPtr = readPtr(anim + ANIM.AnimationId)
    local idStr = readStr(idPtr)
    if not idStr or idStr == "N/A" then return nil end
    for id in pairs(mode) do
        if string.find(idStr, id, 1, true) then return id end
    end
    return nil
end

local function getCurrentAnimFromChar(char, mode)
    local animator = getAnimator(char)
    if not animator then return nil end
    local head = readPtr(animator + ANIM.ActiveAnimations)
    if not head then return nil end
    local first = readPtr(head)
    if not first or first == head then return nil end
    local curr = first
    local maxIter, iter = 64, 0
    while curr and curr ~= 0 and curr ~= head and iter < maxIter do
        iter = iter + 1
        local track = readPtr(curr + ANIM.NodeNext)
        if track and getClass(track) == "AnimationTrack" then
            local id = checkAnim(track, mode)
            if id then return id end
        end
        curr = readPtr(curr)
    end
    return nil
end

-- ════════════════════════════════════════════════════════════════
--  QTE / AUTOMATION
-- ════════════════════════════════════════════════════════════════

local function GetQTELabel() return SafeFind(LocalPlayer, "PlayerGui", "QTE", "QTE_PC") end

local function ProcessQTE()
    if not CONFIG.autoQTE.enabled or iskeypressed(KEYS.F) then return false end
    local label = GetQTELabel()
    if not label or not label.Text or label.Text == "" then return false end
    local keyCode = VALID_QTE_KEYS[label.Text:upper()]
    if not keyCode then return false end
    QTEState.detectedKey  = label.Text:upper()
    QTEState.detectedTime = GetTime()
    keypress(keyCode); keyrelease(keyCode)
    return true
end

local function HasSalarymanMoveset() return HasMoveset("Salaryman") or HasMoveset("Nanami") end

local function FindOurRatioQTE()
    local characters = workspace:FindFirstChild("Characters")
    if not characters then return nil, nil end
    for _, character in ipairs(characters:GetChildren()) do
        local ratio = SafeFind(character, "Info", "Ratio")
        if ratio then
            local owner = ratio:FindFirstChild("Owner")
            if owner and owner.Value then
                local ok, ownerName = pcall(function() return owner.Value.Name end)
                if ok and ownerName == LocalPlayer.Name then return character, ratio end
            end
        end
    end
    return nil, nil
end

local function GetTargetHealthPercent(target)
    if not target then return 1.0 end
    local humanoid = target:FindFirstChild("Humanoid")
    if humanoid then
        local addr = tonumber(humanoid.Address)
        if addr and addr > 4096 then
            local okH, health    = pcall(memory_read, "float", addr + HUM.Health)
            local okM, maxHealth = pcall(memory_read, "float", addr + HUM.MaxHealth)
            if okH and okM and maxHealth and maxHealth > 0 then
                return math.clamp(health / maxHealth, 0, 1)
            end
        end
        if humanoid.MaxHealth and humanoid.MaxHealth > 0 then
            return humanoid.Health / humanoid.MaxHealth
        end
    end
    return 1.0
end

local function CalculatePressDelay(healthPercent)
    local cfg        = CONFIG.ratioQTE
    local effective  = math.max(healthPercent, cfg.healthFloor)
    local normalized = math.clamp((effective - cfg.healthFloor) / (1.0 - cfg.healthFloor), 0, 1)
    return cfg.minDelay + (cfg.baseDelay - cfg.minDelay) * normalized
end

local function ProcessRatioQTE()
    if not CONFIG.ratioQTE.enabled or not HasSalarymanMoveset() then return end
    local currentTime = GetTime()
    local rPressed    = iskeypressed(KEYS.R)
    if rPressed and not RatioState.rWasPressed then
        RatioState.isScanning        = true
        RatioState.scanStartTime     = currentTime
        RatioState.trackedTarget     = nil
        RatioState.trackedRatioValue = nil
        RatioState.hasTriggered      = false
    end
    RatioState.rWasPressed = rPressed
    if not RatioState.isScanning and not RatioState.trackedRatioValue then return end
    if RatioState.isScanning then
        if currentTime - RatioState.scanStartTime > 2.0 then RatioState.isScanning = false return end
        local target, ratioValue = FindOurRatioQTE()
        if target and ratioValue then
            RatioState.isScanning          = false
            RatioState.trackedTarget       = target
            RatioState.trackedRatioValue   = ratioValue
            RatioState.qteDetectedTime     = currentTime
            RatioState.hasTriggered        = false
            RatioState.targetHealthPercent = GetTargetHealthPercent(target)
            RatioState.calculatedDelay     = CalculatePressDelay(RatioState.targetHealthPercent)
        end
        return
    end
    if RatioState.trackedRatioValue then
        if not RatioState.trackedRatioValue.Parent or RatioState.trackedRatioValue:GetAttribute("Activated") == false then
            RatioState.trackedTarget     = nil
            RatioState.trackedRatioValue = nil
            RatioState.hasTriggered      = false
            return
        end
        if RatioState.hasTriggered or currentTime - RatioState.lastTriggerTime < RatioState.triggerCooldown then return end
        if currentTime - RatioState.qteDetectedTime >= RatioState.calculatedDelay then
            keypress(KEYS.R); keyrelease(KEYS.R)
            RatioState.hasTriggered    = true
            RatioState.lastTriggerTime = currentTime
        end
    end
end

local function HasPerfectSwapMoveset()
    local attr = GetMovesetAttr()
    if attr == "Switcher" or attr == "Todo" then return true end
    return HasMovesetMoves(PERFECT_SWAP_MOVES) or HasMovesetMoves(ULT_SWAP_MOVES)
end

local function HasClapTarget()
    local info = SafeFind(GetWorkspaceCharacter(), "Info")
    return info and info:FindFirstChild("ClapTarget") ~= nil
end

local function HasNoM1Flag()
    local char = GetWorkspaceCharacter()
    return char and char:FindFirstChild("NoM1") ~= nil
end

local function ResetSwapState()
    SwapState.isScanning      = false
    SwapState.swapConfirmed   = false
    SwapState.effectsSnapshot = {}
    SwapState.hasTriggeredM1  = false
end

local function ProcessPerfectSwap()
    if not CONFIG.perfectSwap.enabled or not HasPerfectSwapMoveset() then return end
    local currentTime = GetTime()
    local rPressed    = iskeypressed(KEYS.R)
    if rPressed and not SwapState.rWasPressed then
        SwapState.isScanning      = true
        SwapState.scanStartTime   = currentTime
        SwapState.swapConfirmed   = false
        SwapState.hasTriggeredM1  = false
        SwapState.effectsSnapshot = {}
    end
    SwapState.rWasPressed = rPressed
    if not SwapState.isScanning then return end
    if currentTime - SwapState.scanStartTime > CONFIG.perfectSwap.scanTimeout then ResetSwapState() return end
    if not SwapState.swapConfirmed then
        if HasClapTarget() then
            SwapState.swapConfirmed = true
            local ef = workspace:FindFirstChild("Effects")
            if ef then
                for _, desc in ipairs(ef:GetDescendants()) do
                    SwapState.effectsSnapshot[desc.Address] = true
                end
            end
        end
        return
    end
    local ef = workspace:FindFirstChild("Effects")
    if ef then
        for _, desc in ipairs(ef:GetDescendants()) do
            if not SwapState.effectsSnapshot[desc.Address] then
                if desc.ClassName == "MeshPart" and desc.Name == "Clap" then
                    if not SwapState.hasTriggeredM1 and not HasNoM1Flag() then
                        mouse1press(); mouse1release()
                        SwapState.hasTriggeredM1 = true
                    end
                    ResetSwapState(); return
                end
                SwapState.effectsSnapshot[desc.Address] = true
            end
        end
    end
end

local function RunCharaQTE()
    if not CONFIG.charaQTE.enabled then CharaQTEState.active = false return end
    local uiComponent = SafeFind(LocalPlayer, "PlayerGui", "UI")
    if not uiComponent then CharaQTEState.active = false return end
    local bar  = uiComponent:FindFirstChild("Bar")
    if not bar then return end
    local line = bar:FindFirstChild("Line")
    if not line then return end
    CharaQTEState.active = true
    local barX    = bar.AbsolutePosition.X
    local barW    = bar.AbsoluteSize.X
    local centerX = barX + barW / 2
    local prevDist = math.huge
    while uiComponent.Parent and bar.Parent and line.Parent do
        local lineCenterX = line.AbsolutePosition.X + line.AbsoluteSize.X / 2
        local dist = math.abs(lineCenterX - centerX)
        if dist > prevDist then mouse1click() break end
        prevDist = dist
        task.wait()
    end
    CharaQTEState.active = false
end

-- ════════════════════════════════════════════════════════════════
--  ESP
-- ════════════════════════════════════════════════════════════════

local function CreateESPDrawing(name, color)
    local drawing        = Drawing.new("Text")
    drawing.Font         = Drawing.Fonts.System
    drawing.Text         = name
    drawing.Color        = Color3.fromRGB(color[1], color[2], color[3])
    drawing.Outline      = true
    drawing.Center       = true
    drawing.Visible      = false
    return drawing
end

local function RemoveESPDrawing(espObj)
    if espObj and espObj.drawing then espObj.drawing:Remove() end
end

local function ClearAllESP()
    for _, espObj in pairs(ESPState.objects) do RemoveESPDrawing(espObj) end
    ESPState.objects = {}
end

local function UpdateESPPositions()
    if not CONFIG.esp.enabled then
        for _, espObj in pairs(ESPState.objects) do
            if espObj.drawing then espObj.drawing.Visible = false end
        end
        return
    end
    for _, espObj in pairs(ESPState.objects) do
        if espObj.drawing then
            local isEnabled = (espObj.type == "dummy" and CONFIG.esp.dummy)
                           or (espObj.type == "item"  and CONFIG.esp.items)
            if not isEnabled then
                espObj.drawing.Visible = false
            elseif espObj.part and espObj.part.Parent then
                local screenPos, onScreen = WorldToScreen(espObj.part.Position)
                espObj.drawing.Visible = onScreen
                if onScreen then
                    espObj.drawing.Position = screenPos
                    local color = espObj.type == "dummy" and CONFIG.esp.colorDummy or CONFIG.esp.colorItems
                    espObj.drawing.Color = Color3.fromRGB(color[1], color[2], color[3])
                end
            else
                espObj.drawing.Visible = false
            end
        end
    end
end

local function DiscoverDummy()
    local dummyKey = "dummy_character"
    if ESPState.objects[dummyKey] then
        local espObj = ESPState.objects[dummyKey]
        if not espObj.part or not espObj.part.Parent then
            RemoveESPDrawing(espObj); ESPState.objects[dummyKey] = nil
        else return end
    end
    local dummy = SafeFind(workspace, "Characters", "Dummy")
    if not dummy then return end
    local hrp = dummy:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    ESPState.objects[dummyKey] = {
        drawing  = CreateESPDrawing("Dummy", CONFIG.esp.colorDummy),
        instance = dummy, part = hrp, type = "dummy"
    }
end

local function DiscoverItems()
    local itemsFolder = SafeFind(workspace, "Items")
    if not itemsFolder then return end
    local seenAddresses = {}
    for _, item in ipairs(itemsFolder:GetChildren()) do
        if item:IsA("Part") or item:IsA("MeshPart") then
            local address = item.Address
            seenAddresses[address] = true
            if not ESPState.objects[address] then
                ESPState.objects[address] = {
                    drawing  = CreateESPDrawing(item.Name, CONFIG.esp.colorItems),
                    instance = item, part = item, type = "item"
                }
            end
        end
    end
    for address, espObj in pairs(ESPState.objects) do
        if espObj.type == "item" and not seenAddresses[address] then
            RemoveESPDrawing(espObj); ESPState.objects[address] = nil
        end
    end
end

local function DiscoverESPObjects() pcall(DiscoverDummy) pcall(DiscoverItems) end

-- ════════════════════════════════════════════════════════════════
--  DOMAIN HEALTH ESP
-- ════════════════════════════════════════════════════════════════

local function CreateDomainHealthDrawing()
    local d = Drawing.new("Text")
    d.Font    = Drawing.Fonts.System
    d.Size    = 16
    d.Color   = Color3.fromRGB(255, 255, 255)
    d.Outline = true
    d.Center  = true
    d.Visible = false
    return d
end

local function UpdateDomainHealthESP()
    if not CONFIG.domainHealthESP.enabled then
        for _, entry in pairs(DomainHealthESPState.drawings) do
            if entry.drawing then entry.drawing.Visible = false end
        end
        return
    end
    local domainsFolder = workspace:FindFirstChild("Domains")
    local playerPos     = GetPlayerPosition()
    local nearbyThresh  = CONFIG.domainHealthESP.nearbyThreshold

    local screenCenterX = 960
    local cam = workspace.CurrentCamera
    if cam then
        local camAddr = tonumber(cam.Address)
        if camAddr and camAddr > 4096 then
            local okX, vx = pcall(memory_read, "float", camAddr + CAM.ViewportSize)
            if okX and vx and vx > 0 then screenCenterX = vx / 2 end
        elseif cam.ViewportSize then
            screenCenterX = cam.ViewportSize.X / 2
        end
    end

    local seenAddresses = {}
    if domainsFolder then
        for _, domain in ipairs(domainsFolder:GetChildren()) do
            local domainMesh = (domain.Name == "Domain" and domain:IsA("MeshPart")) and domain
                            or domain:FindFirstChild("Domain")
            if domainMesh then
                local addr  = domainMesh.Address
                seenAddresses[addr] = true
                local entry = DomainHealthESPState.drawings[addr]
                if not entry then
                    entry = { drawing = CreateDomainHealthDrawing() }
                    DomainHealthESPState.drawings[addr] = entry
                end
                local health = domainMesh:GetAttribute("Health") or domainMesh:GetAttribute("DomainHealth") or 0
                entry.drawing.Text = "Domain HP: " .. math.floor(health)
                local dist = playerPos and CalculateDistance(playerPos, domainMesh.Position) or math.huge
                if dist <= nearbyThresh then
                    entry.drawing.Position = Vector2.new(screenCenterX, 50)
                    entry.drawing.Visible  = true
                else
                    local screenPos, onScreen = WorldToScreen(domainMesh.Position)
                    entry.drawing.Visible = onScreen
                    if onScreen then entry.drawing.Position = screenPos end
                end
            end
        end
    end
    for addr, entry in pairs(DomainHealthESPState.drawings) do
        if not seenAddresses[addr] then
            entry.drawing:Remove()
            DomainHealthESPState.drawings[addr] = nil
        end
    end
end

-- ════════════════════════════════════════════════════════════════
--  DOMAIN VOTES (Hiromi)
-- ════════════════════════════════════════════════════════════════

local function HasHiromiMoveset() return HasMoveset("Hiromi") end
local function HasChooseUI() return SafeFind(LocalPlayer, "PlayerGui", "Choose") ~= nil end

local function FindPlayerDomain()
    local domainsFolder = workspace:FindFirstChild("Domains")
    if not domainsFolder then return nil end
    local playerPos = GetPlayerPosition()
    if not playerPos then return nil end
    local closestDomain, closestDist = nil, math.huge
    for _, domain in ipairs(domainsFolder:GetChildren()) do
        local domainMesh = (domain.Name == "Domain" and domain:IsA("MeshPart")) and domain
                        or domain:FindFirstChild("Domain")
        if domainMesh then
            local checkPart = domainMesh:FindFirstChild("DomainCollider") or domainMesh
            if checkPart and checkPart:IsA("BasePart") then
                local dist = CalculateDistance(playerPos, checkPart.Position)
                if dist < closestDist then closestDist = dist closestDomain = domainMesh end
            end
        end
    end
    return closestDomain
end

local function GetDomainVotes(domain)
    if not domain then return 0, 0, 0 end
    return domain:GetAttribute("ConfessCount") or 0,
           domain:GetAttribute("SilenceCount") or 0,
           domain:GetAttribute("DenialCount")  or 0
end

local function CreateVoteDrawings()
    local function make()
        local d = Drawing.new("Text")
        d.Font = Drawing.Fonts.System; d.Text = "0"; d.Size = 24
        d.Color = Color3.fromRGB(255, 0, 0); d.Outline = true
        d.Center = true; d.Visible = false
        return d
    end
    DomainState.confessDrawing = DomainState.confessDrawing or make()
    DomainState.silenceDrawing = DomainState.silenceDrawing or make()
    DomainState.denialDrawing  = DomainState.denialDrawing  or make()
end

local function HideVoteDrawings()
    if DomainState.confessDrawing then DomainState.confessDrawing.Visible = false end
    if DomainState.silenceDrawing then DomainState.silenceDrawing.Visible = false end
    if DomainState.denialDrawing  then DomainState.denialDrawing.Visible  = false end
end

local function UpdateVoteDisplay(confess, silence, denial)
    if not DomainState.confessDrawing then return end
    local maxVote  = math.max(confess, silence, denial)
    local tieCount = (confess == maxVote and 1 or 0)
                   + (silence == maxVote and 1 or 0)
                   + (denial  == maxVote and 1 or 0)
    local red    = Color3.fromRGB(255, 50, 50)
    local green  = Color3.fromRGB(50, 255, 50)
    local yellow = Color3.fromRGB(255, 255, 50)
    local function getColor(count)
        if maxVote == 0 then return red end
        if count ~= maxVote then return red end
        return tieCount >= 2 and yellow or green
    end
    DomainState.confessDrawing.Text  = tostring(confess)
    DomainState.confessDrawing.Color = getColor(confess)
    DomainState.silenceDrawing.Text  = tostring(silence)
    DomainState.silenceDrawing.Color = getColor(silence)
    DomainState.denialDrawing.Text   = tostring(denial)
    DomainState.denialDrawing.Color  = getColor(denial)
end

local function GetChooseButtonPositions()
    local chooseUI = SafeFind(LocalPlayer, "PlayerGui", "Choose")
    if not chooseUI then return nil, nil, nil end
    local function getPos(name)
        local btn = chooseUI:FindFirstChild(name)
        if btn then
            local pos  = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            return Vector2.new(pos.X + size.X / 2, pos.Y - 30)
        end
        return nil
    end
    return getPos("Confess"), getPos("Silence"), getPos("Denial")
end

local function PositionVoteDrawings()
    if not DomainState.confessDrawing then return end
    local cPos, sPos, dPos = GetChooseButtonPositions()
    DomainState.confessDrawing.Visible = cPos ~= nil
    if cPos then DomainState.confessDrawing.Position = cPos end
    DomainState.silenceDrawing.Visible = sPos ~= nil
    if sPos then DomainState.silenceDrawing.Position = sPos end
    DomainState.denialDrawing.Visible  = dPos ~= nil
    if dPos then DomainState.denialDrawing.Position  = dPos end
end

local function ResetDomainState()
    DomainState.isActive           = false
    DomainState.trackedDomain      = nil
    DomainState.waitingForChooseUI = false
    DomainState.waitStartTime      = 0
    DomainState.confessCount       = 0
    DomainState.silenceCount       = 0
    DomainState.denialCount        = 0
    HideVoteDrawings()
end

local function ProcessDomainVotes()
    if not CONFIG.domainVotes.enabled then
        if DomainState.isActive then ResetDomainState() end
        return
    end
    if not HasHiromiMoveset() then
        if DomainState.isActive or DomainState.waitingForChooseUI then ResetDomainState() end
        return
    end
    local currentTime = GetTime()
    local gPressed    = iskeypressed(KEYS.G)
    if gPressed and not DomainState.gWasPressed and not DomainState.isActive and not DomainState.waitingForChooseUI then
        DomainState.waitingForChooseUI = true
        DomainState.waitStartTime      = currentTime
    end
    DomainState.gWasPressed = gPressed
    if DomainState.waitingForChooseUI then
        if currentTime - DomainState.waitStartTime > 6.0 then
            DomainState.waitingForChooseUI = false
            return
        end
        if HasChooseUI() then
            DomainState.waitingForChooseUI = false
            local domain = FindPlayerDomain()
            if domain then
                DomainState.isActive      = true
                DomainState.trackedDomain = domain
                CreateVoteDrawings()
                PositionVoteDrawings()
                UpdateVoteDisplay(0, 0, 0)
            end
        end
        return
    end
    if DomainState.isActive then
        if not HasChooseUI() or not DomainState.trackedDomain or not DomainState.trackedDomain.Parent then
            ResetDomainState()
            return
        end
        local confess, silence, denial = GetDomainVotes(DomainState.trackedDomain)
        if confess ~= DomainState.confessCount or silence ~= DomainState.silenceCount or denial ~= DomainState.denialCount then
            DomainState.confessCount = confess
            DomainState.silenceCount = silence
            DomainState.denialCount  = denial
            UpdateVoteDisplay(confess, silence, denial)
        end
        PositionVoteDrawings()
    end
end

-- ════════════════════════════════════════════════════════════════
--  COUNTER / AWAKENING HELPERS
-- ════════════════════════════════════════════════════════════════

local function isUltimateReady()
    local gui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return false end
    local readyFrame = SafeFind(gui, "Main", "Ultimate", "Bar", "Ready")
    if not readyFrame then return false end
    local addr = tonumber(readyFrame.Address)
    if not addr or addr <= 4096 then return false end
    local ok, byte = pcall(memory_read, "byte", addr + VISIBLE_OFFSET)
    return ok and byte ~= 0
end

local function checkForLuckyCoward()
    local gui     = LocalPlayer:FindFirstChild("PlayerGui")
    local moveset = gui and SafeFind(gui, "Main", "Moveset")
    return moveset and moveset:FindFirstChild("Dirty Play") ~= nil
end

local function checkEquippedAbilities()
    local gui     = LocalPlayer:FindFirstChild("PlayerGui")
    local moveset = gui and SafeFind(gui, "Main", "Moveset")
    if not moveset then return end

    headOfHeiEquipped = moveset:FindFirstChild("Projection Breaker") ~= nil
    charlesEquipped   = moveset:FindFirstChild("Eye Catching") ~= nil

    if headOfHeiEquipped then
        if _G.AwakeningCounter_Enabled and not headOfHeiEquippedNotified then
            Win:Notify("Equipment", "Head of Hei equipped - Awakening ready", 2)
            headOfHeiEquippedNotified = true
        end
    else
        headOfHeiEquippedNotified = false
    end

    if charlesEquipped then
        if _G.AutoCounter_Enabled and not charlesEquippedNotified then
            Win:Notify("Counter", "Charles Counter Ready", 2)
            charlesEquippedNotified = true
        end
    else
        charlesEquippedNotified = false
    end

    local hasLucky = checkForLuckyCoward()
    if hasLucky ~= luckyCowardEquipped then
        luckyCowardEquipped = hasLucky
        if _G.AutoCounter_Enabled and luckyCowardEquipped and not luckyCowardEquippedNotified then
            Win:Notify("Counter", "Lucky Coward Counter Available", 3)
            luckyCowardEquippedNotified = true
        elseif not luckyCowardEquipped then
            luckyCowardEquippedNotified = false
        end
    end
end

local function monitorCharlesCooldown()
    local gui     = LocalPlayer:FindFirstChild("PlayerGui")
    local moveset = gui and SafeFind(gui, "Main", "Moveset")
    if not moveset then return true end
    local eyeFrame = moveset:FindFirstChild("Eye Catching")
    if not eyeFrame then return true end
    local cooldown = eyeFrame:FindFirstChild("Cooldown")
    if not cooldown then return true end

    charlesCooldownAddr = tonumber(cooldown.Address)
    if not charlesCooldownAddr or charlesCooldownAddr <= 4096 then return true end

    local ok, secondsLeft = pcall(memory_read, "float", charlesCooldownAddr + VALUE_OFFSET)
    if not ok or secondsLeft ~= secondsLeft then return true end

    local isOnCD = secondsLeft > 0.1
    if isOnCD ~= charlesLastState then
        if isOnCD then
            Win:Notify("Charles", "Eye Catching on cooldown - " .. math.floor(secondsLeft) .. "s", 2)
        else
            Win:Notify("Charles", "Eye Catching ready", 2)
        end
        charlesLastState = isOnCD
    end
    charlesOnCooldown = isOnCD
    return not isOnCD
end

-- ════════════════════════════════════════════════════════════════
--  UI  (GalaxLib)
-- ════════════════════════════════════════════════════════════════

local DefenseTab = Win:AddTab("Defense")
local DefSec     = DefenseTab:AddSection("Auto Defense")

DefSec:AddToggle("Auto Block",       false, function(v) _G.AutoBlock_Enabled        = v end)
DefSec:AddToggle("Auto Block Dash",  false, function(v) _G.AutoBlockDash_Enabled    = v end)
DefSec:AddToggle("Auto Skill Block", false, function(v) _G.AutoSkillBlock_Enabled   = v end)
DefSec:AddToggle("Auto Counter",     false, function(v)
    _G.AutoCounter_Enabled = v
    if v then task.spawn(function() task.wait(0.5) checkEquippedAbilities() end) end
end)
DefSec:AddToggle("Awakening Counter", false, function(v)
    _G.AwakeningCounter_Enabled = v
    if v then task.spawn(function() task.wait(0.5) checkEquippedAbilities() end) end
end)

local AutoTab   = Win:AddTab("Automation")
local QTESec    = AutoTab:AddSection("Defense Attorney")
local RatioSec  = AutoTab:AddSection("Nanami")
local SwapSec   = AutoTab:AddSection("Todo")
local CharaSec  = AutoTab:AddSection("Chara")
local DomainSec = AutoTab:AddSection("Hiromi")

QTESec:AddToggle("Auto QTE", false, function(v) CONFIG.autoQTE.enabled = v end)
RatioSec:AddToggle("Auto Ratio QTE", false, function(v)
    CONFIG.ratioQTE.enabled = v
    if not v then
        RatioState.trackedTarget     = nil
        RatioState.trackedRatioValue = nil
        RatioState.isScanning        = false
        RatioState.hasTriggered      = false
    end
end)
SwapSec:AddToggle("Auto Perfect Swap", false, function(v)
    CONFIG.perfectSwap.enabled = v
    if not v then ResetSwapState() end
end)
CharaSec:AddToggle("Auto Chara QTE", false, function(v)
    CONFIG.charaQTE.enabled = v
    if not v then CharaQTEState.active = false end
end)
DomainSec:AddToggle("Vote Tracker", false, function(v)
    CONFIG.domainVotes.enabled = v
    if not v then ResetDomainState() end
end)

local ESPTab      = Win:AddTab("ESP")
local ESPSec      = ESPTab:AddSection("ESP Settings")
local DomainHPSec = ESPTab:AddSection("Domain Health")

ESPSec:AddToggle("Enable ESP",  false, function(v)
    CONFIG.esp.enabled = v
    if not v then for _, obj in pairs(ESPState.objects) do if obj.drawing then obj.drawing.Visible = false end end end
end)
ESPSec:AddToggle("Dummy ESP",  true,  function(v) CONFIG.esp.dummy  = v end)
ESPSec:AddToggle("Items ESP",  true,  function(v) CONFIG.esp.items  = v end)
DomainHPSec:AddToggle("Domain Health ESP", false, function(v)
    CONFIG.domainHealthESP.enabled = v
    if not v then
        for _, entry in pairs(DomainHealthESPState.drawings) do
            if entry.drawing then entry.drawing.Visible = false end
        end
    end
end)

Win:Notify("Jujutsu Hub", "Loaded!", 3)

-- ════════════════════════════════════════════════════════════════
--  MAIN DEFENSE LOOP
-- ════════════════════════════════════════════════════════════════

local blockTriggered = false
local dashTriggered  = false
local skillTriggered = false
local blockStart     = 0
local dashStart      = 0
local skillStart     = 0

task.spawn(function()
    while true do
        task.wait()
        checkEquippedAbilities()

        local charlesReady = true
        if _G.AutoCounter_Enabled and charlesEquipped then
            charlesReady = monitorCharlesCooldown()
        end

        local myChar = LocalPlayer and LocalPlayer.Character
        if not myChar then
            if blockTriggered then keyrelease(KEY_F); blockTriggered = false end
            if dashTriggered  then keyrelease(KEY_F); dashTriggered  = false end
            if skillTriggered then keyrelease(KEY_F); skillTriggered = false end
            continue
        end

        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    or myChar:FindFirstChild("Torso")
                    or myChar:FindFirstChild("UpperTorso")
        if not myRoot then continue end

        local blockAnimPlayer, dashAnimPlayer, skillAnimPlayer = nil, nil, nil
        local blockAnimId,     dashAnimId,     skillAnimId     = nil, nil, nil
        local anyAnimPlayer,   anyAnimId       = nil, nil

        for _, p in ipairs(Players:GetPlayers()) do
            if not p or isLocalPlayer(p) or not p.Character then continue end
            local theirRoot = p.Character:FindFirstChild("HumanoidRootPart")
                           or p.Character:FindFirstChild("Torso")
                           or p.Character:FindFirstChild("UpperTorso")
            if not theirRoot then continue end
            local dist = getMagnitude(theirRoot.Position, myRoot.Position)

            if dist <= BLOCK_RANGE then
                local id = getCurrentAnimFromChar(p.Character, BlockMode)
                if id then
                    blockAnimPlayer = p; blockAnimId = id
                    anyAnimPlayer   = p; anyAnimId   = id
                end
            end

            if dist <= DASH_RANGE then
                local id = getCurrentAnimFromChar(p.Character, DashMode)
                if id then
                    dashAnimPlayer = p; dashAnimId = id
                    anyAnimPlayer  = p; anyAnimId  = id
                end
            end

            if dist <= SKILL_RANGE then
                local id = getCurrentAnimFromChar(p.Character, SkillBlockMode)
                if id then
                    skillAnimPlayer = p; skillAnimId = id
                    anyAnimPlayer   = p; anyAnimId   = id
                end
            end
        end

        if _G.AutoCounter_Enabled and anyAnimPlayer and anyAnimId then
            if luckyCowardEquipped then
                mouse1click()
                if blockTriggered then keyrelease(KEY_F); blockTriggered = false end
                if dashTriggered  then keyrelease(KEY_F); dashTriggered  = false end
                if skillTriggered then keyrelease(KEY_F); skillTriggered = false end
                continue
            elseif charlesEquipped and charlesReady then
                keypress(KEY_3); keyrelease(KEY_3)
                if blockTriggered then keyrelease(KEY_F); blockTriggered = false end
                if dashTriggered  then keyrelease(KEY_F); dashTriggered  = false end
                if skillTriggered then keyrelease(KEY_F); skillTriggered = false end
                continue
            end
        end

        if _G.AutoSkillBlock_Enabled and skillAnimPlayer and skillAnimId then
            if not skillTriggered then
                skillTriggered = true
                skillStart     = tick()
                keypress(KEY_F)
            end
            if skillTriggered and tick() - skillStart >= BLOCK_HOLD_TIME then
                keyrelease(KEY_F)
                mouse1click()
                skillTriggered = false
            end
            continue
        end

        if _G.AutoBlockDash_Enabled and dashAnimPlayer and dashAnimId then
            if not dashTriggered then
                dashTriggered = true
                dashStart     = tick()
                keypress(KEY_F)
            end
            if dashTriggered and tick() - dashStart >= BLOCK_HOLD_TIME then
                keyrelease(KEY_F)
                mouse1click()
                dashTriggered = false
            end
            continue
        end

        if _G.AutoBlock_Enabled and blockAnimPlayer and blockAnimId then
            if not blockTriggered then
                blockTriggered = true
                blockStart     = tick()
                keypress(KEY_F)
            end
            if blockTriggered and tick() - blockStart >= BLOCK_HOLD_TIME then
                keyrelease(KEY_F)
                mouse1click()
                blockTriggered = false
            end
            continue
        end

        if blockTriggered then keyrelease(KEY_F); blockTriggered = false end
        if dashTriggered  then keyrelease(KEY_F); dashTriggered  = false end
        if skillTriggered then keyrelease(KEY_F); skillTriggered = false end
    end
end)

-- ════════════════════════════════════════════════════════════════
--  AWAKENING COUNTER LOOP
-- ════════════════════════════════════════════════════════════════

task.spawn(function()
    while true do
        task.wait()
        if not _G.AwakeningCounter_Enabled then continue end
        if not isUltimateReady() then continue end
        if not headOfHeiEquipped and not charlesEquipped then continue end

        local myChar = LocalPlayer and LocalPlayer.Character
        if not myChar then continue end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    or myChar:FindFirstChild("Torso")
                    or myChar:FindFirstChild("UpperTorso")
        if not myRoot then continue end

        for _, p in ipairs(Players:GetPlayers()) do
            if not p or isLocalPlayer(p) or not p.Character then continue end
            local theirRoot = p.Character:FindFirstChild("HumanoidRootPart")
                           or p.Character:FindFirstChild("Torso")
                           or p.Character:FindFirstChild("UpperTorso")
            if not theirRoot then continue end
            local dist = getMagnitude(theirRoot.Position, myRoot.Position)
            if dist <= BLOCK_RANGE then
                local blockAnim = getCurrentAnimFromChar(p.Character, BlockMode)
                local dashAnim  = getCurrentAnimFromChar(p.Character, DashMode)
                if blockAnim or dashAnim then
                    keypress(KEY_G); task.wait(0.1); keyrelease(KEY_G)
                    if tick() - lastAwakeningNotif > notifCooldown then
                        Win:Notify("Awakening", "Awakening counter on " .. p.Name, 2)
                        lastAwakeningNotif = tick()
                    end
                    break
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
--  BACKGROUND LOOPS
-- ════════════════════════════════════════════════════════════════

task.spawn(function()
    while true do
        if _G.AutoCounter_Enabled or _G.AwakeningCounter_Enabled then
            checkEquippedAbilities()
        end
        task.wait(1)
    end
end)

spawn(function()
    while running do
        if CONFIG.autoQTE.enabled and not iskeypressed(KEYS.F) then
            if ProcessQTE() then
                local delay = CONFIG.autoQTE.postPressDelay
                if CONFIG.autoQTE.deviation > 0 then
                    delay = delay + (math.random() * 2 - 1) * CONFIG.autoQTE.deviation
                end
                task.wait(delay)
            else
                task.wait(0.05)
            end
        else
            task.wait(0.1)
        end
    end
end)

spawn(function()
    while running do
        pcall(UpdateESPPositions)
        pcall(UpdateDomainHealthESP)
        task.wait(1 / math.max(1, CONFIG.esp.updateRate))
    end
end)

spawn(function()
    while running do pcall(DiscoverESPObjects) task.wait(0.5) end
end)

spawn(function()
    while running do pcall(ProcessRatioQTE) task.wait(0.016) end
end)

spawn(function()
    while running do pcall(ProcessPerfectSwap) task.wait(0.01) end
end)

spawn(function()
    while running do pcall(RunCharaQTE) task.wait(0.2) end
end)

spawn(function()
    while running do pcall(ProcessDomainVotes) task.wait(0.05) end
end)

spawn(function()
    while running do currentPing = GetPing() task.wait(1) end
end)
