-- Classe
local PlayerClass = {}
PlayerClass.__index = PlayerClass

-- Services
local RunService = game:GetService("RunService")

-- Modules

-- Constantes
local STAMINA_DRAIN_PER_STUD = 0.2
local STAMINA_REGEN_RATE = 2 -- points régénérés toutes les 0.5s
local REGEN_INTERVAL = 0.5
local MIN_STAMINA = 0
local MAX_STAMINA = 100

-- Types
export type PlayerClassType = {
	-- Public
	player: Player,
	stamina: number,
	state: number,

	-- Private
	_playerRunConn: RBXScriptConnection | nil,
	_playerStaminaRegenThread: thread | nil,

	-- Public Methods
	new: (player: Player) -> PlayerClassType,
	StartRun: (self: PlayerClassType) -> (),
	StopRun: (self: PlayerClassType) -> (),

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

-- Constructor
function PlayerClass.new(player: Player): PlayerClassType
	local self = setmetatable({}, PlayerClass)
	local typedSelf: PlayerClassType = self

	typedSelf.player = player
	typedSelf.stamina = 100
	typedSelf.state = PlayerStateEnum.Idle

	typedSelf._playerRunConn = nil
	typedSelf._playerStaminaRegenThread = nil

	return typedSelf
end

-- Démarre la consommation de stamina
function PlayerClass.StartRun(self: PlayerClassType)
	local character = self.player.Character
	if not character then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local lastPos = root.Position

	-- stop éventuelle regen en cours
	if self._playerStaminaRegenThread then
		task.cancel(self._playerStaminaRegenThread)
		self._playerStaminaRegenThread = nil
	end

	if self._playerRunConn then
		self._playerRunConn:Disconnect()
	end

	self._playerRunConn = RunService.Heartbeat:Connect(function()
		if not root or not root.Parent then
			if self._playerRunConn then
				self._playerRunConn:Disconnect()
			end
			self._playerRunConn = nil
			return
		end

		local currentPos = root.Position
		local distance = (currentPos - lastPos).Magnitude
		lastPos = currentPos

		self.stamina -= distance * STAMINA_DRAIN_PER_STUD
		if self.stamina <= MIN_STAMINA then
			self.stamina = MIN_STAMINA
			self:StopRun()
		end
	end)
end

function PlayerClass.StopRun(self: PlayerClassType)
	if self._playerRunConn then
		self._playerRunConn:Disconnect()
		self._playerRunConn = nil
	end

	-- lance un thread qui régénère la stamina progressivement
	self._playerStaminaRegenThread = task.spawn(function()
		while self.stamina < MAX_STAMINA do
			self.stamina = math.clamp(self.stamina + STAMINA_REGEN_RATE, 0, MAX_STAMINA)
			task.wait(REGEN_INTERVAL)
		end
		self._playerStaminaRegenThread = nil
	end)
end

return PlayerClass
