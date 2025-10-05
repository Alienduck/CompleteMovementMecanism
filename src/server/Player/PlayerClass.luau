-- Classe
local PlayerClass = {}
PlayerClass.__index = PlayerClass

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Utility = require(ReplicatedStorage.Shared.Utility)

-- Modules

-- Constantes
-- Stamina
local STAMINA_DRAIN_PER_STUD = 0.2
local STAMINA_REGEN_RATE = 2 -- points régénérés toutes les 0.5s
local REGEN_INTERVAL = 0.5
local MIN_STAMINA = 0
local MAX_STAMINA = 100

-- Player Params
local PLAYER_WALK_SPEED = 16
local PLAYER_RUN_SPEED = 24

-- Types
export type PlayerClassType = {
	-- Public
	player: Player,
	character: Model,
	humanoid: Humanoid,
	HumanoidRootPart: BasePart?,
	stamina: number,
	state: number,

	-- Private
	_playerRunConn: RBXScriptConnection?,
	_playerStaminaRegenThread: thread?,

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
function PlayerClass.new(player: Player): PlayerClassType?
	local self = setmetatable({}, PlayerClass)
	local typedSelf: PlayerClassType = self

	typedSelf.player = player
	typedSelf.character = player.Character :: Model
	if not typedSelf.character then
		Utility.Warn("No Character found in " .. player.Name, script.Name)
		return
	end
	typedSelf.humanoid = typedSelf.character:FindFirstChildOfClass("Humanoid") :: Humanoid
	if not typedSelf.humanoid then
		Utility.Warn("No humanoid found in " .. player.Name, script.Name)
		return
	end
	typedSelf.HumanoidRootPart = typedSelf.character:WaitForChild("HumanoidRootPart") :: BasePart
	if not typedSelf.HumanoidRootPart then
		Utility.Warn("No HumanoidRootPart found in " .. player.Name, script.Name)
		return
	end

	typedSelf.stamina = 100
	typedSelf.state = PlayerStateEnum.Idle

	-- Private
	typedSelf._playerRunConn = nil
	typedSelf._playerStaminaRegenThread = nil

	return typedSelf
end

function PlayerClass.Init(self: PlayerClassType)
	self.humanoid.WalkSpeed = PLAYER_WALK_SPEED
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
		self.humanoid.WalkSpeed = PLAYER_RUN_SPEED

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
	self.humanoid.WalkSpeed = PLAYER_WALK_SPEED

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
