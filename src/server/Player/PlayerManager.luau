local PlayerManager = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Utility = require(ReplicatedStorage.Shared.Utility)
local PlayerClass = require(script.Parent.PlayerClass)

-- Variables
local Players: { [number]: PlayerClass.PlayerClassType } = {}

function PlayerManager.addPlayer(player: Player)
    local newPlayerClass: PlayerClass.PlayerClassType = PlayerClass.new(player) :: PlayerClass.PlayerClassType
	if newPlayerClass then
        print("Add player: " .. player.Name .. "in Players")
        Players[player.UserId] = newPlayerClass
	end
    print(Players)
end

function PlayerManager.removePlayer(player: Player)
    Players[player.UserId] = nil
end

function PlayerManager.getPlayer(player: Player): PlayerClass.PlayerClassType
    return Players[player.UserId]
end

function PlayerManager.getAll()
    return Players
end

-- Remotes | Bindables
Utility.CreateRemoteEvent("PlayerStartRun", Utility.CreateFolder("RemoteEvents"), function (player: Player)
    local playerObj: PlayerClass.PlayerClassType = PlayerManager.getPlayer(player)
    if not playerObj then Utility.Warn("No player with id: " .. tostring(player.UserId), script.Name); return end
    playerObj:StartRun()
end)

Utility.CreateRemoteEvent("PlayerStopRun", Utility.CreateFolder("RemoteEvents"), function (player: Player)
    local playerObj: PlayerClass.PlayerClassType = PlayerManager.getPlayer(player)
    if not playerObj then Utility.Warn("No player with id: " .. tostring(player.UserId), script.Name); return end
    playerObj:StopRun()
end)

return PlayerManager
