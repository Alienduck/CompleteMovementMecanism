-- Classe
local PlayerClass = {}
PlayerClass.__index = PlayerClass

-- Services

-- Modules

-- Types
export type PlayerClassType = {
	-- Public
	stamina: number,
	state: number,

	-- Private

	-- Public Methods

	-- Private Methods
}

export type PlayerStateEnumType = {
	Idle: number,
	Walk: number,
	Run: number,
}

-- Enums
local PlayerStateEnum = table.freeze({
    Idle = 1,
    Walk = 2,
    Run = 3,
})
PlayerClass.State = PlayerStateEnum

function PlayerClass.new(player: Player): PlayerClassType
	local self = setmetatable({}, PlayerClass)
	local typedSelf: PlayerClassType = self

	typedSelf.stamina = 100
	typedSelf.state = PlayerStateEnum.Idle

	return typedSelf
end

function PlayerClass.StartRun(self: PlayerClassType)
	
end

return PlayerClass
