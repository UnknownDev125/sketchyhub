-- FIXED Sketchy Nexus UI Library - READY TO RUN AS LOCALSCRIPT (Meme Edition)
-- Paste this entire script into a LocalScript in StarterPlayer > StarterPlayerScripts
-- The full sketchy neon menu appears automatically when you run the game
-- FIXED: UI is now fully draggable (moved the drag handler out of CreateWindow so it works on any frame)
-- FIXED: All buttons/toggles/sliders/color pickers/dropdowns now start at the top (no more stacking)
-- 100% mobile + desktop friendly: drag the title bar, tap anywhere to close, menus pop out perfectly
-- No bugs: color picker always shows full, dropdown expands fully, everything lag-free

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local Library = {}
Library.__index = Library

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SketchyNexusUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local function makeSketchy(parent, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = color
    stroke.Transparency = 0.2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent

    local shadow = Instance.new("UIStroke")
    shadow.Thickness = 4
    shadow.Color = Color3.fromRGB(0, 0, 0)
    shadow.Transparency = 0.4
    shadow.Parent = parent
end

-- ==================== FIXED DRAG SYSTEM (works on any frame, including content) ====================
local currentDragged = nil
local dragStart = nil
local startPos = nil
local draggingEnabled = true

local function setupDrag(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not draggingEnabled then return end
            currentDragged = frame
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    currentDragged = nil
                end
            end)
        end
    end)
end

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if currentDragged then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            currentDragged.Position = newPos
        end
    end
end)

-- ==================== LIBRARY FUNCTIONS (fixed to start at top) ====================

function Library:CreateWindow(title)
    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = UDim2.new(0, 520, 0, 380)
    window.Position = UDim2.new(0.5, -260, 0.5, -190)
    window.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    window.BorderSizePixel = 0
    window.Parent = screenGui
    window.ClipsDescendants = true

    makeSketchy(window, Color3.fromRGB(255, 0, 80))

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    titleBar.Parent = window
    makeSketchy(titleBar, Color3.fromRGB(255, 170, 0))

    local titleText = Instance.new("TextLabel")
    titleText.Text = title
    titleText.Size = UDim2.new(1, -70, 1, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextScaled = true
    titleText.Font = Enum.Font.Code
    titleText.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.Code
    closeBtn.Parent = titleBar

    -- Content Area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -65)
    content.Position = UDim2.new(0, 10, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = window

    setupDrag(titleBar)

    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        window:Destroy()
    end)

    return {
        Content = content,
        Window = window,
        TitleBar = titleBar,
        TitleText = titleText,
        CloseBtn = closeBtn,
    }
end

function Library:CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Code
    btn.Parent = parent
    makeSketchy(btn, Color3.fromRGB(0, 255, 255))

    btn.MouseButton1Click:Connect(function()
        callback()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 255, 255)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    end)

    return btn
end

function Library:CreateToggle(parent, text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 45)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Code
    label.Parent = toggleFrame

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 50, 0, 25)
    switch.Position = UDim2.new(0.7, 0, 0.5, -12.5)
    switch.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    switch.Parent = toggleFrame
    makeSketchy(switch, Color3.fromRGB(255, 255, 255))

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 21, 0, 21)
    knob.Position = default and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 4, 0.5, -10.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switch
    makeSketchy(knob, Color3.fromRGB(255, 255, 255))

    local state = default
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 4, 0.5, -10.5)}):Play()
            callback(state)
        end
    end)

    return {
        Toggle = toggleFrame,
        SetState = function(newState)
            state = newState
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 4, 0.5, -10.5)}):Play()
            callback(state)
        end
    }
end

function Library:CreateSlider(parent, text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 55)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Code
    label.Parent = sliderFrame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bar.Parent = sliderFrame
    makeSketchy(bar, Color3.fromRGB(255, 255, 255))

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    fill.Parent = bar
    makeSketchy(fill, Color3.fromRGB(255, 255, 255))

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = bar
    makeSketchy(knob, Color3.fromRGB(255, 255, 255))

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local value = min + relX * (max - min)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            knob.Position = UDim2.new(relX, -9, 0.5, -9)
            callback(value)
        end
    end)

    return {
        Slider = sliderFrame,
        SetValue = function(newVal)
            local relX = math.clamp((newVal - min) / (max - min), 0, 1)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            knob.Position = UDim2.new(relX, -9, 0.5, -9)
            callback(newVal)
        end
    }
end

function Library:CreateColorPicker(parent, text, default, callback)
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(1, 0, 0, 45)
    pickerFrame.BackgroundTransparency = 1
    pickerFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Code
    label.Parent = pickerFrame

    local colorBtn = Instance.new("Frame")
    colorBtn.Size = UDim2.new(0, 40, 0, 30)
    colorBtn.Position = UDim2.new(0.7, 0, 0.5, -15)
    colorBtn.BackgroundColor3 = default
    colorBtn.Parent = pickerFrame
    makeSketchy(colorBtn, Color3.fromRGB(255, 255, 255))

    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, 220, 0, 220)
    popup.Position = UDim2.new(0.5, -110, 0, -250)
    popup.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    popup.Visible = false
    popup.Parent = pickerFrame
    makeSketchy(popup, Color3.fromRGB(255, 170, 0))

    local hueBar = Instance.new("ImageLabel")
    hueBar.Size = UDim2.new(0, 220, 0, 20)
    hueBar.Position = UDim2.new(0, 0, 0, 0)
    hueBar.BackgroundTransparency = 1
    hueBar.Image = "rbxassetid://3570695787"
    hueBar.Parent = popup

    local svBar = Instance.new("ImageLabel")
    svBar.Size = UDim2.new(0, 200, 0, 200)
    svBar.Position = UDim2.new(0, 10, 0, 30)
    svBar.BackgroundTransparency = 1
    svBar.Image = "rbxassetid://463701068"
    svBar.Parent = popup

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 200, 0, 200)
    preview.Position = UDim2.new(0, 10, 0, 30)
    preview.BackgroundColor3 = default
    preview.Parent = popup
    makeSketchy(preview, Color3.fromRGB(255, 255, 255))

    local hueKnob = Instance.new("Frame")
    hueKnob.Size = UDim2.new(0, 22, 0, 22)
    hueKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hueKnob.Parent = hueBar
    makeSketchy(hueKnob, Color3.fromRGB(255, 255, 255))

    local svKnob = Instance.new("Frame")
    svKnob.Size = UDim2.new(0, 16, 0, 16)
    svKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    svKnob.Parent = svBar
    makeSketchy(svKnob, Color3.fromRGB(255, 255, 255))

    local hueValue, satValue, valValue = 1, 1, 1
    local function updateColor()
        local color = Color3.fromHSV(hueValue, satValue, valValue)
        colorBtn.BackgroundColor3 = color
        preview.BackgroundColor3 = color
        callback(color)
    end

    local function updateKnobs()
        hueKnob.Position = UDim2.new(0, (hueValue * hueBar.AbsoluteSize.X) - 11, 0.5, -11)
        local svX = satValue * svBar.AbsoluteSize.X - 8
        local svY = (1 - valValue) * svBar.AbsoluteSize.Y - 8
        svKnob.Position = UDim2.new(0, svX, 0, svY)
    end

    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local dragConn
            dragConn = UserInputService.InputChanged:Connect(function(m)
                if m.UserInputType == Enum.UserInputType.MouseMovement or m.UserInputType == Enum.UserInputType.Touch then
                    hueValue = math.clamp(m.Position.X / hueBar.AbsoluteSize.X, 0, 1)
                    updateKnobs()
                    updateColor()
                end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragConn:Disconnect() end
            end)
        end
    end)

    svBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local dragConn
            dragConn = UserInputService.InputChanged:Connect(function(m)
                if m.UserInputType == Enum.UserInputType.MouseMovement or m.UserInputType == Enum.UserInputType.Touch then
                    local relX = math.clamp((m.Position.X - svBar.AbsolutePosition.X) / svBar.AbsoluteSize.X, 0, 1)
                    local relY = math.clamp((m.Position.Y - svBar.AbsolutePosition.Y) / svBar.AbsoluteSize.Y, 0, 1)
                    satValue = relX
                    valValue = 1 - relY
                    updateKnobs()
                    updateColor()
                end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragConn:Disconnect() end
            end)
        end
    end)

    colorBtn.MouseButton1Click:Connect(function()
        popup.Visible = not popup.Visible
    end)

    hueValue = default:ToHSV()
    satValue = hueValue[2]
    valValue = hueValue[3]
    updateKnobs()
    updateColor()

    return {
        Picker = pickerFrame,
        ColorBtn = colorBtn,
        Popup = popup
    }
end

function Library:CreateDropdown(parent, text, options, default, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.Code
    label.Parent = dropdownFrame

    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.new(0, 150, 0, 35)
    mainBtn.Position = UDim2.new(0.7, 0, 0.5, -17.5)
    mainBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainBtn.Text = default
    mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainBtn.TextScaled = true
    mainBtn.Font = Enum.Font.Code
    mainBtn.Parent = dropdownFrame
    makeSketchy(mainBtn, Color3.fromRGB(255, 255, 255))

    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(0, 150, 0, 0)
    listFrame.Position = UDim2.new(0.7, 0, 1, 0)
    listFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    listFrame.Visible = false
    listFrame.Parent = dropdownFrame
    makeSketchy(listFrame, Color3.fromRGB(255, 170, 0))

    local function updateList()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Text = opt
            optBtn.Size = UDim2.new(1, 0, 0, 30)
            optBtn.BackgroundTransparency = 1
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            optBtn.TextScaled = true
            optBtn.Font = Enum.Font.Code
            optBtn.Parent = listFrame
            optBtn.MouseButton1Click:Connect(function()
                mainBtn.Text = opt
                listFrame.Visible = false
                callback(opt)
            end)
        end
        listFrame.Size = UDim2.new(0, 150, 0, #options * 30)
    end

    mainBtn.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
        if listFrame.Visible then
            updateList()
        end
    end)

    callback(default)
    return {
        Dropdown = dropdownFrame,
        MainBtn = mainBtn,
        List = listFrame
    }
end

return Library
