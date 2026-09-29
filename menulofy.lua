
local Players = game:GetService("Players")

local UIS = game:GetService("UserInputService")

local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local BackgroundImage
local BackgroundTint
local AccentLine
local TopGradient
local WindowScale
local IsAnimating = false
local TabTransitionId = 0
local BackgroundBox
local SmoothOut = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SmoothFast = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SmoothPress = TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SmoothSpring = TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function PlayTween(Object, Info, Goal)
    if not Object or not Object.Parent then return nil end
    local Tween = TweenService:Create(Object, Info, Goal)
    Tween:Play()
    return Tween
end

local Config = {

    Enabled = false,

    TeamCheck = true,

    AliveCheck = true,

    WallCheck = false,

    Sensitivity = 0.15,

    LockPart = "Head",

    Theme = "Blue",
    BackgroundImage = "",
    BackgroundImageTransparency = 0.30,

}

local Themes = {

    Blue = {

        Background = Color3.fromRGB(13, 15, 20),

        Sidebar = Color3.fromRGB(17, 20, 27),

        Topbar = Color3.fromRGB(20, 23, 31),

        Primary = Color3.fromRGB(45, 125, 255),

        PrimaryHover = Color3.fromRGB(65, 145, 255),

        Text = Color3.fromRGB(240, 243, 250),

        SubText = Color3.fromRGB(150, 157, 172),

        Element = Color3.fromRGB(25, 29, 38),

        ElementHover = Color3.fromRGB(32, 37, 48),

        Border = Color3.fromRGB(43, 48, 61),

        Success = Color3.fromRGB(70, 210, 120),

        Danger = Color3.fromRGB(235, 75, 75),

    },

    Purple = {

        Background = Color3.fromRGB(15, 13, 20),

        Sidebar = Color3.fromRGB(20, 17, 27),

        Topbar = Color3.fromRGB(24, 20, 32),

        Primary = Color3.fromRGB(155, 85, 255),

        PrimaryHover = Color3.fromRGB(175, 110, 255),

        Text = Color3.fromRGB(245, 240, 250),

        SubText = Color3.fromRGB(160, 150, 175),

        Element = Color3.fromRGB(30, 25, 38),

        ElementHover = Color3.fromRGB(39, 32, 49),

        Border = Color3.fromRGB(49, 42, 61),

        Success = Color3.fromRGB(70, 210, 120),

        Danger = Color3.fromRGB(235, 75, 75),

    },

    Red = {

        Background = Color3.fromRGB(19, 13, 14),

        Sidebar = Color3.fromRGB(25, 17, 18),

        Topbar = Color3.fromRGB(30, 20, 21),

        Primary = Color3.fromRGB(235, 65, 75),

        PrimaryHover = Color3.fromRGB(255, 85, 95),

        Text = Color3.fromRGB(250, 240, 240),

        SubText = Color3.fromRGB(175, 150, 152),

        Element = Color3.fromRGB(37, 25, 27),

        ElementHover = Color3.fromRGB(48, 31, 34),

        Border = Color3.fromRGB(62, 42, 44),

        Success = Color3.fromRGB(70, 210, 120),

        Danger = Color3.fromRGB(235, 75, 75),

    },

}

local ThemeManager = {

    Objects = {}

}

function ThemeManager:Register(Object, Property, Role)

    table.insert(self.Objects, {

        Object = Object,

        Property = Property,

        Role = Role

    })

    local Theme = Themes[Config.Theme]

    if Theme and Theme[Role] then

        Object[Property] = Theme[Role]

    end

end

function ThemeManager:Apply(Name)

    local Theme = Themes[Name]

    if not Theme then

        return

    end

    Config.Theme = Name

    for _, Item in ipairs(self.Objects) do

        local Object = Item.Object

        if Object and Object.Parent then

            local Value = Theme[Item.Role]

            if Value ~= nil then
                Object[Item.Property] = Value
            end

        end

    end

    if AccentLine and AccentLine.Parent then
        AccentLine.BackgroundColor3 = Theme.Primary
    end

    if TopGradient and TopGradient.Parent then
        TopGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Topbar),
            ColorSequenceKeypoint.new(0.5, Theme.Primary:Lerp(Theme.Topbar, 0.72)),
            ColorSequenceKeypoint.new(1, Theme.Topbar)
        })
    end

    if BackgroundTint and BackgroundTint.Parent then
        if BackgroundImage and BackgroundImage.Image ~= "" then
            BackgroundTint.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            BackgroundTint.BackgroundTransparency = 0.48
        else
            BackgroundTint.BackgroundColor3 = Theme.Background
            BackgroundTint.BackgroundTransparency = 0.02
        end
    end

end

local function Create(Class, Properties)

    local Object = Instance.new(Class)

    for Property, Value in pairs(Properties or {}) do
        Object[Property] = Value
    end
    if Object:IsA("GuiObject") and (not Properties or Properties.ZIndex == nil) then
        Object.ZIndex = 40
    end

    return Object

end

local function Corner(Object, Radius)

    local UI = Instance.new("UICorner")

    UI.CornerRadius = UDim.new(0, Radius or 8)

    UI.Parent = Object

    return UI

end

local function Stroke(Object, Thickness)

    local UI = Instance.new("UIStroke")

    UI.Thickness = Thickness or 1

    UI.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    UI.Parent = Object

    return UI

end

local function Padding(Object, Value)

    local UI = Instance.new("UIPadding")

    UI.PaddingTop = UDim.new(0, Value)

    UI.PaddingBottom = UDim.new(0, Value)

    UI.PaddingLeft = UDim.new(0, Value)

    UI.PaddingRight = UDim.new(0, Value)

    UI.Parent = Object

    return UI

end

local ScreenGui = Create("ScreenGui", {

    Name = "CleanAimbotUI",

    ResetOnSpawn = false,

    IgnoreGuiInset = true,
    DisplayOrder = 999999,

    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,

    Parent = Player:WaitForChild("PlayerGui")

})

local Window = Create("Frame", {

    Name = "Window",

    Size = UDim2.fromOffset(820, 540),

    Position = UDim2.fromScale(0.5, 0.5),

    AnchorPoint = Vector2.new(0.5, 0.5),

    BorderSizePixel = 0,

    BackgroundTransparency = 0.08,

    ClipsDescendants = true,

    ZIndex = 10,

    Parent = ScreenGui

})

Corner(Window, 16)

local WindowStroke = Stroke(Window, 1)
WindowStroke.Transparency = 0.15
BackgroundImage = Create("ImageLabel", {

    Name = "BackgroundImage",

    Size = UDim2.fromScale(1, 1),

    BackgroundTransparency = 1,

    Image = "",

    ImageTransparency = Config.BackgroundImageTransparency,

    ScaleType = Enum.ScaleType.Crop,

    ZIndex = 11,

    Parent = Window

})

Corner(BackgroundImage, 16)

BackgroundTint = Create("Frame", {

    Name = "BackgroundTint",

    Size = UDim2.fromScale(1, 1),

    BackgroundColor3 = Color3.fromRGB(0, 0, 0),

    BackgroundTransparency = 0.58,

    BorderSizePixel = 0,

    ZIndex = 12,

    Parent = Window

})

Corner(BackgroundTint, 16)

AccentLine = Create("Frame", {

    Name = "AccentLine",

    Size = UDim2.new(1, 0, 0, 3),

    Position = UDim2.fromOffset(0, 0),

    BorderSizePixel = 0,

    ZIndex = 60,

    Parent = Window

})

Corner(AccentLine, 3)

local WindowConstraint = Create("UISizeConstraint", {

    MinSize = Vector2.new(650, 430),

    MaxSize = Vector2.new(1000, 700),

    Parent = Window

})

WindowScale = Instance.new("UIScale")
WindowScale.Scale = 0.92
WindowScale.Parent = Window

ThemeManager:Register(Window, "BackgroundColor3", "Background")

BackgroundImage.ImageTransparency = 1
BackgroundTint.BackgroundColor3 = Themes[Config.Theme].Background
BackgroundTint.BackgroundTransparency = 0.02

local Topbar = Create("Frame", {

    Name = "Topbar",

    Size = UDim2.new(1, 0, 0, 58),

    BorderSizePixel = 0,

    BackgroundTransparency = 0.08,

    ZIndex = 30,

    Parent = Window

})

ThemeManager:Register(Topbar, "BackgroundColor3", "Topbar")

TopGradient = Instance.new("UIGradient")
TopGradient.Rotation = 90
TopGradient.Parent = Topbar

local Title = Create("TextLabel", {

    Size = UDim2.new(1, -80, 1, 0),

    Position = UDim2.fromOffset(20, 0),

    BackgroundTransparency = 1,

    Text = "Lofy menu",

    TextSize = 16,

    Font = Enum.Font.GothamBold,

    TextXAlignment = Enum.TextXAlignment.Left,

    Parent = Topbar

})

ThemeManager:Register(Title, "TextColor3", "Text")

local Subtitle = Create("TextLabel", {
    Size = UDim2.fromOffset(220, 18),
    Position = UDim2.fromOffset(20, 33),
    BackgroundTransparency = 1,
    Text = "CONTROL PANEL  •  READY",
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 41,
    Parent = Topbar
})

ThemeManager:Register(Subtitle, "TextColor3", "SubText")

local Close = Create("TextButton", {

    Size = UDim2.fromOffset(38, 38),

    Position = UDim2.new(1, -47, 0.5, -19),

    BackgroundTransparency = 1,

    Text = "×",

    TextSize = 26,

    Font = Enum.Font.GothamBold,

    Parent = Topbar

})

ThemeManager:Register(Close, "TextColor3", "SubText")

Close.MouseEnter:Connect(function()
    TweenService:Create(Close, SmoothFast, {
        TextColor3 = Themes[Config.Theme].Danger
    }):Play()
end)

Close.MouseLeave:Connect(function()
    TweenService:Create(Close, SmoothFast, {
        TextColor3 = Themes[Config.Theme].SubText
    }):Play()
end)
local function TweenWindow(Open)
    if IsAnimating then return end
    IsAnimating = true

    if Open then
        Window.Visible = true
        Window.BackgroundTransparency = 1
        WindowScale.Scale = 0.90

        local scaleTween = PlayTween(WindowScale, TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1})
        PlayTween(Window, TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.08})
        if scaleTween then scaleTween.Completed:Wait() end
    else
        local scaleTween = PlayTween(WindowScale, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Scale = 0.90})
        PlayTween(Window, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1})
        if scaleTween then scaleTween.Completed:Wait() end
        Window.Visible = false
        Window.BackgroundTransparency = 0.08
    end

    IsAnimating = false
end

Close.MouseButton1Click:Connect(function()
    task.spawn(TweenWindow, false)
end)

local Body = Create("Frame", {

    Size = UDim2.new(1, 0, 1, -58),

    Position = UDim2.fromOffset(0, 58),

    BackgroundTransparency = 1,

    ZIndex = 30,
    Parent = Window

})

local Sidebar = Create("Frame", {

    Size = UDim2.new(0, 220, 1, 0),

    BorderSizePixel = 0,
    BackgroundTransparency = 0.10,
    ZIndex = 31,

    Parent = Body

})

ThemeManager:Register(Sidebar, "BackgroundColor3", "Sidebar")

Padding(Sidebar, 18)

local SidebarBrand = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundTransparency = 1,
    Text = "LOFY",
    TextSize = 18,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 42,
    Parent = Sidebar
})
ThemeManager:Register(SidebarBrand, "TextColor3", "Text")

local SidebarSub = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.fromOffset(0, 30),
    BackgroundTransparency = 1,
    Text = "CONTROL CENTER",
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 42,
    Parent = Sidebar
})
ThemeManager:Register(SidebarSub, "TextColor3", "SubText")

local SidebarLine = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.fromOffset(0, 62),
    BorderSizePixel = 0,
    ZIndex = 42,
    Parent = Sidebar
})
ThemeManager:Register(SidebarLine, "BackgroundColor3", "Border")

local TabList = Create("Frame", {
    Size = UDim2.new(1, 0, 1, -96),
    Position = UDim2.fromOffset(0, 82),
    BackgroundTransparency = 1,
    Parent = Sidebar
})

local TabLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 9),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = TabList
})

local Content = Create("Frame", {

    Size = UDim2.new(1, -220, 1, 0),

    Position = UDim2.new(0, 220, 0, 0),

    BackgroundColor3 = Color3.fromRGB(13, 15, 20),
    BackgroundTransparency = 0.18,
    ZIndex = 31,
    ClipsDescendants = true,

    Parent = Body

})

ThemeManager:Register(Content, "BackgroundColor3", "Background")
Padding(Content, 18)

local Pages = {}

local ActiveTab
local ActivePage
local TabTransitionId = 0
local PageTweens = {}

local function StopPageTween(Page)
    local Tween = PageTweens[Page]
    if Tween then
        pcall(function() Tween:Cancel() end)
        PageTweens[Page] = nil
    end
end

local function TweenPage(Page, Info, Goal)
    StopPageTween(Page)
    local Tween = TweenService:Create(Page, Info, Goal)
    PageTweens[Page] = Tween
    Tween.Completed:Connect(function()
        if PageTweens[Page] == Tween then
            PageTweens[Page] = nil
        end
    end)
    Tween:Play()
    return Tween
end

local function ResetPage(Page)
    if not Page then return end
    StopPageTween(Page)
    Page.Visible = false
    Page.Position = UDim2.fromOffset(0, 0)
    Page.BackgroundTransparency = 1
end

local function CreateTab(Name)
    local Button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = TabList
    })

    Corner(Button, 12)

    local ButtonScale = Instance.new("UIScale")
    ButtonScale.Scale = 1
    ButtonScale.Parent = Button

    local Icon = Create("TextLabel", {
        Name = "Icon",
        Size = UDim2.fromOffset(34, 34),
        Position = UDim2.fromOffset(9, 10),
        BackgroundColor3 = Themes[Config.Theme].Background,
        BackgroundTransparency = 0.15,
        Text = string.upper(Name:sub(1, 1)),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 43,
        Parent = Button
    })
    Corner(Icon, 9)

    local Label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -62, 1, 0),
        Position = UDim2.fromOffset(55, 0),
        BackgroundTransparency = 1,
        Text = Name,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 43,
        Parent = Button
    })

    local TabAccent = Create("Frame", {
        Name = "TabAccent",
        Size = UDim2.fromOffset(3, 26),
        Position = UDim2.new(0, 0, 0.5, -13),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 44,
        Parent = Button
    })
    Corner(TabAccent, 4)

    ThemeManager:Register(Button, "BackgroundColor3", "Element")
    ThemeManager:Register(Label, "TextColor3", "SubText")
    ThemeManager:Register(Icon, "TextColor3", "SubText")
    ThemeManager:Register(Icon, "BackgroundColor3", "Background")
    ThemeManager:Register(TabAccent, "BackgroundColor3", "Primary")

    local Page = Create("ScrollingFrame", {
        Name = Name,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageTransparency = 0.25,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = Content
    })

    Padding(Page, 3)

    Create("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Page
    })

    Pages[Name] = Page
    ResetPage(Page)

    local function SetActive(Active)
        local Theme = Themes[Config.Theme]
        if Active then
            PlayTween(Button, SmoothFast, {BackgroundTransparency = 0.20})
            PlayTween(Label, SmoothFast, {TextColor3 = Theme.Primary})
            PlayTween(Icon, SmoothFast, {
                BackgroundColor3 = Theme.Primary,
                TextColor3 = Theme.Text
            })
            PlayTween(TabAccent, SmoothFast, {BackgroundTransparency = 0})
        else
            PlayTween(Button, SmoothFast, {BackgroundTransparency = 1})
            PlayTween(Label, SmoothFast, {TextColor3 = Theme.SubText})
            PlayTween(Icon, SmoothFast, {
                BackgroundColor3 = Theme.Background,
                TextColor3 = Theme.SubText
            })
            PlayTween(TabAccent, SmoothFast, {BackgroundTransparency = 1})
        end
    end

    Button.MouseEnter:Connect(function()
        if ActiveTab ~= Name then
            local Theme = Themes[Config.Theme]
            PlayTween(Button, SmoothFast, {BackgroundTransparency = 0.55})
            PlayTween(Label, SmoothFast, {TextColor3 = Theme.Text})
            PlayTween(Icon, SmoothFast, {TextColor3 = Theme.Text})
        end
        PlayTween(ButtonScale, SmoothFast, {Scale = 1.012})
    end)

    Button.MouseLeave:Connect(function()
        SetActive(ActiveTab == Name)
        PlayTween(ButtonScale, SmoothFast, {Scale = 1})
    end)

    Button.MouseButton1Click:Connect(function()
        if ActiveTab == Name then
            PlayTween(ButtonScale, SmoothPress, {Scale = 0.975})
            task.delay(0.08, function()
                if Button.Parent then
                    PlayTween(ButtonScale, SmoothSpring, {Scale = 1})
                end
            end)
            return
        end

        TabTransitionId += 1
        local Token = TabTransitionId
        local Theme = Themes[Config.Theme]
        local OldPage = ActivePage
        local NewPage = Page
        for ExistingPage in pairs(Pages) do
            StopPageTween(ExistingPage)
        end
        for _, ExistingPage in pairs(Pages) do
            if ExistingPage ~= OldPage and ExistingPage ~= NewPage then
                ResetPage(ExistingPage)
            end
        end

        for _, Object in ipairs(TabList:GetChildren()) do
            if Object:IsA("TextButton") then
                local OtherLabel = Object:FindFirstChild("Label")
                local OtherIcon = Object:FindFirstChild("Icon")
                local OtherAccent = Object:FindFirstChild("TabAccent")

                PlayTween(Object, SmoothFast, {BackgroundTransparency = 1})
                if OtherLabel then PlayTween(OtherLabel, SmoothFast, {TextColor3 = Theme.SubText}) end
                if OtherIcon then
                    PlayTween(OtherIcon, SmoothFast, {
                        BackgroundColor3 = Theme.Background,
                        TextColor3 = Theme.SubText
                    })
                end
                if OtherAccent then PlayTween(OtherAccent, SmoothFast, {BackgroundTransparency = 1}) end
            end
        end
        if OldPage and OldPage ~= NewPage then
            StopPageTween(OldPage)
            OldPage.Visible = false
            OldPage.Position = UDim2.fromOffset(0, 0)
            OldPage.ZIndex = 40
        end

        for _, ExistingPage in pairs(Pages) do
            if ExistingPage ~= NewPage then
                StopPageTween(ExistingPage)
                ExistingPage.Visible = false
                ExistingPage.Position = UDim2.fromOffset(0, 0)
                ExistingPage.ZIndex = 40
            end
        end

        NewPage.Visible = true
        NewPage.ZIndex = 42
        NewPage.CanvasPosition = Vector2.zero
        NewPage.Position = UDim2.fromOffset(22, 0)
        local PageScale = NewPage:FindFirstChildOfClass("UIScale")
        if not PageScale then
            PageScale = Instance.new("UIScale")
            PageScale.Scale = 1
            PageScale.Parent = NewPage
        end
        PageScale.Scale = 0.985

        local InInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenPage(NewPage, InInfo, {Position = UDim2.fromOffset(0, 0)})
        PlayTween(PageScale, TweenInfo.new(0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1})

        ActiveTab = Name
        ActivePage = NewPage
        SetActive(true)
        task.delay(0.32, function()
            if Token ~= TabTransitionId then return end
            for _, ExistingPage in pairs(Pages) do
                if ExistingPage ~= NewPage then
                    ExistingPage.Visible = false
                    ExistingPage.Position = UDim2.fromOffset(0, 0)
                    ExistingPage.ZIndex = 40
                end
            end
            NewPage.Visible = true
            NewPage.ZIndex = 42
            NewPage.Position = UDim2.fromOffset(0, 0)
            PageScale.Scale = 1
        end)
    end)

    return Page
end

local function Section(Page, Name)

    local Frame = Create("Frame", {

        Size = UDim2.new(1, -4, 0, 52),

        BackgroundTransparency = 1,

        Parent = Page

    })

    local Label = Create("TextLabel", {

        Size = UDim2.new(1, 0, 1, 0),

        BackgroundTransparency = 1,

        Text = Name,

        TextSize = 14,

        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left,

        Parent = Frame

    })

    ThemeManager:Register(Label, "TextColor3", "Text")

    return Frame

end

local function Toggle(Page, Name, Key)

    local Frame = Create("Frame", {

        Size = UDim2.new(1, -4, 0, 52),

        BorderSizePixel = 0,

        Parent = Page

    })

    Corner(Frame, 10)

    local FrameScale = Instance.new("UIScale")
    FrameScale.Scale = 1
    FrameScale.Parent = Frame

    ThemeManager:Register(Frame, "BackgroundColor3", "Element")

    local Label = Create("TextLabel", {

        Size = UDim2.new(1, -80, 1, 0),

        Position = UDim2.fromOffset(15, 0),

        BackgroundTransparency = 1,

        Text = Name,

        TextSize = 13,

        Font = Enum.Font.GothamMedium,

        TextXAlignment = Enum.TextXAlignment.Left,

        Parent = Frame

    })

    ThemeManager:Register(Label, "TextColor3", "Text")

    local Switch = Create("TextButton", {

        Size = UDim2.fromOffset(42, 22),

        Position = UDim2.new(1, -57, 0.5, -11),

        Text = "",

        AutoButtonColor = false,

        Parent = Frame

    })

    Corner(Switch, 20)

    local Knob = Create("Frame", {

        Size = UDim2.fromOffset(16, 16),

        Position = UDim2.fromOffset(3, 3),

        BorderSizePixel = 0,

        Parent = Switch

    })

    Corner(Knob, 20)

    local Pulse = Create("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromOffset(3, 3),
        BackgroundColor3 = Themes[Config.Theme].Text,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 45,
        Parent = Switch
    })
    Corner(Pulse, 20)

    local function Update(Animate)
        local Enabled = Config[Key]
        local Theme = Themes[Config.Theme]
        local TargetPos = Enabled and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3)
        local TargetColor = Enabled and Theme.Primary or Theme.Border

        if Animate then
            TweenService:Create(Switch, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundColor3 = TargetColor
            }):Play()
            TweenService:Create(Knob, TweenInfo.new(0.30, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = TargetPos
            }):Play()
            TweenService:Create(Label, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextColor3 = Enabled and Theme.Primary or Theme.Text
            }):Play()

            Pulse.Position = TargetPos
            Pulse.Size = UDim2.fromOffset(16, 16)
            Pulse.BackgroundColor3 = Theme.Text
            Pulse.BackgroundTransparency = 0.55
            TweenService:Create(Pulse, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(25, 25),
                Position = Enabled and UDim2.new(1, -23, 0.5, -12.5) or UDim2.fromOffset(-1, -1),
                BackgroundTransparency = 1
            }):Play()
        else
            Switch.BackgroundColor3 = TargetColor
            Knob.Position = TargetPos
            Label.TextColor3 = Enabled and Theme.Primary or Theme.Text
        end
    end

    Switch.MouseButton1Click:Connect(function()
        Config[Key] = not Config[Key]

        TweenService:Create(FrameScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.975}):Play()
        task.delay(0.08, function()
            if FrameScale.Parent then
                TweenService:Create(FrameScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
            end
        end)

        Update(true)
    end)

    Frame.MouseEnter:Connect(function()
        TweenService:Create(Frame, SmoothFast, {BackgroundColor3 = Themes[Config.Theme].ElementHover}):Play()
        TweenService:Create(FrameScale, SmoothFast, {Scale = 1.008}):Play()
    end)
    Frame.MouseLeave:Connect(function()
        TweenService:Create(Frame, SmoothFast, {BackgroundColor3 = Themes[Config.Theme].Element}):Play()
        TweenService:Create(FrameScale, SmoothFast, {Scale = 1}):Play()
    end)

    Update(false)

    return Frame

end

local function Button(Page, Name, Callback)

    local Btn = Create("TextButton", {

        Size = UDim2.new(1, -4, 0, 45),

        BorderSizePixel = 0,

        Text = Name,

        TextSize = 13,

        Font = Enum.Font.GothamMedium,

        AutoButtonColor = false,

        Parent = Page

    })

    Corner(Btn, 10)

    local ButtonScale = Instance.new("UIScale")
    ButtonScale.Parent = Btn

    ThemeManager:Register(Btn, "BackgroundColor3", "Element")

    ThemeManager:Register(Btn, "TextColor3", "Text")

    Btn.MouseEnter:Connect(function()
        PlayTween(Btn, SmoothFast, {BackgroundColor3 = Themes[Config.Theme].ElementHover})
        PlayTween(ButtonScale, SmoothFast, {Scale = 1.008})
    end)

    Btn.MouseLeave:Connect(function()
        PlayTween(Btn, SmoothFast, {BackgroundColor3 = Themes[Config.Theme].Element})
        PlayTween(ButtonScale, SmoothFast, {Scale = 1})
    end)

    Btn.MouseButton1Click:Connect(function()
        PlayTween(ButtonScale, SmoothPress, {Scale = 0.985})
        task.delay(0.10, function()
            if Btn.Parent then
                PlayTween(ButtonScale, SmoothSpring, {Scale = 1.008})
                task.delay(0.14, function()
                    if Btn.Parent then PlayTween(ButtonScale, SmoothFast, {Scale = 1}) end
                end)
            end
        end)

        if Callback then
            Callback()
        end
    end)

    return Btn

end

local function Dropdown(Page, Name, Options, Callback)

    local Frame = Create("Frame", {

        Size = UDim2.new(1, -4, 0, 55),

        BorderSizePixel = 0,

        Parent = Page

    })

    Corner(Frame, 10)

    local DropdownScale = Instance.new("UIScale")
    DropdownScale.Parent = Frame

    ThemeManager:Register(Frame, "BackgroundColor3", "Element")

    local Label = Create("TextLabel", {

        Size = UDim2.new(0.5, 0, 1, 0),

        Position = UDim2.fromOffset(15, 0),

        BackgroundTransparency = 1,

        Text = Name,

        TextSize = 13,

        Font = Enum.Font.GothamMedium,

        TextXAlignment = Enum.TextXAlignment.Left,

        Parent = Frame

    })

    ThemeManager:Register(Label, "TextColor3", "Text")

    local Select = Create("TextButton", {

        Size = UDim2.new(0, 150, 0, 34),

        Position = UDim2.new(1, -165, 0.5, -17),

        Text = Options[1],

        TextSize = 12,

        Font = Enum.Font.GothamMedium,

        AutoButtonColor = false,

        Parent = Frame

    })

    Corner(Select, 7)

    ThemeManager:Register(Select, "BackgroundColor3", "Background")

    ThemeManager:Register(Select, "TextColor3", "Text")

    local Index = 1

    Select.MouseEnter:Connect(function()
        TweenService:Create(Select, SmoothFast, {BackgroundColor3 = Themes[Config.Theme].ElementHover}):Play()
    end)
    Select.MouseLeave:Connect(function()
        TweenService:Create(Select, SmoothFast, {BackgroundColor3 = Themes[Config.Theme].Background}):Play()
    end)

    Frame.MouseEnter:Connect(function()
        TweenService:Create(Frame, SmoothFast, {BackgroundColor3 = Themes[Config.Theme].ElementHover}):Play()
        TweenService:Create(DropdownScale, SmoothFast, {Scale = 1.006}):Play()
    end)
    Frame.MouseLeave:Connect(function()
        TweenService:Create(Frame, SmoothFast, {BackgroundColor3 = Themes[Config.Theme].Element}):Play()
        TweenService:Create(DropdownScale, SmoothFast, {Scale = 1}):Play()
    end)

    Select.MouseButton1Click:Connect(function()
        TweenService:Create(Select, TweenInfo.new(0.07), {Size = UDim2.new(0, 144, 0, 32)}):Play()
        task.delay(0.07, function()
            TweenService:Create(Select, TweenInfo.new(0.13, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 150, 0, 34)}):Play()
        end)

        Index += 1

        if Index > #Options then

            Index = 1

        end

        local Value = Options[Index]

        Select.Text = Value

        if Callback then

            Callback(Value)

        end

    end)

    return Frame

end

local function Slider(Page, Name, Key, Min, Max)

    local Frame = Create("Frame", {

        Size = UDim2.new(1, -4, 0, 70),

        BorderSizePixel = 0,

        Parent = Page

    })

    Corner(Frame, 10)

    local SliderScale = Instance.new("UIScale")
    SliderScale.Parent = Frame

    ThemeManager:Register(Frame, "BackgroundColor3", "Element")

    local Label = Create("TextLabel", {

        Size = UDim2.new(1, -30, 0, 25),

        Position = UDim2.fromOffset(15, 8),

        BackgroundTransparency = 1,

        Text = Name .. ": " .. tostring(Config[Key]),

        TextSize = 13,

        Font = Enum.Font.GothamMedium,

        TextXAlignment = Enum.TextXAlignment.Left,

        Parent = Frame

    })

    ThemeManager:Register(Label, "TextColor3", "Text")

    local Bar = Create("Frame", {

        Size = UDim2.new(1, -30, 0, 6),

        Position = UDim2.fromOffset(15, 48),

        BorderSizePixel = 0,

        Parent = Frame

    })

    Corner(Bar, 10)

    ThemeManager:Register(Bar, "BackgroundColor3", "Border")

    local Fill = Create("Frame", {

        Size = UDim2.new(0, 0, 1, 0),

        BorderSizePixel = 0,

        Parent = Bar

    })

    Corner(Fill, 10)

    ThemeManager:Register(Fill, "BackgroundColor3", "Primary")

    local Dragging = false

    local function Set(Value)

        Value = math.clamp(Value, Min, Max)

        Config[Key] = math.floor(Value * 100) / 100

        if Key == "BackgroundImageTransparency" and BackgroundImage then
            BackgroundImage.ImageTransparency = Config[Key]
        end

        local Alpha =

            (Value - Min) / (Max - Min)

        Fill.Size =

            UDim2.new(Alpha, 0, 1, 0)

        Label.Text =

            Name .. ": " .. tostring(Config[Key])

    end

    Frame.MouseEnter:Connect(function()
        TweenService:Create(Frame, SmoothFast, {BackgroundColor3 = Themes[Config.Theme].ElementHover}):Play()
        TweenService:Create(SliderScale, SmoothFast, {Scale = 1.006}):Play()
    end)
    Frame.MouseLeave:Connect(function()
        TweenService:Create(Frame, SmoothFast, {BackgroundColor3 = Themes[Config.Theme].Element}):Play()
        TweenService:Create(SliderScale, SmoothFast, {Scale = 1}):Play()
    end)

    Bar.InputBegan:Connect(function(Input)

        if Input.UserInputType ==

            Enum.UserInputType.MouseButton1 then

            Dragging = true

            local Alpha =

                math.clamp(

                    (Input.Position.X - Bar.AbsolutePosition.X)

                    / Bar.AbsoluteSize.X,

                    0,

                    1

                )

            Set(Min + (Max - Min) * Alpha)

        end

    end)

    UIS.InputEnded:Connect(function(Input)

        if Input.UserInputType ==

            Enum.UserInputType.MouseButton1 then

            Dragging = false

        end

    end)

    UIS.InputChanged:Connect(function(Input)

        if not Dragging then

            return

        end

        if Input.UserInputType ==

            Enum.UserInputType.MouseMovement then

            local Alpha =

                math.clamp(

                    (Input.Position.X - Bar.AbsolutePosition.X)

                    / Bar.AbsoluteSize.X,

                    0,

                    1

                )

            Set(Min + (Max - Min) * Alpha)

        end

    end)

    Set(Config[Key])

    return Frame

end

local MainPage = CreateTab("Main")

local SettingsPage = CreateTab("Settings")

local AppearancePage = CreateTab("Appearance")

Section(MainPage, "General")

Toggle(

    MainPage,

    "Enabled",

    "Enabled"

)

Toggle(

    MainPage,

    "Team Check",

    "TeamCheck"

)

Toggle(

    MainPage,

    "Alive Check",

    "AliveCheck"

)

Toggle(

    MainPage,

    "Wall Check",

    "WallCheck"

)

Section(MainPage, "Sensitivity")

Slider(

    MainPage,

    "Sensitivity",

    "Sensitivity",

    0.01,

    1

)

Section(SettingsPage, "Target")

Dropdown(

    SettingsPage,

    "Target Part",

    {

        "Head",

        "HumanoidRootPart",

        "UpperTorso"

    },

    function(Value)

        Config.LockPart = Value

    end

)

Button(

    SettingsPage,

    "Reset Settings",

    function()

        Config.Enabled = false

        Config.TeamCheck = true

        Config.AliveCheck = true

        Config.WallCheck = false

        Config.Sensitivity = 0.15

        Config.LockPart = "Head"

    end

)

Section(

    AppearancePage,

    "Interface Theme"

)

Dropdown(

    AppearancePage,

    "Theme",

    {

        "Blue",

        "Purple",

        "Red"

    },

    function(Value)

        ThemeManager:Apply(Value)

    end

)

local function GetRequestFunction()
    local Candidates = {
        (syn and syn.request),
        (http and http.request),
        http_request,
        request,
    }

    for _, Fn in ipairs(Candidates) do
        if type(Fn) == "function" then
            return Fn
        end
    end

    return nil
end

local function NormalizeImageURL(URL)
    if URL:find("media.discordapp.net/", 1, true) or URL:find("cdn.discordapp.com/", 1, true) then
        URL = URL:gsub("([?&])format=webp", "%1format=png")
    end

    return URL
end

local function GetAssetExtension(URL, Headers)
    local ContentType = ""

    if type(Headers) == "table" then
        ContentType = tostring(
            Headers["Content-Type"] or
            Headers["content-type"] or
            Headers["CONTENT-TYPE"] or
            ""
        ):lower()
    end

    if ContentType:find("image/png", 1, true) then return ".png" end
    if ContentType:find("image/jpeg", 1, true) or ContentType:find("image/jpg", 1, true) then return ".jpg" end
    if ContentType:find("image/webp", 1, true) then return ".webp" end
    if ContentType:find("image/gif", 1, true) then return ".gif" end
    if ContentType:find("image/bmp", 1, true) then return ".bmp" end

    local CleanURL = URL:lower():match("^[^?#]+") or URL:lower()
    local Extension = CleanURL:match("(%.[a-z0-9]+)$")

    if Extension and #Extension <= 5 then
        return Extension
    end

    return ".png"
end

local function SetBackgroundImage(Value)
    Value = tostring(Value or ""):gsub("^%s+", ""):gsub("%s+$", "")

    if Value == "" then
        Config.BackgroundImage = ""
        if BackgroundStatus then
            BackgroundStatus.Text = "No background • using theme surface"
            BackgroundStatus.TextColor3 = Themes[Config.Theme].SubText
        end
        BackgroundImage.Image = ""
        BackgroundImage.ImageTransparency = 1
        if BackgroundTint then
            BackgroundTint.BackgroundColor3 = Themes[Config.Theme].Background
            BackgroundTint.BackgroundTransparency = 0.02
        end
        return true
    end
    if Value:match("^rbxassetid://") or Value:match("^%d+$") then
        local Id = Value:match("rbxassetid://(%d+)") or Value:match("^(%d+)$")

        if Id then
            Config.BackgroundImage = "rbxassetid://" .. Id
            if BackgroundStatus then
                BackgroundStatus.Text = "Local Roblox image applied"
                BackgroundStatus.TextColor3 = Themes[Config.Theme].Success
            end
            BackgroundImage.Image = Config.BackgroundImage
            BackgroundImage.ImageTransparency = Config.BackgroundImageTransparency
            return true
        end
    end
    local Request = GetRequestFunction()
    local GetAsset = getcustomasset or getsynasset

    if not Request or type(writefile) ~= "function" or type(GetAsset) ~= "function" then
        if BackgroundStatus then
            BackgroundStatus.Text = "External URLs require request + writefile + getcustomasset/getsynasset"
            BackgroundStatus.TextColor3 = Themes[Config.Theme].Danger
        end
        return false
    end

    local URL = NormalizeImageURL(Value)
    if BackgroundStatus then
        BackgroundStatus.Text = "Downloading image..."
        BackgroundStatus.TextColor3 = Themes[Config.Theme].SubText
    end

    task.spawn(function()
        local Ok, Response = pcall(function()
            return Request({
                Url = URL,
                Method = "GET",
                Headers = {
                    ["User-Agent"] = "Mozilla/5.0",
                    ["Accept"] = "image/png,image/jpeg,image/webp,image/*,*/*;q=0.8",
                },
            })
        end)
        if (not Ok or type(Response) ~= "table") then
            Ok, Response = pcall(function()
                return Request({
                    Url = URL,
                    Method = "GET",
                })
            end)
        end

        if not Ok or type(Response) ~= "table" then
            if BackgroundStatus then BackgroundStatus.Text = "Could not access image URL" end
            return
        end
        local StatusCode = tonumber(Response.StatusCode or Response.Status or 0) or 0
        local Success = Response.Success
        if Success == nil then
            Success = StatusCode >= 200 and StatusCode < 300
        end

        local Body = Response.Body or Response.body
        if not Success or type(Body) ~= "string" or #Body == 0 then
            if BackgroundStatus then BackgroundStatus.Text = "URL did not return a valid image" end
            return
        end

        local Extension = GetAssetExtension(URL, Response.Headers or Response.headers)
        local FileName = "LofyMenuBackground" .. Extension
        if type(isfile) == "function" and isfile(FileName) and type(delfile) == "function" then
            pcall(delfile, FileName)
        end

        local Wrote, WriteError = pcall(function()
            writefile(FileName, Body)
        end)

        if not Wrote then
            if BackgroundStatus then BackgroundStatus.Text = "Could not save downloaded image" end
            return
        end

        local AssetOk, Asset = pcall(function()
            return GetAsset(FileName)
        end)

        if not AssetOk or type(Asset) ~= "string" or Asset == "" then
            if BackgroundStatus then BackgroundStatus.Text = "Downloaded, but custom asset loading failed" end
            return
        end

        Config.BackgroundImage = Asset
        BackgroundImage.Image = Asset
        BackgroundImage.ImageTransparency = Config.BackgroundImageTransparency
        if BackgroundTint then
            BackgroundTint.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            BackgroundTint.BackgroundTransparency = 0.48
        end
        if BackgroundStatus then
            BackgroundStatus.Text = "Background applied successfully"
            BackgroundStatus.TextColor3 = Themes[Config.Theme].Success
        end

        if BackgroundBox then
            BackgroundBox.TextColor3 = Themes[Config.Theme].Success
            task.delay(0.8, function()
                if BackgroundBox and BackgroundBox.Parent then
                    BackgroundBox.TextColor3 = Themes[Config.Theme].Text
                end
            end)
        end
    end)

    return true
end

local function SetBackgroundTransparency(Value)
    Value = math.clamp(tonumber(Value) or Config.BackgroundImageTransparency, 0, 1)
    Config.BackgroundImageTransparency = Value
    BackgroundImage.ImageTransparency = (BackgroundImage.Image == "") and 1 or Value
end

Section(AppearancePage, "Background Photo")

BackgroundBox = Create("TextBox", {
    Size = UDim2.new(1, -4, 0, 48),
    BackgroundColor3 = Themes[Config.Theme].Element,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    PlaceholderText = "Cole a URL direta da imagem...",
    PlaceholderColor3 = Themes[Config.Theme].SubText,
    Text = "",
    ClearTextOnFocus = false,
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextColor3 = Themes[Config.Theme].Text,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 40,
    Parent = AppearancePage
})

Corner(BackgroundBox, 10)
Padding(BackgroundBox, 14)
ThemeManager:Register(BackgroundBox, "BackgroundColor3", "Element")
ThemeManager:Register(BackgroundBox, "TextColor3", "Text")

local BackgroundStatus = Create("TextLabel", {
    Size = UDim2.new(1, -4, 0, 20),
    BackgroundTransparency = 1,
    Text = "Paste a direct image URL and press Enter.",
    TextSize = 10,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 40,
    Parent = AppearancePage
})
ThemeManager:Register(BackgroundStatus, "TextColor3", "SubText")

BackgroundBox.FocusLost:Connect(function(EnterPressed)
    if EnterPressed then
        SetBackgroundImage(BackgroundBox.Text)
    end
end)

Button(AppearancePage, "Apply Background", function()
    SetBackgroundImage(BackgroundBox.Text)
end)

Button(AppearancePage, "Remove Background", function()
    BackgroundBox.Text = ""
    SetBackgroundImage("")
end)

Slider(AppearancePage, "Photo Transparency", "BackgroundImageTransparency", 0, 1)

MainPage.Visible = true
MainPage.Position = UDim2.fromOffset(0, 0)
ActivePage = MainPage

ActiveTab = "Main"

ThemeManager:Apply(Config.Theme)
Window.Visible = true
WindowScale.Scale = 0.92
task.defer(function()
    TweenWindow(true)
end)

for _, Object in ipairs(TabList:GetChildren()) do
    if Object:IsA("TextButton") then
        local Label = Object:FindFirstChild("Label")
        local Icon = Object:FindFirstChild("Icon")
        local Accent = Object:FindFirstChild("TabAccent")
        if Label and Label.Text == ActiveTab then
            Object.BackgroundColor3 = Themes[Config.Theme].Element
            Object.BackgroundTransparency = 0.20
            Label.TextColor3 = Themes[Config.Theme].Primary
            if Icon then
                Icon.BackgroundColor3 = Themes[Config.Theme].Primary
                Icon.TextColor3 = Themes[Config.Theme].Text
            end
            if Accent then
                Accent.BackgroundTransparency = 0
                Accent.BackgroundColor3 = Themes[Config.Theme].Primary
            end
        end
    end
end

local Dragging = false

local DragStart

local StartPosition

Topbar.InputBegan:Connect(function(Input)

    if Input.UserInputType ==

        Enum.UserInputType.MouseButton1 then

        Dragging = true

        DragStart = Input.Position

        StartPosition = Window.Position

    end

end)

UIS.InputEnded:Connect(function(Input)

    if Input.UserInputType ==

        Enum.UserInputType.MouseButton1 then

        Dragging = false

    end

end)

UIS.InputChanged:Connect(function(Input)

    if not Dragging then

        return

    end

    if Input.UserInputType ==

        Enum.UserInputType.MouseMovement then

        local Delta =

            Input.Position - DragStart

        Window.Position =

            UDim2.new(

                StartPosition.X.Scale,

                StartPosition.X.Offset + Delta.X,

                StartPosition.Y.Scale,

                StartPosition.Y.Offset + Delta.Y

            )

    end

end)

UIS.InputBegan:Connect(function(Input, Processed)

    if Processed then

        return

    end

    if Input.KeyCode == Enum.KeyCode.RightShift then
        if Window.Visible then
            task.spawn(TweenWindow, false)
        else
            task.spawn(TweenWindow, true)
        end
    end

end)
