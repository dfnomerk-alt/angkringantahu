local v = "1.6.62"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. v .. "/main.lua"))()

local conf = {
    target = "",
    price = 100,
    maxW = 2.0, 
    amt = 3,
    delay = 6.0,      
    loop = 10.0, 
    active = false,
    busy = false,
    maxSlot = 50, 
    done = {}
}

local stats = { listed = 0, gems = 0 }

local win = WindUI:CreateWindow({
    Title = "PauLGG | AFK Market",
    SubTitle = "v7.6 | STABLE",
    Author = "PauL",
    Folder = "PaulGG",
    Icon = "solar:shield-check-bold",
    NewElements = true,
    Transparent = true,
    Acrylic = true,
    TransparencyValue = 0.2,
    OpenButton = { 
        Title = "Open",
        Enabled = true, 
        Draggable = true,
        Icon = "solar:ghost-bold",
        Size = UDim2.fromOffset(45, 45),
        Color = ColorSequence.new(Color3.fromHex("#30FF6A"), Color3.fromHex("#e7ff2f"))
    }
})

win:Tag({ Title = "iPowfu Private", Icon = "solar:verified-check-bold", Color = Color3.fromHex("#1c1c1c"), Border = true })

local main = win:Tab({ Title = "Main", Icon = "solar:scanner-bold" })
local info = win:Tab({ Title = "Stats", Icon = "solar:chart-square-bold" })
local opt = win:Tab({ Title = "Settings", Icon = "solar:settings-bold" })

local sec1 = main:Section({ Title = "Setup" })
sec1:Input({ Title = "Pet Name", Callback = function(x) conf.target = x end })
sec1:Input({ Title = "Price", Callback = function(x) conf.price = tonumber(x) or 100 end })
sec1:Input({ Title = "Amount", Callback = function(x) conf.amt = tonumber(x) or 3 end })

local sec2 = main:Section({ Title = "Control" })
sec2:Toggle({
    Title = "Auto Run",
    Value = false,
    Callback = function(s)
        conf.active = s
        if s then
            conf.done = {}
            task.spawn(function()
                while conf.active do
                    if not conf.busy then
                        conf.busy = true
                        local lp = game.Players.LocalPlayer
                        
                        local function getCount()
                            local b = lp.PlayerGui:FindFirstChild("TradeBooth") or lp.PlayerGui:FindFirstChild("Booth")
                            if b then
                                local f = b:FindFirstChild("List", true) or b:FindFirstChild("ScrollingFrame", true)
                                if f then
                                    local n = 0
                                    for _, i in pairs(f:GetChildren()) do
                                        if i:IsA("Frame") or i:IsA("ImageButton") then n = n + 1 end
                                    end
                                    return n
                                end
                            end
                            return 0
                        end

                        local cur = getCount()
                        _G.BoothStatus:SetTitle("Booth: " .. cur .. "/50")

                        if cur < conf.maxSlot and conf.target ~= "" then
                            local bp = lp:FindFirstChild("Backpack")
                            local list = {}
                            if bp then
                                for _, item in pairs(bp:GetChildren()) do
                                    if #list >= conf.amt or (cur + #list) >= conf.maxSlot then break end
                                    if string.find(item.Name:lower(), conf.target:lower()) then
                                        local w = tonumber(string.match(item.Name, "%d+%.?%d*")) or 0
                                        if w <= conf.maxW then
                                            local id = item:GetAttribute("PET_UUID")
                                            if id and not conf.done[id] then
                                                table.insert(list, {obj = item, id = id})
                                            end
                                        end
                                    end
                                end

                                for _, p in pairs(list) do
                                    if not conf.active then break end
                                    local ok = game:GetService("ReplicatedStorage").GameEvents.TradeEvents.Booths.CreateListing:InvokeServer("Pet", tostring(p.id), conf.price)
                                    if ok then
                                        conf.done[p.id] = true
                                        stats.listed = stats.listed + 1
                                        stats.gems = stats.gems + conf.price
                                        _G.SalesStatus:SetTitle("Listed: " .. stats.listed)
                                        _G.GemStatus:SetTitle("Total: " .. stats.gems)
                                        WindUI:Notify({Title = "Success", Content = p.obj.Name .. " Listed", Type = "success"})
                                    end
                                    task.wait(conf.delay)
                                end
                            end
                        end
                        task.wait(conf.loop)
                        conf.busy = false
                    else task.wait(1) end
                end
            end)
        end
    end
})

local secStats = info:Section({ Title = "Session" })
_G.BoothStatus = secStats:Paragraph({ Title = "Booth: 0/50", Content = "Checking..." })
_G.SalesStatus = secStats:Paragraph({ Title = "Listed: 0", Content = "Pets sold this session" })
_G.GemStatus = secStats:Paragraph({ Title = "Total: 0", Content = "Tokens earned" })

local secOpt = opt:Section({ Title = "Tweak" })
secOpt:Input({ Title = "Max Weight", Value = "2.0", Callback = function(x) conf.maxW = tonumber(x) or 2.0 end })
secOpt:Slider({ Title = "Item Delay", Step = 0.5, Value = { Min = 1, Max = 15, Default = 6 }, Callback = function(x) conf.delay = x end })
secOpt:Slider({ Title = "Loop Delay", Step = 1, Value = { Min = 5, Max = 60, Default = 10 }, Callback = function(x) conf.loop = x end })
