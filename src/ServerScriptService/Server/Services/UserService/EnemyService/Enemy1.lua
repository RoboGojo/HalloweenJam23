local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)
local BehaviorTreeCreator = require(Globals.Vendor.BehaviorTreeCreator)
local SimplePath = require(Globals.Vendor.SimplePath)

local EnemyConfig = Globals.Config.Enemies.Enemy1
local EnemyFolder = Globals.Assets.Enemies.Enemy1
local RoamSearchRange = 25

local Enemy1 = {}
Enemy1.Spawns = {}

local Random = Random.new()

function Enemy1:GameInit() end

local function GetRandomRetryWithCondition(array, condition)
	local spawnpoint = array[math.random(1, #array)]
	local player = game.Players:GetChildren()[1]
	if player and player.Character then
		while not condition(spawnpoint) do
			spawnpoint = array[math.random(1, #array)]
		end
	end
end

local function GetRandomSpawnpoint()
	local currentPlayer = game.Players:GetChildren()[1]

	if currentPlayer and currentPlayer.Character then
		return GetRandomRetryWithCondition(Enemy1.Spawns, function(spawn)
			return (spawn.Position - currentPlayer.Character.Origin.Position).Magnitude
				< EnemyConfig.MinSpawnDistanceFromPlayer
		end)
	end

	return Enemy1.Spawns[math.random(1, #Enemy1.Spawns)]
end

function Enemy1.new(spawnPosition)
	local janitor = Janitor.new()

	spawnPosition = spawnPosition or GetRandomSpawnpoint().Position

	local enemyModel = janitor:Add(EnemyFolder.Model:Clone())
	enemyModel.Parent = workspace
	enemyModel:PivotTo(CFrame.Angles(0, Random:NextNumber(0, 2 * math.pi), 0) + spawnPosition)

	local blackboard = {
		Model = enemyModel,
		Target = nil,
	}
	local Brain = janitor:Add(BehaviorTreeCreator:Create(EnemyFolder.Brain.Value, blackboard), "Destroy")
	local Path = janitor:Add(SimplePath.new(enemyModel), "Destroy")
	Janitor:Add(RunService.PostSimulation:Connect(function()
		Brain:run()
		if blackboard.Target then
			Path:Run(blackboard.Target)
		else
			Path:Stop()
		end
	end))

	return {
		Name = script.Name,
		Path = Path,
		Janitor = Janitor,
	}
end

local function PickRandomWithWeight(array, weightFunction)
	local selectable = {}

	local totalWeight = 0
	for _, v in ipairs(array) do
		local weight = weightFunction(v)

		table.insert(selectable, {
			Value = v,
			Weight = weight,
		})

		totalWeight += weight
	end

	local travelled = 0
	local x = Random:GetNextNumber(0, totalWeight)
	for _, v in ipairs(selectable) do
		if travelled < x then
			travelled += v.Weight
			continue
		end

		return v
	end
end

-- function Enemy1.GetNextRoamPoint(self)
-- 	local overlapParams = OverlapParams.new()
-- 	overlapParams.CollisionGroup = "Waypoint"
-- 	overlapParams.FilterType = Enum.RaycastFilterType.Include
-- 	overlapParams.FilterDescendantsInstances = self.Waypoints

-- 	local nearbyPoints = workspace:GetPartBoundsInBox(
-- 		CFrame.new(self.Model.Origin.Position),
-- 		RoamSearchRange * Vector3.new(1, 1, 1),
-- 		overlapParams
-- 	)

-- 	if #nearbyPoints == 0 then
-- 		return self.Waypoints[Random:NextInteger(1, #self.Waypoints)]
-- 	end

-- 	local player = game.Players:GetChildren()[1]
-- 	if player and player.Character then
-- 		local characterPosition = player.Character.Origin.Position
-- 		local entityToCharacter = (characterPosition - self.Model.Origin.Position).Unit

-- 		return PickRandomWithWeight(nearbyPoints, function(waypoint)
-- 			-- points closer to player have
-- 			local product = (waypoint - characterPosition).Unit:Dot(entityToCharacter)
-- 			return math.clamp((1 + product) / 2, 0, 1)
-- 		end)
-- 	else
-- 		return nearbyPoints[Random:NextInteger(1, #nearbyPoints)]
-- 	end
-- end

return Enemy1
