-- SpawnRealm / Moondiety UI Library Module (Gen2 with Shiny Animation & Audio Boost)
local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Helper: Make UI Draggy
local function makeDraggable(topbar, object)
	local dragging, dragInput, dragStart, startPos

	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
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

-- Sound Effect Helper (Volume boosted to 1.0)
local function playSound(soundId, enabled)
	if not enabled or not soundId then return end
	pcall(function()
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = 1.0
		sound.Parent = CoreGui
		sound:Play()
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end)
end

-- Create Main Window
function Library.CreateWindow(config)
	config = config or {}
	local titleText = config.name or config.Name or "MOONDIETY"
	local subText = config.subtitle or config.Subtitle or "Universal"
	local iconId = config.UIicon or config.UiIcon or "rbxassetid://12787168883"
	local soundEnabled = (config.SoundButtons ~= false)

	local window = {}
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "MoonDeityHub_" .. math.random(1000, 9999)
	ScreenGui.Parent = (gethui and gethui()) or CoreGui
	ScreenGui.ResetOnSpawn = false

	-- Responsive Main Frame (Hidden until loading finishes)
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 620, 0, 370)
	Main.Position = UDim2.new(0.5, -310, 0.5, -185)
	Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	Main.BorderSizePixel = 0
	Main.Visible = false 
	Main.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 10)
	MainCorner.Parent = Main

	-- Main Window Shiny Reflection Overlay Effect
	local MainShiny = Instance.new("Frame")
	MainShiny.Size = UDim2.new(0, 120, 2, 0)
	MainShiny.Position = UDim2.new(-0.5, 0, -0.5, 0)
	MainShiny.Rotation = 30
	MainShiny.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	MainShiny.BackgroundTransparency = 0.92
	MainShiny.BorderSizePixel = 0
	MainShiny.ClipsDescendants = true
	MainShiny.Parent = Main

	local MainShinyGrad = Instance.new("UIGradient")
	MainShinyGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.7),
		NumberSequenceKeypoint.new(1, 1)
	})
	MainShinyGrad.Parent = MainShiny

	task.spawn(function()
		while Main and Main.Parent do
			MainShiny.Position = UDim2.new(-0.5, 0, -0.5, 0)
			TweenService:Create(MainShiny, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(1.2, 0, -0.5, 0)}):Play()
			task.wait(6)
		end
	end)

	-- Authentic Loading Screen
	pcall(function()
		local LoadGui = Instance.new("ScreenGui")
		LoadGui.Name = "MoonDeityLoader"
		LoadGui.Parent = ScreenGui

		local LoadFrame = Instance.new("Frame")
		LoadFrame.Size = UDim2.new(0, 440, 0, 230)
		LoadFrame.Position = UDim2.new(0.5, -220, 0.5, -115)
		LoadFrame.BackgroundColor3 = Color3.fromRGB(16, 14, 18)
		LoadFrame.BorderSizePixel = 0
		LoadFrame.Parent = LoadGui

		local LoadCorner = Instance.new("UICorner")
		LoadCorner.CornerRadius = UDim.new(0, 12)
		LoadCorner.Parent = LoadFrame

		local GlowImg = Instance.new("ImageLabel")
		GlowImg.Size = UDim2.new(0, 120, 0, 120)
		GlowImg.Position = UDim2.new(0.5, -60, 0, 15)
		GlowImg.BackgroundTransparency = 1
		GlowImg.Image = "rbxassetid://12787168883"
		GlowImg.ImageColor3 = Color3.fromRGB(220, 30, 60)
		GlowImg.ImageTransparency = 0.6
		GlowImg.Parent = LoadFrame

		local IconImg = Instance.new("ImageLabel")
		IconImg.Size = UDim2.new(0, 56, 0, 56)
		IconImg.Position = UDim2.new(0.5, -28, 0, 32)
		IconImg.BackgroundTransparency = 1
		IconImg.Image = iconId ~= "" and iconId or "rbxassetid://12787168883"
		IconImg.Parent = LoadFrame

		local LoadTitle = Instance.new("TextLabel")
		LoadTitle.Size = UDim2.new(1, 0, 0, 22)
		LoadTitle.Position = UDim2.new(0, 0, 0, 96)
		LoadTitle.BackgroundTransparency = 1
		LoadTitle.Text = string.upper(titleText)
		LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		LoadTitle.TextSize = 16
		LoadTitle.Font = Enum.Font.GothamBold
		LoadTitle.TextXAlignment = Enum.TextXAlignment.Center
		LoadTitle.Parent = LoadFrame

		local SubLoadTitle = Instance.new("TextLabel")
		SubLoadTitle.Size = UDim2.new(1, 0, 0, 14)
		SubLoadTitle.Position = UDim2.new(0, 0, 0, 116)
		SubLoadTitle.BackgroundTransparency = 1
		SubLoadTitle.Text = "LOADING INTERFACE"
		SubLoadTitle.TextColor3 = Color3.fromRGB(220, 60, 80)
		SubLoadTitle.TextSize = 10
		SubLoadTitle.Font = Enum.Font.GothamBold
		SubLoadTitle.TextXAlignment = Enum.TextXAlignment.Center
		SubLoadTitle.Parent = LoadFrame

		local StatusLabel = Instance.new("TextLabel")
		StatusLabel.Size = UDim2.new(0, 200, 0, 16)
		StatusLabel.Position = UDim2.new(0, 30, 0, 148)
		StatusLabel.BackgroundTransparency = 1
		StatusLabel.Text = "Loading Universal UI..."
		StatusLabel.TextColor3 = Color3.fromRGB(160, 150, 160)
		StatusLabel.TextSize = 11
		StatusLabel.Font = Enum.Font.GothamMedium
		StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
		StatusLabel.Parent = LoadFrame

		local PercentLabel = Instance.new("TextLabel")
		PercentLabel.Size = UDim2.new(0, 60, 0, 16)
		PercentLabel.Position = UDim2.new(1, -90, 0, 148)
		PercentLabel.BackgroundTransparency = 1
		PercentLabel.Text = "0%"
		PercentLabel.TextColor3 = Color3.fromRGB(220, 60, 80)
		PercentLabel.TextSize = 11
		PercentLabel.Font = Enum.Font.GothamBold
		PercentLabel.TextXAlignment = Enum.TextXAlignment.Right
		PercentLabel.Parent = LoadFrame

		local BarBg = Instance.new("Frame")
		BarBg.Size = UDim2.new(1, -60, 0, 6)
		BarBg.Position = UDim2.new(0, 30, 0, 168)
		BarBg.BackgroundColor3 = Color3.fromRGB(35, 30, 38)
		BarBg.BorderSizePixel = 0
		BarBg.Parent = LoadFrame

		local BarBgCorner = Instance.new("UICorner")
		BarBgCorner.CornerRadius = UDim.new(1, 0)
		BarBgCorner.Parent = BarBg

		local BarFill = Instance.new("Frame")
		BarFill.Size = UDim2.new(0, 0, 1, 0)
		BarFill.BackgroundColor3 = Color3.fromRGB(220, 30, 60)
		BarFill.BorderSizePixel = 0
		BarFill.Parent = BarBg

		local BarFillCorner = Instance.new("UICorner")
		BarFillCorner.CornerRadius = UDim.new(1, 0)
		BarFillCorner.Parent = BarFill

		-- Changed footer text requested
		local FooterLabel = Instance.new("TextLabel")
		FooterLabel.Size = UDim2.new(1, 0, 0, 14)
		FooterLabel.Position = UDim2.new(0, 0, 0, 198)
		FooterLabel.BackgroundTransparency = 1
		FooterLabel.Text = "Secure Boot | System"
		FooterLabel.TextColor3 = Color3.fromRGB(90, 85, 95)
		FooterLabel.TextSize = 9
		FooterLabel.Font = Enum.Font.GothamBold
		FooterLabel.TextXAlignment = Enum.TextXAlignment.Center
		FooterLabel.Parent = LoadFrame

		task.spawn(function()
			for i = 1, 100 do
				BarFill.Size = UDim2.new(i / 100, 0, 1, 0)
				PercentLabel.Text = i .. "%"
				if i == 100 then
					StatusLabel.Text = "Ready!"
				end
				task.wait(0.015)
			end
			task.wait(0.2)
			TweenService:Create(LoadFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
			task.wait(0.3)
			LoadGui:Destroy()
			Main.Visible = true -- Show main UI after loading screen finishes
		end)
	end)

	-- Topbar / Header
	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 50)
	Topbar.BackgroundTransparency = 1
	Topbar.Parent = Main

	if iconId ~= "" then
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
	else
		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Size = UDim2.new(0, 200, 0, 20)
		TitleLabel.Position = UDim2.new(0, 16, 0, 8)
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Text = titleText
		TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TitleLabel.TextSize = 16
		TitleLabel.Font = Enum.Font.GothamBold
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.Parent = Topbar

		local SubTitleLabel = Instance.new("TextLabel")
		SubTitleLabel.Size = UDim2.new(0, 200, 0, 14)
		SubTitleLabel.Position = UDim2.new(0, 16, 0, 26)
		SubTitleLabel.BackgroundTransparency = 1
		SubTitleLabel.Text = subText
		SubTitleLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
		SubTitleLabel.TextSize = 11
		SubTitleLabel.Font = Enum.Font.GothamMedium
		SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		SubTitleLabel.Parent = Topbar
	end

	-- Movable Mini Stats Widget with Double Outline (White inner, Black outer) & Shiny Reflection
	local StatsFrameOuter = Instance.new("Frame")
	StatsFrameOuter.Size = UDim2.new(0, 246, 0, 34)
	StatsFrameOuter.Position = UDim2.new(1, -300, 0, 8)
	StatsFrameOuter.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Super tiny black outer outline base
	StatsFrameOuter.BorderSizePixel = 0
	StatsFrameOuter.Parent = ScreenGui

	local OuterCorner = Instance.new("UICorner")
	OuterCorner.CornerRadius = UDim.new(0, 8)
	OuterCorner.Parent = StatsFrameOuter

	local StatsFrameInner = Instance.new("Frame")
	StatsFrameInner.Size = UDim2.new(1, -2, 1, -2)
	StatsFrameInner.Position = UDim2.new(0, 1, 0, 1)
	StatsFrameInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Tiny white outline base
	StatsFrameInner.BorderSizePixel = 0
	StatsFrameInner.Parent = StatsFrameOuter

	local InnerCorner = Instance.new("UICorner")
	InnerCorner.CornerRadius = UDim.new(0, 7)
	InnerCorner.Parent = StatsFrameInner

	local StatsFrame = Instance.new("Frame")
	StatsFrame.Size = UDim2.new(1, -4, 1, -4)
	StatsFrame.Position = UDim2.new(0, 2, 0, 2)
	StatsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	StatsFrame.BorderSizePixel = 0
	StatsFrame.Parent = StatsFrameOuter

	local StatsCorner = Instance.new("UICorner")
	StatsCorner.CornerRadius = UDim.new(0, 6)
	StatsCorner.Parent = StatsFrame

	makeDraggable(StatsFrameOuter, StatsFrameOuter)

	-- Mini-stats shiny reflection effect
	local StatsShiny = Instance.new("Frame")
	StatsShiny.Size = UDim2.new(0, 60, 2, 0)
	StatsShiny.Position = UDim2.new(-0.5, 0, -0.5, 0)
	StatsShiny.Rotation = 30
	StatsShiny.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	StatsShiny.BackgroundTransparency = 0.92
	StatsShiny.BorderSizePixel = 0
	StatsShiny.ClipsDescendants = true
	StatsShiny.Parent = StatsFrame

	local StatsShinyGrad = Instance.new("UIGradient")
	StatsShinyGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.7),
		NumberSequenceKeypoint.new(1, 1)
	})
	StatsShinyGrad.Parent = StatsShiny

	task.spawn(function()
		while StatsFrameOuter and StatsFrameOuter.Parent do
			StatsShiny.Position = UDim2.new(-0.5, 0, -0.5, 0)
			TweenService:Create(StatsShiny, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(1.3, 0, -0.5, 0)}):Play()
			task.wait(6)
		end
	end)

	-- Player Headshot Renderer Fix
	local HeadshotImg = Instance.new("ImageLabel")
	HeadshotImg.Size = UDim2.new(0, 22, 0, 22)
	HeadshotImg.Position = UDim2.new(0, 6, 0.5, -11)
	HeadshotImg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	HeadshotImg.Image = ""
	HeadshotImg.Parent = StatsFrame

	local HeadCorner = Instance.new("UICorner")
	HeadCorner.CornerRadius = UDim.new(1, 0)
	HeadCorner.Parent = HeadshotImg

	task.spawn(function()
		pcall(function()
			local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size42x42)
			if content then
				HeadshotImg.Image = content
			end
		end)
	end)

	local StatsContainer = Instance.new("Frame")
	StatsContainer.Size = UDim2.new(1, -32, 1, 0)
	StatsContainer.Position = UDim2.new(0, 32, 0, 0)
	StatsContainer.BackgroundTransparency = 1
	StatsContainer.Parent = StatsFrame

	local StatsLayout = Instance.new("UIListLayout")
	StatsLayout.FillDirection = Enum.FillDirection.Horizontal
	StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	StatsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	StatsLayout.Padding = UDim.new(0, 8)
	StatsLayout.Parent = StatsContainer

	local function createStatLabel(text)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 60, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
		lbl.TextSize = 10
		lbl.Font = Enum.Font.GothamMedium
		lbl.Parent = StatsContainer
		return lbl
	end

	local PingLabel = createStatLabel("32 ms")
	local FpsLabel = createStatLabel("60 fps")
	local PlayersLabel = createStatLabel("12 players")

	task.spawn(function()
		local lastUpdate = 0
		RunService.RenderStepped:Connect(function(dt)
			lastUpdate += dt
			if lastUpdate >= 1 then
				lastUpdate = 0
				local ping = 0
				pcall(function()
					ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
				end)
				PingLabel.Text = ping .. " ms"
				FpsLabel.Text = math.floor(1 / dt) .. " fps"
				PlayersLabel.Text = #Players:GetPlayers() .. " players"
			end
		end)
	end)

	-- Window Control (Close)
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
	CloseCorner.CornerRadius = UDim.new(0, 6)
	CloseCorner.Parent = CloseBtn

	CloseBtn.MouseButton1Click:Connect(function()
		pcall(function() ScreenGui:Destroy() end)
	end)

	-- Make entire main window movable from the Topbar header
	makeDraggable(Topbar, Main)

	-- Sidebar Tab Container
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(0, 140, 1, -60)
	TabContainer.Position = UDim2.new(0, 12, 0, 52)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 0
	TabContainer.Parent = Main

	local TabList = Instance.new("UIListLayout")
	TabList.Padding = UDim.new(0, 5)
	TabList.Parent = TabContainer

	local PagesHolder = Instance.new("Frame")
	PagesHolder.Name = "PagesHolder"
	PagesHolder.Size = UDim2.new(1, -170, 1, -60)
	PagesHolder.Position = UDim2.new(0, 160, 0, 52)
	PagesHolder.BackgroundTransparency = 1
	PagesHolder.Parent = Main

	local tabs = {}
	local firstTab = true

	function window:CreateTab(tabName)
		local tab = {}
		pcall(function()
			local TabBtn = Instance.new("TextButton")
			TabBtn.Size = UDim2.new(1, 0, 0, 34)
			TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
			TabBtn.Text = "   " .. tostring(tabName)
			TabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
			TabBtn.Font = Enum.Font.GothamMedium
			TabBtn.TextSize = 12
			TabBtn.TextXAlignment = Enum.TextXAlignment.Left
			TabBtn.Parent = TabContainer

			local TabCorner = Instance.new("UICorner")
			TabCorner.CornerRadius = UDim.new(0, 7)
			TabCorner.Parent = TabBtn

			local Page = Instance.new("ScrollingFrame")
			Page.Name = tostring(tabName) .. "Page"
			Page.Size = UDim2.new(1, 0, 1, 0)
			Page.BackgroundTransparency = 1
			Page.ScrollBarThickness = 3
			Page.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
			Page.Visible = false
			Page.Parent = PagesHolder

			local LeftCol = Instance.new("ScrollingFrame")
			LeftCol.Size = UDim2.new(0.5, -5, 1, 0)
			LeftCol.BackgroundTransparency = 1
			LeftCol.ScrollBarThickness = 0
			LeftCol.Parent = Page

			local LeftLayout = Instance.new("UIListLayout")
			LeftLayout.Padding = UDim.new(0, 8)
			LeftLayout.Parent = LeftCol

			local RightCol = Instance.new("ScrollingFrame")
			RightCol.Size = UDim2.new(0.5, -5, 1, 0)
			RightCol.Position = UDim2.new(0.5, 5, 0, 0)
			RightCol.BackgroundTransparency = 1
			RightCol.ScrollBarThickness = 0
			RightCol.Parent = Page

			local RightLayout = Instance.new("UIListLayout")
			RightLayout.Padding = UDim.new(0, 8)
			RightLayout.Parent = RightCol

			if firstTab then
				Page.Visible = true
				TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
				TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				firstTab = false
			end

			TabBtn.MouseButton1Click:Connect(function()
				playSound("rbxassetid://122966251252708", soundEnabled)
				for _, t in pairs(tabs) do
					pcall(function()
						t.Page.Visible = false
						TweenService:Create(t.Button, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(22, 22, 26), TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
					end)
				end
				Page.Visible = true
				TweenService:Create(TabBtn, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(28, 28, 34), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end)

			table.insert(tabs, {Button = TabBtn, Page = Page})

			function tab:CreateSection(columnSide, sectionTitle)
				local section = {}
				pcall(function()
					local targetCol = (tostring(columnSide):lower() == "right") and RightCol or LeftCol

					local SectionFrame = Instance.new("Frame")
					SectionFrame.Size = UDim2.new(1, 0, 0, 100)
					SectionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
					SectionFrame.BorderSizePixel = 0
					SectionFrame.Parent = targetCol

					local SecCorner = Instance.new("UICorner")
					SecCorner.CornerRadius = UDim.new(0, 7)
					SecCorner.Parent = SectionFrame

					local SecTitle = Instance.new("TextLabel")
					SecTitle.Size = UDim2.new(1, -16, 0, 26)
					SecTitle.Position = UDim2.new(0, 10, 0, 0)
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
						SectionFrame.Size = UDim2.new(1, 0, 0, InnerList.AbsoluteContentSize.Y + 12)
					end)

					function section:CreateToggle(name, desc, default, callback)
						pcall(function()
							local state = default or false

							local ToggleItem = Instance.new("Frame")
							ToggleItem.Size = UDim2.new(1, -14, 0, desc and 38 or 28)
							ToggleItem.BackgroundTransparency = 1
							ToggleItem.Parent = SectionFrame

							local Label = Instance.new("TextLabel")
							Label.Size = UDim2.new(1, -50, 0, 16)
							Label.Position = UDim2.new(0, 6, 0, desc and 2 or 6)
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
								DescLabel.Position = UDim2.new(0, 6, 0, 18)
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
							ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(220, 30, 60) or Color3.fromRGB(45, 45, 52)
							ToggleBtn.Text = ""
							ToggleBtn.Parent = ToggleItem

							local BtnCorner = Instance.new("UICorner")
							BtnCorner.CornerRadius = UDim.new(1, 0)
							BtnCorner.Parent = ToggleBtn

							local Circle = Instance.new("Frame")
							Circle.Size = UDim2.new(0, 12, 0, 12)
							Circle.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
							Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							Circle.Parent = ToggleBtn

							local CircleCorner = Instance.new("UICorner")
							CircleCorner.CornerRadius = UDim.new(1, 0)
							CircleCorner.Parent = Circle

							ToggleBtn.MouseButton1Click:Connect(function()
								playSound("rbxassetid://75698187458888", soundEnabled)
								state = not state
								local targetPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
								local targetColor = state and Color3.fromRGB(220, 30, 60) or Color3.fromRGB(45, 45, 52)

								TweenService:Create(Circle, TWEEN_INFO, {Position = targetPos}):Play()
								TweenService:Create(ToggleBtn, TWEEN_INFO, {BackgroundColor3 = targetColor}):Play()
								if callback then pcall(callback, state) end
							end)
						end)
					end

					function section:CreateButton(name, callback)
						pcall(function()
							local Btn = Instance.new("TextButton")
							Btn.Size = UDim2.new(1, -14, 0, 28)
							Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
							Btn.Text = "  " .. tostring(name)
							Btn.TextColor3 = Color3.fromRGB(210, 210, 220)
							Btn.Font = Enum.Font.GothamMedium
							Btn.TextSize = 11
							Btn.TextXAlignment = Enum.TextXAlignment.Left
							Btn.Parent = SectionFrame

							local BtnCorner = Instance.new("UICorner")
							BtnCorner.CornerRadius = UDim.new(0, 5)
							BtnCorner.Parent = Btn

							Btn.MouseButton1Click:Connect(function()
								playSound("rbxassetid://122966251252708", soundEnabled)
								TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
								task.delay(0.1, function()
									TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}):Play()
								end)
								if callback then pcall(callback) end
							end)
						end)
					end
				end)
				return section
			end
		end)
		return tab
	end

	return window
end

return Library