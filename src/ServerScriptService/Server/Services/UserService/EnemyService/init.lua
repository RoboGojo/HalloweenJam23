local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)

local EnemyService = {}
EnemyService.Enemies = {}

local function InitEnemies()
	for _, enemy in ipairs(script:GetChildren()) do
		if not enemy:IsA("ModuleScript") then
			continue
		end
		EnemyService.Enemies[enemy.Name] = require(enemy)
	end
end

local function InitSpawners()
	for _, spawnPart in ipairs(CollectionService:GetTagged("Spawner")) do
		local enemy = EnemyService.Enemies[spawnPart:GetAttribute("EntityName")]
		print(enemy)
		if enemy then
			table.insert(enemy.Spawns, spawnPart)
		end
	end
end

function EnemyService:SpawnEnemy(enemyName: string, position: Vector3?)
	local enemyModule = self.Enemies[enemyName]
	if not enemyModule then
		error(`No such enemy ${enemyName}`)
	end

	return enemyModule.new(position)
end

function EnemyService:GameInit()
	InitEnemies()
	InitSpawners()
end

function EnemyService:GameStart()
	self:SpawnEnemy("Enemy1")
end

return EnemyService
