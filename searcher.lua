local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local placeId = game.PlaceId
local currentJobId = game.JobId

print("JOINED SERVER")

-- Requeue script on teleport
queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/sys32win/artemishub/refs/heads/main/searcher.lua'))()")

-- Helper to print to chat
local function say(msg)
	pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = msg,
			Color = Color3.new(1, 0.3, 0.9),
			Font = Enum.Font.SourceSansBold,
			TextSize = 18
		})
	end)
end

-- Scan current server
local function scan()
	for _, plot in pairs(workspace.Plots:GetChildren()) do
		local plotName = plot.Name
		for _, podium in pairs(plot:WaitForChild("AnimalPodiums"):GetChildren()) do
			local brainrot = podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn"):FindFirstChild("Attachment")
			if brainrot and brainrot:FindFirstChild("AnimalOverhead") then
				local overhead = brainrot.AnimalOverhead
				local name = overhead.DisplayName.Text
				local generation = overhead.Generation.Text
				local rarity = overhead.Rarity.Text
				local inMachine = (overhead:FindFirstChild("Stolen") and overhead.Stolen.Text == "IN MACHINE")

				say(("[%s] %s | %s | %s %s"):format(
					plotName,
					name,
					rarity,
					generation,
					inMachine and "[IN MACHINE]" or ""
				))
			end
		end
	end
end

-- Get available public servers
local function getServers()
	local url = ("https://games.roblox.com/v1/games/%s/servers/Public?limit=100&excludeFullGames=true&sortOrder=Asc"):format(placeId)
	local success, response = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(url))
	end)
	return success and response.data or {}
end

-- Begin scan
scan()

-- Get server list
local servers = getServers()
local index = 1

-- Try next server
local function hop()
	while index <= #servers do
		local server = servers[index]
		index += 1
		if server.id ~= currentJobId then
			wait(2)
			say("Hopping to server: " .. server.id)
			TeleportService:TeleportToPlaceInstance(placeId, server.id)
			break
		end
	end
end

-- If teleport fails, try next
TeleportService.TeleportInitFailed:Connect(function(_, _, msg)
	if msg:find("GameFull") then
		say("Server full. Trying next...")
		hop()
	end
end)

-- Jump to next
hop()

