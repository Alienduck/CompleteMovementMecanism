local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputAction = require(ReplicatedStorage.Shared.Systems.InputAction)

local RunAction: InputAction.Action = InputAction.GetAction("idle", "run")

RunAction.KeyboardBinding.KeyCode = Enum.KeyCode.LeftShift
print(RunAction.KeyboardBinding.KeyCode)
