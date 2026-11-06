-- // SpawnRealmXUI Library (Silent / No-Toast Source) \\ --
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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
    corner.CornerRadius = UDim.new(0, radius or 8)
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

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 620, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
    MainFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    addCorner(MainFrame, 10)
    addStroke(MainFrame, SpawnRealmXUI.Themes.Outline, 1)

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

    -- Sidebar Container
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 190, 1, 0)
    Sidebar.BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    addCorner(Sidebar, 10)

    -- Sidebar Title
    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Size = UDim2.new(1, -20, 0, 25)
    HeaderLabel.Position = UDim2.new(0, 15, 0, 15)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Text = windowTitle
    HeaderLabel.Font = Enum.Font.GothamBold
    HeaderLabel.TextColor3 = SpawnRealmXUI.Themes.Text
    HeaderLabel.TextSize = 15
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Parent = Sidebar

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(1, -20, 0, 18)
    SubLabel.Position = UDim2.new(0, 15, 0, 38)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "by " .. authorName
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextColor3 = SpawnRealmXUI.Themes.SubText
    SubLabel.TextSize = 11
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = Sidebar

    -- Tab Button Holder
    local TabHolder = Instance.new("ScrollingFrame")
    TabHolder.Name = "TabHolder"
    TabHolder.Size = UDim2.new(1, -20, 1, -70)
    TabHolder.Position = UDim2.new(0, 10, 0, 65)
    TabHolder.BackgroundTransparency = 1
    TabHolder.ScrollBarThickness = 0
    TabHolder.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.Parent = TabHolder

    -- Content Holder Area
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(1, -210, 1, -20)
    ContentHolder.Position = UDim2.new(0, 200, 0, 10)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = MainFrame

    -- Tab Creator
    function Window:Tab(tabConfig)
        local tabName = typeof(tabConfig) == "table" and tabConfig.Title or tabConfig or "Tab"
        
        local TabMethods = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
        TabBtn.Text = "   " .. tabName
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextColor3 = SpawnRealmXUI.Themes.SubText
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabHolder
        addCorner(TabBtn, 6)

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

        -- Component 1: Section Header
        function TabMethods:Section(secConfig)
            local titleText = typeof(secConfig) == "table" and secConfig.Title or secConfig
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, 0, 0, 24)
            SecFrame.BackgroundTransparency = 1
            SecFrame.Parent = Page

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 1, 0)
            Label.Position = UDim2.new(0, 4, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = string.upper(titleText)
            Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = SpawnRealmXUI.Themes.SubText
            Label.TextSize = 10
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SecFrame
        end

        -- Component 2: Paragraph / Text Label
        function TabMethods:Paragraph(paraConfig)
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Size = UDim2.new(1, 0, 0, 52)
            ParaFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            ParaFrame.Parent = Page
            addCorner(ParaFrame, 6)
            addStroke(ParaFrame, SpawnRealmXUI.Themes.Outline, 1)

            local TitleLab = Instance.new("TextLabel")
            TitleLab.Size = UDim2.new(1, -20, 0, 20)
            TitleLab.Position = UDim2.new(0, 12, 0, 6)
            TitleLab.BackgroundTransparency = 1
            TitleLab.Text = paraConfig.Title or "Paragraph"
            TitleLab.Font = Enum.Font.GothamBold
            TitleLab.TextColor3 = SpawnRealmXUI.Themes.Text
            TitleLab.TextSize = 13
            TitleLab.TextXAlignment = Enum.TextXAlignment.Left
            TitleLab.Parent = ParaFrame

            local DescLab = Instance.new("TextLabel")
            DescLab.Size = UDim2.new(1, -20, 0, 18)
            DescLab.Position = UDim2.new(0, 12, 0, 26)
            DescLab.BackgroundTransparency = 1
            DescLab.Text = paraConfig.Content or ""
            DescLab.Font = Enum.Font.Gotham
            DescLab.TextColor3 = SpawnRealmXUI.Themes.SubText
            DescLab.TextSize = 11
            DescLab.TextXAlignment = Enum.TextXAlignment.Left
            DescLab.Parent = ParaFrame
        end

        -- Component 3: Divider Line
        function TabMethods:Divider()
            local Div = Instance.new("Frame")
            Div.Size = UDim2.new(1, 0, 0, 10)
            Div.BackgroundTransparency = 1
            Div.Parent = Page

            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(1, 0, 0, 1)
            Line.Position = UDim2.new(0, 0, 0.5, 0)
            Line.BackgroundColor3 = SpawnRealmXUI.Themes.Outline
            Line.BorderSizePixel = 0
            Line.Parent = Div
        end

        -- Component 4: Button
        function TabMethods:Button(btnConfig)
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 38)
            BtnFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            BtnFrame.Parent = Page
            addCorner(BtnFrame, 6)
            addStroke(BtnFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = btnConfig.Title or "Button"
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BtnFrame

            BtnFrame.MouseButton1Click:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = SpawnRealmXUI.Themes.Accent}):Play()
                task.wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = SpawnRealmXUI.Themes.Container}):Play()
                if btnConfig.Callback then task.spawn(btnConfig.Callback) end
            end)
        end

        -- Component 5: Toggle Switch
        function TabMethods:Toggle(toggleConfig)
            local state = toggleConfig.Default or false

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
            ToggleFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = Page
            addCorner(ToggleFrame, 6)
            addStroke(ToggleFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = toggleConfig.Title or "Toggle"
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 36, 0, 20)
            Switch.Position = UDim2.new(1, -44, 0.5, -10)
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

        -- Component 6: Interactive Slider
        function TabMethods:Slider(sliderConfig)
            local min = sliderConfig.Min or 0
            local max = sliderConfig.Max or 100
            local default = sliderConfig.Default or min

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            SliderFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            SliderFrame.Parent = Page
            addCorner(SliderFrame, 6)
            addStroke(SliderFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 0, 24)
            Label.Position = UDim2.new(0, 12, 0, 4)
            Label.BackgroundTransparency = 1
            Label.Text = sliderConfig.Title or "Slider"
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 24)
            ValueLabel.Position = UDim2.new(1, -62, 0, 4)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextColor3 = SpawnRealmXUI.Themes.SubText
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame

            local BarTrack = Instance.new("TextButton")
            BarTrack.Size = UDim2.new(1, -24, 0, 6)
            BarTrack.Position = UDim2.new(0, 12, 0, 34)
            BarTrack.BackgroundColor3 = SpawnRealmXUI.Themes.Outline
            BarTrack.Text = ""
            BarTrack.AutoButtonColor = false
            BarTrack.Parent = SliderFrame
            addCorner(BarTrack, 4)

            local BarFill = Instance.new("Frame")
            BarFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            BarFill.BackgroundColor3 = SpawnRealmXUI.Themes.Accent
            BarFill.Parent = BarTrack
            addCorner(BarFill, 4)

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

        -- Component 7: Dropdown Selector
        function TabMethods:Dropdown(dropConfig)
            local options = dropConfig.Options or {}
            local currentOption = dropConfig.Default or options[1] or ""
            local isOpen = false

            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, 0, 0, 38)
            DropFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = Page
            addCorner(DropFrame, 6)
            addStroke(DropFrame, SpawnRealmXUI.Themes.Outline, 1)

            local HeaderBtn = Instance.new("TextButton")
            HeaderBtn.Size = UDim2.new(1, 0, 0, 38)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.Text = ""
            HeaderBtn.Parent = DropFrame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -30, 0, 38)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = (dropConfig.Title or "Dropdown") .. ": " .. tostring(currentOption)
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = HeaderBtn

            local DropList = Instance.new("ScrollingFrame")
            DropList.Size = UDim2.new(1, -10, 0, 100)
            DropList.Position = UDim2.new(0, 5, 0, 42)
            DropList.BackgroundTransparency = 1
            DropList.ScrollBarThickness = 2
            DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y
            DropList.Parent = DropFrame

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Padding = UDim.new(0, 4)
            ListLayout.Parent = DropList

            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 28)
                OptBtn.BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
                OptBtn.Text = "  " .. tostring(opt)
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextColor3 = SpawnRealmXUI.Themes.SubText
                OptBtn.TextSize = 12
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.AutoButtonColor = false
                OptBtn.Parent = DropList
                addCorner(OptBtn, 4)

                OptBtn.MouseButton1Click:Connect(function()
                    currentOption = opt
                    Label.Text = (dropConfig.Title or "Dropdown") .. ": " .. tostring(currentOption)
                    isOpen = false
                    TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 38)}):Play()
                    if dropConfig.Callback then task.spawn(dropConfig.Callback, opt) end
                end)
            end

            HeaderBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local targetHeight = isOpen and 150 or 38
                TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
            end)
        end

        -- Component 8: Text Box / Input Field
        function TabMethods:Input(inputConfig)
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, 0, 0, 50)
            InputFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            InputFrame.Parent = Page
            addCorner(InputFrame, 6)
            addStroke(InputFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 0, 20)
            Label.Position = UDim2.new(0, 12, 0, 4)
            Label.BackgroundTransparency = 1
            Label.Text = inputConfig.Title or "Input"
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = InputFrame

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, -24, 0, 22)
            TextBox.Position = UDim2.new(0, 12, 0, 24)
            TextBox.BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
            TextBox.Text = inputConfig.Default or ""
            TextBox.PlaceholderText = inputConfig.Placeholder or "Type here..."
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextColor3 = SpawnRealmXUI.Themes.Text
            TextBox.PlaceholderColor3 = SpawnRealmXUI.Themes.SubText
            TextBox.TextSize = 12
            TextBox.ClearTextOnFocus = false
            TextBox.Parent = InputFrame
            addCorner(TextBox, 4)

            TextBox.FocusLost:Connect(function(enterPressed)
                if inputConfig.Callback then
                    task.spawn(inputConfig.Callback, TextBox.Text, enterPressed)
                end
            end)
        end

        -- Component 9: Keybind Picker
        function TabMethods:Keybind(keybindConfig)
            local currentKey = keybindConfig.Default or Enum.KeyCode.E

            local BindFrame = Instance.new("Frame")
            BindFrame.Size = UDim2.new(1, 0, 0, 38)
            BindFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            BindFrame.Parent = Page
            addCorner(BindFrame, 6)
            addStroke(BindFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -100, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = keybindConfig.Title or "Keybind"
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BindFrame

            local BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0, 80, 0, 24)
            BindBtn.Position = UDim2.new(1, -92, 0.5, -12)
            BindBtn.BackgroundColor3 = SpawnRealmXUI.Themes.Sidebar
            BindBtn.Text = currentKey.Name
            BindBtn.Font = Enum.Font.GothamMedium
            BindBtn.TextColor3 = SpawnRealmXUI.Themes.Accent
            BindBtn.TextSize = 12
            BindBtn.AutoButtonColor = false
            BindBtn.Parent = BindFrame
            addCorner(BindBtn, 4)

            BindBtn.MouseButton1Click:Connect(function()
                BindBtn.Text = "..."
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        BindBtn.Text = currentKey.Name
                        connection:Disconnect()
                        if keybindConfig.Callback then task.spawn(keybindConfig.Callback, currentKey) end
                    end
                end)
            end)
        end

        -- Component 10: Color Picker
        function TabMethods:Colorpicker(colorConfig)
            local currentColor = colorConfig.Default or Color3.fromRGB(0, 140, 255)

            local ColorFrame = Instance.new("Frame")
            ColorFrame.Size = UDim2.new(1, 0, 0, 38)
            ColorFrame.BackgroundColor3 = SpawnRealmXUI.Themes.Container
            ColorFrame.Parent = Page
            addCorner(ColorFrame, 6)
            addStroke(ColorFrame, SpawnRealmXUI.Themes.Outline, 1)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = colorConfig.Title or "Color Picker"
            Label.Font = Enum.Font.GothamMedium
            Label.TextColor3 = SpawnRealmXUI.Themes.Text
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ColorFrame

            local Preview = Instance.new("Frame")
            Preview.Size = UDim2.new(0, 36, 0, 20)
            Preview.Position = UDim2.new(1, -48, 0.5, -10)
            Preview.BackgroundColor3 = currentColor
            Preview.Parent = ColorFrame
            addCorner(Preview, 4)
            addStroke(Preview, SpawnRealmXUI.Themes.Outline, 1)
        end

        -- Set up protective Metatable to catch missing functions silently
        local Tab = setmetatable({
            Page = Page,
            TabBtn = TabBtn
        }, {
            __index = function(t, key)
                if TabMethods[key] then
                    return TabMethods[key]
                end
                
                -- Silent fallback: returns an empty dummy function so it won't crash or notify players
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

    -- Silent Notification Method (Does nothing visually to avoid player suspicion)
    function Window:Notify(notifyConfig)
        -- Notifications disabled entirely so no toast frames pop up on screen
    end

    return setmetatable(Window, Window)
end

return SpawnRealmXUI