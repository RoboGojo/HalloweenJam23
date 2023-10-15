local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)
local BehaviorTreeCreator = require(Globals.Vendor.BehaviorTreeCreator)
local SimplePath = require(Globals.Vendor.SimplePath)

local EnemyFolder = Globals.Assets.Enemies.Enemy1

local Enemy = {}

function Enemy.new()
	local Janitor = Janitor.new()
	local EnemyModel = Janitor:Add(EnemyFolder.Model:Clone())
	EnemyModel.Parent = workspace

	local Path = SimplePath.new(EnemyModel)

	local Blackboard = {
		Model = EnemyModel,
		CloseDistance = 15,
		FarDistance = 40,
		Target = nil,
		Path = Path,
	}

	local Brain = BehaviorTreeCreator:Create(EnemyFolder.Brain.Value, Blackboard)
	Janitor:Add(RunService.PostSimulation:Connect(function()
		Brain:run()
		if Blackboard.Target then
			Path:Run(Blackboard.Target)
		else
			Path:Stop()
		end
	end))

	return {
		Janitor = Janitor,
	}
end

return Enemy
