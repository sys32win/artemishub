local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local RunService = game:GetService("RunService")

local Window = Fluent:CreateWindow({
    Title = "Artemis Hub | Steal a Brainrot",
    SubTitle = "@sys32win - dsc.gg/artemishub",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 400),
    Acrylic = false,
    Theme = "Light",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Game = Window:AddTab({ Title = "Game", Icon = "gamepad-2" }),
	Player = Window:AddTab({ Title = "Player", Icon = "person-standing" }),
	Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    -- Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

function player()
	return game.Players.LocalPlayer.Character
end

function hrp()
	return player().HumanoidRootPart
end

function hum()
	return player().Humanoid
end

function getBase()
	local base
	for _,v in pairs(workspace.Plots:GetChildren()) do
		if string.find(v:WaitForChild("PlotSign").SurfaceGui.Frame.TextLabel.Text, game.Players.LocalPlayer.DisplayName) then
			base = v
		end
	end
	return base
end

function getClosestBase()
	local dists = {}
	for _,v in pairs(workspace.Plots:GetChildren()) do
		local root = v:FindFirstChild("AnimalTarget")
		if root then
			local dist = (hrp().Position - root.Position).Magnitude
			dists[tostring(v)] = dist
		end
	end

	local min = math.huge
	local closest = nil
	for _,v in pairs(dists) do
		if v < min then
			min = v
			closest = _
		end
	end
	return closest
end

Tabs.Game:AddButton({
	Title = "Dash Fly To Base",
	Description = "Used for stealing inside bases",
	Callback = function()
		local plr = player()
		local hrp = hrp()
		local hum = hum()
		
		_G.fly = false
		
		local lookVec
		local andar
		andar = 1
		if hrp.Position.Y >= 11 then
			andar = 2
		end
		
		local dashStep = 3
		local dashDelay = 0.075
		local hoverHeight = 3

		local closestBase = workspace.Plots[getClosestBase()]
		local base = getBase()
		local closest
		local closestAnimalTarget
		if andar == 1 then
			_G.fly = true
			closest = closestBase.LaserHitbox.Main
			closestAnimalTarget = closestBase.AnimalTarget
			lookVec = closestBase.AnimalTarget.CFrame.LookVector
			hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(closest.Position.X, hrp.Position.Y, closest.Position.Z))
		elseif andar == 2 then
			local rightvec
			local slopeOri = closestBase.Slope.Rotation
			if tostring(slopeOri) == "90, 0, -90" then
				rightvec = Vector3.new(hrp.CFrame.RightVector.X, 0, hrp.CFrame.RightVector.Z)
			else
				rightvec = -Vector3.new(hrp.CFrame.RightVector.X, 0, hrp.CFrame.RightVector.Z)
			end
			closest = closestBase.LaserHitbox.SecondFloor
			closestAnimalTarget = closestBase.AnimalTarget
			lookVec = closestBase.AnimalTarget.CFrame.LookVector
			hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(closest.Position.X, hrp.Position.Y, closest.Position.Z))
			wait()
			while (hrp.Position - closest.Position).Magnitude > 7 do
				hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * dashStep + Vector3.new(0, 2, 0)
				wait(dashDelay)
			end
			wait()
			hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(closest.Position.X, hrp.Position.Y, closest.Position.Z))
			wait()
			if tostring(slopeOri) == "90, 0, -90" then
				hrp.CFrame = CFrame.Angles(0, math.rad(0), 0) + hrp.Position
			else
				hrp.CFrame = CFrame.Angles(0, math.rad(180), 0) + hrp.Position
			end
			wait()
			local oldPos = hrp.Position
			wait()
			while (hrp.Position - oldPos).Magnitude < 10 do
				hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * dashStep + Vector3.new(0, 2, 0)
				wait(dashDelay)
			end
			wait()
			if tostring(slopeOri) == "90, 0, -90" then
				rightvec = Vector3.new(hrp.CFrame.RightVector.X, 0, hrp.CFrame.RightVector.Z)
			else
				rightvec = -Vector3.new(hrp.CFrame.RightVector.X, 0, hrp.CFrame.RightVector.Z)
			end
			hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + rightvec)
			wait()
			_G.fly = true
			closest = closestBase.LaserHitbox.Main
		end

		while _G.fly do
			while (hrp.Position - closest.Position).Magnitude < 70 do
				local newPos = hrp.Position + lookVec * -dashStep
				local pos = Vector3.new(newPos.X, newPos.Y + hoverHeight, newPos.Z)
				local lookAt = pos + Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z)
				hrp.CFrame = CFrame.new(pos, lookAt)
				wait(dashDelay)
			end
			wait()
			local dir = (base.AnimalTarget.Position - hrp.Position).Unit
			local dot = hrp.CFrame.LookVector:Dot(dir)
			if dot > 0 then -- front
				for i = 1, 17 do
					local newPos = hrp.Position + base.AnimalTarget.CFrame.LookVector * dashStep
					local pos = Vector3.new(newPos.X, newPos.Y + hoverHeight, newPos.Z)
					local lookAt = pos + Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z)
					hrp.CFrame = CFrame.new(pos, lookAt)
					wait(dashDelay)
				end
			else -- behind
				hrp.CFrame = CFrame.new(hrp.Position, hrp.Position - hrp.CFrame.LookVector)
				wait()
				for i = 1, 18 do
					local newPos = hrp.Position + base.AnimalTarget.CFrame.LookVector * dashStep
					local pos = Vector3.new(newPos.X, newPos.Y + hoverHeight, newPos.Z)
					local lookAt = pos + Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z)
					hrp.CFrame = CFrame.new(pos, lookAt)
					wait(dashDelay)
				end
			end
			local dir = base.AnimalTarget.Position - hrp.Position
			local dist = Vector3.new(dir.X, dir.Y, dir.Z).Magnitude

			while dist > 10 do
				dir = base.AnimalTarget.Position - hrp.Position
				dist = Vector3.new(dir.X, dir.Y, dir.Z).Magnitude
				local moveDir = Vector3.new(dir.X, dir.Y, dir.Z).Unit
				local stepOffset = moveDir * dashStep
				local currentPos = hrp.Position
				hrp.CFrame = CFrame.new(Vector3.new(currentPos.X, currentPos.Y + hoverHeight, currentPos.Z) + stepOffset)
				wait(dashDelay)
			end
			wait()
			_G.fly = false
		end
	end
})

Tabs.Game:AddButton({
	Title = "Server Hop",
	Description = "Find a new server",
	Callback = function()
		local TeleportService = game:GetService("TeleportService")
		local HttpService = game:GetService("HttpService")
		local Players = game:GetService("Players")

		local player = Players.LocalPlayer
		local PlaceId = game.PlaceId
		local JobId = game.JobId

		print("Started server hop")

		queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/sys32win/artemishub/refs/heads/main/stealabrainrot.lua'))")

		local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"):format(PlaceId)
		local response = game:HttpGet(url)
		local data = HttpService:JSONDecode(response)

		local serversToTry = {}
		for _, server in pairs(data.data) do
			if server.id ~= JobId then
				table.insert(serversToTry, server.id)
			end
		end

		local currentIndex = 1

		local function tryTeleport(index)
			if index > #serversToTry then
				print("No more servers to try.")
				return
			end

			print("Trying server:", serversToTry[index])
			TeleportService:TeleportToPlaceInstance(PlaceId, serversToTry[index], player)
		end

		TeleportService.TeleportInitFailed:Connect(function(result)
			print("Teleport failed with result:", tostring(result))
			print("Trying next server...")
			currentIndex = currentIndex + 1
			wait(1)
			tryTeleport(currentIndex)
		end)

		tryTeleport(currentIndex)
	end
})

Tabs.Player:AddToggle("JumpBoost", {Title = "Jump Boost", Default = false }):OnChanged(function()
	if Options.JumpBoost.Value then
		hum().UseJumpPower = true
		hum().JumpPower = 100
	else
		hum().UseJumpPower = false
		hum().JumpPower = 50
	end
end)

local baseEsp = true
Tabs.Visual:AddToggle("BaseESP", {Title = "Base ESP", Default = false }):OnChanged(function()
	baseEsp = Options.BaseESP.Value

	if baseEsp then
		task.spawn(function()
			while baseEsp do
				for _,v in pairs(workspace.Plots:GetChildren()) do
					local main
					for _,lock in pairs(v.Purchases:GetChildren()) do
						if math.round(lock.Main.Position.Y, 2) == -8 then
							main = lock
							break
						end
					end

					if main then
						local gui = main.Main:FindFirstChild("BaseESP")
						local timer = main.Main.BillboardGui.RemainingTime.Text
						local timerText = timer
						local timerColor = Color3.fromRGB(255, 0, 0)

						if timer == "0s" then
							timerText = "Unlocked"
							timerColor = Color3.fromRGB(0, 255, 0)
						end

						if not gui then
							local billboard = Instance.new("BillboardGui")
							billboard.Name = "BaseESP"
							billboard.Parent = main.Main
							billboard.Adornee = main.Main
							billboard.AlwaysOnTop = true
							billboard.Size = UDim2.new(0, 100, 0, 50)
							billboard.StudsOffset = Vector3.new(0, 3, 0)

							local label = Instance.new("TextLabel")
							label.Name = "Text"
							label.Parent = billboard
							label.Size = UDim2.new(1, 0, 1, 0)
							label.BackgroundTransparency = 1
							label.TextScaled = true
							label.Font = Enum.Font.SourceSansBold
							label.TextStrokeTransparency = 0.5
						end

						local label = main.Main.BaseESP:FindFirstChild("Text")
						if label then
							label.Text = timerText
							label.TextColor3 = timerColor
						end
					end
				end
				task.wait(0.5)
			end
		end)
	else
		for _,v in pairs(workspace.Plots:GetChildren()) do
			for _,lock in pairs(v.Purchases:GetChildren()) do
				if lock.Main:FindFirstChild("BaseESP") then
					lock.Main.BaseESP:Destroy()
				end
			end
		end
	end
end)

local brainrotEsp = true
Tabs.Visual:AddToggle("BrainrotESP", {Title = "Brainrot ESP", Default = false }):OnChanged(function()
	brainrotEsp = Options.BrainrotESP.Value
	if brainrotEsp then
		task.spawn(function() 
			while brainrotEsp do
				for _,v in pairs(workspace.Plots:GetChildren()) do
					for _,podium in pairs(v:FindFirstChild("AnimalPodiums"):GetChildren()) do
						local brainrot = podium:WaitForChild("Base"):WaitForChild("Spawn"):FindFirstChild("Attachment")
						if brainrot then
							local name = brainrot:WaitForChild("AnimalOverhead").DisplayName.Text
							local generation = brainrot:WaitForChild("AnimalOverhead").Generation.Text
							local rarity = brainrot:WaitForChild("AnimalOverhead").Rarity.Text
							local stolen = brainrot:WaitForChild("AnimalOverhead").Stolen.Text
							if (rarity == "Brainrot God" or rarity == "Secret") and not podium.Base.Spawn:FindFirstChild("BrainrotESP") and stolen ~= "IN MACHINE" then
								local billboard = Instance.new("BillboardGui")
								billboard.Name = "BrainrotESP"
								billboard.Parent = podium:WaitForChild("Base"):WaitForChild("Spawn")
								billboard.Adornee = podium:WaitForChild("Base"):WaitForChild("Spawn")
								billboard.AlwaysOnTop = true
								billboard.StudsOffset = Vector3.new(0, 5, 0)
								billboard.Size = UDim2.new(0, 100, 0, 50)
								local label = Instance.new("TextLabel")
								label.Parent = billboard
								if rarity == "Brainrot God" then label.TextColor3 = Color3.fromRGB(237, 215, 19) end
								if rarity == "Secret" then label.TextColor3 = Color3.fromRGB(64, 64, 64) end
								label.Text = name .. "\n" .. generation
								-- if stolen == "IN MACHINE" then label.Text = name .. "\n" .. generation .. "\n" .. "[MACHINE]" end
								label.Size = UDim2.new(1, 0, 1, 0)
								label.BackgroundTransparency = 1
								label.TextStrokeTransparency = 0.5
								label.TextScaled = true
								label.Font = Enum.Font.SourceSansBold
							end
						end
						local oldBaseEsp = podium:WaitForChild("Base"):WaitForChild("Spawn"):FindFirstChild("BaseESP")
						if (oldBaseEsp and not brainrot) or (oldBaseEsp and brainrot and stolen == "IN MACHINE") then
							oldBaseEsp:Destroy()
						end
					end
				end
				task.wait(1)
			end
		end)
	else
		for _,v in pairs(workspace.Plots:GetChildren()) do
			for _,podium in pairs(v:FindFirstChild("AnimalPodiums"):GetChildren()) do
				if podium.Base.Spawn:FindFirstChild("BrainrotESP") then
					podium.Base.Spawn.BrainrotESP:Destroy()
				end
			end
		end
	end
end)

Window:SelectTab(1)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
-- InterfaceManager:BuildInterfaceSection(Tabs.Settings)
-- SaveManager:BuildConfigSection(Tabs.Settings)

Fluent:Notify({
    Title = "Artemis Hub",
    Content = "Script has been loaded",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
