-- bbot v1 source ui library
local CanPenatrate

local Vector3new = Vector3.new()
local Vector2new = Vector2.new()
local sphereHitbox = Instance.new("Part", workspace)
local diameter
do
    diameter = 11
	sphereHitbox.Size = Vector3.new(diameter, diameter, diameter)
	sphereHitbox.Position = Vector3new
	sphereHitbox.Shape = Enum.PartType.Ball
	sphereHitbox.Transparency = 1
	sphereHitbox.Anchored = true
	sphereHitbox.CanCollide = false
end

local function CreateThread(func)
    local thread = coroutine.create(func)
    coroutine.resume(thread)
    return thread
end

local Input = game:GetService("UserInputService")
local Players = game:GetService("Players")
local MainPlayer = game.Players.LocalPlayer

setfpscap(1000)

local waiting = Drawing.new("Text")
waiting.Visible = true
waiting.Transparency = 1
waiting.Color = Color3.fromRGB(150, 60, 190)
waiting.Size = 50
waiting.Text = "loading..."
waiting.Center = true
waiting.Outline = true
waiting.OutlineColor = Color3.fromRGB(90, 20, 130)
waiting.Font = 3
waiting.Position = Vector2.new(200,100)

wait(12-time())
wait(3)
waiting:Remove()

if not isfile("bbconfigs") then --folders for the configs
    makefolder("bbconfigs")
end

for i = 1, 6 do -- you can put any number it does the job
	if not isfile("bbconfigs/config"..tostring(i)..".bb") then 
		writefile("bbconfigs/config"..tostring(i)..".bb", "")
	end
end

local frameCount = 0
local gamenet
local gamesound
local gamelogic
local gamechar
local gamecam
local gamehud
local gamereplication
local gamebulletcheck
local gametraj
local gamedeploy
local gameparticle
local gameround

local gameNetwork = game:GetService("NetworkClient")
local gameSettings = UserSettings():GetService("UserGameSettings")
-- shit driving me nuts, fuck you nathan 😡😡

for k, v in pairs(getgc(true)) do
	if type(v) == "function" then
		if getinfo(v).name == "bulletcheck" then
			gamebulletcheck = v
		elseif getinfo(v).name == "trajectory" then
			gametraj = v
		end
		for k1, v1 in pairs(debug.getupvalues(v)) do
			if type(v1) == "table" then
				if rawget(v1, "send") then
					gamenet = v1
				elseif rawget(v1, "gammo") then
					gamelogic = v1
				elseif rawget(v1, "setbasewalkspeed") then
					gamechar = v1
				elseif rawget(v1, "basecframe") then
					gamecam = v1
				elseif rawget(v1, "votestep") then
					gamehud = v1
				elseif rawget(v1, "getbodyparts") then
					gamereplication = v1
				elseif rawget(v1, "play") then
					gamesound = v1
				elseif rawget(v1, "checkkillzone") then
					gameround = v1
				end
			end
		end
	end
	if type(v) == "table" then
		if rawget(v, "deploy") then
			gamedeploy = v
		elseif rawget(v, "new") and rawget(v, "step") then
			gameparticle = v
		end
	end
end

local ignoreList = {}
function updateMap()
	ignoreList = {workspace.Camera, workspace.Ignore, workspace.Players}
	for k, v in pairs(gameround.raycastwhitelist) do
		ignoreList[k+1] = v
	end
end

local function table_contains(table, element) --copied from stack overflow, needed this beat to checks stuffs
	for _, value in pairs(table) do --copy == paster, just sayin 
		if value == element then
			return true
		end
	end
	return false
end

local camshake = gamecam.shake
local suppress = gamecam.suppress
local breakwindow
local send = gamenet.send 
local Cam = workspace.CurrentCamera
local chatGame = MainPlayer.PlayerGui.ChatGame
local chatBox = chatGame:FindFirstChild("TextBox")

local rageTarget, rageHitbox, rageAngles
local ragebotShootin = false
local triggerbotShootin = false
local sexTarget
local highlightedGuys = {}
local originPart = Instance.new("Part")

local flyToggle = false
drawcount = 0
local function draw_filled_rect(visible, pos_x, pos_y, width, height, r, g, b, a, tablename)
	drawcount = drawcount + 1
	varname = tostring(drawcount)
	tablename[varname] = Drawing.new("Square")
	tablename[varname].Visible = visible
	tablename[varname].Position = Vector2.new(pos_x, pos_y)
	tablename[varname].Size = Vector2.new(width, height)
	tablename[varname].Color = Color3.fromRGB(r, g, b)
	tablename[varname].Filled = true
	tablename[varname].Thickness = 0
	tablename[varname].Transparency = a / 255
end

local function draw_outlined_rect(visible, pos_x, pos_y, width, height, r, g, b, a, tablename)
	drawcount = drawcount + 1
	varname = tostring(drawcount)
	tablename[varname] = Drawing.new("Square")
	tablename[varname].Visible = visible
	tablename[varname].Position = Vector2.new(pos_x, pos_y)
	tablename[varname].Size = Vector2.new(width, height)
	tablename[varname].Color = Color3.fromRGB(r, g, b)
	tablename[varname].Filled = false
	tablename[varname].Thickness = 0
	tablename[varname].Transparency = a / 255
end

local function draw_text(text, font, visible, pos_x, pos_y, size, centered, r, g, b, a, tablename)
	drawcount = drawcount + 1
	varname = tostring(drawcount)
	tablename[varname] = Drawing.new("Text")
	tablename[varname].Text = text
	tablename[varname].Visible = visible
	tablename[varname].Position = Vector2.new(pos_x, pos_y)
	tablename[varname].Size = size
	tablename[varname].Center = centered
	tablename[varname].Color = Color3.fromRGB(r, g, b)
	tablename[varname].Transparency = a / 255
	tablename[varname].Outline = false
	tablename[varname].Font = font
end

local function draw_outlined_text(text, font, visible, pos_x, pos_y, size, centered, r, g, b, a, r2, g2, b2, tablename)
	drawcount = drawcount + 1
	varname = tostring(drawcount)
	tablename[varname] = Drawing.new("Text")
	tablename[varname].Text = text
	tablename[varname].Visible = visible
	tablename[varname].Position = Vector2.new(pos_x, pos_y)
	tablename[varname].Size = size
	tablename[varname].Center = centered
	tablename[varname].Color = Color3.fromRGB(r, g, b)
	tablename[varname].Transparency = a / 255
	tablename[varname].Outline = true
	tablename[varname].Font = font
	tablename[varname].OutlineColor = Color3.fromRGB(r2, g2, b2)
end

local function draw_line(visible, thickness, start_x, start_y, end_x, end_y, r, g, b, a, tablename)
	drawcount = drawcount + 1
	varname = tostring(drawcount)
	tablename[varname] = Drawing.new("Line")
	tablename[varname].Visible = visible
	tablename[varname].Thickness = thickness
	tablename[varname].From = Vector2.new(start_x, start_y)
	tablename[varname].To = Vector2.new(end_x, end_y)
	tablename[varname].Color = Color3.fromRGB(r, g, b)
	tablename[varname].Transparency = a / 255
end

local function draw_circle(visible, pos_x, pos_y, size, r, g, b, a, tablename)
	drawcount = drawcount + 1
	varname = tostring(drawcount)
	tablename[varname] = Drawing.new("Circle")
	tablename[varname].Position = Vector2.new(pos_x, pos_y)
	tablename[varname].Visible = visible
	tablename[varname].Radius = size
	tablename[varname].Thickness = 1
	tablename[varname].NumSides = 20
	tablename[varname].Color = Color3.fromRGB(r, g, b)
	tablename[varname].Transparency = a / 255
end

local function draw_tri(visible, pa_x, pa_y, pb_x, pb_y, pc_x, pc_y, r, g, b, a, tablename)
	drawcount = drawcount + 1
	varname = tostring(drawcount)
	tablename[varname] = Drawing.new("Triangle")
	tablename[varname].Visible = visible
	tablename[varname].Transparency = a/255
	tablename[varname].Color = Color3.fromRGB(r, g, b)
	tablename[varname].Thickness = 3.8
	tablename[varname].PointA = Vector2.new(pa_x, pa_y)
	tablename[varname].PointB = Vector2.new(pb_x, pb_y)
	tablename[varname].PointC = Vector2.new(pc_x, pc_y)
	tablename[varname].Filled = false
end

local function draw_filled_tri(visible, pa_x, pa_y, pb_x, pb_y, pc_x, pc_y, r, g, b, a, tablename)
	drawcount = drawcount + 1
	varname = tostring(drawcount)
	tablename[varname] = Drawing.new("Triangle")
	tablename[varname].Visible = visible
	tablename[varname].Transparency = a/255
	tablename[varname].Color = Color3.fromRGB(r, g, b)
	tablename[varname].Thickness = 2
	tablename[varname].PointA = Vector2.new(pa_x, pa_y)
	tablename[varname].PointB = Vector2.new(pb_x, pb_y)
	tablename[varname].PointC = Vector2.new(pc_x, pc_y)
	tablename[varname].Filled = true
end

local vec3Gravity = Vector3.new(0, -196.2, 0)

drawcount = 0
for i = 1, 60 do 
	draw_outlined_text("nil", 2, false, 30, 30, 13, true, 255, 255, 255, 255, 0, 0, 0, dropped_wep)
end

drawcount = 0
for i = 1, 60 do 
	draw_outlined_text("nil", 2, false, 30, 30, 13, true, 255, 255, 255, 255, 0, 0, 0, dropped_wep_ammo)
end

for k, v in pairs(enemy_skeleton) do
	drawcount = 0
	for i = 1, 32 do
		draw_line(false, 1, 30, 30, 50, 50, 255, 255, 255, 255, v)
	end
end

for k, v in pairs(enemy_health) do
	drawcount = 0
	for i = 1, 32 do
		if v == enemy_health_outer then
			draw_outlined_rect(false, 30, 30, 30, 30, 0, 0, 0, 220, v)
		elseif v == enemy_health_text then
			draw_outlined_text("nil", 3, false, 30, 30, 13, true, 255, 255, 255, 255, 0, 0, 0, v)
		else
			draw_filled_rect(false, 30, 30, 30, 30, 40, 40, 40, 220, v)
		end 
	end
end

for k, v in pairs(alltext) do
	drawcount = 0
	for i = 1, 32 do
		draw_outlined_text("nil", 2, false, 30, 30, 13, true, 255, 255, 255, 255, 0, 0, 0, v)
	end
end

for k, v in pairs(allboxes) do
	drawcount = 0
	for i = 1, 32 do
		draw_outlined_rect(false, 30, 30, 30, 30, 255, 255, 255, 255, v)
	end
end

for k, v in pairs(outline_boxes) do
	for k1, v1 in pairs(v) do
		v1.Transparency = 220 / 255
		v1.Color = Color3.fromRGB(0, 0, 0)
	end
end

local mouse = MainPlayer:GetMouse()
local screen_w = mouse.ViewSizeX
local screen_h = mouse.ViewSizeY + 72
drawcount = 0 
local fovthingy = {} 
local magnetfov = {}
draw_circle(false, screen_w/2, screen_h/2, 100, 255, 255, 255, 255, fovthingy)
draw_circle(false, screen_w/2, screen_h/2, 100, 255, 255, 255, 255, magnetfov)