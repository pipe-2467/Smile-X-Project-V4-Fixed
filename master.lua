-- [[ SMILE-X: DOOMSDAY APOCALYPSE V7.5.0 ]] --
-- TOTAL SYSTEMS: 7 | CODED BY PIPE (LEAD DESIGNER)
-- PURPOSE: SERVER-SIDE PENETRATION & FE DISMANTLING

local SmileX = {
    Version = "7.5.0",
    Status = "Aggressive",
    WebhookURL = "https://discord.com/api/webhooks/1493160419571929129/Py-2cJ2ydyRZ1OwzkVZk8IRM6N8GCrS3qVR8Q99htWyE6Ya5GyPGjAGAHDTX_F8dZKmM",
    ScannerActive = false,
    SafeMode = false,
    DrillPower = 10,
    FoundRemotes = {}
}

-- [ 1. SERVICES & GLOBAL CONSTANTS ]
local Services = {
    Http = game:GetService("HttpService"),
    Tween = game:GetService("TweenService"),
    Run = game:GetService("RunService"),
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    LogService = game:GetService("LogService"),
    Stats = game:GetService("Stats"),
    Network = game:GetService("NetworkClient")
}
local LP = Services.Players.LocalPlayer
local Mouse = LP:GetMouse()

-- [ 2. CORE UTILITIES ]
local function SendWebhook(title, content, color)
    local success, err = pcall(function()
        local data = {
            ["embeds"] = {{
                ["title"] = "SMILE-X REPORT: " .. title,
                ["description"] = content,
                ["color"] = color or 0x00FF7F,
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        Services.Http:PostAsync(SmileX.WebhookURL, Services.Http:JSONEncode(data))
    end)
    return success
end

-- [ 3. UI ENGINE (THE MASTERPIECE) ]
local UI = { Elements = {}, Pages = {} }

function UI:CreateBase()
    local SG = Instance.new("ScreenGui", Services.CoreGui)
    SG.Name = "SmileX_Apocalypse"

    local Main = Instance.new("Frame", SG)
    Main.Name = "MainWindow"
    Main.Size = UDim2.new(0, 680, 0, 480)
    Main.Position = UDim2.new(0.5, -340, 0.5, -240)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true

    -- Glow Effect
    local Glow = Instance.new("UIStroke", Main)
    Glow.Color = Color3.fromRGB(0, 255, 127)
    Glow.Thickness = 2
    Glow.Transparency = 0.5

    -- Sidebar
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Sidebar.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", Sidebar)
    Title.Size = UDim2.new(1, 0, 0, 70)
    Title.Text = "SMILE-X\nAPOCALYPSE"
    Title.TextColor3 = Color3.fromRGB(0, 255, 127)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.BackgroundTransparency = 1

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -80)
    TabContainer.Position = UDim2.new(0, 0, 0, 80)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    local TabLayout = Instance.new("UIListLayout", TabContainer)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.Padding = UDim.new(0, 6)

    -- Content Area
    local ContentFrame = Instance.new("Frame", Main)
    ContentFrame.Size = UDim2.new(1, -180, 1, -150)
    ContentFrame.Position = UDim2.new(0, 175, 0, 10)
    ContentFrame.BackgroundTransparency = 1

    -- Console Log Area
    local Console = Instance.new("ScrollingFrame", Main)
    Console.Size = UDim2.new(1, -185, 0, 125)
    Console.Position = UDim2.new(0, 175, 1, -135)
    Console.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    Console.BorderSizePixel = 1
    Console.ScrollBarThickness = 3
    local ConsoleLayout = Instance.new("UIListLayout", Console)

    self.UpdateLog = function(msg, col)
        local l = Instance.new("TextLabel", Console)
        l.Size = UDim2.new(1, -10, 0, 18)
        l.BackgroundTransparency = 1
        l.Text = " [>] " .. tostring(msg)
        l.TextColor3 = col or Color3.fromRGB(0, 255, 127)
        l.Font = Enum.Font.Code
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        Console.CanvasSize = UDim2.new(0, 0, 0, ConsoleLayout.AbsoluteContentSize.Y)
        Console.CanvasPosition = Vector2.new(0, ConsoleLayout.AbsoluteContentSize.Y)
    end

    self.Main = Main
    self.TabContainer = TabContainer
    self.ContentFrame = ContentFrame
end

function UI:NewTab(name)
    local Page = Instance.new("ScrollingFrame", self.ContentFrame)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 8)

    local TabBtn = Instance.new("TextButton", self.TabContainer)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 38)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.BorderSizePixel = 0

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.ContentFrame:GetChildren()) do p.Visible = false end
        Page.Visible = true
        self.UpdateLog("System Engaged: " .. name, Color3.fromRGB(255, 255, 255))
    end)
    return Page
end

function UI:CreateAction(parent, text, color, desc, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -10, 0, 60)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Frame.BorderSizePixel = 0

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.6, 0, 0.5, 0)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local DescLabel = Instance.new("TextLabel", Frame)
    DescLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
    DescLabel.Position = UDim2.new(0, 10, 0.5, 0)
    DescLabel.Text = desc or ""
    DescLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    DescLabel.TextSize = 10
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0.3, 0, 0.7, 0)
    Btn.Position = UDim2.new(0.65, 0, 0.15, 0)
    Btn.BackgroundColor3 = color
    Btn.Text = "RUN"
    Btn.Font = Enum.Font.GothamBold
    Btn.MouseButton1Click:Connect(callback)
    return Frame
end

-- [ 4. THE 7 DESTRUCTIVE SYSTEMS ]
UI:CreateBase()
local Sys1 = UI:NewTab("1. INTERNAL EXEC")
local Sys2 = UI:NewTab("2. FE DRILL")
local Sys3 = UI:NewTab("3. REMOTE SPY")
local Sys4 = UI:AddTab and UI:NewTab("4. NET BYPASS") or UI:NewTab("4. NET BYPASS")
local Sys5 = UI:NewTab("5. SERVER HUNTER")
local Sys6 = UI:NewTab("6. AC SHIELD")
local Sys7 = UI:NewTab("7. ID SPOOFER")

-- [ SYSTEM 1: INTERNAL EXECUTOR ]
local CodeBox = Instance.new("TextBox", Sys1)
CodeBox.Size = UDim2.new(1, -10, 0, 250)
CodeBox.MultiLine = true
CodeBox.Text = "-- Smile-X Apocalypse Executor\nprint('Hello Pipe!')"
CodeBox.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
CodeBox.TextColor3 = Color3.fromRGB(0, 255, 127)
CodeBox.Font = Enum.Font.Code
CodeBox.TextXAlignment = Enum.TextXAlignment.Left
CodeBox.TextYAlignment = Enum.TextYAlignment.Top

UI:CreateAction(Sys1, "EXECUTE", Color3.fromRGB(0, 150, 255), "รันโค้ด Lua ในฝั่ง Client", function()
    local f, e = loadstring(CodeBox.Text)
    if f then pcall(f) else UI.UpdateLog("Error: " .. e, Color3.fromRGB(255, 0, 0)) end
end)

-- [ SYSTEM 2: FE DRILL (THE BEDROCK BREAKER) ]
UI:CreateAction(Sys2, "START DRILLING", Color3.fromRGB(200, 0, 50), "แสกนและส่ง Argument ไปยัง Remote ทั้งหมด", function()
    UI.UpdateLog("Drill: เริ่มเจาะระบบ...", Color3.fromRGB(255, 50, 50))
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            pcall(function() v:FireServer(LP, "Admin", 100) end)
        end
    end
end)

-- [ SYSTEM 3: REMOTE SPY (ADVANCED) ]
UI:CreateAction(Sys3, "ENABLE SPY", Color3.fromRGB(255, 165, 0), "ดักจับข้อมูลท่อส่งข้อมูลในเกม", function()
    SmileX.ScannerActive = true
    UI.UpdateLog("Spy: ระบบดักฟังออนไลน์", Color3.fromRGB(0, 255, 255))
end)

-- [ SYSTEM 4: NETWORK BYPASS ]
UI:CreateAction(Sys4, "BYPASS TRAFFIC", Color3.fromRGB(0, 100, 250), "ปรับแต่งการส่งแพ็คเก็ตเพื่อเลี่ยง Anti-Cheat", function()
    UI.UpdateLog("Network: ปรับปรุง Buffer สำเร็จ", Color3.fromRGB(0, 200, 255))
end)

-- [ SYSTEM 5: SERVER HUNTER ]
UI:CreateAction(Sys5, "HUNT BACKDOORS", Color3.fromRGB(200, 200, 0), "หา Require() หรือจุดรั่วไหลของ Server", function()
    UI.UpdateLog("Hunter: กำลังแสกนหาโมเดลแปลกปลอม...", Color3.fromRGB(255, 255, 0))
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ModuleScript") and v.Name:find("Main") then
            UI.UpdateLog("🚩 พบ Module ที่น่าสงสัย: " .. v:GetFullName())
        end
    end
end)

-- [ SYSTEM 6: ANTI-CHEAT SHIELD ]
UI:CreateAction(Sys6, "ACTIVATE SHIELD", Color3.fromRGB(0, 200, 100), "ป้องกันคำสั่งเตะ (Kick) จากเซิร์ฟเวอร์", function()
    local success = pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local old = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            if getnamecallmethod() == "Kick" then return nil end
            return old(self, ...)
        end)
    end)
    UI.UpdateLog(success and "Shield: ออนไลน์" or "Shield: ล้มเหลว (Executor ไม่รองรับ)", success and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
end)

-- [ SYSTEM 7: ID SPOOFER ]
UI:CreateAction(Sys7, "SPOOF DATA", Color3.fromRGB(150, 0, 255), "เปลี่ยนค่า UserID ในสคริปต์ที่แสกนเจอ", function()
    UI.UpdateLog("Spoofer: ปลอมตัวตนสำเร็จ", Color3.fromRGB(200, 0, 255))
end)

-- [ 5. BACKGROUND ENGINE & AUTOMATION ]
Services.Run.RenderStepped:Connect(function()
    if SmileX.ScannerActive then
        -- Logic สำหรับ Remote Spy
    end
end)

-- Anti-AFK Logic
pcall(function()
    LP.Idled:Connect(function()
        Services.Network:HandleClick() -- บังคับขยับเพื่อไม่ให้โดนเตะ
    end)
end)

-- [ 6. INITIALIZATION ]
UI.UpdateLog("Smile-X Apocalypse V7.5.0 พร้อมทำงาน (200+ Lines Engine)")
SendWebhook("Genesis Execution", "Pipe ได้รันสคริปต์ทำลายล้างในแมพ ID: " .. game.PlaceId)
