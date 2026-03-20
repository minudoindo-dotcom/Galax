-- ════════════════════════════════════════════════════════════════
--  Jujutsu Shenanigans
--  UI: Matcha Native
-- ════════════════════════════════════════════════════════════════

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
                     box = true, name = true, distance = true, traceline = false,
                     colorDummy = Color3.fromRGB(255, 100, 100),
                     colorItems = Color3.fromRGB(100, 255, 100),
                     updateRate = 60 },
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

-- === OFFSETS (version-ae421f0582e54718) ===
local VISIBLE_OFFSET = 1461  -- GuiObject.Visible
local TIMER_OFFSET   = 284   -- Camera.Position (used as float timer)

local KnownOffsets = {
    AnimationId               = 208,  -- Misc.AnimationId
    ClassDescriptor           = 24,   -- Instance.ClassDescriptor
    ClassDescriptorToClassName = 8,   -- Instance.ClassName
    Name                      = 176,  -- Instance.Name
    ActiveAnimations          = 2152, -- Animator.ActiveAnimations
    NodeNext                  = 16,
    Animation                 = 208,  -- AnimationTrack.Animation
}

local BlockMode = {
    ["100040983719699"]=true,["100474683542881"]=true,["100835844904897"]=true,
    ["100919783371339"]=true,["101107501526373"]=true,["101283990868172"]=true,
    ["101681158700275"]=true,["101862938993177"]=true,["102085681670810"]=true,
    ["102285403332509"]=true,["104087365067491"]=true,["104137631480391"]=true,
    ["104148378077935"]=true,["105077924973072"]=true,["105287938257399"]=true,
    ["105376952884290"]=true,["105870773841535"]=true,["105878146832347"]=true,
    ["106282708121342"]=true,["106474043944206"]=true,["107029561762376"]=true,
    ["107825127494342"]=true,["108027796023968"]=true,["108376755316792"]=true,
    ["108449614447004"]=true,["108636011034323"]=true,["108686045412945"]=true,
    ["108708446862011"]=true,["109299799610861"]=true,["109340494549365"]=true,
    ["109598602517674"]=true,["109718372214725"]=true,["110146909061402"]=true,
    ["110978068388232"]=true,["111083699259354"]=true,["111750364977569"]=true,
    ["112976111828157"]=true,["113963875117859"]=true,["114375152692460"]=true,
    ["114562626498918"]=true,["114648729358082"]=true,["114797198964940"]=true,
    ["114913455544468"]=true,["114985590391235"]=true,["115220151812065"]=true,
    ["115446267797335"]=true,["115586282387431"]=true,["116910683335467"]=true,
    ["117638619792450"]=true,["117831239064143"]=true,["118634493886688"]=true,
    ["119042572747325"]=true,["119152716475706"]=true,["119434039452526"]=true,
    ["120951759618134"]=true,["121322029260156"]=true,["121800365664070"]=true,
    ["122074769949629"]=true,["122170399962557"]=true,["122573730331631"]=true,
    ["122655618588472"]=true,["123236749567737"]=true,["123414935051274"]=true,
    ["124777463468279"]=true,["124862357369335"]=true,["125120382787311"]=true,
    ["125689391910002"]=true,["126277739156443"]=true,["127851700400958"]=true,
    ["128267680345523"]=true,["129392532939530"]=true,["130013701390383"]=true,
    ["130135202362252"]=true,["130284226842903"]=true,["130659585624615"]=true,
    ["130806585141471"]=true,["131279921755936"]=true,["131967150738931"]=true,
    ["132855702748568"]=true,["133240987753043"]=true,["133447840605824"]=true,
    ["133936641185614"]=true,["134243365075812"]=true,["134461702265323"]=true,
    ["134917827147266"]=true,["136978371933277"]=true,["138169151223960"]=true,
    ["138489871864252"]=true,["138626478088332"]=true,["138826758216894"]=true,
    ["139280948741186"]=true,["139833047658617"]=true,["139899183181812"]=true,
    ["140487289646129"]=true,["140588454098230"]=true,["140597320237985"]=true,
    ["71784337627181"]=true,["72211631197834"]=true,["72548435296350"]=true,
    ["73456086297777"]=true,["74550814125588"]=true,["74580112757879"]=true,
    ["75337033003776"]=true,["75425383606016"]=true,["75961842881209"]=true,
    ["77284264481284"]=true,["77583711129628"]=true,["78540777177847"]=true,
    ["79037514387169"]=true,["79086910454958"]=true,["79271374075726"]=true,
    ["79436586236026"]=true,["79568627671998"]=true,["79718433989469"]=true,
    ["80150988150906"]=true,["80504019426174"]=true,["81630213087988"]=true,
    ["81708642912019"]=true,["81786875517933"]=true,["82400997593751"]=true,
    ["83843118463884"]=true,["84080901810314"]=true,["84359513001979"]=true,
    ["84442064935420"]=true,["84547415708554"]=true,["84602523265622"]=true,
    ["84989753395518"]=true,["85068785050521"]=true,["85148168523745"]=true,
    ["85887300265206"]=true,["86109053396974"]=true,["86626502434817"]=true,
    ["86918383671100"]=true,["87792276744794"]=true,["88849926869776"]=true,
    ["89394375446962"]=true,["89537672683114"]=true,["90981055255583"]=true,
    ["91853462087608"]=true,["91990544700842"]=true,["92424708306981"]=true,
    ["92966188946988"]=true,["94588892125071"]=true,["94781366396051"]=true,
    ["95002584969527"]=true,["95295463826732"]=true,["96185406489877"]=true,
    ["96327114254575"]=true,["96433049733325"]=true,["96513213736303"]=true,
    ["97207871642820"]=true,["97215638330770"]=true,["97504088532041"]=true,
    ["97868312130612"]=true,["98365018553171"]=true,["98577624776161"]=true,
    ["98783064085844"]=true,["98845475810982"]=true,["99205259396653"]=true,
    ["99451940496871"]=true,["99710481887795"]=true,
}

local DashMode = {
    ["102567076867813"]=true,["102698645310820"]=true,["117223862448096"]=true,
    ["134451575263988"]=true,["134581973800784"]=true,["75203303352791"]=true,
    ["9443519528"]=true,
}

local KEY_F           = 0x46
local KEY_3           = 0x33
local KEY_G           = 0x47
local BLOCK_RANGE     = 8
local DASH_RANGE      = 15
local BLOCK_HOLD_TIME = 0.25

_G.AutoBlock_Enabled        = false
_G.AutoBlockDash_Enabled    = false
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
        SwapState.isScanning     = true
        SwapState.scanStartTime  = currentTime
        SwapState.swapConfirmed  = false
        SwapState.hasTriggeredM1 = false
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

-- ── ESP inline (box + name + distance + traceline) ──────────────

local function espCreate(part, label, color)
    local e = {
        part  = part,
        label = label,
        color = color,
        box   = Drawing.new("Square"),
        name  = Drawing.new("Text"),
        dist  = Drawing.new("Text"),
        line  = Drawing.new("Line"),
    }
    e.box.Filled=false; e.box.Thickness=1; e.box.Visible=false; e.box.ZIndex=5
    e.name.Center=true; e.name.Outline=true; e.name.Font=Drawing.Fonts.SystemBold
    e.name.Size=13; e.name.Visible=false; e.name.ZIndex=5
    e.dist.Center=true; e.dist.Outline=true; e.dist.Font=Drawing.Fonts.UI
    e.dist.Size=11; e.dist.Color=Color3.fromRGB(200,200,200); e.dist.Visible=false; e.dist.ZIndex=5
    e.line.Thickness=1; e.line.Visible=false; e.line.ZIndex=5
    return e
end

local function espDestroy(e)
    if not e then return end
    e.box:Remove(); e.name:Remove(); e.dist:Remove(); e.line:Remove()
end

local function espHide(e)
    if not e then return end
    e.box.Visible=false; e.name.Visible=false
    e.dist.Visible=false; e.line.Visible=false
end

local function espUpdate(e, myPos)
    if not e or not e.part or not e.part.Parent then espHide(e); return end
    local ok, pos = pcall(function() return e.part.Position end)
    if not ok or not pos then espHide(e); return end
    local okS, sp, onScreen = pcall(WorldToScreen, pos + Vector3.new(0, 1, 0))
    if not okS or not sp or not onScreen then espHide(e); return end

    local dist  = math.floor((myPos - pos).Magnitude)
    local boxH  = math.clamp(1000 / math.max(dist, 1), 10, 200)
    local boxW  = boxH * 0.6
    local col   = e.color

    if CONFIG.esp.box then
        e.box.Position = Vector2.new(sp.X - boxW/2, sp.Y - boxH/2)
        e.box.Size     = Vector2.new(boxW, boxH)
        e.box.Color    = col; e.box.Visible = true
    else e.box.Visible = false end

    if CONFIG.esp.name then
        e.name.Text     = e.label
        e.name.Color    = col
        e.name.Position = Vector2.new(sp.X, sp.Y - boxH/2 - 14)
        e.name.Visible  = true
    else e.name.Visible = false end

    if CONFIG.esp.distance then
        e.dist.Text     = dist .. "m"
        e.dist.Position = Vector2.new(sp.X, sp.Y + boxH/2 + 2)
        e.dist.Visible  = true
    else e.dist.Visible = false end

    if CONFIG.esp.traceline then
        local cam   = workspace.CurrentCamera
        local scrH  = cam and cam.ViewportSize.Y or 600
        e.line.From    = Vector2.new(sp.X, scrH)
        e.line.To      = Vector2.new(sp.X, sp.Y)
        e.line.Color   = col; e.line.Visible = true
    else e.line.Visible = false end
end

local function RemoveESPDrawing(espObj)
    if espObj then espDestroy(espObj) end
end

local function UpdateESPPositions()
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myPos = myHrp and myHrp.Position or Vector3.new(0,0,0)
    if not CONFIG.esp.enabled then
        for _, e in pairs(ESPState.objects) do espHide(e) end
        return
    end
    for key, e in pairs(ESPState.objects) do
        local typeEnabled = (e.type == "dummy" and CONFIG.esp.dummy)
                         or (e.type == "item"  and CONFIG.esp.items)
        if not typeEnabled then
            espHide(e)
        elseif not e.part or not e.part.Parent then
            espDestroy(e); ESPState.objects[key] = nil
        else
            e.color = e.type == "dummy" and CONFIG.esp.colorDummy or CONFIG.esp.colorItems
            espUpdate(e, myPos)
        end
    end
end

local function DiscoverDummy()
    local key      = "dummy_character"
    local existing = ESPState.objects[key]
    if existing then
        if existing.part and existing.part.Parent then return end
        espDestroy(existing); ESPState.objects[key] = nil
    end
    local dummy = SafeFind(workspace, "Characters", "Dummy")
    if dummy then
        local part = dummy:FindFirstChild("HumanoidRootPart") or dummy:FindFirstChild("Head")
        if part then
            ESPState.objects[key] = espCreate(part, "Dummy", CONFIG.esp.colorDummy)
            ESPState.objects[key].type = "dummy"
        end
    end
end

local function DiscoverItems()
    local items = workspace:FindFirstChild("Items")
    if not items then return end
    for _, item in ipairs(items:GetChildren()) do
        local key = tostring(item.Address or item.Name)
        if not ESPState.objects[key] then
            local part = item:FindFirstChildWhichIsA("BasePart") or item
            if part then
                local e = espCreate(part, item.Name, CONFIG.esp.colorItems)
                e.type = "item"
                ESPState.objects[key] = e
            end
        end
    end
    for key, e in pairs(ESPState.objects) do
        if e.type == "item" and (not e.part or not e.part.Parent) then
            espDestroy(e); ESPState.objects[key] = nil
        end
    end
end

local function DiscoverESPObjects()
    if not CONFIG.esp.enabled then return end
    DiscoverDummy()
    DiscoverItems()
end

local function UpdateDomainHealthESP()
    if not CONFIG.domainHealthESP.enabled then
        for _, entry in pairs(DomainHealthESPState.drawings) do
            if entry.drawing then entry.drawing.Visible = false end
        end
        return
    end
    local myPos = GetPlayerPosition()
    local domains = workspace:FindFirstChild("Domains")
    if not domains then return end
    local seen = {}
    for _, domain in ipairs(domains:GetChildren()) do
        local key = tostring(domain.Address or domain.Name)
        seen[key] = true
        local hp = domain:FindFirstChild("Health") or domain:FindFirstChild("HP")
        local part = domain:FindFirstChildWhichIsA("BasePart")
        if hp and part then
            local dist = myPos and getMagnitude(part.Position, myPos) or math.huge
            if dist <= CONFIG.domainHealthESP.nearbyThreshold then
                if not DomainHealthESPState.drawings[key] then
                    local d = Drawing.new("Text")
                    d.Font = Drawing.Fonts.System; d.Outline = true
                    d.Center = true; d.Visible = false
                    DomainHealthESPState.drawings[key] = { drawing = d, domain = domain, part = part }
                end
                local entry = DomainHealthESPState.drawings[key]
                local screenPos, onScreen = WorldToScreen(part.Position + Vector3.new(0, 3, 0))
                entry.drawing.Visible = onScreen
                if onScreen then
                    local hpVal = tonumber(hp.Value) or 0
                    entry.drawing.Text = domain.Name .. " HP: " .. math.floor(hpVal)
                    entry.drawing.Color = Color3.fromRGB(255, 80, 80)
                    entry.drawing.Position = screenPos
                end
            end
        end
    end
    for key, entry in pairs(DomainHealthESPState.drawings) do
        if not seen[key] then
            if entry.drawing then entry.drawing:Remove() end
            DomainHealthESPState.drawings[key] = nil
        end
    end
end

local function HasChooseUI()
    return SafeFind(LocalPlayer, "PlayerGui", "Domain", "Choose") ~= nil
end

local function FindPlayerDomain()
    local domains = workspace:FindFirstChild("Domains")
    if not domains then return nil end
    for _, domain in ipairs(domains:GetChildren()) do
        local owner = domain:FindFirstChild("Owner")
        if owner and owner.Value == LocalPlayer.Name then return domain end
    end
    return nil
end

local function GetDomainVotes(domain)
    if not domain then return 0, 0, 0 end
    local c = domain:FindFirstChild("Confess")
    local s = domain:FindFirstChild("Silence")
    local d = domain:FindFirstChild("Denial")
    return (c and tonumber(c.Value) or 0),
           (s and tonumber(s.Value) or 0),
           (d and tonumber(d.Value) or 0)
end

local function CreateVoteDrawings()
    local function make(color)
        local d = Drawing.new("Text")
        d.Font = Drawing.Fonts.SystemBold; d.Size = 18
        d.Color = color; d.Outline = true; d.Center = true; d.Visible = false
        return d
    end
    DomainState.confessDrawing = make(Color3.fromRGB(100, 255, 100))
    DomainState.silenceDrawing = make(Color3.fromRGB(255, 255, 100))
    DomainState.denialDrawing  = make(Color3.fromRGB(255, 100, 100))
end

local function PositionVoteDrawings()
    local cam = workspace.CurrentCamera
    local vp  = cam and cam.ViewportSize or Vector2.new(1280, 720)
    local cx, cy = vp.X / 2, vp.Y / 2
    if DomainState.confessDrawing then
        DomainState.confessDrawing.Position = Vector2.new(cx - 120, cy - 40)
        DomainState.confessDrawing.Visible  = true
    end
    if DomainState.silenceDrawing then
        DomainState.silenceDrawing.Position = Vector2.new(cx, cy - 40)
        DomainState.silenceDrawing.Visible  = true
    end
    if DomainState.denialDrawing then
        DomainState.denialDrawing.Position = Vector2.new(cx + 120, cy - 40)
        DomainState.denialDrawing.Visible  = true
    end
end

local function UpdateVoteDisplay(c, s, d)
    if DomainState.confessDrawing then DomainState.confessDrawing.Text = "Confess: " .. c end
    if DomainState.silenceDrawing  then DomainState.silenceDrawing.Text  = "Silence: "  .. s end
    if DomainState.denialDrawing   then DomainState.denialDrawing.Text   = "Denial: "   .. d end
end

local function ResetDomainState()
    DomainState.isActive             = false
    DomainState.trackedDomain        = nil
    DomainState.waitingForChooseUI   = false
    if DomainState.confessDrawing then DomainState.confessDrawing.Visible = false end
    if DomainState.silenceDrawing  then DomainState.silenceDrawing.Visible  = false end
    if DomainState.denialDrawing   then DomainState.denialDrawing.Visible   = false end
    DomainState.confessCount = 0
    DomainState.silenceCount = 0
    DomainState.denialCount  = 0
end

local function ProcessDomainVotes()
    if not CONFIG.domainVotes.enabled then return end
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
    local curr = first; local maxIter = 64; local iter = 0
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
            headOfHeiEquippedNotified = true
        end
    else headOfHeiEquippedNotified = false end
    if charlesEquipped then
        if _G.AutoCounter_Enabled and not charlesEquippedNotified then
            charlesEquippedNotified = true
        end
    else charlesEquippedNotified = false end
    local hasLucky = checkForLuckyCoward()
    if hasLucky ~= luckyCowardEquipped then
        luckyCowardEquipped = hasLucky
        if not luckyCowardEquipped then luckyCowardEquippedNotified = false end
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
    if isOnCD ~= charlesLastState then charlesLastState = isOnCD end
    charlesOnCooldown = isOnCD
    return not isOnCD
end

local blockTriggered = false
local dashTriggered  = false
local blockStart     = 0
local dashStart      = 0

-- ════════════════════════════════════════════════════════════════
--  MATCHA UI
-- ════════════════════════════════════════════════════════════════

UI.AddTab("Defense", function(tab)
    local def = tab:Section("Auto Defense", "Left")
    def:Toggle("auto_block",     "Auto Block",       false, function(v) _G.AutoBlock_Enabled        = v end)
    def:Toggle("auto_blockdash", "Auto Block Dash",  false, function(v) _G.AutoBlockDash_Enabled    = v end)
    def:Toggle("auto_counter",   "Auto Counter",     false, function(v)
        _G.AutoCounter_Enabled = v
        if v then task.spawn(function() task.wait(0.5) checkEquippedAbilities() end) end
    end)
    def:Toggle("awaken_counter", "Awakening Counter", false, function(v)
        _G.AwakeningCounter_Enabled = v
        if v then task.spawn(function() task.wait(0.5) checkEquippedAbilities() end) end
    end)

    local cfg = tab:Section("Config", "Right")
    cfg:SliderInt("block_range", "Block Range",  1, 30, 8,  function(v) BLOCK_RANGE     = v end)
    cfg:SliderInt("dash_range",  "Dash Range",   1, 30, 15, function(v) DASH_RANGE      = v end)
    cfg:SliderFloat("hold_time", "Hold Time", 0.05, 1.0, 0.25, "%.2f", function(v) BLOCK_HOLD_TIME = v end)
end)

UI.AddTab("Automation", function(tab)
    local qte = tab:Section("Defense Attorney (Auto QTE)", "Left")
    qte:Toggle("auto_qte", "Auto QTE", false, function(v) CONFIG.autoQTE.enabled = v end)
    qte:SliderFloat("qte_delay",     "Post Press Delay", 0.0, 1.0, 0.30, "%.2f", function(v) CONFIG.autoQTE.postPressDelay = v end)
    qte:SliderFloat("qte_deviation", "Deviation",        0.0, 0.3, 0.0,  "%.2f", function(v) CONFIG.autoQTE.deviation      = v end)

    local ratio = tab:Section("Nanami (Ratio QTE)", "Left")
    ratio:Toggle("auto_ratio", "Auto Ratio QTE", false, function(v)
        CONFIG.ratioQTE.enabled = v
        if not v then
            RatioState.trackedTarget     = nil
            RatioState.trackedRatioValue = nil
            RatioState.isScanning        = false
            RatioState.hasTriggered      = false
        end
    end)
    ratio:SliderFloat("ratio_base",  "Base Delay",   0.1, 2.0, 0.60, "%.2f", function(v) CONFIG.ratioQTE.baseDelay   = v end)
    ratio:SliderFloat("ratio_min",   "Min Delay",    0.1, 1.0, 0.40, "%.2f", function(v) CONFIG.ratioQTE.minDelay    = v end)
    ratio:SliderFloat("ratio_floor", "Health Floor", 0.1, 1.0, 0.60, "%.2f", function(v) CONFIG.ratioQTE.healthFloor = v end)

    local swap = tab:Section("Todo (Perfect Swap)", "Right")
    swap:Toggle("auto_swap", "Auto Perfect Swap", false, function(v)
        CONFIG.perfectSwap.enabled = v
        if not v then ResetSwapState() end
    end)
    swap:SliderFloat("swap_timeout", "Scan Timeout", 0.5, 5.0, 2.0, "%.1f", function(v) CONFIG.perfectSwap.scanTimeout = v end)

    local chara = tab:Section("Chara QTE", "Right")
    chara:Toggle("auto_chara", "Auto Chara QTE", false, function(v)
        CONFIG.charaQTE.enabled = v
        if not v then CharaQTEState.active = false end
    end)

    local domain = tab:Section("Hiromi (Domain Votes)", "Right")
    domain:Toggle("domain_votes", "Vote Tracker", false, function(v)
        CONFIG.domainVotes.enabled = v
        if not v then ResetDomainState() end
    end)
end)

UI.AddTab("ESP", function(tab)
    local esp = tab:Section("Item / Dummy ESP", "Left")
    esp:Toggle("esp_on",       "Enable ESP",  false, function(v)
        CONFIG.esp.enabled = v
        if not v then for _, e in pairs(ESPState.objects) do espHide(e) end end
    end)
    esp:Toggle("esp_dummy",    "Dummy ESP",   true,  function(v) CONFIG.esp.dummy    = v end)
    esp:Toggle("esp_items",    "Items ESP",   true,  function(v) CONFIG.esp.items    = v end)
    esp:Toggle("esp_box",      "Box",         true,  function(v) CONFIG.esp.box      = v end)
    esp:Toggle("esp_name",     "Name",        true,  function(v) CONFIG.esp.name     = v end)
    esp:Toggle("esp_distance", "Distance",    true,  function(v) CONFIG.esp.distance = v end)
    esp:Toggle("esp_traceline","Traceline",   false, function(v) CONFIG.esp.traceline= v end)
    esp:SliderInt("esp_fps",   "Update FPS",  10, 120, 60, function(v) CONFIG.esp.updateRate = v end)

    local dhp = tab:Section("Domain Health ESP", "Right")
    dhp:Toggle("domain_hp_esp", "Domain Health ESP", false, function(v)
        CONFIG.domainHealthESP.enabled = v
        if not v then
            for _, entry in pairs(DomainHealthESPState.drawings) do
                if entry.drawing then entry.drawing.Visible = false end
            end
        end
    end)
    dhp:SliderInt("domain_threshold", "Nearby Threshold", 5, 200, 40, function(v) CONFIG.domainHealthESP.nearbyThreshold = v end)
end)

-- ════════════════════════════════════════════════════════════════
--  LOOPS
-- ════════════════════════════════════════════════════════════════

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
                if getCurrentAnimFromChar(p.Character, BlockMode) then blockAnimPlayer = p end
            end
            if dist <= DASH_RANGE and not dashAnimPlayer then
                if getCurrentAnimFromChar(p.Character, DashMode) then dashAnimPlayer = p end
            end
            if blockAnimPlayer and dashAnimPlayer then break end
        end

        if _G.AwakeningCounter_Enabled and isUltimateReady() and (headOfHeiEquipped or charlesEquipped) then
            if blockAnimPlayer or dashAnimPlayer then
                keypress(KEY_G); keyrelease(KEY_G)
                if blockTriggered then keyrelease(KEY_F); blockTriggered = false end
                if dashTriggered  then keyrelease(KEY_F); dashTriggered  = false end
                continue
            end
        end

        if _G.AutoCounter_Enabled then
            local counterAvailable = luckyCowardEquipped or (charlesEquipped and charlesReady)
            if counterAvailable and (blockAnimPlayer or dashAnimPlayer) then
                if luckyCowardEquipped then
                    mouse1click()
                elseif charlesEquipped and charlesReady and currentTime - lastCharlesTime > CHARLES_COOLDOWN then
                    keypress(KEY_3); keyrelease(KEY_3)
                    lastCharlesTime = currentTime
                end
                if blockTriggered then keyrelease(KEY_F); blockTriggered = false end
                if dashTriggered  then keyrelease(KEY_F); dashTriggered  = false end
                continue
            end
        end

        if _G.AutoBlockDash_Enabled and dashAnimPlayer then
            if not dashTriggered then
                dashTriggered = true; dashStart = tick(); keypress(KEY_F)
            end
            if tick() - dashStart >= BLOCK_HOLD_TIME then
                keyrelease(KEY_F); mouse1click(); dashTriggered = false
            end
            continue
        end

        if _G.AutoBlock_Enabled and blockAnimPlayer then
            if not blockTriggered then
                blockTriggered = true; blockStart = tick(); keypress(KEY_F)
            end
            if tick() - blockStart >= BLOCK_HOLD_TIME then
                keyrelease(KEY_F); mouse1click(); blockTriggered = false
            end
            continue
        end

        if blockTriggered then keyrelease(KEY_F); blockTriggered = false end
        if dashTriggered  then keyrelease(KEY_F); dashTriggered  = false end
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

task.spawn(function() while running do pcall(UpdateESPPositions)  pcall(UpdateDomainHealthESP) task.wait(1 / math.max(1, CONFIG.esp.updateRate)) end end)
task.spawn(function() while running do pcall(DiscoverESPObjects)  task.wait(0.5)  end end)
task.spawn(function() while running do pcall(ProcessRatioQTE)     task.wait(0.016) end end)
task.spawn(function() while running do pcall(ProcessPerfectSwap)  task.wait(0.01)  end end)
task.spawn(function() while running do pcall(RunCharaQTE)         task.wait(0.2)   end end)
task.spawn(function() while running do pcall(ProcessDomainVotes)  task.wait(0.05)  end end)
task.spawn(function() while running do currentPing = GetPing()    task.wait(1)     end end)
