-- SpawnRealm / Moondiety UI Library Module (Corner Radius 30, High-Visibility Border Beam & Fixed Tab Icon Spacing)
local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Expanded Latte-Soft Lucide Roblox Compiled Icon Registry (~100 Icons, 256px Asset IDs)
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
	["folderopen"] = "rbxassetid://10734928509",
	["file"] = "rbxassetid://10734924151",
	["files"] = "rbxassetid://10734924619",
	["bookmark"] = "rbxassetid://10734876643",
	["star"] = "rbxassetid://10735016335",
	["heart"] = "rbxassetid://10734944967",
	["flag"] = "rbxassetid://10734926528",
	["tag"] = "rbxassetid://10735022802",
	["tags"] = "rbxassetid://10735023062",
	["filter"] = "rbxassetid://10734925852",
	["sliders"] = "rbxassetid://10735008543",
	["globe"] = "rbxassetid://10734936274",
	["map"] = "rbxassetid://10734976451",
	["compass"] = "rbxassetid://10734887754",
	["navigation"] = "rbxassetid://10734981134",
	["shield"] = "rbxassetid://10709791437",
	["shieldalert"] = "rbxassetid://10709791689",
	["shieldcheck"] = "rbxassetid://10709791881",
	["sword"] = "rbxassetid://10747371351",
	["combat"] = "rbxassetid://10747371351",
	["crosshair"] = "rbxassetid://10734885564",
	["target"] = "rbxassetid://10735022416",
	["zap"] = "rbxassetid://10735034606",
	["flame"] = "rbxassetid://10734927237",
	["skull"] = "rbxassetid://10735008064",
	["ghost"] = "rbxassetid://10734934336",
	["eye"] = "rbxassetid://10734920239",
	["eyeoff"] = "rbxassetid://10734920409",
	["lock"] = "rbxassetid://10734975736",
	["unlock"] = "rbxassetid://10735027877",
	["key"] = "rbxassetid://10734963503",
	["cpu"] = "rbxassetid://10734885834",
	["terminal"] = "rbxassetid://10735024403",
	["code"] = "rbxassetid://10734884242",
	["bug"] = "rbxassetid://10734878193",
	["activity"] = "rbxassetid://10734870503",
	["radio"] = "rbxassetid://10734997420",
	["wifi"] = "rbxassetid://10735033722",
	["wifioff"] = "rbxassetid://10735033907",
	["volume"] = "rbxassetid://10735032506",
	["volumex"] = "rbxassetid://10735032902",
	["bell"] = "rbxassetid://10734875630",
	["belloff"] = "rbxassetid://10734875953",
	["play"] = "rbxassetid://10734992435",
	["pause"] = "rbxassetid://10734983059",
	["stop"] = "rbxassetid://10735017281",
	["fastforward"] = "rbxassetid://10734923297",
	["rewind"] = "rbxassetid://10734999824",
	["repeat"] = "rbxassetid://10734999243",
	["shuffle"] = "rbxassetid://10735007324",
	["volume1"] = "rbxassetid://10735032115",
	["volume2"] = "rbxassetid://10735032506",
	["mic"] = "rbxassetid://10734978716",
	["micoff"] = "rbxassetid://10734979105",
	["camera"] = "rbxassetid://10734881373",
	["video"] = "rbxassetid://10735031154",
	["image"] = "rbxassetid://10734954778",
	["refresh"] = "rbxassetid://10734998706",
	["trash"] = "rbxassetid://10735026916",
	["download"] = "rbxassetid://10734914175",
	["upload"] = "rbxassetid://10735028475",
	["share"] = "rbxassetid://10735011704",
	["external"] = "rbxassetid://10734921616",
	["link"] = "rbxassetid://10734971358",
	["copy"] = "rbxassetid://10734884949",
	["scissors"] = "rbxassetid://10735003901",
	["edit"] = "rbxassetid://10734918579",
	["plus"] = "rbxassetid://10734995059",
	["minus"] = "rbxassetid://10734979435",
	["x"] = "rbxassetid://10735034177",
	["check"] = "rbxassetid://10734882173",
	["chevronright"] = "rbxassetid://10734886616",
	["chevronleft"] = "rbxassetid://10734886361",
	["chevromup"] = "rbxassetid://10734886915",
	["chevrondown"] = "rbxassetid://10734885994",
	["arrowright"] = "rbxassetid://10734873111",
	["arrowleft"] = "rbxassetid://10734872628",
	["arrowup"] = "rbxassetid://10734873461",
	["arrowdown"] = "rbxassetid://10734872081",
	["power"] = "rbxassetid://10734995393",
	["battery"] = "rbxassetid://10734874945",
	["harddrive"] = "rbxassetid://10734944365",
	["server"] = "rbxassetid://10735010078",
	["database"] = "rbxassetid://10734910356",
	["cloud"] = "rbxassetid://10734883196",
	["clouddownload"] = "rbxassetid://10734883405",
	["cloudupload"] = "rbxassetid://10734883838",
	["maximize"] = "rbxassetid://10734976767",
	["minimize"] = "rbxassetid://10734979854",
	["maximize2"] = "rbxassetid://10734977239",
	["minimize2"] = "rbxassetid://10734980181",
	["rotatecw"] = "rbxassetid://10735000572",
	["rotateccw"] = "rbxassetid://10735000213",
	["info"] = "rbxassetid://10734958133",
	["help"] = "rbxassetid://10734947936",
	["alerttriangle"] = "rbxassetid://10734871051",
	["alertcircle"] = "rbxassetid://10734870716",
	["alertoctagon"] = "rbxassetid://10734870877",
	["clock"] = "rbxassetid://10734882823",
	["calendar"] = "rbxassetid://10734880436",
	["gift"] = "rbxassetid://10734933939",
	["award"] = "rbxassetid://10734874523",
	["trophy"] = "rbxassetid://10735027411",
	["package"] = "rbxassetid://10734982638",
	["box"] = "rbxassetid://10734877202",
	["layers"] = "rbxassetid://10734969248",
	["layout"] = "rbxassetid://10734969578"
}

local function getLucideIcon(iconName)
	if not iconName then return nil end
	if type(iconName) == "string" and iconName:match("^rbxassetid://") then
		return iconName
	end
	local formatted = tostring(iconName):lower():gsub("[^a-z]", "")
	return LucideIcons[formatted] or iconName
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
		folder.Name = "SR_DedicatedFolder_" .. math.random(1000, 9999)
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
	local iconId = getLucideIcon(config.UIicon or config.UiIcon or "shield") or "rbxassetid://10709791437"
	local soundEnabled = (config.SoundButtons ~= false)
	local userConfig = config.User or nil

	local window = {}
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "SR_" .. math.random(100000, 999999)
	ScreenGui.Parent = getProtectedParent()
	ScreenGui.ResetOnSpawn = false

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	local targetWidth = 682
	local targetHeight = 310
	Main.Size = UDim2.new(0, targetWidth, 0, targetHeight)
	Main.Position = UDim2.new(0.5, -targetWidth/2, 0.45, -targetHeight/2)
	Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	Main.BorderSizePixel = 0
	Main.Visible = false
	Main.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 30)
	MainCorner.Parent = Main

	-- High-Visibility, Thicker Rotating Neon Border Beam
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

	-- Mini Stats Widget (Corner 30 with High-Visibility Neon Beam)
	local StatsFrame = Instance.new("Frame")
	StatsFrame.Name = "StatsFrame"
	StatsFrame.Size = UDim2.new(0, 246, 0, 32)
	StatsFrame.Position = UDim2.new(0.5, 90, 0.45, -175)
	StatsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	StatsFrame.BorderSizePixel = 0
	StatsFrame.Visible = false
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
	StatsContainer.Size = UDim2.new(1, -32, 1, 0)
	StatsContainer.Position = UDim2.new(0, 32, 0, 0)
	StatsContainer.BackgroundTransparency = 1
	StatsContainer.Parent = StatsFrame

	local StatsLayout = Instance.new("UIListLayout")
	StatsLayout.FillDirection = Enum.FillDirection.Horizontal
	StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	StatsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	StatsLayout.Padding = UDim.new(0, 6)
	StatsLayout.Parent = StatsContainer

	local function createStatLabel(text)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 58, 1, 0)
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
				pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
				PingLabel.Text = ping .. " ms"
				FpsLabel.Text = math.floor(1 / dt) .. " fps"
				PlayersLabel.Text = #Players:GetPlayers() .. " players"
			end
		end)
	end)

	makeDraggable(StatsFrame, StatsFrame)

	-- Loading Screen
	pcall(function()
		local LoadGui = Instance.new("ScreenGui")
		LoadGui.Name = "SR_Load_" .. math.random(1000,9999)
		LoadGui.Parent = getProtectedParent()

		local LoadFrame = Instance.new("Frame")
		LoadFrame.Size = UDim2.new(0, 420, 0, 210)
		LoadFrame.Position = UDim2.new(0.5, -210, 0.5, -105)
		LoadFrame.BackgroundColor3 = Color3.fromRGB(14, 13, 18)
		LoadFrame.BorderSizePixel = 0
		LoadFrame.Parent = LoadGui

		local LoadCorner = Instance.new("UICorner")
		LoadCorner.CornerRadius = UDim.new(0, 30)
		LoadCorner.Parent = LoadFrame

		local LoadStroke = Instance.new("UIStroke")
		LoadStroke.Thickness = 3
		LoadStroke.Parent = LoadFrame

		local LoadStrokeGrad = Instance.new("UIGradient")
		LoadStrokeGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0.2),
			NumberSequenceKeypoint.new(1, 0)
		})
		LoadStrokeGrad.Parent = LoadStroke

		task.spawn(function()
			while LoadStrokeGrad and LoadStrokeGrad.Parent do
				TweenService:Create(LoadStrokeGrad, TweenInfo.new(2.5, Enum.EasingStyle.Linear), {Rotation = LoadStrokeGrad.Rotation + 360}):Play()
				task.wait(2.5)
			end
		end)

		local IconImg = Instance.new("ImageLabel")
		IconImg.Size = UDim2.new(0, 54, 0, 54)
		IconImg.Position = UDim2.new(0.5, -27, 0, 28)
		IconImg.BackgroundTransparency = 1
		IconImg.Image = iconId
		IconImg.Parent = LoadFrame

		local LoadTitle = Instance.new("TextLabel")
		LoadTitle.Size = UDim2.new(1, 0, 0, 24)
		LoadTitle.Position = UDim2.new(0, 0, 0, 96)
		LoadTitle.BackgroundTransparency = 1
		LoadTitle.Text = string.upper(titleText)
		LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		LoadTitle.TextSize = 18
		LoadTitle.Font = Enum.Font.GothamBold
		LoadTitle.TextXAlignment = Enum.TextXAlignment.Center
		LoadTitle.Parent = LoadFrame

		local SubLoadTitle = Instance.new("TextLabel")
		SubLoadTitle.Size = UDim2.new(1, 0, 0, 16)
		SubLoadTitle.Position = UDim2.new(0, 0, 0, 124)
		SubLoadTitle.BackgroundTransparency = 1
		SubLoadTitle.Text = "ESTABLISHING SECURE CONNECTION..."
		SubLoadTitle.TextColor3 = Color3.fromRGB(170, 170, 185)
		SubLoadTitle.TextSize = 10
		SubLoadTitle.Font = Enum.Font.GothamBold
		SubLoadTitle.TextXAlignment = Enum.TextXAlignment.Center
		SubLoadTitle.Parent = LoadFrame

		task.spawn(function()
			task.wait(1.4)
			TweenService:Create(LoadFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
			task.wait(0.4)
			LoadGui:Destroy()
			Main.Visible = true
			StatsFrame.Visible = true
		end)
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

	-- Floating Toggle Button
	local ToggleBtnOuter = Instance.new("Frame")
	ToggleBtnOuter.Name = "ToggleBtnOuter"
	ToggleBtnOuter.Size = UDim2.new(0, 42, 0, 42)
	ToggleBtnOuter.Position = UDim2.new(0, 40, 0, 200)
	ToggleBtnOuter.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ToggleBtnOuter.BorderSizePixel = 0
	ToggleBtnOuter.Visible = false
	ToggleBtnOuter.Parent = ScreenGui

	local ToggleBtn = Instance.new("ImageButton")
	ToggleBtn.Size = UDim2.new(1, -4, 1, -4)
	ToggleBtn.Position = UDim2.new(0, 2, 0, 2)
	ToggleBtn.BackgroundColor3 = Color3.fromRGB(18, 16, 20)
	ToggleBtn.Image = iconId
	ToggleBtn.ScaleType = Enum.ScaleType.Fit
	ToggleBtn.Parent = ToggleBtnOuter

	local TBtnCorner = Instance.new("UICorner")
	TBtnCorner.CornerRadius = UDim.new(0, 21)
	TBtnCorner.Parent = ToggleBtn

	makeDraggable(ToggleBtnOuter, ToggleBtnOuter)
	makeDraggable(ToggleBtn, ToggleBtnOuter)

	ToggleBtn.MouseButton1Click:Connect(function()
		playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
		Main.Visible = true
		StatsFrame.Visible = true
		ToggleBtnOuter.Visible = false
	end)

	-- Window Controls
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
		pcall(function() ScreenGui:Destroy() end)
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
		Main.Visible = false
		StatsFrame.Visible = false
		ToggleBtnOuter.Visible = true
	end)

	makeDraggable(Topbar, Main)

	-- Sidebar Tab Container
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(0, 140, 1, userConfig and userConfig.Enabled ~= false and -112 or -55)
	TabContainer.Position = UDim2.new(0, 12, 0, 48)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 0
	TabContainer.Parent = Main

	local TabList = Instance.new("UIListLayout")
	TabList.Padding = UDim.new(0, 5)
	TabList.Parent = TabContainer

	-- User Profile Card
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
			AvatarImg.Image = getLucideIcon("user")
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
		ArrowIcon.Image = getLucideIcon("chevronright")
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
		local tab = {}
		pcall(function()
			if type(tabConfig) == "string" then
				tabConfig = { name = tabConfig }
			end
			local tabName = tabConfig.name or tabConfig.Name or "Tab"
			local tabIconId = getLucideIcon(tabConfig.icon or tabConfig.Icon)

			local TabBtn = Instance.new("TextButton")
			TabBtn.Size = UDim2.new(1, 0, 0, 32)
			TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
			-- Fixed text padding offset so text never overlaps the icon
			TabBtn.Text = tabIconId and "        " .. tostring(tabName) or "   " .. tostring(tabName)
			TabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
			TabBtn.Font = Enum.Font.GothamMedium
			TabBtn.TextSize = 12
			TabBtn.TextXAlignment = Enum.TextXAlignment.Left
			TabBtn.TextTruncate = Enum.TextTruncate.AtEnd
			TabBtn.ClipsDescendants = true
			TabBtn.Parent = TabContainer

			if tabIconId then
				local TIcon = Instance.new("ImageLabel")
				TIcon.Size = UDim2.new(0, 16, 0, 16)
				TIcon.Position = UDim2.new(0, 10, 0.5, -8)
				TIcon.BackgroundTransparency = 1
				TIcon.Image = tabIconId
				TIcon.Parent = TabBtn
			end

			-- Flashlight Beam Light Effect
			local FlashlightBeam = Instance.new("Frame")
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

			-- Bright Glowing Line on Left Edge
			local GlowLine = Instance.new("Frame")
			GlowLine.Name = "GlowLine"
			GlowLine.Size = UDim2.new(0, 3, 1, 0)
			GlowLine.Position = UDim2.new(0, 0, 0, 0)
			GlowLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			GlowLine.BackgroundTransparency = 1
			GlowLine.BorderSizePixel = 0
			GlowLine.ZIndex = 3
			GlowLine.Parent = TabBtn

			local DotContainer = Instance.new("Frame")
			DotContainer.Name = "DotContainer"
			DotContainer.Size = UDim2.new(1, 0, 1, 0)
			DotContainer.BackgroundTransparency = 1
			DotContainer.ClipsDescendants = true
			DotContainer.ZIndex = 4
			DotContainer.Parent = TabBtn

			local TabCorner = Instance.new("UICorner")
			TabCorner.CornerRadius = UDim.new(0, 30)
			TabCorner.Parent = TabBtn

			local Page = Instance.new("ScrollingFrame")
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
			LeftCol.Size = UDim2.new(0.5, -5, 1, 0)
			LeftCol.BackgroundTransparency = 1
			LeftCol.Parent = Page

			local LeftLayout = Instance.new("UIListLayout")
			LeftLayout.Padding = UDim.new(0, 8)
			LeftLayout.Parent = LeftCol

			LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				LeftCol.Size = UDim2.new(0.5, -5, 0, LeftLayout.AbsoluteContentSize.Y)
			end)

			local RightCol = Instance.new("Frame")
			RightCol.Size = UDim2.new(0.5, -5, 1, 0)
			RightCol.Position = UDim2.new(0.5, 5, 0, 0)
			RightCol.BackgroundTransparency = 1
			RightCol.Parent = Page

			local RightLayout = Instance.new("UIListLayout")
			RightLayout.Padding = UDim.new(0, 8)
			RightLayout.Parent = RightCol

			RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				RightCol.Size = UDim2.new(0.5, -5, 0, RightLayout.AbsoluteContentSize.Y)
			end)

			local tabObj = {Button = TabBtn, Page = Page, Beam = FlashlightBeam, Glow = GlowLine, Dots = DotContainer, Active = false}

			if not activeTabObject then
				Page.Visible = true
				TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
				TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				FlashlightBeam.BackgroundTransparency = 0.2
				GlowLine.BackgroundTransparency = 0.1
				tabObj.Active = true
				activeTabObject = tabObj
			end

			TabBtn.MouseButton1Click:Connect(function()
				playSound("rbxassetid://122966251252708", soundEnabled, 1.5)
				for _, t in pairs(tabs) do
					pcall(function()
						t.Page.Visible = false
						t.Active = false
						TweenService:Create(t.Button, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(22, 22, 26), TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
						if t.Beam then
							TweenService:Create(t.Beam, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
						end
						if t.Glow then
							TweenService:Create(t.Glow, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
						end
					end)
				end
				Page.Visible = true
				tabObj.Active = true
				activeTabObject = tabObj
				TweenService:Create(TabBtn, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(28, 28, 34), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				TweenService:Create(FlashlightBeam, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
				TweenService:Create(GlowLine, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
			end)

			task.spawn(function()
				while TabBtn and TabBtn.Parent do
					if tabObj.Active then
						pcall(function()
							local dot = Instance.new("Frame")
							dot.Size = UDim2.new(0, 3 + math.random(0, 2), 0, 3 + math.random(0, 2))
							dot.Position = UDim2.new(0, math.random(0, 15), 0, math.random(4, 26))
							dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
							dot.BackgroundTransparency = 0.15
							dot.BorderSizePixel = 0
							dot.ZIndex = 5
							dot.Parent = DotContainer

							local dotCorner = Instance.new("UICorner")
							dotCorner.CornerRadius = UDim.new(0, 30)
							dotCorner.Parent = dot

							local slowTravelTime = 1.2 + (math.random() * 0.6)
							TweenService:Create(dot, TweenInfo.new(slowTravelTime, Enum.EasingStyle.Linear), {
								Position = UDim2.new(0.85, 0, dot.Position.Y.Scale, dot.Position.Y.Offset),
								BackgroundTransparency = 1
							}):Play()

							task.delay(slowTravelTime, function()
								pcall(function() dot:Destroy() end)
							end)
						end)
						task.wait(0.35)
					else
						task.wait(0.4)
					end
				end
			end)

			table.insert(tabs, tabObj)

			function tab:CreateSection(columnSide, sectionTitle)
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
							ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 52)
							ToggleBtn.Text = ""
							ToggleBtn.Parent = ToggleItem

							local BtnCorner = Instance.new("UICorner")
							BtnCorner.CornerRadius = UDim.new(0, 30)
							BtnCorner.Parent = ToggleBtn

							local Circle = Instance.new("Frame")
							Circle.Size = UDim2.new(0, 12, 0, 12)
							Circle.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
							Circle.BackgroundColor3 = state and Color3.fromRGB(15, 15, 18) or Color3.fromRGB(255, 255, 255)
							Circle.Parent = ToggleBtn

							local CircleCorner = Instance.new("UICorner")
							CircleCorner.CornerRadius = UDim.new(0, 30)
							CircleCorner.Parent = Circle

							ToggleBtn.MouseButton1Click:Connect(function()
								playSound("rbxassetid://75698187458888", soundEnabled, 2.0)
								state = not state
								local targetPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
								local targetColor = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 52)
								local circleColor = state and Color3.fromRGB(15, 15, 18) or Color3.fromRGB(255, 255, 255)

								TweenService:Create(Circle, TWEEN_INFO, {Position = targetPos, BackgroundColor3 = circleColor}):Play()
								TweenService:Create(ToggleBtn, TWEEN_INFO, {BackgroundColor3 = targetColor}):Play()
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
								TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
								task.delay(0.1, function()
									TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}):Play()
								end)
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

							-- Slider Progress Handle / Dot at the end of the line
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
		return tab
	end

	return window
end

return Library