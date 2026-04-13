-- [[ SMILE-X ULTIMATE SS++ ]]
-- START FROM ZERO: THE FRAMEWORK

local SmileX = {
    Config = {},
    Version = "3.0.0",
    Log = {}
}

-- [ 1. SERVICES ]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- [ 2. INTERNAL LOGGING SYSTEM ]
-- ฟังก์ชันสำหรับบันทึกการทำงานของ "ไส้ใน"
local function DebugLog(msg, color)
    local timestamp = os.date("%X")
    print(string.format("[%s] [SMILE-X]: %s", timestamp, msg))
    -- เดี๋ยวเราจะเอาไปโชว์ใน UI ภายหลัง
end

-- [ 3. JSON DATA FETCHING ]
-- ก้าวแรกของระบบ ++ คือการดึงข้อมูลจาก Cloud
local function LoadConfig()
    DebugLog("กำลังดึงข้อมูลจาก Cloud...", Color3.fromRGB(0, 255, 255))
    -- Pipe ต้องเอาลิงก์ Raw JSON ของตัวเองมาใส่ตรงนี้
    local rawUrl = "https://raw.githubusercontent.com/pipe-2467/Smile-X-Project-V4-Fixed/refs/heads/main/config.json" 
    
    local success, result = pcall(function()
        return HttpService:GetAsync(rawUrl)
    end)
    
    if success then
        SmileX.Config = HttpService:JSONEncode(result)
        DebugLog("โหลด Config สำเร็จ! เวอร์ชัน: " .. SmileX.Version, Color3.fromRGB(0, 255, 0))
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
