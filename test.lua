-- SpawnRealm / Moondiety UI Library Module (Interactive Expandable Profile & Stats Pill)
local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Automatically detect running exploit executor name
local function getExecutorName()
	local success, name = pcall(function()
		return identifyexecutor and identifyexecutor() or (syn and "Synapse" or (KRNL_LOADED and "Krnl" or (fluxus and "Fluxus" or "Delta")))
	end)
	return success and name or "Delta"
end

local LucideIcons = {
	["home"] = "rbxassetid://10734949856",
	["settings"] = "rbxassetid://10734950309",
	["user"] = "rbxassetid://10735031441",
	["users"] = "rbxassetid://10735031601",
	["search"] = "rbxassetid://10735005431",
	["menu"] = "rbxassetid://10734978184",
	["grid"] = "rbxassetid://10734941926",
	["list"] = "rbxassetid://10734974026",
	["folder"] = "rbxassetid://10734928173",
	["star"] = "rbxassetid://10735016335",
	["heart"] = "rbxassetid://10734944967",
	["shield"] = "rbxassetid://10709791437",
	["sword"] = "rbxassetid://10747371351",
	["combat"] = "rbxassetid://10747371351",
	["crosshair"] = "rbxassetid://10734885564",
	["zap"] = "rbxassetid://10735034606",
	["flame"] = "rbxassetid://10734927237",
	["skull"] = "rbxassetid://10735008064",
	["lock"] = "rbxassetid://10734975736",
	["unlock"] = "rbxassetid://10735027877",
	["key"] = "rbxassetid://10734963503",
	["cpu"] = "rbxassetid://10734885834",
	["terminal"] = "rbxassetid://10735024403",
	["code"] = "rbxassetid://10734884242",
	["refresh"] = "rbxassetid://10734998706",
	["trash"] = "rbxassetid://10735026916",
	["download"] = "rbxassetid://10734914175",
	["upload"] = "rbxassetid://10735028475",
	["play"] = "rbxassetid://10734992435",
	["pause"] = "rbxassetid://10734983059",
	["chevronright"] = "rbxassetid://10734886616"
}

local function getIconAsset(input)
	if not input then return "" end
	local str = tostring(input)
	if str:match("^rbxassetid://") or str:match("^http") then
		return str
	end
	local formatted = str:lower().gsub(str, "[^a-z]", "")
	return LucideIcons[formatted] or str
end

local function getProtectedParent()
	local base
	if gethui then
		base = gethui()
	elseif syn and syn.protect_gui then
		base = Instance.new("Folder")
		syn.protect_gui(base)
		base.Parent = CoreGui
	else
		base = CoreGui
	end

	local folder = base:FindFirstChild("SR_DedicatedFolder")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "SR_DedicatedFolder"
		folder.Parent = base
	end
	return folder
end

local function makeDraggable(handle, object)
	local dragging, dragInput, dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local function playSound(soundId, enabled, volume)
	if not enabled or not soundId then return end
	pcall(function()
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = volume or 1.5
		sound.Parent = getProtectedParent()
		sound:Play()
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end)
end

function Library.CreateWindow(config)
	config = config or {}
	local titleText = config.name or config.Name or "MOONDIETY"
	local subText = config.subtitle or config.Subtitle or "Universal"
	local iconId = getIconAsset(config.UIicon or config.UiIcon or "shield")
	local soundEnabled = (config.SoundButtons ~= false)
	local userConfig = config.User or nil
	local searchBarEnabled = (config.UiSearchBar == true)
	
	local pillUIWavesEnabled = (config.PillUIWaves == true)
	local pillUIFPSEnabled = (config.PillUIFPS == true)
	local loadingXUIEnabled = (config.LoadingXUI == true)

	local parentBase = gethui() or CoreGui
	local existingFolder = parentBase:FindFirstChild("SR_DedicatedFolder")
	if existingFolder then
		existingFolder:Destroy()
	end

	local window = {}
	local registeredElements = {}
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "SR_MainGui"
	ScreenGui.Parent = getProtectedParent()
	ScreenGui.ResetOnSpawn = false

	local targetWidth = 682
	local targetHeight = 310

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, targetWidth, 0, targetHeight)
	Main.Position = UDim2.new(0.5, -targetWidth/2, 0.45, -targetHeight/2)
	Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	Main.BackgroundTransparency = loadingXUIEnabled and 1 or 0
	Main.BorderSizePixel = 0
	Main.Visible = not loadingXUIEnabled
	if loadingXUIEnabled then
		Main.Size = UDim2.new(0, 0, 0, 0)
		Main.Position = UDim2.new(0.5, 0, 0.45, 0)
	end
	Main.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 30)
	MainCorner.Parent = Main

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Thickness = 2.8
	MainStroke.Parent = Main

	local MainStrokeGrad = Instance.new("UIGradient")
	MainStrokeGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.15, 0.1),
		NumberSequenceKeypoint.new(0.35, 0.9),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(0.65, 0.9),
		NumberSequenceKeypoint.new(0.85, 0.1),
		NumberSequenceKeypoint.new(1, 0)
	})
	MainStrokeGrad.Parent = MainStroke

	task.spawn(function()
		while MainStrokeGrad and MainStrokeGrad.Parent do
			TweenService:Create(MainStrokeGrad, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {Rotation = MainStrokeGrad.Rotation + 360}):Play()
			task.wait(2.8)
		end
	end)

	local ShinyClip = Instance.new("Frame")
	ShinyClip.Size = UDim2.new(1, 0, 1, 0)
	ShinyClip.BackgroundTransparency = 1
	ShinyClip.ClipsDescendants = true
	ShinyClip.Parent = Main

	local ShinyClipCorner = Instance.new("UICorner")
	ShinyClipCorner.CornerRadius = UDim.new(0, 30)
	ShinyClipCorner.Parent = ShinyClip

	local MainShiny = Instance.new("Frame")
	MainShiny.Size = UDim2.new(0, 100, 2, 0)
	MainShiny.Position = UDim2.new(-0.5, 0, -0.5, 0)
	MainShiny.Rotation = 30
	MainShiny.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MainShiny.BackgroundTransparency = 0.93
	MainShiny.BorderSizePixel = 0
	MainShiny.Parent = ShinyClip

	local MainShinyGrad = Instance.new("UIGradient")
	MainShinyGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 1)
	})
	MainShinyGrad.Parent = MainShiny

	task.spawn(function()
		while Main and Main.Parent do
			MainShiny.Position = UDim2.new(-0.5, 0, -0.5, 0)
			TweenService:Create(MainShiny, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(1.3, 0, -0.5, 0)}):Play()
			task.wait(7)
		end
	end)

	-- 1. Tapable Interactive Expandable Profile & Stats Pill (Top-Middle)
	local WavesStatsFrame = nil
	if pillUIWavesEnabled then
		WavesStatsFrame = Instance.new("TextButton")
		WavesStatsFrame.Name = "WavesStatsFrame"
		WavesStatsFrame.Size = UDim2.new(0, 185, 0, 34)
		WavesStatsFrame.Position = UDim2.new(0.5, -92, 0, 2)
		WavesStatsFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
		WavesStatsFrame.BackgroundTransparency = loadingXUIEnabled and 1 or 0
		WavesStatsFrame.BorderSizePixel = 0
		WavesStatsFrame.AutoButtonColor = false
		WavesStatsFrame.Text = ""
		WavesStatsFrame.Visible = not loadingXUIEnabled
		WavesStatsFrame.ClipsDescendants = true
		WavesStatsFrame.Parent = ScreenGui

		local WStatsCorner = Instance.new("UICorner")
		WStatsCorner.CornerRadius = UDim.new(0, 18)
		WStatsCorner.Parent = WavesStatsFrame

		local WStatsStroke = Instance.new("UIStroke")
		WStatsStroke.Thickness = 2.2
		WStatsStroke.Parent = WavesStatsFrame

		local WStatsStrokeGrad = Instance.new("UIGradient")
		WStatsStrokeGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 0.2),
			NumberSequenceKeypoint.new(0.4, 0.9),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(0.7, 0.9),
			NumberSequenceKeypoint.new(0.9, 0.2),
			NumberSequenceKeypoint.new(1, 0)
		})
		WStatsStrokeGrad.Parent = WStatsStroke

		task.spawn(function()
			while WStatsStrokeGrad and WStatsStrokeGrad.Parent do
				TweenService:Create(WStatsStrokeGrad, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {Rotation = WStatsStrokeGrad.Rotation + 360}):Play()
				task.wait(2.8)
			end
		end)

		-- Collapsed Pill Content Container
		local CollapsedContainer = Instance.new("Frame")
		CollapsedContainer.Name = "CollapsedContainer"
		CollapsedContainer.Size = UDim2.new(1, 0, 0, 34)
		CollapsedContainer.BackgroundTransparency = 1
		CollapsedContainer.Parent = WavesStatsFrame

		local RadarContainer = Instance.new("Frame")
		RadarContainer.Size = UDim2.new(0, 20, 0, 20)
		RadarContainer.Position = UDim2.new(0, 8, 0.5, -10)
		RadarContainer.BackgroundTransparency = 1
		RadarContainer.ClipsDescendants = false
		RadarContainer.Parent = CollapsedContainer

		local PingDot = Instance.new("Frame")
		PingDot.Size = UDim2.new(0, 8, 0, 8)
		PingDot.Position = UDim2.new(0.5, -4, 0.5, -4)
		PingDot.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		PingDot.BorderSizePixel = 0
		PingDot.ZIndex = 3
		PingDot.Parent = RadarContainer

		local PingDotCorner = Instance.new("UICorner")
		PingDotCorner.CornerRadius = UDim.new(1, 0)
		PingDotCorner.Parent = PingDot

		task.spawn(function()
			while WavesStatsFrame and WavesStatsFrame.Parent do
				pcall(function()
					local ring = Instance.new("Frame")
					ring.Size = UDim2.new(0, 8, 0, 8)
					ring.Position = UDim2.new(0.5, -4, 0.5, -4)
					ring.BackgroundColor3 = PingDot.BackgroundColor3
					ring.BackgroundTransparency = 0.2
					ring.BorderSizePixel = 0
					ring.ZIndex = 2
					ring.Parent = RadarContainer

					local rCorner = Instance.new("UICorner")
					rCorner.CornerRadius = UDim.new(1, 0)
					rCorner.Parent = ring

					TweenService:Create(ring, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, 24, 0, 24),
						Position = UDim2.new(0.5, -12, 0.5, -12),
						BackgroundTransparency = 1
					}):Play()

					task.delay(0.9, function()
						if ring then ring:Destroy() end
					end)
				end)
				task.wait(1.0)
			end
		end)

		local CenterContent = Instance.new("Frame")
		CenterContent.Size = UDim2.new(1, -56, 1, 0)
		CenterContent.Position = UDim2.new(0, 28, 0, 0)
		CenterContent.BackgroundTransparency = 1
		CenterContent.Parent = CollapsedContainer

		local CenterIcon = Instance.new("ImageLabel")
		CenterIcon.Size = UDim2.new(0, 13, 0, 13)
		CenterIcon.Position = UDim2.new(0, 0, 0.5, -6.5)
		CenterIcon.BackgroundTransparency = 1
		CenterIcon.Image = iconId
		CenterIcon.Parent = CenterContent

		local CenterTitle = Instance.new("TextLabel")
		CenterTitle.Size = UDim2.new(1, -15, 1, 0)
		CenterTitle.Position = UDim2.new(0, 15, 0, 0)
		CenterTitle.BackgroundTransparency = 1
		CenterTitle.Text = "SpawnRealmXHub"
		CenterTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		CenterTitle.TextSize = 10
		CenterTitle.Font = Enum.Font.GothamBold
		CenterTitle.TextXAlignment = Enum.TextXAlignment.Left
		CenterTitle.Parent = CenterContent

		local WaveContainer = Instance.new("Frame")
		WaveContainer.Size = UDim2.new(0, 22, 0, 16)
		WaveContainer.Position = UDim2.new(1, -26, 0.5, -8)
		WaveContainer.BackgroundTransparency = 1
		WaveContainer.Parent = CollapsedContainer

		local WaveLayout = Instance.new("UIListLayout")
		WaveLayout.FillDirection = Enum.FillDirection.Horizontal
		WaveLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		WaveLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		WaveLayout.Padding = UDim.new(0, 2)
		WaveLayout.Parent = WaveContainer

		local function createWaveBar()
			local bar = Instance.new("Frame")
			bar.Size = UDim2.new(0, 4, 0, 8)
			bar.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
			bar.BorderSizePixel = 0
			bar.Parent = WaveContainer

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(1, 0)
			bCorner.Parent = bar
			return bar
		end

		local bar1 = createWaveBar()
		local bar2 = createWaveBar()
		local bar3 = createWaveBar()

		-- Expanded Menu Container (Matching User Screenshot Layout)
		local ExpandedContainer = Instance.new("Frame")
		ExpandedContainer.Name = "ExpandedContainer"
		ExpandedContainer.Size = UDim2.new(1, 0, 1, -34)
		ExpandedContainer.Position = UDim2.new(0, 0, 0, 34)
		ExpandedContainer.BackgroundTransparency = 1
		ExpandedContainer.Visible = false
		ExpandedContainer.Parent = WavesStatsFrame

		-- Profile Card Header inside Expanded View
		local AvatarImg = Instance.new("ImageLabel")
		AvatarImg.Size = UDim2.new(0, 34, 0, 34)
		AvatarImg.Position = UDim2.new(0, 12, 0, 8)
		AvatarImg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		AvatarImg.BorderSizePixel = 0
		AvatarImg.Parent = ExpandedContainer

		local AvatarCorner = Instance.new("UICorner")
		AvatarCorner.CornerRadius = UDim.new(1, 0)
		AvatarCorner.Parent = AvatarImg

		task.spawn(function()
			pcall(function()
				AvatarImg.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", LocalPlayer.UserId)
			end)
		end)

		local DisplayNameLbl = Instance.new("TextLabel")
		DisplayNameLbl.Size = UDim2.new(1, -110, 0, 16)
		DisplayNameLbl.Position = UDim2.new(0, 54, 0, 8)
		DisplayNameLbl.BackgroundTransparency = 1
		DisplayNameLbl.Text = LocalPlayer.DisplayName
		DisplayNameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		DisplayNameLbl.TextSize = 12
		DisplayNameLbl.Font = Enum.Font.GothamBold
		DisplayNameLbl.TextXAlignment = Enum.TextXAlignment.Left
		DisplayNameLbl.Parent = ExpandedContainer

		local execName = getExecutorName()
		local gameName = "[UP] Just a baseplate"
		pcall(function()
			local info = MarketplaceService:GetProductInfo(game.PlaceId)
			if info and info.Name then
				gameName = "[UP] " .. info.Name
			end
		end)

		local SubInfoLbl = Instance.new("TextLabel")
		SubInfoLbl.Size = UDim2.new(1, -110, 0, 14)
		SubInfoLbl.Position = UDim2.new(0, 54, 0, 26)
		SubInfoLbl.BackgroundTransparency = 1
		SubInfoLbl.Text = "@" .. LocalPlayer.Name .. " • " .. execName .. "\n" .. gameName
		SubInfoLbl.TextColor3 = Color3.fromRGB(150, 150, 165)
		SubInfoLbl.TextSize = 9
		SubInfoLbl.Font = Enum.Font.GothamMedium
		SubInfoLbl.TextXAlignment = Enum.TextXAlignment.Left
		SubInfoLbl.Parent = ExpandedContainer

		-- Session Timer Pill
		local TimerPill = Instance.new("Frame")
		TimerPill.Size = UDim2.new(0, 64, 0, 22)
		TimerPill.Position = UDim2.new(1, -74, 0, 12)
		TimerPill.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
		TimerPill.BorderSizePixel = 0
		TimerPill.Parent = ExpandedContainer

		local TimerCorner = Instance.new("UICorner")
		TimerCorner.CornerRadius = UDim.new(0, 11)
		TimerCorner.Parent = TimerPill

		local TimerLbl = Instance.new("TextLabel")
		TimerLbl.Size = UDim2.new(1, 0, 1, 0)
		TimerLbl.BackgroundTransparency = 1
		TimerLbl.Text = "0m 0s"
		TimerLbl.TextColor3 = Color3.fromRGB(210, 210, 220)
		TimerLbl.TextSize = 9
		TimerLbl.Font = Enum.Font.GothamBold
		TimerLbl.Parent = TimerPill

		local startTime = tick()
		task.spawn(function()
			while true do
				task.wait(1)
				local elapsed = math.floor(tick() - startTime)
				local mins = math.floor(elapsed / 60)
				local secs = elapsed % 60
				TimerLbl.Text = string.format("%dm %ds", mins, secs)
			end
		end)

		-- Grid Stats Cards (FPS, Ping, Players, Online)
		local CardsHolder = Instance.new("Frame")
		CardsHolder.Size = UDim2.new(1, -20, 0, 68)
		CardsHolder.Position = UDim2.new(0, 10, 0, 52)
		CardsHolder.BackgroundTransparency = 1
		CardsHolder.Parent = ExpandedContainer

		local function createStatCard(posX, posY, iconName, labelName, defaultVal)
			local card = Instance.new("Frame")
			card.Size = UDim2.new(0.5, -4, 0, 30)
			card.Position = posX
			card.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
			card.BorderSizePixel = 0
			card.Parent = CardsHolder

			local cCorner = Instance.new("UICorner")
			cCorner.CornerRadius = UDim.new(0, 8)
			cCorner.Parent = card

			local icon = Instance.new("ImageLabel")
			icon.Size = UDim2.new(0, 12, 0, 12)
			icon.Position = UDim2.new(0, 8, 0.5, -6)
			icon.BackgroundTransparency = 1
			icon.Image = getIconAsset(iconName)
			icon.ImageColor3 = Color3.fromRGB(160, 160, 175)
			icon.Parent = card

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -26, 1, 0)
			lbl.Position = UDim2.new(0, 26, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = labelName .. " " .. defaultVal
			lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
			lbl.TextSize = 10
			lbl.Font = Enum.Font.GothamMedium
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Parent = card
			return lbl
		end

		local FpsCardLbl = createStatCard(UDim2.new(0, 0, 0, 0), UDim2.new(0, 0, 0, 0), "cpu", "FPS", "60")
		local PingCardLbl = createStatCard(UDim2.new(0.5, 4, 0, 0), UDim2.new(0, 0, 0, 0), "zap", "Ping", "35 ms")
		local PlrCardLbl = createStatCard(UDim2.new(0, 0, 0, 34), UDim2.new(0, 0, 0, 0), "users", "Players", "4")
		local OnlineCardLbl = createStatCard(UDim2.new(0.5, 4, 0, 34), UDim2.new(0, 0, 0, 0), "globe", "Online", "3000")

		-- Toggle Expand / Collapse Action
		local isExpanded = false
		WavesStatsFrame.MouseButton1Click:Connect(function()
			playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
			isExpanded = not isExpanded

			local targetHeight = isExpanded and 130 or 34
			TweenService:Create(WavesStatsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 260, 0, targetHeight)
			}):Play()

			CollapsedContainer.Visible = not isExpanded
			ExpandedContainer.Visible = isExpanded
		end)

		-- Update Stats Loop
		task.spawn(function()
			local lastUpdate = 0
			RunService.RenderStepped:Connect(function(dt)
				lastUpdate += dt
				if lastUpdate >= 1 then
					lastUpdate = 0
					local ping = 0
					pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
					PingCardLbl.Text = "Ping " .. ping .. " ms"
					FpsCardLbl.Text = "FPS " .. math.floor(1 / dt)
					PlrCardLbl.Text = "Players " .. #Players:GetPlayers()
				end
			end)
		end)

		makeDraggable(WavesStatsFrame, WavesStatsFrame)
	end

	-- 2. Top-Right Mini Stats Pill
	local StatsFrame = nil
	if pillUIFPSEnabled then
		StatsFrame = Instance.new("Frame")
		StatsFrame.Name = "StatsFrame"
		StatsFrame.Size = UDim2.new(0, 220, 0, 32)
		StatsFrame.Position = UDim2.new(1, -232, 0, 2)
		StatsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
		StatsFrame.BackgroundTransparency = loadingXUIEnabled and 1 or 0
		StatsFrame.BorderSizePixel = 0
		StatsFrame.Visible = not loadingXUIEnabled
		StatsFrame.Parent = ScreenGui

		local StatsCorner = Instance.new("UICorner")
		StatsCorner.CornerRadius = UDim.new(0, 30)
		StatsCorner.Parent = StatsFrame

		local StatsStroke = Instance.new("UIStroke")
		StatsStroke.Thickness = 2.5
		StatsStroke.Parent = StatsFrame

		local StatsStrokeGrad = Instance.new("UIGradient")
		StatsStrokeGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 0.2),
			NumberSequenceKeypoint.new(0.4, 0.9),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(0.7, 0.9),
			NumberSequenceKeypoint.new(0.9, 0.2),
			NumberSequenceKeypoint.new(1, 0)
		})
		StatsStrokeGrad.Parent = StatsStroke

		task.spawn(function()
			while StatsStrokeGrad and StatsStrokeGrad.Parent do
				TweenService:Create(StatsStrokeGrad, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {Rotation = StatsStrokeGrad.Rotation + 360}):Play()
				task.wait(2.8)
			end
		end)

		local HeadshotImg = Instance.new("ImageLabel")
		HeadshotImg.Size = UDim2.new(0, 20, 0, 20)
		HeadshotImg.Position = UDim2.new(0, 8, 0.5, -10)
		HeadshotImg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		HeadshotImg.BorderSizePixel = 0
		HeadshotImg.Parent = StatsFrame

		local HeadCorner = Instance.new("UICorner")
		HeadCorner.CornerRadius = UDim.new(1, 0)
		HeadCorner.Parent = HeadshotImg

		task.spawn(function()
			while not LocalPlayer do task.wait(0.1) end
			pcall(function()
				HeadshotImg.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", LocalPlayer.UserId)
			end)
		end)

		local StatsContainer = Instance.new("Frame")
		StatsContainer.Size = UDim2.new(1, -30, 1, 0)
		StatsContainer.Position = UDim2.new(0, 30, 0, 0)
		StatsContainer.BackgroundTransparency = 1
		StatsContainer.Parent = StatsFrame

		local StatsLayout = Instance.new("UIListLayout")
		StatsLayout.FillDirection = Enum.FillDirection.Horizontal
		StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		StatsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		StatsLayout.Padding = UDim.new(0, 4)
		StatsLayout.Parent = StatsContainer

		local function createStatBadge(iconId, labelName, defaultVal)
			local holder = Instance.new("Frame")
			holder.Size = UDim2.new(0, 58, 1, 0)
			holder.BackgroundTransparency = 1
			holder.Parent = StatsContainer

			local icon = Instance.new("ImageLabel")
			icon.Size = UDim2.new(0, 11, 0, 11)
			icon.Position = UDim2.new(0, 0, 0.5, -5.5)
			icon.BackgroundTransparency = 1
			icon.Image = getIconAsset(iconId)
			icon.ImageColor3 = Color3.fromRGB(160, 160, 175)
			icon.Parent = holder

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -13, 1, 0)
			lbl.Position = UDim2.new(0, 13, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = defaultVal .. " " .. labelName
			lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
			lbl.TextSize = 8.5
			lbl.Font = Enum.Font.GothamMedium
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Parent = holder
			return lbl
		end

		local PingLabel = createStatBadge("zap", "ms", "32")
		local FpsLabel = createStatBadge("cpu", "fps", "60")
		local PlayersLabel = createStatBadge("users", "plrs", "12")

		task.spawn(function()
			local lastUpdate = 0
			RunService.RenderStepped:Connect(function(dt)
				lastUpdate += dt
				if lastUpdate >= 1 then
					lastUpdate = 0
					local ping = 0
					pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
					PingLabel.Text = ping .. " ms"
					FpsLabel.Text = math.floor(1 / dt) .. " fps"
					PlayersLabel.Text = #Players:GetPlayers() .. " plrs"
				end
			end)
		end)

		makeDraggable(StatsFrame, StatsFrame)
	end

	-- 3. Minimized Floating Circle Toggle Button
	local ToggleBtnOuter = Instance.new("Frame")
	ToggleBtnOuter.Name = "ToggleBtnOuter"
	ToggleBtnOuter.Size = UDim2.new(0, 44, 0, 44)
	ToggleBtnOuter.Position = UDim2.new(0, 40, 0, 200)
	ToggleBtnOuter.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	ToggleBtnOuter.BorderSizePixel = 0
	ToggleBtnOuter.Visible = false
	ToggleBtnOuter.Parent = ScreenGui

	local TBtnOuterCorner = Instance.new("UICorner")
	TBtnOuterCorner.CornerRadius = UDim.new(1, 0)
	TBtnOuterCorner.Parent = ToggleBtnOuter

	local ToggleBtnStroke = Instance.new("UIStroke")
	ToggleBtnStroke.Thickness = 2.2
	ToggleBtnStroke.Parent = ToggleBtnOuter

	local ToggleBtnStrokeGrad = Instance.new("UIGradient")
	ToggleBtnStrokeGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.15, 0.1),
		NumberSequenceKeypoint.new(0.35, 0.9),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(0.65, 0.9),
		NumberSequenceKeypoint.new(0.85, 0.1),
		NumberSequenceKeypoint.new(1, 0)
	})
	ToggleBtnStrokeGrad.Parent = ToggleBtnStroke

	task.spawn(function()
		while ToggleBtnStrokeGrad and ToggleBtnStrokeGrad.Parent do
			TweenService:Create(ToggleBtnStrokeGrad, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {Rotation = ToggleBtnStrokeGrad.Rotation + 360}):Play()
			task.wait(2.8)
		end
	end)

	local ToggleBtn = Instance.new("ImageButton")
	ToggleBtn.Size = UDim2.new(0, 24, 0, 24)
	ToggleBtn.Position = UDim2.new(0.5, -12, 0.5, -12)
	ToggleBtn.BackgroundTransparency = 1
	ToggleBtn.Image = iconId
	ToggleBtn.ScaleType = Enum.ScaleType.Fit
	ToggleBtn.Parent = ToggleBtnOuter

	makeDraggable(ToggleBtnOuter, ToggleBtnOuter)
	makeDraggable(ToggleBtn, ToggleBtnOuter)

	local function restoreWindowAction()
		playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
		Main.Visible = true
		if WavesStatsFrame then WavesStatsFrame.Visible = true end
		if StatsFrame then StatsFrame.Visible = true end

		Main.Size = UDim2.new(0, 0, 0, 0)
		Main.Position = UDim2.new(0.5, 0, 0.45, 0)
		if WavesStatsFrame then
			WavesStatsFrame.Size = UDim2.new(0, 185, 0, 34)
			WavesStatsFrame.Position = UDim2.new(0.5, -92, 0, 2)
		end
		if StatsFrame then
			StatsFrame.Size = UDim2.new(0, 220, 0, 32)
			StatsFrame.Position = UDim2.new(1, -232, 0, 2)
		end

		Main.BackgroundTransparency = 1
		if WavesStatsFrame then WavesStatsFrame.BackgroundTransparency = 1 end
		if StatsFrame then StatsFrame.BackgroundTransparency = 1 end

		TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, targetWidth, 0, targetHeight),
			Position = UDim2.new(0.5, -targetWidth/2, 0.45, -targetHeight/2),
			BackgroundTransparency = 0
		}):Play()

		if WavesStatsFrame then
			TweenService:Create(WavesStatsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 185, 0, 34),
				Position = UDim2.new(0.5, -92, 0, 2),
				BackgroundTransparency = 0
			}):Play()
		end

		if StatsFrame then
			TweenService:Create(StatsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 220, 0, 32),
				Position = UDim2.new(1, -232, 0, 2),
				BackgroundTransparency = 0
			}):Play()
		end

		ToggleBtnOuter.Visible = false
	end

	ToggleBtn.MouseButton1Click:Connect(restoreWindowAction)

	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 50)
	Topbar.BackgroundTransparency = 1
	Topbar.Parent = Main

	local WindowIcon = Instance.new("ImageLabel")
	WindowIcon.Size = UDim2.new(0, 24, 0, 24)
	WindowIcon.Position = UDim2.new(0, 16, 0, 13)
	WindowIcon.BackgroundTransparency = 1
	WindowIcon.Image = iconId
	WindowIcon.Parent = Topbar

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(0, 200, 0, 20)
	TitleLabel.Position = UDim2.new(0, 48, 0, 8)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = titleText
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 16
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Topbar

	local SubTitleLabel = Instance.new("TextLabel")
	SubTitleLabel.Size = UDim2.new(0, 200, 0, 14)
	SubTitleLabel.Position = UDim2.new(0, 48, 0, 26)
	SubTitleLabel.BackgroundTransparency = 1
	SubTitleLabel.Text = subText
	SubTitleLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
	SubTitleLabel.TextSize = 11
	SubTitleLabel.Font = Enum.Font.GothamMedium
	SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	SubTitleLabel.Parent = Topbar

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 22, 0, 22)
	CloseBtn.Position = UDim2.new(1, -32, 0, 14)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	CloseBtn.Text = "×"
	CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	CloseBtn.TextSize = 15
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.Parent = Topbar

	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 11)
	CloseCorner.Parent = CloseBtn

	CloseBtn.MouseButton1Click:Connect(function()
		TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			BackgroundTransparency = 1
		}):Play()
		if WavesStatsFrame then
			TweenService:Create(WavesStatsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0.5, -92, 0, 2),
				BackgroundTransparency = 1
			}):Play()
		end
		if StatsFrame then
			TweenService:Create(StatsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(1, -232, 0, 2),
				BackgroundTransparency = 1
			}):Play()
		end
		task.wait(0.25)
		pcall(function() getProtectedParent():Destroy() end)
	end)

	local MinBtn = Instance.new("TextButton")
	MinBtn.Size = UDim2.new(0, 22, 0, 22)
	MinBtn.Position = UDim2.new(1, -58, 0, 14)
	MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	MinBtn.Text = "-"
	MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	MinBtn.TextSize = 15
	MinBtn.Font = Enum.Font.GothamBold
	MinBtn.Parent = Topbar

	local MinCorner = Instance.new("UICorner")
	MinCorner.CornerRadius = UDim.new(0, 11)
	MinCorner.Parent = MinBtn

	MinBtn.MouseButton1Click:Connect(function()
		playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
		TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			BackgroundTransparency = 1
		}):Play()
		if WavesStatsFrame then
			TweenService:Create(WavesStatsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0.5, -92, 0, 2),
				BackgroundTransparency = 1
			}):Play()
		end
		if StatsFrame then
			TweenService:Create(StatsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(1, -232, 0, 2),
				BackgroundTransparency = 1
			}):Play()
		end
		task.wait(0.25)
		Main.Visible = false
		if WavesStatsFrame then WavesStatsFrame.Visible = false end
		if StatsFrame then StatsFrame.Visible = false end
		ToggleBtnOuter.Visible = true
	end)

	makeDraggable(Topbar, Main)

	local SearchBox = nil
	if searchBarEnabled then
		SearchBox = Instance.new("TextBox")
		SearchBox.Name = "SearchBox"
		SearchBox.Size = UDim2.new(0, 126, 0, 28)
		SearchBox.Position = UDim2.new(0, 12, 0, 52)
		SearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
		SearchBox.BorderSizePixel = 0
		SearchBox.PlaceholderText = "Search..."
		SearchBox.Text = ""
		SearchBox.TextColor3 = Color3.fromRGB(240, 240, 245)
		SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
		SearchBox.TextSize = 10
		SearchBox.Font = Enum.Font.GothamMedium
		SearchBox.ClearTextOnFocus = false
		SearchBox.TextXAlignment = Enum.TextXAlignment.Left
		SearchBox.TextWrapped = false
		SearchBox.Parent = Main

		local SearchCorner = Instance.new("UICorner")
		SearchCorner.CornerRadius = UDim.new(0, 30)
		SearchCorner.Parent = SearchBox

		local SearchIcon = Instance.new("ImageLabel")
		SearchIcon.Size = UDim2.new(0, 14, 0, 14)
		SearchIcon.Position = UDim2.new(0, 8, 0.5, -7)
		SearchIcon.BackgroundTransparency = 1
		SearchIcon.Image = getIconAsset("search")
		SearchIcon.ImageColor3 = Color3.fromRGB(130, 130, 140)
		SearchIcon.Active = false
		SearchIcon.Selectable = false
		SearchIcon.Parent = SearchBox

		local SearchPadding = Instance.new("UIPadding")
		SearchPadding.PaddingLeft = UDim.new(0, 28)
		SearchPadding.Parent = SearchBox
	end
	
	local tabYOffset = searchBarEnabled and 84 or 52
	local tabBottomOffset = (userConfig and userConfig.Enabled ~= false) and (searchBarEnabled and -146 or -112) or (searchBarEnabled and -88 or -55)

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(0, 140, 1, tabBottomOffset)
	TabContainer.Position = UDim2.new(0, 12, 0, tabYOffset)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 4
	TabContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95)
	TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TabContainer.Parent = Main

	local TabList = Instance.new("UIListLayout")
	TabList.Padding = UDim.new(0, 6)
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Parent = TabContainer

	if userConfig and userConfig.Enabled ~= false then
		local isAnonymous = (userConfig.Anonymous == true)

		local ProfileCard = Instance.new("TextButton")
		ProfileCard.Name = "ProfileCard"
		ProfileCard.Size = UDim2.new(0, 140, 0, 52)
		ProfileCard.Position = UDim2.new(0, 12, 1, -60)
		ProfileCard.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
		ProfileCard.AutoButtonColor = false
		ProfileCard.Text = ""
		ProfileCard.Parent = Main

		local PCardCorner = Instance.new("UICorner")
		PCardCorner.CornerRadius = UDim.new(0, 30)
		PCardCorner.Parent = ProfileCard

		local AvatarImg = Instance.new("ImageLabel")
		AvatarImg.Size = UDim2.new(0, 34, 0, 34)
		AvatarImg.Position = UDim2.new(0, 8, 0.5, -17)
		AvatarImg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		AvatarImg.BorderSizePixel = 0
		AvatarImg.Parent = ProfileCard

		local AvatarCorner = Instance.new("UICorner")
		AvatarCorner.CornerRadius = UDim.new(0, 17)
		AvatarCorner.Parent = AvatarImg

		if isAnonymous then
			AvatarImg.Image = getIconAsset("user")
		else
			task.spawn(function()
				pcall(function()
					AvatarImg.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", LocalPlayer.UserId)
				end)
			end)
		end

		local displayName = isAnonymous and "Anonymous" or LocalPlayer.Name
		local handleName = isAnonymous and "Hidden User" or ("@" .. LocalPlayer.Name)

		local NameLbl = Instance.new("TextLabel")
		NameLbl.Size = UDim2.new(1, -52, 0, 16)
		NameLbl.Position = UDim2.new(0, 48, 0, 10)
		NameLbl.BackgroundTransparency = 1
		NameLbl.Text = displayName
		NameLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
		NameLbl.TextSize = 11
		NameLbl.Font = Enum.Font.GothamBold
		NameLbl.TextXAlignment = Enum.TextXAlignment.Left
		NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
		NameLbl.Parent = ProfileCard

		local HandleLbl = Instance.new("TextLabel")
		HandleLbl.Size = UDim2.new(1, -52, 0, 14)
		HandleLbl.Position = UDim2.new(0, 48, 0, 26)
		HandleLbl.BackgroundTransparency = 1
		HandleLbl.Text = handleName
		HandleLbl.TextColor3 = Color3.fromRGB(130, 130, 140)
		HandleLbl.TextSize = 9
		HandleLbl.Font = Enum.Font.GothamMedium
		HandleLbl.TextXAlignment = Enum.TextXAlignment.Left
		HandleLbl.TextTruncate = Enum.TextTruncate.AtEnd
		HandleLbl.Parent = ProfileCard

		local ArrowIcon = Instance.new("ImageLabel")
		ArrowIcon.Size = UDim2.new(0, 12, 0, 12)
		ArrowIcon.Position = UDim2.new(1, -14, 0.5, -6)
		ArrowIcon.BackgroundTransparency = 1
		ArrowIcon.Image = getIconAsset("chevronright")
		ArrowIcon.ImageColor3 = Color3.fromRGB(150, 150, 160)
		ArrowIcon.Parent = ProfileCard

		ProfileCard.MouseButton1Click:Connect(function()
			playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
			if userConfig.Callback then
				pcall(userConfig.Callback)
			end
		end)
	end

	local PagesHolder = Instance.new("Frame")
	PagesHolder.Name = "PagesHolder"
	PagesHolder.Size = UDim2.new(1, -165, 1, -55)
	PagesHolder.Position = UDim2.new(0, 158, 0, 48)
	PagesHolder.BackgroundTransparency = 1
	PagesHolder.Parent = Main

	local tabs = {}
	local activeTabObject = nil

	function window:CreateTab(tabConfig)
		local tabObj = {}
		local TabBtn, Page, FlashlightBeam, GlowLine, DotContainer
		local loopConnection = nil
		
		pcall(function()
			if type(tabConfig) == "string" then
				tabConfig = { name = tabConfig }
			end
			local tabName = tabConfig.name or tabConfig.Name or "Tab"
			local tabIconId = getIconAsset(tabConfig.icon or tabConfig.Icon)

			TabBtn = Instance.new("TextButton")
			TabBtn.Size = UDim2.new(1, 0, 0, 32)
			TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
			TabBtn.Text = ""
			TabBtn.ClipsDescendants = true
			TabBtn.Parent = TabContainer

			FlashlightBeam = Instance.new("Frame")
			FlashlightBeam.Name = "FlashlightBeam"
			FlashlightBeam.Size = UDim2.new(1, 0, 1, 0)
			FlashlightBeam.Position = UDim2.new(0, 0, 0, 0)
			FlashlightBeam.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			FlashlightBeam.BackgroundTransparency = 1
			FlashlightBeam.BorderSizePixel = 0
			FlashlightBeam.ZIndex = 2
			FlashlightBeam.Parent = TabBtn

			local BeamGrad = Instance.new("UIGradient")
			BeamGrad.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.55),
				NumberSequenceKeypoint.new(0.4, 0.85),
				NumberSequenceKeypoint.new(1, 1)
			})
			BeamGrad.Parent = FlashlightBeam

			GlowLine = Instance.new("Frame")
			GlowLine.Name = "GlowLine"
			GlowLine.Size = UDim2.new(0, 3, 1, 0)
			GlowLine.Position = UDim2.new(0, 0, 0, 0)
			GlowLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			GlowLine.BackgroundTransparency = 1
			GlowLine.BorderSizePixel = 0
			GlowLine.ZIndex = 3
			GlowLine.Parent = TabBtn

			DotContainer = Instance.new("Frame")
			DotContainer.Name = "DotContainer"
			DotContainer.Size = UDim2.new(1, 0, 1, 0)
			DotContainer.BackgroundTransparency = 1
			DotContainer.ClipsDescendants = true
			DotContainer.ZIndex = 4
			DotContainer.Parent = TabBtn

			local TabCorner = Instance.new("UICorner")
			TabCorner.CornerRadius = UDim.new(0, 30)
			TabCorner.Parent = TabBtn

			if tabIconId ~= "" then
				local TIcon = Instance.new("ImageLabel")
				TIcon.Size = UDim2.new(0, 16, 0, 16)
				TIcon.Position = UDim2.new(0, 10, 0.5, -8)
				TIcon.BackgroundTransparency = 1
				TIcon.Image = tabIconId
				TIcon.ZIndex = 5
				TIcon.Parent = TabBtn
			end

			local TabText = Instance.new("TextLabel")
			TabText.Size = UDim2.new(1, tabIconId ~= "" and -34 or -16, 1, 0)
			TabText.Position = UDim2.new(0, tabIconId ~= "" and 30 or 12, 0, 0)
			TabText.BackgroundTransparency = 1
			TabText.Text = tostring(tabName)
			TabText.TextColor3 = Color3.fromRGB(150, 150, 160)
			TabText.Font = Enum.Font.GothamMedium
			TabText.TextSize = 12
			TabText.TextXAlignment = Enum.TextXAlignment.Left
			TabText.TextTruncate = Enum.TextTruncate.AtEnd
			TabText.ZIndex = 5
			TabText.Parent = TabBtn

			Page = Instance.new("ScrollingFrame")
			Page.Name = tostring(tabName) .. "Page"
			Page.Size = UDim2.new(1, 0, 1, 0)
			Page.BackgroundTransparency = 1
			Page.ScrollBarThickness = 4
			Page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 95)
			Page.CanvasSize = UDim2.new(0, 0, 0, 0)
			Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
			Page.Visible = false
			Page.Parent = PagesHolder

			local LeftCol = Instance.new("Frame")
			LeftCol.Name = "LeftCol"
			LeftCol.Size = UDim2.new(0.5, -6, 0, 0)
			LeftCol.Position = UDim2.new(0, 0, 0, 0)
			LeftCol.BackgroundTransparency = 1
			LeftCol.Parent = Page

			local LeftLayout = Instance.new("UIListLayout")
			LeftLayout.Padding = UDim.new(0, 8)
			LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
			LeftLayout.Parent = LeftCol

			local RightCol = Instance.new("Frame")
			RightCol.Name = "RightCol"
			RightCol.Size = UDim2.new(0.5, -6, 0, 0)
			RightCol.Position = UDim2.new(0.5, 6, 0, 0)
			RightCol.BackgroundTransparency = 1
			RightCol.Parent = Page

			local RightLayout = Instance.new("UIListLayout")
			RightLayout.Padding = UDim.new(0, 8)
			RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
			RightLayout.Parent = RightCol

			LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				LeftCol.Size = UDim2.new(0.5, -6, 0, LeftLayout.AbsoluteContentSize.Y)
				Page.CanvasSize = UDim2.new(0, 0, 0, math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y) + 16)
			end)

			RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				RightCol.Size = UDim2.new(0.5, -6, 0, RightLayout.AbsoluteContentSize.Y)
				Page.CanvasSize = UDim2.new(0, 0, 0, math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y) + 16)
			end)

			local switchToThisTab = function()
				playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
				for _, t in pairs(tabs) do
					pcall(function()
						t.Page.Visible = false
						t.Active = false
						if t.StopLoop then t.StopLoop() end
						TweenService:Create(t.Button, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(22, 22, 26)}):Play()
						TweenService:Create(t.Label, TWEEN_INFO, {TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
						if t.Beam then TweenService:Create(t.Beam, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end
						if t.Glow then TweenService:Create(t.Glow, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end
					end)
				end
				Page.Visible = true
				tabObj.Active = true
				activeTabObject = tabObj
				TweenService:Create(TabBtn, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}):Play()
				TweenService:Create(TabText, TWEEN_INFO, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				TweenService:Create(FlashlightBeam, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
				TweenService:Create(GlowLine, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()

				if loopConnection then task.cancel(loopConnection) end
				loopConnection = task.spawn(function()
					while tabObj.Active and DotContainer and DotContainer.Parent do
						task.spawn(function()
							pcall(function()
								local dot = Instance.new("Frame")
								dot.Size = UDim2.new(0, math.random(3, 5), 0, math.random(3, 5))
								dot.Position = UDim2.new(0, math.random(10, 120), 1, 5)
								dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
								dot.BackgroundTransparency = 0.3
								dot.BorderSizePixel = 0
								dot.ZIndex = 6
								dot.Parent = DotContainer

								local dCorner = Instance.new("UICorner")
								dCorner.CornerRadius = UDim.new(1, 0)
								dCorner.Parent = dot

								local randX = math.random(-25, 25)
								TweenService:Create(dot, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
									Position = UDim2.new(0, dot.Position.X.Offset + randX, 0, math.random(-6, 10)),
									BackgroundTransparency = 1
								}):Play()
								task.wait(0.7)
								dot:Destroy()
							end)
						end)
						task.wait(0.18)
					end
				end)
			end

			TabBtn.MouseButton1Click:Connect(switchToThisTab)

			tabObj.Button = TabBtn
			tabObj.Label = TabText
			tabObj.Page = Page
			tabObj.Beam = FlashlightBeam
			tabObj.Glow = GlowLine
			tabObj.Dots = DotContainer
			tabObj.Active = false
			tabObj.StopLoop = function()
				if loopConnection then
					task.cancel(loopConnection)
					loopConnection = nil
				end
			end

			if not activeTabObject then
				Page.Visible = true
				TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
				TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
				FlashlightBeam.BackgroundTransparency = 0.2
				GlowLine.BackgroundTransparency = 0.1
				tabObj.Active = true
				activeTabObject = tabObj
				
				loopConnection = task.spawn(function()
					while tabObj.Active and DotContainer and DotContainer.Parent do
						task.spawn(function()
							pcall(function()
								local dot = Instance.new("Frame")
								dot.Size = UDim2.new(0, math.random(3, 5), 0, math.random(3, 5))
								dot.Position = UDim2.new(0, math.random(10, 120), 1, 5)
								dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
								dot.BackgroundTransparency = 0.3
								dot.BorderSizePixel = 0
								dot.ZIndex = 6
								dot.Parent = DotContainer

								local dCorner = Instance.new("UICorner")
								dCorner.CornerRadius = UDim.new(1, 0)
								dCorner.Parent = dot

								local randX = math.random(-25, 25)
								TweenService:Create(dot, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
									Position = UDim2.new(0, dot.Position.X.Offset + randX, 0, math.random(-6, 10)),
									BackgroundTransparency = 1
								}):Play()
								task.wait(0.7)
								dot:Destroy()
							end)
						end)
						task.wait(0.18)
					end
				end)
			end

			table.insert(tabs, tabObj)

			function tabObj:JumpTo()
				switchToThisTab()
			end

			function tabObj:CreateSection(columnSide, sectionTitle)
				local section = {}
				pcall(function()
					local targetCol = (tostring(columnSide):lower() == "right") and RightCol or LeftCol

					local SectionFrame = Instance.new("Frame")
					SectionFrame.Size = UDim2.new(1, 0, 0, 40)
					SectionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
					SectionFrame.BorderSizePixel = 0
					SectionFrame.Parent = targetCol

					local SecCorner = Instance.new("UICorner")
					SecCorner.CornerRadius = UDim.new(0, 30)
					SecCorner.Parent = SectionFrame

					local SecTitle = Instance.new("TextLabel")
					SecTitle.Size = UDim2.new(1, -20, 0, 26)
					SecTitle.Position = UDim2.new(0, 14, 0, 0)
					SecTitle.BackgroundTransparency = 1
					SecTitle.Text = tostring(sectionTitle)
					SecTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
					SecTitle.TextSize = 12
					SecTitle.Font = Enum.Font.GothamBold
					SecTitle.TextXAlignment = Enum.TextXAlignment.Left
					SecTitle.Parent = SectionFrame

					local InnerList = Instance.new("UIListLayout")
					InnerList.Padding = UDim.new(0, 5)
					InnerList.SortOrder = Enum.SortOrder.LayoutOrder
					InnerList.Parent = SectionFrame

					InnerList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
						SectionFrame.Size = UDim2.new(1, 0, 0, InnerList.AbsoluteContentSize.Y + 14)
					end)

					function section:CreateToggle(name, desc, default, callback)
						pcall(function()
							local state = default or false

							local ToggleItem = Instance.new("Frame")
							ToggleItem.Size = UDim2.new(1, -18, 0, desc and 38 or 28)
							ToggleItem.BackgroundTransparency = 1
							ToggleItem.Parent = SectionFrame

							local Label = Instance.new("TextLabel")
							Label.Size = UDim2.new(1, -50, 0, 16)
							Label.Position = UDim2.new(0, 8, 0, desc and 2 or 6)
							Label.BackgroundTransparency = 1
							Label.Text = tostring(name)
							Label.TextColor3 = Color3.fromRGB(210, 210, 220)
							Label.TextSize = 11
							Label.Font = Enum.Font.GothamMedium
							Label.TextXAlignment = Enum.TextXAlignment.Left
							Label.Parent = ToggleItem

							if desc then
								local DescLabel = Instance.new("TextLabel")
								DescLabel.Size = UDim2.new(1, -50, 0, 12)
								DescLabel.Position = UDim2.new(0, 8, 0, 18)
								DescLabel.BackgroundTransparency = 1
								DescLabel.Text = tostring(desc)
								DescLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
								DescLabel.TextSize = 9
								DescLabel.Font = Enum.Font.Gotham
								DescLabel.TextXAlignment = Enum.TextXAlignment.Left
								DescLabel.Parent = ToggleItem
							end

							local ToggleBtn = Instance.new("TextButton")
							ToggleBtn.Size = UDim2.new(0, 32, 0, 18)
							ToggleBtn.Position = UDim2.new(1, -36, 0.5, -9)
							ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(45, 45, 52)
							ToggleBtn.Text = ""
							ToggleBtn.Parent = ToggleItem

							local BtnCorner = Instance.new("UICorner")
							BtnCorner.CornerRadius = UDim.new(0, 30)
							BtnCorner.Parent = ToggleBtn

							local Circle = Instance.new("Frame")
							Circle.Size = UDim2.new(0, 12, 0, 12)
							Circle.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
							Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							Circle.Parent = ToggleBtn

							local CircleCorner = Instance.new("UICorner")
							CircleCorner.CornerRadius = UDim.new(0, 30)
							CircleCorner.Parent = Circle

							ToggleBtn.MouseButton1Click:Connect(function()
								playSound("rbxassetid://75698187458888", soundEnabled, 2.0)
								state = not state
								local targetPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
								local targetColor = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(45, 45, 52)

								TweenService:Create(Circle, TWEEN_INFO, {Position = targetPos}):Play()
								TweenService:Create(ToggleBtn, TWEEN_INFO, {BackgroundColor3 = targetColor}):Play()
								if callback then pcall(callback, state) end
							end)

							table.insert(registeredElements, {Name = tostring(name):lower(), Tab = tabObj, Frame = ToggleItem})
						end)
					end

					function section:CreateButton(name, callback)
						pcall(function()
							local Btn = Instance.new("TextButton")
							Btn.Size = UDim2.new(1, -18, 0, 28)
							Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
							Btn.Text = "  " .. tostring(name)
							Btn.TextColor3 = Color3.fromRGB(210, 210, 220)
							Btn.Font = Enum.Font.GothamMedium
							Btn.TextSize = 11
							Btn.TextXAlignment = Enum.TextXAlignment.Left
							Btn.Parent = SectionFrame

							local BtnCorner = Instance.new("UICorner")
							BtnCorner.CornerRadius = UDim.new(0, 30)
							BtnCorner.Parent = Btn

							Btn.MouseButton1Click:Connect(function()
								playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
								TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
								task.delay(0.1, function()
									TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}):Play()
								end)
								if callback then pcall(callback) end
							end)

							table.insert(registeredElements, {Name = tostring(name):lower(), Tab = tabObj, Frame = Btn})
						end)
					end

					function section:CreateSlider(name, min, max, default, callback)
						pcall(function()
							min = min or 0
							max = max or 100
							default = default or min
							local value = default

							local SliderItem = Instance.new("Frame")
							SliderItem.Size = UDim2.new(1, -18, 0, 42)
							SliderItem.BackgroundTransparency = 1
							SliderItem.Parent = SectionFrame

							local Label = Instance.new("TextLabel")
							Label.Size = UDim2.new(1, 0, 0, 16)
							Label.Position = UDim2.new(0, 8, 0, 2)
							Label.BackgroundTransparency = 1
							Label.Text = tostring(name)
							Label.TextColor3 = Color3.fromRGB(210, 210, 220)
							Label.TextSize = 11
							Label.Font = Enum.Font.GothamMedium
							Label.TextXAlignment = Enum.TextXAlignment.Left
							Label.Parent = SliderItem

							local ValLabel = Instance.new("TextLabel")
							ValLabel.Size = UDim2.new(0, 50, 0, 16)
							ValLabel.Position = UDim2.new(1, -56, 0, 2)
							ValLabel.BackgroundTransparency = 1
							ValLabel.Text = tostring(default)
							ValLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
							ValLabel.TextSize = 11
							ValLabel.Font = Enum.Font.GothamBold
							ValLabel.TextXAlignment = Enum.TextXAlignment.Right
							ValLabel.Parent = SliderItem

							local SliderBar = Instance.new("Frame")
							SliderBar.Size = UDim2.new(1, -16, 0, 6)
							SliderBar.Position = UDim2.new(0, 8, 0, 26)
							SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
							SliderBar.BorderSizePixel = 0
							SliderBar.Parent = SliderItem

							local SBarCorner = Instance.new("UICorner")
							SBarCorner.CornerRadius = UDim.new(0, 30)
							SBarCorner.Parent = SliderBar

							local SliderFill = Instance.new("Frame")
							SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
							SliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							SliderFill.BorderSizePixel = 0
							SliderFill.Parent = SliderBar

							local SFillCorner = Instance.new("UICorner")
							SFillCorner.CornerRadius = UDim.new(0, 30)
							SFillCorner.Parent = SliderFill

							local SliderKnob = Instance.new("Frame")
							SliderKnob.Size = UDim2.new(0, 12, 0, 12)
							SliderKnob.Position = UDim2.new(1, -6, 0.5, -6)
							SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							SliderKnob.BorderSizePixel = 0
							SliderKnob.ZIndex = 3
							SliderKnob.Parent = SliderFill

							local KnobCorner = Instance.new("UICorner")
							KnobCorner.CornerRadius = UDim.new(1, 0)
							KnobCorner.Parent = SliderKnob

							local draggingSlider = false

							local function updateSlider(input)
								local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
								value = math.floor(min + ((max - min) * pos))
								SliderFill.Size = UDim2.new(pos, 0, 1, 0)
								ValLabel.Text = tostring(value)
								if callback then pcall(callback, value) end
							end

							SliderBar.InputBegan:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
									draggingSlider = true
									updateSlider(input)
								end
							end)

							UserInputService.InputEnded:Connect(function(input)
								if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
									draggingSlider = false
								end
							end)

							UserInputService.InputChanged:Connect(function(input)
								if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
									updateSlider(input)
								end
							end)

							table.insert(registeredElements, {Name = tostring(name):lower(), Tab = tabObj, Frame = SliderItem})
						end)
					end
				end)
				return section
			end
		end)
		return tabObj
	end

	if searchBarEnabled and SearchBox then
		SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
			local query = SearchBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
			if query == "" then return end

			for _, item in ipairs(registeredElements) do
				if item.Name:find(query) then
					if item.Tab and item.Tab.JumpTo then
						item.Tab:JumpTo()
					end
					task.spawn(function()
						pcall(function()
							for i = 1, 3 do
								TweenService:Create(item.Frame, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
								task.wait(0.15)
								TweenService:Create(item.Frame, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
								task.wait(0.15)
							end
						end)
					end)
					break
				end
			end
		end)
	end

	return window
end

return Library