-- Object
local Main = {}

-- Services
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
-- local testez = require(ServerScriptService.DevPackages.testez)
local PlayerManager = require(ServerScriptService.Server.Player.PlayerManager)

-- Connections
local _playerAddedConn: RBXScriptConnection | nil = nil
local _playerRemovingConn: RBXScriptConnection | nil = nil

-- Start Tests
-- local testsFolder: Folder = ServerScriptService.Tests
-- testez.TestBootstrap:run(
--     {testsFolder},
--     testez.Reporters.TextReporter
-- )

-- Init
_playerAddedConn = Players.PlayerAdded:Connect(function (player: Player)
    PlayerManager.addPlayer(player)
end)

_playerRemovingConn = Players.PlayerRemoving:Connect(function (player: Player)
    PlayerManager.removePlayer(player)
end)

return Main