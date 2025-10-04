local PlayerManager = {}

-- Services
local PlayerClass = require(script.Parent.PlayerClass)

-- Modules

-- Variables
local Players: { [number]: PlayerClass.PlayerClassType } = {}

function PlayerManager.addPlayer(player: Player)
	Players[player.UserId] = PlayerClass.new(player)
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

return PlayerManager
