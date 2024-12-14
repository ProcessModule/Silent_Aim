--[[
   Script Description
   This script only works for level 7 executors 
   this only is silent aim
--]]

getgenv().Private = {
    Load = { 
        ['Intro'] = true, 
        ['IntroID'] = "rbxassetid://18512288865",
        ['Delay'] = 0.5
    },

    Bullet_Redirection = { -- // Only Works With Wave , Electron [ Uses HIT ]
        ['Enabled'] = true, 
        ['HitChance'] = 100,
        ['ClosestPart'] = true,
        ['Prediction'] = {
            ['Automatic'] = true,
            ['Prediction'] = { 0.11120, 0.11120, 0.11120 } -- // Pred X , Pred Y , Pred Z
        },
        ['Drawings'] = {
            ['Field Of View'] = {
                ['Visible'] = false,
                ['Radius'] = 125,
                ['Filled'] = false,
                ['Thickness'] = 1,
                ['Transparency'] = 0.25,
                ['Color'] = Color3.fromRGB(0, 0, 0)
            },
            ['Tracer'] = {
                ['Visible'] = false,
                ['Thickness'] = 1,
                ['Transparency'] = 1,
                ['Color'] = Color3.fromRGB(255, 255, 255)
            },
        },
        ['Conditions'] = {
            ['Wall'] = true,
            ['Knocked'] = true,
            ['Grabbed'] = true,
            ['Tool Equipped'] = false,
        }
    },
}


wait(Private.Load.Delay)

if Private.Load.Intro then
    local cam = workspace.CurrentCamera
    local x = cam.ViewportSize.X
    local y = cam.ViewportSize.Y
    local newx = math.floor(x * 0.5)
    local newy = math.floor(y * 0.5)

    local SpashScreen = Instance.new("ScreenGui")
    local Image = Instance.new("ImageLabel")
    SpashScreen.Name = "SpashScreen"
    SpashScreen.Parent = game.CoreGui
    SpashScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Image.Name = "Image"
    Image.Parent = SpashScreen
    Image.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Image.BackgroundTransparency = 1
    Image.Position = UDim2.new(0, newx, 0, newy)
    Image.Size = UDim2.new(0, 825, 0, 377)
    Image.Image = Private.Load.IntroID
    Image.ImageTransparency = 1
    Image.AnchorPoint = Vector2.new(0.5, 0.5)

    local Blur = Instance.new("BlurEffect")
    Blur.Parent = game.Lighting
    Blur.Size = 0
    Blur.Name = tostring(math.random(1, 123123))

    local function gui(last, sex, t, s, inorout)
        local TI = TweenInfo.new(t or 1, s or Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local Tweening = game:GetService("TweenService"):Create(last, TI, sex)
        Tweening:Play()
    end

    gui(Image, {ImageTransparency = 0}, 0.3)
    gui(Blur, {Size = 20}, 0.3)
    wait(3)
    gui(Image, {ImageTransparency = 1}, 0.3)
    gui(Blur, {Size = 0}, 0.3)
    wait(0.3)
end

local Private = getgenv().Private

local Framework = {
    SilentTarget = nil,
    CamTarget = nil,

    SilentAimPart = "Head",

    Functions = {}
}

for _, con in next, getconnections(workspace.CurrentCamera.Changed) do
    task.wait()
    con:Disable()
end
for _, con in next, getconnections(workspace.CurrentCamera:GetPropertyChangedSignal("CFrame")) do
     task.wait()
    con:Disable()
end

--// Services \\--
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local GuiS             = game:GetService("GuiService")

--// Variables \\--
local Client        = Players.LocalPlayer
local Mouse         = Client:GetMouse()
local Camera        = workspace.CurrentCamera
local Inset         = GuiS:GetGuiInset().Y

--// Visuals \\--
SilentCircle              = Drawing.new("Circle")
SilentCircle.Visible      = Private.Bullet_Redirection.Drawings["Field Of View"].Visible
SilentCircle.Filled       = Private.Bullet_Redirection.Drawings["Field Of View"].Filled
SilentCircle.Radius       = Private.Bullet_Redirection.Drawings["Field Of View"].Radius
SilentCircle.Transparency = Private.Bullet_Redirection.Drawings["Field Of View"].Transparency
SilentCircle.Thickness    = Private.Bullet_Redirection.Drawings["Field Of View"].Thickness
SilentCircle.Color        = Private.Bullet_Redirection.Drawings["Field Of View"].Color
Tracer                    = Drawing.new("Line")
Tracer.Color              = Private.Bullet_Redirection.Drawings.Tracer.Color
Tracer.Transparency       = Private.Bullet_Redirection.Drawings.Tracer.Transparency
Tracer.Thickness          = Private.Bullet_Redirection.Drawings.Tracer.Thickness
Tracer.Visible            = Private.Bullet_Redirection.Drawings.Tracer.Visible

Framework.Functions.WTS = function(Object)
    local ObjectVector = Camera:WorldToScreenPoint(Object.Position)
    return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

Framework.Functions.IsOnScreen = function(Object)
    local IsOnScreen = Camera:WorldToScreenPoint(Object.Position)
    return IsOnScreen
end

Framework.Functions.FilterObjs = function(Object)
    if string.find(Object.Name, "Gun") then
        return
    end
    if table.find({"Part", "MeshPart", "BasePart"}, Object.ClassName) then
        return true
    end
end

Framework.Functions.RayCastCheck = function(Part, PartDescendant)
    if Private.Bullet_Redirection.Conditions.Wall then
        local Character = Client.Character or Client.CharacterAdded.Wait(Client.CharacterAdded)
        local Origin = Camera.CFrame.Position
    
        local RayCastParams = RaycastParams.new()
        RayCastParams.FilterType = Enum.RaycastFilterType.Blacklist
        RayCastParams.FilterDescendantsInstances = {Character, Camera}
    
        local Result = workspace.Raycast(workspace, Origin, Part.Position - Origin, RayCastParams)
        
        if (Result) then
            local PartHit = Result.Instance
            local Visible = (not PartHit or Instance.new("Part").IsDescendantOf(PartHit, PartDescendant))
            
            return Visible
        end
        return false
    else
        return true
    end
end

Framework.Functions.CalcHitchance = function(percentage)
    percentage = math.floor(percentage)
  
    local chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100
  
    return chance <= percentage / 100
end

Framework.Functions.GetClosestToMouse = function()
    local Target, Closest = nil, 1 / 0
    local HitChance = Framework.Functions.CalcHitchance(Private.Bullet_Redirection.HitChance)
    if not HitChance then Target = nil return Target end

    for _, v in pairs(Players:GetPlayers()) do
        if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
            local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if (SilentCircle.Radius > Distance and Distance < Closest and OnScreen and Framework.Functions.RayCastCheck(v.Character.HumanoidRootPart, v.Character)) then
                    Closest = Distance
                    Target = v
                end
        end
    end
    return Target
end

Framework.Functions.GetClosestBodyPart = function(character)
	local ClosestDistance = 1/0
	local BodyPart = nil
	if (character and character:GetChildren()) then
		for _,  x in next, character:GetChildren() do
			if Framework.Functions.FilterObjs(x) and Framework.Functions.IsOnScreen(x) then
				local Distance = (Framework.Functions.WTS(x) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
				if (Distance and Distance < ClosestDistance) then
					ClosestDistance = Distance
					BodyPart = x
				end
			end
		end
	end
	return BodyPart
end

Framework.Functions.UpdateVisuals = function()
    SilentCircle.Position = Vector2.new(Mouse.X, Mouse.Y + GuiS:GetGuiInset().Y)

    if Framework.SilentTarget and Framework.SilentTarget.Character and Private.Bullet_Redirection.Drawings.Tracer.Visible then
        local ViewportPoint = Camera:WorldToViewportPoint(Framework.SilentTarget.Character[Framework.SilentAimPart].Position + (Framework.SilentTarget.Character[Framework.SilentAimPart].Velocity * 0.1424))

        Tracer.From = Vector2.new(Mouse.X, Mouse.Y + GuiS:GetGuiInset().Y)
        Tracer.To = Vector2.new(ViewportPoint.X, ViewportPoint.Y)
        Tracer.Visible = true
    else
        Tracer.Visible = false
    end
end

Framework.Functions.Knocked = function(Plr)
    if Plr and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") and Plr.Character:FindFirstChild("Humanoid") and Plr.Character:FindFirstChild("Head") and Plr.Character.BodyEffects["K.O"].Value == true then
        return true
    end
    return false
end

Framework.Functions.Grabbed = function(Plr)
    if Plr and Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and Plr.Character:FindFirstChild("Humanoid") ~= nil and Plr.Character:FindFirstChild("Head") ~= nil and Plr.Character:FindFirstChild("GRABBING_CONSTRAINT") then
        return true
    end
    return false
end

local smoothingFactor, positionData, currentIndex = 30, {}, 1
calculateVelocityAverage = function(positionData)
    local totalVelocity = 0
    local avgPosition = Vector3.zero
    local avgTime = 0
    local len = #positionData
    if len == 0 then
        return avgPosition, avgTime
    end
    for i = 1, len do
        local data = positionData[i]
        if data and data.pos then
            local velocity = smoothingFactor - i + 1
            avgPosition += data.pos * velocity
            avgTime += data.time * velocity
            totalVelocity += velocity
        end
    end
    avgPosition = avgPosition / totalVelocity
    avgTime = avgTime / totalVelocity
    return avgPosition, avgTime
end

SmoothVelocity = function(character)
    local currentPos = character.HumanoidRootPart.Position
    local currentTick = tick()
    positionData[currentIndex] = {
        pos = currentPos,
        time = currentTick,
    }
    currentIndex = (currentIndex % smoothingFactor) + 1
    local avgPosition, avgTime = calculateVelocityAverage(positionData)
    local prevData = positionData[currentIndex]
    if prevData and prevData.pos then
        local Velocity = (currentPos - prevData.pos) / (currentTick - prevData.time)
        return Velocity
    end
end



RunService.RenderStepped:Connect(function()
    Framework.Functions.UpdateVisuals()

    Framework.SilentTarget = Framework.Functions.GetClosestToMouse()

    if Private.Bullet_Redirection.ClosestPart and Framework.SilentTarget and Framework.SilentTarget.Character then
        Framework.SilentAimPart = tostring(Framework.Functions.GetClosestBodyPart(Framework.SilentTarget.Character))
    end

    --// Checks
    if Private.Bullet_Redirection.Conditions.Knocked then
        if Framework.Functions.Knocked(Framework.SilentTarget) then
            Framework.SilentTarget = nil
        end
    end

    if Private.Bullet_Redirection.Conditions.Grabbed then
        if Framework.Functions.Grabbed(Framework.SilentTarget) then
            Framework.SilentTarget = nil
        end
    end

    if Private.Bullet_Redirection.Conditions["Tool Equipped"] then
        if not Client.Character:FindFirstChildWhichIsA("Tool") then
            Framework.SilentTarget = nil
        end
    end

    if Private.Bullet_Redirection.Prediction.Automatic then
        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        local pingValue = string.split(ping, " ")[1]
        local pingNumber = tonumber(pingValue)
    
        Private.Bullet_Redirection.Prediction.Prediction[1] = tonumber(pingNumber / 225 * 0.1 + 0.1)
        Private.Bullet_Redirection.Prediction.Prediction[2] = tonumber(pingNumber / 225 * 0.1 + 0.1)
        Private.Bullet_Redirection.Prediction.Prediction[3] = tonumber(pingNumber / 225 * 0.1 + 0.1)
    end
end)


local grmt = getrawmetatable(game)
local backupindex = grmt.__index
setreadonly(grmt, false)

grmt.__index = newcclosure(function(self, v)
    if ((v == "Hit")) and Mouse and Framework.SilentTarget and Framework.SilentTarget.Character then
        local Vel = SmoothVelocity(Framework.SilentTarget.Character)
        if Vel then
            local PredX = Private.Bullet_Redirection.Prediction.Prediction[1]
            local PredY = Private.Bullet_Redirection.Prediction.Prediction[2]
            local PredZ = Private.Bullet_Redirection.Prediction.Prediction[3]
            local Hit = Framework.SilentTarget.Character[Framework.SilentAimPart].CFrame
    
            local endpoint = CFrame.new(
                Hit.X + (Vel.X * PredX),
                Hit.Y + (Vel.Y * PredY),
                Hit.Z + (Vel.Z * PredZ)
            )
            return (tostring(v) == "Hit" and endpoint)
        end
    end
    return backupindex(self, v)
end)

warn("Loaded")
