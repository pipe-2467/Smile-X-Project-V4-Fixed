-- [[ SMILE-X ULTIMATE SS++: THE INTERNAL EXECUTOR ]]
-- DEVELOPER: PIPE
-- VERSION: 3.9.5 | STATUS: OPERATIONAL

-- [ 1. INTERNAL ENVIRONMENT SETUP ]
-- สร้างสภาพแวดล้อมให้เหมือน Executor จริง (Custom API)
local GenEnv = getgenv and getgenv() or _G
GenEnv.smile_version = "3.9.5"
GenEnv.is_smile_x = true

-- [ 2. EXTERNAL SERVICES ]
local Services = {
    Http = game:GetService("HttpService"),
    Tween = game:GetService("TweenService"),
    Run = game:GetService("RunService"),
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    Teleport = game:GetService("TeleportService")
}

local LP = Services.Players.LocalPlayer
local SmileX = {
    ScannerActive = false,
    Injected = false,
    WebhookURL = "https://discord.com/api/webhooks/1493160419571929129/Py-2cJ2ydyRZ1OwzkVZk8IRM6N8GCrS3qVR8Q99htWyE6Ya5GyPGjAGAHDTX_F8dZKmM", -- Pipe เอาลิงก์ Discord มาวางที่นี่
    Config = {}
}

-- [ 3. WEBHOOK SYSTEM ]
local function SendToDiscord(title, msg, color)
    if SmileX.WebhookURL == "" or string.len(SmileX.WebhookURL) < 10 then return end
    local data = {
        ["embeds"] = {{
            ["title"] = "SMILE-X LOG: " .. title,
            ["description"] = msg,
            ["color"] = color or 0x00FF7F,
            ["footer"] = {["text"] = "Executed by " .. LP.Name .. " | Time: " .. os.date("%X")}
        }}
    }
    pcall(function()
        Services.Http:PostAsync(SmileX.WebhookURL, Services.Http:JSONEncode(data))
    end)
end

-- [ 4. UI ENGINE (NEON STYLE) ]
local UI = { Tabs = {} }

function UI:Init()
    local SG = Instance.new("ScreenGui", Services.CoreGui)
    SG.Name = "SmileX_V3_Executor"

    local Main = Instance.new("Frame", SG)
    Main.Size = UDim2.new(0, 580, 0, 430)
    Main.Position = UDim2.new(0.5, -290, 0.5, -215)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true

    -- Glow Border
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(0, 255, 127)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.4

    -- Sidebar
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Sidebar.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", Sidebar)
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.Text = "SMILE-X SS++"
    Title.TextColor3 = Color3.fromRGB(0, 255, 127)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.BackgroundTransparency = 1

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -165, 1, -145)
    Container.Position = UDim2.new(0, 160, 0, 10)
    Container.BackgroundTransparency = 1

    local TabList = Instance.new("ScrollingFrame", Sidebar)
    TabList.Size = UDim2.new(1, 0, 1, -80)
    TabList.Position = UDim2.new(0, 0, 0, 70)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 0
    local Layout = Instance.new("UIListLayout", TabList)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Padding = UDim.new(0, 5)

    -- Internal Console
    local ConsoleFrame = Instance.new("ScrollingFrame", Main)
    ConsoleFrame.Size = UDim2.new(1, -165, 0, 120)
    ConsoleFrame.Position = UDim2.new(0, 160, 1, -130)
    ConsoleFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    ConsoleFrame.BorderSizePixel = 1
    ConsoleFrame.ScrollBarThickness = 2
    local ConsoleLayout = Instance.new("UIListLayout", ConsoleFrame)

    self.UpdateLog = function(txt, col)
        local l = Instance.new("TextLabel", ConsoleFrame)
        l.Size = UDim2.new(1, 0, 0, 18)
        l.BackgroundTransparency = 1
        l.Text = " [SMILE-X]: " .. txt
        l.TextColor3 = col or Color3.fromRGB(0, 255, 127)
        l.Font = Enum.Font.Code
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        ConsoleFrame.CanvasPosition = Vector2.new(0, ConsoleLayout.AbsoluteContentSize.Y)
    end

    self.Main = Main
    self.Container = Container
    self.TabList = TabList
end

function UI:AddTab(name)
    local Page = Instance.new("ScrollingFrame", self.Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 0

    local Btn = Instance.new("TextButton", self.TabList)
    Btn.Size = UDim2.new(0.9, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.Gotham
    Btn.BorderSizePixel = 0
    
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Container:GetChildren()) do p.Visible = false end
        Page.Visible = true
        self.UpdateLog("Switched to: " .. name)
    end)
    return Page
end

function UI:CreateButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.BorderSizePixel = 0

    Btn.MouseButton1Click:Connect(function()
        local t = Services.Tween:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = color})
        t:Play()
        t.Completed:Wait()
        Services.Tween:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        callback()
    end)
    local Layout = parent:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", parent)
    Layout.Padding = UDim.new(0, 5)
    return Btn
end

-- [ 5. THE HOOK ENGINE (SERVER-SIDE BYPASS) ]
local function InitiateEngine()
    local MT = getrawmetatable(game)
    local OldNC = MT.__namecall
    setreadonly(MT, false)

    MT.__namecall = newcclosure(function(self, ...)
        local Method = getnamecallmethod()
        local Args = {...}

        if SmileX.ScannerActive and (Method == "FireServer" or Method == "InvokeServer") then
            UI.UpdateLog("DETECTOR: " .. self.Name, Color3.fromRGB(0, 200, 255))
            SendToDiscord("Remote Found!", "**Name:** " .. self.Name .. "\n**Place:** " .. game.PlaceId, 0x00FFFF)
        end
        return OldNC(self, unpack(Args))
    end)
    setreadonly(MT, true)
    UI.UpdateLog("SS++ Engine Hooked Successfully", Color3.fromRGB(255, 255, 0))
end

-- [ 6. EXECUTION & UI RENDER ]
UI:Init()
local Home = UI:AddTab("Dashboard")
local Executor = UI:AddTab("Executor")
local Scanner = UI:AddTab("Scanner")

-- Home Tab Buttons
UI:CreateButton(Home, "INJECT SMILE-X ENGINE", Color3.fromRGB(0, 150, 255), function()
    if not SmileX.Injected then
        InitiateEngine()
        SmileX.Injected = true
    else
        UI.UpdateLog("Engine already running!")
    end
end)

UI:CreateButton(Home, "TOGGLE SCANNER (ON/OFF)", Color3.fromRGB(255, 165, 0), function()
    SmileX.ScannerActive = not SmileX.ScannerActive
    UI.UpdateLog("Scanner: " .. (SmileX.ScannerActive and "ACTIVE" or "OFF"))
end)

-- Executor Tab Setup
local CodeBox = Instance.new("TextBox", Executor)
CodeBox.Size = UDim2.new(1, -10, 0, 180)
CodeBox.MultiLine = true
CodeBox.Text = "-- Write your SS++ code here\nprint('Smile-X Loaded!')"
CodeBox.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
CodeBox.TextColor3 = Color3.fromRGB(0, 255, 127)
CodeBox.Font = Enum.Font.Code
CodeBox.TextSize = 14
CodeBox.TextXAlignment = Enum.TextXAlignment.Left
CodeBox.TextYAlignment = Enum.TextYAlignment.Top

UI:CreateButton(Executor, "EXECUTE SCRIPT", Color3.fromRGB(0, 200, 100), function()
    local func, err = loadstring(CodeBox.Text)
    if func then
        UI.UpdateLog("Executing...")
        pcall(func)
    else
        UI.UpdateLog("Error: " .. err, Color3.fromRGB(255, 50, 50))
    end
end)

-- [ 7. STARTUP ]
UI.UpdateLog("Smile-X SS++ Ready. Welcome, Pipe.", Color3.fromRGB(255, 255, 255))
SendToDiscord("System Started", "Smile-X has been injected into Place: " .. game.PlaceId)
