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

local function GetCurrentPlayerCharacter()
	local player = game.Players:GetChildren()[1]
	if player and player.Character and player.Character.Parent then
		return player.Character
	end
end

local function GetRandomRetryWithCondition(array, condition)
	local spawnpoint = array[math.random(1, #array)]
	
	if character then
		while not condition(spawnpoint) do
			spawnpoint = array[math.random(1, #array)]
		end
	end
end

local function GetRandomSpawnpoint()
	local character = GetCurrentPlayerCharacter()
	if character then
		return GetRandomRetryWithCondition(Enemy1.Spawns, function(spawn)
			return (spawn.Position - character.Origin.Position).Magnitude
				< EnemyConfig.MinSpawnDistanceFromPlayer
		end)
	end

	return Enemy1.Spawns[math.random(1, #Enemy1.Spawns)]
end

local function GetWaypointGraph(waypointFolder)
    local graph = {}

    for _, waypoint in ipairs(waypointFolder) do
        local overlapParams = OverlapParams.new()
        overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = {waypointFolder}
        overlapParams.BruteForceAllSlow = true
        graph[waypoint] = workspace:GetPartsInPart(waypoint, overlapParams)
    end

    return graph
end

function Enemy1:GameInit() end

function Enemy1.new(waypoints, spawnWaypoint)
	local janitor = Janitor.new()

	local spawnPosition = spawnWaypoint.Position

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
		Model = enemyModel,
		WaypointFolder = workspace.Waypoints,
		CurrentWaypoint = spawnWaypoint,
		WaypointGraph = GetWaypointGraph(workspace.Waypoints),
		WaypointsLastVisited = {},
		Janitor = Janitor,
	}
end

function Enemy1:GetNextRoamPoint()
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = {self.WaypointFolder}

	local nextWaypoint

	local overlappedWaypoints = workspace:GetPartsInPart(self.Model.WaypointDetector)
	if #overlappedWaypoints == 0 then
		-- pick random waypoint

	end
	
	local currentCharacter = GetCurrentPlayerCharacter()
	if currentCharacter then
		local distance = (currentCharacter.Origin.Position - self.Model.Origin.Position).Magnitude
		
		if distance > RETURN_TO_CHARACTER_DISTANCE then
			
		elseif distance > 
		end

	end

	local currentWaypoint = overlappedWaypoints[1]
	local potentialNextWaypoints = self.WaypointGraph[currentWaypoint]
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
