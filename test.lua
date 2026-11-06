-- // SpawnRealmXUI Library (Ultimate WindUI Replica with Profile Card, Transparency, Custom Asset Themes & Toasts) \\ --
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
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
    
    -- Theme & Custom Asset Background Resolver
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
        IsMinimized = false
    }
    
    setmetatable(Window, {
        __index = function(t, key)
            warn("[SpawnRealmXUI Warning]: CreateWindow missing method or property '" .. tostring(key) .. "'. Ignored.")
            return function() end
        end
    })

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

    -- Custom Background Image Layer if asset ID provided
    if customBgAsset then
        local BgImage = Instance.new("ImageLabel")
        BgImage.Size = UDim2.new(1, 0, 1, 0)
        BgImage.BackgroundTransparency = 1
        BgImage.Image = customBgAsset
        BgImage.ScaleType = Enum.ScaleType.Slice
        BgImage.ImageTransparency = transparencyVal * 0.5
        BgImage.Parent = MainFrame
    end

    local UIScale = Instance.new("UIScale")
    UIScale.Parent = MainFrame

    local function updateScreenTracking()
        local viewportSize = Camera.ViewportSize
        if viewportSize.X < 900 or viewportSize.Y < 600 then
            UIScale.Scale = math.clamp(viewportSize.X / 1000, 0.75, 1)
        else
            UIScale.Scale = 1
        end
    end
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScreenTracking)
    updateScreenTracking()

    -- Draggable Topbar Header
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
    LogoIcon.ImageTransparency = transparencyVal
    LogoIcon.Parent = Topbar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 250, 0, 18)
    TitleLabel.Position = UDim2.new(0, 40, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = windowTitle
    applyFont(TitleLabel)
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextTransparency = transparencyVal
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
    AuthorLabel.TextTransparency = transparencyVal
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
        Btn.TextTransparency = transparencyVal
        Btn.TextSize = 12
        Btn.Parent = ControlHolder

        Btn.MouseEnter:Connect(function() Btn.TextColor3 = Theme.Text end)
        Btn.MouseLeave:Connect(function() Btn.TextColor3 = Theme.SubText end)
        Btn.MouseButton1Click:Connect(callback)
        return Btn
    end

    createControlButton("—", 0, function()
        Window.IsMinimized = not Window.IsMinimized
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = Window.IsMinimized and UDim2.new(0, winWidth, 0, 42) or UDim2.new(0, winWidth, 0, winHeight)
        }):Play()
    end)

    createControlButton("⸌⸍", 30, function() end)

    createControlButton("✕", 60, function()
        ScreenGui:Destroy()
    end)

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
            TweenService:Create(MainFrame, TweenInfo.new(0.02), {
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

    -- Sidebar User Profile Card (from Screenshot)
    local ProfileCard = Instance.new("Frame")
    ProfileCard.Size = UDim2.new(1, -12, 0, 48)
    ProfileCard.Position = UDim2.new(0, 6, 1, -54)
    ProfileCard.BackgroundColor3 = Theme.Container
    ProfileCard.BackgroundTransparency = transparencyVal
    ProfileCard.Parent = Sidebar
    addCorner(ProfileCard, 8)
    addStroke(ProfileCard, Theme.Outline, 1)

    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.Size = UDim2.new(0, 32, 0, 32)
    AvatarImg.Position = UDim2.new(0, 8, 0.5, -16)
    AvatarImg.BackgroundColor3 = Theme.Outline
    AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size42x42)
    AvatarImg.Parent = ProfileCard
    addCorner(AvatarImg, 16)

    local DispNameLab = Instance.new("TextLabel")
    DispNameLab.Size = UDim2.new(1, -48, 0, 16)
    DispNameLab.Position = UDim2.new(0, 46, 0, 8)
    DispNameLab.BackgroundTransparency = 1
    DispNameLab.Text = LocalPlayer.DisplayName
    applyFont(DispNameLab)
    DispNameLab.TextColor3 = Theme.Text
    DispNameLab.TextTransparency = transparencyVal
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
    UserLab.TextTransparency = transparencyVal
    UserLab.TextSize = 10
    UserLab.TextXAlignment = Enum.TextXAlignment.Left
    UserLab.Parent = ProfileCard

    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Size = UDim2.new(1, -12, 1, -66)
    TabHolder.Position = UDim2.new(0, 6, 0, 6)
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

    -- Top-Middle Toast Notification System
    function Window:Notify(notifyConfig)
        notifyConfig = notifyConfig or {}
        local title = notifyConfig.Title or "Notification"
        local content = notifyConfig.Content or ""
        local useRobloxHeadshot = notifyConfig.Identity or false
        local duration = notifyConfig.Duration or 3

        local Toast = Instance.new("Frame")
        Toast.Name = "ToastNotification"
        Toast.Size = UDim2.new(0, 240, 0, 48)
        Toast.Position = UDim2.new(0.5, -120, 0, -60)
        Toast.BackgroundColor3 = Theme.Container
        Toast.BackgroundTransparency = transparencyVal
        Toast.ZIndex = 100
        Toast.Parent = ScreenGui
        addCorner(Toast, 24) -- Pill shape
        addStroke(Toast, Theme.Accent, 1.5)

        local thumbType = useRobloxHeadshot and Enum.ThumbnailType.HeadShot or Enum.ThumbnailType.AvatarBust
        local thumbSize = Enum.ThumbnailSize.Size42x42
        local thumbUrl = Players:GetUserThumbnailAsync(LocalPlayer.UserId, thumbType, thumbSize)

        local Mugshot = Instance.new("ImageLabel")
        Mugshot.Size = UDim2.new(0, 36, 0, 36)
        Mugshot.Position = UDim2.new(0, 6, 0.5, -18)
        Mugshot.BackgroundColor3 = Theme.Outline
        Mugshot.Image = thumbUrl
        Mugshot.ZIndex = 101
        Mugshot.Parent = Toast
        addCorner(Mugshot, 18)

        local TTitle = Instance.new("TextLabel")
        TTitle.Size = UDim2.new(1, -50, 0, 18)
        TTitle.Position = UDim2.new(0, 48, 0, 7)
        TTitle.BackgroundTransparency = 1
        TTitle.Text = title
        applyFont(TTitle)
        TTitle.TextColor3 = Theme.Text
        TTitle.TextSize = 12
        TTitle.ZIndex = 101
        TTitle.TextXAlignment = Enum.TextXAlignment.Left
        TTitle.Parent = Toast

        local TDesc = Instance.new("TextLabel")
        TDesc.Size = UDim2.new(1, -50, 0, 16)
        TDesc.Position = UDim2.new(0, 48, 0, 23)
        TDesc.BackgroundTransparency = 1
        TDesc.Text = content
        applyFont(TDesc)
        TDesc.TextColor3 = Theme.SubText
        TDesc.TextSize = 10
        TDesc.ZIndex = 101
        TDesc.TextXAlignment = Enum.TextXAlignment.Left
        TDesc.Parent = Toast

        -- Slide Down to Top Middle
        TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -120, 0, 16)
        }):Play()

        task.delay(duration, function()
            local fadeOut = TweenService:Create(Toast, TweenInfo.new(0.3), {
                Position = UDim2.new(0.5, -120, 0, -60)
            })
            fadeOut:Play()
            fadeOut.Completed:Connect(function() Toast:Destroy() end)
        end)
    end

    function Window:Tab(tabConfig)
        local tabName = typeof(tabConfig) == "table" and tabConfig.Title or tabConfig or "Tab"
        local tabIcon = typeof(tabConfig) == "table" and tabConfig.Icon or nil
        local TabMethods = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.BackgroundTransparency = transparencyVal
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
        TabLabel.TextTransparency = transparencyVal
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

        TabBtn.MouseButton1Click:Connect(selectTab)

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
            Label.TextTransparency = transparencyVal
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
            ParaFrame.BackgroundTransparency = transparencyVal
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
            TitleLab.TextTransparency = transparencyVal
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
                DescLab.TextTransparency = transparencyVal
                DescLab.TextSize = 11
                DescLab.TextXAlignment = Enum.TextXAlignment.Left
                DescLab.TextWrapped = true
                DescLab.LayoutOrder = 2
                DescLab.Parent = ParaFrame
            end
        end

        function TabMethods:Divider()
            local Div = Instance.new("Frame")
            Div.Size = UDim2.new(1, 0, 0, 6)
            Div.BackgroundTransparency = 1
            Div.Parent = Page

            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(1, 0, 0, 1)
            Line.Position = UDim2.new(0, 0, 0.5, 0)
            Line.BackgroundColor3 = Theme.Outline
            Line.BorderSizePixel = 0
            Line.Parent = Div
        end

        function TabMethods:Button(btnConfig)
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 36)
            BtnFrame.BackgroundColor3 = Theme.Container
            BtnFrame.BackgroundTransparency = transparencyVal
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            BtnFrame.Parent = Page
            addCorner(BtnFrame, 8)
            addStroke(BtnFrame, Theme.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = btnConfig.Title or "Button"
            applyFont(Label)
            Label.TextColor3 = Theme.Text
            Label.TextTransparency = transparencyVal
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BtnFrame

            BtnFrame.MouseButton1Click:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Hover}):Play()
                task.wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Container}):Play()
                if btnConfig.Callback then task.spawn(btnConfig.Callback) end
            end)
        end

        function TabMethods:Toggle(toggleConfig)
            local state = toggleConfig.Default or false

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
            ToggleFrame.BackgroundColor3 = Theme.Container
            ToggleFrame.BackgroundTransparency = transparencyVal
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = Page
            addCorner(ToggleFrame, 8)
            addStroke(ToggleFrame, Theme.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = toggleConfig.Title or "Toggle"
            applyFont(Label)
            Label.TextColor3 = Theme.Text
            Label.TextTransparency = transparencyVal
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
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = switchColor}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.2), {Position = knobPos}):Play()
            end

            ToggleFrame.MouseButton1Click:Connect(function()
                state = not state
                updateToggle()
                if toggleConfig.Callback then task.spawn(toggleConfig.Callback, state) end
            end)
        end

        function TabMethods:Slider(sliderConfig)
            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 100
            local default = sliderConfig.Default or min

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 44)
            SliderFrame.BackgroundColor3 = Theme.Container
            SliderFrame.BackgroundTransparency = transparencyVal
            SliderFrame.Parent = Page
            addCorner(SliderFrame, 8)
            addStroke(SliderFrame, Theme.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 0, 20)
            Label.Position = UDim2.new(0, 12, 0, 4)
            Label.BackgroundTransparency = 1
            Label.Text = sliderConfig.Title or "Slider"
            applyFont(Label)
            Label.TextColor3 = Theme.Text
            Label.TextTransparency = transparencyVal
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
            ValueLabel.TextTransparency = transparencyVal
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
        end

        local Tab = setmetatable({
            Page = Page,
            TabBtn = TabBtn,
            TabLabel = TabLabel
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

    return setmetatable(Window, Window)
end

return SpawnRealmXUI