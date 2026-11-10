-- SpawnRealm UI Library Module
local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Automatically detect running exploit executor name
local function getExecutorName()
	local success, name = pcall(function()
		return identifyexecutor and identifyexecutor() or (syn and "Synapse" or (KRNL_LOADED and "Krnl" or (fluxus and "Fluxus" or "Delta")))
	end)
	return success and name or "Delta"
end

local function formatNumber(value)
	if not value then return "0" end
	if value >= 1e12 then
		return string.format("%.1fT", value / 1e12)
	elseif value >= 1e9 then
		return string.format("%.1fB", value / 1e9)
	elseif value >= 1e6 then
		return string.format("%.1fM", value / 1e6)
	elseif value >= 1e3 then
		return string.format("%.1fK", value / 1e3)
	else
		return tostring(value)
	end
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
	local formatted = str:lower():gsub("[^a-z]", "")
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
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "SR_MainGui"
	ScreenGui.Parent = getProtectedParent()
	ScreenGui.ResetOnSpawn = false

	local targetWidth = 682
	local targetHeight = 310

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 0, 0, 0)
	Main.Position = UDim2.new(0.5, 0, 0.45, 0)
	Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	Main.BackgroundTransparency = 1
	Main.BorderSizePixel = 0
	Main.Visible = true
	Main.Parent = ScreenGui

	task.spawn(function()
		task.wait(0.05)
		TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, targetWidth, 0, targetHeight),
			Position = UDim2.new(0.5, -targetWidth/2, 0.45, -targetHeight/2),
			BackgroundTransparency = 0
		}):Play()
	end)

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

	-- Minimized Floating Circle Toggle Button with Moving Gradient Outline
	local ToggleBtnOuter = Instance.new("Frame")
	ToggleBtnOuter.Name = "ToggleBtnOuter"
	ToggleBtnOuter.Size = UDim2.new(0, 44, 0, 44)
	ToggleBtnOuter.Position = UDim2.new(0, 40, 0, 200)
	ToggleBtnOuter.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	ToggleBtnOuter.BorderSizePixel = 0
	ToggleBtnOuter.Visible = false
	ToggleBtnOuter.ZIndex = 60
	ToggleBtnOuter.Parent = ScreenGui

	local TBtnOuterCorner = Instance.new("UICorner")
	TBtnOuterCorner.CornerRadius = UDim.new(1, 0)
	TBtnOuterCorner.Parent = ToggleBtnOuter

	local ToggleBtnStroke = Instance.new("UIStroke")
	ToggleBtnStroke.Thickness = 2.4
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
	ToggleBtn.ZIndex = 61
	ToggleBtn.Parent = ToggleBtnOuter

	makeDraggable(ToggleBtnOuter, ToggleBtnOuter)
	makeDraggable(ToggleBtn, ToggleBtnOuter)

	ToggleBtn.MouseButton1Click:Connect(function()
		playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
		Main.Visible = true
		Main.Size = UDim2.new(0, 0, 0, 0)
		Main.Position = UDim2.new(0.5, 0, 0.45, 0)
		Main.BackgroundTransparency = 1
		TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, targetWidth, 0, targetHeight),
			Position = UDim2.new(0.5, -targetWidth/2, 0.45, -targetHeight/2),
			BackgroundTransparency = 0
		}):Play()
		ToggleBtnOuter.Visible = false
	end)

	-- Bottom-Right Corner Resizing Handle
	local ResizeHandle = Instance.new("TextButton")
	ResizeHandle.Name = "ResizeHandle"
	ResizeHandle.Size = UDim2.new(0, 24, 0, 24)
	ResizeHandle.Position = UDim2.new(1, -24, 1, -24)
	ResizeHandle.BackgroundTransparency = 1
	ResizeHandle.Text = ""
	ResizeHandle.AutoButtonColor = false
	ResizeHandle.ZIndex = 30
	ResizeHandle.Parent = Main

	local ResizeVisual = Instance.new("Frame")
	ResizeVisual.Size = UDim2.new(0, 12, 0, 12)
	ResizeVisual.Position = UDim2.new(1, -16, 1, -16)
	ResizeVisual.BackgroundTransparency = 1
	ResizeVisual.ZIndex = 31
	ResizeVisual.Parent = ResizeHandle

	for i = 0, 2 do
		local line = Instance.new("Frame")
		line.Size = UDim2.new(0, 2 + (i * 3), 0, 2)
		line.Position = UDim2.new(1, -2 - (i * 4), 1, -2 - (i * 4))
		line.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
		line.BackgroundTransparency = 0.4
		line.BorderSizePixel = 0
		line.ZIndex = 32
		line.Parent = ResizeVisual

		local lCorner = Instance.new("UICorner")
		lCorner.CornerRadius = UDim.new(1, 0)
		lCorner.Parent = line
	end

	local resizing, resizeStart, startSize = false, nil, nil
	ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			resizeStart = input.Position
			startSize = Main.AbsoluteSize
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - resizeStart
			local newW = math.clamp(startSize.X + delta.X, 480, 1200)
			local newH = math.clamp(startSize.Y + delta.Y, 220, 800)
			Main.Size = UDim2.new(0, newW, 0, newH)
		end
	end)

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
	TitleLabel.Name = "TitleLabel"
	TitleLabel.Size = UDim2.new(0, 0, 0, 20)
	TitleLabel.AutomaticSize = Enum.AutomaticSize.X
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

	local WindowTagsContainer = Instance.new("Frame")
	WindowTagsContainer.Name = "WindowTagsContainer"
	WindowTagsContainer.Size = UDim2.new(0, 400, 0, 24)
	WindowTagsContainer.Position = UDim2.new(0, 195, 0, 6)
	WindowTagsContainer.BackgroundTransparency = 1
	WindowTagsContainer.ZIndex = 15
	WindowTagsContainer.Parent = Topbar

	local WindowTagsLayout = Instance.new("UIListLayout")
	WindowTagsLayout.FillDirection = Enum.FillDirection.Horizontal
	WindowTagsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	WindowTagsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	WindowTagsLayout.Padding = UDim.new(0, 6)
	WindowTagsLayout.Parent = WindowTagsContainer

	function window:Tag(tagConfig)
		tagConfig = tagConfig or {}
		local tText = tagConfig.Title or tagConfig.title or "Tag"
		local tIcon = getIconAsset(tagConfig.Icon or tagConfig.icon)
		local tTextColor = tagConfig.TextColor or tagConfig.textColor or Color3.fromRGB(255, 255, 255)
		local tBgColor = tagConfig.BackgroundColor or tagConfig.backgroundColor or Color3.fromRGB(45, 45, 55)

		pcall(function()
			local tagPill = Instance.new("Frame")
			tagPill.Size = UDim2.new(0, 0, 0, 22)
			tagPill.AutomaticSize = Enum.AutomaticSize.X
			tagPill.BackgroundColor3 = tBgColor
			tagPill.BorderSizePixel = 0
			tagPill.ZIndex = 16
			tagPill.Parent = WindowTagsContainer

			local tCorner = Instance.new("UICorner")
			tCorner.CornerRadius = UDim.new(1, 0)
			tCorner.Parent = tagPill

			local pad = Instance.new("UIPadding")
			pad.PaddingLeft = UDim.new(0, tIcon ~= "" and 6 or 10)
			pad.PaddingRight = UDim.new(0, 10)
			pad.Parent = tagPill

			local layout = Instance.new("UIListLayout")
			layout.FillDirection = Enum.FillDirection.Horizontal
			layout.VerticalAlignment = Enum.VerticalAlignment.Center
			layout.Padding = UDim.new(0, 4)
			layout.Parent = tagPill

			if tIcon ~= "" then
				local img = Instance.new("ImageLabel")
				img.Size = UDim2.new(0, 12, 0, 12)
				img.BackgroundTransparency = 1
				img.Image = tIcon
				img.ImageColor3 = tTextColor
				img.ZIndex = 17
				img.Parent = tagPill
			end

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(0, 0, 1, 0)
			lbl.AutomaticSize = Enum.AutomaticSize.X
			lbl.BackgroundTransparency = 1
			lbl.Text = tText
			lbl.TextColor3 = tTextColor
			lbl.TextSize = 10
			lbl.Font = Enum.Font.GothamBold
			lbl.ZIndex = 17
			lbl.Parent = tagPill
		end)
	end

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
		playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
		TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.45, 0),
			BackgroundTransparency = 1
		}):Play()
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
		task.wait(0.25)
		Main.Visible = false
		if ToggleBtnOuter then ToggleBtnOuter.Visible = true end
	end)

	makeDraggable(Topbar, Main)

	-- 1. Tapable Interactive Profile & Stats Pill (Top-Middle) with Moving Outline
	local WavesStatsFrame = nil
	local OnlineCardLbl = nil
	local FpsCardLbl = nil
	local PingCardLbl = nil
	local PlrCardLbl = nil
	local waveBar1, waveBar2, waveBar3 = nil, nil, nil

	if pillUIWavesEnabled then
		WavesStatsFrame = Instance.new("TextButton")
		WavesStatsFrame.Name = "WavesStatsFrame"
		WavesStatsFrame.Size = UDim2.new(0, 185, 0, 34)
		WavesStatsFrame.Position = UDim2.new(0.5, -92, 0, 8)
		WavesStatsFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
		WavesStatsFrame.BackgroundTransparency = loadingXUIEnabled and 1 or 0
		WavesStatsFrame.BorderSizePixel = 0
		WavesStatsFrame.AutoButtonColor = false
		WavesStatsFrame.Text = ""
		WavesStatsFrame.Visible = not loadingXUIEnabled
		WavesStatsFrame.ClipsDescendants = true
		WavesStatsFrame.ZIndex = 50
		WavesStatsFrame.Parent = ScreenGui

		local WStatsCorner = Instance.new("UICorner")
		WStatsCorner.CornerRadius = UDim.new(0, 18)
		WStatsCorner.Parent = WavesStatsFrame

		local WStatsStroke = Instance.new("UIStroke")
		WStatsStroke.Thickness = 2.4
		WStatsStroke.Parent = WavesStatsFrame

		local WStatsStrokeGrad = Instance.new("UIGradient")
		WStatsStrokeGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.15, 0.1),
			NumberSequenceKeypoint.new(0.35, 0.9),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(0.65, 0.9),
			NumberSequenceKeypoint.new(0.85, 0.1),
			NumberSequenceKeypoint.new(1, 0)
		})
		WStatsStrokeGrad.Parent = WStatsStroke

		task.spawn(function()
			while WStatsStrokeGrad and WStatsStrokeGrad.Parent do
				TweenService:Create(WStatsStrokeGrad, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {Rotation = WStatsStrokeGrad.Rotation + 360}):Play()
				task.wait(2.8)
			end
		end)

		local CollapsedContainer = Instance.new("Frame")
		CollapsedContainer.Name = "CollapsedContainer"
		CollapsedContainer.Size = UDim2.new(1, 0, 0, 34)
		CollapsedContainer.BackgroundTransparency = 1
		CollapsedContainer.ZIndex = 51
		CollapsedContainer.Parent = WavesStatsFrame

		local RadarContainer = Instance.new("Frame")
		RadarContainer.Size = UDim2.new(0, 20, 0, 20)
		RadarContainer.Position = UDim2.new(0, 8, 0.5, -10)
		RadarContainer.BackgroundTransparency = 1
		RadarContainer.ClipsDescendants = false
		RadarContainer.ZIndex = 52
		RadarContainer.Parent = CollapsedContainer

		local PingDot = Instance.new("Frame")
		PingDot.Size = UDim2.new(0, 8, 0, 8)
		PingDot.Position = UDim2.new(0.5, -4, 0.5, -4)
		PingDot.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
		PingDot.BorderSizePixel = 0
		PingDot.ZIndex = 53
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
					ring.ZIndex = 52
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
		CenterContent.ZIndex = 52
		CenterContent.Parent = CollapsedContainer

		local CenterIcon = Instance.new("ImageLabel")
		CenterIcon.Size = UDim2.new(0, 13, 0, 13)
		CenterIcon.Position = UDim2.new(0, 0, 0.5, -6.5)
		CenterIcon.BackgroundTransparency = 1
		CenterIcon.Image = iconId
		CenterIcon.ZIndex = 53
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
		CenterTitle.ZIndex = 53
		CenterTitle.Parent = CenterContent

		local WaveContainer = Instance.new("Frame")
		WaveContainer.Size = UDim2.new(0, 22, 0, 16)
		WaveContainer.Position = UDim2.new(1, -26, 0.5, -8)
		WaveContainer.BackgroundTransparency = 1
		WaveContainer.ZIndex = 52
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
			bar.ZIndex = 53
			bar.Parent = WaveContainer

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(1, 0)
			bCorner.Parent = bar
			return bar
		end

		waveBar1 = createWaveBar()
		waveBar2 = createWaveBar()
		waveBar3 = createWaveBar()

		local ExpandedContainer = Instance.new("Frame")
		ExpandedContainer.Name = "ExpandedContainer"
		ExpandedContainer.Size = UDim2.new(1, 0, 0, 136)
		ExpandedContainer.Position = UDim2.new(0, 0, 0, 34)
		ExpandedContainer.BackgroundTransparency = 1
		ExpandedContainer.Visible = false
		ExpandedContainer.ZIndex = 51
		ExpandedContainer.Parent = WavesStatsFrame

		local AvatarImg = Instance.new("ImageLabel")
		AvatarImg.Size = UDim2.new(0, 34, 0, 34)
		AvatarImg.Position = UDim2.new(0, 12, 0, 4)
		AvatarImg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		AvatarImg.BorderSizePixel = 0
		AvatarImg.ZIndex = 52
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
		DisplayNameLbl.Size = UDim2.new(1, -125, 0, 16)
		DisplayNameLbl.Position = UDim2.new(0, 54, 0, 4)
		DisplayNameLbl.BackgroundTransparency = 1
		DisplayNameLbl.Text = LocalPlayer.DisplayName
		DisplayNameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		DisplayNameLbl.TextSize = 11
		DisplayNameLbl.Font = Enum.Font.GothamBold
		DisplayNameLbl.TextXAlignment = Enum.TextXAlignment.Left
		DisplayNameLbl.ZIndex = 52
		DisplayNameLbl.Parent = ExpandedContainer

		local execName = getExecutorName()
		local gameName = "Just a baseplate"
		pcall(function()
			local info = MarketplaceService:GetProductInfo(game.PlaceId)
			if info and info.Name then gameName = info.Name end
		end)

		local SubInfoLbl = Instance.new("TextLabel")
		SubInfoLbl.Size = UDim2.new(1, -125, 0, 20)
		SubInfoLbl.Position = UDim2.new(0, 54, 0, 20)
		SubInfoLbl.BackgroundTransparency = 1
		SubInfoLbl.Text = "@" .. LocalPlayer.Name .. " • " .. execName .. "\n" .. gameName
		SubInfoLbl.TextColor3 = Color3.fromRGB(150, 150, 165)
		SubInfoLbl.TextSize = 8.5
		SubInfoLbl.Font = Enum.Font.GothamMedium
		SubInfoLbl.TextXAlignment = Enum.TextXAlignment.Left
		SubInfoLbl.ZIndex = 52
		SubInfoLbl.Parent = ExpandedContainer

		local TimerPill = Instance.new("Frame")
		TimerPill.Size = UDim2.new(0, 60, 0, 20)
		TimerPill.Position = UDim2.new(1, -70, 0, 6)
		TimerPill.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
		TimerPill.BorderSizePixel = 0
		TimerPill.ZIndex = 52
		TimerPill.Parent = ExpandedContainer

		local TimerCorner = Instance.new("UICorner")
		TimerCorner.CornerRadius = UDim.new(0, 10)
		TimerCorner.Parent = TimerPill

		local TimerLbl = Instance.new("TextLabel")
		TimerLbl.Size = UDim2.new(1, 0, 1, 0)
		TimerLbl.BackgroundTransparency = 1
		TimerLbl.Text = "0m 0s"
		TimerLbl.TextColor3 = Color3.fromRGB(210, 210, 220)
		TimerLbl.TextSize = 8.5
		TimerLbl.Font = Enum.Font.GothamBold
		TimerLbl.ZIndex = 53
		TimerLbl.Parent = TimerPill

		local startTime = tick()
		task.spawn(function()
			while true do
				task.wait(1)
				local elapsed = math.floor(tick() - startTime)
				TimerLbl.Text = string.format("%dm %ds", math.floor(elapsed / 60), elapsed % 60)
			end
		end)

		local CardsHolder = Instance.new("Frame")
		CardsHolder.Size = UDim2.new(1, -16, 0, 58)
		CardsHolder.Position = UDim2.new(0, 8, 0, 44)
		CardsHolder.BackgroundTransparency = 1
		CardsHolder.ZIndex = 52
		CardsHolder.Parent = ExpandedContainer

		local function createStatCard(posX, iconName, labelName, defaultVal)
			local card = Instance.new("Frame")
			card.Size = UDim2.new(0.5, -4, 0, 26)
			card.Position = posX
			card.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
			card.BorderSizePixel = 0
			card.ZIndex = 53
			card.Parent = CardsHolder

			local cCorner = Instance.new("UICorner")
			cCorner.CornerRadius = UDim.new(0, 8)
			cCorner.Parent = card

			local icon = Instance.new("ImageLabel")
			icon.Size = UDim2.new(0, 11, 0, 11)
			icon.Position = UDim2.new(0, 6, 0.5, -5.5)
			icon.BackgroundTransparency = 1
			icon.Image = getIconAsset(iconName)
			icon.ImageColor3 = Color3.fromRGB(160, 160, 175)
			icon.ZIndex = 54
			icon.Parent = card

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -22, 1, 0)
			lbl.Position = UDim2.new(0, 22, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = labelName .. " " .. defaultVal
			lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
			lbl.TextSize = 9.5
			lbl.Font = Enum.Font.GothamMedium
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.ZIndex = 54
			lbl.Parent = card
			return lbl
		end

		FpsCardLbl = createStatCard(UDim2.new(0, 0, 0, 0), "cpu", "FPS", "60")
		PingCardLbl = createStatCard(UDim2.new(0.5, 4, 0, 0), "zap", "Ping", "35 ms")
		PlrCardLbl = createStatCard(UDim2.new(0, 0, 0, 30), "users", "Players", "4")
		OnlineCardLbl = createStatCard(UDim2.new(0.5, 4, 0, 30), "users", "Active", "0")

		-- Universe Active Players Count
		task.spawn(function()
			while true do
				pcall(function()
					local activeCount = 0
					local success, result = pcall(function()
						return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games?universeIds=" .. tostring(game.GameId)))
					end)
					if success and result and result.data and result.data[1] and result.data[1].playing then
						activeCount = result.data[1].playing
					else
						activeCount = #Players:GetPlayers() * 12
					end
					OnlineCardLbl.Text = "Active " .. formatNumber(activeCount)
				end)
				task.wait(10)
			end
		end)

		local RestoreBtn = Instance.new("TextButton")
		RestoreBtn.Size = UDim2.new(1, -16, 0, 26)
		RestoreBtn.Position = UDim2.new(0, 8, 0, 106)
		RestoreBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
		RestoreBtn.BorderSizePixel = 0
		RestoreBtn.AutoButtonColor = false
		RestoreBtn.Text = "> Restore Window"
		RestoreBtn.TextColor3 = Color3.fromRGB(210, 210, 220)
		RestoreBtn.TextSize = 9.5
		RestoreBtn.Font = Enum.Font.GothamBold
		RestoreBtn.ZIndex = 53
		RestoreBtn.Parent = ExpandedContainer

		local RestoreCorner = Instance.new("UICorner")
		RestoreCorner.CornerRadius = UDim.new(0, 8)
		RestoreCorner.Parent = RestoreBtn

		local isExpanded = false
		local function collapsePill()
			if not isExpanded then return end
			isExpanded = false
			ExpandedContainer.Visible = false
			CollapsedContainer.Visible = true
			TweenService:Create(WavesStatsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 185, 0, 34)
			}):Play()
		end

		local function expandPill()
			if isExpanded then return end
			isExpanded = true
			CollapsedContainer.Visible = false
			ExpandedContainer.Visible = true
			TweenService:Create(WavesStatsFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 260, 0, 140)
			}):Play()
		end

		WavesStatsFrame.MouseButton1Click:Connect(function()
			playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
			if isExpanded then collapsePill() else expandPill() end
		end)

		RestoreBtn.MouseButton1Click:Connect(function()
			playSound("rbxassetid://122966251252708", soundEnabled, 2.0)
			collapsePill()
			Main.Visible = true
			Main.Size = UDim2.new(0, targetWidth, 0, targetHeight)
			Main.Position = UDim2.new(0.5, -targetWidth/2, 0.45, -targetHeight/2)
			Main.BackgroundTransparency = 0
			WavesStatsFrame.Size = UDim2.new(0, 185, 0, 34)
			WavesStatsFrame.Position = UDim2.new(0.5, -92, 0, 8)
			WavesStatsFrame.Visible = true
		end)

		makeDraggable(WavesStatsFrame, WavesStatsFrame)
	end

	-- 2. Top-Right Mini Stats Pill (MS, FPS, PLAYERS) with Moving Outline
	local StatsFrame = nil
	local PingLabel, FpsLabel, PlayersLabel = nil, nil, nil

	if pillUIFPSEnabled then
		StatsFrame = Instance.new("Frame")
		StatsFrame.Name = "StatsFrame"
		StatsFrame.Size = UDim2.new(0, 230, 0, 32)
		StatsFrame.Position = UDim2.new(1, -242, 0, 8)
		StatsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
		StatsFrame.BackgroundTransparency = loadingXUIEnabled and 1 or 0
		StatsFrame.BorderSizePixel = 0
		StatsFrame.Visible = not loadingXUIEnabled
		StatsFrame.ZIndex = 50
		StatsFrame.Parent = ScreenGui

		local StatsCorner = Instance.new("UICorner")
		StatsCorner.CornerRadius = UDim.new(0, 30)
		StatsCorner.Parent = StatsFrame

		local StatsStroke = Instance.new("UIStroke")
		StatsStroke.Thickness = 2.4
		StatsStroke.Parent = StatsFrame

		local StatsStrokeGrad = Instance.new("UIGradient")
		StatsStrokeGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.15, 0.1),
			NumberSequenceKeypoint.new(0.35, 0.9),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(0.65, 0.9),
			NumberSequenceKeypoint.new(0.85, 0.1),
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
		HeadshotImg.ZIndex = 51
		HeadshotImg.Parent = StatsFrame

		local HeadCorner = Instance.new("UICorner")
		HeadCorner.CornerRadius = UDim.new(1, 0)
		HeadCorner.Parent = HeadshotImg

		task.spawn(function()
			pcall(function()
				HeadshotImg.Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150", LocalPlayer.UserId)
			end)
		end)

		local StatsContainer = Instance.new("Frame")
		StatsContainer.Size = UDim2.new(1, -30, 1, 0)
		StatsContainer.Position = UDim2.new(0, 30, 0, 0)
		StatsContainer.BackgroundTransparency = 1
		StatsContainer.ZIndex = 51
		StatsContainer.Parent = StatsFrame

		local StatsLayout = Instance.new("UIListLayout")
		StatsLayout.FillDirection = Enum.FillDirection.Horizontal
		StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		StatsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		StatsLayout.Padding = UDim.new(0, 4)
		StatsLayout.Parent = StatsContainer

		local function createStatBadge(iconId, labelName, defaultVal)
			local holder = Instance.new("Frame")
			holder.Size = UDim2.new(0, 62, 1, 0)
			holder.BackgroundTransparency = 1
			holder.ZIndex = 51
			holder.Parent = StatsContainer

			local icon = Instance.new("ImageLabel")
			icon.Size = UDim2.new(0, 11, 0, 11)
			icon.Position = UDim2.new(0, 0, 0.5, -5.5)
			icon.BackgroundTransparency = 1
			icon.Image = getIconAsset(iconId)
			icon.ImageColor3 = Color3.fromRGB(160, 160, 175)
			icon.ZIndex = 52
			icon.Parent = holder

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -13, 1, 0)
			lbl.Position = UDim2.new(0, 13, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = defaultVal .. " " .. labelName
			lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
			lbl.TextSize = 8
			lbl.Font = Enum.Font.GothamMedium
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.ZIndex = 52
			lbl.Parent = holder
			return lbl
		end

		PingLabel = createStatBadge("zap", "MS", "32")
		FpsLabel = createStatBadge("cpu", "FPS", "60")
		PlayersLabel = createStatBadge("users", "PLAYERS", "12")

		makeDraggable(StatsFrame, StatsFrame)
	end

	-- Stable FPS & Ping Tracker Loop
	local frameCount = 0
	local fpsTimer = 0
	local currentFps = 60

	RunService.RenderStepped:Connect(function(dt)
		pcall(function()
			fpsTimer = fpsTimer + dt
			frameCount = frameCount + 1
			if fpsTimer >= 0.5 then
				currentFps = math.floor((frameCount / fpsTimer) + 0.5)
				frameCount = 0
				fpsTimer = 0
			end

			local ping = 0
			pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)

			if FpsLabel then FpsLabel.Text = currentFps .. " FPS" end
			if PingLabel then PingLabel.Text = ping .. " MS" end
			if PlayersLabel then PlayersLabel.Text = #Players:GetPlayers() .. " PLAYERS" end

			if FpsCardLbl then FpsCardLbl.Text = "FPS " .. currentFps end
			if PingCardLbl then PingCardLbl.Text = "Ping " .. ping .. " ms" end
			if PlrCardLbl then PlrCardLbl.Text = "Players " .. #Players:GetPlayers() end

			if waveBar1 and waveBar2 and waveBar3 then
				local t = tick() * 6
				waveBar1.Size = UDim2.new(0, 4, 0, math.clamp(math.floor(8 + math.sin(t) * 5), 4, 16))
				waveBar2.Size = UDim2.new(0, 4, 0, math.clamp(math.floor(8 + math.cos(t * 1.2) * 6), 4, 16))
				waveBar3.Size = UDim2.new(0, 4, 0, math.clamp(math.floor(8 + math.sin(t * 0.8) * 5), 4, 16))
			end
		end)
	end)

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
		SearchIcon.Parent = SearchBox

		local SearchPadding = Instance.new("UIPadding")
		SearchPadding.PaddingLeft = UDim.new(0, 28)
		SearchPadding.Parent = SearchBox
	end
	
	local tabYOffset = searchBarEnabled and 84 or 52
	local tabBottomOffset = (userConfig and userConfig.Enabled ~= false) and (searchBarEnabled and -155 or -120) or (searchBarEnabled and -88 or -55)

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(0, 155, 1, tabBottomOffset)
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

	-- Bottom-Left Profile Card Fix (Wider 155px container with non-overlapping text bounds)
	if userConfig and userConfig.Enabled ~= false then
		local isAnonymous = (userConfig.Anonymous == true)
		local ProfileCard = Instance.new("TextButton")
		ProfileCard.Name = "ProfileCard"
		ProfileCard.Size = UDim2.new(0, 155, 0, 56)
		ProfileCard.Position = UDim2.new(0, 12, 1, -64)
		ProfileCard.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
		ProfileCard.AutoButtonColor = false
		ProfileCard.Text = ""
		ProfileCard.Parent = Main

		local PCardCorner = Instance.new("UICorner")
		PCardCorner.CornerRadius = UDim.new(0, 28)
		PCardCorner.Parent = ProfileCard

		local AvatarImg = Instance.new("ImageLabel")
		AvatarImg.Size = UDim2.new(0, 36, 0, 36)
		AvatarImg.Position = UDim2.new(0, 10, 0.5, -18)
		AvatarImg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		AvatarImg.BorderSizePixel = 0
		AvatarImg.Parent = ProfileCard

		local AvatarCorner = Instance.new("UICorner")
		AvatarCorner.CornerRadius = UDim.new(0, 18)
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

		local NameLbl = Instance.new("TextLabel")
		NameLbl.Size = UDim2.new(1, -54, 0, 16)
		NameLbl.Position = UDim2.new(0, 52, 0, 11)
		NameLbl.BackgroundTransparency = 1
		NameLbl.Text = isAnonymous and "Anonymous" or LocalPlayer.Name
		NameLbl.TextColor3 = Color3.fromRGB(240, 240, 245)
		NameLbl.TextSize = 10.5
		NameLbl.Font = Enum.Font.GothamBold
		NameLbl.TextXAlignment = Enum.TextXAlignment.Left
		NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
		NameLbl.Parent = ProfileCard

		local HandleLbl = Instance.new("TextLabel")
		HandleLbl.Size = UDim2.new(1, -54, 0, 14)
		HandleLbl.Position = UDim2.new(0, 52, 0, 29)
		HandleLbl.BackgroundTransparency = 1
		HandleLbl.Text = isAnonymous and "Hidden" or ("@" .. LocalPlayer.Name)
		HandleLbl.TextColor3 = Color3.fromRGB(130, 130, 140)
		HandleLbl.TextSize = 8.5
		HandleLbl.Font = Enum.Font.GothamMedium
		HandleLbl.TextXAlignment = Enum.TextXAlignment.Left
		HandleLbl.TextTruncate = Enum.TextTruncate.AtEnd
		HandleLbl.Parent = ProfileCard

		ProfileCard.MouseButton1Click:Connect(function()
			playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
			if userConfig.Callback then pcall(userConfig.Callback) end
		end)
	end

	local PagesHolder = Instance.new("Frame")
	PagesHolder.Name = "PagesHolder"
	PagesHolder.Size = UDim2.new(1, -180, 1, -55)
	PagesHolder.Position = UDim2.new(0, 172, 0, 48)
	PagesHolder.BackgroundTransparency = 1
	PagesHolder.Parent = Main

	local tabs = {}
	local activeTabObject = nil

	function window:CreateTab(tabConfig)
		local tabObj = {}
		local TabBtn, Page, FlashlightBeam, GlowLine, DotContainer
		local hasTag = false
		
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
			TabText.Size = UDim2.new(1, tabIconId ~= "" and -45 or -20, 1, 0)
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

			local TabTagsHolder = Instance.new("Frame")
			TabTagsHolder.Size = UDim2.new(0, 50, 1, 0)
			TabTagsHolder.Position = UDim2.new(1, -55, 0, 0)
			TabTagsHolder.BackgroundTransparency = 1
			TabTagsHolder.ZIndex = 6
			TabTagsHolder.Parent = TabBtn

			local TabTagsLayout = Instance.new("UIListLayout")
			TabTagsLayout.FillDirection = Enum.FillDirection.Horizontal
			TabTagsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			TabTagsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			TabTagsLayout.Padding = UDim.new(0, 4)
			TabTagsLayout.Parent = TabTagsHolder

			function tabObj:Tag(tagConfig)
				if hasTag then
					print("[SpawnRealmX]: Tab tags have a limit of 1 per tab!")
					return
				end

				tagConfig = tagConfig or {}
				local tText = tagConfig.Title or tagConfig.title or "Beta"
				local tIcon = getIconAsset(tagConfig.Icon or tagConfig.icon)
				local tTextColor = tagConfig.TextColor or tagConfig.textColor or Color3.fromRGB(255, 255, 255)
				local tBgColor = tagConfig.BackgroundColor or tagConfig.backgroundColor or Color3.fromRGB(0, 162, 255)

				pcall(function()
					local tPill = Instance.new("Frame")
					tPill.Size = UDim2.new(0, 0, 0, 18)
					tPill.AutomaticSize = Enum.AutomaticSize.X
					tPill.BackgroundColor3 = tBgColor
					tPill.BorderSizePixel = 0
					tPill.ZIndex = 7
					tPill.Parent = TabTagsHolder

					local c = Instance.new("UICorner")
					c.CornerRadius = UDim.new(1, 0)
					c.Parent = tPill

					local pad = Instance.new("UIPadding")
					pad.PaddingLeft = UDim.new(0, tIcon ~= "" and 4 or 6)
					pad.PaddingRight = UDim.new(0, 6)
					pad.Parent = tPill

					local l = Instance.new("UIListLayout")
					l.FillDirection = Enum.FillDirection.Horizontal
					l.VerticalAlignment = Enum.VerticalAlignment.Center
					l.Padding = UDim.new(0, 3)
					l.Parent = tPill

					if tIcon ~= "" then
						local img = Instance.new("ImageLabel")
						img.Size = UDim2.new(0, 10, 0, 10)
						img.BackgroundTransparency = 1
						img.Image = tIcon
						img.ImageColor3 = tTextColor
						img.ZIndex = 8
						img.Parent = tPill
					end

					local lbl = Instance.new("TextLabel")
					lbl.Size = UDim2.new(0, 0, 1, 0)
					lbl.AutomaticSize = Enum.AutomaticSize.X
					lbl.BackgroundTransparency = 1
					lbl.Text = tText
					lbl.TextColor3 = tTextColor
					lbl.TextSize = 9
					lbl.Font = Enum.Font.GothamBold
					lbl.ZIndex = 8
					lbl.Parent = tPill

					hasTag = true
				end)
			end

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
			LeftCol.Size = UDim2.new(0.5, -6, 0, 0)
			LeftCol.BackgroundTransparency = 1
			LeftCol.Parent = Page

			local LeftLayout = Instance.new("UIListLayout")
			LeftLayout.Padding = UDim.new(0, 8)
			LeftLayout.Parent = LeftCol

			local RightCol = Instance.new("Frame")
			RightCol.Size = UDim2.new(0.5, -6, 0, 0)
			RightCol.Position = UDim2.new(0.5, 6, 0, 0)
			RightCol.BackgroundTransparency = 1
			RightCol.Parent = Page

			local RightLayout = Instance.new("UIListLayout")
			RightLayout.Padding = UDim.new(0, 8)
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

				-- Spawn ripple dot animation on tab click
				pcall(function()
					local mouseLoc = UserInputService:GetMouseLocation()
					local absPos = TabBtn.AbsolutePosition
					local rx = mouseLoc.X - absPos.X
					local ry = mouseLoc.Y - absPos.Y

					local dot = Instance.new("Frame")
					dot.Size = UDim2.new(0, 4, 0, 4)
					dot.Position = UDim2.new(0, rx, 0, ry)
					dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					dot.BackgroundTransparency = 0.3
					dot.BorderSizePixel = 0
					dot.ZIndex = 10
					dot.Parent = DotContainer

					local dCorner = Instance.new("UICorner")
					dCorner.CornerRadius = UDim.new(1, 0)
					dCorner.Parent = dot

					TweenService:Create(dot, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, 160, 0, 160),
						Position = UDim2.new(0, rx - 80, 0, ry - 80),
						BackgroundTransparency = 1
					}):Play()

					task.delay(0.5, function()
						if dot then dot:Destroy() end
					end)
				end)

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
			end

			TabBtn.MouseButton1Click:Connect(switchToThisTab)

			tabObj.Button = TabBtn
			tabObj.Label = TabText
			tabObj.Page = Page
			tabObj.Beam = FlashlightBeam
			tabObj.Glow = GlowLine
			tabObj.Active = false

			if not activeTabObject then
				Page.Visible = true
				TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
				TabText.TextColor3 = Color3.fromRGB(255, 255, 255)
				FlashlightBeam.BackgroundTransparency = 0.2
				GlowLine.BackgroundTransparency = 0.1
				tabObj.Active = true
				activeTabObject = tabObj
			end

			table.insert(tabs, tabObj)

			function tabObj:JumpTo() switchToThisTab() end

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

							local TBtn = Instance.new("TextButton")
							TBtn.Size = UDim2.new(0, 32, 0, 18)
							TBtn.Position = UDim2.new(1, -36, 0.5, -9)
							TBtn.BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(45, 45, 52)
							TBtn.Text = ""
							TBtn.Parent = ToggleItem

							local BtnCorner = Instance.new("UICorner")
							BtnCorner.CornerRadius = UDim.new(0, 30)
							BtnCorner.Parent = TBtn

							local Circle = Instance.new("Frame")
							Circle.Size = UDim2.new(0, 12, 0, 12)
							Circle.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
							Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							Circle.Parent = TBtn

							local CircleCorner = Instance.new("UICorner")
							CircleCorner.CornerRadius = UDim.new(0, 30)
							CircleCorner.Parent = Circle

							TBtn.MouseButton1Click:Connect(function()
								playSound("rbxassetid://75698187458888", soundEnabled, 2.0)
								state = not state
								TweenService:Create(Circle, TWEEN_INFO, {Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)}):Play()
								TweenService:Create(TBtn, TWEEN_INFO, {BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(45, 45, 52)}):Play()
								if callback then pcall(callback, state) end
							end)
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
								if callback then pcall(callback) end
							end)
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
						end)
					end
				end)
				return section
			end
		end)
		return tabObj
	end

	return window
end

return Library