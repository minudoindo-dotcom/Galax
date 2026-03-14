-- =============================================
--         Galax Hub Loader
--         macOS style + Whitelist
-- =============================================

local GAMES_URL     = "https://raw.githubusercontent.com/minudoindo-dotcom/Galax/refs/heads/main/BetaID.lua"
local WHITELIST_URL = "https://raw.githubusercontent.com/minudoindo-dotcom/Galax/refs/heads/main/BetaProfile.lua"

local LOADER_TITLE     = "Galax Hub"
local LOADER_SUBTITLE  = "Loading..."
local BAR_DURATION     = 5
local INITIAL_WAIT     = 1
local RESULT_HOLD_TIME = 2
local ANIM_DELAY       = 0.014
local DRIFT_SPEED      = 12

-- macOS dark palette
local C_BG      = Color3.fromRGB(28,  28,  30)
local C_BG2     = Color3.fromRGB(38,  38,  42)
local C_BORDER  = Color3.fromRGB(60,  60,  67)
local C_ACCENT  = Color3.fromRGB(10,  132, 255)
local C_OK      = Color3.fromRGB(48,  209, 88)
local C_FAIL    = Color3.fromRGB(255, 69,  58)
local C_TEXT    = Color3.fromRGB(255, 255, 255)
local C_SUBTEXT = Color3.fromRGB(152, 152, 157)
local C_BLACK   = Color3.new(0, 0, 0)
local C_WHITE   = Color3.new(1, 1, 1)

local C_DOT_RED = Color3.fromRGB(255, 95,  86)
local C_DOT_YEL = Color3.fromRGB(255, 189, 46)
local C_DOT_GRN = Color3.fromRGB(39,  201, 63)

-- =============================================
-- HELPERS
-- =============================================
local function lerp(a, b, t) return a + (b - a) * t end
local function clamp(x, a, b) return x > b and b or (x < a and a or x) end
local function lerpColor(c1, c2, t) return Color3.new(lerp(c1.R, c2.R, t), lerp(c1.G, c2.G, t), lerp(c1.B, c2.B, t)) end
local function easeOutExpo(t) return t == 0 and 0 or 1 - 2 ^ (-10 * t) end
local function easeInExpo(t) return t == 0 and 0 or 2 ^ (10 * t - 10) end
local function easeOutBack(t) local c1 = 1.70158; local c3 = c1 + 1; return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2 end
local function easeOutQuad(t) return 1 - (1 - t) * (1 - t) end
local function easeInQuad(t) return t * t end

local function getScreen()
    local cam = workspace.CurrentCamera
    return (cam and cam.ViewportSize) and cam.ViewportSize or Vector2.new(1920, 1080)
end

local function newSquare(props)
    local d = Drawing.new("Square")
    d.Filled = true; d.Visible = false
    for k, v in pairs(props or {}) do d[k] = v end
    return d
end

local function newText(props)
    local d = Drawing.new("Text")
    d.Visible = false; d.Outline = false; d.Font = Drawing.Fonts.SystemBold
    for k, v in pairs(props or {}) do d[k] = v end
    return d
end

local function newCircle(props)
    local d = Drawing.new("Circle")
    d.Filled = true; d.Visible = false
    for k, v in pairs(props or {}) do d[k] = v end
    return d
end

-- =============================================
-- FETCH GAME LIST FROM GITHUB
-- =============================================
GalaxHubGames = nil
local ok1 = pcall(function()
    local raw = game:HttpGet(GAMES_URL)
    local fn  = loadstring(raw)
    if fn then fn() end
end)
local SupportedGames = GalaxHubGames or {}
-- =============================================
-- FETCH WHITELIST FROM GITHUB
-- =============================================
GalaxHubWhitelist = nil
local ok2 = pcall(function()
    local fn = loadstring(game:HttpGet(WHITELIST_URL))
    if fn then fn() end
end)
local Whitelist = GalaxHubWhitelist or {}

-- Check current player against whitelist
local localName = ""
local lpOk = pcall(function()
    localName = game:GetService("Players").LocalPlayer.Name
end)

local isWhitelisted = false
for _, name in ipairs(Whitelist) do
    if tostring(name):lower() == localName:lower() then
        isWhitelisted = true
        break
    end
end

-- =============================================
-- SETUP
-- =============================================
task.wait(INITIAL_WAIT)

local screen = getScreen()
local sw, sh = screen.X, screen.Y
local cx, cy = sw / 2, sh / 2
local PW, PH, CR = 380, 148, 14
local BAR_W, BAR_H = PW - 48, 4

-- =============================================
-- PARTICLE DATA
-- =============================================
local PARTICLE_COUNT = 26
math.randomseed(777)

local pData = {}
local particles = {}

for i = 1, PARTICLE_COUNT do
    local base  = (i / PARTICLE_COUNT) * math.pi * 2
    local angle = base + (math.random() - 0.5) * 0.55
    local dist  = 120 + math.random() * 220
    local tx, ty = cx + math.cos(angle) * dist, cy + math.sin(angle) * dist
    local r = 2 + math.random() * 4
    local baseTr = 0.42 + math.random() * 0.44

    local roll = math.random()
    local col
    if roll > 0.80 then col = C_ACCENT elseif roll > 0.62 then col = Color3.fromRGB(160, 200, 255) else col = C_WHITE end

    pData[i] = { tx = tx, ty = ty, r = r, baseTr = baseTr, col = col, angle = angle }

    particles[i] = newCircle({
        Color = col, Radius = r, Transparency = 1, ZIndex = 91, NumSides = 16,
        Position = Vector2.new(cx, cy), Visible = false,
    })
end

local function explodeParticles(t)
    local eased = easeOutQuad(clamp(t, 0, 1))
    for i, p in ipairs(particles) do
        local pd = pData[i]
        local alpha = eased
        p.Position = Vector2.new(lerp(cx, pd.tx, eased), lerp(cy, pd.ty, eased))
        p.Transparency = pd.baseTr * alpha
        p.Visible = alpha > 0.05
    end
end

local function implodeParticles(t)
    local eased = easeInQuad(clamp(t, 0, 1))
    for i, p in ipairs(particles) do
        local pd = pData[i]
        local alpha = 1 - eased
        p.Position = Vector2.new(lerp(pd.tx, cx, eased), lerp(pd.ty, cy, eased))
        p.Transparency = pd.baseTr * alpha
        p.Visible = alpha > 0.05
    end
end

-- =============================================
-- UI DRAWINGS
-- =============================================
local overlay = newSquare({ Color = C_BLACK, Position = Vector2.new(0, 0), Size = Vector2.new(sw, sh), Transparency = 0, ZIndex = 90, Visible = true })
local shadows = {}
for i = 1, 3 do shadows[i] = newSquare({ Color = C_BLACK, Transparency = 0, ZIndex = 92, Corner = CR + i * 2 }) end
local panel = newSquare({ Color = C_BG, Transparency = 0, ZIndex = 93, Corner = CR })
local panelBorder = Drawing.new("Square")
panelBorder.Filled = false; panelBorder.Color = C_BORDER; panelBorder.Thickness = 1
panelBorder.Transparency = 0; panelBorder.ZIndex = 94; panelBorder.Corner = CR; panelBorder.Visible = false
local dots = {}
local dotColors = { C_DOT_RED, C_DOT_YEL, C_DOT_GRN }
for i = 1, 3 do dots[i] = newCircle({ Color = dotColors[i], Radius = 5, Transparency = 0, ZIndex = 95, NumSides = 32 }) end
local separator = newSquare({ Color = C_BORDER, Transparency = 0, ZIndex = 95 })
local appIcon = newSquare({ Color = C_ACCENT, Transparency = 0, ZIndex = 95, Corner = 8 })
local appIconText = newText({ Text = "G", Color = C_TEXT, Size = 16, Center = true, Transparency = 0, ZIndex = 96 })
local titleDraw = newText({ Text = LOADER_TITLE, Color = C_TEXT, Size = 15, Transparency = 0, ZIndex = 96 })
local statusDraw = newText({ Text = LOADER_SUBTITLE, Color = C_SUBTEXT, Size = 12, Transparency = 0, ZIndex = 96 })
local barBg = newSquare({ Color = C_BG2, Transparency = 0, ZIndex = 95, Corner = 2 })
local barFill = newSquare({ Color = C_ACCENT, Transparency = 0, ZIndex = 96, Corner = 2 })

local function layout(scale, opacity)
    local w, h = PW * scale, PH * scale
    local px, py = cx - w / 2, cy - h / 2

    for i, s in ipairs(shadows) do
        local off = i * 6 * scale
        s.Position = Vector2.new(px - off / 2, py + off * 0.6)
        s.Size = Vector2.new(w + off, h + off * 0.3)
        s.Transparency = opacity * (0.38 - i * 0.1)
        s.Visible = opacity > 0.05
    end

    panel.Position, panel.Size, panel.Transparency, panel.Visible = Vector2.new(px, py), Vector2.new(w, h), opacity, opacity > 0.05
    panelBorder.Position, panelBorder.Size, panelBorder.Transparency, panelBorder.Visible = Vector2.new(px, py), Vector2.new(w, h), opacity * 0.6, opacity > 0.05

    local titleBarH = 30 * scale
    local dotY, dotX0 = py + titleBarH / 2, px + 16 * scale
    for i, dot in ipairs(dots) do
        dot.Position, dot.Radius, dot.Transparency, dot.Visible = Vector2.new(dotX0 + (i - 1) * 16 * scale, dotY), 5 * scale, opacity * 0.15, opacity > 0.05
    end

    separator.Position, separator.Size, separator.Transparency, separator.Visible = Vector2.new(px, py + titleBarH), Vector2.new(w, 1), opacity * 0.6, opacity > 0.05

    local contentY, iconSize, iconX = py + titleBarH + 18 * scale, 36 * scale, px + 24 * scale
    appIcon.Position, appIcon.Size, appIcon.Transparency, appIcon.Visible = Vector2.new(iconX, contentY), Vector2.new(iconSize, iconSize), opacity, opacity > 0.05
    appIconText.Position, appIconText.Transparency, appIconText.Visible = Vector2.new(iconX + iconSize / 2, contentY + iconSize / 2 - 9), opacity, opacity > 0.05

    local textX = iconX + iconSize + 10 * scale
    titleDraw.Position, titleDraw.Transparency, titleDraw.Visible = Vector2.new(textX, contentY + 4 * scale), opacity, opacity > 0.05
    statusDraw.Position, statusDraw.Transparency, statusDraw.Visible = Vector2.new(textX, contentY + 20 * scale), opacity, opacity > 0.05

    local barY, barX, bw = py + h - 28 * scale, px + 24 * scale, BAR_W * scale
    barBg.Position, barBg.Size, barBg.Transparency, barBg.Visible = Vector2.new(barX, barY), Vector2.new(bw, BAR_H * scale), opacity, opacity > 0.05
    barFill.Position, barFill.Size, barFill.Transparency, barFill.Visible = Vector2.new(barX, barY), Vector2.new(barFill.Size.X, BAR_H * scale), opacity, opacity > 0.05
end

-- =============================================
-- ANIMATIONS
-- =============================================
local STEPS_FADE, STEPS_PANEL, STEPS_BURST, STEPS_CLOSE = 25, 30, 35, 30

-- 1. FADE IN
overlay.Visible = true
for i = 1, STEPS_FADE do
    overlay.Transparency = lerp(0, 0.65, easeOutExpo(i / STEPS_FADE))
    task.wait(ANIM_DELAY)
end
overlay.Transparency = 0.65

-- 2. PANEL ENTERS
for i = 1, STEPS_PANEL do
    local t = i / STEPS_PANEL
    layout(easeOutBack(t), easeOutExpo(t))
    task.wait(ANIM_DELAY)
end
layout(1, 1); barFill.Size = Vector2.new(0, BAR_H)

-- 3. EXPLOSION
task.spawn(function()
    for i = 1, STEPS_BURST do
        explodeParticles(i / STEPS_BURST)
        task.wait(ANIM_DELAY)
    end
    explodeParticles(1)
end)

-- 4. BAR LOADING
-- If not whitelisted, we don't even check game — result is already decided
local currentId, foundScript = tostring(game.PlaceId), nil

if isWhitelisted then
    for _, gameData in ipairs(SupportedGames) do
        for _, id in ipairs(gameData.ids) do
            if tostring(id) == currentId then foundScript = gameData.script; break end
        end
        if foundScript then break end
    end
end

local elapsed, dt = 0, 0.033
local burst_duration = STEPS_BURST * ANIM_DELAY

while elapsed < BAR_DURATION do
    elapsed = elapsed + dt
    local progress = clamp(elapsed / BAR_DURATION, 0, 1)

    for i, p in ipairs(particles) do
        local pd = pData[i]
        pd.tx = pd.tx + math.cos(pd.angle) * DRIFT_SPEED * dt
        pd.ty = pd.ty + math.sin(pd.angle) * DRIFT_SPEED * dt
        if elapsed > burst_duration then
            p.Position = Vector2.new(pd.tx, pd.ty)
        end
    end

    if progress > 0.85 then
        local t = (progress - 0.85) / 0.15
        if not isWhitelisted then
            -- not a supporter: red bar
            barFill.Color = lerpColor(C_ACCENT, C_FAIL, t)
            appIcon.Color = lerpColor(C_ACCENT, C_FAIL, t)
        elseif foundScript then
            barFill.Color = lerpColor(C_ACCENT, C_OK, t)
            appIcon.Color = lerpColor(C_ACCENT, C_OK, t)
        else
            barFill.Color = lerpColor(C_ACCENT, C_FAIL, t)
            appIcon.Color = lerpColor(C_ACCENT, C_FAIL, t)
        end
    end

    barFill.Size = Vector2.new(BAR_W * progress, BAR_H)
    task.wait(dt)
end
barFill.Size = Vector2.new(BAR_W, BAR_H)

-- 4.5 RESULT MESSAGE
if not isWhitelisted then
    statusDraw.Text  = "Go get Supporter bud it's only 100 Robux"
    statusDraw.Color = C_FAIL
    barFill.Color    = C_FAIL
    appIcon.Color    = C_FAIL
elseif foundScript then
    statusDraw.Text  = "Game Found!"
    statusDraw.Color = C_OK
else
    statusDraw.Text  = "Game Not Found"
    statusDraw.Color = C_FAIL
end

-- 4.6. DRIFT DURING RESULT HOLD
local resultElapsed = 0
while resultElapsed < RESULT_HOLD_TIME do
    resultElapsed = resultElapsed + dt
    for i, p in ipairs(particles) do
        local pd = pData[i]
        pd.tx = pd.tx + math.cos(pd.angle) * DRIFT_SPEED * dt
        pd.ty = pd.ty + math.sin(pd.angle) * DRIFT_SPEED * dt
        p.Position = Vector2.new(pd.tx, pd.ty)
    end
    task.wait(dt)
end

-- 5. IMPLOSION
task.spawn(function()
    for i = 1, STEPS_BURST do
        implodeParticles(i / STEPS_BURST)
        task.wait(ANIM_DELAY)
    end
    for _, p in ipairs(particles) do if p then p.Visible = false end end
end)

-- 6. PANEL EXITS
for i = 1, STEPS_CLOSE do
    local ease = easeInExpo(i / STEPS_CLOSE)
    layout(1 - ease * 0.15, 1 - ease)
    task.wait(ANIM_DELAY)
end
layout(0, 0)

local diff = STEPS_BURST - STEPS_CLOSE
if diff > 0 then task.wait(diff * ANIM_DELAY) end

for _, s in ipairs(shadows) do s.Visible = false end
panel.Visible, panelBorder.Visible, separator.Visible, appIcon.Visible, appIconText.Visible = false, false, false, false, false
for _, d in ipairs(dots) do d.Visible = false end
titleDraw.Visible, statusDraw.Visible, barBg.Visible, barFill.Visible = false, false, false, false

-- 7. FADE OUT
for i = 1, STEPS_FADE do
    overlay.Transparency = lerp(0.65, 0, easeInExpo(i / STEPS_FADE))
    task.wait(ANIM_DELAY)
end
overlay.Transparency, overlay.Visible = 0, false

-- =============================================
-- CLEANUP
-- =============================================
overlay:Remove()
for _, s in ipairs(shadows) do s:Remove() end
panel:Remove(); panelBorder:Remove(); separator:Remove()
for _, d in ipairs(dots) do d:Remove() end
appIcon:Remove(); appIconText:Remove(); titleDraw:Remove(); statusDraw:Remove(); barBg:Remove(); barFill:Remove()
for _, p in ipairs(particles) do p:Remove() end

-- =============================================
-- EXECUTE GAME SCRIPT (only if whitelisted + game found)
-- =============================================
if isWhitelisted and foundScript then
    loadstring(foundScript)()
end
