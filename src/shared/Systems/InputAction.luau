--!strict
local actionTemplate: InputAction = Instance.new("InputAction")
actionTemplate.Name = "ActionTemplate"
actionTemplate.Parent = script
actionTemplate.Type = Enum.InputActionType.Bool

local GamepadBinding: InputBinding = Instance.new("InputBinding")
GamepadBinding.Name = "GamepadBinding"
GamepadBinding.Parent = actionTemplate

local KeyboardBinding: InputBinding = Instance.new("InputBinding")
KeyboardBinding.Name = "KeyboardBinding"
KeyboardBinding.Parent = actionTemplate

export type Action = typeof(script.ActionTemplate)
export type KeybindImpl = {
	CurrentContext: string,
	EnableContext: (context: string) -> (),
	GetAction: (context: string, name: string) -> Action,
}

export type KeybindContext = {
	context: InputContext,
	keybinds: { [string]: Action },
}

-- module table:
local Keybind: KeybindImpl = { CurrentContext = "" } :: KeybindImpl

-- constant variables
local ACTION_TEMPLATE = script.ActionTemplate
local ALWAYS_ON_STATE = "idle" -- this state will always be on

-- Private variables
local keybinds: { [string]: KeybindContext } = {}

-- Private functions
local function getContext(name: string): Action
	if not keybinds[name] then
		local context = Instance.new("InputContext")
		context.Enabled = name == ALWAYS_ON_STATE
		context.Name = name
		context.Parent = script

		keybinds[name] = {
			context = context,
			keybinds = {},
		}
	end
	return keybinds[name]
end

local function getEmptyAction(): Action
	return ACTION_TEMPLATE:Clone()
end

-- Global methods
function Keybind.GetAction(ctx: string, name: string): Action
	local context: KeybindContext = getContext(ctx)

	local action = context.keybinds[name]
	if action == nil then
		action = getEmptyAction()
		action.Name = name
		action.Parent = context.context

		for _, v in action:GetChildren() do
			local binding = v :: InputBinding
			local bindingName = v.Name

			binding:GetPropertyChangedSignal("KeyCode"):Connect(function()
				if binding.KeyCode == Enum.KeyCode.Unknown then
					return
				end

				-- cannot bind non-gamepad keycodes into gamepad binding
				local isGamepadBinding = (
					binding.KeyCode.Name:find("Button") ~= nil or binding.KeyCode.Name:find("DPad") ~= nil
				) and binding.KeyCode.Name:find("Mouse") == nil

				if (bindingName == "GamepadBinding") ~= isGamepadBinding then
					binding.KeyCode = Enum.KeyCode.Unknown
					warn(
						"Invalid keybind provided. Gamepad bindings must only use gamepad buttons, and vice versa for keyboard."
					)
					return
				end

				-- loop to check for duplicates
				for otherName, v in context.keybinds do
					if v == action then
						continue
					end -- don't check itself

					if v[bindingName].KeyCode == binding.KeyCode then
						warn(`Conflicting keybinds found for {name} and {otherName}.`)
					end
				end
			end)
		end

		context.keybinds[name] = action
	end
	return action
end

function Keybind.EnableContext(context)
	for name: string, v: KeybindContext in keybinds do
		v.context.Enabled = name == context or name == ALWAYS_ON_STATE
	end
	Keybind.CurrentContext = context
end

return Keybind -- :: KeybindImpl
