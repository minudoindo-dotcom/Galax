loadstring(game:HttpGet("https://pastebin.com/raw/bghZmR8D"))()

local Win = GalaxLib:CreateWindow({
    Title   = "Skid Galax",
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
local lastCharlesTime         = 0
local CHARLES_COOLDOWN        = 2

-- === UPDATED OFFSETS (version-ae421f0582e54718) ===
local VISIBLE_OFFSET = 1461  -- GuiObject.Visible (was 1445)
local TIMER_OFFSET   = 284   -- unchanged

local KnownOffsets = {
    AnimationId              = 208,  -- Misc.AnimationId
    ClassDescriptor          = 24,   -- Instance.ClassDescriptor
    ClassDescriptorToClassName = 8,  -- Instance.ClassName
    Name                     = 176,  -- Instance.Name
    ActiveAnimations         = 2152, -- Animator.ActiveAnimations (was 2136)
    NodeNext                 = 16,   -- unchanged
    Animation                = 208,  -- AnimationTrack.Animation
}

local BlockMode = {
    ["94588892125071"]=true,["97868312130612"]=true,["140588454098230"]=true,
    ["138826758216894"]=true,["109299799610861"]=true,["95295463826732"]=true,
    ["105077924973072"]=true,["124862357369335"]=true,["81630213087988"]=true,
    ["75337033003776"]=true,["138489871864252"]=true,["96185406489877"]=true,
    ["105287938257399"]=true,["134243365075812"]=true,["119042572747325"]=true,
    ["107029561762376"]=true,["117831239064143"]=true,["127851700400958"]=true,
    ["73456086297777"]=true,["84442064935420"]=true,["111750364977569"]=true,
    ["133447840605824"]=true,["113963875117859"]=true,["106282708121342"]=true,
    ["101681158700275"]=true,["119152716475706"]=true,["100040983719699"]=true,
    ["125689391910002"]=true,["84080901810314"]=true,["139833047658617"]=true,
    ["79271374075726"]=true,["106474043944206"]=true,["91990544700842"]=true,
    ["107825127494342"]=true,["97504088532041"]=true,["85068785050521"]=true,
    ["79086910454958"]=true,["108027796023968"]=true,["96327114254575"]=true,
    ["84359513001979"]=true,["79436586236026"]=true,["102285403332509"]=true,
    ["104137631480391"]=true,["78540777177847"]=true,["133936641185614"]=true,
    ["122573730331631"]=true,["82400997593751"]=true,["118634493886688"]=true,
    ["115586282387431"]=true,["101283990868172"]=true,["108708446862011"]=true,
    ["77583711129628"]=true,["116910683335467"]=true,
}

local DashMode = {
    ["92966188946988"]=true,["81708642912019"]=true,["130284226842903"]=true,
    ["110978068388232"]=true,["134917827147266"]=true,["140597320237985"]=true,
    ["132855702748568"]=true,["99451940496871"]=true,["130135202362252"]=true,
}

local KEY_F          = 0x46
local KEY_3          = 0x33
local KEY_G          = 0x47
local BLOCK_RANGE    = 8
local DASH_RANGE     = 15
local BLOCK_HOLD_TIME = 0.25

_G.AutoBlock_Enabled        = false
_G.AutoBlockDash_Enabled    = false
_G.AutoCounter_Enabled      = false
_G.AwakeningCounter_Enabled = false

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
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"].Value
    end)
    return (ok and tonumber(v)) or 0
end

local function GetQTELabel()
    return SafeFind(LocalPlayer, "PlayerGui", "QTE", "QTE_PC")
end

local function ProcessQTE()
    if not CONFIG.autoQTE.enabled or iskeypressed(KEYS.F) then return false end
    local label = GetQTELabel()
    if not label or not label.Text or label.Text == "" then return false end
    local keyCode = VALID_QTE_KEYS[label.Text:upper()]
    if not keyCode then return false end
    QTEState.detectedKey  = label.Text:upper()
    QTEState.detectedTime = GetTime()
    keypress(keyCode)
    keyrelease(keyCode)
    return true
end

local function HasSalarymanMoveset()
    return HasMoveset("Salaryman") or HasMoveset("Nanami")
end

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
    if humanoid and humanoid.MaxHealth > 0 then return humanoid.Health / humanoid.MaxHealth end
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
            RatioState.trackedTarget      = nil
            RatioState.trackedRatioValue  = nil
            RatioState.hasTriggered       = false
            return
        end
        if RatioState.hasTriggered or currentTime - RatioState.lastTriggerTime < RatioState.triggerCooldown then return end
        if currentTime - RatioState.qteDetectedTime >= RatioState.calculatedDelay then
            keypress(KEYS.R)
            keyrelease(KEYS.R)
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
                        mouse1press()
                        mouse1release()
                        SwapState.hasTriggeredM1 = true
                    end
                    ResetSwapState()
                    return
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
    local centerX  = bar.AbsolutePosition.X + bar.AbsoluteSize.X / 2
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

local function CreateESPDrawing(name, color)
    local d = Drawing.new("Text")
    d.Font    = Drawing.Fonts.System
    d.Text    = name
    d.Color   = Color3.fromRGB(color[1], color[2], color[3])
    d.Outline = true
    d.Center  = true
    d.Visible = false
    return d
end

local function RemoveESPDrawing(espObj)
    if espObj and espObj.drawing then espObj.drawing:Remove() end
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
    local key     = "dummy_character"
    local existing = ESPState.objects[key]
    if existing then
        if existing.part and existing.part.Parent then return end
        RemoveESPDrawing(existing)
        ESPState.objects[key] = nil
    end
    local dummy = SafeFind(workspace, "Characters", "Dummy")
    if not dummy then return end
    local hrp = dummy:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    ESPState.objects[key] = {
        drawing  = CreateESPDrawing("Dummy", CONFIG.esp.colorDummy),
        instance = dummy, part = hrp, type = "dummy"
    }
end

local function DiscoverItems()
    local itemsFolder = SafeFind(workspace, "Items")
    if not itemsFolder then return end
    local seen = {}
    for _, item in ipairs(itemsFolder:GetChildren()) do
        if item:IsA("Part") or item:IsA("MeshPart") then
            local addr = item.Address
            seen[addr] = true
            if not ESPState.objects[addr] then
                ESPState.objects[addr] = {
                    drawing  = CreateESPDrawing(item.Name, CONFIG.esp.colorItems),
                    instance = item, part = item, type = "item"
                }
            end
        end
    end
    for addr, espObj in pairs(ESPState.objects) do
        if espObj.type == "item" and not seen[addr] then
            RemoveESPDrawing(espObj)
            ESPState.objects[addr] = nil
        end
    end
end

local function DiscoverESPObjects()
    pcall(DiscoverDummy)
    pcall(DiscoverItems)
end

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
        for _, entry in pairs(DomainHealthESPState.drawings) do entry.drawing.Visible = false end
        return
    end
    local domainsFolder = workspace:FindFirstChild("Domains")
    local playerPos     = GetPlayerPosition()
    local threshold     = CONFIG.domainHealthESP.nearbyThreshold
    local camera        = workspace.CurrentCamera
    local vpSize        = camera and camera.ViewportSize
    local centerX       = vpSize and (vpSize.X / 2) or 960
    local seen          = {}
    if domainsFolder then
        for _, domain in ipairs(domainsFolder:GetChildren()) do
            local mesh = (domain.Name == "Domain" and domain:IsA("MeshPart"))
                and domain or domain:FindFirstChild("Domain")
            if not mesh then continue end
            local addr  = mesh.Address
            seen[addr]  = true
            local entry = DomainHealthESPState.drawings[addr]
            if not entry then
                entry = { drawing = CreateDomainHealthDrawing() }
                DomainHealthESPState.drawings[addr] = entry
            end
            local hp   = mesh:GetAttribute("Health") or mesh:GetAttribute("DomainHealth") or 0
            entry.drawing.Text = "Domain HP: " .. math.floor(hp)
            local dist = playerPos and CalculateDistance(playerPos, mesh.Position) or math.huge
            if dist <= threshold then
                entry.drawing.Position = Vector2.new(centerX, 50)
                entry.drawing.Visible  = true
            else
                local screenPos, onScreen = WorldToScreen(mesh.Position)
                entry.drawing.Visible = onScreen
                if onScreen then entry.drawing.Position = screenPos end
            end
        end
    end
    for addr, entry in pairs(DomainHealthESPState.drawings) do
        if not seen[addr] then
            entry.drawing:Remove()
            DomainHealthESPState.drawings[addr] = nil
        end
    end
end

local function HasHiromiMoveset() return HasMoveset("Hiromi") end
local function HasChooseUI() return SafeFind(LocalPlayer, "PlayerGui", "Choose") ~= nil end

local function FindPlayerDomain()
    local domainsFolder = workspace:FindFirstChild("Domains")
    if not domainsFolder then return nil end
    local playerPos = GetPlayerPosition()
    if not playerPos then return nil end
    local closest, closestDist = nil, math.huge
    for _, domain in ipairs(domainsFolder:GetChildren()) do
        local mesh = (domain.Name == "Domain" and domain:IsA("MeshPart"))
            and domain or domain:FindFirstChild("Domain")
        if not mesh then continue end
        local col = mesh:FindFirstChild("DomainCollider") or mesh
        if col and col:IsA("BasePart") then
            local d = CalculateDistance(playerPos, col.Position)
            if d < closestDist then closestDist = d closest = mesh end
        end
    end
    return closest
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
        d.Font    = Drawing.Fonts.System
        d.Text    = "0"
        d.Size    = 24
        d.Color   = Color3.fromRGB(255, 0, 0)
        d.Outline = true
        d.Center  = true
        d.Visible = false
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
        if maxVote == 0 or count ~= maxVote then return red end
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
    local ui = SafeFind(LocalPlayer, "PlayerGui", "Choose")
    if not ui then return nil, nil, nil end
    local function getPos(name)
        local btn = ui:FindFirstChild(name)
        if not btn then return nil end
        return Vector2.new(btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2, btn.AbsolutePosition.Y - 30)
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
        if DomainState.isActive then ResetDomainState() end return
    end
    if not HasHiromiMoveset() then
        if DomainState.isActive or DomainState.waitingForChooseUI then ResetDomainState() end return
    end
    local currentTime = GetTime()
    local gPressed    = iskeypressed(KEYS.G)
    if gPressed and not DomainState.gWasPressed and not DomainState.isActive and not DomainState.waitingForChooseUI then
        DomainState.waitingForChooseUI = true
        DomainState.waitStartTime      = currentTime
    end
    DomainState.gWasPressed = gPressed
    if DomainState.waitingForChooseUI then
        if currentTime - DomainState.waitStartTime > 6.0 then DomainState.waitingForChooseUI = false return end
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
            ResetDomainState() return
        end
        local c, s, d = GetDomainVotes(DomainState.trackedDomain)
        if c ~= DomainState.confessCount or s ~= DomainState.silenceCount or d ~= DomainState.denialCount then
            DomainState.confessCount = c
            DomainState.silenceCount = s
            DomainState.denialCount  = d
            UpdateVoteDisplay(c, s, d)
        end
        PositionVoteDrawings()
    end
end

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
    local desc = readPtr(addr + KnownOffsets.ClassDescriptor)
    if not desc then return nil end
    local namePtr = readPtr(desc + KnownOffsets.ClassDescriptorToClassName)
    return namePtr and readStr(namePtr) or nil
end

local function getAnimator(char)
    if not char or char.Address == 0 then return nil end
    local hum  = char:FindFirstChild("Humanoid")
    if not hum then return nil end
    local anim = hum:FindFirstChild("Animator")
    return anim and anim.Address or nil
end

local function checkAnim(track, mode)
    local anim = readPtr(track + KnownOffsets.Animation)
    if not anim or getClass(anim) ~= "Animation" then return nil end
    local idPtr = readPtr(anim + KnownOffsets.AnimationId)
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
    local head = readPtr(animator + KnownOffsets.ActiveAnimations)
    if not head then return nil end
    local first = readPtr(head)
    if not first or first == head then return nil end
    local curr    = first
    local maxIter = 64
    local iter    = 0
    while curr and curr ~= 0 and curr ~= head and iter < maxIter do
        iter = iter + 1
        local track = readPtr(curr + KnownOffsets.NodeNext)
        if track and getClass(track) == "AnimationTrack" then
            local id = checkAnim(track, mode)
            if id then return id end
        end
        curr = readPtr(curr)
    end
    return nil
end

local function isLocalPlayer(p)
    return p == LocalPlayer
        or (p.UserId and p.UserId == LocalPlayer.UserId)
        or (p.Name   and p.Name   == LocalPlayer.Name)
end

local function isUltimateReady()
    local gui        = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
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
    charlesCooldownAddr = cooldown.Address
    local secondsLeft   = memory_read("float", charlesCooldownAddr + TIMER_OFFSET)
    if not secondsLeft or secondsLeft ~= secondsLeft then return true end
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

local blockTriggered = false
local dashTriggered  = false
local blockStart     = 0
local dashStart      = 0

-- === UI ===
local DefenseTab = Win:AddTab("Defense")
local DefSec     = DefenseTab:AddSection("Auto Defense")

DefSec:AddToggle("Auto Block", false, function(v) _G.AutoBlock_Enabled = v end)
DefSec:AddToggle("Auto Block Dash", false, function(v) _G.AutoBlockDash_Enabled = v end)
DefSec:AddToggle("Auto Counter", false, function(v)
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
        RatioState.trackedTarget      = nil
        RatioState.trackedRatioValue  = nil
        RatioState.isScanning         = false
        RatioState.hasTriggered       = false
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

ESPSec:AddToggle("Enable ESP", false, function(v)
    CONFIG.esp.enabled = v
    if not v then
        for _, obj in pairs(ESPState.objects) do
            if obj.drawing then obj.drawing.Visible = false end
        end
    end
end)
ESPSec:AddToggle("Dummy ESP", true, function(v) CONFIG.esp.dummy = v end)
ESPSec:AddToggle("Items ESP", true, function(v) CONFIG.esp.items = v end)
DomainHPSec:AddToggle("Domain Health ESP", false, function(v)
    CONFIG.domainHealthESP.enabled = v
    if not v then
        for _, entry in pairs(DomainHealthESPState.drawings) do
            entry.drawing.Visible = false
        end
    end
end)

local SupportersTab  = Win:AddTab("Supporters")
local TopDonatorsSec = SupportersTab:AddSection("Top Donators")
TopDonatorsSec:AddLabel("Unserializedfirearms - 1k")
TopDonatorsSec:AddLabel("Anis3504 - 1k")
TopDonatorsSec:AddLabel("infinite - Dev 500")
TopDonatorsSec:AddLabel("Shelovedami - 300")
TopDonatorsSec:AddLabel("_swishh. - 100")

-- === MAIN DEFENSE LOOP ===
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
            if blockTriggered then keyrelease(KEY_F) blockTriggered = false end
            if dashTriggered  then keyrelease(KEY_F) dashTriggered  = false end
            continue
        end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                    or myChar:FindFirstChild("Torso")
                    or myChar:FindFirstChild("UpperTorso")
        if not myRoot then continue end

        local blockAnimPlayer = nil
        local dashAnimPlayer  = nil
        local currentTime     = tick()

        for _, p in ipairs(Players:GetPlayers()) do
            if not p or isLocalPlayer(p) or not p.Character then continue end
            local theirRoot = p.Character:FindFirstChild("HumanoidRootPart")
                           or p.Character:FindFirstChild("Torso")
                           or p.Character:FindFirstChild("UpperTorso")
            if not theirRoot then continue end
            local dist = getMagnitude(theirRoot.Position, myRoot.Position)
            if dist <= BLOCK_RANGE and not blockAnimPlayer then
                if getCurrentAnimFromChar(p.Character, BlockMode) then
                    blockAnimPlayer = p
                end
            end
            if dist <= DASH_RANGE and not dashAnimPlayer then
                if getCurrentAnimFromChar(p.Character, DashMode) then
                    dashAnimPlayer = p
                end
            end
            if blockAnimPlayer and dashAnimPlayer then break end
        end

        -- Awakening Counter (highest priority)
        if _G.AwakeningCounter_Enabled and isUltimateReady() and (headOfHeiEquipped or charlesEquipped) then
            if blockAnimPlayer or dashAnimPlayer then
                keypress(KEY_G) keyrelease(KEY_G)
                if tick() - lastAwakeningNotif > notifCooldown then
                    local name = (blockAnimPlayer or dashAnimPlayer).Name
                    Win:Notify("Awakening", "Awakening counter on " .. name, 2)
                    lastAwakeningNotif = tick()
                end
                if blockTriggered then keyrelease(KEY_F) blockTriggered = false end
                if dashTriggered  then keyrelease(KEY_F) dashTriggered  = false end
                continue
            end
        end

        -- Auto Counter
        if _G.AutoCounter_Enabled then
            local counterAvailable = luckyCowardEquipped or (charlesEquipped and charlesReady)
            if counterAvailable and (blockAnimPlayer or dashAnimPlayer) then
                if luckyCowardEquipped then
                    mouse1click()
                elseif charlesEquipped and charlesReady and currentTime - lastCharlesTime > CHARLES_COOLDOWN then
                    keypress(KEY_3) keyrelease(KEY_3)
                    lastCharlesTime = currentTime
                end
                if blockTriggered then keyrelease(KEY_F) blockTriggered = false end
                if dashTriggered  then keyrelease(KEY_F) dashTriggered  = false end
                continue
            end
        end

        -- Auto Block Dash
        if _G.AutoBlockDash_Enabled and dashAnimPlayer then
            if not dashTriggered then
                dashTriggered = true
                dashStart     = tick()
                keypress(KEY_F)
            end
            if tick() - dashStart >= BLOCK_HOLD_TIME then
                keyrelease(KEY_F)
                mouse1click()
                dashTriggered = false
            end
            continue
        end

        -- Auto Block
        if _G.AutoBlock_Enabled and blockAnimPlayer then
            if not blockTriggered then
                blockTriggered = true
                blockStart     = tick()
                keypress(KEY_F)
            end
            if tick() - blockStart >= BLOCK_HOLD_TIME then
                keyrelease(KEY_F)
                mouse1click()
                blockTriggered = false
            end
            continue
        end

        if blockTriggered then keyrelease(KEY_F) blockTriggered = false end
        if dashTriggered  then keyrelease(KEY_F) dashTriggered  = false end
    end
end)

task.spawn(function()
    while true do
        if _G.AutoCounter_Enabled or _G.AwakeningCounter_Enabled then
            checkEquippedAbilities()
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while running do
        if CONFIG.autoQTE.enabled and not iskeypressed(KEYS.F) then
            if ProcessQTE() then
                local delay = CONFIG.autoQTE.postPressDelay
                if CONFIG.autoQTE.deviation > 0 then
                    delay = delay + (math.random() * 2 - 1) * CONFIG.autoQTE.deviation
                end
                task.wait(delay)
            else task.wait(0.05) end
        else task.wait(0.1) end
    end
end)

task.spawn(function() while running do pcall(UpdateESPPositions) pcall(UpdateDomainHealthESP) task.wait(1 / math.max(1, CONFIG.esp.updateRate)) end end)
task.spawn(function() while running do pcall(DiscoverESPObjects) task.wait(0.5)  end end)
task.spawn(function() while running do pcall(ProcessRatioQTE)    task.wait(0.016) end end)
task.spawn(function() while running do pcall(ProcessPerfectSwap) task.wait(0.01)  end end)
task.spawn(function() while running do pcall(RunCharaQTE)        task.wait(0.2)   end end)
task.spawn(function() while running do pcall(ProcessDomainVotes) task.wait(0.05)  end end)
task.spawn(function() while running do currentPing = GetPing()   task.wait(1)     end end)

Win:LoadConfig(true, false)
Win:Notify("Skid Galax", "Loaded!", 3)
