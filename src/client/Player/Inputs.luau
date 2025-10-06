-- Object
local Inputs = {}
Inputs.__index = Inputs

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Utility = require(ReplicatedStorage.Shared.Utility)
local InputAction = require(ReplicatedStorage.Shared.Systems.InputAction)

-- Connections | Thread
local _startRun: RBXScriptConnection? = nil
local _stopRun: RBXScriptConnection? = nil

-- Actions
local RunAction: InputAction.Action = InputAction.GetAction("idle", "run")
RunAction.KeyboardBinding.KeyCode = Enum.KeyCode.LeftShift
RunAction.GamepadBinding.KeyCode = Enum.KeyCode.ButtonL3
_startRun = RunAction.Pressed:Connect(function ()
    Utility.CreateRemoteEvent("PlayerStartRun", Utility.CreateFolder("RemoteEvents")):FireServer()
end)

_stopRun = RunAction.Released:Connect(function ()
    Utility.CreateRemoteEvent("PlayerStopRun", Utility.CreateFolder("RemoteEvents")):FireServer()
end)

return Inputs