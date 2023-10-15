local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)
local BehaviorTreeCreator = require(Globals.Vendor.BehaviorTreeCreator)
local SimplePath = require(Globals.Vendor.SimplePath)

local EnemyFolder = Globals.Assets.Enemies.Enemy1
local RoamSearchRange = 25

local Enemy1 = {}

local Random = Random.new()

function Enemy1:GameInit() end

function Enemy1.new(waypoints, spawnPosition)
	local Janitor = Janitor.new()
	local EnemyModel = Janitor:Add(EnemyFolder.Model:Clone())
	EnemyModel.Parent = workspace
	EnemyModel:PivotTo(CFrame.Angles(0, Random:NextNumber(0, 2 * math.pi), 0) + spawnPosition)

	local Path = SimplePath.new(EnemyModel)

	local self = {
		Model = EnemyModel,
		CloseDistance = 15,
		FarDistance = 40,
		Target = nil,
		Path = Path,
		Waypoints = waypoints,
		Janitor = Janitor,
	}

	local Brain = BehaviorTreeCreator:Create(EnemyFolder.Brain.Value, self)
	Janitor:Add(RunService.PostSimulation:Connect(function()
		Brain:run()
		if self.Target then
			Path:Run(self.Target)
		else
			Path:Stop()
		end
	end))

	return self
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

function Enemy1.GetNextRoamPoint(self)
	local overlapParams = OverlapParams.new()
	overlapParams.CollisionGroup = "Waypoint"
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = self.Waypoints

	local nearbyPoints = workspace:GetPartBoundsInBox(
		CFrame.new(self.Model.Origin.Position),
		RoamSearchRange * Vector3.new(1, 1, 1),
		overlapParams
	)

	local player = game.Players:GetChildren()[1]
	if player and player.Character and #nearbyPoints > 0 then
		local characterPosition = player.Character.Origin.Position
		local entityToCharacter = (characterPosition - self.Model.Origin.Position).Unit

		return PickRandomWithWeight(self.Waypoints, function(waypoint)
			local product = (waypoint - characterPosition).Unit:Dot(entityToCharacter)
			return math.max(0, (1 + product) / 2)
		end)
	else
		return self.Waypoints[Random:NextInteger(1, #self.Waypoints)]
	end
end

return Enemy1
