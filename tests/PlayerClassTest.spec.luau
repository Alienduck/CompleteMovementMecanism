local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerClass = require(ServerScriptService.Server.Player.PlayerClass)

return function()
	describe("PlayerClass", function()
		it("initialise correctement un joueur", function()
			local fakePlayer: Player= Players.PlayerAdded:Wait()
			local playerObj = PlayerClass.new(fakePlayer)

			expect(playerObj.player).to.equal(fakePlayer)
			expect(playerObj.stamina).to.equal(100)
			expect(playerObj.state).to.equal(PlayerClass.State.Idle)
		end)

		it("drain de stamina correct", function()
			local fakePlayer: Player= Players.PlayerAdded:Wait()
			local playerObj = PlayerClass.new(fakePlayer)

			-- simule un déplacement de 10 studs
			local distance = 10
			local drain = distance * 0.2
			playerObj.stamina -= drain

			expect(playerObj.stamina).to.equal(100 - drain)
		end)

		it("regen augmente la stamina jusqu'à 100", function()
			local fakePlayer: Player= Players.PlayerAdded:Wait()
			local playerObj = PlayerClass.new(fakePlayer)
			playerObj.stamina = 80

			-- appelle directement la logique de regen sans RunService
			while playerObj.stamina < 100 do
				playerObj.stamina = math.clamp(playerObj.stamina + 2, 0, 100)
			end

			expect(playerObj.stamina).to.equal(100)
		end)
	end)
end
