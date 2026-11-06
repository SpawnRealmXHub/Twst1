-- // SpawnRealmXUI Library (Compact WindUI Size + Screen Tracking Resizer) \\ --
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SpawnRealmXUI = {
    Themes = {
        Background = Color3.fromRGB(13, 13, 16),
        Sidebar = Color3.fromRGB(18, 19, 24),
        Container = Color3.fromRGB(22, 24, 31),
        Accent = Color3.fromRGB(0, 140, 255),
        Text = Color3.fromRGB(245, 245, 247),
        SubText = Color3.fromRGB(150, 153, 168),
        Outline = Color3.fromRGB(38, 41, 52),
        Hover = Color3.fromRGB(28, 30, 39)
    }
}
SpawnRealmXUI.__index = SpawnRealmXUI

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
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
    local windowTitle = config.Title or "SpawnRealmXUI"
    local authorName = config.Author or "Developer"

    local Window = {
        Tabs = {},
        ActiveTab = nil
    }
    Window.__index = Window

    -- Secure GUI Setup
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

    -- Compact WindUI Dimensions (500x320) with Dynamic Scale Tracker
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
    MainFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    addCorner(MainFrame, 8)
    addStroke(MainFrame, SpawnRealmXUI.Themes.Outline, 1)

    -- Screen Tracker & Auto-Resizer Guard
    -- Detects viewport manipulation/tracking attempts and re-anchors proportions
    local UIScale = Instance.new("UIScale")
    UIScale.Parent = MainFrame

    local function updateScreenTracking()
        local viewportSize = Camera.ViewportSize
        -- If tracking software drops resolution or scales view abnormally, normalize UI scale factor
        if viewportSize.X < 800 or viewportSize.Y < 600 then
            UIScale.Scale = math.clamp(viewportSize.X / 1000, 0.75, 1)
        else
            UIScale.Scale = 1
        end
    end

    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScreenTracking)
    updateScreenTracking()

    -- Draggable Header Logic
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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

    -- Sidebar Container (Compact Width)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    addCorner(Sidebar, 8)

    -- Sidebar Title
    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Size = UDim2.new(1, -16, 0, 20)
    HeaderLabel.Position = UDim2.new(0, 10, 0, 12)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Text = windowTitle
    HeaderLabel.Font = Enum.Font.GothamBold
    HeaderLabel.TextColor3 = SpawnRealmXUI.Themes.Text
    HeaderLabel.TextSize = 13
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Parent = Sidebar

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(1, -16, 0, 16)
    SubLabel.Position = UDim2.new(0, 10, 0, 30)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "by " .. authorName
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextColor3 = SpawnRealmXUI.Themes.SubText
    SubLabel.TextSize = 10
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = Sidebar

    -- Tab Button Holder
    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Name = "TabHolder"
    TabHolder.Size = UDim2.new(1, -16, 1, -58)
    TabHolder.Position = UDim2.new(0, 8, 0, 52)
    TabHolder.BackgroundTransparency = 1
    TabHolder.ScrollBarThickness = 0
    TabHolder.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = TabHolder

    -- Content Holder Area
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -166, 1, -16)
    ContentHolder.Position = UDim2.new(0, 158, 0, 8)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    -- Tab Creator
    function Window:Tab(tabConfig)
        local tabName = typeof(tabConfig) == "table" and tabConfig.Title or tabConfig or "Tab"
        local TabMethods = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
        TabBtn.Text = "   " .. tabName
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextColor3 = SpawnRealmXUI.Themes.SubText
        TabBtn.TextSize = 12
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabHolder
        addCorner(TabBtn, 5)

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
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 2)
        PagePadding.PaddingRight = UDim.new(0, 4)
        PagePadding.PaddingLeft = UDim.new(0, 2)
        PagePadding.Parent = Page

        local function selectTab()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.TabBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar,
                    TextColor3 = SpawnRealmXUI.Themes.SubText
                }):Play()
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = SpawnRealmXUI.Themes.Container,
                TextColor3 = SpawnRealmXUI.Themes.Text
            }):Play()
        end

        TabBtn.MouseButton1Click:Connect(selectTab)

        -- Compact Component 1: Section Header
        function TabMethods:Section(secConfig)
            local titleText = typeof(secConfig) == "table" and secConfig.Title or secConfig
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, 0, 0, 20)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -6, 1, 0)
            Label.Position = UDim2.new(0, 2, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = string.upper(titleText)
            Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = SpawnRealmXUI.Themes.SubText
            Label.TextSize = 9
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SecFrame
        end

        -- Compact Component 2: Paragraph
        function TabMethods:Paragraph(paraConfig)
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Size = UDim2.new(1, 0, 0, 42)
            ParaFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            ParaFrame.Parent = Page
            addCorner(ParaFrame, 5)
            addStroke(ParaFrame, SpawnRealmXUI.Themes.Outline, 1)

            local TitleLab = Instance.new("TextLabel")
            TitleLab.Size = UDim2.new(1, -16, 0, 18)
            TitleLab.Position = UDim2.new(0, 10, 0, 4)
            TitleLab.BackgroundTransparency = 1
            TitleLab.Text = paraConfig.Title or "Paragraph"
            TitleLab.Font = Enum.Font.GothamBold
            TitleLab.TextColor3 = SpawnRealmXUI.Themes.Text
            TitleLab.TextSize = 12
            TitleLab.TextXAlignment = Enum.TextXAlignment.Left
            TitleLab.Parent = ParaFrame

            local DescLab = Instance.new("TextLabel")
            DescLab.Size = UDim2.new(1, -16, 0, 16)
            DescLab.Position = UDim2.new(0, 10, 0, 22)
            DescLab.BackgroundTransparency = 1
            DescLab.Text = paraConfig.Content or ""
            DescLab.Font = Enum.Font.Gotham
            DescLab.TextColor3 = SpawnRealmXUI.Themes.SubText
            DescLab.TextSize = 10
            DescLab.TextXAlignment = Enum.TextXAlignment.Left
            DescLab.Parent = ParaFrame
        end

        -- Compact Component 3: Divider
        function TabMethods:Divider()
            local Div = Instance.new("Frame")
            Div.Size = UDim2.new(1, 0, 0, 8)
            Div.BackgroundTransparency = 1
            Div.Parent = Page

            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(1, 0, 0, 1)
            Line.Position = UDim2.new(0, 0, 0.5, 0)
            Line.BackgroundColor3 = SpawnRealmXUI.Themes.Outline
            Line.BorderSizePixel = 0
            Line.Parent = Div
        end

        -- Compact Component 4: Button
        function TabMethods:Button(btnConfig)
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 32)
            BtnFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            BtnFrame.Parent = Page
            addCorner(BtnFrame, 5)
            addStroke(BtnFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -16, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = btnConfig.Title or "Button"
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BtnFrame

            BtnFrame.MouseButton1Click:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = SpawnRealmXUI.Themes.Accent}):Play()
                task.wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = SpawnRealmXUI.Themes.Container}):Play()
                if btnConfig.Callback then task.spawn(btnConfig.Callback) end
            end)
        end

        -- Compact Component 5: Toggle
        function TabMethods:Toggle(toggleConfig)
            local state = toggleConfig.Default or false

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
            ToggleFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = Page
            addCorner(ToggleFrame, 5)
            addStroke(ToggleFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -50, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = toggleConfig.Title or "Toggle"
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 30, 0, 16)
            Switch.Position = UDim2.new(1, -38, 0.5, -8)
            Switch.BackgroundColor3 = state and SpawnRealmXUI.Themes.Accent or SpawnRealmXUI.Themes.Outline
            Switch.Parent = ToggleFrame
            addCorner(Switch, 8)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 12, 0, 12)
            Knob.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            Knob.BackgroundColor3 = SpawnRealmXUI.Themes.Text
            Knob.Parent = Switch
            addCorner(Knob, 6)

            local function updateToggle()
                local switchColor = state and SpawnRealmXUI.Themes.Accent or SpawnRealmXUI.Themes.Outline
                local knobPos = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = switchColor}):Play()
                TweenService:Create(Knob, TweenInfo.new(0.2), {Position = knobPos}):Play()
            end

            ToggleFrame.MouseButton1Click:Connect(function()
                state = not state
                updateToggle()
                if toggleConfig.Callback then task.spawn(toggleConfig.Callback, state) end
            end)
        end

        -- Compact Component 6: Slider
        function TabMethods:Slider(sliderConfig)
            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 100
            local default = sliderConfig.Default or min

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 42)
            SliderFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            SliderFrame.Parent = Page
            addCorner(SliderFrame, 5)
            addStroke(SliderFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -50, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 3)
            Label.BackgroundTransparency = 1
            Label.Text = sliderConfig.Title or "Slider"
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 40, 0, 20)
            ValueLabel.Position = UDim2.new(1, -50, 0, 3)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextColor3 = SpawnRealmXUI.Themes.SubText
            ValueLabel.TextSize = 11
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame

            local BarTrack = Instance.new("TextButton")
            BarTrack.Size = UDim2.new(1, -20, 0, 5)
            BarTrack.Position = UDim2.new(0, 10, 0, 28)
            BarTrack.BackgroundColor3 = SpawnRealmXUI.Themes.Outline
            BarTrack.Text = ""
            BarTrack.AutoButtonColor = false
            BarTrack.Parent = SliderFrame
            addCorner(BarTrack, 3)

            local BarFill = Instance.new("Frame")
            BarFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            BarFill.BackgroundColor3 = SpawnRealmXUI.Themes.Accent
            BarFill.Parent = BarTrack
            addCorner(BarFill, 3)

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

        -- Set up protective Metatable
        local Tab = setmetatable({
            Page = Page,
            TabBtn = TabBtn
        }, {
            __index = function(t, key)
                if TabMethods[key] then
                    return TabMethods[key]
                end
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

    function Window:Notify(notifyConfig)
        -- Silent
    end

    return setmetatable(Window, Window)
end

return SpawnRealmXUI