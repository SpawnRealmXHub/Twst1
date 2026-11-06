-- // SpawnRealmXUI Library (WindUI Replica + Marketplace Font ID Support) \\ --
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SpawnRealmXUI = {
    Themes = {
        Background = Color3.fromRGB(15, 15, 18),
        Sidebar = Color3.fromRGB(20, 20, 24),
        Container = Color3.fromRGB(27, 27, 32),
        Accent = Color3.fromRGB(46, 204, 113),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(140, 142, 155),
        Outline = Color3.fromRGB(35, 35, 42),
        Hover = Color3.fromRGB(32, 32, 38)
    },
    CurrentFont = Font.fromEnum(Enum.Font.Gotham)
}
SpawnRealmXUI.__index = SpawnRealmXUI

-- Global Font Setter (Handles Asset IDs like 8764312106 or "rbxassetid://8764312106")
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

local function applyFont(textLabel, weight)
    if typeof(SpawnRealmXUI.CurrentFont) == "Font" then
        textLabel.FontFace = SpawnRealmXUI.CurrentFont
        if weight then
            textLabel.FontFace = Font.new(SpawnRealmXUI.CurrentFont.Family, weight)
        end
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
    stroke.Color = color or SpawnRealmXUI.Themes.Outline
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

    local Window = {
        Tabs = {},
        ActiveTab = nil,
        IsMinimized = false
    }
    Window.__index = Window

    -- Secure GUI Container
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

    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, winWidth, 0, winHeight)
    MainFrame.Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2)
    MainFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    addCorner(MainFrame, 14)
    addStroke(MainFrame, SpawnRealmXUI.Themes.Outline, 1)

    -- Dynamic Screen Resolution Scaling
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

    -- Window Controls Topbar Header
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 42)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainFrame

    -- Window Header Icon (Lucide / Roblox Asset ID)
    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Size = UDim2.new(0, 18, 0, 18)
    LogoIcon.Position = UDim2.new(0, 14, 0, 12)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = windowIcon
    LogoIcon.ImageColor3 = SpawnRealmXUI.Themes.Text
    LogoIcon.Parent = Topbar

    -- Title & Subtitle Labels
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 250, 0, 18)
    TitleLabel.Position = UDim2.new(0, 40, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = windowTitle
    applyFont(TitleLabel, Enum.FontWeight.Bold)
    TitleLabel.TextColor3 = SpawnRealmXUI.Themes.Text
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar

    local AuthorLabel = Instance.new("TextLabel")
    AuthorLabel.Size = UDim2.new(0, 250, 0, 14)
    AuthorLabel.Position = UDim2.new(0, 40, 0, 22)
    AuthorLabel.BackgroundTransparency = 1
    AuthorLabel.Text = "by " .. authorName
    applyFont(AuthorLabel, Enum.FontWeight.Regular)
    AuthorLabel.TextColor3 = SpawnRealmXUI.Themes.SubText
    AuthorLabel.TextSize = 10
    AuthorLabel.TextXAlignment = Enum.TextXAlignment.Left
    AuthorLabel.Parent = Topbar

    -- Window Controls (Minimize, Expand, Close)
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
        applyFont(Btn, Enum.FontWeight.Bold)
        Btn.TextColor3 = SpawnRealmXUI.Themes.SubText
        Btn.TextSize = 12
        Btn.Parent = ControlHolder

        Btn.MouseEnter:Connect(function() Btn.TextColor3 = SpawnRealmXUI.Themes.Text end)
        Btn.MouseLeave:Connect(function() Btn.TextColor3 = SpawnRealmXUI.Themes.SubText end)
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

    -- Draggable Topbar Logic
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            TweenService:Create(MainFrame, TweenInfo.new(0.05), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)

    -- Sidebar Container
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, -50)
    Sidebar.Position = UDim2.new(0, 10, 0, 42)
    Sidebar.BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    addCorner(Sidebar, 10)

    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Size = UDim2.new(1, -12, 1, -12)
    TabHolder.Position = UDim2.new(0, 6, 0, 6)
    TabHolder.BackgroundTransparency = 1
    TabHolder.ScrollBarThickness = 0
    TabHolder.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = TabHolder

    -- Main Content Display Panel
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -186, 1, -50)
    ContentHolder.Position = UDim2.new(0, 176, 0, 42)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    -- Tab Builder Method
    function Window:Tab(tabConfig)
        local tabName = typeof(tabConfig) == "table" and tabConfig.Title or tabConfig or "Tab"
        local tabIcon = typeof(tabConfig) == "table" and tabConfig.Icon or nil
        local TabMethods = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
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
            IconLabel.ImageColor3 = SpawnRealmXUI.Themes.SubText
            IconLabel.Parent = TabBtn
        end

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -tabTextOffset, 1, 0)
        TabLabel.Position = UDim2.new(0, tabTextOffset, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        applyFont(TabLabel, Enum.FontWeight.Medium)
        TabLabel.TextColor3 = SpawnRealmXUI.Themes.SubText
        TabLabel.TextSize = 12
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = SpawnRealmXUI.Themes.Accent
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
                TweenService:Create(t.TabBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
                }):Play()
                TweenService:Create(t.TabLabel, TweenInfo.new(0.2), {
                    TextColor3 = SpawnRealmXUI.Themes.SubText
                }):Play()
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = SpawnRealmXUI.Themes.Container
            }):Play()
            TweenService:Create(TabLabel, TweenInfo.new(0.2), {
                TextColor3 = SpawnRealmXUI.Themes.Text
            }):Play()
        end

        TabBtn.MouseButton1Click:Connect(selectTab)

        -- Section Component
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
            applyFont(Label, Enum.FontWeight.Bold)
            Label.TextColor3 = SpawnRealmXUI.Themes.SubText
            Label.TextSize = 10
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SecFrame
        end

        -- Paragraph Component
        function TabMethods:Paragraph(paraConfig)
            local titleText = paraConfig.Title or "Paragraph"
            local contentText = paraConfig.Content or ""

            local ParaFrame = Instance.new("Frame")
            ParaFrame.Size = UDim2.new(1, 0, 0, 0)
            ParaFrame.AutomaticSize = Enum.AutomaticSize.Y
            ParaFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            ParaFrame.Parent = Page
            addCorner(ParaFrame, 8)
            addStroke(ParaFrame, SpawnRealmXUI.Themes.Outline, 1)

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
            applyFont(TitleLab, Enum.FontWeight.Bold)
            TitleLab.TextColor3 = SpawnRealmXUI.Themes.Text
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
                applyFont(DescLab, Enum.FontWeight.Regular)
                DescLab.TextColor3 = SpawnRealmXUI.Themes.SubText
                DescLab.TextSize = 11
                DescLab.TextXAlignment = Enum.TextXAlignment.Left
                DescLab.TextWrapped = true
                DescLab.LayoutOrder = 2
                DescLab.Parent = ParaFrame
            end
        end

        -- Divider Component
        function TabMethods:Divider()
            local Div = Instance.new("Frame")
            Div.Size = UDim2.new(1, 0, 0, 6)
            Div.BackgroundTransparency = 1
            Div.Parent = Page

            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(1, 0, 0, 1)
            Line.Position = UDim2.new(0, 0, 0.5, 0)
            Line.BackgroundColor3 = SpawnRealmXUI.Themes.Outline
            Line.BorderSizePixel = 0
            Line.Parent = Div
        end

        -- Button Component
        function TabMethods:Button(btnConfig)
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 36)
            BtnFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            BtnFrame.Parent = Page
            addCorner(BtnFrame, 8)
            addStroke(BtnFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = btnConfig.Title or "Button"
            applyFont(Label, Enum.FontWeight.Medium)
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BtnFrame

            BtnFrame.MouseButton1Click:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = SpawnRealmXUI.Themes.Hover}):Play()
                task.wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = SpawnRealmXUI.Themes.Container}):Play()
                if btnConfig.Callback then task.spawn(btnConfig.Callback) end
            end)
        end

        -- Toggle Component
        function TabMethods:Toggle(toggleConfig)
            local state = toggleConfig.Default or false

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
            ToggleFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = Page
            addCorner(ToggleFrame, 8)
            addStroke(ToggleFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = toggleConfig.Title or "Toggle"
            applyFont(Label, Enum.FontWeight.Medium)
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 38, 0, 20)
            Switch.Position = UDim2.new(1, -48, 0.5, -10)
            Switch.BackgroundColor3 = state and SpawnRealmXUI.Themes.Accent or SpawnRealmXUI.Themes.Outline
            Switch.Parent = ToggleFrame
            addCorner(Switch, 10)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Knob.BackgroundColor3 = SpawnRealmXUI.Themes.Text
            Knob.Parent = Switch
            addCorner(Knob, 8)

            local function updateToggle()
                local switchColor = state and SpawnRealmXUI.Themes.Accent or SpawnRealmXUI.Themes.Outline
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

        -- Slider Component
        function TabMethods:Slider(sliderConfig)
            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 100
            local default = sliderConfig.Default or min

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 44)
            SliderFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            SliderFrame.Parent = Page
            addCorner(SliderFrame, 8)
            addStroke(SliderFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 0, 20)
            Label.Position = UDim2.new(0, 12, 0, 4)
            Label.BackgroundTransparency = 1
            Label.Text = sliderConfig.Title or "Slider"
            applyFont(Label, Enum.FontWeight.Medium)
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -62, 0, 4)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default)
            applyFont(ValueLabel, Enum.FontWeight.Regular)
            ValueLabel.TextColor3 = SpawnRealmXUI.Themes.SubText
            ValueLabel.TextSize = 11
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame

            local BarTrack = Instance.new("TextButton")
            BarTrack.Size = UDim2.new(1, -24, 0, 4)
            BarTrack.Position = UDim2.new(0, 12, 0, 30)
            BarTrack.BackgroundColor3 = SpawnRealmXUI.Themes.Outline
            BarTrack.Text = ""
            BarTrack.AutoButtonColor = false
            BarTrack.Parent = SliderFrame
            addCorner(BarTrack, 2)

            local BarFill = Instance.new("Frame")
            BarFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            BarFill.BackgroundColor3 = SpawnRealmXUI.Themes.Accent
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
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
            end)
        end

        -- Safe Metatable
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

    function Window:Notify(notifyConfig) end

    return setmetatable(Window, Window)
end

return SpawnRealmXUI
}
SpawnRealmXUI.__index = SpawnRealmXUI

-- Global Font Setter
function SpawnRealmXUI:SetFont(fontAsset)
    if typeof(fontAsset) == "EnumItem" then
        SpawnRealmXUI.CurrentFont = fontAsset
    elseif typeof(fontAsset) == "string" then
        -- Supports custom rbxassetid fonts if executor permits, or falls back safely
        SpawnRealmXUI.CurrentFont = fontAsset
    end
end

local function applyFont(textLabel, weight)
    if typeof(SpawnRealmXUI.CurrentFont) == "EnumItem" then
        textLabel.Font = SpawnRealmXUI.CurrentFont
    else
        -- If custom font asset string is passed
        textLabel.FontFace = Font.new(SpawnRealmXUI.CurrentFont, weight or Enum.FontWeight.Regular)
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
    stroke.Color = color or SpawnRealmXUI.Themes.Outline
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
    local winHeight = config.Height | 390 or config.Height or 390
    local windowIcon = config.Icon or "rbxassetid://6031097225"

    local Window = {
        Tabs = {},
        ActiveTab = nil,
        IsMinimized = false
    }
    Window.__index = Window

    -- Secure GUI Container
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

    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, winWidth, 0, winHeight)
    MainFrame.Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2)
    MainFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    addCorner(MainFrame, 14)
    addStroke(MainFrame, SpawnRealmXUI.Themes.Outline, 1)

    -- Dynamic Screen Resolution Scaling
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

    -- Window Controls Topbar Header
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 42)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = MainFrame

    -- Window Header Icon (Supports Lucide / Roblox Asset ID)
    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Size = UDim2.new(0, 18, 0, 18)
    LogoIcon.Position = UDim2.new(0, 14, 0, 12)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = windowIcon
    LogoIcon.ImageColor3 = SpawnRealmXUI.Themes.Text
    LogoIcon.Parent = Topbar

    -- Title & Subtitle Labels
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 250, 0, 18)
    TitleLabel.Position = UDim2.new(0, 40, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = windowTitle
    applyFont(TitleLabel, Enum.FontWeight.Bold)
    TitleLabel.TextColor3 = SpawnRealmXUI.Themes.Text
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar

    local AuthorLabel = Instance.new("TextLabel")
    AuthorLabel.Size = UDim2.new(0, 250, 0, 14)
    AuthorLabel.Position = UDim2.new(0, 40, 0, 22)
    AuthorLabel.BackgroundTransparency = 1
    AuthorLabel.Text = "by " .. authorName
    applyFont(AuthorLabel, Enum.FontWeight.Regular)
    AuthorLabel.TextColor3 = SpawnRealmXUI.Themes.SubText
    AuthorLabel.TextSize = 10
    AuthorLabel.TextXAlignment = Enum.TextXAlignment.Left
    AuthorLabel.Parent = Topbar

    -- Window Controls (Minimize, Maximize, Close)
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
        applyFont(Btn, Enum.FontWeight.Bold)
        Btn.TextColor3 = SpawnRealmXUI.Themes.SubText
        Btn.TextSize = 12
        Btn.Parent = ControlHolder

        Btn.MouseEnter:Connect(function() Btn.TextColor3 = SpawnRealmXUI.Themes.Text end)
        Btn.MouseLeave:Connect(function() Btn.TextColor3 = SpawnRealmXUI.Themes.SubText end)
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

    -- Draggable Topbar Logic
    local dragging, dragStart, startPos
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            TweenService:Create(MainFrame, TweenInfo.new(0.05), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)

    -- Sidebar Container
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, -50)
    Sidebar.Position = UDim2.new(0, 10, 0, 42)
    Sidebar.BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    addCorner(Sidebar, 10)

    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Size = UDim2.new(1, -12, 1, -12)
    TabHolder.Position = UDim2.new(0, 6, 0, 6)
    TabHolder.BackgroundTransparency = 1
    TabHolder.ScrollBarThickness = 0
    TabHolder.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = TabHolder

    -- Main Content Display Panel
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -186, 1, -50)
    ContentHolder.Position = UDim2.new(0, 176, 0, 42)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    -- Tab Builder Method (Supports Icons)
    function Window:Tab(tabConfig)
        local tabName = typeof(tabConfig) == "table" and tabConfig.Title or tabConfig or "Tab"
        local tabIcon = typeof(tabConfig) == "table" and tabConfig.Icon or nil
        local TabMethods = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
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
            IconLabel.ImageColor3 = SpawnRealmXUI.Themes.SubText
            IconLabel.Parent = TabBtn
        end

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -tabTextOffset, 1, 0)
        TabLabel.Position = UDim2.new(0, tabTextOffset, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        applyFont(TabLabel, Enum.FontWeight.Medium)
        TabLabel.TextColor3 = SpawnRealmXUI.Themes.SubText
        TabLabel.TextSize = 12
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = SpawnRealmXUI.Themes.Accent
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
                TweenService:Create(t.TabBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
                }):Play()
                TweenService:Create(t.TabLabel, TweenInfo.new(0.2), {
                    TextColor3 = SpawnRealmXUI.Themes.SubText
                }):Play()
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = SpawnRealmXUI.Themes.Container
            }):Play()
            TweenService:Create(TabLabel, TweenInfo.new(0.2), {
                TextColor3 = SpawnRealmXUI.Themes.Text
            }):Play()
        end

        TabBtn.MouseButton1Click:Connect(selectTab)

        -- Section Component
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
            applyFont(Label, Enum.FontWeight.Bold)
            Label.TextColor3 = SpawnRealmXUI.Themes.SubText
            Label.TextSize = 10
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SecFrame
        end

        -- Paragraph Component (Auto-Height Fix)
        function TabMethods:Paragraph(paraConfig)
            local titleText = paraConfig.Title or "Paragraph"
            local contentText = paraConfig.Content or ""

            local ParaFrame = Instance.new("Frame")
            ParaFrame.Size = UDim2.new(1, 0, 0, 0)
            ParaFrame.AutomaticSize = Enum.AutomaticSize.Y
            ParaFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            ParaFrame.Parent = Page
            addCorner(ParaFrame, 8)
            addStroke(ParaFrame, SpawnRealmXUI.Themes.Outline, 1)

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
            applyFont(TitleLab, Enum.FontWeight.Bold)
            TitleLab.TextColor3 = SpawnRealmXUI.Themes.Text
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
                applyFont(DescLab, Enum.FontWeight.Regular)
                DescLab.TextColor3 = SpawnRealmXUI.Themes.SubText
                DescLab.TextSize = 11
                DescLab.TextXAlignment = Enum.TextXAlignment.Left
                DescLab.TextWrapped = true
                DescLab.LayoutOrder = 2
                DescLab.Parent = ParaFrame
            end
        end

        -- Divider Component
        function TabMethods:Divider()
            local Div = Instance.new("Frame")
            Div.Size = UDim2.new(1, 0, 0, 6)
            Div.BackgroundTransparency = 1
            Div.Parent = Page

            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(1, 0, 0, 1)
            Line.Position = UDim2.new(0, 0, 0.5, 0)
            Line.BackgroundColor3 = SpawnRealmXUI.Themes.Outline
            Line.BorderSizePixel = 0
            Line.Parent = Div
        end

        -- Button Component
        function TabMethods:Button(btnConfig)
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 36)
            BtnFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            BtnFrame.Parent = Page
            addCorner(BtnFrame, 8)
            addStroke(BtnFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = btnConfig.Title or "Button"
            applyFont(Label, Enum.FontWeight.Medium)
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BtnFrame

            BtnFrame.MouseButton1Click:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = SpawnRealmXUI.Themes.Hover}):Play()
                task.wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = SpawnRealmXUI.Themes.Container}):Play()
                if btnConfig.Callback then task.spawn(btnConfig.Callback) end
            end)
        end

        -- Toggle Component
        function TabMethods:Toggle(toggleConfig)
            local state = toggleConfig.Default or false

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
            ToggleFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = Page
            addCorner(ToggleFrame, 8)
            addStroke(ToggleFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = toggleConfig.Title or "Toggle"
            applyFont(Label, Enum.FontWeight.Medium)
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 38, 0, 20)
            Switch.Position = UDim2.new(1, -48, 0.5, -10)
            Switch.BackgroundColor3 = state and SpawnRealmXUI.Themes.Accent or SpawnRealmXUI.Themes.Outline
            Switch.Parent = ToggleFrame
            addCorner(Switch, 10)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Knob.BackgroundColor3 = SpawnRealmXUI.Themes.Text
            Knob.Parent = Switch
            addCorner(Knob, 8)

            local function updateToggle()
                local switchColor = state and SpawnRealmXUI.Themes.Accent or SpawnRealmXUI.Themes.Outline
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

        -- Slider Component
        function TabMethods:Slider(sliderConfig)
            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 100
            local default = sliderConfig.Default or min

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 44)
            SliderFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            SliderFrame.Parent = Page
            addCorner(SliderFrame, 8)
            addStroke(SliderFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 0, 20)
            Label.Position = UDim2.new(0, 12, 0, 4)
            Label.BackgroundTransparency = 1
            Label.Text = sliderConfig.Title or "Slider"
            applyFont(Label, Enum.FontWeight.Medium)
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -62, 0, 4)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default)
            applyFont(ValueLabel, Enum.FontWeight.Regular)
            ValueLabel.TextColor3 = SpawnRealmXUI.Themes.SubText
            ValueLabel.TextSize = 11
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame

            local BarTrack = Instance.new("TextButton")
            BarTrack.Size = UDim2.new(1, -24, 0, 4)
            BarTrack.Position = UDim2.new(0, 12, 0, 30)
            BarTrack.BackgroundColor3 = SpawnRealmXUI.Themes.Outline
            BarTrack.Text = ""
            BarTrack.AutoButtonColor = false
            BarTrack.Parent = SliderFrame
            addCorner(BarTrack, 2)

            local BarFill = Instance.new("Frame")
            BarFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            BarFill.BackgroundColor3 = SpawnRealmXUI.Themes.Accent
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
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
            end)
        end

        -- Safe Fallback Metatable
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

    function Window:Notify(notifyConfig) end

    return setmetatable(Window, Window)
end

return SpawnRealmXUI