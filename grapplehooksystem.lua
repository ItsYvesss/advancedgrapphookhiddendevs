local grapplerPlayer = game:GetService("Players").LocalPlayer
local grapplerMouse = grapplerPlayer:GetMouse()
local grapplerRun = game:GetService("RunService")
local grapplerUis = game:GetService("UserInputService")
local grapplerTween = game:GetService("TweenService")

local grapplerCharges = 5
local grapplerMax = 5
local grapplerActive = false
local grapplerHolding = false
local grapplerCooldown = false

local grapplerHud = grapplerPlayer.PlayerGui:WaitForChild("GrapplerHUD"):WaitForChild("Frame")
local grapplerCount = grapplerHud:WaitForChild("Counter")
local grapplerFill = grapplerHud:WaitForChild("BarBackground"):WaitForChild("Fill")

local function grapplerUpdateUI()
	grapplerCount.Text = grapplerCharges .. "/" .. grapplerMax
	local grapplerSize = grapplerCharges / grapplerMax
	grapplerTween:Create(grapplerFill, TweenInfo.new(0.3), {Size = UDim2.new(grapplerSize, 0, 1, 0)}):Play()
end

script.Parent.Equipped:Connect(function() 
	grapplerHud.Visible = true 
end)

script.Parent.Unequipped:Connect(function() 
	grapplerHud.Visible = false 
end)

local function grapplerReload()
	if grapplerCooldown then return end
	grapplerCooldown = true
	local grapplerInfo = TweenInfo.new(4, Enum.EasingStyle.Linear)
	local grapplerTweenObj = grapplerTween:Create(grapplerFill, grapplerInfo, {Size = UDim2.new(1, 0, 1, 0)})
	grapplerTweenObj:Play()
	grapplerTweenObj.Completed:Connect(function()
		grapplerCharges = grapplerMax
		grapplerUpdateUI()
		grapplerCooldown = false
	end)
end

grapplerMouse.Button1Down:Connect(function()
	if grapplerCharges <= 0 or grapplerActive or grapplerCooldown then return end
	
	local grapplerParams = RaycastParams.new()
	grapplerParams.FilterDescendantsInstances = {grapplerPlayer.Character}
	local grapplerRay = workspace:Raycast(grapplerMouse.UnitRay.Origin, grapplerMouse.UnitRay.Direction * 1500, grapplerParams)
	
	if grapplerRay then
		local grapplerTarget = grapplerRay.Instance
		local grapplerPos = grapplerRay.Position
		
		local grapplerChar = grapplerPlayer.Character
		local grapplerHrp = grapplerChar:FindFirstChild("HumanoidRootPart")
		local grapplerHum = grapplerChar:FindFirstChild("Humanoid")
		if not grapplerHrp then return end
		
		grapplerActive = true
		grapplerHolding = true
		grapplerCharges -= 1
		grapplerUpdateUI()
		if grapplerCharges == 0 then grapplerReload() end

		local grapplerA0 = Instance.new("Attachment", grapplerHrp)
		local grapplerA1 = Instance.new("Attachment", grapplerTarget)
		grapplerA1.WorldPosition = grapplerPos

		local grapplerBeam = Instance.new("Beam")
		grapplerBeam.Attachment0 = grapplerA0
		grapplerBeam.Attachment1 = grapplerA1
		grapplerBeam.Color = ColorSequence.new(Color3.fromRGB(75, 200, 130))
		grapplerBeam.Width0 = 0.05
		grapplerBeam.Width1 = 0.05
		grapplerBeam.Parent = grapplerHrp

		local grapplerSpring = Instance.new("SpringConstraint")
		grapplerSpring.Attachment0 = grapplerA0
		grapplerSpring.Attachment1 = grapplerA1
		grapplerSpring.FreeLength = (grapplerHrp.Position - grapplerPos).Magnitude * 0.3
		grapplerSpring.Stiffness = 1200
		grapplerSpring.Damping = 10
		grapplerSpring.Parent = grapplerHrp

		local function grapplerStop()
			grapplerActive = false
			grapplerHolding = false
			grapplerHrp.Velocity += Vector3.new(0, 45, 0) + (grapplerHrp.CFrame.LookVector * 25)
			if grapplerA0 then grapplerA0:Destroy() end
			if grapplerA1 then grapplerA1:Destroy() end
			if grapplerBeam then grapplerBeam:Destroy() end
			if grapplerSpring then grapplerSpring:Destroy() end
		end

		local grapplerStep
		grapplerStep = grapplerRun.RenderStepped:Connect(function()
			if not grapplerHolding or grapplerHum.Health <= 0 then
				grapplerStop()
				grapplerStep:Disconnect()
			else
				local grapplerDir = (grapplerPos - grapplerHrp.Position).Unit
				grapplerHrp.Velocity = grapplerHrp.Velocity:Lerp(grapplerHrp.Velocity + (grapplerDir * 2.5), 0.08)
				if grapplerHrp.Velocity.Magnitude > 100 then
					grapplerHrp.Velocity = grapplerHrp.Velocity.Unit * 100
				end
			end
		end)

		local grapplerInput
		grapplerInput = grapplerUis.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.X then
				grapplerHolding = false
				grapplerInput:Disconnect()
			end
		end)
		
		local grapplerEnd
		grapplerEnd = grapplerUis.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				grapplerHolding = false
				grapplerEnd:Disconnect()
			end
		end)
	end
end)
