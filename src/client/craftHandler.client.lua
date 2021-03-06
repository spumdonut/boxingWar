local KLItems = require(game.ReplicatedStorage.Common.KLItems)

--/ Events
local KLEvents = game.ReplicatedStorage:WaitForChild('KLEvents')
local CraftEvent = KLEvents.CraftEvent

--/ Gui
local PlayerGui = game.Players.LocalPlayer.PlayerGui
local CraftingGui = PlayerGui:WaitForChild('CraftingGui')
local MainGui = PlayerGui:WaitForChild('MainGui')
local CraftingCategories = CraftingGui.CraftingCategories
local CraftingItems = CraftingGui.CraftingItems
local CraftButton = MainGui.CraftButton

local isOpen = nil

local function onItemClick(toCraft)
    CraftEvent:FireServer(toCraft)
end

local function handleButtonInstance(value, parent)
    local button = Instance.new('TextButton', parent)
    button.Name = value
    button.Text = string.lower(value:gsub("(%l)(%u)", "%1 %2"))
    button.BackgroundTransparency = 1
    button.BackgroundColor3 = Color3.new(0, 0, 0)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(255, 255, 255)

    button.MouseButton1Down:Connect(function()
        onItemClick(button.Name)
    end)
end

local function destroyOldButtons()
    for _, v in pairs(CraftingItems:GetChildren()) do
        if v:IsA('TextButton') then
            v:Destroy()
        end
    end
end

local function createItemButtons(category)
    if isOpen ~= category then
        destroyOldButtons()

        for categoryIndex, items in pairs(KLItems.Items) do
            if categoryIndex == category then
                for item, _ in pairs(items) do
                    handleButtonInstance(item, CraftingItems)
                end
            end
        end
        isOpen = category
    else
        destroyOldButtons()
        isOpen = nil
    end
end

local function onCatergoryClick(value)
    createItemButtons(value)
end

for _, button in pairs(CraftingCategories:GetChildren()) do
    local isButton = button:IsA('TextButton')
    if isButton then
        button.MouseButton1Down:Connect(function()
            onCatergoryClick(button.Name)
        end)
    end
end

local function handleCraftingVisible()
    CraftingGui.Enabled = not CraftingGui.Enabled

    if CraftingGui.Enabled == true then
        destroyOldButtons()
        isOpen = nil
    end
end

-- / Bindings
CraftButton.MouseButton1Down:Connect(handleCraftingVisible)