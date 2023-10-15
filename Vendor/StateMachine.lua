local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Signal = require(Globals.Packages.Signal)
local Janitor = require(Globals.Packages.Janitor)

export type StateMachine = {
	currentState: string,
	states: { [any]: any },
	events: { [string]: {} },
}

export type Action = {
	name: string,
	data: { [string]: any },
}

local StateMachine = {}

function StateMachine.new(states, events): StateMachine
	local machineJanitor = Janitor.new()

	return {
		states = states,
		events = events,
		currentState = states._initial,
		transitioned = machineJanitor:Add(Signal.new(), "Disconnect"),

		stateJanitor = machineJanitor:Add(Janitor.new()),
		machineJanitor = machineJanitor,
	}
end

local function hasTransition(currentAncestor: string, enemyName: string): boolean
	-- @TODO: Look up if it has a transition or not, depends on the structure of "events"?
end

-- pass event name and check if event is possible and if it is possible
-- call transition, handle actions
function StateMachine.fireEvent(self: StateMachine, eventName)
    local actions = {}
    
	local currentAncestor = self.currentState
	repeat -- currentAncestor and  do
        for _, action in currentAncestor.actions do
            table.insert(actions, action)
        end
        currentAncestor = currentAncestor.parent
	until not currentAncestor or hasTransition(currentAncestor, eventName)


	if not currentAncestor then
		warn(`{self.currentState} had no ancestors with eventName: {eventName}`)
		return
	end

    local event = self.events[eventName]
    local toState = if typeof(event.to) == "function" then event.to() else 

    
    -- append entered/exited state actions


    -- append event actions
    for _, action in ipairs(event._actions) do
        table.insert(actions, action)
    end

	self.transitioned:Fire(currentState, actions)
    -- StateMachine.transitionTo(self, )

	-- currentAncestor has Transition

	--currentAncestor[eventName] -- do action? transition?
	-- local target = events[stateMachine.currentState][eventName]
end

-- handle state entry/exit actions and event actions
function StateMachine.transitionTo(self: StateMachine, targetState)
	self.stateJanitor:Cleanup()

	-- find transition function between states if it exists?

	-- find start function for new state
end

local function setParents(states)
	local open = { states }

	local cur
	while #open > 0 do
		-- get next in queue
		local oldCur = cur
		cur = table.remove(open, 1)

		-- set current parent
		cur.parent = oldCur

		-- add all children to queue
		for _, tbl in cur do
			if type(tbl) == "table" then
				table.insert(open, tbl)
			end
		end
	end

	return states
end

local states = setParents({
	Pathfinding = {
		Roaming = {},
		["Running to Sound"] = {},

		_initial = "Roaming",
	},
	Flashing = {},
	Attacking = {
		_entryActions = {
			"Teleport Player to Limbo",
		},
	},

	_initial = "Pathfinding",
})

-- local events = {
-- 	{ eventName = "roam", from = "attacking", to = "pathfinding" },
-- }

local events = {
	[States.Pathfinding.Roaming] = {

		["functionRef"] = States.Pathfinding.Attacking,
		[States.Pathfinding.Flashing] = "funcRef",
	},
}

local events = {
	[States.Pathfinding.Roaming] = {
		onStart = function(fsm: StateMachine)
			fsm.stateJanitor:Add(
				fsm.transitioned:Connect(function(eventName)
					if eventName ~= "Player Makes Noise" then
						return
					end

					-- check if player close

					-- warn players
				end),
				"Disconnect"
			)
		end,
	},

	[States.Pathfinding["Running to Sound"]] = {
		["Player Makes Noise"] = {
			_to = function()
				if "Player Nearby" then
				end
			end,
			_actions = {
				"Warn Player",
			},
		},
	},

	[States.Flashing] = {
		Flashed = {
			_to = function()
				return if "Player at Close Range"
					then states.Attacking
					elseif "Player Moving at Medium Range" then states.Attacking
					else states.Pathfinding
			end,
		},
	},

	[States.Attacking] = {},
}

return StateMachine
