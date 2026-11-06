-- // SpawnRealmXUI Library (Fluid, Tactile, Rayfield-Gen2 Minimized Icon & All Systems) \\ --
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SpawnRealmXUI = {
    Themes = {
        DarkTheme = {
            Background = Color3.fromRGB(15, 15, 18),
            Sidebar = Color3.fromRGB(20, 20, 24),
            Container = Color3.fromRGB(27, 27, 32),
            Accent = Color3.fromRGB(46, 204, 113),
            Text = Color3.fromRGB(240, 240, 245),
            SubText = Color3.fromRGB(140, 142, 155),
            Outline = Color3.fromRGB(35, 35, 42),
            Hover = Color3.fromRGB(32, 32, 38)
        },
        LightTheme = {
            Background = Color3.fromRGB(240, 240, 245),
            Sidebar = Color3.fromRGB(225, 225, 230),
            Container = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(0, 122, 255),
            Text = Color3.fromRGB(20, 20, 25),
            SubText = Color3.fromRGB(100, 100, 110),
            Outline = Color3.fromRGB(200, 200, 210),
            Hover = Color3.fromRGB(235, 235, 240)
        },
        Midnight = {
            Background = Color3.fromRGB(8, 8, 12),
            Sidebar = Color3.fromRGB(12, 12, 18),
            Container = Color3.fromRGB(18, 18, 26),
            Accent = Color3.fromRGB(138, 43, 226),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(160, 160, 180),
            Outline = Color3.fromRGB(40, 40, 60),
            Hover = Color3.fromRGB(25, 25, 36)
        }
    },
    CurrentFont = Font.fromEnum(Enum.Font.Gotham)
}
SpawnRealmXUI.__index = SpawnRealmXUI

local function playSound(soundId)
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. tostring(soundId):match("%d+")
    s.Volume = 0.5
    s.Parent = SoundService
    s:Play()
    s.Ended:Connect(function() s:Destroy() end)
end

function SpawnRealmXUI:SetFont(fontInput)
    if typeof(fontInput) == "number" then
        SpawnRealmXUI.CurrentFont = Font.fromId(fontInput)
    elseif typeof(fontInput) == "string" then
        local id = fontInput:match("%d+")
        if id then
            SpawnRealmXUI.CurrentFont = Font.fromId(tonumber(id))
        else
            SpawnRealmXUI.CurrentFont = Font.fromEnum(Enum.Font.Gotham)
        end
    elseif typeof(fontInput) == "EnumItem" then
        SpawnRealmXUI.CurrentFont = Font.fromEnum(fontInput)
    end
end

local function applyFont(textLabel)
    if typeof(SpawnRealmXUI.CurrentFont) == "Font" then
        textLabel.FontFace = SpawnRealmXUI.CurrentFont
    end
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function SpawnRealmXUI:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Theme 'Dark'"
    local authorName = config.Author or ".ftgs"
    local winWidth = config.Width or 580
    local winHeight = config.Height or 390
    local windowIcon = config.Icon or "rbxassetid://6031097225"
    local transparencyVal = math.clamp(config.Transparency or 0, 0, 1)
    
    local searchBarEnabled = config.SearchBarEnabled or false
    local syncSearchBar = config.SyncSearchBar or false
    local resizeUI = config.ResizeUI or false

    local themeInput = config.Theme or "DarkTheme"
    local Theme = SpawnRealmXUI.Themes.DarkTheme
    local customBgAsset = nil

    if typeof(themeInput) == "string" then
        if themeInput:find("rbxassetid://") or themeInput:match("^%d+$") then
            local assetId = themeInput:match("%d+")
            customBgAsset = "rbxassetid://" .. tostring(assetId)
        elseif SpawnRealmXUI.Themes[themeInput] then
            Theme = SpawnRealmXUI.Themes[themeInput]
        end
    end

    local Window = {
        Tabs = {},
        ActiveTab = nil,
        IsMinimized = false,
        IsFullscreen = false
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SpawnRealmXUI_Instance"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, winWidth, 0, winHeight)
    MainFrame.Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BackgroundTransparency = transparencyVal
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    addCorner(MainFrame, 14)
    addStroke(MainFrame, Theme.Outline, 1)

    if customBgAsset then
        local BgImage = Instance.new("ImageLabel")
        BgImage.Size = UDim2.new(1, 0, 1, 0)
        BgImage.BackgroundTransparency = 1
        BgImage.Image = customBgAsset
        BgImage.ScaleType = Enum.ScaleType.Slice
        BgImage.ImageTransparency = transparencyVal * 0.5
        BgImage.Parent = MainFrame
    end

    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 42)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainFrame

    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Size = UDim2.new(0, 18, 0, 18)
    LogoIcon.Position = UDim2.new(0, 14, 0, 12)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = windowIcon
    LogoIcon.ImageColor3 = Theme.Text
    LogoIcon.Parent = Topbar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 250, 0, 18)
    TitleLabel.Position = UDim2.new(0, 40, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = windowTitle
    applyFont(TitleLabel)
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar

    local AuthorLabel = Instance.new("TextLabel")
    AuthorLabel.Size = UDim2.new(0, 250, 0, 14)
    AuthorLabel.Position = UDim2.new(0, 40, 0, 22)
    AuthorLabel.BackgroundTransparency = 1
    AuthorLabel.Text = "by " .. authorName
    applyFont(AuthorLabel)
    AuthorLabel.TextColor3 = Theme.SubText
    AuthorLabel.TextSize = 10
    AuthorLabel.TextXAlignment = Enum.TextXAlignment.Left
    AuthorLabel.Parent = Topbar

    local ControlHolder = Instance.new("Frame")
    ControlHolder.Size = UDim2.new(0, 90, 1, 0)
    ControlHolder.Position = UDim2.new(1, -95, 0, 0)
    ControlHolder.BackgroundTransparency = 1
    ControlHolder.Parent = Topbar

    local function createControlButton(text, posOffset, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 26, 0, 26)
        Btn.Position = UDim2.new(0, posOffset, 0.5, -13)
        Btn.BackgroundTransparency = 1
        Btn.Text = text
        applyFont(Btn)
        Btn.TextColor3 = Theme.SubText
        Btn.TextSize = 12
        Btn.Parent = ControlHolder

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {TextColor3 = Theme.SubText}):Play()
        end)
        Btn.MouseButton1Click:Connect(callback)
        return Btn
    end

    local normalSize = UDim2.new(0, winWidth, 0, winHeight)
    local normalPos = MainFrame.Position

    -- Rayfield-Gen2 style Floating Minimized Floating Button Setup
    local FloatingMinBtn = Instance.new("ImageButton")
    FloatingMinBtn.Name = "FloatingMinimizeIcon"
    FloatingMinBtn.Size = UDim2.new(0, 46, 0, 46)
    FloatingMinBtn.Position = UDim2.new(0, 30, 0.5, -23)
    FloatingMinBtn.BackgroundColor3 = Theme.Container
    FloatingMinBtn.Visible = false
    FloatingMinBtn.ZIndex = 500
    FloatingMinBtn.AutoButtonColor = false
    FloatingMinBtn.Parent = ScreenGui

    addCorner(FloatingMinBtn, 23)
    addStroke(FloatingMinBtn, Theme.Outline, 1.5)

    local FloatImg = Instance.new("ImageLabel")
    FloatImg.Size = UDim2.new(0, 24, 0, 24)
    FloatImg.Position = UDim2.new(0.5, -12, 0.5, -12)
    FloatImg.BackgroundTransparency = 1
    FloatImg.Image = windowIcon
    FloatImg.ImageColor3 = Theme.Text
    FloatImg.ZIndex = 501
    FloatImg.Parent = FloatingMinBtn

    -- Make Floating Button Movable / Draggable
    local floatDragging, floatDragStart, floatStartPos
    FloatingMinBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatDragging = true
            floatDragStart = input.Position
            floatStartPos = FloatingMinBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then floatDragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - floatDragStart
            FloatingMinBtn.Position = UDim2.new(floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X, floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y)
        end
    end)

    -- Minimize Action
    createControlButton("—", 0, function()
        playSound(103061940249989)
        Window.IsMinimized = true
        
        -- Smooth fluid shrink & fade out
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.25)
        MainFrame.Visible = false
        
        -- Pop in floating Gen2 icon
        FloatingMinBtn.Visible = true
        FloatingMinBtn.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(FloatingMinBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 46, 0, 46)
        }):Play()
    end)

    -- Tap Floating Icon to Restore Main GUI
    FloatingMinBtn.MouseButton1Click:Connect(function()
        playSound(103061940249989)
        Window.IsMinimized = false

        TweenService:Create(FloatingMinBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        task.wait(0.15)
        FloatingMinBtn.Visible = false
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)

        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = normalSize,
            BackgroundTransparency = transparencyVal
        }):Play()
    end)

    createControlButton("⸌⸍", 30, function()
        playSound(103061940249989)
        Window.IsFullscreen = not Window.IsFullscreen
        if Window.IsFullscreen then
            normalSize = MainFrame.Size
            normalPos = MainFrame.Position
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -40, 1, -40), Position = UDim2.new(0, 20, 0, 20)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = normalSize, Position = normalPos}):Play()
        end
    end)

    -- Warning Screen for Closing Window
    createControlButton("✕", 60, function()
        playSound(103061940249989)
        
        local DialogOverlay = Instance.new("Frame")
        DialogOverlay.Size = UDim2.new(1, 0, 1, 0)
        DialogOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        DialogOverlay.BackgroundTransparency = 0.7
        DialogOverlay.ZIndex = 200
        DialogOverlay.Parent = MainFrame

        local WarningBox = Instance.new("Frame")
        WarningBox.Size = UDim2.new(0, 320, 0, 160)
        WarningBox.Position = UDim2.new(0.5, -160, 0.5, -80)
        WarningBox.BackgroundColor3 = Theme.Container
        WarningBox.ZIndex = 201
        WarningBox.Parent = DialogOverlay
        addCorner(WarningBox, 12)
        addStroke(WarningBox, Theme.Outline, 1)

        local WTitle = Instance.new("TextLabel")
        WTitle.Size = UDim2.new(1, -24, 0, 24)
        WTitle.Position = UDim2.new(0, 12, 0, 12)
        WTitle.BackgroundTransparency = 1
        WTitle.Text = "Close Window"
        applyFont(WTitle)
        WTitle.TextColor3 = Theme.Text
        WTitle.TextSize = 14
        WTitle.ZIndex = 202
        WTitle.TextXAlignment = Enum.TextXAlignment.Left
        WTitle.Parent = WarningBox

        local WDesc = Instance.new("TextLabel")
        WDesc.Size = UDim2.new(1, -24, 0, 40)
        WDesc.Position = UDim2.new(0, 12, 0, 40)
        WDesc.BackgroundTransparency = 1
        WDesc.Text = "Do you want to close this window? You will not be able to open it again."
        applyFont(WDesc)
        WDesc.TextColor3 = Theme.SubText
        WDesc.TextSize = 11
        WDesc.ZIndex = 202
        WDesc.TextWrapped = true
        WDesc.TextXAlignment = Enum.TextXAlignment.Left
        WDesc.Parent = WarningBox

        local CancelBtn = Instance.new("TextButton")
        CancelBtn.Size = UDim2.new(0.46, 0, 0, 36)
        CancelBtn.Position = UDim2.new(0, 12, 1, -48)
        CancelBtn.BackgroundColor3 = Theme.Sidebar
        CancelBtn.Text = "Cancel"
        applyFont(CancelBtn)
        CancelBtn.TextColor3 = Theme.Text
        CancelBtn.TextSize = 12
        CancelBtn.ZIndex = 202
        CancelBtn.Parent = WarningBox
        addCorner(CancelBtn, 8)
        addStroke(CancelBtn, Theme.Outline, 1)

        local ConfirmBtn = Instance.new("TextButton")
        ConfirmBtn.Size = UDim2.new(0.46, 0, 0, 36)
        ConfirmBtn.Position = UDim2.new(0.52, 0, 1, -48)
        ConfirmBtn.BackgroundColor3 = Theme.Accent
        ConfirmBtn.Text = "Close Window"
        applyFont(ConfirmBtn)
        ConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ConfirmBtn.TextSize = 12
        ConfirmBtn.ZIndex = 202
        ConfirmBtn.Parent = WarningBox
        addCorner(ConfirmBtn, 8)

        CancelBtn.MouseButton1Click:Connect(function()
            playSound(103061940249989)
            DialogOverlay:Destroy()
        end)

        ConfirmBtn.MouseButton1Click:Connect(function()
            playSound(103061940249989)
            ScreenGui:Destroy()
        end)
    end)

    -- Smooth Fluid Window Dragging
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            TweenService:Create(MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, -50)
    Sidebar.Position = UDim2.new(0, 10, 0, 42)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BackgroundTransparency = transparencyVal
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    addCorner(Sidebar, 10)

    -- Search Bar integration
    local searchBox = nil
    local currentSearchQuery = ""
    if searchBarEnabled then
        local SearchFrame = Instance.new("Frame")
        SearchFrame.Size = UDim2.new(1, -12, 0, 32)
        SearchFrame.Position = UDim2.new(0, 6, 0, 6)
        SearchFrame.BackgroundColor3 = Theme.Container
        SearchFrame.Parent = Sidebar
        addCorner(SearchFrame, 8)
        addStroke(SearchFrame, Theme.Outline, 1)

        searchBox = Instance.new("TextBox")
        searchBox.Size = UDim2.new(1, -24, 1, 0)
        searchBox.Position = UDim2.new(0, 10, 0, 0)
        searchBox.BackgroundTransparency = 1
        searchBox.PlaceholderText = "Search..."
        searchBox.Text = ""
        applyFont(searchBox)
        searchBox.TextColor3 = Theme.Text
        searchBox.PlaceholderColor3 = Theme.SubText
        searchBox.TextSize = 11
        searchBox.TextXAlignment = Enum.TextXAlignment.Left
        searchBox.Parent = SearchFrame

        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            playSound(9116158128)
            currentSearchQuery = string.lower(searchBox.Text)
            for _, tabObj in ipairs(Window.Tabs) do
                local matchTab = string.find(string.lower(tabObj.Name), currentSearchQuery) ~= nil
                local anyMatch = false
                for _, itemObj in ipairs(tabObj.Items) do
                    local matchItem = string.find(string.lower(itemObj.Title), currentSearchQuery) ~= nil
                    if syncSearchBar then
                        itemObj.Instance.Visible = matchItem or matchTab or currentSearchQuery == ""
                    end
                    if matchItem then anyMatch = true end
                end
                if syncSearchBar then
                    tabObj.TabBtn.Visible = matchTab or anyMatch or currentSearchQuery == ""
                end
            end
        end)
    end

    local ProfileCard = Instance.new("Frame")
    ProfileCard.Size = UDim2.new(1, -12, 0, 48)
    ProfileCard.Position = UDim2.new(0, 6, 1, -54)
    ProfileCard.BackgroundColor3 = Theme.Container
    ProfileCard.Parent = Sidebar
    addCorner(ProfileCard, 8)
    addStroke(ProfileCard, Theme.Outline, 1)

    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.Size = UDim2.new(0, 32, 0, 32)
    AvatarImg.Position = UDim2.new(0, 8, 0.5, -16)
    AvatarImg.BackgroundColor3 = Theme.Outline
    AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
    AvatarImg.Parent = ProfileCard
    addCorner(AvatarImg, 16)

    local DispNameLab = Instance.new("TextLabel")
    DispNameLab.Size = UDim2.new(1, -48, 0, 16)
    DispNameLab.Position = UDim2.new(0, 46, 0, 8)
    DispNameLab.BackgroundTransparency = 1
    DispNameLab.Text = LocalPlayer.DisplayName
    applyFont(DispNameLab)
    DispNameLab.TextColor3 = Theme.Text
    DispNameLab.TextSize = 12
    DispNameLab.TextXAlignment = Enum.TextXAlignment.Left
    DispNameLab.Parent = ProfileCard

    local UserLab = Instance.new("TextLabel")
    UserLab.Size = UDim2.new(1, -48, 0, 14)
    UserLab.Position = UDim2.new(0, 46, 0, 24)
    UserLab.BackgroundTransparency = 1
    UserLab.Text = "@" .. LocalPlayer.Name
    applyFont(UserLab)
    UserLab.TextColor3 = Theme.SubText
    UserLab.TextSize = 10
    UserLab.TextXAlignment = Enum.TextXAlignment.Left
    UserLab.TextTruncate = Enum.TextTruncate.AtEnd
    UserLab.Parent = ProfileCard

    task.spawn(function()
        local success, result = pcall(function()
            local req = (syn and syn.request) or request or (http and http.request)
            if req then
                local res = req({Url = "https://users.roblox.com/v1/users/" .. tostring(LocalPlayer.UserId), Method = "GET"})
                if res and res.Body then
                    local data = HttpService:JSONDecode(res.Body)
                    if data and data.description and data.description ~= "" then
                        return data.description:gsub("[\n\r]", " ")
                    end
                end
            end
        end)
        if success and result then UserLab.Text = result end
    end)

    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Size = UDim2.new(1, -12, 1, searchBarEnabled and -106 or -66)
    TabHolder.Position = UDim2.new(0, 6, 0, searchBarEnabled and 44 or 6)
    TabHolder.BackgroundTransparency = 1
    TabHolder.ScrollBarThickness = 0
    TabHolder.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = TabHolder

    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -186, 1, -50)
    ContentHolder.Position = UDim2.new(0, 176, 0, 42)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    -- ResizeUI Handle Support
    if resizeUI then
        local ResizeHandle = Instance.new("TextButton")
        ResizeHandle.Size = UDim2.new(0, 16, 0, 16)
        ResizeHandle.Position = UDim2.new(1, -16, 1, -16)
        ResizeHandle.BackgroundTransparency = 1
        ResizeHandle.Text = "◢"
        applyFont(ResizeHandle)
        ResizeHandle.TextColor3 = Theme.SubText
        ResizeHandle.TextSize = 12
        ResizeHandle.ZIndex = 150
        ResizeHandle.Parent = MainFrame

        local resizing = false
        local resizeStart, startSize
        ResizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                resizeStart = input.Position
                startSize = MainFrame.AbsoluteSize
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - resizeStart
                local newW = math.clamp(startSize.X + delta.X, 400, 900)
                local newH = math.clamp(startSize.Y + delta.Y, 250, 700)
                MainFrame.Size = UDim2.new(0, newW, 0, newH)
            end
        end)
    end

    -- Window:Toast (Top Middle Screen with White Outline)
    function Window:Toast(toastConfig)
        toastConfig = toastConfig or {}
        local title = toastConfig.Title or "Toast"
        local content = toastConfig.Content or ""
        local duration = toastConfig.Duration or 3
        playSound(17208372272)

        local Toast = Instance.new("Frame")
        Toast.Size = UDim2.new(0, 260, 0, 50)
        Toast.Position = UDim2.new(0.5, -130, 0, -60)
        Toast.BackgroundColor3 = Theme.Container
        Toast.ZIndex = 300
        Toast.Parent = ScreenGui
        addCorner(Toast, 25)
        addStroke(Toast, Color3.fromRGB(255, 255, 255), 1.5)

        local TTitle = Instance.new("TextLabel")
        TTitle.Size = UDim2.new(1, -20, 0, 18)
        TTitle.Position = UDim2.new(0, 10, 0, 8)
        TTitle.BackgroundTransparency = 1
        TTitle.Text = title
        applyFont(TTitle)
        TTitle.TextColor3 = Theme.Text
        TTitle.TextSize = 12
        TTitle.ZIndex = 301
        TTitle.TextXAlignment = Enum.TextXAlignment.Center
        TTitle.Parent = Toast

        local TDesc = Instance.new("TextLabel")
        TDesc.Size = UDim2.new(1, -20, 0, 16)
        TDesc.Position = UDim2.new(0, 10, 0, 26)
        TDesc.BackgroundTransparency = 1
        TDesc.Text = content
        applyFont(TDesc)
        TDesc.TextColor3 = Theme.SubText
        TDesc.TextSize = 10
        TDesc.ZIndex = 301
        TDesc.TextXAlignment = Enum.TextXAlignment.Center
        TDesc.Parent = Toast

        TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -130, 0, 16)
        }):Play()

        task.delay(duration, function()
            local fadeOut = TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -130, 0, -60)
            })
            fadeOut:Play()
            fadeOut.Completed:Connect(function() Toast:Destroy() end)
        end)
    end

    -- Window:Notify (Bottom Right Corner with X Button & Click-Through)
    function Window:Notify(notifyConfig)
        notifyConfig = notifyConfig or {}
        local title = notifyConfig.Title or "Notification"
        local content = notifyConfig.Content or ""
        local duration = notifyConfig.Duration or 4
        playSound(17208361335)

        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(0, 240, 0, 60)
        NotifFrame.Position = UDim2.new(1, 260, 1, -70)
        NotifFrame.BackgroundColor3 = Theme.Container
        NotifFrame.Active = false
        NotifFrame.ZIndex = 300
        NotifFrame.Parent = ScreenGui
        addCorner(NotifFrame, 8)
        addStroke(NotifFrame, Theme.Outline, 1)

        local NTitle = Instance.new("TextLabel")
        NTitle.Size = UDim2.new(1, -30, 0, 18)
        NTitle.Position = UDim2.new(0, 10, 0, 8)
        NTitle.BackgroundTransparency = 1
        NTitle.Text = title
        applyFont(NTitle)
        NTitle.TextColor3 = Theme.Text
        NTitle.TextSize = 12
        NTitle.ZIndex = 301
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.Parent = NotifFrame

        local NDesc = Instance.new("TextLabel")
        NDesc.Size = UDim2.new(1, -30, 0, 26)
        NDesc.Position = UDim2.new(0, 10, 0, 26)
        NDesc.BackgroundTransparency = 1
        NDesc.Text = content
        applyFont(NDesc)
        NDesc.TextColor3 = Theme.SubText
        NDesc.TextSize = 10
        NDesc.ZIndex = 301
        NDesc.TextWrapped = true
        NDesc.TextXAlignment = Enum.TextXAlignment.Left
        NDesc.Parent = NotifFrame

        local CloseNBtn = Instance.new("TextButton")
        CloseNBtn.Size = UDim2.new(0, 18, 0, 18)
        CloseNBtn.Position = UDim2.new(1, -22, 0, 8)
        CloseNBtn.BackgroundTransparency = 1
        CloseNBtn.Text = "✕"
        applyFont(CloseNBtn)
        CloseNBtn.TextColor3 = Theme.SubText
        CloseNBtn.TextSize = 10
        CloseNBtn.ZIndex = 302
        CloseNBtn.Parent = NotifFrame

        local function dismiss()
            playSound(103061940249989)
            local fadeOut = TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 260, 1, -70)
            })
            fadeOut:Play()
            fadeOut.Completed:Connect(function() NotifFrame:Destroy() end)
        end

        CloseNBtn.MouseButton1Click:Connect(dismiss)

        TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -250, 1, -70)
        }):Play()

        task.delay(duration, function()
            if NotifFrame.Parent then dismiss() end
        end)
    end

    function Window:Tab(tabConfig)
        local tabName = typeof(tabConfig) == "table" and tabConfig.Title or tabConfig or "Tab"
        local tabIcon = typeof(tabConfig) == "table" and tabConfig.Icon or nil
        local TabMethods = { Name = tabName, Items = {} }

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabHolder
        addCorner(TabBtn, 8)

        local tabTextOffset = 12
        if tabIcon then
            tabTextOffset = 36
            local IconLabel = Instance.new("ImageLabel")
            IconLabel.Size = UDim2.new(0, 16, 0, 16)
            IconLabel.Position = UDim2.new(0, 10, 0.5, -8)
            IconLabel.BackgroundTransparency = 1
            IconLabel.Image = tabIcon
            IconLabel.ImageColor3 = Theme.SubText
            IconLabel.Parent = TabBtn
        end

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -tabTextOffset, 1, 0)
        TabLabel.Position = UDim2.new(0, tabTextOffset, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        applyFont(TabLabel)
        TabLabel.TextColor3 = Theme.SubText
        TabLabel.TextSize = 12
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Parent = ContentHolder

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 2)
        PagePadding.PaddingRight = UDim.new(0, 6)
        PagePadding.PaddingLeft = UDim.new(0, 2)
        PagePadding.Parent = Page

        local function selectTab()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Sidebar}):Play()
                TweenService:Create(t.TabLabel, TweenInfo.new(0.2), {TextColor3 = Theme.SubText}):Play()
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Container}):Play()
            TweenService:Create(TabLabel, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
        end

        TabBtn.MouseButton1Click:Connect(function()
            playSound(103061940249989)
            selectTab()
        end)

        function TabMethods:Section(secConfig)
            local titleText = typeof(secConfig) == "table" and secConfig.Title or secConfig
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, 0, 0, 20)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Text = string.upper(titleText)
            applyFont(Label)
            Label.TextColor3 = Theme.SubText
            Label.TextSize = 10
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SecFrame
        end

        function TabMethods:Paragraph(paraConfig)
            local titleText = paraConfig.Title or "Paragraph"
            local contentText = paraConfig.Content or ""

            local ParaFrame = Instance.new("Frame")
            ParaFrame.Size = UDim2.new(1, 0, 0, 0)
            ParaFrame.AutomaticSize = Enum.AutomaticSize.Y
            ParaFrame.BackgroundColor3 = Theme.Container
            ParaFrame.Parent = Page
            addCorner(ParaFrame, 8)
            addStroke(ParaFrame, Theme.Outline, 1)

            local Layout = Instance.new("UIListLayout")
            Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Layout.Padding = UDim.new(0, 4)
            Layout.Parent = ParaFrame

            local Padding = Instance.new("UIPadding")
            Padding.PaddingTop = UDim.new(0, 8)
            Padding.PaddingBottom = UDim.new(0, 8)
            Padding.PaddingLeft = UDim.new(0, 12)
            Padding.PaddingRight = UDim.new(0, 12)
            Padding.Parent = ParaFrame

            local TitleLab = Instance.new("TextLabel")
            TitleLab.Size = UDim2.new(1, 0, 0, 0)
            TitleLab.AutomaticSize = Enum.AutomaticSize.Y
            TitleLab.BackgroundTransparency = 1
            TitleLab.Text = titleText
            applyFont(TitleLab)
            TitleLab.TextColor3 = Theme.Text
            TitleLab.TextSize = 13
            TitleLab.TextXAlignment = Enum.TextXAlignment.Left
            TitleLab.TextWrapped = true
            TitleLab.LayoutOrder = 1
            TitleLab.Parent = ParaFrame

            if contentText ~= "" then
                local DescLab = Instance.new("TextLabel")
                DescLab.Size = UDim2.new(1, 0, 0, 0)
                DescLab.AutomaticSize = Enum.AutomaticSize.Y
                DescLab.BackgroundTransparency = 1
                DescLab.Text = contentText
                applyFont(DescLab)
                DescLab.TextColor3 = Theme.SubText
                DescLab.TextSize = 11
                DescLab.TextXAlignment = Enum.TextXAlignment.Left
                DescLab.TextWrapped = true
                DescLab.LayoutOrder = 2
                DescLab.Parent = ParaFrame
            end
            table.insert(TabMethods.Items, {Title = titleText, Instance = ParaFrame})
        end

        function TabMethods:Button(btnConfig)
            local btnTitle = btnConfig.Title or "Button"
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 36)
            BtnFrame.BackgroundColor3 = Theme.Container
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            BtnFrame.Parent = Page
            addCorner(BtnFrame, 8)
            addStroke(BtnFrame, Theme.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = btnTitle
            applyFont(Label)
            Label.TextColor3 = Theme.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BtnFrame

            BtnFrame.MouseButton1Click:Connect(function()
                playSound(103061940249989)
                TweenService:Create(BtnFrame, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Hover}):Play()
                task.wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Container}):Play()
                if btnConfig.Callback then task.spawn(btnConfig.Callback) end
            end)
            table.insert(TabMethods.Items, {Title = btnTitle, Instance = BtnFrame})
        end

        function TabMethods:Toggle(toggleConfig)
            local toggleId = toggleConfig.Title or "Toggle"
            local state = toggleConfig.Default or false

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
            ToggleFrame.BackgroundColor3 = Theme.Container
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = Page
            addCorner(ToggleFrame, 8)
            addStroke(ToggleFrame, Theme.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = toggleId
            applyFont(Label)
            Label.TextColor3 = Theme.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 38, 0, 20)
            Switch.Position = UDim2.new(1, -48, 0.5, -10)
            Switch.BackgroundColor3 = state and Theme.Accent or Theme.Outline
            Switch.Parent = ToggleFrame
            addCorner(Switch, 10)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Knob.BackgroundColor3 = Theme.Text
            Knob.Parent = Switch
            addCorner(Knob, 8)

            local function updateToggle()
                local switchColor = state and Theme.Accent or Theme.Outline
                local knobPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                TweenService:Create(Switch, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = switchColor}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = knobPos}):Play()
            end

            ToggleFrame.MouseButton1Click:Connect(function()
                playSound(122966251252708)
                state = not state
                updateToggle()
                if toggleConfig.Callback then task.spawn(toggleConfig.Callback, state) end
            end)
            
            if state and toggleConfig.Callback then task.spawn(toggleConfig.Callback, state) end
            table.insert(TabMethods.Items, {Title = toggleId, Instance = ToggleFrame})
        end

        function TabMethods:Slider(sliderConfig)
            local sliderId = sliderConfig.Title or "Slider"
            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 100
            local default = sliderConfig.Default or min

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 44)
            SliderFrame.BackgroundColor3 = Theme.Container
            SliderFrame.Parent = Page
            addCorner(SliderFrame, 8)
            addStroke(SliderFrame, Theme.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 0, 20)
            Label.Position = UDim2.new(0, 12, 0, 4)
            Label.BackgroundTransparency = 1
            Label.Text = sliderId
            applyFont(Label)
            Label.TextColor3 = Theme.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -62, 0, 4)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default)
            applyFont(ValueLabel)
            ValueLabel.TextColor3 = Theme.SubText
            ValueLabel.TextSize = 11
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame

            local BarTrack = Instance.new("TextButton")
            BarTrack.Size = UDim2.new(1, -24, 0, 4)
            BarTrack.Position = UDim2.new(0, 12, 0, 30)
            BarTrack.BackgroundColor3 = Theme.Outline
            BarTrack.Text = ""
            BarTrack.AutoButtonColor = false
            BarTrack.Parent = SliderFrame
            addCorner(BarTrack, 2)

            local BarFill = Instance.new("Frame")
            BarFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            BarFill.BackgroundColor3 = Theme.Accent
            BarFill.Parent = BarTrack
            addCorner(BarFill, 2)

            local sliding = false
            local function updateSlider(input)
                playSound(6275793198)
                local percentage = math.clamp((input.Position.X - BarTrack.AbsolutePosition.X) / BarTrack.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * percentage)
                ValueLabel.Text = tostring(val)
                BarFill.Size = UDim2.new(percentage, 0, 1, 0)
                if sliderConfig.Callback then task.spawn(sliderConfig.Callback, val) end
            end

            BarTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
            end)
            
            if sliderConfig.Callback then task.spawn(sliderConfig.Callback, default) end
            table.insert(TabMethods.Items, {Title = sliderId, Instance = SliderFrame})
        end

        local Tab = setmetatable({
            Page = Page,
            TabBtn = TabBtn,
            TabLabel = TabLabel,
            Items = TabMethods.Items,
            Name = tabName
        }, {
            __index = function(t, key)
                if TabMethods[key] then return TabMethods[key] end
                return function(...) end
            end
        })

        if not Window.ActiveTab then
            Window.ActiveTab = Tab
            selectTab()
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    return setmetatable(Window, {
        __index = function(t, key)
            warn("[SpawnRealmXUI Warning]: Missing window method '" .. tostring(key) .. "'. Ignored.")
            return function() end
        end
    })
end

return SpawnRealmXUI