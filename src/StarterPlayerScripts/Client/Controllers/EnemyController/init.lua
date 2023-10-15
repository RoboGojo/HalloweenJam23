local EnemyController = {}

function EnemyController:GameInit() end

function EnemyController:GameStart() end

function EnemyController:SpawnEnemy(enemyName, spawnPoints)
	local enemyModule = script:FindFirstChild(enemyName)
	if not enemyModule then
		error(`No such enemy ${enemyName}`)
	end

	local enemy = enemyModule.new(enemyName, spawnPoints)

	return enemy
end

return EnemyController
