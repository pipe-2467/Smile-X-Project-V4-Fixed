-- [[ SMILE-X ULTIMATE SS++ ]]
-- DEVELOPER: PIPE | VERSION: 3.8.0 (FIXED & INTEGRATED)

local SmileX = {
    Config = {},
    Version = "3.8.0",
    ScannerActive = false,
    WebhookURL = "https://discord.com/api/webhooks/1493160419571929129/Py-2cJ2ydyRZ1OwzkVZk8IRM6N8GCrS3qVR8Q99htWyE6Ya5GyPGjAGAHDTX_F8dZKmM" -- อย่าลืมใส่ URL ของ Pipe นะครับ
}

-- [ 1. SERVICES ]
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- [ 2. UTILS & WEBHOOK ]
local function SendToDiscord(title, msg, color)
    if SmileX.WebhookURL == "" or not SmileX.WebhookURL then return end
    local data = {
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = msg,
            ["color"] = color or 65280,
            ["footer"] = {["text"] = "Smile-X SS++ | User: " .. LP.Name}
        }}
    }
    pcall(function()
        HttpService:PostAsync(SmileX.WebhookURL, HttpService:JSONEncode(data))
    end)
end

-- [ 3. JSON DATA FETCHING ]
local function LoadConfig()
    local rawUrl = "https://raw.githubusercontent.com/pipe-2467/Smile-X-Project-V4-Fixed/refs/heads/main/config.json" 
    local success, result = pcall(function() return HttpService:GetAsync(rawUrl) end)
    if success then
        SmileX.Config = HttpService:JSONDecode(result)
        return true
    end
    return false
end

-- [ 4. UI FRAMEWORK ]
local UI = { Tabs = {} }

function UI:Init()
    local SG = Instance.new("ScreenGui", game:GetService("CoreGui"))
    SG.Name = "SmileX_V3"

    local Main = Instance.new("Frame", SG)
    Main.Size = UDim2.new(0, 580, 0, 420)
    Main.Position = UDim2.new(0.5, -290, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 127)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)

    local Title = Instance.new("TextLabel", Sidebar)
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.Text = "SMILE-X ++"
    Title.TextColor3 = Color3.fromRGB(0, 255, 127)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.BackgroundTransparency = 1

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -160, 1, -150)
    Container.Position = UDim2.new(0, 155, 0, 10)
    Container.BackgroundTransparency = 1

    local TabList = Instance.new("ScrollingFrame", Sidebar)
    TabList.Size = UDim2.new(1, 0, 1, -70)
    TabList.Position = UDim2.new(0, 0, 0, 65)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabList).HorizontalAlignment = Enum.HorizontalAlignment.Center

    local ConsoleFrame = Instance.new("ScrollingFrame", Main)
    ConsoleFrame.Size = UDim2.new(1, -165, 0, 120)
    ConsoleFrame.Position = UDim2.new(0, 155, 1, -130)
    ConsoleFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    local ConsoleLayout = Instance.new("UIListLayout", ConsoleFrame)

    self.UpdateLog = function(text, color)
        local l = Instance.new("TextLabel", ConsoleFrame)
        l.Size = UDim2.new(1, 0, 0, 18)
        l.BackgroundTransparency = 1
        l.Text = " [>] " .. text
        l.TextColor3 = color or Color3.fromRGB(0, 255, 127)
        l.Font = Enum.Font.Code
        l.TextSize = 12
        ConsoleFrame.CanvasSize = UDim2.new(0, 0, 0, ConsoleLayout.AbsoluteContentSize.Y)
    end

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
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    
    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Container:GetChildren()) do p.Visible = false end
        Page.Visible = true
        self.UpdateLog("สลับไปหน้า: " .. name)
    end)
    return Page
end

function UI:CreateButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    
    Btn.MouseButton1Click:Connect(function()
        local oldColor = Btn.BackgroundColor3
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        task.wait(0.2)
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = oldColor}):Play()
        callback()
    end)
    return Btn
end

-- [ 5. HOOK ENGINE ]
local function InitiateEngine()
    local MT = getrawmetatable(game)
    local OldNC = MT.__namecall
    setreadonly(MT, false)

    MT.__namecall = newcclosure(function(self, ...)
        local Method = getnamecallmethod()
        if SmileX.ScannerActive and (Method == "FireServer" or Method == "InvokeServer") then
            UI.UpdateLog("DETECTED: " .. self.Name, Color3.fromRGB(0, 200, 255))
            SendToDiscord("🔥 Remote Found", "Name: "..self.Name.."\nPlace: "..game.PlaceId, 16711680)
        end
        return OldNC(self, ...)
    end)
    setreadonly(MT, true)
end

-- [ 6. EXECUTION ]
UI:Init()
local HomeTab = UI:AddTab("Dashboard")
local ExecTab = UI:AddTab("Executor")

-- Setup HomeTab
Instance.new("UIListLayout", HomeTab).Padding = UDim.new(0, 10)
UI:CreateButton(HomeTab, "INJECT ENGINE", Color3.fromRGB(0, 150, 255), function()
    InitiateEngine()
    UI.UpdateLog("Engine Injected!", Color3.fromRGB(0, 255, 0))
end)

UI:CreateButton(HomeTab, "REMOTE SPY: OFF", Color3.fromRGB(200, 150, 0), function()
    SmileX.ScannerActive = not SmileX.ScannerActive
    UI.UpdateLog("Scanner: " .. (SmileX.ScannerActive and "ON" or "OFF"))
end)

-- Setup ExecTab
local CodeBox = Instance.new("TextBox", ExecTab)
CodeBox.Size = UDim2.new(1, -10, 0, 200)
CodeBox.MultiLine = true
CodeBox.Text = "-- พิมพ์สคริปต์ที่นี่"
CodeBox.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
CodeBox.TextColor3 = Color3.fromRGB(0, 255, 127)
CodeBox.Font = Enum.Font.Code
CodeBox.TextSize = 14
CodeBox.TextYAlignment = Enum.TextYAlignment.Top
CodeBox.TextXAlignment = Enum.TextXAlignment.Left

UI:CreateButton(ExecTab, "EXECUTE", Color3.fromRGB(0, 200, 100), function()
    local func, err = loadstring(CodeBox.Text)
    if func then pcall(func) UI.UpdateLog("Success!") else UI.UpdateLog("Error: "..err, Color3.fromRGB(255,0,0)) end
end)

if LoadConfig() then UI.UpdateLog("Cloud Config Loaded", Color3.fromRGB(0, 255, 0)) end
UI.UpdateLog("Welcome Pipe!", Color3.fromRGB(255, 255, 255))
    else
        DebugLog("โหลด Config พลาด: " .. tostring(result), Color3.fromRGB(255, 0, 0))
    end
end

-- [ 4. METATABLE BYPASS ENGINE ]
-- ระบบขุดดินพื้นฐานแต่ทรงพลัง
local function InitiateEngine()
    DebugLog("กำลังเตรียมการขุดดิน (Bypass FE)...")
    local MT = getrawmetatable(game)
    local OldNC = MT.__namecall
    setreadonly(MT, false)

    MT.__namecall = newcclosure(function(self, ...)
        local Method = getnamecallmethod()
        -- ระบบ Scanner ในตัว
        if Method == "FireServer" or Method == "InvokeServer" then
            DebugLog("ตรวจพบการส่งข้อมูล: " .. self.Name)
        end
        return OldNC(self, ...)
    end)
    setreadonly(MT, true)
    DebugLog("Engine พร้อมทำงาน!", Color3.fromRGB(255, 255, 0))
end

-- [ 5. EXECUTION ]
LoadConfig()
InitiateEngine()
DebugLog("--- SMILE-X SS++ STARTED ---")
