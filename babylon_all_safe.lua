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
badge.BackgroundColor3 = Color3.fromRGB(14, 40, 24)
badge.BackgroundTransparency = 0.15
badge.TextColor3 = Color3.fromRGB(150, 255, 190)
badge.Font = Enum.Font.GothamMedium
badge.TextSize = 14
badge.Text = "Babylon injected   G wall   P shop   U sell   K bring"
badge.Parent = ui
Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)
local toastLabel = Instance.new("TextLabel")
toastLabel.Name = "Toast"
toastLabel.AnchorPoint = Vector2.new(0.5, 0)
toastLabel.Position = UDim2.new(0.5, 0, 0, 70)
toastLabel.Size = UDim2.new(0, 440, 0, 44)
toastLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
toastLabel.BackgroundTransparency = 0.2
toastLabel.TextColor3 = Color3.new(1, 1, 1)
toastLabel.Font = Enum.Font.GothamMedium
toastLabel.TextSize = 17
toastLabel.TextWrapped = true
toastLabel.Visible = false
toastLabel.Parent = ui
Instance.new("UICorner", toastLabel).CornerRadius = UDim.new(0, 8)
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
local loadErrors = {}
local function run(name, fn)
print("[Babylon] loading " .. name)
badge.Text = "Babylon loading: " .. name .. " ..."
local ok, err = pcall(fn)
if not ok then
table.insert(loadErrors, name .. ": " .. tostring(err))
warn("[Babylon] " .. name .. " failed to load: " .. tostring(err))
end
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
local function patchTool(tool)
if not tool:IsA("Tool") then return end
task.spawn(function()
local gl = tool:WaitForChild("GunLocal", 5)
local mod = gl and gl:WaitForChild("Recoil", 5)
if not mod or not mod:IsA("ModuleScript") then return end
local ok, m = pcall(require, mod)
if ok and type(m) == "table" and type(m.new) == "function" and not patchedRecoil[m] then
local orig = m.new
patchedRecoil[m] = orig
m.new = function(...)
local obj = orig(...)
if CFG.noRecoil then
local okCalm = pcall(calmRecoil, obj)
if not okCalm then return obj end
end
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
end)
run("Shop", function()
local CFG = {
key = Enum.KeyCode.P,
shopGui = "1",                   -- name of the weapon shop screen in ReplicatedStorage.ShopGuis
buttonName = "pawn shop button", -- the shop's button in the map (lowercase, partial match)
}
local busy = false
local function isOpen()
return lp.PlayerGui:FindFirstChild(CFG.shopGui) ~= nil
end
local function touchOpen(root)
if not firetouchinterest then return false end
local parts = {}
for _, d in ipairs(workspace:GetChildren()) do
if d.Name:lower():find(CFG.buttonName, 1, true) then
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
while not isOpen() and os.clock() - t0 < 1.5 do task.wait(0.1) end
if isOpen() then return true end
end
return false
end
local function buildOpen()
local shops = ReplicatedStorage:FindFirstChild("ShopGuis")
local template = shops and shops:FindFirstChild(CFG.shopGui)
if not template then return false end
template:Clone().Parent = lp.PlayerGui
return true
end
local function open()
if busy then return end
busy = true
local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
local g = lp.PlayerGui:FindFirstChild(CFG.shopGui)
if g then g:Destroy() end
task.wait(0.1)
if root then touchOpen(root) end
if not isOpen() then buildOpen() end
if isOpen() then
toast("Shop opened. Selling only works when you are at the pawn shop")
else
toast("Shop did not open, try again")
end
busy = false
end
local conn = UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == CFG.key then task.spawn(open) end
end)
getgenv().OpenShop = {
cfg = CFG,
run = function() task.spawn(open) end,
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
local function press()
if busy then return end
local list, total = collect()
if #list == 0 then
toast("Nothing to sell (no items the pawn shop buys)")
return
end
if CFG.confirm and os.clock() > armedUntil then
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
local conn = UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == CFG.key then task.spawn(press) end
end)
getgenv().SellAll = {
cfg = CFG,
run = function() task.spawn(press) end,
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
local conn = UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == CFG.key then task.spawn(run) end
end)
getgenv().BringGuns = {
cfg = CFG,
run = function() task.spawn(run) end,
stop = function()
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
pcall(function()
CAS:BindActionAtPriority("BabylonPreFire", preFire, false, 3000, Enum.UserInputType.MouseButton1)
end)
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
local inputConn = UIS.InputBegan:Connect(function(input, processed)
if processed then return end
if input.KeyCode == CFG.key then setOn(not on) end
end)
getgenv().BabylonESP = {
cfg = CFG,
toggle = function() setOn(not on) end,
isOn = function() return on end,
stop = function()
conn:Disconnect()
inputConn:Disconnect()
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
}
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
airLabel.Visible = CFG.showAirTime
airLabel.Text = string.format("Air time: %.1fs   best %.1fs", airTime, bestAir)
if forceLand then
airLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
elseif CFG.autoLand and airTime >= CFG.landAt * 0.7 then
airLabel.TextColor3 = Color3.fromRGB(255, 200, 120)
else
airLabel.TextColor3 = Color3.new(1, 1, 1)
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
local lastSig = ""
local function layout()
local L, G, T = CFG.length, CFG.gap, CFG.thickness
local sig = table.concat({ L, G, T, tostring(CFG.dot), tostring(CFG.color) }, "|")
if sig == lastSig then return end
lastSig = sig
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
bg = Color3.fromRGB(24, 24, 30),
side = Color3.fromRGB(31, 31, 40),
item = Color3.fromRGB(40, 40, 52),
hover = Color3.fromRGB(52, 52, 66),
text = Color3.fromRGB(235, 235, 242),
sub = Color3.fromRGB(150, 150, 168),
accent = Color3.fromRGB(96, 150, 255),
on = Color3.fromRGB(60, 190, 120),
off = Color3.fromRGB(84, 84, 100),
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
Size = UDim2.new(0, 560, 0, 360),
BackgroundColor3 = THEME.bg,
BorderSizePixel = 0,
ClipsDescendants = true,
Active = true,
}, ui)
corner(win, 10)
local top = mk("Frame", { Name = "Top", Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = THEME.side, BorderSizePixel = 0 }, win)
local dot = mk("Frame", { Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 14, 0.5, -5), BackgroundColor3 = THEME.on, BorderSizePixel = 0 }, top)
corner(dot, 5)
mk("TextLabel", {
Position = UDim2.new(0, 34, 0, 0),
Size = UDim2.new(1, -90, 1, 0),
BackgroundTransparency = 1,
Text = "Babylon   |   injected (" .. execName() .. ")",
TextXAlignment = Enum.TextXAlignment.Left,
Font = Enum.Font.GothamBold,
TextSize = 15,
TextColor3 = THEME.text,
}, top)
local hideBtn = mk("TextButton", {
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -8, 0.5, 0),
Size = UDim2.new(0, 26, 0, 22),
Text = "-",
Font = Enum.Font.GothamBold,
TextSize = 16,
TextColor3 = THEME.text,
BackgroundColor3 = THEME.item,
BorderSizePixel = 0,
AutoButtonColor = false,
}, top)
corner(hideBtn, 6)
local side = mk("Frame", { Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(0, 130, 1, -38), BackgroundColor3 = THEME.side, BorderSizePixel = 0 }, win)
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, side)
mk("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, side)
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
local pages, tabButtons = {}, {}
local function selectTab(name)
for n, p in pairs(pages) do p.Visible = (n == name) end
for n, b in pairs(tabButtons) do
b.BackgroundColor3 = (n == name) and THEME.accent or THEME.side
b.TextColor3 = (n == name) and Color3.new(1, 1, 1) or THEME.sub
end
end
local tabCount = 0
local function newTab(name)
tabCount += 1
local btn = mk("TextButton", {
Size = UDim2.new(1, 0, 0, 32),
Text = name,
Font = Enum.Font.GothamMedium,
TextSize = 14,
BackgroundColor3 = THEME.side,
TextColor3 = THEME.sub,
AutoButtonColor = false,
BorderSizePixel = 0,
LayoutOrder = tabCount,
}, side)
corner(btn, 6)
local page = mk("ScrollingFrame", {
Position = UDim2.new(0, 138, 0, 46),
Size = UDim2.new(1, -146, 1, -54),
BackgroundTransparency = 1,
BorderSizePixel = 0,
ScrollBarThickness = 3,
CanvasSize = UDim2.new(0, 0, 0, 0),
AutomaticCanvasSize = Enum.AutomaticSize.Y,
Visible = false,
}, win)
mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)
mk("UIPadding", { PaddingRight = UDim.new(0, 6) }, page)
pages[name] = page
tabButtons[name] = btn
table.insert(conns, btn.MouseButton1Click:Connect(function() selectTab(name) end))
return page
end
local function row(page, h)
local r = mk("Frame", { Size = UDim2.new(1, 0, 0, h or 38), BackgroundColor3 = THEME.item, BorderSizePixel = 0 }, page)
corner(r, 8)
return r
end
local function nameLabel(r, text)
return mk("TextLabel", {
Position = UDim2.new(0, 12, 0, 0),
Size = UDim2.new(1, -90, 0, 38),
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
Position = UDim2.new(0, 12, 0, 0),
Size = UDim2.new(1, -24, 1, 0),
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
local sw = mk("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 42, 0, 22), BorderSizePixel = 0 }, r)
corner(sw, 11)
local knob = mk("Frame", { Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, sw)
corner(knob, 8)
local state = false
local function render(v)
sw.BackgroundColor3 = v and THEME.on or THEME.off
knob.Position = v and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
end
state = getter() and true or false
render(state)
local hit = mk("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 5 }, r)
table.insert(conns, hit.MouseButton1Click:Connect(function()
state = not state
setter(state)
render(state)
end))
table.insert(syncs, function()
local v = getter() and true or false
if v ~= state then state = v render(v) end
end)
end
local function fmt(v)
if v == math.floor(v) then return tostring(v) end
return string.format("%.1f", v)
end
local function addSlider(page, text, min, max, step, getter, setter)
local r = row(page, 52)
mk("TextLabel", {
Position = UDim2.new(0, 12, 0, 4),
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
Position = UDim2.new(1, -12, 0, 4),
Size = UDim2.new(0, 70, 0, 22),
BackgroundTransparency = 1,
TextXAlignment = Enum.TextXAlignment.Right,
Font = Enum.Font.GothamBold,
TextSize = 14,
TextColor3 = THEME.accent,
}, r)
local track = mk("Frame", { Position = UDim2.new(0, 12, 0, 36), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = THEME.off, BorderSizePixel = 0 }, r)
corner(track, 3)
local fill = mk("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = THEME.accent, BorderSizePixel = 0 }, track)
corner(fill, 3)
local knob = mk("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, track)
corner(knob, 7)
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
table.insert(conns, b.MouseEnter:Connect(function() r.BackgroundColor3 = THEME.hover end))
table.insert(conns, b.MouseLeave:Connect(function() r.BackgroundColor3 = THEME.item end))
table.insert(conns, b.MouseButton1Click:Connect(function() pcall(callback) end))
end
local function addKeybind(page, text, getter, setter)
local r = row(page)
nameLabel(r, text)
local b = mk("TextButton", {
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.new(0, 74, 0, 24),
BackgroundColor3 = THEME.bg,
Font = Enum.Font.GothamBold,
TextSize = 13,
TextColor3 = THEME.accent,
AutoButtonColor = false,
BorderSizePixel = 0,
}, r)
corner(b, 6)
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
if input.KeyCode == menuKey then win.Visible = not win.Visible end
end))
table.insert(conns, hideBtn.MouseButton1Click:Connect(function() win.Visible = false end))
local function api(name) return getgenv()[name] end
local gate = newTab("Gate")
addToggle(gate, "Gate of Babylon", function() local g = api("FloatGuns") return g and g.isOn and g.isOn() end, function(v) local g = api("FloatGuns") if g then g.set(v) end end)
addKeybind(gate, "Toggle key", function() local g = api("FloatGuns") return g and g.cfg.toggleKey or Enum.KeyCode.G end, function(k) local g = api("FloatGuns") if g then g.cfg.toggleKey = k end end)
addSlider(gate, "Spread (degrees)", 20, 140, 1, function() local g = api("FloatGuns") return g and g.cfg.fanAngle or 80 end, function(v) local g = api("FloatGuns") if g then g.cfg.fanAngle = v end end)
addSlider(gate, "Wall height", 2, 10, 0.5, function() local g = api("FloatGuns") return g and g.cfg.baseHeight or 4.5 end, function(v) local g = api("FloatGuns") if g then g.cfg.baseHeight = v end end)
addSlider(gate, "Held gun height", 2, 8, 0.5, function() local g = api("FloatGuns") return g and g.cfg.heldHeight or 4.4 end, function(v) local g = api("FloatGuns") if g then g.cfg.heldHeight = v end end)
addSlider(gate, "Guns per row", 2, 12, 1, function() local g = api("FloatGuns") return g and g.cfg.gunsPerRow or 6 end, function(v) local g = api("FloatGuns") if g then g.cfg.gunsPerRow = v end end)
addToggle(gate, "Reload all guns together", function() local g = api("FloatGuns") return g and g.cfg.reloadAll end, function(v) local g = api("FloatGuns") if g then g.cfg.reloadAll = v end end)
addToggle(gate, "No camera recoil (screen shake)", function() local g = api("FloatGuns") return g and g.cfg.noRecoil end, function(v) local g = api("FloatGuns") if g then g.cfg.noRecoil = v end end)
infoLabel(gate, "Applies the next time you equip a gun. If a gun ever will not fire, turn this off and re-equip it.", 46)
local items = newTab("Items")
addButton(items, "Open shop", function() local o = api("OpenShop") if o then o.run() end end)
addKeybind(items, "Shop key", function() local o = api("OpenShop") return o and o.cfg.key or Enum.KeyCode.P end, function(k) local o = api("OpenShop") if o then o.cfg.key = k end end)
addButton(items, "Sell everything", function() local s = api("SellAll") if s then s.run() end end)
addKeybind(items, "Sell key", function() local s = api("SellAll") return s and s.cfg.key or Enum.KeyCode.U end, function(k) local s = api("SellAll") if s then s.cfg.key = k end end)
addToggle(items, "Ask before selling", function() local s = api("SellAll") return s and s.cfg.confirm end, function(v) local s = api("SellAll") if s then s.cfg.confirm = v end end)
addToggle(items, "Keep my guns when selling", function() local s = api("SellAll") return s and s.cfg.keepGuns end, function(v) local s = api("SellAll") if s then s.cfg.keepGuns = v end end)
addButton(items, "Bring loose weapons", function() local b = api("BringGuns") if b then b.run() end end)
addKeybind(items, "Bring key", function() local b = api("BringGuns") return b and b.cfg.key or Enum.KeyCode.K end, function(k) local b = api("BringGuns") if b then b.cfg.key = k end end)
infoLabel(items, "Selling only works while you stand at the pawn shop.")
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
if #loadErrors > 0 then
badge.Text = "Babylon: " .. #loadErrors .. " feature(s) failed. See menu > Info"
badge.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
badge.TextColor3 = Color3.fromRGB(255, 170, 170)
toast(loadErrors[1])
else
toast("Babylon injected. RightShift opens the menu")
end
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
