local KLDealer = require(script.Parent.KLDealer)
local positions = require(script.Parent.positions)
local ReplicatedStorage = game.ReplicatedStorage

local Sdk = {
    data = {}
}

local function onCharacherTouched(part, player)
    local attribute = part:GetAttribute('String')
    if not attribute then return end

    local data = Sdk.data
    data[player].Materials[attribute]+=1
    part:Destroy()
    print('MESSAGE/Info: ' .. player.Name .. ' has picked up a ' .. attribute .. ' and their ' .. attribute .. ' are now ' .. data[player].Materials[attribute] .. '.')
end

local function onCharacterAdded(character)
    local player = game.Players:GetPlayerFromCharacter(character)
    local characterChildren = character:GetChildren()

    for _, v in pairs(characterChildren) do
        local isPart = v:IsA('Part')
        if isPart then
            v.Touched:Connect(function(part)
                onCharacherTouched(part, player)
            end)
        end
    end
end

local function takesPotion(player, potion)
    local data = Sdk.data
    local potions = data[player].Potions
    local potionBool = potions[potion].bool
    local potionValue = potions[potion].value

    local hasPotion = potionBool == true
    if hasPotion then
        potions[potion].bool = false
        KLDealer.addHealth(player, potionValue)

        warn(player.Name .. ' took a '.. potion .. ' potion and has been given more health :)')
    end
end

local function onPlayerAdded(player)

    local data = Sdk.data
    data[player] = {}

    --/ materials
    data[player].Materials = {}
    local materials = data[player].Materials
    data[player].Materials['Sticks'] = 0

    --/ potions
    data[player].Potions = {}
    data[player].Potions['halfHealth'] = {bool = true, value = 50}
    data[player].Potions['fullHealth'] = {bool = true, value = 100}

    --/ canHurt
    data[player].canHurt = true

    --/ level
    local level = data[player].Level
    level = 1
    local xp = data[player].Xp
    xp = 0

    -- Todo add formula for xp and level so that you need more xp to reach next level
    local function levelAndXpHandler()
        local canAddXp = true
        if canAddXp == true then
            xp+=1
            canAddXp = false
            wait(1)
            canAddXp = true
        end

        if xp == 10 then
            xp = 0
            level +=1
        end
    end

    warn('MESSAGE/Info: Data has been added for ' .. player.Name .. '.')

    player.CharacterAdded:Connect(onCharacterAdded)

    while true do
        task.wait()
        local playerData = data[player]
        KLDealer.smoke(player, playerData)
        levelAndXpHandler()
    end
end

local function onPlayerRemoving(player)
    local data = Sdk.data
    data[player] = nil 

    warn('MESSAGE/Info:  Data has been removed for ' .. player.Name .. '.')
end

local function createMaterials()
    local Materials = ReplicatedStorage:WaitForChild('Materials')
    local stick = Materials.Stick
    
    for i = 1, math.random(4, 7) do
        local stickClone = stick:Clone()
        stickClone.Parent = workspace
        stickClone.Position = positions.positionfy(stickClone)
        stickClone:SetAttribute('String', 'Sticks')
    end
end

function Sdk.initialize()
    createMaterials()

    --/ Events
    local potionEvent = Instance.new('RemoteEvent', ReplicatedStorage)
    potionEvent.Name = 'potionEvent'

    --/ Event Bindings
    potionEvent.OnServerEvent:Connect(takesPotion)

    game.Players.PlayerAdded:Connect(onPlayerAdded)
    game.Players.PlayerRemoving:Connect(onPlayerRemoving)
end

return Sdk