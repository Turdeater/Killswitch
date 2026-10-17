-- Babylon (safe loader): runs the full script and, if the executor cannot compile or run it,
-- shows the exact reason in a red box on screen (and in the F9 console) instead of silently doing nothing.
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
print("[Babylon loader] started")

local function report(msg)
	warn("[Babylon loader] " .. msg)
	pcall(function()
		local gui = Instance.new("ScreenGui")
		gui.Name = "BabylonLoaderError"
		gui.ResetOnSpawn = false
		gui.DisplayOrder = 999
		gui.Parent = lp:WaitForChild("PlayerGui", 10)
		local box = Instance.new("TextLabel")
		box.AnchorPoint = Vector2.new(0.5, 0)
		box.Position = UDim2.new(0.5, 0, 0.1, 0)
		box.Size = UDim2.new(0, 640, 0, 160)
		box.BackgroundColor3 = Color3.fromRGB(90, 20, 20)
		box.TextColor3 = Color3.new(1, 1, 1)
		box.Font = Enum.Font.GothamMedium
		box.TextSize = 14
		box.TextWrapped = true
		box.Text = "Babylon could not start:\n" .. msg
		box.Parent = gui
		task.delay(40, function() gui:Destroy() end)
	end)
end

if not loadstring then
	report("this executor has no loadstring")
	return
end

local SRC = [==[

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local KS = {
url = "https://raw.githubusercontent.com/Turdeater/Killswitch/main/switch.txt",
strict = false,  -- true = also refuse to run when the link cannot be reached (safer, but breaks offline / no-HTTP executors)
recheck = 60,    -- seconds between checks while the script is running
exempt = {
[1408310551] = true, -- Danielhail2009
[271644981] = true,  -- Kazhauzx (Hinazuki)
},
}

function KS.notice(text)
pcall(function()
local gui = Instance.new("ScreenGui")
gui.Name = "BabylonNotice"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 10)
local box = Instance.new("TextLabel")
box.AnchorPoint = Vector2.new(0.5, 0)
box.Position = UDim2.new(0.5, 0, 0.1, 0)
box.Size = UDim2.new(0, 420, 0, 60)
box.BackgroundColor3 = Color3.fromRGB(90, 20, 20)
box.TextColor3 = Color3.new(1, 1, 1)
box.Font = Enum.Font.GothamMedium
box.TextSize = 15
box.TextWrapped = true
box.Text = text
box.Parent = gui
task.delay(8, function() gui:Destroy() end)
end)
end

function KS.check()
if KS.url == "" or KS.exempt[lp.UserId] then return "on" end
local url = KS.url .. (KS.url:find("?", 1, true) and "&" or "?") .. "t=" .. tostring(os.time())
local body, done = nil, false
task.spawn(function()
pcall(function() body = game:HttpGet(url) end)
if type(body) ~= "string" then
local req = (syn and syn.request) or http_request or request
if req then
local ok, res = pcall(req, { Url = url, Method = "GET" })
if ok and type(res) == "table" then body = res.Body end
end
end
done = true
end)
local waited = 0
while not done and waited < 8 do
task.wait(0.1)
waited += 0.1
end
local word = type(body) == "string" and body:lower():match("^%s*(%a+)") or nil
if word == "on" then return "on" end
if word == "off" then return "off" end
return KS.strict and "off" or "unknown"
end

print("[Babylon] checking kill switch")
if KS.check() == "off" then
warn("[Babylon] switched off by its owner")
KS.notice("Babylon is switched off by its owner.")
return
end

for _, name in ipairs({ "BabylonAll", "FloatGuns", "BringGuns", "SellAll", "OpenShop", "BabylonSpeed", "BabylonESP", "BabylonJump", "BabylonDefense", "BabylonCrosshair" }) do
local old = getgenv()[name]
if old and old.stop then pcall(old.stop) end
end

print("[Babylon] script started")
local uiParent = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 10)
if not uiParent and gethui then
local okHui, hui = pcall(gethui)
if okHui and typeof(hui) == "Instance" then uiParent = hui end
end
local ui = Instance.new("ScreenGui")
ui.Name = "BabylonUI"
ui.ResetOnSpawn = false
ui.IgnoreGuiInset = true
ui.DisplayOrder = 999
ui.Parent = uiParent

task.spawn(function()
for _ = 1, 30 do
task.wait(0.1)
local b = ui:FindFirstChild("Badge")
if b and b.AbsoluteSize.X > 0 then
if b.AbsolutePosition.Y < 5 then ui.IgnoreGuiInset = false end
break
end
end
end)

local badge = Instance.new("TextLabel")
badge.Name = "Badge"
badge.AnchorPoint = Vector2.new(0, 0)
badge.Position = UDim2.new(0, 10, 0, 10)
badge.Size = UDim2.new(0, 330, 0, 26)
badge.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
badge.BackgroundTransparency = 0.1
badge.TextColor3 = Color3.fromRGB(180, 235, 255)
badge.Font = Enum.Font.GothamMedium
badge.TextSize = 14
badge.Text = "Babylon injected   G wall   P shop   U sell   K bring"
badge.Visible = false -- shown once the intro has finished
badge.Parent = ui
Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 8)
do
local st = Instance.new("UIStroke")
st.Color = Color3.fromRGB(138, 99, 255)
st.Thickness = 1.2
st.Transparency = 0.2
st.Parent = badge
end

local toastLabel = Instance.new("TextLabel")
toastLabel.Name = "Toast"
toastLabel.AnchorPoint = Vector2.new(0.5, 0)
toastLabel.Position = UDim2.new(0.5, 0, 0, 70)
toastLabel.Size = UDim2.new(0, 440, 0, 44)
toastLabel.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
toastLabel.BackgroundTransparency = 0.1
toastLabel.TextColor3 = Color3.new(1, 1, 1)
toastLabel.Font = Enum.Font.GothamMedium
toastLabel.TextSize = 17
toastLabel.TextWrapped = true
toastLabel.Visible = false
toastLabel.Parent = ui
Instance.new("UICorner", toastLabel).CornerRadius = UDim.new(0, 10)
do
local st = Instance.new("UIStroke")
st.Color = Color3.fromRGB(66, 214, 255)
st.Thickness = 1.2
st.Transparency = 0.25
st.Parent = toastLabel
end

local toastStamp = 0
local function toast(text)
print("[Babylon] " .. text)
toastStamp += 1
local mine = toastStamp
toastLabel.Text = text
toastLabel.Visible = true
task.delay(3.5, function()
if toastStamp == mine then toastLabel.Visible = false end
end)
end

local stops = {}

local TweenService = game:GetService("TweenService")
local ACCENT = Color3.fromRGB(138, 99, 255)  -- violet
local ACCENT2 = Color3.fromRGB(66, 214, 255) -- cyan
local CREDIT = 'Made by <font color="#9d7bff">Ace</font> <font color="#8a8aa8">&amp;</font> <font color="#4fd8ff">Hinazuki</font>'

local function tween(obj, time, props, style, dir)
local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
t:Play()
return t
end

local function accentGradient(parent, rotation)
local g = Instance.new("UIGradient")
g.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, ACCENT),
ColorSequenceKeypoint.new(0.5, ACCENT2),
ColorSequenceKeypoint.new(1, ACCENT),
})
g.Rotation = rotation or 0
g.Parent = parent
return g
end

local spinners = {}
local function spin(g, speed, owner) table.insert(spinners, { g = g, speed = speed, owner = owner }) end
do
local spinAcc = 0
local animConn = RunService.Heartbeat:Connect(function(dt)
spinAcc += dt
if spinAcc < 1 / 30 then return end
local step = spinAcc
spinAcc = 0
for i = #spinners, 1, -1 do
local sp = spinners[i]
if not sp.g.Parent or (sp.owner and not sp.owner:IsDescendantOf(game)) then
table.remove(spinners, i)
elseif not sp.owner or sp.owner.Visible then
sp.g.Rotation = (sp.g.Rotation + sp.speed * step) % 360
end
end
end)
table.insert(stops, function() animConn:Disconnect() end)
end

local splash = { active = false, progress = function() end, finish = function(cb) if cb then cb() end end }
local onIntroDone = function() end
do
local okIntro, errIntro = pcall(function()
local t0 = os.clock()
local root = Instance.new("CanvasGroup")
root.Name = "Intro"
root.Size = UDim2.new(1, 0, 1, 0)
root.BackgroundColor3 = Color3.new(1, 1, 1)
root.BorderSizePixel = 0
root.ZIndex = 200
root.Active = true
root.GroupTransparency = 1
root.Parent = ui
local bg = Instance.new("UIGradient")
bg.Color = ColorSequence.new(Color3.fromRGB(14, 10, 30), Color3.fromRGB(4, 4, 10))
bg.Rotation = 60
bg.Parent = root

local particles = {}
for i = 1, 30 do
local size = math.random(2, 5)
local f = Instance.new("Frame")
f.Size = UDim2.fromOffset(size, size)
f.BackgroundColor3 = (i % 2 == 0) and ACCENT or ACCENT2
f.BackgroundTransparency = 0.45 + math.random() * 0.45
f.BorderSizePixel = 0
f.ZIndex = 201
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(1, 0)
c.Parent = f
f.Parent = root
particles[i] = { f = f, x = math.random(), y = math.random(), v = 0.03 + math.random() * 0.07, sway = math.random() * 6.28 }
end

local function ring(size, thick, speed)
local r = Instance.new("Frame")
r.AnchorPoint = Vector2.new(0.5, 0.5)
r.Position = UDim2.new(0.5, 0, 0.5, -10)
r.Size = UDim2.fromOffset(size, size)
r.BackgroundTransparency = 1
r.ZIndex = 202
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(1, 0)
c.Parent = r
local st = Instance.new("UIStroke")
st.Thickness = thick
st.Color = Color3.new(1, 1, 1)
st.Parent = r
local g = Instance.new("UIGradient")
g.Color = ColorSequence.new(ACCENT, ACCENT2)
g.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0),
NumberSequenceKeypoint.new(0.35, 0.15),
NumberSequenceKeypoint.new(0.6, 1),
NumberSequenceKeypoint.new(1, 1),
})
g.Parent = st
spin(g, speed, root)
r.Parent = root
end
ring(360, 2, 150)
ring(300, 1, -220)

local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.new(0.5, 0, 0.5, -10)
card.Size = UDim2.fromOffset(520, 256)
card.BackgroundTransparency = 1
card.ZIndex = 210
card.Parent = root
local cardScale = Instance.new("UIScale")
cardScale.Scale = 0.92
cardScale.Parent = card
tween(cardScale, 0.9, { Scale = 1 }, Enum.EasingStyle.Quint)

local letters = {}
local word = "BABYLON"
for i = 1, #word do
local l = Instance.new("TextLabel")
l.Size = UDim2.fromOffset(50, 76)
l.Position = UDim2.fromOffset(85 + (i - 1) * 50, 24)
l.BackgroundTransparency = 1
l.Text = word:sub(i, i)
l.Font = Enum.Font.GothamBlack
l.TextSize = 60
l.TextColor3 = Color3.new(1, 1, 1)
l.TextTransparency = 1
l.ZIndex = 211
l.Parent = card
local g = accentGradient(l, 90)
spin(g, 70, root)
letters[i] = l
end

local function text(txt, y, size, font, color, h)
local t = Instance.new("TextLabel")
t.AnchorPoint = Vector2.new(0.5, 0)
t.Position = UDim2.new(0.5, 0, 0, y)
t.Size = UDim2.fromOffset(500, h or 22)
t.BackgroundTransparency = 1
t.Text = txt
t.Font = font
t.TextSize = size
t.TextColor3 = color
t.TextTransparency = 1
t.RichText = true
t.ZIndex = 211
t.Parent = card
return t
end
local sub = text("G A T E   O F   B A B Y L O N", 92, 13, Enum.Font.GothamMedium, Color3.fromRGB(150, 150, 182))
local credit = text(CREDIT, 204, 18, Enum.Font.GothamBold, Color3.new(1, 1, 1), 26)
local hint = text("RightShift opens the menu", 234, 12, Enum.Font.Gotham, Color3.fromRGB(110, 110, 140))
local status = text("Starting ...", 162, 12, Enum.Font.GothamMedium, Color3.fromRGB(170, 170, 200))

local div = Instance.new("Frame")
div.AnchorPoint = Vector2.new(0.5, 0)
div.Position = UDim2.new(0.5, 0, 0, 122)
div.Size = UDim2.fromOffset(0, 2)
div.BackgroundColor3 = Color3.new(1, 1, 1)
div.BorderSizePixel = 0
div.ZIndex = 211
div.Parent = card
local dg = accentGradient(div, 0)
dg.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 1),
NumberSequenceKeypoint.new(0.5, 0),
NumberSequenceKeypoint.new(1, 1),
})

local track = Instance.new("Frame")
track.AnchorPoint = Vector2.new(0.5, 0)
track.Position = UDim2.new(0.5, 0, 0, 144)
track.Size = UDim2.fromOffset(340, 6)
track.BackgroundColor3 = Color3.fromRGB(30, 28, 48)
track.BorderSizePixel = 0
track.BackgroundTransparency = 1
track.ZIndex = 211
track.Parent = card
local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(1, 0)
tc.Parent = track
local fill = Instance.new("Frame")
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.new(1, 1, 1)
fill.BorderSizePixel = 0
fill.ZIndex = 212
fill.Parent = track
local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(1, 0)
fc.Parent = fill
spin(accentGradient(fill, 0), 120, root)

tween(root, 0.5, { GroupTransparency = 0 })
for i, l in ipairs(letters) do
local x = l.Position.X.Offset
task.delay(0.3 + i * 0.08, function()
if l.Parent then tween(l, 0.5, { TextTransparency = 0, Position = UDim2.fromOffset(x, 0) }, Enum.EasingStyle.Back) end
end)
l.Position = UDim2.fromOffset(x, 24)
end
task.delay(1.0, function()
if not root.Parent then return end
tween(sub, 0.6, { TextTransparency = 0 })
tween(div, 0.8, { Size = UDim2.fromOffset(320, 2) }, Enum.EasingStyle.Quint)
tween(track, 0.5, { BackgroundTransparency = 0 })
tween(status, 0.5, { TextTransparency = 0 })
end)
task.delay(1.3, function()
if not root.Parent then return end
tween(credit, 0.8, { TextTransparency = 0 })
tween(hint, 0.8, { TextTransparency = 0.2 })
end)

local target, shown, statusText, finishCb, done = 0, 0, "Starting", nil, false
local conn
local function outro(cb)
done = true
task.spawn(function()
statusText = "Ready"
task.wait(0.4)
tween(cardScale, 0.7, { Scale = 1.1 }, Enum.EasingStyle.Quint)
tween(root, 0.6, { GroupTransparency = 1 })
task.wait(0.3)
pcall(cb)
task.wait(0.4)
if conn then conn:Disconnect() end
root:Destroy()
end)
end
conn = RunService.Heartbeat:Connect(function(dt)
local now = os.clock()
for _, pt in ipairs(particles) do
pt.y -= pt.v * dt
if pt.y < -0.05 then pt.y = 1.05 pt.x = math.random() end
pt.f.Position = UDim2.new(pt.x + math.sin(now * 0.6 + pt.sway) * 0.012, 0, pt.y, 0)
end
local cap = math.clamp((now - t0 - 0.6) / 2.2, 0, 1)
shown += (math.min(target, cap) - shown) * math.min(1, dt * 5)
if target >= 1 and cap >= 1 and shown > 0.985 then shown = 1 end
fill.Size = UDim2.new(shown, 0, 1, 0)
status.Text = statusText .. "   " .. math.floor(shown * 100 + 0.5) .. "%"
if finishCb and shown >= 1 and not done then
local cb = finishCb
finishCb = nil
outro(cb)
end
end)
table.insert(stops, function() if conn then conn:Disconnect() end end)

splash.progress = function(frac, txt)
target = math.clamp(frac, 0, 1)
if txt then statusText = txt end
end
splash.finish = function(cb)
target = 1
finishCb = cb or function() end
end
splash.active = true
end)
if not okIntro then
warn("[Babylon] intro screen failed: " .. tostring(errIntro))
local leftover = ui:FindFirstChild("Intro")
if leftover then leftover:Destroy() end
end
end

local loadErrors = {}
local MODULE_TOTAL = 11
local modulesDone = 0
local function run(name, fn)
print("[Babylon] loading " .. name)
badge.Text = "Babylon loading: " .. name .. " ..."
splash.progress(modulesDone / MODULE_TOTAL, "Loading " .. name)
local ok, err = pcall(fn)
if not ok then
table.insert(loadErrors, name .. ": " .. tostring(err))
warn("[Babylon] " .. name .. " failed to load: " .. tostring(err))
end
modulesDone += 1
splash.progress(modulesDone / MODULE_TOTAL, modulesDone >= MODULE_TOTAL and "Almost ready" or ("Loaded " .. name))
end

run("Gate", function()
local CFG = {
toggleKey = Enum.KeyCode.G,
maxGuns = math.huge, -- most guns that float at once (no cap by default)
staticArm = true,    -- keeps your right arm still while guns float
aimMode = "forward", -- "forward" | "crosshair" | "converge"
tilt = -8,
minPitch = -15,
maxPitch = 10,
fanAngle = 80,
minRadius = 9,
gunSpacing = 2,
gunsPerRow = 6,
maxRows = 5,
baseHeight = 4.5,
rowSpacing = 2.6,
lift = 2.5,
back = 2.5,
heldHeight = 4.4, -- where the gun you are holding floats
heldBack = 1.5,
bob = 0,
faceOffset = CFrame.Angles(0, math.pi, 0),
emote = "none",
emoteSpeed = 0.6,
emoteIds = { cheer = 129423030, wave = 128777973, point = 128853357 },
reloadAll = true,
noRecoil = true,
checkEvery = 0.5,
}

local isReal = (function()
local ok, name = pcall(function() return identifyexecutor and identifyexecutor() or "" end)
return ok and type(name) == "string" and name:lower():find("real", 1, true) ~= nil
end)()
local calmedObjs = setmetatable({}, { __mode = "k" })

local enabled = true
local userHeld = nil
local adopted = {}
local gunsState = {}
local track = nil
local conns = {}
local patchedRecoil = {}

local function connect(signal, fn)
local c = signal:Connect(fn)
table.insert(conns, c)
return c
end

local function char() return lp.Character end

local function isGun(t)
return typeof(t) == "Instance" and t:IsA("Tool") and t:FindFirstChild("FireEvent") ~= nil and t:FindFirstChild("Handle") ~= nil
end

local function gunsIn(container)
local list = {}
if container then
for _, t in ipairs(container:GetChildren()) do
if isGun(t) then table.insert(list, t) end
end
end
return list
end

local function allGuns()
local list = gunsIn(lp:FindFirstChild("Backpack"))
for _, t in ipairs(gunsIn(char())) do table.insert(list, t) end
return list
end

local function gripFor(tool)
local c = char()
local handle = tool:FindFirstChild("Handle")
local arm = c and c:FindFirstChild("Right Arm")
if not arm or not handle then return end
for _, d in ipairs(arm:GetChildren()) do
if d:IsA("Weld") and d.Name == "RightGrip" and d.Part1 == handle then return d end
end
end

local function restoreOne(tool)
local s = gunsState[tool]
if not s then return end
if s.grip and s.grip.Parent then
if s.part0 and s.part0.Parent then s.grip.Part0 = s.part0 end
s.grip.C0 = s.c0
end
local h = s.handle
if h and h.Parent then
h.Massless = s.massless
h.CanCollide = s.canCollide
h.AssemblyLinearVelocity = Vector3.zero
h.AssemblyAngularVelocity = Vector3.zero
end
gunsState[tool] = nil
end

local function releaseAdopted()
for tool in pairs(gunsState) do restoreOne(tool) end
local bp = lp:FindFirstChild("Backpack")
for tool in pairs(adopted) do
if tool.Parent == char() and bp then tool.Parent = bp end
end
table.clear(adopted)
end

local function stopEmote()
if track then
pcall(function() track:Stop(0.3) end)
track = nil
end
end

local function startEmote()
if track or CFG.emote == "none" then return end
local c = char()
local hum = c and c:FindFirstChildOfClass("Humanoid")
local animator = hum and hum:FindFirstChildOfClass("Animator")
local id = CFG.emoteIds[CFG.emote]
if not animator or not id then return end
local a = Instance.new("Animation")
a.AnimationId = "rbxassetid://" .. id
local ok, tr = pcall(function() return animator:LoadAnimation(a) end)
if not ok or not tr then return end
tr.Priority = Enum.AnimationPriority.Action4
track = tr
if CFG.emote == "point" then
tr.Looped = false
tr:Play(0.2)
task.spawn(function()
local t0 = os.clock()
while tr.Length == 0 and os.clock() - t0 < 3 do task.wait() end
task.wait(math.max(tr.Length * 0.95, 0.1))
if track == tr then tr:AdjustSpeed(0) end
end)
else
tr.Looped = true
tr:Play(0.3)
tr:AdjustSpeed(CFG.emoteSpeed)
end
end

local function calmRecoil(obj)
if type(obj) ~= "table" then return obj end
pcall(function()
if obj.run_connection then obj.run_connection:Disconnect() end
end)
obj.ApplyRecoil = function() end
obj.Fire = function() end
obj.FlinchFire = function() end
obj.Update = function() end
return obj
end

local function scanRecoil()
local list
if type(filtergc) == "function" then
local ok, res = pcall(filtergc, "table", { Keys = { "run_connection", "virtualRotation" } }, false)
if ok and type(res) == "table" then list = res end
end
if not list and type(getgc) == "function" then
local ok, res = pcall(getgc, true)
if ok and type(res) == "table" then list = res end
end
if not list then return 0 end
local n = 0
for _, v in ipairs(list) do
if type(v) == "table" and not calmedObjs[v] then
local ok, hit = pcall(function()
return typeof(rawget(v, "run_connection")) == "RBXScriptConnection" and rawget(v, "virtualRotation") ~= nil
end)
if ok and hit then
calmedObjs[v] = true
pcall(calmRecoil, v)
n += 1
end
end
end
return n
end

local function holdingGun()
local c = char()
if not c then return false end
for _, t in ipairs(c:GetChildren()) do
if t:IsA("Tool") and t:FindFirstChild("GunLocal") then return true end
end
return false
end

local function patchTool(tool)
if not CFG.noRecoil or not tool:IsA("Tool") then return end
if not isReal then return end -- handled by the scan loop below
task.spawn(function()
local gl = tool:WaitForChild("GunLocal", 5)
local mod = gl and gl:WaitForChild("Recoil", 5)
if not mod or not mod:IsA("ModuleScript") then return end
local ok, m = pcall(require, mod)
if ok and type(m) == "table" and type(m.new) == "function" and not patchedRecoil[m] and CFG.noRecoil then
local orig = m.new
patchedRecoil[m] = orig
m.new = function(...)
local obj = orig(...)
if CFG.noRecoil then pcall(calmRecoil, obj) end
return obj
end
end
end)
end

local function watchForRecoil(container)
if not container then return end
for _, t in ipairs(container:GetChildren()) do patchTool(t) end
connect(container.ChildAdded, patchTool)
end

watchForRecoil(lp:FindFirstChild("Backpack"))
if lp.Character then watchForRecoil(lp.Character) end
connect(lp.CharacterAdded, function(c)
watchForRecoil(c)
watchForRecoil(lp:WaitForChild("Backpack"))
end)

local function setNoRecoil(on)
CFG.noRecoil = on and true or false
if CFG.noRecoil then
for _, container in ipairs({ lp:FindFirstChild("Backpack"), lp.Character }) do
if container then
for _, t in ipairs(container:GetChildren()) do patchTool(t) end
end
end
else
for m, orig in pairs(patchedRecoil) do m.new = orig end
table.clear(patchedRecoil)
end
end

if not isReal then
local nextScan = 0
local wasHolding = false
connect(RunService.Heartbeat, function()
if not CFG.noRecoil then wasHolding = false return end
local holding = holdingGun()
local now = os.clock()
if holding and (not wasHolding or now >= nextScan) then
nextScan = now + (wasHolding and 1.5 or 0.3)
wasHolding = true
task.spawn(scanRecoil)
elseif not holding then
wasHolding = false
end
end)
end

local reloadConn = nil
local reloadWatching = nil
local reloadBusyUntil = 0
local function watchReload(tool)
if reloadWatching == tool then return end
if reloadConn then reloadConn:Disconnect() reloadConn = nil end
reloadWatching = tool
if not tool then return end
reloadConn = tool:GetAttributeChangedSignal("last_reload"):Connect(function()
if not CFG.reloadAll or not enabled then return end
if os.clock() < reloadBusyUntil then return end
reloadBusyUntil = os.clock() + 1
for _, other in ipairs(allGuns()) do
if other ~= tool then
local remote = other:FindFirstChild("ReloadEvent")
if remote then pcall(function() remote:FireServer() end) end
end
end
end)
table.insert(conns, reloadConn)
end

local rebinding = false
local rebindAt = nil
local function rebind(tool)
if rebinding or not tool then return end
local c = char()
local hum = c and c:FindFirstChildOfClass("Humanoid")
local bp = lp:FindFirstChild("Backpack")
if not hum or not bp or tool.Parent ~= c then return end
if os.clock() - (getgenv().__FloatGunsLastRebind or 0) < 5 then return end
getgenv().__FloatGunsLastRebind = os.clock()
rebinding = true
tool.Parent = bp
task.wait(0.1)
if tool.Parent == bp and hum.Health > 0 then tool.Parent = c end
task.wait(0.1)
rebinding = false
end

local function setEnabled(on)
if on == enabled then return end
enabled = on
if not on then
local keep = userHeld
releaseAdopted()
stopEmote()
userHeld = nil
if keep then task.delay(0.4, function() rebind(keep) end) end
end
toast("Gate of Babylon " .. (enabled and "ON" or "OFF"))
end

connect(UIS.InputBegan, function(input, processed)
if processed then return end
if input.KeyCode == CFG.toggleKey then setEnabled(not enabled) end
end)

connect(lp.CharacterRemoving, function()
userHeld = nil
track = nil
table.clear(adopted)
table.clear(gunsState)
end)

getgenv().FloatGuns = {
cfg = CFG,
toggle = function() setEnabled(not enabled) end,
set = setEnabled,
setEmote = function(name) CFG.emote = name stopEmote() end,
setAim = function(mode) CFG.aimMode = mode end,
held = function() return userHeld end,
isOn = function() return enabled end,
setNoRecoil = setNoRecoil,
stop = function()
for _, c in ipairs(conns) do c:Disconnect() end
table.clear(conns)
stopEmote()
releaseAdopted()
for m, orig in pairs(patchedRecoil) do m.new = orig end
getgenv().FloatGuns = nil
end,
}
table.insert(stops, function() if getgenv().FloatGuns then getgenv().FloatGuns.stop() end end)

connect(RunService.Stepped, function()
if not CFG.staticArm or not enabled or next(gunsState) == nil then return end
local c = char()
local torso = c and c:FindFirstChild("Torso")
local rs = torso and torso:FindFirstChild("Right Shoulder")
if rs then rs.Transform = CFrame.new() end
end)

local lastCheck = 0
local function maintain()
if rebinding then return end
local c = char()
if not c then return end
if userHeld and userHeld.Parent ~= c then
releaseAdopted()
userHeld = nil
end
if not userHeld then
for _, t in ipairs(gunsIn(c)) do
if not adopted[t] then userHeld = t break end
end
end
watchReload(userHeld)
if userHeld then
local count = #gunsIn(c)
local brought = 0
for _, t in ipairs(gunsIn(lp:FindFirstChild("Backpack"))) do
if count >= CFG.maxGuns then break end
adopted[t] = true
t.Parent = c
count += 1
brought += 1
end
if brought > 0 then rebindAt = os.clock() + 0.6 end
end
if rebindAt and os.clock() >= rebindAt and userHeld then
rebindAt = nil
task.spawn(rebind, userHeld)
end
end

local function clampAim(dir, flatFallback)
local flat = Vector3.new(dir.X, 0, dir.Z)
if flat.Magnitude < 0.05 then flat = flatFallback end
flat = flat.Unit
local pitch = math.asin(math.clamp(dir.Unit.Y, -1, 1))
pitch = math.clamp(pitch, math.rad(CFG.minPitch), math.rad(CFG.maxPitch))
return (CFrame.lookAt(Vector3.zero, flat) * CFrame.Angles(pitch, 0, 0)).LookVector
end

connect(RunService.RenderStepped, function()
local c = char()
local root = c and c:FindFirstChild("HumanoidRootPart")

local floating = enabled and userHeld ~= nil
if floating and not track then startEmote()
elseif not floating and track then stopEmote() end

if not enabled or not root then return end

if os.clock() - lastCheck > CFG.checkEvery then
lastCheck = os.clock()
maintain()
end
if not userHeld and next(gunsState) == nil then return end -- no gun in hand: nothing to position this frame

local active = {}
local held = nil
for _, t in ipairs(gunsIn(c)) do
local g = gripFor(t)
if g then
if t == userHeld then held = { tool = t, grip = g, isHeld = true }
else table.insert(active, { tool = t, grip = g }) end
end
end
for tool in pairs(gunsState) do
if tool.Parent ~= c then gunsState[tool] = nil end
end

local forward = root.CFrame.LookVector * Vector3.new(1, 0, 1)
if forward.Magnitude < 0.01 then forward = Vector3.new(0, 0, -1) end
forward = forward.Unit
local frame = CFrame.lookAt(root.Position, root.Position + forward)

local target, parallelDir
if CFG.aimMode ~= "forward" then
local cam = workspace.CurrentCamera
local loc = UIS:GetMouseLocation()
local ray = cam:ViewportPointToRay(loc.X, loc.Y)
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = { c }
local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
target = hit and hit.Position or (ray.Origin + ray.Direction * 120)
parallelDir = clampAim(target - root.Position, forward)
end

local n = #active
local rows = math.clamp(math.ceil(n / CFG.gunsPerRow), 1, CFG.maxRows)
local cols = math.max(1, math.ceil(n / rows))
local radius = math.max(CFG.minRadius, (cols * CFG.gunSpacing) / (2 * math.sin(math.rad(CFG.fanAngle))))

local list = {}
if held then table.insert(list, held) end
for _, a in ipairs(active) do table.insert(list, a) end
local wallIndex = 0

for _, a in ipairs(list) do
local g, handle = a.grip, a.grip.Part1
local s = gunsState[a.tool]
if not s or s.grip ~= g then
restoreOne(a.tool)
gunsState[a.tool] = { grip = g, c0 = g.C0, part0 = g.Part0, handle = handle, massless = handle.Massless, canCollide = handle.CanCollide }
handle.Massless = true
handle.CanCollide = false
end

local i = 1
if not a.isHeld then wallIndex += 1 i = wallIndex end
local row = ((i - 1) % rows) + 1
local col = math.ceil(i / rows)
local f = cols > 1 and ((col - 1) / (cols - 1)) * 2 - 1 or 0
if row % 2 == 0 and cols > 1 then f = math.clamp(f + 1 / cols, -1, 1) end
local ang = math.rad(CFG.fanAngle) * f
local bob = math.sin(os.clock() * 2 + i) * CFG.bob
local pos = frame * Vector3.new(
math.sin(ang) * radius,
CFG.baseHeight + (row - 1) * CFG.rowSpacing + math.cos(ang) * CFG.lift + bob,
CFG.back + (1 - math.cos(ang)) * radius * 0.35
)
if a.isHeld then
pos = frame * Vector3.new(0, CFG.heldHeight, CFG.heldBack)
end

local aimDir
if CFG.aimMode == "converge" then
aimDir = clampAim(target - pos, forward)
elseif CFG.aimMode == "crosshair" then
aimDir = parallelDir
else
aimDir = (CFrame.lookAt(Vector3.zero, forward) * CFrame.Angles(math.rad(CFG.tilt), 0, 0)).LookVector
end

local desired = CFrame.lookAt(pos, pos + aimDir) * CFG.faceOffset
local newC0 = g.Part0.CFrame:Inverse() * desired * g.C1
local old = g.C0
local moved = (newC0.Position - old.Position).Magnitude > 0.03
if not moved then
local rel = old:Inverse() * newC0
local _, angle = rel:ToAxisAngle()
moved = math.abs(angle) > 0.02
end
if moved then g.C0 = newC0 end
end
end)

local SoundService = game:GetService("SoundService")

CFG.fx = true             -- master switch for everything below
CFG.portals = true        -- golden portals on the guns
CFG.hideGuns = true       -- hide the gun models on your screen only
CFG.swords = true         -- swords / spears fly out of the portals on every shot
CFG.muteGunSounds = true  -- silence the guns' own sounds while the gate is open
CFG.fallbackFire = true   -- also show swords when you hold the mouse button, even if the shot itself was not detected
CFG.portalSize = 3.0
CFG.themeVolume = 0.6
CFG.humVolume = 0.35
CFG.shotVolume = 0.8
CFG.themeFile = "gate_theme"
CFG.shotFile = "gate_shot"
CFG.shotMaxLen = 1.4
CFG.swordSpeed = 340
CFG.swordRange = 450
CFG.maxSwords = 110
CFG.watchRange = 400      -- how far away (studs) other players' gates are drawn
CFG.watchOthers = true    -- see the portals and swords of other players who run this script (they must have 2+ guns out)

local GOLD = Color3.fromRGB(226, 126, 12)
local GOLD_HI = Color3.fromRGB(255, 182, 58)
local GOLD_DK = Color3.fromRGB(150, 90, 10)
local fxConns = {}
local function fxConnect(signal, fn)
local c = signal:Connect(fn)
table.insert(fxConns, c)
return c
end

local fxFolder = nil
local function folder()
if fxFolder and fxFolder.Parent then return fxFolder end
fxFolder = Instance.new("Folder")
fxFolder.Name = "GateOfBabylonFX"
fxFolder.Parent = workspace
return fxFolder
end

local function mkPart(kind, size, color, transp, material)
local p = Instance.new(kind == "wedge" and "WedgePart" or "Part")
p.Anchored = true
p.CanCollide = false
p.CanQuery = false
p.CanTouch = false
p.CastShadow = false
p.Massless = true
if kind == "cyl" then p.Shape = Enum.PartType.Cylinder
elseif kind == "ball" then p.Shape = Enum.PartType.Ball end
p.Material = material or Enum.Material.Neon
p.Color = color
p.Transparency = transp or 0
p.Size = size
p.Parent = folder()
return p
end

local audioTry, audioId = {}, {}
local function audioAsset(base, default)
if audioId[base] then return audioId[base] end
if audioTry[base] and os.clock() - audioTry[base] < 4 then return nil end
audioTry[base] = os.clock()
local id
pcall(function()
if not (isfile and getcustomasset) then return end
for _, ext in ipairs({ ".mp3", ".ogg", ".wav" }) do
if isfile(base .. ext) then id = getcustomasset(base .. ext) return end
end
if default and isfile(default) then id = getcustomasset(default) end
end)
audioId[base] = id
return id
end

CFG.autoDownload = true
CFG.soundBase = "https://raw.githubusercontent.com/Turdeater/Killswitch/main/"
local SOUND_FILES = { "gate_theme.mp3", "gate_shot.mp3", "gate_hum.wav", "gate_open.wav", "fuga_voice.mp3" }
local function fetchSounds(list)
if not (isfile and writefile and getcustomasset) then return end
local got = 0
for _, name in ipairs(list or SOUND_FILES) do
local have = false
pcall(function() have = isfile(name) end)
if not have then
local ok, data = pcall(function() return game:HttpGet(CFG.soundBase .. name) end)
if ok and type(data) == "string" and #data > 2000 and data:sub(1, 3) ~= "404" then
if pcall(writefile, name, data) then
got += 1
print("[Babylon] downloaded " .. name)
end
else
print("[Babylon] could not download " .. name .. " (is it uploaded to the repo?)")
end
end
end
table.clear(audioId)
table.clear(audioTry)
return got
end

local function newSound(id, vol, looped, parent)
local s = Instance.new("Sound")
s.SoundId = id
s.Volume = vol
s.Looped = looped and true or false
s.Parent = parent or SoundService
return s
end

local liveShots = 0
local function playShot(parent, mul)
if CFG.shotVolume <= 0 then return end
local id = audioAsset(CFG.shotFile, "gate_shot_default.wav")
if not id or liveShots >= 24 then return end
local s = newSound(id, CFG.shotVolume * (mul or 1), false, parent)
if parent then
s.RollOffMinDistance = 14
s.RollOffMaxDistance = 150
end
s.PlaybackSpeed = 0.94 + math.random() * 0.14
liveShots += 1
local done = false
local function fin()
if done then return end
done = true
liveShots -= 1
pcall(function() s:Destroy() end)
end
s.Ended:Connect(fin)
task.delay(CFG.shotMaxLen, fin)
s:Play()
end

local theme = { snd = nil, fade = 0 }
local hum = { snd = nil, part = nil, fade = 0 }
local wasWanted = false
local noThemeNote = false

local function destroyAudio()
if theme.snd then pcall(function() theme.snd:Destroy() end) theme.snd = nil end
if hum.snd then pcall(function() hum.snd:Destroy() end) hum.snd = nil end
if hum.part then pcall(function() hum.part:Destroy() end) hum.part = nil end
theme.fade, hum.fade = 0, 0
end

local function audioStep(dt, want, center)
if want and not wasWanted then
local id = audioAsset("gate_open", "gate_open.wav")
if id then
local s = newSound(id, math.clamp(CFG.humVolume * 2.2, 0, 10), false)
s.Ended:Connect(function() pcall(function() s:Destroy() end) end)
task.delay(6, function() pcall(function() s:Destroy() end) end)
s:Play()
end
end
wasWanted = want
local step = (want and 1 / 1.6 or -1 / 1.1) * dt
theme.fade = math.clamp(theme.fade + step, 0, 1)
if want and not theme.snd then
local id = audioAsset(CFG.themeFile, "gate_theme_default.wav")
if id then
theme.snd = newSound(id, 0, true)
theme.snd:Play()
elseif not noThemeNote then
noThemeNote = true
print("[Babylon] Gate music: put gate_theme.mp3 in the executor's workspace folder")
end
end
if theme.snd then
theme.snd.Volume = CFG.themeVolume * theme.fade
if theme.fade <= 0 and not want then
pcall(function() theme.snd:Destroy() end)
theme.snd = nil
end
end
hum.fade = math.clamp(hum.fade + step, 0, 1)
if want and not hum.snd then
local id = audioAsset("gate_hum", "gate_hum.wav")
if id then
hum.part = Instance.new("Part")
hum.part.Anchored = true
hum.part.CanCollide = false
hum.part.CanQuery = false
hum.part.CanTouch = false
hum.part.Transparency = 1
hum.part.Size = Vector3.new(1, 1, 1)
hum.part.Parent = folder()
hum.snd = newSound(id, 0, true, hum.part)
hum.snd.RollOffMinDistance = 18
hum.snd.RollOffMaxDistance = 160
hum.snd:Play()
end
end
if hum.snd then
hum.snd.Volume = CFG.humVolume * hum.fade
if center and hum.part then hum.part.Position = center end
if hum.fade <= 0 and not want then
pcall(function() hum.snd:Destroy() end)
pcall(function() hum.part:Destroy() end)
hum.snd, hum.part = nil, nil
end
end
end

local watched = setmetatable({}, { __mode = "k" })
local gunSounds = {} -- { snd = Sound, vol = original volume }
local soundInfo = setmetatable({}, { __mode = "k" })
local muted = false
local lastShot = setmetatable({}, { __mode = "k" })
local lastShotAny = 0
local mouseUpAt = 0
local mouseWasDown = false
local fireTool -- defined with the portals below
local debugOn = false

local function dbg(...)
if debugOn then print("[GateFX]", ...) end
end

local attrWorks = setmetatable({}, { __mode = "k" })
local function onShot(tool, why)
local now = os.clock()
if why:sub(1, 4) == "attr" or why:sub(1, 4) == "ammo" then attrWorks[tool] = true
elseif attrWorks[tool] then return end -- the gun's ammo counter is reliable, ignore sound guesses
if lastShot[tool] and now - lastShot[tool] < 0.05 then return end
lastShot[tool] = now
lastShotAny = now
dbg("shot", tool.Name, why)
if fireTool then fireTool(tool) end
end

local function mouseRecent()
return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or os.clock() - mouseUpAt < 0.7
end

local SKIP = { "reload", "equip", "unsheath", "draw", "empty", "click", "pickup", "cock", "mag" }
local function looksLikeShot(name)
name = name:lower()
for _, w in ipairs(SKIP) do
if name:find(w, 1, true) then return false end
end
return true
end

local function hookSound(tool, snd)
if soundInfo[snd] then return end
local info = { snd = snd, vol = snd.Volume }
soundInfo[snd] = info
table.insert(gunSounds, info)
if muted then snd.Volume = 0 end
fxConnect(snd.Played, function()
if looksLikeShot(snd.Name) and mouseRecent() then onShot(tool, "sound " .. snd.Name) end
end)
fxConnect(snd:GetPropertyChangedSignal("Playing"), function()
if snd.Playing and looksLikeShot(snd.Name) and mouseRecent() then onShot(tool, "playing " .. snd.Name) end
end)
fxConnect(snd:GetPropertyChangedSignal("Volume"), function()
if muted and snd.Volume ~= 0 then
info.vol = snd.Volume
snd.Volume = 0
elseif not muted then
info.vol = snd.Volume
end
end)
end

local function hookAttrs(tool)
local last = {}
for name, v in pairs(tool:GetAttributes()) do
if type(v) == "number" then last[name] = v end
end
fxConnect(tool.AttributeChanged, function(name)
local n = name:lower()
local v = tool:GetAttribute(name)
if n:find("fire", 1, true) or n:find("shot", 1, true) or n:find("shoot", 1, true) then
if not n:find("rate", 1, true) and not n:find("mode", 1, true) then onShot(tool, "attr " .. name) end
elseif (n:find("ammo", 1, true) or n:find("mag", 1, true) or n:find("bullet", 1, true) or n:find("clip", 1, true)) and type(v) == "number" then
if last[name] and v < last[name] then onShot(tool, "ammo " .. name) end
last[name] = v
end
end)
end

local function watchTool(tool)
if watched[tool] then return end
watched[tool] = true
for _, d in ipairs(tool:GetDescendants()) do
if d:IsA("Sound") then hookSound(tool, d) end
end
fxConnect(tool.DescendantAdded, function(d)
if d:IsA("Sound") then hookSound(tool, d) end
end)
hookAttrs(tool)
end

local function applyMute(on)
muted = on
for i = #gunSounds, 1, -1 do
local info = gunSounds[i]
if info.snd.Parent == nil and not info.snd:IsDescendantOf(game) then
table.remove(gunSounds, i)
elseif on then
info.vol = info.snd.Volume ~= 0 and info.snd.Volume or info.vol
info.snd.Volume = 0
else
info.snd.Volume = info.vol
end
end
end

local portals, portalCount, portalOrder = {}, 0, 0
local pulses = {}
local swords = {}
local trailCount = 0
local cfParts, cfValues = {}, {}

local function addCF(part, cf)
local n = #cfParts + 1
cfParts[n] = part
cfValues[n] = cf
end

local function lod(n)
if n <= 6 then return 22, 8, true, 14
elseif n <= 14 then return 14, 6, false, 6
else return 9, 0, false, 0 end
end

local function newPortal(tool, n)
portalOrder += 1
local segN, tickN, star, rate = lod(n)
local P = {
tool = tool, id = portalOrder, born = os.clock() + math.min(portalOrder % 14, 13) * 0.035,
closing = false, closedAt = 0, kick = 0, pulseAt = os.clock() + math.random() * 1.3,
pos = Vector3.zero, dir = Vector3.new(0, 0, -1), scale = 0, ringA = {}, ringB = {}, ticks = {}, starA = {},
}
P.core = mkPart("cyl", Vector3.new(0.1, 1, 1), GOLD, 0.22)
P.halo = mkPart("cyl", Vector3.new(0.06, 1, 1), GOLD, 0.84)
for i = 1, segN do P.ringA[i] = mkPart("block", Vector3.new(0.4, 0.07, 0.07), GOLD_HI, 0) end
for i = 1, math.max(6, math.floor(segN * 0.75)) do P.ringB[i] = mkPart("block", Vector3.new(0.4, 0.12, 0.12), GOLD, 0.1) end
for i = 1, tickN do P.ticks[i] = mkPart("block", Vector3.new(0.4, 0.08, 0.08), GOLD, 0.05) end
if star then
for i = 1, 8 do P.starA[i] = mkPart("block", Vector3.new(0.4, 0.06, 0.06), GOLD_HI, 0.1) end
end
if rate > 0 then
local e = Instance.new("ParticleEmitter")
e.Rate = rate
e.Lifetime = NumberRange.new(0.5, 1.2)
e.Speed = NumberRange.new(1, 4)
e.SpreadAngle = Vector2.new(180, 180)
e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.28), NumberSequenceKeypoint.new(1, 0) })
e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
e.Color = ColorSequence.new(GOLD_HI, GOLD)
e.LightEmission = 1
e.Acceleration = Vector3.new(0, 2.5, 0)
e.Drag = 1
pcall(function() e.Shape = Enum.ParticleEmitterShape.Disc e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume end)
e.Parent = P.core
P.emitter = e
end
if n <= 8 then
local l = Instance.new("PointLight")
l.Color = GOLD
l.Range = 14
l.Brightness = 0.8
l.Parent = P.core
P.light = l
end
return P
end

local function destroyPortal(P)
pcall(function() P.core:Destroy() end)
pcall(function() P.halo:Destroy() end)
for _, group in ipairs({ P.ringA, P.ringB, P.ticks, P.starA }) do
for _, p in ipairs(group) do pcall(function() p:Destroy() end) end
end
end

local function backOut(a)
a = a - 1
return 1 + 2.70158 * a * a * a + 1.70158 * a * a
end

local function placeRing(group, F, R, theta, thick, dashed, count)
local n = #group
local spacing = 2 * math.pi * R / n
local len = spacing * (dashed and 0.6 or 1.08)
for i, p in ipairs(group) do
local a = theta + (i - 1) * 2 * math.pi / n
p.Size = Vector3.new(len, thick, thick)
addCF(p, F * CFrame.new(math.cos(a) * R, math.sin(a) * R, -0.02) * CFrame.Angles(0, 0, a + math.pi / 2))
end
end

local function updatePortal(P, now)
local open
if P.closing then
open = 1 - math.clamp((now - P.closedAt) / 0.3, 0, 1)
P.scale = open * open
else
local a = math.clamp((now - P.born) / 0.5, 0, 1)
P.scale = a <= 0 and 0 or backOut(a)
open = a
end
P.kick = math.max(0, P.kick - (1 / 0.22) * (1 / 60))
local s = math.max(P.scale, 0.001)
local D = CFG.portalSize * s * (1 + 0.035 * math.sin(now * 7 + P.id)) * (1 + 0.3 * P.kick)
local F = CFrame.lookAt(P.pos, P.pos + P.dir)
local disc = CFrame.Angles(0, math.pi / 2, 0)
P.core.Size = Vector3.new(0.1, D, D)
P.core.Transparency = 0.22 - 0.14 * P.kick
addCF(P.core, F * disc)
P.halo.Size = Vector3.new(0.06, D * 1.3, D * 1.3)
P.halo.Transparency = 0.84 - 0.2 * P.kick
addCF(P.halo, F * CFrame.new(0, 0, 0.05) * disc)
local th = now * 0.85 + P.id
placeRing(P.ringA, F, D * 0.53, th * 0.6, 0.07, false)
placeRing(P.ringB, F, D * 0.74, -th, 0.12, true)
local nt = #P.ticks
for i, p in ipairs(P.ticks) do
local a = th * 0.9 + (i - 1) * 2 * math.pi / nt
local r = D * 0.34
p.Size = Vector3.new(D * 0.2, 0.07, 0.07)
addCF(p, F * CFrame.new(math.cos(a) * r, math.sin(a) * r, -0.02) * CFrame.Angles(0, 0, a))
end
if #P.starA == 8 then
local R = D * 0.3
for sq = 0, 1 do
local rot = -th * 0.5 + sq * math.pi / 4
for k = 0, 3 do
local p = P.starA[sq * 4 + k + 1]
local a = rot + k * math.pi / 2
local apo = R * 0.707
p.Size = Vector3.new(R * 1.414, 0.06, 0.06)
addCF(p, F * CFrame.new(math.cos(a) * apo, math.sin(a) * apo, -0.03) * CFrame.Angles(0, 0, a + math.pi / 2))
end
end
end
if P.light then P.light.Brightness = (0.7 + 1.5 * P.kick) * open end
if not P.closing and open >= 1 and now >= P.pulseAt and #pulses < 40 then
P.pulseAt = now + 1.25 + math.random() * 0.7
local pp = mkPart("cyl", Vector3.new(0.05, D, D), GOLD, 0.5)
table.insert(pulses, { part = pp, born = now, life = 1.1, pos = P.pos, dir = P.dir, base = CFG.portalSize })
end
end

local function addWeapon(def, list, root, sc)
for _, d in ipairs(def) do
local p = mkPart(d.kind, d.size * sc, d.color, d.transp or 0, d.mat)
table.insert(list, { part = p, off = CFrame.new(d.off * sc) * (d.rot or CFrame.new()) })
end
end

local SWORD = {
{ kind = "block", size = Vector3.new(0.34, 0.07, 3.2), off = Vector3.new(0, 0, -2.7), color = GOLD_HI },
{ kind = "wedge", size = Vector3.new(0.07, 0.34, 0.9), off = Vector3.new(0, 0, -4.75), color = GOLD_HI, rot = CFrame.new() },
{ kind = "block", size = Vector3.new(1.2, 0.16, 0.22), off = Vector3.new(0, 0, -1.05), color = GOLD },
{ kind = "block", size = Vector3.new(0.16, 0.16, 1.0), off = Vector3.new(0, 0, -0.5), color = GOLD_DK },
{ kind = "ball", size = Vector3.new(0.32, 0.32, 0.32), off = Vector3.new(0, 0, 0.05), color = GOLD },
{ kind = "block", size = Vector3.new(0.9, 0.9, 5.4), off = Vector3.new(0, 0, -2.9), color = GOLD, transp = 0.94 },
}
local SPEAR = {
{ kind = "block", size = Vector3.new(0.13, 0.13, 5.4), off = Vector3.new(0, 0, -2.7), color = GOLD_DK, mat = Enum.Material.Metal },
{ kind = "block", size = Vector3.new(0.5, 0.07, 1.3), off = Vector3.new(0, 0, -5.9), color = GOLD_HI },
{ kind = "wedge", size = Vector3.new(0.07, 0.5, 0.9), off = Vector3.new(0, 0, -6.95), color = GOLD_HI },
{ kind = "block", size = Vector3.new(0.3, 0.3, 0.3), off = Vector3.new(0, 0, -5.2), color = GOLD },
{ kind = "block", size = Vector3.new(0.9, 0.9, 7.2), off = Vector3.new(0, 0, -3.6), color = GOLD, transp = 0.94 },
}

local UPISH = Vector3.new(0.0001, 1, 0).Unit
local impactEmitters = {}
local function impact(pos, normal, scale)
local p = mkPart("ball", Vector3.new(0.6, 0.6, 0.6) * scale, GOLD_HI, 0.1)
p.Position = pos
table.insert(pulses, { part = p, born = os.clock(), life = 0.4, pos = pos, ball = true, base = 0.6 * scale })
local holder = Instance.new("Part")
holder.Anchored = true holder.CanCollide = false holder.CanQuery = false holder.Transparency = 1
holder.Size = Vector3.new(0.2, 0.2, 0.2)
holder.Position = pos
holder.Parent = folder()
local e = Instance.new("ParticleEmitter")
e.Rate = 0
e.Lifetime = NumberRange.new(0.3, 0.8)
e.Speed = NumberRange.new(10, 26)
e.SpreadAngle = Vector2.new(70, 70)
e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) })
e.Color = ColorSequence.new(GOLD_HI, GOLD)
e.LightEmission = 1
e.Acceleration = Vector3.new(0, -30, 0)
e.EmissionDirection = Enum.NormalId.Top
e.Parent = holder
holder.CFrame = CFrame.lookAt(pos, pos + (normal or Vector3.yAxis)) * CFrame.Angles(-math.pi / 2, 0, 0)
e:Emit(34)
local ringDir = normal and normal.Magnitude > 0.1 and normal.Unit or UPISH
if math.abs(ringDir.Y) > 0.999 then ringDir = UPISH end
table.insert(pulses, { part = mkPart("cyl", Vector3.new(0.05, 2 * scale, 2 * scale), GOLD, 0.35), born = os.clock(), life = 0.55, pos = pos + ringDir * 0.1, dir = ringDir, base = 2 * scale, grow = 6, t0 = 0.35 })
local fl = Instance.new("PointLight")
fl.Color = GOLD
fl.Range = 18
fl.Brightness = 3
fl.Parent = holder
TweenService:Create(fl, TweenInfo.new(0.35), { Brightness = 0 }):Play()
task.delay(1.2, function() pcall(function() holder:Destroy() end) end)
end

local function spawnSword(P)
if #swords >= CFG.maxSwords then return end
local spear = math.random() < 0.3
local def = spear and SPEAR or SWORD
local sc = spear and (0.9 + math.random() * 0.4) or (0.8 + math.random() * 0.6)
local W = { parts = {}, spear = spear, sc = sc, dir = P.dir, born = os.clock(), state = "emerge", len = (spear and 7.4 or 5.2) * sc }
local jitter = CFrame.Angles((math.random() - 0.5) * 0.05, (math.random() - 0.5) * 0.05, 0)
W.dir = (CFrame.lookAt(Vector3.zero, P.dir) * jitter).LookVector
W.start = P.pos - W.dir * (W.len + 0.3) -- fully behind the portal to begin with
W.cf = CFrame.lookAt(W.start, W.start + W.dir) * CFrame.Angles(0, 0, math.random() * math.pi * 2)
W.roll = math.random() * math.pi * 2
addWeapon(def, W.parts, W.cf, sc)
if trailCount < 60 and W.parts[1] then
local blade = W.parts[1].part
local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
a0.Position = Vector3.new(0, 0.5 * sc, 0)
a1.Position = Vector3.new(0, -0.5 * sc, 0)
a0.Parent, a1.Parent = blade, blade
local tr = Instance.new("Trail")
tr.Attachment0, tr.Attachment1 = a0, a1
tr.Lifetime = 0.22
tr.LightEmission = 1
tr.Color = ColorSequence.new(GOLD_HI, GOLD)
tr.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
tr.MinLength = 0.05
tr.Parent = blade
W.trail = tr
trailCount += 1
end
W.pos = W.start
W.tip = W.start + W.dir * W.len
table.insert(swords, W)
end

local function killSword(W)
for _, e in ipairs(W.parts) do pcall(function() e.part:Destroy() end) end
if W.trail then trailCount = math.max(0, trailCount - 1) end
end

local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude

local function updateSwords(dt, now)
for i = #swords, 1, -1 do
local W = swords[i]
local age = now - W.born
if W.state == "emerge" then
local a = math.clamp(age / 0.16, 0, 1)
W.pos = W.start + W.dir * (W.len * 0.9 * a * (2 - a))
if a >= 1 then W.state = "fly" W.flyAt = now W.flown = 0 end
elseif W.state == "fly" then
local fa = now - W.flyAt
local speed = CFG.swordSpeed * (0.3 + 0.7 * math.min(1, fa / 0.28))
local step = speed * dt
local tipStart = W.pos + W.dir * W.len
local hit = workspace:Raycast(tipStart, W.dir * (step + 0.5), rp)
if hit then
W.pos = hit.Position - W.dir * (W.len * (0.55 + math.random() * 0.15))
W.state = "stuck"
W.stuckAt = now
impact(hit.Position, hit.Normal, W.sc)
else
W.pos = W.pos + W.dir * step
W.flown += step
if W.flown > CFG.swordRange then W.state = "stuck" W.stuckAt = now - 2.4 W.fade = true end
end
else -- stuck, then fades away
local sa = now - W.stuckAt
local t = math.clamp((sa - 2.6) / 0.9, 0, 1)
if t >= 1 then
killSword(W)
table.remove(swords, i)
W = nil
else
for _, e in ipairs(W.parts) do
e.part.Transparency = math.max(e.part.Transparency, t)
end
if W.trail then W.trail.Enabled = false end
end
end
if W then
local cf = CFrame.lookAt(W.pos, W.pos + W.dir) * CFrame.Angles(0, 0, W.roll)
for _, e in ipairs(W.parts) do addCF(e.part, cf * e.off) end
end
end
end

local function updatePulses(now)
for i = #pulses, 1, -1 do
local q = pulses[i]
local a = (now - q.born) / q.life
if a >= 1 then
pcall(function() q.part:Destroy() end)
table.remove(pulses, i)
elseif q.ball then
local d = q.base * (1 + 6 * a)
q.part.Size = Vector3.new(d, d, d)
q.part.Transparency = 0.1 + 0.9 * a
addCF(q.part, CFrame.new(q.pos))
else
local d = math.max(0.1, q.base * (1 + (q.grow or 1.9) * a))
q.part.Size = Vector3.new(0.05, d, d)
local t0 = q.t0 or 0.45
q.part.Transparency = t0 + (1 - t0) * a
addCF(q.part, CFrame.lookAt(q.pos, q.pos + q.dir) * CFrame.Angles(0, math.pi / 2, 0))
end
end
end

local hideLists = setmetatable({}, { __mode = "k" })
local hiddenNow = {}
local function partsOf(tool)
local list = hideLists[tool]
if not list then
list = {}
hideLists[tool] = list
for _, d in ipairs(tool:GetDescendants()) do
if d:IsA("BasePart") then table.insert(list, d) end
end
fxConnect(tool.DescendantAdded, function(d)
if d:IsA("BasePart") then table.insert(list, d) end
end)
end
return list
end
local function setHidden(tool, on)
local list = partsOf(tool)
for i = #list, 1, -1 do
local d = list[i]
if d.Parent then d.LocalTransparencyModifier = on and 1 or 0
else table.remove(list, i) end
end
end
local function unhideAll()
for tool in pairs(hiddenNow) do pcall(setHidden, tool, false) end
table.clear(hiddenNow)
end

CFG.impact = true         -- anime-style impact frame when the gate opens
CFG.impactOnFire = true   -- lighter gold flash when a barrage starts
CFG.tint = true           -- warm gold colour on your screen while the gate is open
CFG.shake = true          -- one short camera shake when the gate opens (never on shots)
CFG.aura = true           -- ground magic circle, light pillar and gold dust around every open gate
CFG.sigilSize = 13
local Lighting = game:GetService("Lighting")
local impactGui = nil
local lastImpact, lastBarrage = 0, 0

local function ensureImpact()
if impactGui and impactGui.Parent then return end
impactGui = Instance.new("ScreenGui")
impactGui.Name = "GateImpact"
impactGui.ResetOnSpawn = false
impactGui.IgnoreGuiInset = true
impactGui.DisplayOrder = 980
impactGui.Parent = uiParent
end

local impactCC = nil
local function pulseCC(power)
if not impactCC or not impactCC.Parent then
impactCC = Instance.new("ColorCorrectionEffect")
impactCC.Name = "GateImpactCC"
impactCC.Parent = Lighting
end
impactCC.Brightness = 0.16 * power
impactCC.Contrast = 0.45 * power
impactCC.Saturation = 0.4 * power
TweenService:Create(impactCC, TweenInfo.new(0.5), { Brightness = 0, Contrast = 0, Saturation = 0 }):Play()
end

local function impactFrame(power)
if not CFG.impact or os.clock() - lastImpact < 0.35 then return end
lastImpact = os.clock()
local strong = power >= 1
task.spawn(function()
ensureImpact()
local vs = workspace.CurrentCamera.ViewportSize
local diag = math.sqrt(vs.X * vs.X + vs.Y * vs.Y)
local holder = Instance.new("Frame")
holder.BackgroundTransparency = 1
holder.BorderSizePixel = 0
holder.Size = UDim2.fromScale(1, 1)
holder.Parent = impactGui
local bg = Instance.new("Frame")
bg.BorderSizePixel = 0
bg.Size = UDim2.fromScale(1, 1)
bg.Parent = holder
local lines = {}
for i = 1, (strong and 48 or 28) do
local ang = math.random() * 360
local r0 = diag * (0.05 + math.random() * 0.15)
local len = diag * (0.22 + math.random() * 0.5)
local f = Instance.new("Frame")
f.AnchorPoint = Vector2.new(0.5, 0.5)
f.BorderSizePixel = 0
f.Size = UDim2.fromOffset(len, 2 + math.random() * (strong and 16 or 8))
local rad = math.rad(ang)
f.Position = UDim2.new(0.5, math.cos(rad) * (r0 + len / 2), 0.5, math.sin(rad) * (r0 + len / 2))
f.Rotation = ang
f.Parent = holder
lines[i] = f
end
local function paint(bgColor, bgT, lineColor, lineT)
bg.BackgroundColor3 = bgColor
bg.BackgroundTransparency = bgT
for _, f in ipairs(lines) do
f.BackgroundColor3 = lineColor
f.BackgroundTransparency = lineT
end
end
if strong then
paint(Color3.new(1, 1, 1), 0, Color3.new(0, 0, 0), 0) -- stark white frame with black speed lines
task.wait(0.06)
paint(Color3.new(0, 0, 0), 0, Color3.new(1, 1, 1), 0) -- inverted frame
task.wait(0.06)
end
paint(GOLD_HI, strong and 0.25 or 0.55, Color3.new(1, 1, 1), 0.1)
pulseCC(strong and 1 or 0.5)
local ti = TweenInfo.new(strong and 0.55 or 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(bg, ti, { BackgroundTransparency = 1 }):Play()
for _, f in ipairs(lines) do
TweenService:Create(f, ti, { BackgroundTransparency = 1, Size = UDim2.fromOffset(f.Size.X.Offset * 1.7, 0) }):Play()
end
task.wait(0.6)
holder:Destroy()
end)
end

local shakeAmp = 0
local function shakeKick(a)
if CFG.shake then shakeAmp = math.max(shakeAmp, a) end
end
pcall(function() RunService:UnbindFromRenderStep("GateShake") end)
RunService:BindToRenderStep("GateShake", Enum.RenderPriority.Camera.Value + 1, function(dt)
if shakeAmp < 0.01 then return end
local cam = workspace.CurrentCamera
local a = shakeAmp * 0.012
cam.CFrame = cam.CFrame * CFrame.Angles((math.random() - 0.5) * a, (math.random() - 0.5) * a, (math.random() - 0.5) * a * 0.6)
shakeAmp = shakeAmp * (1 - math.min(1, dt * 7))
end)

local tintCC, tintWanted = nil, false
local function tintOn()
tintWanted = true
if not CFG.tint then return end
if not tintCC or not tintCC.Parent then
tintCC = Instance.new("ColorCorrectionEffect")
tintCC.Name = "GateTint"
tintCC.Parent = Lighting
end
TweenService:Create(tintCC, TweenInfo.new(1.2), { TintColor = Color3.fromRGB(255, 232, 196), Saturation = 0.12, Contrast = 0.04 }):Play()
end
local function tintOff(instant)
tintWanted = false
if not tintCC or not tintCC.Parent then return end
if instant then pcall(function() tintCC:Destroy() end) tintCC = nil return end
local cc = tintCC
TweenService:Create(cc, TweenInfo.new(1.0), { TintColor = Color3.new(1, 1, 1), Saturation = 0, Contrast = 0 }):Play()
task.delay(1.1, function()
if tintCC == cc and not tintWanted then pcall(function() cc:Destroy() end) tintCC = nil end
end)
end

local auras = {}

local function ringBurst(center, base, grow, life, transp)
local part = mkPart("cyl", Vector3.new(0.05, base, base), GOLD, transp or 0.4)
table.insert(pulses, { part = part, born = os.clock(), life = life, pos = center, dir = UPISH, base = base, grow = grow, t0 = transp or 0.4 })
end

local function newAura(owner, info)
local rr = info.root
local A = {
owner = owner, root = rr, ch = info.ch, isSelf = info.isSelf, born = os.clock(), closing = false, closedAt = 0,
nextGround = 0, gy = rr.Position.Y - 3, gyT = rr.Position.Y - 3, spin = math.random() * 6.28,
outer = {}, inner = {}, runes = {}, tri = {},
}
A.rp = RaycastParams.new()
A.rp.FilterType = Enum.RaycastFilterType.Exclude
for i = 1, 56 do A.outer[i] = mkPart("block", Vector3.new(1, 0.08, 0.34), GOLD_HI, 0) end
for i = 1, 36 do A.inner[i] = mkPart("block", Vector3.new(1, 0.08, 0.22), GOLD, 0.05) end
for i = 1, 18 do A.runes[i] = mkPart("block", Vector3.new(1, 0.08, 0.5), GOLD, 0.1) end
for i = 1, 6 do A.tri[i] = mkPart("block", Vector3.new(0.3, 0.08, 1), GOLD_HI, 0.05) end
A.disc = mkPart("cyl", Vector3.new(0.05, 1, 1), GOLD, 0.85)
A.pillar = mkPart("cyl", Vector3.new(90, 4, 4), GOLD, 0.55)
A.core = mkPart("cyl", Vector3.new(90, 1.6, 1.6), GOLD_HI, 0.2)
local holder = Instance.new("Part")
holder.Anchored = true holder.CanCollide = false holder.CanQuery = false holder.CanTouch = false
holder.Transparency = 1
holder.Size = Vector3.new(20, 0.2, 20)
holder.Parent = folder()
A.holder = holder
local e = Instance.new("ParticleEmitter")
e.Rate = 0
e.Lifetime = NumberRange.new(2.2, 4)
e.Speed = NumberRange.new(1, 3.5)
e.SpreadAngle = Vector2.new(20, 20)
e.EmissionDirection = Enum.NormalId.Top
e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.38), NumberSequenceKeypoint.new(1, 0) })
e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.1), NumberSequenceKeypoint.new(1, 1) })
e.Color = ColorSequence.new(GOLD_HI, GOLD)
e.LightEmission = 1
e.Acceleration = Vector3.new(0, 1.2, 0)
e.Parent = holder
A.dust = e
local b = Instance.new("ParticleEmitter")
b.Rate = 0
b.Lifetime = NumberRange.new(0.8, 1.8)
b.Speed = NumberRange.new(25, 55)
b.SpreadAngle = Vector2.new(35, 35)
b.EmissionDirection = Enum.NormalId.Top
b.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 0) })
b.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
b.Color = ColorSequence.new(GOLD_HI, GOLD)
b.LightEmission = 1
b.Acceleration = Vector3.new(0, -22, 0)
b.Parent = holder
A.burst = b
return A
end

local function destroyAura(A)
for _, group in ipairs({ A.outer, A.inner, A.runes, A.tri }) do
for _, p in ipairs(group) do pcall(function() p:Destroy() end) end
end
for _, p in ipairs({ A.disc, A.pillar, A.core, A.holder }) do
if p then pcall(function() p:Destroy() end) end
end
end

local function flatRing(group, c, R, theta, thick, dashed, radial)
local n = #group
local len = (2 * math.pi * R / n) * (dashed and 0.6 or 1.08)
for i, p in ipairs(group) do
local a = theta + (i - 1) * 2 * math.pi / n
p.Size = Vector3.new(radial and R * 0.14 or len, 0.08, thick)
addCF(p, CFrame.new(c + Vector3.new(math.cos(a) * R, 0.06, math.sin(a) * R)) * CFrame.Angles(0, radial and -a or (-a - math.pi / 2), 0))
end
end

local function onGateOpen(A)
local rr = A.root
local c = Vector3.new(rr.Position.X, A.gy, rr.Position.Z)
task.spawn(function()
for i = 1, 3 do
ringBurst(c + Vector3.new(0, 0.1, 0), 10, 5 + i * 2.5, 0.9 + i * 0.15, 0.35)
task.wait(0.14)
end
end)
A.burst:Emit(90)
if A.isSelf then
impactFrame(1)
shakeKick(3)
tintOn()
else
local me = char() and char():FindFirstChild("HumanoidRootPart")
if me and (me.Position - rr.Position).Magnitude < 80 then impactFrame(0.5) end
end
end

local function onGateClose(A)
local rr = A.root
if rr and rr.Parent then
ringBurst(Vector3.new(rr.Position.X, A.gy + 0.1, rr.Position.Z), 26, -0.75, 0.6, 0.3)
end
if A.isSelf then tintOff(false) end
end

local function updateAura(A, now)
local rr = A.root
if not (rr and rr.Parent) then return end
if now >= A.nextGround then
A.nextGround = now + 0.2
A.rp.FilterDescendantsInstances = { A.ch or rr.Parent, folder() }
local hit = workspace:Raycast(rr.Position + Vector3.new(0, 1, 0), Vector3.new(0, -40, 0), A.rp)
A.gyT = hit and (hit.Position.Y + 0.1) or (rr.Position.Y - 3)
end
A.gy += (A.gyT - A.gy) * 0.3
local age = now - A.born
local open = A.closing and (1 - math.clamp((now - A.closedAt) / 0.7, 0, 1)) or math.clamp(age / 0.7, 0, 1)
local s = A.closing and open * open or (open <= 0 and 0 or backOut(open))
local R = CFG.sigilSize * math.max(s, 0.001)
local c = Vector3.new(rr.Position.X, A.gy, rr.Position.Z)
local th = now * 0.5 + A.spin
flatRing(A.outer, c, R, th * 0.6, 0.34, false)
flatRing(A.inner, c, R * 0.8, -th * 0.9, 0.22, true)
flatRing(A.runes, c, R * 0.9, th * 0.7, 0.5, false, true)
for sq = 0, 1 do
local verts = {}
for k = 0, 2 do
local a = th * 0.4 + sq * math.pi / 3 + k * 2 * math.pi / 3
verts[k + 1] = c + Vector3.new(math.cos(a) * R * 0.72, 0.08, math.sin(a) * R * 0.72)
end
for k = 1, 3 do
local v1, v2 = verts[k], verts[k % 3 + 1]
local p = A.tri[sq * 3 + k]
p.Size = Vector3.new(0.3, 0.08, (v2 - v1).Magnitude)
addCF(p, CFrame.lookAt((v1 + v2) / 2, v2))
end
end
A.disc.Size = Vector3.new(0.05, R * 1.96, R * 1.96)
addCF(A.disc, CFrame.new(c + Vector3.new(0, 0.03, 0)) * CFrame.Angles(0, 0, math.pi / 2))
if age < 1.7 and not A.closing then
local a = age / 1.7
local w = 0.5 + 6 * math.sqrt(1 - a)
A.pillar.Size = Vector3.new(90, w, w)
A.pillar.Transparency = 0.45 + 0.55 * a
A.core.Size = Vector3.new(90, w * 0.4, w * 0.4)
A.core.Transparency = 0.15 + 0.85 * a
addCF(A.pillar, CFrame.new(c + Vector3.new(0, 45, 0)) * CFrame.Angles(0, 0, math.pi / 2))
addCF(A.core, CFrame.new(c + Vector3.new(0, 45, 0)) * CFrame.Angles(0, 0, math.pi / 2))
elseif A.pillar and A.pillar.Transparency < 1 then
A.pillar.Transparency = 1
A.core.Transparency = 1
end
A.holder.Size = Vector3.new(R * 1.5, 0.2, R * 1.5)
A.holder.CFrame = CFrame.new(c + Vector3.new(0, 0.4, 0))
A.dust.Rate = A.closing and 0 or math.floor(34 * open)
end

local remoteWatched = setmetatable({}, { __mode = "k" })
local function remoteOffsets(total)
local out = { Vector3.new(0, CFG.heldHeight, CFG.heldBack) }
local n = total - 1
local rows = math.clamp(math.ceil(n / CFG.gunsPerRow), 1, CFG.maxRows)
local cols = math.max(1, math.ceil(n / rows))
local radius = math.max(CFG.minRadius, (cols * CFG.gunSpacing) / (2 * math.sin(math.rad(CFG.fanAngle))))
for i = 1, n do
local row = ((i - 1) % rows) + 1
local col = math.ceil(i / rows)
local f = cols > 1 and ((col - 1) / (cols - 1)) * 2 - 1 or 0
if row % 2 == 0 and cols > 1 then f = math.clamp(f + 1 / cols, -1, 1) end
local ang = math.rad(CFG.fanAngle) * f
table.insert(out, Vector3.new(
math.sin(ang) * radius,
CFG.baseHeight + (row - 1) * CFG.rowSpacing + math.cos(ang) * CFG.lift,
CFG.back + (1 - math.cos(ang)) * radius * 0.35
))
end
return out
end

local lastFx = os.clock()
local fallbackFor = 0
local nextFallback = 0
local function floatingTools()
local list = {}
local c = char()
for tool, s in pairs(gunsState) do
if tool.Parent == c and s.handle and s.handle.Parent then table.insert(list, tool) end
end
return list
end

fireTool = function(tool)
local P = portals[tool]
if not P or P.closing then return end
P.kick = 1
if not P.remote then
local nowF = os.clock()
if nowF - lastBarrage > 2.5 and CFG.impactOnFire then impactFrame(0.5) end
lastBarrage = nowF
end
P.pulseAt = os.clock() + 0.05
if P.emitter then P.emitter:Emit(6) end
if CFG.swords then spawnSword(P) end
if P.remote then playShot(P.core, 0.7) else playShot() end
end

local menuOpenNow = function() return getgenv().__BabylonMenuOpen == true end

fxConnect(RunService.RenderStepped, function()
local now = os.clock()
local dt = math.min(now - lastFx, 0.1)
lastFx = now
local c = char()
local root = c and c:FindFirstChild("HumanoidRootPart")
local floating = CFG.fx and enabled and userHeld ~= nil and root ~= nil
local tools = floating and floatingTools() or {}

local down = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
if down then
if not mouseWasDown then fallbackFor = now nextFallback = now + 0.35 end
elseif mouseWasDown then
mouseUpAt = now
end
mouseWasDown = down

for _, t in ipairs(tools) do watchTool(t) end

local wantMute = floating and CFG.muteGunSounds
if wantMute ~= muted then applyMute(wantMute) end

local want = {}
local remoteOwners = {}
for _, t in ipairs(tools) do want[t] = true end
if CFG.fx and CFG.watchOthers then
local shown = 0
for _, pl in ipairs(Players:GetPlayers()) do
if pl ~= lp and shown < 2 then
local ch = pl.Character
local rr = ch and ch:FindFirstChild("HumanoidRootPart")
if rr and (not root or (rr.Position - root.Position).Magnitude < CFG.watchRange) then
local guns = {}
for _, t in ipairs(ch:GetChildren()) do
if isGun(t) then table.insert(guns, t) end
end
if #guns >= 2 then
shown += 1
remoteOwners[pl] = { root = rr, ch = ch }
local flat = rr.CFrame.LookVector * Vector3.new(1, 0, 1)
if flat.Magnitude < 0.01 then flat = Vector3.new(0, 0, -1) end
local frame = CFrame.lookAt(rr.Position, rr.Position + flat.Unit)
local offs = remoteOffsets(#guns)
local look = rr.CFrame.LookVector
for i, t in ipairs(guns) do
want[t] = true
if not remoteWatched[t] then
remoteWatched[t] = true
hookAttrs(t)
for _, d in ipairs(t:GetDescendants()) do
if d:IsA("Sound") then
fxConnect(d.Played, function()
if looksLikeShot(d.Name) then onShot(t, "remote sound " .. d.Name) end
end)
end
end
end
local P = portals[t]
if CFG.portals and (not P or P.closing) then
if P then destroyPortal(P) end
P = newPortal(t, #guns)
P.remote = true
portals[t] = P
end
if P and not P.closing then
P.pos = frame * offs[i]
P.dir = look
end
end
end
end
end
end
end

if CFG.portals then
portalCount = #tools
for _, t in ipairs(tools) do
local P = portals[t]
if not P or P.closing then
if P then destroyPortal(P) end
portals[t] = newPortal(t, #tools)
end
end
end
for t, P in pairs(portals) do
if (not want[t]) or not CFG.portals then
if not P.closing then P.closing = true P.closedAt = now end
if now - P.closedAt > 0.32 then
destroyPortal(P)
portals[t] = nil
end
end
end

local target
if floating then
local cam = workspace.CurrentCamera
local loc = UIS:GetMouseLocation()
local ray = cam:ViewportPointToRay(loc.X, loc.Y)
rp.FilterDescendantsInstances = { c, folder() }
local hit = workspace:Raycast(ray.Origin, ray.Direction * 700, rp)
target = hit and hit.Position or (ray.Origin + ray.Direction * 500)
end

table.clear(cfParts)
table.clear(cfValues)
local center, nCenter = Vector3.zero, 0
for t, P in pairs(portals) do
local s = gunsState[t]
local h = s and s.handle
if P.remote then
if not P.closing then
center += P.pos
nCenter += 1
end
elseif h and h.Parent and not P.closing then
P.pos = h.Position
local d = target and (target - P.pos) or nil
if d and d.Magnitude > 6 then
P.dir = d.Unit
elseif root then
P.dir = root.CFrame.LookVector
end
center += P.pos
nCenter += 1
end
updatePortal(P, now)
end

local owners = {}
if CFG.fx and CFG.aura then
if floating and root then owners[lp] = { root = root, ch = c, isSelf = true } end
for pl, info in pairs(remoteOwners) do owners[pl] = info end
end
for owner, info in pairs(owners) do
local A = auras[owner]
if not A or A.closing then
if A then destroyAura(A) end
A = newAura(owner, info)
auras[owner] = A
onGateOpen(A)
end
A.root = info.root
end
for owner, A in pairs(auras) do
if not owners[owner] and not A.closing then
A.closing = true
A.closedAt = now
onGateClose(A)
end
updateAura(A, now)
if A.closing and now - A.closedAt > 0.8 then
destroyAura(A)
auras[owner] = nil
end
end

if CFG.hideGuns then
for t in pairs(want) do
hiddenNow[t] = true
setHidden(t, true)
end
end
for t in pairs(hiddenNow) do
if not (CFG.hideGuns and want[t]) then
pcall(setHidden, t, false)
hiddenNow[t] = nil
end
end

if floating and CFG.fallbackFire and down and not menuOpenNow() and now >= nextFallback
and now - lastShotAny > 0.45 and not UIS:GetFocusedTextBox() then
nextFallback = now + 0.17
dbg("fallback volley")
for _, t in ipairs(tools) do
lastShot[t] = nil
onShot(t, "fallback")
end
lastShotAny = 0
end

updateSwords(dt, now)
updatePulses(now)
if #cfParts > 0 then
pcall(function() workspace:BulkMoveTo(cfParts, cfValues, Enum.BulkMoveMode.FireCFrameChanged) end)
end

audioStep(dt, floating, nCenter > 0 and center / nCenter or (root and root.Position or nil))
end)

local function fxStop()
for _, cn in ipairs(fxConns) do cn:Disconnect() end
table.clear(fxConns)
applyMute(false)
unhideAll()
destroyAudio()
pcall(function() RunService:UnbindFromRenderStep("GateShake") end)
tintOff(true)
if impactCC then pcall(function() impactCC:Destroy() end) impactCC = nil end
if impactGui then pcall(function() impactGui:Destroy() end) impactGui = nil end
for _, A in pairs(auras) do destroyAura(A) end
table.clear(auras)
for _, P in pairs(portals) do destroyPortal(P) end
table.clear(portals)
for _, W in ipairs(swords) do killSword(W) end
table.clear(swords)
if fxFolder then pcall(function() fxFolder:Destroy() end) fxFolder = nil end
end

if CFG.autoDownload then task.spawn(fetchSounds) end
local floatApi = getgenv().FloatGuns
if floatApi then
local oldStop = floatApi.stop
floatApi.stop = function()
fxStop()
oldStop()
end
floatApi.fx = {
reloadSounds = function() table.clear(audioId) table.clear(audioTry) noThemeNote = false task.spawn(fetchSounds) end,
fetch = fetchSounds,
debug = function(on) debugOn = on ~= false print("[GateFX] debug", debugOn) end,
sounds = function()
for _, i in ipairs(gunSounds) do print("[GateFX] sound", i.snd:GetFullName(), i.vol) end
end,
test = function() for _, P in pairs(portals) do fireTool(P.tool) end end,
}
end
end)

run("Fuga", function()
local CFG = {
key = Enum.KeyCode.Z,
height = 9,          -- how high the ring floats above your feet
minRadius = 6,
spacing = 1.7,       -- room per bottle around the ring (the ring grows with more Molotovs)
spin = 1.6,          -- radians per second while it floats
chargeTime = 0.45,   -- seconds the ring spins up before it throws
gap = 0.05,          -- seconds between the throws of the "throw all" button
sprayGap = 0.12,     -- seconds between throws while you hold the mouse button (machine gun)
tilt = 40,           -- degrees the bottles lean outwards
bob = 0.25,
arrow = true,        -- the big flame arrow that forms while you spray (visual only)
impact = true,       -- one very short black/white "impact frame" flash when you start spraying (visual only)
mega = true,         -- shrine gate, sigil, lightning, ember storm, red sky, slashes and a giant kanji while you spray (visual only)
voiceVolume = 1.6,   -- volume of the voice line
voiceFile = "fuga_voice", -- put your own fuga_voice.mp3 (or .ogg / .wav) in the executor's workspace folder and it plays when you start spraying
cinematic = true,    -- black bars, dark red tint and the typed chant while you spray (visual only)
sound = true,        -- sound effects while you spray (the game's built-in sounds)
formation = "gyro",  -- how the Molotovs float while idle (other players see this): ring, gyro, wings, halo
pose = true,         -- raise your arms in a hand-sign pose while you spray (other players see this)
detach = false,      -- EXPERIMENT, KEEP OFF: placing the bottles directly made the server delete them after about 2.4 seconds
chat = false,        -- also say "Kai." / "FUGA." in the game chat when you spray. Off by default: the shared show works from the Molotov rockets themselves, so chat is not needed
watch = true,        -- show the Fuga effects around other players who run this script when their chat lines arrive
safeDistance = 25,   -- studs: a throw is held back if your cursor is pointing closer than this to you (it would burn you)
voiceId = "",        -- optional: your own Roblox audio id (for example "rbxassetid://123456") played when the ring fires
faceOffset = CFrame.Angles(math.rad(-90), 0, 0), -- how a bottle sits relative to its look direction
}
local on = false
local adopted = {}
local state = {}
local spinAngle = 0
local POSE_R, POSE_L = math.rad(110), math.rad(-110) -- arm raise angles: both arms point forward and slightly up (checked in game)
local FORMS = { "ring", "gyro", "wings", "halo" }
local smoothPos = setmetatable({}, { __mode = "k" })
local lastChat = 0
local cueSent = false
local fireBlend = 0 -- 0 = the ring floats around you, 1 = the Molotovs form a firing circle in front of you
local lastWarn = 0
local startT = 0
local chargeStart = nil
local volleying = false
local spraying = false
local sprayId = 0
local fired = setmetatable({}, { __mode = "k" }) -- Molotovs already thrown (they are removed a moment later)
local lastAdopt = 0
local conns = {}

local function char() return lp.Character end
local function molotovsIn(container)
local list = {}
if container then
for _, t in ipairs(container:GetChildren()) do
if t:IsA("Tool") and t.Name:lower():find("molotov", 1, true) and t:FindFirstChild("Handle") then
table.insert(list, t)
end
end
end
return list
end

local function gripFor(tool)
local c = char()
local handle = tool:FindFirstChild("Handle")
local arm = c and c:FindFirstChild("Right Arm")
if not arm or not handle then return end
for _, d in ipairs(arm:GetChildren()) do
if d:IsA("Weld") and d.Name == "RightGrip" and d.Part1 == handle then return d end
end
end

local function restoreOne(tool)
local st = state[tool]
if not st then return end
if st.grip and st.grip.Parent then
pcall(function() st.grip.Enabled = true end)
if st.part0 and st.part0.Parent then st.grip.Part0 = st.part0 end
st.grip.C0 = st.c0
end
local h = st.handle
if h and h.Parent then
h.Massless = st.massless
h.CanCollide = st.canCollide
h.AssemblyLinearVelocity = Vector3.zero
h.AssemblyAngularVelocity = Vector3.zero
end
state[tool] = nil
end

local mouse = lp:GetMouse()
local aimAt = setmetatable({}, { __mode = "k" })
local hooked = setmetatable({}, { __mode = "k" })
local function hookTool(tool)
if hooked[tool] then return end
local rf = tool:FindFirstChild("MouseLoc")
if not rf or not rf:IsA("RemoteFunction") then return end
hooked[tool] = true
pcall(function()
rf.OnClientInvoke = function()
local p = aimAt[tool]
if p then aimAt[tool] = nil return p end
return mouse.Hit.Position
end
end)
end
local function markAim(tool)
pcall(function() aimAt[tool] = mouse.Hit.Position end)
end

local FIRE_TEX = "rbxasset://textures/particles/fire_main.dmg"
local toolFx = setmetatable({}, { __mode = "k" })
local base = nil -- invisible anchored part at your feet: ember disc + light
local arrow = nil
local arrowState = "idle" -- idle | charge | launch
local arrowT = 0
local lastDir = Vector3.new(0, 0, -1)
local lastCenter = Vector3.zero
local cineCleanup = function() end -- set below, once the cinematic code exists
local function dropFx()
cineCleanup()
if arrow then pcall(function() arrow.part:Destroy() end) arrow = nil end
arrowState = "idle"
for tool, list in pairs(toolFx) do
for _, o in ipairs(list) do pcall(function() o:Destroy() end) end
end
table.clear(toolFx)
if base then pcall(function() base:Destroy() end) base = nil end
end
local function dressBottle(tool, handle)
if toolFx[tool] then return end
local made = {}
toolFx[tool] = made
pcall(function()
local a0 = Instance.new("Attachment")
a0.Position = Vector3.new(0, 0.7, 0)
a0.Parent = handle
local a1 = Instance.new("Attachment")
a1.Position = Vector3.new(0, -0.7, 0)
a1.Parent = handle
local trail = Instance.new("Trail")
trail.Attachment0, trail.Attachment1 = a0, a1
trail.Lifetime = 0.55
trail.LightEmission = 1
trail.FaceCamera = true
trail.Color = ColorSequence.new(Color3.fromRGB(255, 190, 70), Color3.fromRGB(200, 30, 10))
trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
trail.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.2) })
trail.Parent = handle
local fire = Instance.new("ParticleEmitter")
fire.Texture = FIRE_TEX
fire.LightEmission = 1
fire.Rate = 45
fire.Lifetime = NumberRange.new(0.4, 0.8)
fire.Speed = NumberRange.new(1, 3)
fire.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.8), NumberSequenceKeypoint.new(1, 0) })
fire.Color = ColorSequence.new(Color3.fromRGB(255, 220, 120), Color3.fromRGB(220, 50, 10))
fire.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
fire.Parent = handle
table.insert(made, a0) table.insert(made, a1) table.insert(made, trail) table.insert(made, fire)
end)
end
local function ensureBase()
if base and base.Parent then return base end
pcall(function()
local part = Instance.new("Part")
part.Name = "FugaFx"
part.Anchored = true
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.Transparency = 1
part.Size = Vector3.new(10, 0.2, 10)
local embers = Instance.new("ParticleEmitter")
embers.Name = "Embers"
embers.Texture = FIRE_TEX
embers.LightEmission = 1
embers.Rate = 25
embers.Lifetime = NumberRange.new(0.8, 1.6)
embers.Speed = NumberRange.new(3, 7)
embers.EmissionDirection = Enum.NormalId.Top
embers.Shape = Enum.ParticleEmitterShape.Disc
embers.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
embers.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.6), NumberSequenceKeypoint.new(1, 0) })
embers.Color = ColorSequence.new(Color3.fromRGB(255, 200, 90), Color3.fromRGB(190, 30, 10))
embers.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
embers.Parent = part
local col = Instance.new("Part")
col.Name = "Column"
col.Anchored = true
col.CanCollide = false
col.CanQuery = false
col.CanTouch = false
col.Transparency = 1
col.Size = Vector3.new(2, 0.2, 2)
local column = Instance.new("ParticleEmitter")
column.Name = "Flame"
column.Texture = FIRE_TEX
column.LightEmission = 1
column.Rate = 10
column.Lifetime = NumberRange.new(0.9, 1.5)
column.Speed = NumberRange.new(10, 16)
column.SpreadAngle = Vector2.new(6, 6)
column.EmissionDirection = Enum.NormalId.Top
column.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3.2), NumberSequenceKeypoint.new(1, 0) })
column.Color = ColorSequence.new(Color3.fromRGB(255, 235, 150), Color3.fromRGB(215, 40, 10))
column.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
column.Parent = col
col.Parent = part
local light = Instance.new("PointLight")
light.Name = "Glow"
light.Color = Color3.fromRGB(255, 130, 40)
light.Range = 24
light.Brightness = 1.2
light.Parent = part
part.Parent = workspace
base = part
end)
return base
end
local function pulse(root)
pcall(function()
local ring = Instance.new("Part")
ring.Name = "FugaPulse"
ring.Shape = Enum.PartType.Cylinder
ring.Anchored = true
ring.CanCollide = false
ring.CanQuery = false
ring.CanTouch = false
ring.Material = Enum.Material.Neon
ring.Color = Color3.fromRGB(255, 120, 30)
ring.Size = Vector3.new(0.4, 4, 4)
ring.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.pi / 2)
ring.Parent = workspace
local tw = TweenService:Create(ring, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
Size = Vector3.new(0.2, 46, 46),
Transparency = 1,
})
tw:Play()
tw.Completed:Once(function() ring:Destroy() end)
task.delay(1.5, function() if ring.Parent then ring:Destroy() end end)
end)
end

local function buildArrow()
if arrow and arrow.part.Parent then return arrow end
local ok, made = pcall(function()
local part = Instance.new("Part")
part.Name = "FugaArrow"
part.Anchored = true
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.Transparency = 1
part.Size = Vector3.new(0.2, 0.2, 0.2)
local function att(name, z)
local a = Instance.new("Attachment")
a.Name = name
a.Position = Vector3.new(0, 0, z)
a.Parent = part
return a
end
local aT, aS, aP = att("Tail", 0), att("ShaftEnd", -12), att("Tip", -17)
local function beam(a0, a1, c0, c1, transp)
local b = Instance.new("Beam")
b.Attachment0, b.Attachment1 = a0, a1
b.FaceCamera = true
b.LightEmission = 1
b.LightInfluence = 0
b.Segments = 1
b.Color = ColorSequence.new(c0, c1)
b.Transparency = NumberSequence.new(transp)
b.Enabled = false
b.Parent = part
return b
end
local white, hot, orange, red = Color3.fromRGB(255, 250, 225), Color3.fromRGB(255, 190, 80), Color3.fromRGB(255, 110, 25), Color3.fromRGB(190, 20, 10)
local a = {
part = part, aT = aT, aS = aS, aP = aP,
glow = beam(aT, aS, red, orange, 0.55),
shaft = beam(aT, aS, orange, white, 0),
headGlow = beam(aS, aP, orange, red, 0.5),
head = beam(aS, aP, white, white, 0),
}
a.bow = {}
a.bowBeams = {}
for i = 1, 7 do a.bow[i] = att("Bow" .. i, 0) end
for i = 1, 6 do
table.insert(a.bowBeams, beam(a.bow[i], a.bow[i + 1], red, hot, 0.1))
table.insert(a.bowBeams, beam(a.bow[i], a.bow[i + 1], orange, red, 0.55))
end
a.stringL = beam(a.bow[1], aT, white, white, 0.15)
a.stringR = beam(aT, a.bow[7], white, white, 0.15)
local fire = Instance.new("ParticleEmitter")
fire.Texture = FIRE_TEX
fire.LightEmission = 1
fire.Rate = 0
fire.Lifetime = NumberRange.new(0.4, 0.9)
fire.Speed = NumberRange.new(2, 8)
fire.SpreadAngle = Vector2.new(180, 180)
fire.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 2.4), NumberSequenceKeypoint.new(1, 0) })
fire.Color = ColorSequence.new(hot, red)
fire.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
fire.Parent = aT
a.fire = fire
part.Parent = workspace
return a
end)
if ok then arrow = made end
return arrow
end

local function arrowVisible(v)
if not arrow then return end
pcall(function()
arrow.glow.Enabled = v arrow.shaft.Enabled = v arrow.headGlow.Enabled = v arrow.head.Enabled = v
arrow.stringL.Enabled = v arrow.stringR.Enabled = v
for _, b in ipairs(arrow.bowBeams) do b.Enabled = v end
if not v then arrow.fire.Rate = 0 end
end)
end

local function updateArrow(root)
if arrowState == "idle" then
if arrow then arrowVisible(false) end
return
end
local a = buildArrow()
if not a then return end
local now = os.clock()
local origin = root.Position + Vector3.new(0, 8, 0)
local center, dir, scale, wm
if arrowState == "charge" then
local g = math.clamp((now - arrowT) / 0.55, 0, 1)
scale = 1 - (1 - g) ^ 3
local aim = mouse.Hit.Position - origin
dir = aim.Magnitude > 1 and aim.Unit or root.CFrame.LookVector
center = origin + dir * 1.5
lastDir, lastCenter = dir, center
wm = 1 + math.sin(now * 30) * 0.07
else
local t = (now - arrowT) / 0.4
if t >= 1 then
arrowState = "idle"
arrowVisible(false)
return
end
dir = lastDir
center = lastCenter + lastDir * (190 * (now - arrowT))
scale = 1
wm = 1 - t
end
arrowVisible(true)
local m = (0.3 + 0.7 * scale) * wm
pcall(function()
a.part.CFrame = CFrame.lookAt(center, center + dir)
local draw = arrowState == "charge" and (1 - scale) * 3 or 0 -- the string is drawn back while it forms
a.aT.Position = Vector3.new(0, 0, 2.5 * scale + draw)
a.aS.Position = Vector3.new(0, 0, -12 * scale)
a.aP.Position = Vector3.new(0, 0, -17 * scale)
a.shaft.Width0, a.shaft.Width1 = 1 * m, 1 * m
a.glow.Width0, a.glow.Width1 = 2.8 * m, 2.8 * m
a.head.Width0, a.head.Width1 = 4.2 * m, 0
a.headGlow.Width0, a.headGlow.Width1 = 7 * m, 0
for i = 1, 7 do
local k = (i - 4) / 3
a.bow[i].Position = Vector3.new(k * 7 * scale, 0, (-8 + 6.5 * k * k) * scale)
end
local bw = 0.8 * m
for i, b in ipairs(a.bowBeams) do
b.Width0, b.Width1 = bw * (i % 2 == 1 and 1 or 2.6), bw * (i % 2 == 1 and 1 or 2.6)
end
a.stringL.Width0, a.stringL.Width1 = 0.3 * m, 0.3 * m
a.stringR.Width0, a.stringR.Width1 = 0.3 * m, 0.3 * m
a.fire.Rate = 60 * scale * wm
end)
end

local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local function playSound(id, vol, speed)
if not CFG.sound then return end
pcall(function()
local snd = Instance.new("Sound")
snd.SoundId = id
snd.Volume = vol
snd.PlaybackSpeed = speed or 1
snd.Parent = SoundService
snd:Play()
Debris:AddItem(snd, 8)
end)
end
local S_BASS, S_BOOM, S_WHOOSH = "rbxasset://sounds/bass.wav", "rbxasset://sounds/impact_explosion_03.mp3", "rbxasset://sounds/Rocket whoosh 01.wav"
local S_LAUNCH, S_SLASH, S_THUNDER = "rbxasset://sounds/Launching rocket.wav", "rbxasset://sounds/swordslash.wav", "rbxasset://sounds/HalloweenThunder.wav"

local impacting = false
local function playImpact()
if not CFG.impact or impacting then return end
impacting = true
task.spawn(function()
pcall(function()
local gui = Instance.new("ScreenGui")
gui.Name = "FugaImpact"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 900
local f = Instance.new("Frame")
f.Size = UDim2.fromScale(1, 1)
f.BackgroundColor3 = Color3.new(1, 1, 1)
f.BorderSizePixel = 0
f.ClipsDescendants = true
f.Parent = gui
local lines = {}
for i = 0, 17 do -- speed lines radiating from the middle
local l = Instance.new("Frame")
l.AnchorPoint = Vector2.new(0.5, 0.5)
l.Position = UDim2.fromScale(0.5, 0.5)
l.Size = UDim2.new(0, 2600, 0, 2 + (i * 7 % 5) * 3)
l.Rotation = i * 10 + (i % 2) * 3
l.BackgroundColor3 = Color3.new(0, 0, 0)
l.BorderSizePixel = 0
l.ZIndex = 2
l.Parent = f
table.insert(lines, l)
end
local hole = Instance.new("Frame") -- keeps the middle clear so the lettering reads
hole.AnchorPoint = Vector2.new(0.5, 0.5)
hole.Position = UDim2.fromScale(0.5, 0.5)
hole.Size = UDim2.fromOffset(300, 300)
hole.BackgroundTransparency = 1
hole.ZIndex = 3
hole.Parent = f
local txt = Instance.new("TextLabel")
txt.AnchorPoint = Vector2.new(0.5, 0.5)
txt.Position = UDim2.fromScale(0.5, 0.5)
txt.Size = UDim2.fromScale(0.9, 0.34)
txt.BackgroundTransparency = 1
txt.Text = "FUGA"
txt.Font = Enum.Font.GothamBlack
txt.TextScaled = true
txt.TextColor3 = Color3.fromRGB(235, 20, 20)
txt.TextStrokeColor3 = Color3.new(1, 1, 1)
txt.TextStrokeTransparency = 0
txt.Rotation = -6
txt.ZIndex = 5
txt.Visible = false
txt.Parent = f
gui.Parent = lp:WaitForChild("PlayerGui")
local cam = workspace.CurrentCamera
local fov0 = cam.FieldOfView
pcall(function() TweenService:Create(cam, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = fov0 + 10 }):Play() end)
local function paint(bg, lineColor, showText)
f.BackgroundColor3 = bg
for _, l in ipairs(lines) do l.BackgroundColor3 = lineColor end
txt.Visible = showText
end
paint(Color3.new(1, 1, 1), Color3.new(0, 0, 0), false)   -- 1: white, black lines
task.wait(0.045)
paint(Color3.new(0, 0, 0), Color3.new(1, 1, 1), true)    -- 2: black, white lines, red lettering
task.wait(0.06)
paint(Color3.fromRGB(190, 12, 12), Color3.new(0, 0, 0), false) -- 3: red, black lines
task.wait(0.05)
pcall(function() TweenService:Create(cam, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { FieldOfView = fov0 }):Play() end)
for _, l in ipairs(lines) do l.Visible = false end
local tw = TweenService:Create(f, TweenInfo.new(0.22, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 })
tw:Play()
tw.Completed:Wait()
gui:Destroy()
end)
impacting = false
end)
end

local cine = nil
local function cineOff(instant)
local c = cine
if not c then return end
cine = nil
pcall(function()
if instant then
c.gui:Destroy()
c.cc:Destroy()
return
end
local info = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
TweenService:Create(c.top, info, { Size = UDim2.new(1, 0, 0, 0) }):Play()
TweenService:Create(c.bottom, info, { Size = UDim2.new(1, 0, 0, 0) }):Play()
TweenService:Create(c.sub, info, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
TweenService:Create(c.cc, info, { TintColor = Color3.new(1, 1, 1), Saturation = 0, Contrast = 0, Brightness = 0 }):Play()
task.delay(0.5, function()
pcall(function() c.gui:Destroy() end)
pcall(function() c.cc:Destroy() end)
end)
end)
end
local function cineOn()
if not CFG.cinematic or cine then return end
pcall(function()
local gui = Instance.new("ScreenGui")
gui.Name = "FugaCine"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 800
local function bar(anchorY, posY)
local b = Instance.new("Frame")
b.AnchorPoint = Vector2.new(0, anchorY)
b.Position = UDim2.fromScale(0, posY)
b.Size = UDim2.new(1, 0, 0, 0)
b.BackgroundColor3 = Color3.new(0, 0, 0)
b.BorderSizePixel = 0
b.Parent = gui
return b
end
local top, bottom = bar(0, 0), bar(1, 1)
local sub = Instance.new("TextLabel")
sub.AnchorPoint = Vector2.new(0.5, 1)
sub.Position = UDim2.new(0.5, 0, 0.86, 0)
sub.Size = UDim2.new(0.8, 0, 0, 46)
sub.BackgroundTransparency = 1
sub.Text = ""
sub.Font = Enum.Font.GothamBlack
sub.TextSize = 34
sub.TextColor3 = Color3.fromRGB(255, 70, 40)
sub.TextStrokeColor3 = Color3.new(0, 0, 0)
sub.TextStrokeTransparency = 0
sub.Parent = gui
local cc = Instance.new("ColorCorrectionEffect")
cc.Name = "FugaTint"
cc.Parent = game:GetService("Lighting")
gui.Parent = lp:WaitForChild("PlayerGui")
local info = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(top, info, { Size = UDim2.new(1, 0, 0.1, 0) }):Play()
TweenService:Create(bottom, info, { Size = UDim2.new(1, 0, 0.1, 0) }):Play()
TweenService:Create(cc, info, { TintColor = Color3.fromRGB(255, 205, 190), Saturation = -0.3, Contrast = 0.22, Brightness = -0.05 }):Play()
local mine = { gui = gui, top = top, bottom = bottom, sub = sub, cc = cc }
cine = mine
task.spawn(function()
local line = "Kai."
for i = 1, #line do
if cine ~= mine then return end
sub.Text = line:sub(1, i)
task.wait(0.07)
end
task.wait(0.35)
local line2 = "FUGA."
sub.TextSize = 44
for i = 1, #line2 do
if cine ~= mine then return end
sub.Text = line2:sub(1, i)
task.wait(0.06)
end
end)
end)
end

local Lighting = game:GetService("Lighting")
local skyOrig, bloomFx, skyUsers = nil, nil, 0
local shakeUntil, shakeMag = 0, 0
local selfShow = nil
local remoteShows = {}
local RED, WHITE = Color3.fromRGB(255, 40, 20), Color3.fromRGB(255, 235, 215)

local function newPart(folder, size, color, material, shape)
local p = Instance.new("Part")
p.Anchored = true
p.CanCollide = false
p.CanQuery = false
p.CanTouch = false
p.CastShadow = false
p.Size = size
p.Color = color
p.Material = material or Enum.Material.Neon
if shape then p.Shape = shape end
p.Parent = folder
return p
end

local function groundYAt(pos, ignore)
local y = pos.Y - 2.9
pcall(function()
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude
rp.FilterDescendantsInstances = { ignore }
local hit = workspace:Raycast(pos, Vector3.new(0, -14, 0), rp)
if hit then y = hit.Position.Y + 0.15 end
end)
return y
end

local function shake(mag, dur)
shakeMag = math.max(shakeMag, mag)
shakeUntil = math.max(shakeUntil, os.clock() + dur)
end

local function skyOn()
skyUsers += 1
if skyOrig then return end
skyOrig = {
Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, Brightness = Lighting.Brightness,
FogColor = Lighting.FogColor, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
ExposureCompensation = Lighting.ExposureCompensation,
}
TweenService:Create(Lighting, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {
Ambient = Color3.fromRGB(110, 14, 10), OutdoorAmbient = Color3.fromRGB(120, 18, 12),
FogColor = Color3.fromRGB(70, 0, 0), FogStart = 60, FogEnd = 520, ExposureCompensation = -0.5,
}):Play()
pcall(function()
bloomFx = Instance.new("BloomEffect")
bloomFx.Name = "FugaBloom"
bloomFx.Intensity = 0
bloomFx.Size = 24
bloomFx.Threshold = 1.0
bloomFx.Parent = Lighting
TweenService:Create(bloomFx, TweenInfo.new(0.5), { Intensity = 0.7 }):Play()
end)
end
local function skyOff(instant)
skyUsers = math.max(0, skyUsers - 1)
if skyUsers > 0 and not instant then return end
if instant then skyUsers = 0 end
local o = skyOrig
skyOrig = nil
if bloomFx then
local b = bloomFx
bloomFx = nil
if instant then pcall(function() b:Destroy() end)
else
TweenService:Create(b, TweenInfo.new(0.7), { Intensity = 0 }):Play()
task.delay(0.8, function() pcall(function() b:Destroy() end) end)
end
end
if o then
if instant then
for k, v in pairs(o) do pcall(function() Lighting[k] = v end) end
else
TweenService:Create(Lighting, TweenInfo.new(0.9, Enum.EasingStyle.Quad), o):Play()
end
end
end

local function bolt(folder, from, to, color)
local segs, prev = 9, from
for i = 1, segs do
local p = from:Lerp(to, i / segs)
if i < segs then p += Vector3.new((math.random() - 0.5) * 9, 0, (math.random() - 0.5) * 9) end
local len = (p - prev).Magnitude
if len > 0.1 then
local seg = newPart(folder, Vector3.new(0.45, 0.45, len), color)
seg.CFrame = CFrame.lookAt((prev + p) / 2, p)
Debris:AddItem(seg, 0.14)
end
prev = p
end
end

local function fireEmitter(parent, rate, life, speed, size, spread)
local e = Instance.new("ParticleEmitter")
e.Texture = FIRE_TEX
e.LightEmission = 1
e.Rate = rate
e.Lifetime = life
e.Speed = speed
e.SpreadAngle = spread or Vector2.new(10, 10)
e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, 0) })
e.Color = ColorSequence.new(Color3.fromRGB(255, 220, 130), Color3.fromRGB(210, 30, 10))
e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 1) })
e.Parent = parent
return e
end

local function screenShow(S, withKanji)
pcall(function()
if not S.gui then
S.gui = Instance.new("ScreenGui")
S.gui.Name = "FugaMegaGui"
S.gui.IgnoreGuiInset = true
S.gui.ResetOnSpawn = false
S.gui.DisplayOrder = 40
S.gui.Parent = lp:WaitForChild("PlayerGui")
end
local gui = S.gui
task.spawn(function()
for i = 1, 8 do
if S.gui ~= gui then return end
pcall(function()
local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
local glow = Instance.new("Frame")
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Position = UDim2.fromOffset(vp.X * (0.2 + math.random() * 0.6), vp.Y * (0.2 + math.random() * 0.6))
glow.Size = UDim2.fromOffset(0, 16)
glow.Rotation = math.random(-35, 35) + (i % 2 == 0 and 180 or 0)
glow.BackgroundColor3 = RED
glow.BorderSizePixel = 0
glow.Parent = gui
local core = Instance.new("Frame")
core.AnchorPoint = Vector2.new(0.5, 0.5)
core.Position = UDim2.fromScale(0.5, 0.5)
core.Size = UDim2.new(1, 0, 0, 4)
core.BackgroundColor3 = Color3.new(1, 1, 1)
core.BorderSizePixel = 0
core.Parent = glow
TweenService:Create(glow, TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(vp.X * 1.5, 16) }):Play()
task.delay(0.1, function()
TweenService:Create(glow, TweenInfo.new(0.35), { BackgroundTransparency = 1, Size = UDim2.fromOffset(vp.X * 1.5, 2) }):Play()
TweenService:Create(core, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
end)
Debris:AddItem(glow, 0.7)
end)
playSound(S_SLASH, 0.5, 0.9 + math.random() * 0.4)
task.wait(0.05)
end
end)
if withKanji then
task.delay(0.45, function()
if S.gui ~= gui then return end
pcall(function()
local lbl = Instance.new("TextLabel")
lbl.AnchorPoint = Vector2.new(0.5, 0.5)
lbl.Position = UDim2.fromScale(0.5, 0.4)
lbl.Size = UDim2.fromOffset(1000, 1000)
lbl.BackgroundTransparency = 1
lbl.Text = "開"
lbl.Font = Enum.Font.GothamBlack
lbl.TextScaled = true
lbl.TextColor3 = Color3.fromRGB(255, 245, 235)
lbl.TextTransparency = 1
lbl.Parent = gui
local stroke = Instance.new("UIStroke")
stroke.Color = RED
stroke.Thickness = 14
stroke.Transparency = 1
stroke.Parent = lbl
TweenService:Create(lbl, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(380, 380), TextTransparency = 0.05 }):Play()
TweenService:Create(stroke, TweenInfo.new(0.22), { Transparency = 0 }):Play()
shake(1.6, 0.35)
playSound(S_BOOM, 1, 0.7)
task.delay(1.1, function()
TweenService:Create(lbl, TweenInfo.new(0.7), { TextTransparency = 1, Size = UDim2.fromOffset(520, 520) }):Play()
TweenService:Create(stroke, TweenInfo.new(0.7), { Transparency = 1 }):Play()
end)
end)
end)
end
end)
end

local function bigBoom(pos)
pcall(function()
local function sphere(color, endSize, dur, startT)
local p = Instance.new("Part")
p.Shape = Enum.PartType.Ball
p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch, p.CastShadow = true, false, false, false, false
p.Material = Enum.Material.Neon
p.Color = color
p.Transparency = startT
p.Size = Vector3.new(6, 6, 6)
p.CFrame = CFrame.new(pos)
p.Parent = workspace
TweenService:Create(p, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(endSize, endSize, endSize), Transparency = 1 }):Play()
Debris:AddItem(p, dur + 0.2)
end
sphere(Color3.fromRGB(255, 80, 20), 150, 0.9, 0.15)
sphere(Color3.fromRGB(255, 240, 220), 70, 0.45, 0)
for i = 1, 3 do
local ring = Instance.new("Part")
ring.Shape = Enum.PartType.Cylinder
ring.Anchored, ring.CanCollide, ring.CanQuery, ring.CanTouch, ring.CastShadow = true, false, false, false, false
ring.Material = Enum.Material.Neon
ring.Color = i == 2 and Color3.fromRGB(255, 235, 215) or Color3.fromRGB(255, 40, 20)
ring.Size = Vector3.new(0.6, 8, 8)
ring.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(i * 55), math.rad(i * 70), math.pi / 2)
ring.Parent = workspace
TweenService:Create(ring, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.8, 200, 200), Transparency = 1 }):Play()
Debris:AddItem(ring, 1)
end
local sp = Instance.new("Part")
sp.Anchored, sp.CanCollide, sp.CanQuery, sp.CanTouch = true, false, false, false
sp.Transparency = 1
sp.Size = Vector3.new(1, 1, 1)
sp.CFrame = CFrame.new(pos)
sp.Parent = workspace
local e = fireEmitter(sp, 0, NumberRange.new(1, 2.2), NumberRange.new(40, 120), 9, Vector2.new(180, 180))
e:Emit(260)
Debris:AddItem(sp, 3)
local me = char() and char():FindFirstChild("HumanoidRootPart")
if me and (me.Position - pos).Magnitude < 400 then shake(1.2, 0.5) end
playSound(S_BOOM, 1, 0.6)
playSound(S_THUNDER, 0.8, 0.9)
end)
end

local function newShow(opts)
local S = { on = false, folder = nil, gui = nil, conns = {}, usesSky = false }
local sigil, shrine, bottles = {}, {}, {}
local center, frameCF, t0 = Vector3.zero, CFrame.new(), 0
local lance, lanceGlow, lanceBits = nil, nil, {}
local launchT, launchFrom, launchDir = nil, nil, nil

local function polygon(sides, radius, rot, color, dir, thick)
for i = 1, sides do
local a1 = rot + (i - 1) * 2 * math.pi / sides
local a2 = rot + i * 2 * math.pi / sides
local v1 = Vector3.new(math.cos(a1), 0, math.sin(a1)) * radius
local v2 = Vector3.new(math.cos(a2), 0, math.sin(a2)) * radius
local mid = (v1 + v2) / 2
local th = thick or 0.5
local p = newPart(S.folder, Vector3.new(th, 0.3, (v2 - v1).Magnitude + th * 0.8), color)
table.insert(sigil, { part = p, off = CFrame.lookAt(mid + Vector3.new(0, 0.1, 0), mid + (v2 - v1) + Vector3.new(0, 0.1, 0)), spin = dir })
end
end
local function buildSigil()
polygon(36, 15, 0, RED, 1, 0.7)
polygon(30, 12.4, 0, WHITE, 1, 0.4)
polygon(20, 5.5, 0, RED, 1, 0.5)
polygon(4, 11.2, math.pi / 4, RED, 1)
polygon(4, 11.2, 0, RED, 1)
polygon(3, 7, 0, WHITE, -1.6)
polygon(3, 7, math.pi, WHITE, -1.6)
for i = 1, 16 do
local a = i * 2 * math.pi / 16
local d = Vector3.new(math.cos(a), 0, math.sin(a))
local p = newPart(S.folder, Vector3.new(0.45, 0.3, 2.4), i % 2 == 0 and RED or WHITE)
table.insert(sigil, { part = p, off = CFrame.lookAt(d * 13.7 + Vector3.new(0, 0.1, 0), d * 20 + Vector3.new(0, 0.1, 0)), spin = 1 })
end
end

local function buildShrine(pos, towards)
local K = 0.8
local dark = Color3.fromRGB(24, 12, 12)
frameCF = CFrame.lookAt(pos, towards)
local function add(size, off, color, material, shape, fire)
local p = newPart(S.folder, size * K, color, material, shape)
table.insert(shrine, { part = p, off = CFrame.new(off.Position * K) * (off - off.Position), fire = fire })
if fire then fireEmitter(p, 18, NumberRange.new(0.8, 1.6), NumberRange.new(6, 12), 7, Vector2.new(20, 20)) p.Transparency = 1 end
return p
end
local cyl = Enum.PartType.Cylinder
for _, sx in ipairs({ -20, 20 }) do
add(Vector3.new(36, 4.2, 4.2), CFrame.new(sx, 18, 0) * CFrame.Angles(0, 0, math.pi / 2), dark, Enum.Material.Slate, cyl)
for _, yy in ipairs({ 3, 11, 19 }) do
add(Vector3.new(0.7, 4.9, 4.9), CFrame.new(sx, yy, 0) * CFrame.Angles(0, 0, math.pi / 2), RED, Enum.Material.Neon, cyl)
end
end
add(Vector3.new(56, 2, 2.4), CFrame.new(0, 24, 0), dark, Enum.Material.Slate)
add(Vector3.new(56, 0.35, 2.7), CFrame.new(0, 25.1, 0), RED)
add(Vector3.new(66, 3, 3.2), CFrame.new(0, 31, 0), dark, Enum.Material.Slate)
add(Vector3.new(66, 0.4, 3.5), CFrame.new(0, 32.7, 0), RED)
add(Vector3.new(86, 3, 10), CFrame.new(0, 35, 0), dark, Enum.Material.Slate)
add(Vector3.new(86, 0.45, 10.4), CFrame.new(0, 33.4, 0), RED)
add(Vector3.new(15, 3, 10), CFrame.new(-44, 36.8, 0) * CFrame.Angles(0, 0, math.rad(20)), dark, Enum.Material.Slate)
add(Vector3.new(15, 3, 10), CFrame.new(44, 36.8, 0) * CFrame.Angles(0, 0, math.rad(-20)), dark, Enum.Material.Slate)
add(Vector3.new(60, 3, 7), CFrame.new(0, 38.6, 0), dark, Enum.Material.Slate)
add(Vector3.new(60, 0.4, 7.4), CFrame.new(0, 40.2, 0), RED)
local eye = add(Vector3.new(6, 6, 6), CFrame.new(0, 28, 0), RED, Enum.Material.Neon, Enum.PartType.Ball)
local light = Instance.new("PointLight")
light.Color = Color3.fromRGB(255, 60, 30)
light.Range = 70
light.Brightness = 4
light.Parent = eye
add(Vector3.new(1.4, 6, 6.2), CFrame.new(0, 28, 0), WHITE, Enum.Material.Neon, Enum.PartType.Ball)
for _, fx in ipairs({ -36, -18, 0, 18, 36 }) do
add(Vector3.new(1, 1, 1), CFrame.new(fx, 41, 0), RED, Enum.Material.Neon, nil, true)
end
end

local function buildBottles()
for i = 1, 9 do
local b = newPart(S.folder, Vector3.new(2.6, 0.95, 0.95), Color3.fromRGB(95, 52, 22), Enum.Material.Glass, Enum.PartType.Cylinder)
local cap = newPart(S.folder, Vector3.new(0.6, 1.05, 1.05), Color3.fromRGB(255, 120, 30), Enum.Material.Neon, Enum.PartType.Cylinder)
local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
a0.Position, a1.Position = Vector3.new(0, 0.5, 0), Vector3.new(0, -0.5, 0)
a0.Parent, a1.Parent = b, b
local tr = Instance.new("Trail")
tr.Attachment0, tr.Attachment1 = a0, a1
tr.Lifetime = 0.5
tr.LightEmission = 1
tr.Color = ColorSequence.new(Color3.fromRGB(255, 190, 70), Color3.fromRGB(200, 30, 10))
tr.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
tr.Parent = b
fireEmitter(cap, 35, NumberRange.new(0.4, 0.8), NumberRange.new(1, 3), 1.6, Vector2.new(15, 15))
table.insert(bottles, { body = b, cap = cap, i = i })
end
end

function S.start()
if S.on then return end
local root = opts.getRoot()
if not root then return end
S.on = true
t0 = os.clock()
S.folder = Instance.new("Folder")
S.folder.Name = "FugaMega"
S.folder.Parent = workspace
local gy = groundYAt(root.Position, root.Parent)
center = Vector3.new(root.Position.X, gy, root.Position.Z)
local flat
if opts.isSelf then
local cam = workspace.CurrentCamera
flat = cam and cam.CFrame.LookVector * Vector3.new(1, 0, 1) or Vector3.zero
else
local me = char() and char():FindFirstChild("HumanoidRootPart")
flat = me and ((root.Position - me.Position) * Vector3.new(1, 0, 1)) or Vector3.zero
end
if flat.Magnitude < 0.05 then flat = Vector3.new(0, 0, -1) end
flat = flat.Unit
buildSigil()
buildShrine(center + flat * 90, center)
if not opts.isSelf then buildBottles() end
local storm = newPart(S.folder, Vector3.new(80, 1, 80), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic)
storm.Transparency = 1
local em = fireEmitter(storm, 140, NumberRange.new(2.5, 4.5), NumberRange.new(10, 24), 1.1, Vector2.new(0, 0))
em.EmissionDirection = Enum.NormalId.Top
em.Shape = Enum.ParticleEmitterShape.Box
local ash = Instance.new("ParticleEmitter")
ash.Texture = "rbxasset://textures/particles/smoke_main.dds"
ash.Rate = 30
ash.Lifetime = NumberRange.new(3, 5)
ash.Speed = NumberRange.new(4, 10)
ash.EmissionDirection = Enum.NormalId.Top
ash.Shape = Enum.ParticleEmitterShape.Box
ash.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 6), NumberSequenceKeypoint.new(1, 12) })
ash.Color = ColorSequence.new(Color3.fromRGB(40, 5, 5))
ash.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) })
ash.Parent = storm
local pillar
if not opts.isSelf then
pillar = newPart(S.folder, Vector3.new(260, 3, 3), RED, Enum.Material.Neon, Enum.PartType.Cylinder)
pillar.Transparency = 0.45
end
if not opts.isSelf then
lance = newPart(S.folder, Vector3.new(70, 2.4, 2.4), Color3.fromRGB(255, 225, 190), Enum.Material.Neon, Enum.PartType.Cylinder)
lanceGlow = newPart(S.folder, Vector3.new(74, 6, 6), Color3.fromRGB(255, 60, 20), Enum.Material.Neon, Enum.PartType.Cylinder)
lanceGlow.Transparency = 0.6
local tip = newPart(S.folder, Vector3.new(8, 5, 5), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, Enum.PartType.Ball)
table.insert(lanceBits, tip)
local fe = fireEmitter(lance, 90, NumberRange.new(0.5, 1.1), NumberRange.new(3, 9), 5, Vector2.new(25, 25))
fe.EmissionDirection = Enum.NormalId.Left
end
for i = 1, 8 do
local a = i * 2 * math.pi / 8
local p = newPart(S.folder, Vector3.new(1, 1, 1), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic)
p.Transparency = 1
p.Position = center + Vector3.new(math.cos(a) * 16, 0.5, math.sin(a) * 16)
local fe = fireEmitter(p, 70, NumberRange.new(0.8, 1.4), NumberRange.new(18, 30), 5, Vector2.new(5, 5))
fe.EmissionDirection = Enum.NormalId.Top
table.insert(shrine, { part = p, fixed = true, rel = Vector3.new(math.cos(a) * 16, 0.5, math.sin(a) * 16) })
end
local near = true
if not opts.isSelf then
local me = char() and char():FindFirstChild("HumanoidRootPart")
near = me and (me.Position - root.Position).Magnitude < 130
end
if near then S.usesSky = true skyOn() end
if opts.isSelf then
screenShow(S, true)
shake(1.1, 0.6)
end
for i = 0, 2 do
task.delay(i * 0.18, function()
if not S.on then return end
pcall(function()
local ring = newPart(S.folder, Vector3.new(0.5, 4, 4), i == 1 and WHITE or RED, Enum.Material.Neon, Enum.PartType.Cylinder)
ring.CFrame = CFrame.new(center + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, 0, math.pi / 2)
TweenService:Create(ring, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Vector3.new(0.4, 150, 150), Transparency = 1 }):Play()
Debris:AddItem(ring, 1.1)
end)
end)
end
local lastBolt = 0
table.insert(S.conns, RunService.RenderStepped:Connect(function()
if not S.on then return end
local r = opts.getRoot()
if not r or not r.Parent then S.stop(true) return end
local now = os.clock()
local age = now - t0
local alpha = math.clamp(age / 0.6, 0, 1)
center = Vector3.new(r.Position.X, center.Y, r.Position.Z)
local spin = age * 0.8
local cf0 = CFrame.new(center)
for _, rec in ipairs(sigil) do
rec.part.CFrame = cf0 * CFrame.Angles(0, spin * rec.spin, 0) * rec.off
rec.part.Transparency = 1 - 0.7 * alpha
end
local rise = math.clamp(age / 1.0, 0, 1)
local e = 1 + 2.2 * (rise - 1) ^ 3 + 1.2 * (rise - 1) ^ 2
local lift = -60 * (1 - e)
for _, rec in ipairs(shrine) do
if rec.fixed then
rec.part.Position = center + rec.rel
else
rec.part.CFrame = frameCF * CFrame.new(0, lift, 0) * rec.off
if not rec.fire then rec.part.Transparency = math.clamp(1 - rise * 1.1, 0, 1) * 0.9 end
end
end
storm.CFrame = CFrame.new(r.Position - Vector3.new(0, 6, 0))
if pillar then
pillar.CFrame = CFrame.new(r.Position + Vector3.new(0, 110, 0)) * CFrame.Angles(0, 0, math.pi / 2)
pillar.Transparency = 0.4 + math.sin(now * 14) * 0.12
end
if lance then
local look = r.CFrame.LookVector
local cf
if launchT then
local travel = (now - launchT) * 650
local pos = launchFrom + launchDir * travel
cf = CFrame.lookAt(pos, pos + launchDir) * CFrame.Angles(0, math.rad(90), 0)
if travel > 300 and not S.boomed then
S.boomed = true
bigBoom(pos)
lance.Transparency, lanceGlow.Transparency = 1, 1
for _, b in ipairs(lanceBits) do b.Transparency = 1 end
local em = lance:FindFirstChildOfClass("ParticleEmitter")
if em then em.Enabled = false end
end
else
local pos = r.Position + Vector3.new(0, 13 + math.sin(now * 3) * 0.6, 0) + look * 6
local grow = math.clamp(age / 0.8, 0, 1)
cf = CFrame.lookAt(pos, pos + look) * CFrame.Angles(0, math.rad(90), 0)
lance.Size = Vector3.new(70 * grow, 2.4, 2.4) * (1 + math.sin(now * 12) * 0.03)
lanceGlow.Size = Vector3.new(74 * grow, 6 + math.sin(now * 9) * 1.2, 6 + math.sin(now * 9) * 1.2)
end
lance.CFrame = cf
lanceGlow.CFrame = cf
for _, b in ipairs(lanceBits) do b.CFrame = cf * CFrame.new(lance.Size.X / 2 + 1, 0, 0) end
end
local n = #bottles
for _, b in ipairs(bottles) do
local k = (b.i - 1) % 3
local m = math.max(1, math.ceil((n - k) / 3))
local j = (b.i - 1 - k) // 3
local R = 5.8 * math.clamp(age / 0.7, 0, 1)
local ang = spin * 1.6 * (k % 2 == 0 and 1.3 or -1.3) + j * 2 * math.pi / m
local tilt = k == 0 and CFrame.new() or (k == 1 and CFrame.Angles(math.rad(62), 0, 0) or CFrame.Angles(0, 0, math.rad(62)))
local rot = CFrame.Angles(0, spin * 0.6, 0) * tilt
local off = rot:VectorToWorldSpace(Vector3.new(math.cos(ang), 0, math.sin(ang))) * R
local pos = r.Position + Vector3.new(0, 4.5, 0) + off
local face = CFrame.lookAt(pos, pos + off) * CFrame.Angles(math.rad(-90), 0, 0)
b.body.CFrame = face * CFrame.Angles(0, 0, math.pi / 2)
b.cap.CFrame = face * CFrame.new(0, 1.55, 0) * CFrame.Angles(0, 0, math.pi / 2)
end
if now - lastBolt > 0.16 then
lastBolt = now
for _ = 1, 2 do
local a = math.random() * 2 * math.pi
local d = 14 + math.random() * 55
local top = r.Position + Vector3.new(math.cos(a) * d, 85, math.sin(a) * d)
bolt(S.folder, top, Vector3.new(top.X, center.Y, top.Z), math.random() < 0.5 and Color3.fromRGB(255, 60, 40) or WHITE)
end
end
if opts.isSelf then
local hum = char() and char():FindFirstChildOfClass("Humanoid")
if hum then
if now < shakeUntil then
local m = shakeMag * math.clamp((shakeUntil - now) / 0.5, 0.15, 1)
hum.CameraOffset = Vector3.new((math.random() - 0.5) * m, (math.random() - 0.5) * m, 0)
else
shakeMag = 0
if hum.CameraOffset ~= Vector3.zero then hum.CameraOffset = Vector3.zero end
end
end
end
end))
if not opts.isSelf then
playSound(S_BASS, 0.7, 0.8)
playSound(S_WHOOSH, 0.4, 0.6)
end
end

function S.flash()
if not S.on then return end
local root = opts.getRoot()
if lance and not launchT then
launchT = os.clock()
launchFrom = lance.Position
launchDir = root and root.CFrame.LookVector or Vector3.new(0, 0, -1)
playSound(S_LAUNCH, 0.9, 0.8)
end
local me = char() and char():FindFirstChild("HumanoidRootPart")
if root and me and (me.Position - root.Position).Magnitude < 160 then
screenShow(S, false)
shake(0.9, 0.35)
end
playSound(S_THUNDER, 0.7, 1.1)
playSound(S_BOOM, 0.8, 0.7)
end

function S.stop(instant)
if not S.on and not S.folder and not S.gui then return end
S.on = false
if S.usesSky then S.usesSky = false skyOff(instant) end
for _, cn in ipairs(S.conns) do pcall(function() cn:Disconnect() end) end
table.clear(S.conns)
if opts.isSelf then
local hum = char() and char():FindFirstChildOfClass("Humanoid")
if hum then pcall(function() hum.CameraOffset = Vector3.zero end) end
shakeUntil, shakeMag = 0, 0
end
local folder, gui = S.folder, S.gui
S.folder, S.gui = nil, nil
if instant then
if folder then pcall(function() folder:Destroy() end) end
if gui then pcall(function() gui:Destroy() end) end
else
if folder then
for _, d in ipairs(folder:GetChildren()) do
if d:IsA("BasePart") then pcall(function() TweenService:Create(d, TweenInfo.new(0.8, Enum.EasingStyle.Quad), { Transparency = 1 }):Play() end) end
end
for _, d in ipairs(folder:GetDescendants()) do
if d:IsA("ParticleEmitter") then d.Enabled = false end
end
task.delay(1.2, function() pcall(function() folder:Destroy() end) end)
end
if gui then task.delay(1.5, function() pcall(function() gui:Destroy() end) end) end
end
table.clear(sigil)
table.clear(shrine)
table.clear(bottles)
end
return S
end

local function megaStart()
if not CFG.mega then return end
if selfShow then selfShow.stop(true) end
selfShow = newShow({ isSelf = true, getRoot = function() local c = char() return c and c:FindFirstChild("HumanoidRootPart") end })
selfShow.start()
end
local function megaStop(instant)
if selfShow then
local s = selfShow
selfShow = nil
s.stop(instant)
end
end
local function megaKick() -- one small shake per Molotov thrown
if selfShow then shake(0.35, 0.18) end
end
local function megaStopAll()
megaStop(true)
for p, s in pairs(remoteShows) do pcall(function() s.stop(true) end) remoteShows[p] = nil end
end

local voiceAsset = nil
local myVoice = nil
local function voiceId()
if voiceAsset then return voiceAsset end
if not (isfile and getcustomasset) then return nil end
local id
pcall(function()
for _, ext in ipairs({ ".mp3", ".ogg", ".wav" }) do
local name = CFG.voiceFile .. ext
if isfile(name) then id = getcustomasset(name) break end
end
end)
voiceAsset = id
return id
end
local function playVoice(parent, mul)
local ok, snd = pcall(function()
local id = voiceId()
if not id then return nil end
local sn = Instance.new("Sound")
sn.SoundId = id
sn.Volume = CFG.voiceVolume * (mul or 1)
if parent then
sn.RollOffMinDistance = 20
sn.RollOffMaxDistance = 220
end
sn.Parent = parent or SoundService
sn:Play()
Debris:AddItem(sn, 45)
return sn
end)
return ok and snd or nil
end
local function fadeVoice(sn, delay)
if not sn then return end
task.delay(delay or 0, function()
if not sn.Parent then return end
TweenService:Create(sn, TweenInfo.new(1.2), { Volume = 0 }):Play()
task.delay(1.3, function() pcall(function() sn:Destroy() end) end)
end)
end

local function remoteStart(p, byRockets)
if remoteShows[p] or not CFG.watch or p == lp then return remoteShows[p] end
local count = 0
for _ in pairs(remoteShows) do count += 1 end
if count >= 2 then return end
local c = p.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
local me = char() and char():FindFirstChild("HumanoidRootPart")
if not root or not me or (me.Position - root.Position).Magnitude > 300 then return end
local show = newShow({ isSelf = false, getRoot = function() local ch = p.Character return ch and ch:FindFirstChild("HumanoidRootPart") end })
show.byRockets = byRockets
remoteShows[p] = show
show.start()
show.voice = playVoice(root, 0.9)
task.delay(15, function() if remoteShows[p] == show then remoteShows[p] = nil show.stop(false) fadeVoice(show.voice, 0) end end)
return show
end
local function remoteFinish(p)
local show = remoteShows[p]
if not show then return end
remoteShows[p] = nil
show.flash()
fadeVoice(show.voice, 1.5)
task.delay(2.2, function() show.stop(false) end)
end

local lastCue = {}
local function remoteCue(p, msg)
if not CFG.watch or p == lp then return end
local m = tostring(msg):lower():gsub("%s", "")
local key = p.UserId .. m
if lastCue[key] and os.clock() - lastCue[key] < 0.5 then return end -- both chat systems can report the same line
lastCue[key] = os.clock()
if m == "kai." then remoteStart(p, false) elseif m == "fuga." then remoteFinish(p) end
end

local rocketLog, lastRocket = {}, {}
local fugaStopped = false
table.insert(conns, workspace.ChildAdded:Connect(function(d)
if d.Name ~= "Rocket" or not CFG.watch then return end
task.defer(function()
local part = d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart", true)
if not part then return end
local pos = part.Position
local best, bd = nil, 60
for _, pl in ipairs(Players:GetPlayers()) do
local r = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
if r then
local dd = (r.Position - pos).Magnitude
if dd < bd then best, bd = pl, dd end
end
end
if not best or best == lp then return end
local now = os.clock()
lastRocket[best] = now
local log = rocketLog[best] or {}
rocketLog[best] = log
table.insert(log, now)
while #log > 0 and now - log[1] > 1.5 do table.remove(log, 1) end
if #log >= 2 then remoteStart(best, true) end
end)
end))
task.spawn(function()
while true do
task.wait(0.25)
if fugaStopped then break end
for pl, show in pairs(remoteShows) do
if show.byRockets and os.clock() - (lastRocket[pl] or 0) > 1.7 then remoteFinish(pl) end
end
end
end)
local function watchPlayer(p)
if p == lp then return end
table.insert(conns, p.Chatted:Connect(function(msg) remoteCue(p, msg) end))
end
for _, p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
table.insert(conns, Players.PlayerAdded:Connect(watchPlayer))
pcall(function()
local TCS = game:GetService("TextChatService")
table.insert(conns, TCS.MessageReceived:Connect(function(m)
local src = m.TextSource
local pl = src and Players:GetPlayerByUserId(src.UserId)
if pl then remoteCue(pl, m.Text) end
end))
end)
table.insert(conns, Players.PlayerRemoving:Connect(function(p)
local s = remoteShows[p]
if s then remoteShows[p] = nil s.stop(true) end
end))

cineCleanup = function() cineOff(true) megaStop(true) end

local function sayChat(text)
pcall(function()
local TCS = game:GetService("TextChatService")
if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
local ch = TCS:FindFirstChild("TextChannels") and TCS.TextChannels:FindFirstChild("RBXGeneral")
if ch then ch:SendAsync(text) end
else
local ev = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
local r = ev and ev:FindFirstChild("SayMessageRequest")
if r then r:FireServer(text, "All") end
end
end)
end
local function pressEffects()
if myVoice then pcall(function() myVoice:Destroy() end) end
myVoice = playVoice()
if CFG.mega then pcall(megaStart) end
if CFG.chat and os.clock() - lastChat > 6 then
lastChat = os.clock()
cueSent = true
sayChat("Kai.")
end
playSound(S_BASS, 1.5, 0.55)
playSound(S_BOOM, 0.9, 0.7)
playSound(S_WHOOSH, 0.5, 0.55)
if CFG.voiceId and CFG.voiceId ~= "" then playSound(CFG.voiceId, 2, 1) end -- your own audio id for a voice line, if you set one
playImpact()
cineOn()
end
local function releaseEffects()
if cueSent then
cueSent = false
local wait = math.max(0, 1.2 - (os.clock() - lastChat))
task.delay(wait, function() sayChat("FUGA.") end)
end
fadeVoice(myVoice, 1.2)
myVoice = nil
pcall(megaStop, false)
if CFG.mega then shake(2.2, 0.5) end
playSound(S_LAUNCH, 0.9, 0.8)
playSound(S_SLASH, 1, 0.5)
playSound(S_THUNDER, 0.5, 1.1)
cineOff()
end

local function updateFx(root, charge)
local part = ensureBase()
if not part then return end
pcall(function()
part.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.9, 0))
local embers, light = part:FindFirstChild("Embers"), part:FindFirstChild("Glow")
if embers then embers.Rate = 25 + charge * 150 end
local col = part:FindFirstChild("Column")
if col then
col.CFrame = part.CFrame
local flame = col:FindFirstChild("Flame")
if flame then flame.Rate = 8 + charge * 120 end
end
if light then light.Brightness = 1.2 + charge * 4.5 + math.sin(os.clock() * 9) * 0.3 end
end)
end

local armsFree = false
local function driveArms(k)
local c = char()
local torso = c and c:FindFirstChild("Torso")
if not torso then return end
local sides = { { "Right Shoulder", "Right Arm", POSE_R }, { "Left Shoulder", "Left Arm", POSE_L } }
if k > 0.02 and CFG.pose and CFG.detach then
for _, sd in ipairs(sides) do
local sh, arm = torso:FindFirstChild(sd[1]), c:FindFirstChild(sd[2])
if sh and arm and sh:IsA("JointInstance") then
if sh.Enabled then sh.Enabled = false end
arm.CFrame = torso.CFrame * sh.C0 * CFrame.Angles(0, 0, sd[3] * k) * sh.C1:Inverse()
arm.AssemblyLinearVelocity = Vector3.zero
arm.AssemblyAngularVelocity = Vector3.zero
end
end
armsFree = true
elseif armsFree then
armsFree = false
for _, sd in ipairs(sides) do
local sh = torso:FindFirstChild(sd[1])
if sh and sh:IsA("JointInstance") then sh.Enabled = true end
end
end
end

local function releaseAll()
pcall(driveArms, 0)
dropFx()
for tool in pairs(state) do restoreOne(tool) end
local bp = lp:FindFirstChild("Backpack")
local c = char()
for tool in pairs(adopted) do
if tool.Parent == c and bp then tool.Parent = bp end
end
table.clear(adopted)
end

local function setOn(v)
v = v and true or false
if v == on then return end
on = v
if not on then spraying = false sprayId += 1 arrowState = "idle" cineOff() end
if on then
startT = os.clock()
spinAngle = 0
toast("Fuga. Hold the mouse button to spray the fire where you aim")
else
chargeStart = nil
releaseAll()
toast("Fuga ring OFF")
end
end

local pathParams = RaycastParams.new()
pathParams.FilterType = Enum.RaycastFilterType.Exclude
local function checkAim(target)
local c = char()
local root = c and c:FindFirstChild("HumanoidRootPart")
if not root then return false, "no character" end
local d = (target - root.Position).Magnitude
if d < CFG.safeDistance then return false, "close" end
local start = root.Position + Vector3.new(0, 1.5, 0)
local dir = target - start
local len = math.min(dir.Magnitude, CFG.safeDistance + 15)
if dir.Magnitude < 1 then return false, "close" end
dir = dir.Unit
local ignore = { c }
for _ = 1, 6 do
pathParams.FilterDescendantsInstances = ignore
local hit
local ok = pcall(function() hit = workspace:Spherecast(start, 1.6, dir * len, pathParams) end)
if not ok then hit = workspace:Raycast(start, dir * len, pathParams) end
if not hit then return true end
local part = hit.Instance
if part.CanCollide == false and part.Transparency >= 0.95 then
table.insert(ignore, part)
else
local hd = (hit.Position - root.Position).Magnitude
if hd < CFG.safeDistance then return false, "blocked", hd end
return true
end
end
return true
end

local function aimIsSafe()
local c = char()
local root = c and c:FindFirstChild("HumanoidRootPart")
if not root then return false end
local okHit, target = pcall(function() return mouse.Hit.Position end)
if not okHit then return true end
local safe, why, hd = checkAim(target)
if safe then return true end
if os.clock() - lastWarn > 1.5 then
lastWarn = os.clock()
if why == "blocked" then
toast(string.format("Something is in the way %d studs from you. The Molotov would burst there and burn you", math.floor(hd or 0)))
else
toast("Aim farther away. That spot is too close and would burn you")
end
end
return false
end

local function volley()
if volleying then return end
local c = char()
local list = molotovsIn(c)
if #list == 0 then return end
volleying = true
chargeStart = os.clock()
task.delay(CFG.chargeTime, function()
chargeStart = nil
local now = aimIsSafe() and molotovsIn(char()) or {}
for i, tool in ipairs(now) do
task.delay((i - 1) * CFG.gap, function()
if tool.Parent then
markAim(tool)
pcall(function() tool:Activate() end)
end
end)
end
task.delay(#now * CFG.gap + 1.6, function() volleying = false end)
end)
end

local function haveMolotov()
for _, t in ipairs(molotovsIn(char())) do
if not fired[t] then return true end
end
return false
end

local function startSpray()
if spraying or volleying then return end
if not haveMolotov() then return end
spraying = true
local r0 = char() and char():FindFirstChild("HumanoidRootPart")
if r0 then pulse(r0) end
if CFG.arrow then arrowState = "charge" arrowT = os.clock() end
pressEffects()
sprayId += 1
local mine = sprayId
task.spawn(function()
while on and spraying and sprayId == mine do
local nextTool
for _, t in ipairs(molotovsIn(char())) do
if not fired[t] then nextTool = t break end
end
if nextTool then
if aimIsSafe() then
fired[nextTool] = true
markAim(nextTool)
pcall(function() nextTool:Activate() end)
megaKick()
end
elseif #molotovsIn(char()) == 0 then
break -- the last Molotov has been thrown
end
task.wait(CFG.sprayGap)
end
if sprayId == mine and spraying then
spraying = false
if arrowState == "charge" then arrowState = "launch" arrowT = os.clock() end
releaseEffects()
end
end)
end
local function stopSpray()
local was = spraying
spraying = false
sprayId += 1
if arrowState == "charge" then arrowState = "launch" arrowT = os.clock() end
if was then releaseEffects() end
end

table.insert(conns, UIS.InputBegan:Connect(function(input, processed)
if input.KeyCode == CFG.key and not processed then setOn(not on) return end
if processed or not on then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 then task.defer(startSpray) end
end))
table.insert(conns, UIS.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then stopSpray() end
end))
table.insert(conns, lp.CharacterRemoving:Connect(function()
table.clear(adopted)
table.clear(state)
chargeStart = nil
volleying = false
end))

table.insert(conns, RunService.Stepped:Connect(function()
if not on or next(state) == nil then return end
local c = char()
local torso = c and c:FindFirstChild("Torso")
local rs = torso and torso:FindFirstChild("Right Shoulder")
if rs then rs.Transform = CFrame.new() end
if CFG.pose and not CFG.detach and fireBlend > 0.3 and torso then
local ls = torso:FindFirstChild("Left Shoulder")
local k = math.clamp((fireBlend - 0.3) / 0.7, 0, 1)
if rs then rs.Transform = CFrame.Angles(0, 0, POSE_R * k) end
if ls then ls.Transform = CFrame.Angles(0, 0, POSE_L * k) end
end
end))

table.insert(conns, RunService.RenderStepped:Connect(function(dt)
if not on then return end
local c = char()
local root = c and c:FindFirstChild("HumanoidRootPart")
local hum = c and c:FindFirstChildOfClass("Humanoid")
if not root or not hum or hum.Health <= 0 then return end

if CFG.arrow then pcall(updateArrow, root) end
local now = os.clock()
if now - lastAdopt > 0.3 then
lastAdopt = now
local bp = lp:FindFirstChild("Backpack")
for _, t in ipairs(molotovsIn(bp)) do
adopted[t] = true
t.Parent = c
end
end

local list = molotovsIn(c)
local n = #list
pcall(driveArms, (n > 0 and arrowState == "charge") and math.clamp((fireBlend - 0.3) / 0.7, 0, 1) or 0)
if n == 0 then return end
for tool in pairs(state) do
if tool.Parent ~= c then state[tool] = nil end
end

local charge = chargeStart and math.clamp((now - chargeStart) / CFG.chargeTime, 0, 1) or (spraying and 0.55 or 0)
spinAngle += dt * (CFG.spin + charge * charge * 9)
local grow = math.clamp((now - startT) / 0.7, 0, 1)
grow = 1 - (1 - grow) * (1 - grow)
local radius = math.max(CFG.minRadius, n * CFG.spacing / (2 * math.pi)) * grow * (1 - charge * 0.25)
local height = CFG.height * (0.35 + 0.65 * grow) + charge * 1.2

local firing = arrowState == "charge"
fireBlend += ((firing and 1 or 0) - fireBlend) * math.min(1, dt * 9)
local origin = root.Position + Vector3.new(0, 8, 0)
local aimv = mouse.Hit.Position - origin
local aimDir = aimv.Magnitude > 1 and aimv.Unit or root.CFrame.LookVector
local right = aimDir:Cross(Vector3.yAxis)
if right.Magnitude < 0.05 then right = root.CFrame.RightVector end
right = right.Unit
local up2 = right:Cross(aimDir).Unit
local discCenter = origin + aimDir * 11
local discRadius = math.max(4.5, n * 1.15 / (2 * math.pi))

for i, tool in ipairs(list) do
local g = gripFor(tool)
if g then
local handle = g.Part1
if not state[tool] or state[tool].grip ~= g then
restoreOne(tool)
state[tool] = { grip = g, c0 = g.C0, part0 = g.Part0, handle = handle, massless = handle.Massless, canCollide = handle.CanCollide }
handle.Massless = true
handle.CanCollide = false
end
local a = spinAngle + (i - 1) * (2 * math.pi / n)
local out = Vector3.new(math.cos(a), 0, math.sin(a))
local bob = math.sin(now * 2.4 + i * 1.7) * CFG.bob
local pos = root.Position + out * radius + Vector3.new(0, height - 3 + bob, 0)
local lean = math.rad(CFG.tilt)
local dir = out * math.sin(lean) + Vector3.new(0, math.cos(lean), 0)
local form = CFG.formation
if form == "gyro" then
local k = (i - 1) % 3
local m = math.max(1, math.ceil((n - k) / 3))
local j = (i - 1 - k) // 3
local R = math.max(5.5, m * 1.7 / (2 * math.pi)) * grow
local ang = spinAngle * (k % 2 == 0 and 1.3 or -1.3) + j * 2 * math.pi / m
local tilt = k == 0 and CFrame.new() or (k == 1 and CFrame.Angles(math.rad(62), 0, 0) or CFrame.Angles(0, 0, math.rad(62)))
local rot = CFrame.Angles(0, spinAngle * 0.35, 0) * tilt
local off = rot:VectorToWorldSpace(Vector3.new(math.cos(ang), 0, math.sin(ang))) * R
pos = root.Position + Vector3.new(0, height * 0.55 + bob, 0) + off
dir = off.Magnitude > 0.01 and off.Unit or dir
elseif form == "wings" then
local s2 = (i % 2 == 0) and 1 or -1
local kk = (i - 1) // 2
local cnt = math.max(1, s2 == 1 and n // 2 or math.ceil(n / 2))
local f = cnt > 1 and kk / (cnt - 1) or 0.5
local flat = root.CFrame.LookVector * Vector3.new(1, 0, 1)
if flat.Magnitude < 0.01 then flat = Vector3.new(0, 0, -1) end
local back = -flat.Unit
local rv = root.CFrame.RightVector
local ang2 = math.rad(12 + f * 68) + math.sin(now * 2.2) * 0.14 * (0.4 + f)
local d = (rv * s2 * math.cos(ang2) + Vector3.new(0, math.sin(ang2), 0) + back * 0.3).Unit
local len = (4.2 + (1 - f) * 3.4) * grow
pos = root.Position + Vector3.new(0, 2.6, 0) + back * 1.1 + d * len
dir = d
elseif form == "halo" then
local R = math.max(3, n * 1.5 / (2 * math.pi)) * grow
local ang = spinAngle * 2.2 + (i - 1) * 2 * math.pi / n
local o = Vector3.new(math.cos(ang), 0, math.sin(ang))
pos = root.Position + Vector3.new(0, 6.6 + grow * 1.4 + bob, 0) + o * R
dir = (Vector3.new(0, 1, 0) + o * 0.3).Unit
end
local prev = smoothPos[tool]
if prev then pos = prev:Lerp(pos, math.min(1, dt * 10)) end
smoothPos[tool] = pos
if fireBlend > 0.002 then
local da = spinAngle * 1.4 + (i - 1) * (2 * math.pi / n)
local discPos = discCenter + right * math.cos(da) * discRadius + up2 * math.sin(da) * discRadius
pos = pos:Lerp(discPos, fireBlend)
dir = dir:Lerp(aimDir, fireBlend)
if dir.Magnitude < 0.01 then dir = aimDir end
end
local desired = CFrame.lookAt(pos, pos + dir) * CFG.faceOffset
if CFG.detach then
if g.Enabled then g.Enabled = false end
handle.CFrame = desired
handle.AssemblyLinearVelocity = Vector3.zero
handle.AssemblyAngularVelocity = Vector3.zero
else
if not g.Enabled then g.Enabled = true end
g.C0 = g.Part0.CFrame:Inverse() * desired * g.C1
end
dressBottle(tool, handle)
hookTool(tool)
end
end
updateFx(root, charge)
end))

getgenv().FugaRing = {
cfg = CFG,
checkAim = function(t) return checkAim(t) end, -- (Vector3) -> safe, reason, distance (for testing)
cue = remoteCue, -- (player, "Kai." or "FUGA.") shows the effects around another player, for testing
set = setOn,
isOn = function() return on end,
release = function() task.spawn(volley) end,
nextFormation = function()
local idx = 1
for k, v in ipairs(FORMS) do if v == CFG.formation then idx = k end end
CFG.formation = FORMS[idx % #FORMS + 1]
return CFG.formation
end,
preview = function()
if not on or not haveMolotov() then toast("Hold a Molotov first (turn the ring on with Molotovs in your backpack)") return end
arrowState = "charge"
arrowT = os.clock()
pressEffects()
task.delay(1.8, function()
if arrowState == "charge" and not spraying then arrowState = "launch" arrowT = os.clock() releaseEffects() end
end)
end,
stop = function()
on = false
for _, c in ipairs(conns) do c:Disconnect() end
table.clear(conns)
fugaStopped = true
releaseAll()
megaStopAll()
getgenv().FugaRing = nil
end,
}
table.insert(stops, function() if getgenv().FugaRing then getgenv().FugaRing.stop() end end)
end)

run("Shop", function()
local CFG = {
key = Enum.KeyCode.P, -- opens the pawn / weapon shop
shops = {
{ id = "1", label = "Pawn / weapon shop", button = "pawn shop button" },
{ id = "2", label = "7/12 Shop", button = "7/12 shop button" },
{ id = "3", label = "Cafe Bodoni", button = "cafe shop button" },
{ id = "4", label = "Tofu Shop", button = "tofu shop button" },
{ id = "5", label = "Borger Baron", button = "baron shop button" },
{ id = "6", label = "Wild Tejas", button = "tejas shop button" },
{ id = "7", label = "Don Quijote Shop", button = "quijote shop button" },
{ id = "0", label = "KazokuMart", button = "familymart shop button" },
{ id = "8", label = "Banmin", button = "banmin shop button" },
{ id = "9", label = "Tahatto Hardware", button = "hardware store button" },
},
}
local busy = false

local function isOpen(shop)
return lp.PlayerGui:FindFirstChild(shop.id) ~= nil
end

local function touchOpen(root, shop)
if not firetouchinterest then return false end
local parts = {}
for _, d in ipairs(workspace:GetChildren()) do
if d.Name:lower():find(shop.button, 1, true) then
local part = d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart", true)
if part then table.insert(parts, part) end
end
end
for _, part in ipairs(parts) do
pcall(function()
firetouchinterest(root, part, 0)
task.wait(0.15)
firetouchinterest(root, part, 1)
end)
local t0 = os.clock()
while not isOpen(shop) and os.clock() - t0 < 1.5 do task.wait(0.1) end
if isOpen(shop) then return true end
end
return false
end

local function buildOpen(shop)
local shops = ReplicatedStorage:FindFirstChild("ShopGuis")
local template = shops and shops:FindFirstChild(shop.id)
if not template then return false end
template:Clone().Parent = lp.PlayerGui
return true
end

local function open(shop)
shop = shop or CFG.shops[1]
if busy then return end
busy = true
local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
local g = lp.PlayerGui:FindFirstChild(shop.id)
if g then g:Destroy() end
task.wait(0.1)
if root then touchOpen(root, shop) end
if not isOpen(shop) then buildOpen(shop) end
if isOpen(shop) then
if shop.id == "1" then
toast(shop.label .. " opened. Selling only works when you are at the pawn shop")
else
toast(shop.label .. " opened. The game still decides if a purchase goes through")
end
else
toast(shop.label .. " did not open, try again")
end
busy = false
end

local conn = UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == CFG.key then task.spawn(open, CFG.shops[1]) end
end)

getgenv().OpenShop = {
cfg = CFG,
run = function(shop) task.spawn(open, shop) end,
stop = function()
conn:Disconnect()
getgenv().OpenShop = nil
end,
}
table.insert(stops, function() if getgenv().OpenShop then getgenv().OpenShop.stop() end end)
end)

run("Sell", function()
local CFG = {
key = Enum.KeyCode.U,
confirm = true,     -- press twice. Set false to sell instantly with one press (careful!)
confirmWindow = 5,  -- seconds you have to press the second time
keepGuns = false,   -- true = never sell guns (anything with a FireEvent)
goKey = Enum.KeyCode.B, -- walks you to the pawn shop, sells there, and walks back to the AFK weapon walk if it was on
}

local function collect()
local list, total = {}, 0
local c = lp.Character
for _, where in ipairs({ lp:FindFirstChild("Backpack"), c }) do
if where then
for _, t in ipairs(where:GetChildren()) do
if t:IsA("Tool") then
local pc = t:FindFirstChild("PawnCost")
if pc and pc:IsA("ValueBase") and (not CFG.keepGuns or not t:FindFirstChild("FireEvent")) then
table.insert(list, t)
total += tonumber(pc.Value) or 0
end
end
end
end
end
return list, total
end

local armedUntil = 0
local busy = false

local function press(force)
if busy then return end
local list, total = collect()
if #list == 0 then
toast("Nothing to sell (no items the pawn shop buys)")
return
end
if CFG.confirm and force ~= true and os.clock() > armedUntil then
armedUntil = os.clock() + CFG.confirmWindow
toast(("Sell %d item(s) for about %d Yen? Press U again to confirm"):format(#list, total))
return
end
armedUntil = 0
busy = true
local yen = lp:FindFirstChild("leaderstats") and lp.leaderstats:FindFirstChild("Yen")
local before = yen and yen.Value or 0
ReplicatedStorage.SellWeapon:FireServer(list)
task.wait(2)
local gained = yen and (yen.Value - before) or 0
if gained > 0 then
toast(("Sold %d item(s) for %d Yen"):format(#list, gained))
else
toast("Nothing was paid. Stand at the pawn shop with its sell screen open, then try again")
end
busy = false
end

local going = false
local function goSell()
if going then going = false return end
local list, total = collect()
if #list == 0 then
toast("Nothing to sell (no items the pawn shop buys)")
return
end
local B = getgenv().BringGuns
local c = lp.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
if not B or not B.walkTo or not root then return end
local spot, best
for _, d in ipairs(workspace:GetChildren()) do
if d.Name:lower():find("pawn shop button", 1, true) then
local part = d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart", true)
if part then
local dist = (part.Position - root.Position).Magnitude
if not best or dist < best then spot, best = part.Position, dist end
end
end
end
if not spot then toast("Could not find the pawn shop") return end
local resume = B.autoOn and B.autoOn()
if resume then B.setAuto(false) end
going = true
toast(("Walking to the pawn shop (%dm) to sell %d item(s), about %d Yen. Move or press %s to cancel"):format(math.floor(best), #list, total, CFG.goKey.Name))
local res = B.walkTo(spot, 5, 90, function() return not going end)
if res == "arrived" and going then
local o = getgenv().OpenShop
if o then o.run(o.cfg.shops[1]) end
task.wait(1.5)
press(true)
elseif res == "stopped" then
toast("Cancelled")
else
toast("Could not reach the pawn shop. Try again or walk the rest")
end
going = false
if resume and B.setAuto then B.setAuto(true) end
end

local conn = UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == CFG.key then task.spawn(press) end
if input.KeyCode == CFG.goKey then task.spawn(goSell) end
end)

getgenv().SellAll = {
cfg = CFG,
run = function() task.spawn(press) end,
goSell = function() task.spawn(goSell) end,
stop = function()
conn:Disconnect()
getgenv().SellAll = nil
end,
}
table.insert(stops, function() if getgenv().SellAll then getgenv().SellAll.stop() end end)
end)

run("Bring", function()
local CFG = {
key = Enum.KeyCode.K,
skipNearPlayers = 60, -- studs; weapons with another player this close are left alone (0 = never skip)
inFront = 7,          -- studs in front of you where the weapons are placed
spread = 2.5,         -- gap between weapons
silentKey = Enum.KeyCode.V, -- switches the silent pickup on / off
pickupKey = Enum.KeyCode.N, -- brings the weapon pickups from the spawn points to you
guns = true,          -- which kinds of pickup to bring
melee = true,
other = true,
}
local busy = false

local function nearOtherPlayer(pos)
if CFG.skipNearPlayers <= 0 then return false end
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp and p.Character then
local r = p.Character:FindFirstChild("HumanoidRootPart")
if r and (r.Position - pos).Magnitude < CFG.skipNearPlayers then return true end
end
end
return false
end

local function run()
if busy then return end
local c = lp.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
if not root then return end
busy = true
if sethiddenproperty then
pcall(function() sethiddenproperty(lp, "SimulationRadius", 1e9) end)
pcall(function() sethiddenproperty(lp, "MaximumSimulationRadius", 1e9) end)
end

local found, skipped = {}, 0
for _, d in ipairs(workspace:GetChildren()) do
if d:IsA("Tool") and (d:FindFirstChild("FireEvent") or d:FindFirstChild("MeleeScript")) then
local h = d:FindFirstChild("Handle")
if h and h:IsA("BasePart") then
if nearOtherPlayer(h.Position) then skipped += 1 else table.insert(found, d) end
end
end
end

local base = root.CFrame * CFrame.new(0, 0, -CFG.inFront)
local n = #found
local names = {}
for i, tool in ipairs(found) do
local h = tool:FindFirstChild("Handle")
if h and tool.Parent == workspace then
local offset = (i - (n + 1) / 2) * CFG.spread
h.AssemblyLinearVelocity = Vector3.zero
h.CFrame = base * CFrame.new(offset, 1, 0)
table.insert(names, tool.Name)
end
end
if n == 0 then
toast(skipped > 0 and ("Nothing brought (" .. skipped .. " skipped, players nearby)") or "No loose weapons found")
else
toast("Brought " .. n .. ": " .. table.concat(names, ", "))
end
busy = false
end

local silentOn = false
local function grabLoose()
local c = lp.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
local hum = c and c:FindFirstChildOfClass("Humanoid")
if not root or not hum or hum.Health <= 0 or not firetouchinterest then return 0 end
local mine = {}
for _, d in ipairs(workspace:GetChildren()) do
if d:IsA("Tool") then
local h = d:FindFirstChild("Handle")
if h and h:IsA("BasePart") and not nearOtherPlayer(h.Position) then
table.insert(mine, { tool = d, handle = h })
end
end
end
if #mine == 0 then return 0 end
for _, m in ipairs(mine) do pcall(firetouchinterest, root, m.handle, 0) end
task.wait(0.15)
for _, m in ipairs(mine) do pcall(firetouchinterest, root, m.handle, 1) end
task.wait(0.4)
local got, equipped = 0, false
for _, m in ipairs(mine) do
if m.tool.Parent ~= workspace then
got += 1
if m.tool.Parent == c then equipped = true end
end
end
if equipped then pcall(function() hum:UnequipTools() end) end
return got
end
local function setSilent(v)
v = v and true or false
if v == silentOn then return end
silentOn = v
if not v then return end
task.spawn(function()
while silentOn do
pcall(grabLoose)
task.wait(2)
end
end)
end

local MELEE_WORDS = { "knife", "katana", "sledge", "hammer", "bat", "bokken", "axe", "machete", "sword" }
local function pickupKindOf(m)
local l = m.Name:lower()
for _, w in ipairs(MELEE_WORDS) do
if l:find(w, 1, true) then return "melee" end
end
return "gun"
end
local function pickupPrettyName(m)
local n = m.Name:gsub("Pickup$", "")
if n == "Sledge" then n = "Sledgehammer" end
return n
end

local PathfindingService = game:GetService("PathfindingService")
local walkToken = 0
local walking = false
local autoOn = false
local skipUntil = setmetatable({}, { __mode = "k" }) -- pickups that could not be reached are left alone for a while

local function playerNear(pos, radius)
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp and p.Character then
local r = p.Character:FindFirstChild("HumanoidRootPart")
if r and (r.Position - pos).Magnitude < radius then return true end
end
end
return false
end

local function nearestPickup(root)
local best, bestD
for _, sp in ipairs(workspace:GetChildren()) do
if sp.Name:find("Spawn") and (sp:IsA("Model") or sp:IsA("Folder")) then
for _, m in ipairs(sp:GetChildren()) do
local part = m:IsA("Model") and m:FindFirstChild("Pickup")
if part and part:IsA("BasePart") then
local kind = pickupKindOf(m)
if ((kind == "gun" and CFG.guns) or (kind == "melee" and CFG.melee)) and (skipUntil[m] or 0) < os.clock() then
local d = (part.Position - root.Position).Magnitude
if (not bestD or d < bestD) and not playerNear(part.Position, 25) then
best, bestD = { model = m, part = part }, d
end
end
end
end
end
end
return best, bestD
end

local function userIsSteering()
return UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.D)
end

local function walkOnce(auto)
if walking then
if not auto then walkToken += 1 end -- pressing again stops the walk
return "busy"
end
local c = lp.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
local hum = c and c:FindFirstChildOfClass("Humanoid")
if not root or not hum or hum.Health <= 0 then return "none" end

local target, dist = nearestPickup(root)
if not target then
if not auto then toast("No weapon pickup to walk to right now (none spawned, or players are next to them)") end
return "none"
end
walking = true
walkToken += 1
local mine = walkToken
local name = pickupPrettyName(target.model)
if not auto then toast("Walking to the nearest " .. name .. " (" .. math.floor(dist) .. "m). Press " .. CFG.pickupKey.Name .. " or a move key to stop") end

local points = {}
local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, AgentCanClimb = true })
local okPath = pcall(function() path:ComputeAsync(root.Position, target.part.Position) end)
if okPath and path.Status == Enum.PathStatus.Success then
points = path:GetWaypoints()
else
points = { { Position = target.part.Position, Action = Enum.PathWaypointAction.Walk } }
end

local startedAt = os.clock()
local function stillGoing()
return walkToken == mine and target.model.Parent ~= nil and hum.Health > 0 and root.Parent ~= nil and os.clock() - startedAt < 45
end
task.wait(0.3) -- lets the key press that started the walk finish first
for _, wp in ipairs(points) do
if not stillGoing() then break end
if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
hum:MoveTo(wp.Position)
local t0 = os.clock()
while stillGoing() and os.clock() - t0 < 4 do
local flat = Vector3.new(root.Position.X - wp.Position.X, 0, root.Position.Z - wp.Position.Z).Magnitude
if flat < 3 then break end
if not auto and userIsSteering() then walkToken += 1 break end
task.wait(0.1)
end
end
if stillGoing() then
local spot = Vector3.new(target.part.Position.X, root.Position.Y, target.part.Position.Z)
hum:MoveTo(spot)
local t2 = os.clock()
while stillGoing() and os.clock() - t2 < 3 do
local flat = Vector3.new(root.Position.X - spot.X, 0, root.Position.Z - spot.Z).Magnitude
if flat < 0.8 then break end
if not auto and userIsSteering() then walkToken += 1 break end
task.wait(0.1)
end
end
hum:MoveTo(root.Position) -- stop walking
local t1 = os.clock()
while target.model.Parent and os.clock() - t1 < 1 and walkToken == mine do task.wait(0.1) end
local result
if not target.model.Parent then
toast("Picked up " .. name)
result = "ok"
elseif walkToken ~= mine then
if not auto then toast("Stopped") end
result = "stopped"
else
if not auto then toast("Could not reach that " .. name .. " (" .. math.floor((root.Position - target.part.Position).Magnitude) .. "m left). Try again or walk the rest") end
skipUntil[target.model] = os.clock() + 30
result = "failed"
end
walking = false
return result
end

local function setAuto(v)
v = v and true or false
if v == autoOn then return end
autoOn = v
walkToken += 1 -- ends a walk that is in progress
if not v then
toast("Auto-walk to weapons OFF")
return
end
toast("Auto-walk to weapons ON (AFK). Press " .. CFG.pickupKey.Name .. " or turn it off in the menu to stop")
task.spawn(function()
while autoOn do
local st = walkOnce(true)
if st == "ok" or st == "failed" then task.wait(0.5) else task.wait(1.5) end
end
end)
end

local function walkTo(pos, radius, timeout, shouldStop)
local t0 = os.clock()
while walking and os.clock() - t0 < 3 do task.wait(0.1) end -- let a walk that was just cancelled finish
if walking then return "failed" end
local c = lp.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
local hum = c and c:FindFirstChildOfClass("Humanoid")
if not root or not hum or hum.Health <= 0 then return "failed" end
walking = true
walkToken += 1
local mine = walkToken
local startedAt = os.clock()
local function flatDist() return Vector3.new(root.Position.X - pos.X, 0, root.Position.Z - pos.Z).Magnitude end
local function going()
return walkToken == mine and hum.Health > 0 and root.Parent ~= nil and os.clock() - startedAt < (timeout or 60)
and not (shouldStop and shouldStop()) and not userIsSteering()
end
local points
local path = PathfindingService:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, AgentCanClimb = true })
local okPath = pcall(function() path:ComputeAsync(root.Position, pos) end)
if okPath and path.Status == Enum.PathStatus.Success then
points = path:GetWaypoints()
else
points = { { Position = pos, Action = Enum.PathWaypointAction.Walk } }
end
task.wait(0.3)
for _, wp in ipairs(points) do
if not going() or flatDist() < radius then break end
if wp.Action == Enum.PathWaypointAction.Jump then hum.Jump = true end
hum:MoveTo(wp.Position)
local w0 = os.clock()
while going() and os.clock() - w0 < 4 do
local f = Vector3.new(root.Position.X - wp.Position.X, 0, root.Position.Z - wp.Position.Z).Magnitude
if f < 3 or flatDist() < radius then break end
task.wait(0.1)
end
end
if going() and flatDist() >= radius then
hum:MoveTo(Vector3.new(pos.X, root.Position.Y, pos.Z))
local w1 = os.clock()
while going() and os.clock() - w1 < 4 and flatDist() >= radius do task.wait(0.1) end
end
local result = flatDist() < radius + 0.5 and "arrived" or ((walkToken ~= mine or userIsSteering() or (shouldStop and shouldStop())) and "stopped" or "failed")
hum:MoveTo(root.Position)
walking = false
return result
end

local function runPickups()
setAuto(not autoOn)
end

local function walkNearest()
if autoOn then setAuto(false) return end
walkOnce(false)
end

local conn = UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == CFG.key then task.spawn(run) end
if input.KeyCode == CFG.pickupKey then task.spawn(runPickups) end
if input.KeyCode == CFG.silentKey then setSilent(not silentOn) end
end)

getgenv().BringGuns = {
cfg = CFG,
run = function() task.spawn(run) end,
runPickups = function() task.spawn(runPickups) end,
walkNearest = function() task.spawn(walkNearest) end,
grabNow = function() task.spawn(function() pcall(grabLoose) end) end,
setSilent = setSilent,
silentOn = function() return silentOn end,
walkTo = walkTo,
setAuto = function(v) task.spawn(setAuto, v) end,
autoOn = function() return autoOn end,
stop = function()
autoOn = false
silentOn = false
walkToken += 1
conn:Disconnect()
getgenv().BringGuns = nil
end,
}
table.insert(stops, function() if getgenv().BringGuns then getgenv().BringGuns.stop() end end)
end)

run("Speed", function()
local CFG = {
key = Enum.KeyCode.Y,
min = 16,
max = 58, -- the game's server pulls you back above ~59, so the slider stops before that
value = 24,
enabled = false,
shootLimit = 28, -- the game blocks shooting at 29 and above
}

local frame = Instance.new("Frame")
frame.Name = "SpeedPanel"
frame.AnchorPoint = Vector2.new(1, 0)
frame.Position = UDim2.new(1, -10, 0, 10)
frame.Size = UDim2.new(0, 250, 0, 76)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
frame.BackgroundTransparency = 0.15
frame.Visible = false -- the menu window below replaces this small panel
frame.Parent = ui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 6)
title.Size = UDim2.new(1, -90, 0, 22)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamMedium
title.TextSize = 14
title.Parent = frame

local button = Instance.new("TextButton")
button.Position = UDim2.new(1, -74, 0, 6)
button.Size = UDim2.new(0, 64, 0, 22)
button.Font = Enum.Font.GothamBold
button.TextSize = 13
button.TextColor3 = Color3.new(1, 1, 1)
button.AutoButtonColor = false
button.Parent = frame
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Position = UDim2.new(0, 10, 1, -22)
hint.Size = UDim2.new(1, -20, 0, 16)
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Font = Enum.Font.Gotham
hint.TextSize = 12
hint.Parent = frame

local track = Instance.new("Frame")
track.Position = UDim2.new(0, 12, 0, 40)
track.Size = UDim2.new(1, -24, 0, 6)
track.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
track.BorderSizePixel = 0
track.Parent = frame
Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

local fill = Instance.new("Frame")
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(110, 200, 255)
fill.BorderSizePixel = 0
fill.Parent = track
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

local knob = Instance.new("Frame")
knob.AnchorPoint = Vector2.new(0.5, 0.5)
knob.Size = UDim2.new(0, 16, 0, 16)
knob.Position = UDim2.new(0, 0, 0.5, 0)
knob.BackgroundColor3 = Color3.new(1, 1, 1)
knob.BorderSizePixel = 0
knob.Parent = track
Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

local original = nil
local dragging = false
local conns = {}
local firing = false
local lastShot = 0

local function refresh()
local alpha = (CFG.value - CFG.min) / (CFG.max - CFG.min)
fill.Size = UDim2.new(alpha, 0, 1, 0)
knob.Position = UDim2.new(alpha, 0, 0.5, 0)
title.Text = "Speed: " .. math.floor(CFG.value)
button.Text = CFG.enabled and "ON" or "OFF"
button.BackgroundColor3 = CFG.enabled and Color3.fromRGB(40, 160, 90) or Color3.fromRGB(120, 60, 60)
if CFG.enabled and CFG.value > CFG.shootLimit then
hint.Text = "Above " .. CFG.shootLimit .. ": slows to " .. CFG.shootLimit .. " while you shoot"
hint.TextColor3 = Color3.fromRGB(255, 200, 120)
else
hint.Text = "Drag the bar, Y turns it on or off"
hint.TextColor3 = Color3.fromRGB(170, 170, 180)
end
end

local function setFromX(x)
local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
CFG.value = math.floor(CFG.min + alpha * (CFG.max - CFG.min) + 0.5)
refresh()
end

local function humanoid()
local c = lp.Character
return c and c:FindFirstChildOfClass("Humanoid")
end

local mode = "walk"
local reverts = 0
local lastSet = nil
local unlockedFor = nil
local preFireBound = false
local bindPreFire -- assigned below, after the click handler exists
local function unlock(hum)
if not hum or unlockedFor == hum or not getconnections then return end
unlockedFor = hum
local signals = { hum.Changed, hum:GetPropertyChangedSignal("WalkSpeed") }
for _, sig in ipairs(signals) do
local ok, list = pcall(getconnections, sig)
if ok and type(list) == "table" then
for _, c in ipairs(list) do
local okf, src = pcall(function() return c.Function and debug.info(c.Function, "s") or "" end)
if okf and type(src) == "string" and src:find("AAAAAAAAAHHHHHHHH", 1, true) then
pcall(function() c:Disable() end)
end
end
end
end
end

local function setEnabled(on)
if on == CFG.enabled then return end
CFG.enabled = on
bindPreFire(on)
local hum = humanoid()
if on then
mode = "walk"
reverts = 0
lastSet = nil
unlock(hum)
original = hum and hum.WalkSpeed or 16
else
if hum and original and mode == "walk" then hum.WalkSpeed = original end
original = nil
lastSet = nil
end
refresh()
end

local CAS = game:GetService("ContextActionService")
local function preFire(_, state)
if state == Enum.UserInputState.Begin then
firing = true
lastShot = os.clock()
if CFG.enabled and mode == "walk" and CFG.value > CFG.shootLimit then
local hum = humanoid()
if hum and hum.WalkSpeed > CFG.shootLimit then hum.WalkSpeed = CFG.shootLimit end
end
else
firing = false
lastShot = os.clock()
end
return Enum.ContextActionResult.Pass
end
bindPreFire = function(on)
if on == preFireBound then return end
preFireBound = on
pcall(function()
if on then
CAS:BindActionAtPriority("BabylonPreFire", preFire, false, 3000, Enum.UserInputType.MouseButton1)
else
CAS:UnbindAction("BabylonPreFire")
end
end)
end

table.insert(conns, track.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
setFromX(input.Position.X)
end
end))
table.insert(conns, UIS.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
setFromX(input.Position.X)
end
end))
table.insert(conns, UIS.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end))
table.insert(conns, UIS.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
firing = true
lastShot = os.clock()
end
end))
table.insert(conns, UIS.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
firing = false
lastShot = os.clock()
end
end))
table.insert(conns, button.MouseButton1Click:Connect(function() setEnabled(not CFG.enabled) end))
table.insert(conns, UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == CFG.key then setEnabled(not CFG.enabled) end
end))
table.insert(conns, RunService.Heartbeat:Connect(function()
if not CFG.enabled then return end
local hum = humanoid()
if hum and hum ~= unlockedFor then unlock(hum) end
if not hum then return end
if mode == "velocity" then
local c = lp.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
local md = hum.MoveDirection
if root and md.Magnitude > 0.1 and CFG.value > hum.WalkSpeed and hum.FloorMaterial ~= Enum.Material.Air then
local v = root.AssemblyLinearVelocity
root.AssemblyLinearVelocity = Vector3.new(md.X * CFG.value, v.Y, md.Z * CFG.value)
end
return
end
local target = CFG.value
if target > CFG.shootLimit and (firing or os.clock() - lastShot < 0.25) then
target = CFG.shootLimit
end
if lastSet and lastSet > CFG.shootLimit and hum.WalkSpeed ~= lastSet then
reverts += 1
if reverts >= 8 then
mode = "velocity"
reverts = 0
lastSet = nil
hum.WalkSpeed = (original and original <= CFG.shootLimit) and original or 16
return
end
else
reverts = 0
end
if hum.WalkSpeed ~= target then hum.WalkSpeed = target end
lastSet = target
end))

refresh()

getgenv().BabylonSpeed = {
cfg = CFG,
set = function(v) CFG.value = math.clamp(v, CFG.min, CFG.max) refresh() end,
toggle = function() setEnabled(not CFG.enabled) end,
mode = function() return mode end,
stop = function()
setEnabled(false)
pcall(function() CAS:UnbindAction("BabylonPreFire") end)
for _, c in ipairs(conns) do c:Disconnect() end
frame:Destroy()
getgenv().BabylonSpeed = nil
end,
}
table.insert(stops, function() if getgenv().BabylonSpeed then getgenv().BabylonSpeed.stop() end end)
end)

run("ESP", function()
local CFG = {
key = Enum.KeyCode.L,
color = Color3.fromRGB(255, 70, 70),
interval = 0.25,
}
local on = false
local objs = {}
local acc = 0

local function clear(p)
local o = objs[p]
if o then
pcall(function() o.hl:Destroy() end)
pcall(function() o.gui:Destroy() end)
objs[p] = nil
end
end

local function clearAll()
for p in pairs(objs) do clear(p) end
end

local function attach(p)
local c = p.Character
local head = c and c:FindFirstChild("Head")
if not head then return end
local o = objs[p]
if o and o.char == c and o.hl.Parent then return end
clear(p)

local hl = Instance.new("Highlight")
hl.FillColor = CFG.color
hl.FillTransparency = 0.65
hl.OutlineColor = Color3.new(1, 1, 1)
hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
hl.Adornee = c
hl.Parent = c

local gui = Instance.new("BillboardGui")
gui.Size = UDim2.new(0, 200, 0, 44)
gui.StudsOffset = Vector3.new(0, 2.8, 0)
gui.AlwaysOnTop = true
gui.Adornee = head
gui.Parent = head

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.TextStrokeTransparency = 0.3
label.Font = Enum.Font.GothamMedium
label.TextSize = 14
label.Parent = gui

objs[p] = { hl = hl, gui = gui, label = label, char = c }
end

local function setOn(v)
on = v
if not on then clearAll() end
toast("ESP " .. (on and "ON" or "OFF"))
end

local conn = RunService.Heartbeat:Connect(function(dt)
if not on then return end
acc += dt
if acc < CFG.interval then return end
acc = 0
local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp then
attach(p)
local o = objs[p]
if o then
local c = o.char
local root = c:FindFirstChild("HumanoidRootPart")
local hum = c:FindFirstChildOfClass("Humanoid")
local tool = c:FindFirstChildOfClass("Tool")
local dist = (myRoot and root) and math.floor((myRoot.Position - root.Position).Magnitude) or 0
local text = p.Name .. "  [" .. dist .. "m]"
if hum then text ..= "  " .. math.floor(hum.Health) .. " HP" end
if tool then text ..= "\n" .. tool.Name end
o.label.Text = text
end
end
end
for p in pairs(objs) do
if p.Parent ~= Players then clear(p) end
end
end)

local ITEM = { on = false, guns = true, melee = true, other = true, empty = false, maxDist = 800, key = Enum.KeyCode.O, glowNearest = 4, glowRange = 150 }
CFG.items = ITEM
local itemObjs = {}  -- pickup model or dropped tool -> { gui, label, kind, part, name, hl }
local spawnMarks = {} -- WeaponSpawn model -> { gui, label, part } (only exists while "empty spawn points" is on)
local spawnList = {}  -- every WeaponSpawn model we know about
local KIND_COLOR = {
gun = Color3.fromRGB(255, 120, 60),
melee = Color3.fromRGB(255, 215, 70),
other = Color3.fromRGB(90, 220, 255),
}
local KIND_NAME = { gun = "Gun", melee = "Melee", other = "Item" }
local MELEE_WORDS = { "knife", "katana", "sledge", "hammer", "bat", "bokken", "axe", "machete", "sword", "bat" }

local function pickupKind(name)
local l = name:lower()
for _, w in ipairs(MELEE_WORDS) do
if l:find(w, 1, true) then return "melee" end
end
return "gun"
end

local function prettyName(name)
local n = name:gsub("Pickup$", "")
if n == "Sledge" then n = "Sledgehammer" end
return n
end

local function toolKind(tool)
if tool:FindFirstChild("FireEvent") then return "gun" end
if tool:FindFirstChild("MeleeScript") then return "melee" end
return "other"
end

local function isLoose(tool)
local parent = tool.Parent
if not parent or parent:IsA("Backpack") then return false end
local model = tool:FindFirstAncestorOfClass("Model")
if model and model:FindFirstChildOfClass("Humanoid") then return false end
return true
end

local function isPickupModel(m)
if not m:IsA("Model") then return false end
if m.Name:find("Pickup$") then return true end
local pk = m:FindFirstChild("Pickup")
return pk ~= nil and pk:IsA("BasePart")
end

local function makeBillboard(part, color, big)
local gui = Instance.new("BillboardGui")
gui.Name = "BabylonItemEsp"
gui.Size = UDim2.new(0, 170, 0, big and 34 or 26)
gui.StudsOffset = Vector3.new(0, 1.8, 0)
gui.AlwaysOnTop = true
gui.Adornee = part
gui.Parent = part
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.TextColor3 = color
label.TextStrokeTransparency = 0.25
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.Parent = gui
return gui, label
end

local function clearItem(inst)
local o = itemObjs[inst]
if o then
pcall(function() o.gui:Destroy() end)
if o.hl then pcall(function() o.hl:Destroy() end) end
itemObjs[inst] = nil
end
end

local function attachObject(inst, kind, name)
if itemObjs[inst] then return end
local part = (inst:IsA("Tool") and inst:FindFirstChild("Handle")) or inst:FindFirstChild("Pickup") or inst:FindFirstChildWhichIsA("BasePart", true)
if not part then return end
local gui, label = makeBillboard(part, KIND_COLOR[kind], true)
itemObjs[inst] = { gui = gui, label = label, kind = kind, part = part, name = name }
end

local function createMark(spawn)
if spawnMarks[spawn] then return end
local loc = spawn:FindFirstChild("WeaponLocation") or spawn:FindFirstChildWhichIsA("BasePart", true)
if not loc then return end
local gui, label = makeBillboard(loc, Color3.fromRGB(150, 150, 170), false)
label.Text = "Empty spawn"
gui.Enabled = false
spawnMarks[spawn] = { gui = gui, label = label, part = loc }
end

local function consider(d)
if d:IsA("Tool") then
if isLoose(d) then attachObject(d, toolKind(d), d.Name) end
elseif d:IsA("Model") then
if d.Name == "WeaponSpawn" then spawnList[d] = true end
if isPickupModel(d) then attachObject(d, pickupKind(d.Name), prettyName(d.Name)) end
end
end

local function scanItems()
for _, c in ipairs(workspace:GetChildren()) do
consider(c)
if c.Name:find("Spawn") and (c:IsA("Model") or c:IsA("Folder")) then
for _, d in ipairs(c:GetChildren()) do consider(d) end
end
end
end

local itemAdded = nil
local function setItems(v)
ITEM.on = v and true or false
if ITEM.on then
scanItems()
if not itemAdded then
itemAdded = workspace.DescendantAdded:Connect(function(d)
if d:IsA("Model") or d:IsA("Tool") then
task.delay(0.2, function()
if ITEM.on and d.Parent then consider(d) end
end)
end
end)
end
else
if itemAdded then itemAdded:Disconnect() itemAdded = nil end
for inst in pairs(itemObjs) do clearItem(inst) end
for sp, m in pairs(spawnMarks) do pcall(function() m.gui:Destroy() end) spawnMarks[sp] = nil end
table.clear(spawnList)
end
toast("Item ESP " .. (ITEM.on and "ON" or "OFF"))
end

local itemAcc = 0
local itemConn = RunService.Heartbeat:Connect(function(dt)
if not ITEM.on then return end
itemAcc += dt
if itemAcc < 0.4 then return end
itemAcc = 0
local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
local myPos = myRoot and myRoot.Position
local shown = {}
for inst, o in pairs(itemObjs) do
local stillThere = inst.Parent and o.part.Parent
if stillThere and inst:IsA("Tool") then stillThere = isLoose(inst) end
if not stillThere then
clearItem(inst)
else
local kindOn = (o.kind == "gun" and ITEM.guns) or (o.kind == "melee" and ITEM.melee) or (o.kind == "other" and ITEM.other)
local dist = myPos and (myPos - o.part.Position).Magnitude or 0
if kindOn and dist <= ITEM.maxDist then
if o.gui.MaxDistance ~= ITEM.maxDist then o.gui.MaxDistance = ITEM.maxDist end
o.gui.Enabled = true
o.label.Text = o.name .. "\n" .. KIND_NAME[o.kind] .. "  [" .. math.floor(dist) .. "m]"
table.insert(shown, { inst = inst, dist = dist })
else
o.gui.Enabled = false
if o.hl then o.hl:Destroy() o.hl = nil end
end
end
end
if ITEM.empty then
for sp in pairs(spawnList) do
if not sp.Parent then spawnList[sp] = nil else createMark(sp) end
end
elseif next(spawnMarks) then
for sp, m in pairs(spawnMarks) do pcall(function() m.gui:Destroy() end) spawnMarks[sp] = nil end
end
for sp, m in pairs(spawnMarks) do
if not sp.Parent or not m.part.Parent then
pcall(function() m.gui:Destroy() end)
spawnMarks[sp] = nil
else
local filled = false
for _, ch in ipairs(sp:GetChildren()) do
if ch:IsA("Model") and isPickupModel(ch) then filled = true break end
end
local dist = myPos and (myPos - m.part.Position).Magnitude or 0
m.gui.Enabled = ITEM.empty and not filled and dist <= ITEM.maxDist
if m.gui.Enabled then m.label.Text = "Empty spawn  [" .. math.floor(dist) .. "m]" end
end
end
table.sort(shown, function(a, b) return a.dist < b.dist end)
for i, e in ipairs(shown) do
local o = itemObjs[e.inst]
if i <= ITEM.glowNearest and e.dist <= ITEM.glowRange then
if not o.hl then
local hl = Instance.new("Highlight")
hl.FillColor = KIND_COLOR[o.kind]
hl.FillTransparency = 0.55
hl.OutlineColor = Color3.new(1, 1, 1)
hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
hl.Adornee = e.inst
hl.Parent = e.inst
o.hl = hl
end
elseif o.hl then
o.hl:Destroy()
o.hl = nil
end
end
end)

local inputConn = UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == CFG.key then setOn(not on) end
if input.KeyCode == ITEM.key then setItems(not ITEM.on) end
end)

getgenv().BabylonESP = {
cfg = CFG,
toggle = function() setOn(not on) end,
isOn = function() return on end,
toggleItems = function() setItems(not ITEM.on) end,
itemsOn = function() return ITEM.on end,
stop = function()
conn:Disconnect()
itemConn:Disconnect()
inputConn:Disconnect()
if itemAdded then itemAdded:Disconnect() itemAdded = nil end
for t in pairs(itemObjs) do clearItem(t) end
for sp, m in pairs(spawnMarks) do pcall(function() m.gui:Destroy() end) spawnMarks[sp] = nil end
table.clear(spawnList)
clearAll()
getgenv().BabylonESP = nil
end,
}
table.insert(stops, function() if getgenv().BabylonESP then getgenv().BabylonESP.stop() end end)
end)

run("Jump", function()
local CFG = {
key = Enum.KeyCode.J,
infinite = false,    -- jump again in mid-air
softLanding = false, -- slows your fall just before you hit the ground (helps against fall damage)
fallSpeed = 45,      -- falling faster than this triggers the soft landing
landingSpeed = 25,   -- speed you are slowed to
showAirTime = true,  -- on-screen counter of how long you have been in the air
autoLand = true,
landAt = 4.2,        -- be on the ground by this many seconds of air time (the game's limit is 5.0)
descentSpeed = 50,   -- studs per second while coming down
jumpPower = 44,      -- upward speed of each extra jump
boost = true,        -- jump higher from the ground too
groundPower = 95,    -- the Humanoid jump power used while "boost" is on (the game's normal value is usually 50)
}
local origJump = nil -- { UseJumpPower, JumpPower, JumpHeight } as the game had them
local conns = {}
local airTime, bestAir, forceLand, lastBoost = 0, 0, false, 0
local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Exclude

local function groundDistance(char, root)
groundParams.FilterDescendantsInstances = { char }
local hit = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), groundParams)
return hit and (root.Position.Y - hit.Position.Y - 3) or nil
end

local airLabel = Instance.new("TextLabel")
airLabel.Name = "AirTime"
airLabel.AnchorPoint = Vector2.new(0.5, 0)
airLabel.Position = UDim2.new(0.5, 0, 0, 12)
airLabel.Size = UDim2.new(0, 230, 0, 30)
airLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
airLabel.BackgroundTransparency = 0.25
airLabel.TextColor3 = Color3.new(1, 1, 1)
airLabel.Font = Enum.Font.GothamMedium
airLabel.TextSize = 15
airLabel.ZIndex = 100
airLabel.Parent = ui
Instance.new("UICorner", airLabel).CornerRadius = UDim.new(0, 8)

local function humanoid()
local c = lp.Character
return c and c:FindFirstChildOfClass("Humanoid")
end

table.insert(conns, UIS.JumpRequest:Connect(function()
if not CFG.infinite or forceLand then return end
local c = lp.Character
local hum = humanoid()
local root = c and c:FindFirstChild("HumanoidRootPart")
if not hum or not root or hum.Health <= 0 then return end
if hum.FloorMaterial ~= Enum.Material.Air or airTime < 0.12 then return end -- the normal jump handles the ground
local now = os.clock()
if now - lastBoost < 0.15 then return end
lastBoost = now
local v = root.AssemblyLinearVelocity
root.AssemblyLinearVelocity = Vector3.new(v.X, CFG.jumpPower, v.Z)
end))

table.insert(conns, RunService.Heartbeat:Connect(function()
local hum = humanoid()
if not hum then return end
if CFG.boost then
if not origJump then origJump = { hum.UseJumpPower, hum.JumpPower, hum.JumpHeight } end
if not hum.UseJumpPower then hum.UseJumpPower = true end
if hum.JumpPower ~= CFG.groundPower then hum.JumpPower = CFG.groundPower end
elseif origJump then
hum.UseJumpPower, hum.JumpPower, hum.JumpHeight = origJump[1], origJump[2], origJump[3]
origJump = nil
end
end))

local lastAirText, lastAirColor = "", nil
table.insert(conns, RunService.Heartbeat:Connect(function(dt)
local hum = humanoid()
local c = lp.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
if not hum or not root or hum.Health <= 0 then
airTime = 0
forceLand = false
elseif hum.FloorMaterial == Enum.Material.Air then
airTime += dt
if airTime > bestAir then bestAir = airTime end
local dist
if CFG.autoLand and not forceLand then
dist = groundDistance(c, root) or 150
if airTime + math.max(dist, 0) / CFG.descentSpeed >= CFG.landAt then
forceLand = true
toast("Landing - the game kills you after 5s in the air")
end
end
if forceLand then
dist = dist or groundDistance(c, root) or 150
local v = root.AssemblyLinearVelocity
if dist < 14 then
if v.Y < -22 or v.Y > 0 then root.AssemblyLinearVelocity = Vector3.new(v.X, -22, v.Z) end
elseif v.Y > -CFG.descentSpeed then
root.AssemblyLinearVelocity = Vector3.new(v.X, -CFG.descentSpeed, v.Z)
end
end
else
airTime = 0
forceLand = false
end
if airLabel.Visible ~= CFG.showAirTime then airLabel.Visible = CFG.showAirTime end
if CFG.showAirTime then
local txt = string.format("Air time: %.1fs   best %.1fs", airTime, bestAir)
if txt ~= lastAirText then
lastAirText = txt
airLabel.Text = txt
end
local col
if forceLand then
col = Color3.fromRGB(255, 120, 120)
elseif CFG.autoLand and airTime >= CFG.landAt * 0.7 then
col = Color3.fromRGB(255, 200, 120)
else
col = Color3.new(1, 1, 1)
end
if col ~= lastAirColor then
lastAirColor = col
airLabel.TextColor3 = col
end
end
end))

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
table.insert(conns, RunService.Heartbeat:Connect(function()
if not CFG.softLanding then return end
local c = lp.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
if not root then return end
local v = root.AssemblyLinearVelocity
if v.Y > -CFG.fallSpeed then return end
params.FilterDescendantsInstances = { c }
local hit = workspace:Raycast(root.Position, Vector3.new(0, -16, 0), params)
if hit then
root.AssemblyLinearVelocity = Vector3.new(v.X, -CFG.landingSpeed, v.Z)
end
end))

table.insert(conns, UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == CFG.key then
CFG.infinite = not CFG.infinite
toast("Infinite jump " .. (CFG.infinite and "ON" or "OFF"))
end
end))

getgenv().BabylonJump = {
cfg = CFG,
resetBest = function() bestAir = 0 end,
stop = function()
for _, c in ipairs(conns) do c:Disconnect() end
local hum = humanoid()
if hum and origJump then pcall(function() hum.UseJumpPower, hum.JumpPower, hum.JumpHeight = origJump[1], origJump[2], origJump[3] end) end
airLabel:Destroy()
getgenv().BabylonJump = nil
end,
}
table.insert(stops, function() if getgenv().BabylonJump then getgenv().BabylonJump.stop() end end)
end)

run("Defense", function()
local CFG = {
warn = true,          -- warn when an armed player is close
warnRadius = 70,      -- studs
antiFling = true,     -- cancel crazy spins / launch speeds on your own character
maxSpeed = 140,
maxSpin = 40,
ghostPlayers = true,  -- other players cannot push you (their bodies stop colliding with you, on your screen only)
ghostRadius = 30,
watchName = nil,      -- player you want a loud alert for (set from the menu: "Watch closest armed player")
alertRadius = 60,     -- studs
panicKey = Enum.KeyCode.B,
panicSeconds = 1.2,   -- how long the panic run lasts
panicSpeed = 50,      -- run speed away from the threat (the server pulls you back above ~59)
}
local conns = {}
local alerted = {}
local panicUntil, panicTarget = 0, nil

local flash = Instance.new("Frame")
flash.Name = "ThreatFlash"
flash.Size = UDim2.new(1, 0, 1, 0)
flash.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.Active = false
flash.ZIndex = 5
flash.Parent = ui
local flashOn = false

local function findPlayer(name)
if not name or name == "" then return nil end
name = name:lower()
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp and (p.Name:lower():find(name, 1, true) or p.DisplayName:lower():find(name, 1, true)) then return p end
end
return nil
end

local function rootOf(p)
local c = p and p.Character
return c and c:FindFirstChild("HumanoidRootPart")
end

local function nearestArmed()
local myRoot = rootOf(lp)
if not myRoot then return nil end
local best, bestD
for _, p in ipairs(Players:GetPlayers()) do
local r = p ~= lp and rootOf(p)
if r and p.Character then
local held = false
for _, t in ipairs(p.Character:GetChildren()) do
if t:IsA("Tool") and t:FindFirstChild("FireEvent") then held = true break end
end
local d = (r.Position - myRoot.Position).Magnitude
if held and (not bestD or d < bestD) then best, bestD = p, d end
end
end
return best, bestD
end

local hud = Instance.new("TextLabel")
hud.Name = "Threats"
hud.AnchorPoint = Vector2.new(0.5, 0)
hud.Position = UDim2.new(0.5, 0, 0, 48)
hud.Size = UDim2.new(0, 280, 0, 28)
hud.BackgroundColor3 = Color3.fromRGB(90, 25, 25)
hud.BackgroundTransparency = 0.25
hud.TextColor3 = Color3.new(1, 1, 1)
hud.Font = Enum.Font.GothamMedium
hud.TextSize = 14
hud.ZIndex = 100
hud.Visible = false
hud.Parent = ui
Instance.new("UICorner", hud).CornerRadius = UDim.new(0, 8)

local function armedWith(char)
for _, t in ipairs(char:GetChildren()) do
if t:IsA("Tool") and t:FindFirstChild("FireEvent") then return t.Name end
end
return nil
end

local acc = 0
table.insert(conns, RunService.Heartbeat:Connect(function(dt)
local myChar = lp.Character
local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

if CFG.antiFling and myRoot then
if myRoot.AssemblyAngularVelocity.Magnitude > CFG.maxSpin then
myRoot.AssemblyAngularVelocity = Vector3.zero
end
local v = myRoot.AssemblyLinearVelocity
if v.Magnitude > CFG.maxSpeed then
myRoot.AssemblyLinearVelocity = v.Unit * 50
end
end

if os.clock() < panicUntil and myRoot then
local tr = rootOf(panicTarget)
if tr then
local away = Vector3.new(myRoot.Position.X - tr.Position.X, 0, myRoot.Position.Z - tr.Position.Z)
if away.Magnitude > 0.1 then
local v = myRoot.AssemblyLinearVelocity
local d = away.Unit * CFG.panicSpeed
myRoot.AssemblyLinearVelocity = Vector3.new(d.X, v.Y, d.Z)
end
end
end

acc += dt
if acc < 0.25 then return end
acc = 0

local count, closest, closestName = 0, math.huge, nil
if CFG.warn and myRoot then
for _, p in ipairs(Players:GetPlayers()) do
local c = p ~= lp and p.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
if root then
local dist = (root.Position - myRoot.Position).Magnitude
local weapon = dist <= CFG.warnRadius and armedWith(c)
if weapon then
count += 1
if dist < closest then closest, closestName = dist, p.Name end
if not alerted[p] or os.clock() - alerted[p] > 10 then
toast(p.Name .. " is armed (" .. weapon .. ") " .. math.floor(dist) .. "m away")
end
alerted[p] = os.clock()
end
end
end
end
hud.Visible = count > 0
if count > 0 then
hud.Text = string.format("Armed nearby: %d   closest %s %dm", count, closestName, math.floor(closest))
end

local alarm = false
local wp = findPlayer(CFG.watchName)
local wroot = rootOf(wp)
if wroot and myRoot then
local d = (wroot.Position - myRoot.Position).Magnitude
if d <= CFG.alertRadius then
alarm = true
hud.Visible = true
hud.Text = string.format("WATCHING %s  %dm   (%s = panic)", wp.Name, math.floor(d), CFG.panicKey.Name)
end
end
flashOn = alarm and not flashOn
flash.BackgroundTransparency = flashOn and 0.88 or 1
end))

table.insert(conns, UIS.InputBegan:Connect(function(input, processed)
if processed or input.KeyCode ~= CFG.panicKey then return end
local target = findPlayer(CFG.watchName)
if not target or not rootOf(target) then target = nearestArmed() end
if target and rootOf(target) then
panicTarget = target
panicUntil = os.clock() + CFG.panicSeconds
toast("Panic: running away from " .. target.Name)
else
toast("Panic: nobody armed nearby")
end
end))

table.insert(conns, RunService.Stepped:Connect(function()
if not CFG.ghostPlayers then return end
local myChar = lp.Character
local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
if not myRoot then return end
for _, p in ipairs(Players:GetPlayers()) do
local c = p ~= lp and p.Character
local root = c and c:FindFirstChild("HumanoidRootPart")
if root and (root.Position - myRoot.Position).Magnitude < CFG.ghostRadius then
for _, part in ipairs(c:GetChildren()) do
if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
end
end
end
end))

getgenv().BabylonDefense = {
cfg = CFG,
stop = function()
for _, c in ipairs(conns) do c:Disconnect() end
hud:Destroy()
flash:Destroy()
getgenv().BabylonDefense = nil
end,
watchNearest = function()
local p = nearestArmed()
CFG.watchName = p and p.Name or nil
return CFG.watchName
end,
clearWatch = function() CFG.watchName = nil end,
}
table.insert(stops, function() if getgenv().BabylonDefense then getgenv().BabylonDefense.stop() end end)
end)

run("Crosshair", function()
local GuiService = game:GetService("GuiService")
local CFG = {
key = Enum.KeyCode.H,
enabled = true,
length = 9,      -- length of each arm in pixels
gap = 4,         -- empty space around the centre
thickness = 2,
dot = true,      -- small dot in the middle
color = Color3.fromRGB(80, 255, 140),
}
local PALETTE = {
Color3.fromRGB(80, 255, 140), Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 255, 255),
Color3.fromRGB(80, 200, 255), Color3.fromRGB(255, 220, 60),
}
local paletteIndex = 1

local gui = Instance.new("ScreenGui")
gui.Name = "BabylonCrosshair"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 990 -- below the Babylon menu (999) so the menu is never covered
gui.Parent = uiParent

local holder = Instance.new("Frame")
holder.Size = UDim2.new(1, 0, 1, 0)
holder.BackgroundTransparency = 1
holder.Active = false
holder.Parent = gui

local center = Instance.new("Frame") -- an invisible point that follows the mouse
center.Size = UDim2.fromOffset(0, 0)
center.BackgroundTransparency = 1
center.Parent = holder

local parts = {}
local function part()
local f = Instance.new("Frame")
f.AnchorPoint = Vector2.new(0.5, 0.5)
f.BorderSizePixel = 0
f.Active = false
local s = Instance.new("UIStroke")
s.Thickness = 1
s.Color = Color3.new(0, 0, 0)
s.Parent = f
f.Parent = center
table.insert(parts, f)
return f
end
local top, bottom, left, right, dot = part(), part(), part(), part(), part()

local sL, sG, sT, sD, sC
local function layout()
local L, G, T = CFG.length, CFG.gap, CFG.thickness
if L == sL and G == sG and T == sT and CFG.dot == sD and CFG.color == sC then return end
sL, sG, sT, sD, sC = L, G, T, CFG.dot, CFG.color
top.Size = UDim2.fromOffset(T, L)
top.Position = UDim2.fromOffset(0, -(G + L / 2))
bottom.Size = UDim2.fromOffset(T, L)
bottom.Position = UDim2.fromOffset(0, G + L / 2)
left.Size = UDim2.fromOffset(L, T)
left.Position = UDim2.fromOffset(-(G + L / 2), 0)
right.Size = UDim2.fromOffset(L, T)
right.Position = UDim2.fromOffset(G + L / 2, 0)
dot.Size = UDim2.fromOffset(T + 1, T + 1)
dot.Position = UDim2.fromOffset(0, 0)
dot.Visible = CFG.dot
for _, p in ipairs(parts) do p.BackgroundColor3 = CFG.color end
end
layout()

local conns = {}
table.insert(conns, RunService.RenderStepped:Connect(function()
gui.Enabled = CFG.enabled
if not CFG.enabled then return end
layout()
local m = UIS:GetMouseLocation()
local inset = GuiService:GetGuiInset()
center.Position = UDim2.fromOffset(m.X - inset.X, m.Y - inset.Y)
end))

table.insert(conns, UIS.InputBegan:Connect(function(input, processed)
if processed or input.KeyCode ~= CFG.key then return end
CFG.enabled = not CFG.enabled
toast("Crosshair " .. (CFG.enabled and "ON" or "OFF"))
end))

getgenv().BabylonCrosshair = {
cfg = CFG,
nextColor = function()
paletteIndex = paletteIndex % #PALETTE + 1
CFG.color = PALETTE[paletteIndex]
end,
stop = function()
for _, c in ipairs(conns) do c:Disconnect() end
gui:Destroy()
getgenv().BabylonCrosshair = nil
end,
}
table.insert(stops, function() if getgenv().BabylonCrosshair then getgenv().BabylonCrosshair.stop() end end)
end)

run("Menu", function()
local THEME = {
bg = Color3.fromRGB(11, 11, 19),
side = Color3.fromRGB(15, 15, 25),
item = Color3.fromRGB(21, 21, 34),
hover = Color3.fromRGB(34, 30, 58),
line = Color3.fromRGB(44, 42, 70),
text = Color3.fromRGB(240, 240, 250),
sub = Color3.fromRGB(138, 138, 165),
accent = ACCENT,
accent2 = ACCENT2,
on = ACCENT,
off = Color3.fromRGB(52, 52, 76),
}
local menuKey = Enum.KeyCode.RightShift
local conns, syncs = {}, {}
local activeSlider = nil
local listening = nil

local function corner(o, r)
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, r or 8)
c.Parent = o
end

local function mk(class, props, parent)
local o = Instance.new(class)
for k, v in pairs(props) do o[k] = v end
o.Parent = parent
return o
end

local function execName()
local ok, name = pcall(function() return identifyexecutor and identifyexecutor() or "unknown" end)
return tostring(ok and name or "unknown")
end

toastLabel.ZIndex = 100
badge.ZIndex = 100

local win = mk("Frame", {
Name = "Window",
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0.5, 0, 0.5, 0),
Size = UDim2.new(0, 610, 0, 400),
BackgroundColor3 = Color3.new(1, 1, 1),
BorderSizePixel = 0,
ClipsDescendants = true,
Active = true,
Visible = not splash.active,
}, ui)
corner(win, 14)
local winScale = mk("UIScale", { Scale = splash.active and 0.9 or 1 }, win)
mk("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(19, 14, 36), Color3.fromRGB(8, 8, 15)), Rotation = 65 }, win)
local winStroke = mk("UIStroke", { Thickness = 1.6, Color = Color3.new(1, 1, 1), Transparency = 0.1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, win)
spin(accentGradient(winStroke, 0), 50, win)

local top = mk("Frame", { Name = "Top", Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, win)
mk("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(30, 22, 56), Color3.fromRGB(15, 15, 26)), Rotation = 0 }, top)
local line = mk("Frame", { Position = UDim2.new(0, 0, 0, 46), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, win)
spin(accentGradient(line, 0), 60, win)

local dot = mk("Frame", { Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 16, 0.5, -5), BackgroundColor3 = THEME.accent2, BorderSizePixel = 0 }, top)
corner(dot, 5)
pcall(function()
TweenService:Create(dot, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency = 0.75 }):Play()
end)
local title = mk("TextLabel", {
Position = UDim2.new(0, 36, 0, 0),
Size = UDim2.new(0, 100, 1, 0),
BackgroundTransparency = 1,
Text = "BABYLON",
TextXAlignment = Enum.TextXAlignment.Left,
Font = Enum.Font.GothamBlack,
TextSize = 20,
TextColor3 = Color3.new(1, 1, 1),
}, top)
spin(accentGradient(title, 0), 70, win)
mk("TextLabel", {
Position = UDim2.new(0, 138, 0, 0),
Size = UDim2.new(0, 170, 1, 0),
BackgroundTransparency = 1,
Text = "injected  |  " .. execName(),
TextXAlignment = Enum.TextXAlignment.Left,
Font = Enum.Font.Gotham,
TextSize = 12,
TextColor3 = THEME.sub,
}, top)
mk("TextLabel", {
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -50, 0, 0),
Size = UDim2.new(0, 220, 1, 0),
BackgroundTransparency = 1,
Text = CREDIT,
RichText = true,
TextXAlignment = Enum.TextXAlignment.Right,
Font = Enum.Font.GothamMedium,
TextSize = 12,
TextColor3 = THEME.sub,
}, top)
local hideBtn = mk("TextButton", {
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -10, 0.5, 0),
Size = UDim2.new(0, 28, 0, 24),
Text = "-",
Font = Enum.Font.GothamBold,
TextSize = 16,
TextColor3 = THEME.text,
BackgroundColor3 = THEME.item,
BorderSizePixel = 0,
AutoButtonColor = false,
}, top)
corner(hideBtn, 7)
table.insert(conns, hideBtn.MouseEnter:Connect(function() tween(hideBtn, 0.12, { BackgroundColor3 = THEME.hover }) end))
table.insert(conns, hideBtn.MouseLeave:Connect(function() tween(hideBtn, 0.12, { BackgroundColor3 = THEME.item }) end))

local side = mk("Frame", { Position = UDim2.new(0, 0, 0, 47), Size = UDim2.new(0, 142, 1, -47), BackgroundColor3 = THEME.side, BorderSizePixel = 0 }, win)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, side)
mk("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, side)
mk("TextLabel", {
Position = UDim2.new(0, 12, 1, -44),
Size = UDim2.new(0, 124, 0, 36),
BackgroundTransparency = 1,
Text = '<font size="10" color="#6c6c8a">MADE BY</font>\n<font color="#9d7bff">Ace</font> <font color="#6c6c8a">&amp;</font> <font color="#4fd8ff">Hinazuki</font>',
RichText = true,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Center,
Font = Enum.Font.GothamBold,
TextSize = 13,
TextColor3 = THEME.sub,
}, win)

local menuOpen = not splash.active
local menuToken = 0
getgenv().__BabylonMenuOpen = menuOpen
local function setMenu(show)
menuToken += 1
local mine = menuToken
menuOpen = show
getgenv().__BabylonMenuOpen = show
if show then
win.Visible = true
winScale.Scale = 0.93
tween(winScale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
else
tween(winScale, 0.12, { Scale = 0.94 })
task.delay(0.12, function()
if menuToken == mine then win.Visible = false end
end)
end
end
onIntroDone = function() setMenu(true) end

local dragging, dragStart, startPos = false, nil, nil
table.insert(conns, top.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = true
dragStart = input.Position
startPos = win.Position
end
end))
table.insert(conns, UIS.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement then
if dragging and dragStart then
local d = input.Position - dragStart
win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end
if activeSlider then activeSlider(input.Position.X) end
end
end))
table.insert(conns, UIS.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
activeSlider = nil
end
end))

local pages, tabButtons, tabBars = {}, {}, {}
local currentTab = nil
local function selectTab(name)
for n, pg in pairs(pages) do
if n == name then
if currentTab ~= name then
pg.Position = UDim2.new(0, 152, 0, 62)
pg.Visible = true
tween(pg, 0.22, { Position = UDim2.new(0, 152, 0, 54) })
end
else
pg.Visible = false
end
end
for n, b in pairs(tabButtons) do
local sel = n == name
tween(b, 0.15, { BackgroundTransparency = sel and 0.75 or 1, TextColor3 = sel and Color3.new(1, 1, 1) or THEME.sub })
tabBars[n].Visible = sel
end
currentTab = name
end

local tabCount = 0
local function newTab(name)
tabCount += 1
local btn = mk("TextButton", {
Size = UDim2.new(1, 0, 0, 34),
Text = name,
TextXAlignment = Enum.TextXAlignment.Left,
Font = Enum.Font.GothamMedium,
TextSize = 14,
BackgroundColor3 = THEME.accent,
BackgroundTransparency = 1,
TextColor3 = THEME.sub,
AutoButtonColor = false,
BorderSizePixel = 0,
LayoutOrder = tabCount,
}, side)
corner(btn, 8)
mk("UIPadding", { PaddingLeft = UDim.new(0, 16) }, btn)
local bar = mk("Frame", { Position = UDim2.new(0, -12, 0.5, -9), Size = UDim2.new(0, 3, 0, 18), BackgroundColor3 = THEME.accent2, BorderSizePixel = 0, Visible = false }, btn)
corner(bar, 2)
local page = mk("ScrollingFrame", {
Position = UDim2.new(0, 152, 0, 54),
Size = UDim2.new(1, -162, 1, -64),
BackgroundTransparency = 1,
BorderSizePixel = 0,
ScrollBarThickness = 3,
ScrollBarImageColor3 = THEME.accent,
CanvasSize = UDim2.new(0, 0, 0, 0),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
Visible = false,
}, win)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)
mk("UIPadding", { PaddingRight = UDim.new(0, 6) }, page)
pages[name] = page
tabButtons[name] = btn
tabBars[name] = bar
table.insert(conns, btn.MouseEnter:Connect(function()
if currentTab ~= name then tween(btn, 0.12, { TextColor3 = THEME.text }) end
end))
table.insert(conns, btn.MouseLeave:Connect(function()
if currentTab ~= name then tween(btn, 0.12, { TextColor3 = THEME.sub }) end
end))
table.insert(conns, btn.MouseButton1Click:Connect(function() selectTab(name) end))
return page
end

local function row(page, h)
local r = mk("Frame", { Size = UDim2.new(1, 0, 0, h or 40), BackgroundColor3 = THEME.item, BorderSizePixel = 0 }, page)
corner(r, 9)
mk("UIStroke", { Color = THEME.line, Thickness = 1, Transparency = 0.35, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, r)
return r
end

local function nameLabel(r, text)
return mk("TextLabel", {
Position = UDim2.new(0, 14, 0, 0),
Size = UDim2.new(1, -90, 0, 40),
BackgroundTransparency = 1,
Text = text,
TextXAlignment = Enum.TextXAlignment.Left,
Font = Enum.Font.GothamMedium,
TextSize = 14,
TextColor3 = THEME.text,
}, r)
end

local function infoLabel(page, text, h)
local r = row(page, h or 30)
mk("TextLabel", {
Position = UDim2.new(0, 14, 0, 0),
Size = UDim2.new(1, -28, 1, 0),
BackgroundTransparency = 1,
Text = text,
TextWrapped = true,
TextXAlignment = Enum.TextXAlignment.Left,
Font = Enum.Font.Gotham,
TextSize = 12,
TextColor3 = THEME.sub,
}, r)
return r
end

local function addToggle(page, text, getter, setter)
local r = row(page)
nameLabel(r, text)
local sw = mk("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 44, 0, 22), BackgroundColor3 = THEME.off, BorderSizePixel = 0 }, r)
corner(sw, 11)
local grad = accentGradient(sw, 0)
grad.Enabled = false
local knob = mk("Frame", { Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, sw)
corner(knob, 8)
local state = false
local function render(v, animate)
grad.Enabled = v
local pos = v and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
local col = v and Color3.new(1, 1, 1) or THEME.off
if animate then
tween(knob, 0.16, { Position = pos })
tween(sw, 0.16, { BackgroundColor3 = col })
else
knob.Position = pos
sw.BackgroundColor3 = col
end
end
state = getter() and true or false
render(state, false)
local hit = mk("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 5 }, r)
table.insert(conns, hit.MouseEnter:Connect(function() tween(r, 0.12, { BackgroundColor3 = THEME.hover }) end))
table.insert(conns, hit.MouseLeave:Connect(function() tween(r, 0.12, { BackgroundColor3 = THEME.item }) end))
table.insert(conns, hit.MouseButton1Click:Connect(function()
state = not state
setter(state)
render(state, true)
end))
table.insert(syncs, function()
local v = getter() and true or false
if v ~= state then state = v render(v, true) end
end)
end

local function fmt(v)
if v == math.floor(v) then return tostring(v) end
return string.format("%.1f", v)
end

local function addSlider(page, text, min, max, step, getter, setter)
local r = row(page, 54)
mk("TextLabel", {
Position = UDim2.new(0, 14, 0, 4),
Size = UDim2.new(1, -90, 0, 22),
BackgroundTransparency = 1,
Text = text,
TextXAlignment = Enum.TextXAlignment.Left,
Font = Enum.Font.GothamMedium,
TextSize = 14,
TextColor3 = THEME.text,
}, r)
local valueLabel = mk("TextLabel", {
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, -14, 0, 4),
Size = UDim2.new(0, 70, 0, 22),
BackgroundTransparency = 1,
TextXAlignment = Enum.TextXAlignment.Right,
Font = Enum.Font.GothamBold,
TextSize = 14,
TextColor3 = THEME.accent2,
}, r)
local track = mk("Frame", { Position = UDim2.new(0, 14, 0, 38), Size = UDim2.new(1, -28, 0, 6), BackgroundColor3 = THEME.off, BorderSizePixel = 0 }, r)
corner(track, 3)
local fill = mk("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, track)
corner(fill, 3)
accentGradient(fill, 0)
local knob = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, track)
corner(knob, 7)
mk("UIStroke", { Color = THEME.accent, Thickness = 2 }, knob)
local shown = nil
local function render(v)
shown = v
local alpha = math.clamp((v - min) / (max - min), 0, 1)
fill.Size = UDim2.new(alpha, 0, 1, 0)
knob.Position = UDim2.new(alpha, 0, 0.5, 0)
valueLabel.Text = fmt(v)
end
local function fromX(x)
local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
local v = min + alpha * (max - min)
v = math.clamp(math.floor(v / step + 0.5) * step, min, max)
setter(v)
render(v)
end
render(getter())
table.insert(conns, track.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
activeSlider = fromX
fromX(input.Position.X)
end
end))
table.insert(syncs, function()
local v = getter()
if v ~= shown then render(v) end
end)
end

local function addButton(page, text, callback)
local r = row(page)
local b = mk("TextButton", {
Size = UDim2.new(1, 0, 1, 0),
BackgroundTransparency = 1,
Text = text,
Font = Enum.Font.GothamMedium,
TextSize = 14,
TextColor3 = THEME.text,
AutoButtonColor = false,
}, r)
mk("TextLabel", {
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -14, 0.5, 0),
Size = UDim2.new(0, 14, 0, 20),
BackgroundTransparency = 1,
Text = ">",
Font = Enum.Font.GothamBold,
TextSize = 14,
TextColor3 = THEME.accent,
}, r)
table.insert(conns, b.MouseEnter:Connect(function()
tween(r, 0.12, { BackgroundColor3 = THEME.hover })
tween(b, 0.12, { TextColor3 = THEME.accent2 })
end))
table.insert(conns, b.MouseLeave:Connect(function()
tween(r, 0.12, { BackgroundColor3 = THEME.item })
tween(b, 0.12, { TextColor3 = THEME.text })
end))
table.insert(conns, b.MouseButton1Click:Connect(function()
tween(r, 0.06, { BackgroundColor3 = THEME.accent })
task.delay(0.08, function() tween(r, 0.25, { BackgroundColor3 = THEME.hover }) end)
pcall(callback)
end))
end

local function addKeybind(page, text, getter, setter)
local r = row(page)
nameLabel(r, text)
local b = mk("TextButton", {
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.new(0, 78, 0, 26),
BackgroundColor3 = THEME.bg,
Font = Enum.Font.GothamBold,
TextSize = 13,
TextColor3 = THEME.accent2,
AutoButtonColor = false,
BorderSizePixel = 0,
}, r)
corner(b, 7)
mk("UIStroke", { Color = THEME.line, Thickness = 1 }, b)
local function render() b.Text = getter().Name end
render()
table.insert(conns, b.MouseButton1Click:Connect(function()
b.Text = "press key"
listening = function(key)
if key then
task.defer(function()
setter(key)
render()
end)
else
render()
end
end
end))
table.insert(syncs, function() if not listening then render() end end)
end

table.insert(conns, UIS.InputBegan:Connect(function(input, processed)
if listening and input.UserInputType == Enum.UserInputType.Keyboard then
local cb = listening
listening = nil
cb(input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode or nil)
return
end
if processed then return end
if input.KeyCode == menuKey and not (splash.active and not menuOpen and ui:FindFirstChild("Intro")) then setMenu(not menuOpen) end
end))
table.insert(conns, hideBtn.MouseButton1Click:Connect(function() setMenu(false) end))

local function api(name) return getgenv()[name] end

local gate = newTab("Gate")
addToggle(gate, "Gate of Babylon", function() local g = api("FloatGuns") return g and g.isOn and g.isOn() end, function(v) local g = api("FloatGuns") if g then g.set(v) end end)
addKeybind(gate, "Toggle key", function() local g = api("FloatGuns") return g and g.cfg.toggleKey or Enum.KeyCode.G end, function(k) local g = api("FloatGuns") if g then g.cfg.toggleKey = k end end)
addSlider(gate, "Spread (degrees)", 20, 140, 1, function() local g = api("FloatGuns") return g and g.cfg.fanAngle or 80 end, function(v) local g = api("FloatGuns") if g then g.cfg.fanAngle = v end end)
addSlider(gate, "Wall height", 2, 10, 0.5, function() local g = api("FloatGuns") return g and g.cfg.baseHeight or 4.5 end, function(v) local g = api("FloatGuns") if g then g.cfg.baseHeight = v end end)
addSlider(gate, "Held gun height", 2, 8, 0.5, function() local g = api("FloatGuns") return g and g.cfg.heldHeight or 4.4 end, function(v) local g = api("FloatGuns") if g then g.cfg.heldHeight = v end end)
addSlider(gate, "Guns per row", 2, 12, 1, function() local g = api("FloatGuns") return g and g.cfg.gunsPerRow or 6 end, function(v) local g = api("FloatGuns") if g then g.cfg.gunsPerRow = v end end)
addToggle(gate, "Reload all guns together", function() local g = api("FloatGuns") return g and g.cfg.reloadAll end, function(v) local g = api("FloatGuns") if g then g.cfg.reloadAll = v end end)
addToggle(gate, "No camera recoil (screen shake)", function() local g = api("FloatGuns") return g and g.cfg.noRecoil end, function(v) local g = api("FloatGuns") if g then g.setNoRecoil(v) end end)
addToggle(gate, "Gate FX (portals, swords, music)", function() local g = api("FloatGuns") return g and g.cfg.fx end, function(v) local g = api("FloatGuns") if g then g.cfg.fx = v end end)
addToggle(gate, "  Golden portals", function() local g = api("FloatGuns") return g and g.cfg.portals end, function(v) local g = api("FloatGuns") if g then g.cfg.portals = v end end)
addToggle(gate, "  Hide gun models (your screen only)", function() local g = api("FloatGuns") return g and g.cfg.hideGuns end, function(v) local g = api("FloatGuns") if g then g.cfg.hideGuns = v end end)
addToggle(gate, "  Swords and spears fly out on every shot", function() local g = api("FloatGuns") return g and g.cfg.swords end, function(v) local g = api("FloatGuns") if g then g.cfg.swords = v end end)
addToggle(gate, "  See other players' gates (needs the same script, 2+ guns out)", function() local g = api("FloatGuns") return g and g.cfg.watchOthers end, function(v) local g = api("FloatGuns") if g then g.cfg.watchOthers = v end end)
addToggle(gate, "  Impact frame when the gate opens", function() local g = api("FloatGuns") return g and g.cfg.impact end, function(v) local g = api("FloatGuns") if g then g.cfg.impact = v end end)
addToggle(gate, "  Gold flash when a barrage starts", function() local g = api("FloatGuns") return g and g.cfg.impactOnFire end, function(v) local g = api("FloatGuns") if g then g.cfg.impactOnFire = v end end)
addToggle(gate, "  Ground sigil, light pillar, gold dust", function() local g = api("FloatGuns") return g and g.cfg.aura end, function(v) local g = api("FloatGuns") if g then g.cfg.aura = v end end)
addToggle(gate, "  Gold screen tint", function() local g = api("FloatGuns") return g and g.cfg.tint end, function(v) local g = api("FloatGuns") if g then g.cfg.tint = v end end)
addToggle(gate, "  Camera shake when the gate opens", function() local g = api("FloatGuns") return g and g.cfg.shake end, function(v) local g = api("FloatGuns") if g then g.cfg.shake = v end end)
addSlider(gate, "Sigil size", 6, 30, 1, function() local g = api("FloatGuns") return g and g.cfg.sigilSize or 13 end, function(v) local g = api("FloatGuns") if g then g.cfg.sigilSize = v end end)
addToggle(gate, "  Mute the guns' own sounds", function() local g = api("FloatGuns") return g and g.cfg.muteGunSounds end, function(v) local g = api("FloatGuns") if g then g.cfg.muteGunSounds = v end end)
addToggle(gate, "  Show swords while holding click (if a shot is not detected)", function() local g = api("FloatGuns") return g and g.cfg.fallbackFire end, function(v) local g = api("FloatGuns") if g then g.cfg.fallbackFire = v end end)
addSlider(gate, "Music volume", 0, 3, 0.05, function() local g = api("FloatGuns") return g and g.cfg.themeVolume or 0.6 end, function(v) local g = api("FloatGuns") if g then g.cfg.themeVolume = v end end)
addSlider(gate, "Shot sound volume", 0, 3, 0.05, function() local g = api("FloatGuns") return g and g.cfg.shotVolume or 0.8 end, function(v) local g = api("FloatGuns") if g then g.cfg.shotVolume = v end end)
addSlider(gate, "Portal hum volume", 0, 3, 0.05, function() local g = api("FloatGuns") return g and g.cfg.humVolume or 0.35 end, function(v) local g = api("FloatGuns") if g then g.cfg.humVolume = v end end)
addSlider(gate, "Portal size", 1.5, 8, 0.1, function() local g = api("FloatGuns") return g and g.cfg.portalSize or 3.0 end, function(v) local g = api("FloatGuns") if g then g.cfg.portalSize = v end end)
addSlider(gate, "Sword speed", 120, 700, 10, function() local g = api("FloatGuns") return g and g.cfg.swordSpeed or 340 end, function(v) local g = api("FloatGuns") if g then g.cfg.swordSpeed = v end end)
addButton(gate, "Download / reload sound files", function() local g = api("FloatGuns") if g and g.fx then g.fx.reloadSounds() end end)
infoLabel(gate, "Music and shot sounds download by themselves the first time. If they are missing, press the button above. You can also put your own gate_theme.mp3 / gate_shot.mp3 in the executor's workspace folder. The portals and swords are only on your own screen.", 70)
infoLabel(gate, "Takes effect when you equip a gun. If a gun ever will not fire, turn this off, rejoin, and tell the owner.", 44)

local fuga = newTab("Fuga")
addToggle(fuga, "Fuga ring (Molotovs)", function() local f = api("FugaRing") return f and f.isOn and f.isOn() end, function(v) local f = api("FugaRing") if f then f.set(v) end end)
addKeybind(fuga, "Toggle key", function() local f = api("FugaRing") return f and f.cfg.key or Enum.KeyCode.Z end, function(k) local f = api("FugaRing") if f then f.cfg.key = k end end)
addSlider(fuga, "Spray speed (throws per second)", 2, 15, 1, function() local f = api("FugaRing") return f and math.floor(1 / f.cfg.sprayGap + 0.5) or 8 end, function(v) local f = api("FugaRing") if f then f.cfg.sprayGap = 1 / v end end)
addButton(fuga, "Throw the whole ring at once", function() local f = api("FugaRing") if f then f.release() end end)
addToggle(fuga, "MEGA effects: shrine, sigil, lightning, sky (visual)", function() local f = api("FugaRing") return f and f.cfg.mega end, function(v) local f = api("FugaRing") if f then f.cfg.mega = v end end)
addToggle(fuga, "Flame arrow (visual)", function() local f = api("FugaRing") return f and f.cfg.arrow end, function(v) local f = api("FugaRing") if f then f.cfg.arrow = v end end)
addToggle(fuga, "Cinematic bars, tint and chant (visual)", function() local f = api("FugaRing") return f and f.cfg.cinematic end, function(v) local f = api("FugaRing") if f then f.cfg.cinematic = v end end)
addToggle(fuga, "Sound effects", function() local f = api("FugaRing") return f and f.cfg.sound end, function(v) local f = api("FugaRing") if f then f.cfg.sound = v end end)
addToggle(fuga, "Impact frame flash (visual)", function() local f = api("FugaRing") return f and f.cfg.impact end, function(v) local f = api("FugaRing") if f then f.cfg.impact = v end end)
addButton(fuga, "Next formation (ring, gyro, wings, halo)", function()
local f = api("FugaRing")
if f then toast("Formation: " .. f.nextFormation()) end
end)
addToggle(fuga, "Arm pose while spraying (others see it)", function() local f = api("FugaRing") return f and f.cfg.pose end, function(v) local f = api("FugaRing") if f then f.cfg.pose = v end end)
addToggle(fuga, "See other players' Fuga show (when they spray Molotovs)", function() local f = api("FugaRing") return f and f.cfg.watch end, function(v) local f = api("FugaRing") if f then f.cfg.watch = v end end)
addSlider(fuga, "Voice line volume", 0, 4, 0.1, function() local f = api("FugaRing") return f and f.cfg.voiceVolume or 1.6 end, function(v) local f = api("FugaRing") if f then f.cfg.voiceVolume = v end end)
addToggle(fuga, "Say Kai. / FUGA. in chat (lets script users see your show)", function() local f = api("FugaRing") return f and f.cfg.chat end, function(v) local f = api("FugaRing") if f then f.cfg.chat = v end end)
addButton(fuga, "Preview the look (throws nothing)", function() local f = api("FugaRing") if f then f.preview() end end)
addSlider(fuga, "Safe distance (studs)", 10, 80, 1, function() local f = api("FugaRing") return f and f.cfg.safeDistance or 25 end, function(v) local f = api("FugaRing") if f then f.cfg.safeDistance = v end end)
addSlider(fuga, "Ring height", 3, 14, 0.5, function() local f = api("FugaRing") return f and f.cfg.height or 9 end, function(v) local f = api("FugaRing") if f then f.cfg.height = v end end)
addSlider(fuga, "Spin speed", 0.5, 5, 0.1, function() local f = api("FugaRing") return f and f.cfg.spin or 1.6 end, function(v) local f = api("FugaRing") if f then f.cfg.spin = v end end)
addSlider(fuga, "Charge-up (seconds)", 0.1, 1.5, 0.05, function() local f = api("FugaRing") return f and f.cfg.chargeTime or 0.45 end, function(v) local f = api("FugaRing") if f then f.cfg.chargeTime = v end end)
addSlider(fuga, "Lean outwards (degrees)", 0, 80, 1, function() local f = api("FugaRing") return f and f.cfg.tilt or 40 end, function(v) local f = api("FugaRing") if f then f.cfg.tilt = v end end)
infoLabel(fuga, "Buy Molotovs at Banmin. With the ring on they float around you in a spinning circle of fire. Hold the left mouse button to spray them one after another like a machine gun, aiming with your cursor. Each Molotov lands where your cursor was when it left the ring. Each throw uses up one Molotov. Separate from the Gate (guns).", 84)

local items = newTab("Items")
addButton(items, "Open pawn / weapon shop", function() local o = api("OpenShop") if o then o.run(o.cfg.shops[1]) end end)
addKeybind(items, "Shop key", function() local o = api("OpenShop") return o and o.cfg.key or Enum.KeyCode.P end, function(k) local o = api("OpenShop") if o then o.cfg.key = k end end)
addButton(items, "Sell everything", function() local s = api("SellAll") if s then s.run() end end)
addButton(items, "Go to pawn shop and sell", function() local s = api("SellAll") if s then s.goSell() end end)
addKeybind(items, "Go-sell key", function() local s = api("SellAll") return s and s.cfg.goKey or Enum.KeyCode.B end, function(k) local s = api("SellAll") if s then s.cfg.goKey = k end end)
addKeybind(items, "Sell key", function() local s = api("SellAll") return s and s.cfg.key or Enum.KeyCode.U end, function(k) local s = api("SellAll") if s then s.cfg.key = k end end)
addToggle(items, "Ask before selling", function() local s = api("SellAll") return s and s.cfg.confirm end, function(v) local s = api("SellAll") if s then s.cfg.confirm = v end end)
addToggle(items, "Keep my guns when selling", function() local s = api("SellAll") return s and s.cfg.keepGuns end, function(v) local s = api("SellAll") if s then s.cfg.keepGuns = v end end)
addToggle(items, "Silent pickup (grab loose items from anywhere)", function() local b = api("BringGuns") return b and b.silentOn and b.silentOn() end, function(v) local b = api("BringGuns") if b and b.silentOn() ~= v then b.setSilent(v) end end)
addButton(items, "Grab all loose items now (silent)", function() local b = api("BringGuns") if b then b.grabNow() end end)
addKeybind(items, "Silent pickup key", function() local b = api("BringGuns") return b and b.cfg.silentKey or Enum.KeyCode.V end, function(k) local b = api("BringGuns") if b then b.cfg.silentKey = k end end)
addButton(items, "Bring loose weapons", function() local b = api("BringGuns") if b then b.run() end end)
addKeybind(items, "Bring key", function() local b = api("BringGuns") return b and b.cfg.key or Enum.KeyCode.K end, function(k) local b = api("BringGuns") if b then b.cfg.key = k end end)
addToggle(items, "Auto-walk to weapons (AFK farm)", function() local b = api("BringGuns") return b and b.autoOn and b.autoOn() end, function(v) local b = api("BringGuns") if b and b.autoOn() ~= v then b.setAuto(v) end end)
addButton(items, "Walk to nearest spawned weapon (once)", function() local b = api("BringGuns") if b then b.walkNearest() end end)
addKeybind(items, "Auto-walk key", function() local b = api("BringGuns") return b and b.cfg.pickupKey or Enum.KeyCode.N end, function(k) local b = api("BringGuns") if b then b.cfg.pickupKey = k end end)
addToggle(items, "  Include guns", function() local b = api("BringGuns") return b and b.cfg.guns end, function(v) local b = api("BringGuns") if b then b.cfg.guns = v end end)
addToggle(items, "  Include melee weapons", function() local b = api("BringGuns") return b and b.cfg.melee end, function(v) local b = api("BringGuns") if b then b.cfg.melee = v end end)
infoLabel(items, "Selling only works while you stand at the pawn shop, so Go to pawn shop and sell walks you there, sells, and goes back to the AFK walk. Auto-walk keeps walking you to the next weapon pickup along a real path until you switch it off. The single walk stops when you press it again or move. The game does not allow teleporting.", 58)

local shopsTab = newTab("Shops")
do
local o = api("OpenShop")
if o then
for _, shop in ipairs(o.cfg.shops) do
if shop.id ~= "1" then
addButton(shopsTab, shop.label, function() local oo = api("OpenShop") if oo then oo.run(shop) end end)
end
end
end
end
infoLabel(shopsTab, "Opens that shop's screen from anywhere. Food shops are where you buy items to heal. Prices and whether a purchase works are decided by the game, not by this menu.", 58)

local move = newTab("Movement")
addToggle(move, "Speed boost", function() local s = api("BabylonSpeed") return s and s.cfg.enabled end, function(v) local s = api("BabylonSpeed") if s and s.cfg.enabled ~= v then s.toggle() end end)
do
local s = api("BabylonSpeed")
addSlider(move, "Walk speed", s and s.cfg.min or 16, s and s.cfg.max or 58, 1, function() local x = api("BabylonSpeed") return x and x.cfg.value or 24 end, function(v) local x = api("BabylonSpeed") if x then x.set(v) end end)
end
addKeybind(move, "Speed key", function() local s = api("BabylonSpeed") return s and s.cfg.key or Enum.KeyCode.Y end, function(k) local s = api("BabylonSpeed") if s then s.cfg.key = k end end)
do
local r = infoLabel(move, "Above 28 you slow to 28 while shooting. The server pulls you back above ~59.", 46)
local lbl = r:FindFirstChildOfClass("TextLabel")
table.insert(syncs, function()
local s = api("BabylonSpeed")
if not (s and lbl) then return end
if s.cfg.enabled and s.mode and s.mode() == "velocity" then
lbl.Text = "Mode: velocity (this executor cannot unlock the game's speed limit, so you are pushed along instead). Shooting is not affected."
else
lbl.Text = "Above 28 you slow to 28 while shooting. The server pulls you back above ~59."
end
end)
end

addToggle(move, "Higher jump (from the ground)", function() local j = api("BabylonJump") return j and j.cfg.boost end, function(v) local j = api("BabylonJump") if j then j.cfg.boost = v end end)
addSlider(move, "Jump power (game default is about 50)", 50, 300, 5, function() local j = api("BabylonJump") return j and j.cfg.groundPower or 95 end, function(v) local j = api("BabylonJump") if j then j.cfg.groundPower = v end end)
addSlider(move, "Air jump power (infinite jump)", 30, 200, 2, function() local j = api("BabylonJump") return j and j.cfg.jumpPower or 44 end, function(v) local j = api("BabylonJump") if j then j.cfg.jumpPower = v end end)
addToggle(move, "Infinite jump", function() local j = api("BabylonJump") return j and j.cfg.infinite end, function(v) local j = api("BabylonJump") if j then j.cfg.infinite = v end end)
addKeybind(move, "Infinite jump key", function() local j = api("BabylonJump") return j and j.cfg.key or Enum.KeyCode.J end, function(k) local j = api("BabylonJump") if j then j.cfg.key = k end end)
addToggle(move, "Soft landing (fall damage)", function() local j = api("BabylonJump") return j and j.cfg.softLanding end, function(v) local j = api("BabylonJump") if j then j.cfg.softLanding = v end end)

addToggle(move, "Show air time", function() local j = api("BabylonJump") return j and j.cfg.showAirTime end, function(v) local j = api("BabylonJump") if j then j.cfg.showAirTime = v end end)
addToggle(move, "Auto-land before the limit", function() local j = api("BabylonJump") return j and j.cfg.autoLand end, function(v) local j = api("BabylonJump") if j then j.cfg.autoLand = v end end)
addSlider(move, "Be on the ground by (seconds)", 1, 4.8, 0.2, function() local j = api("BabylonJump") return j and j.cfg.landAt or 4.2 end, function(v) local j = api("BabylonJump") if j then j.cfg.landAt = v end end)
addButton(move, "Reset best air time", function() local j = api("BabylonJump") if j then j.resetBest() end end)

local vis = newTab("Visuals")
addToggle(vis, "Player ESP", function() local e = api("BabylonESP") return e and e.isOn and e.isOn() end, function(v) local e = api("BabylonESP") if e and e.isOn() ~= v then e.toggle() end end)
addKeybind(vis, "ESP key", function() local e = api("BabylonESP") return e and e.cfg.key or Enum.KeyCode.L end, function(k) local e = api("BabylonESP") if e then e.cfg.key = k end end)
infoLabel(vis, "Outline, name, distance, health and held item of other players.")
addToggle(vis, "Item ESP (everything that spawns)", function() local e = api("BabylonESP") return e and e.itemsOn and e.itemsOn() end, function(v) local e = api("BabylonESP") if e and e.itemsOn() ~= v then e.toggleItems() end end)
addKeybind(vis, "Item ESP key", function() local e = api("BabylonESP") return e and e.cfg.items.key or Enum.KeyCode.O end, function(k) local e = api("BabylonESP") if e then e.cfg.items.key = k end end)
addToggle(vis, "  Show guns", function() local e = api("BabylonESP") return e and e.cfg.items.guns end, function(v) local e = api("BabylonESP") if e then e.cfg.items.guns = v end end)
addToggle(vis, "  Show melee weapons", function() local e = api("BabylonESP") return e and e.cfg.items.melee end, function(v) local e = api("BabylonESP") if e then e.cfg.items.melee = v end end)
addToggle(vis, "  Show other items", function() local e = api("BabylonESP") return e and e.cfg.items.other end, function(v) local e = api("BabylonESP") if e then e.cfg.items.other = v end end)
addToggle(vis, "  Show empty spawn points", function() local e = api("BabylonESP") return e and e.cfg.items.empty end, function(v) local e = api("BabylonESP") if e then e.cfg.items.empty = v end end)
addSlider(vis, "  Item ESP range (studs)", 100, 3000, 50, function() local e = api("BabylonESP") return e and e.cfg.items.maxDist or 800 end, function(v) local e = api("BabylonESP") if e then e.cfg.items.maxDist = v end end)
infoLabel(vis, "Marks every weapon pickup on the map and every dropped tool. Orange = gun, yellow = melee, cyan = other. Spawn points show again when a pickup respawns.", 58)
addToggle(vis, "Custom crosshair", function() local c = api("BabylonCrosshair") return c and c.cfg.enabled end, function(v) local c = api("BabylonCrosshair") if c then c.cfg.enabled = v end end)
addKeybind(vis, "Crosshair key", function() local c = api("BabylonCrosshair") return c and c.cfg.key or Enum.KeyCode.H end, function(k) local c = api("BabylonCrosshair") if c then c.cfg.key = k end end)
addSlider(vis, "Crosshair size", 3, 30, 1, function() local c = api("BabylonCrosshair") return c and c.cfg.length or 9 end, function(v) local c = api("BabylonCrosshair") if c then c.cfg.length = v end end)
addSlider(vis, "Crosshair gap", 0, 20, 1, function() local c = api("BabylonCrosshair") return c and c.cfg.gap or 4 end, function(v) local c = api("BabylonCrosshair") if c then c.cfg.gap = v end end)
addSlider(vis, "Crosshair thickness", 1, 5, 1, function() local c = api("BabylonCrosshair") return c and c.cfg.thickness or 2 end, function(v) local c = api("BabylonCrosshair") if c then c.cfg.thickness = v end end)
addToggle(vis, "Crosshair centre dot", function() local c = api("BabylonCrosshair") return c and c.cfg.dot end, function(v) local c = api("BabylonCrosshair") if c then c.cfg.dot = v end end)
addButton(vis, "Next crosshair colour", function() local c = api("BabylonCrosshair") if c then c.nextColor() end end)

local def = newTab("Defense")
addToggle(def, "Armed-player warning", function() local d = api("BabylonDefense") return d and d.cfg.warn end, function(v) local d = api("BabylonDefense") if d then d.cfg.warn = v end end)
addSlider(def, "Warning distance", 20, 200, 5, function() local d = api("BabylonDefense") return d and d.cfg.warnRadius or 70 end, function(v) local d = api("BabylonDefense") if d then d.cfg.warnRadius = v end end)
addToggle(def, "Anti-fling", function() local d = api("BabylonDefense") return d and d.cfg.antiFling end, function(v) local d = api("BabylonDefense") if d then d.cfg.antiFling = v end end)
addToggle(def, "Walk through other players", function() local d = api("BabylonDefense") return d and d.cfg.ghostPlayers end, function(v) local d = api("BabylonDefense") if d then d.cfg.ghostPlayers = v end end)
infoLabel(def, "Walking through players stops them pushing you. It only changes what you see and feel on your side.", 46)
do
local r = infoLabel(def, "Watching: nobody", 24)
local lbl = r:FindFirstChildOfClass("TextLabel")
table.insert(syncs, function()
local d = api("BabylonDefense")
if lbl then lbl.Text = "Watching: " .. ((d and d.cfg.watchName) or "nobody") end
end)
end
addButton(def, "Watch closest armed player", function()
local d = api("BabylonDefense")
if not d then return end
local n = d.watchNearest()
toast(n and ("Watching " .. n) or "Nobody armed nearby to watch")
end)
addButton(def, "Stop watching", function() local d = api("BabylonDefense") if d then d.clearWatch() end end)
addSlider(def, "Alert distance", 20, 200, 5, function() local d = api("BabylonDefense") return d and d.cfg.alertRadius or 60 end, function(v) local d = api("BabylonDefense") if d then d.cfg.alertRadius = v end end)
addKeybind(def, "Panic key (run away)", function() local d = api("BabylonDefense") return d and d.cfg.panicKey or Enum.KeyCode.B end, function(k) local d = api("BabylonDefense") if d then d.cfg.panicKey = k end end)

local info = newTab("Info")
do
local cr = infoLabel(info, "", 44)
local lbl = cr:FindFirstChildOfClass("TextLabel")
lbl.RichText = true
lbl.Font = Enum.Font.GothamBold
lbl.TextSize = 16
lbl.TextColor3 = THEME.text
lbl.Text = CREDIT .. '\n<font size="12" color="#8a8aa8">Gate of Babylon</font>'
end
infoLabel(info, "Executor: " .. execName())
infoLabel(info, "RightShift shows or hides this menu.")
do
local caps = {}
for _, fname in ipairs({ "getconnections", "firetouchinterest", "sethiddenproperty", "gethui", "decompile" }) do
table.insert(caps, fname .. (getfenv()[fname] ~= nil and " yes" or " NO"))
end
infoLabel(info, "Executor features: " .. table.concat(caps, ", "), 46)
end
if #loadErrors == 0 then
infoLabel(info, "All features loaded without errors.")
else
for _, e in ipairs(loadErrors) do
infoLabel(info, "ERROR  " .. e, 60)
end
end
addButton(info, "Remove Babylon completely", function()
task.defer(function()
local all = getgenv().BabylonAll
if all then all.stop() end
end)
end)

selectTab("Gate")

local acc = 0
table.insert(conns, RunService.Heartbeat:Connect(function(dt)
acc += dt
if acc < 0.25 then return end
acc = 0
if not menuOpen then return end -- window hidden: nothing on screen to keep up to date
for _, fn in ipairs(syncs) do pcall(fn) end
end))

table.insert(stops, function()
for _, c in ipairs(conns) do c:Disconnect() end
table.clear(conns)
end)
end)

getgenv().BabylonAll = {
stop = function()
for _, fn in ipairs(stops) do pcall(fn) end
table.clear(stops)
ui:Destroy()
getgenv().BabylonAll = nil
end,
}

do
local ok, name = pcall(function() return identifyexecutor and identifyexecutor() or "unknown" end)
local fg = getgenv().FloatGuns
local recoil = fg and fg.cfg.noRecoil and "on" or "off"
badge.Text = "Babylon injected (" .. tostring(ok and name or "unknown") .. ")   RightShift = menu"
badge.Size = UDim2.new(0, 330, 0, 26)
print("[Babylon] executor=" .. tostring(ok and name or "unknown") .. " noRecoil=" .. recoil)
end

splash.finish(function()
badge.Visible = true
pcall(onIntroDone)
if #loadErrors > 0 then
badge.Text = "Babylon: " .. #loadErrors .. " feature(s) failed. See menu > Info"
badge.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
badge.TextColor3 = Color3.fromRGB(255, 170, 170)
toast(loadErrors[1])
else
toast("Babylon injected. RightShift opens the menu")
end
end)

if KS.url ~= "" then
local me = getgenv().BabylonAll
task.spawn(function()
while true do
task.wait(KS.recheck)
if getgenv().BabylonAll ~= me then break end -- stopped or replaced by a newer copy
if KS.check() == "off" then
warn("[Babylon] switched off by its owner")
pcall(function() getgenv().BabylonAll.stop() end)
KS.notice("Babylon was switched off by its owner.")
break
end
end
end)
end

]==]

local fn, compileErr = loadstring(SRC, "=Babylon")
if not fn then
	report("compile error: " .. tostring(compileErr))
	return
end
local ok, runErr = pcall(fn)
if not ok then
	report("runtime error: " .. tostring(runErr))
end
