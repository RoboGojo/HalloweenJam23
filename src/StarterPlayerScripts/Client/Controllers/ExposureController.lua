local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Globals = require(ReplicatedStorage.Shared.Globals)
local Janitor = require(Globals.Packages.Janitor)

local ExposureFolder = Globals.Assets.LightingStates.Exposure

local exposureOn = false
local transitioning = false

local jan = Janitor.new()

local ExposureController = {}

local function centerCast(params)
	local viewport = workspace.CurrentCamera.ViewportSize / 2
	local ray = workspace.CurrentCamera:ScreenPointToRay(viewport.X, viewport.Y)

	return workspace:Raycast(ray.Origin, ray.Direction * 200, params)
end

function ExposureController:GameInit()
	--Prestart Code
end

local properties = {
	BloomEffect = {
		"Intensity",
		"Size",
		"Threshold",
	},
	ColorCorrectionEffect = {
		"Brightness",
		"Contrast",
		"Saturation",
		"TintColor",
	},
}

local function fadeIn()
	jan:Add(TweenService:Create(Lighting, TweenInfo.new(1), ExposureFolder:GetAttributes()), "Cancel"):Play()
	jan:Add(function()
		task.defer(function()
			jan:Add(TweenService:Create(Lighting, TweenInfo.new(1), { ExposureCompensation = 0 }), "Cancel"):Play()
		end)
	end)

	for _, child in ExposureFolder:GetChildren() do
		local class = child.ClassName
		-- print(class)
		local new = Instance.new(class)
		new.Parent = Lighting

		local goal = {}
		for _, prop in properties[class] do
			goal[prop] = child[prop]
		end

		local g = {}
		for _, prop in properties[class] do
			g[prop] = new[prop]
		end

		jan:Add(TweenService:Create(new, TweenInfo.new(1), goal), "Cancel"):Play()
		jan:Add(function()
			task.defer(function()
				local tween = jan:Add(TweenService:Create(new, TweenInfo.new(1), g), "Cancel")
				tween.Completed:Connect(function()
					new:Destroy()
				end)

				tween:Play()
			end)
		end)
	end
end

local function checkPart()
	RunService.RenderStepped:Connect(function()
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = { Players.LocalPlayer.Character }
		params.CollisionGroup = "Default"

		local rcr = centerCast(params)
		if not rcr then
			return
		end

		if not CollectionService:HasTag(rcr.Instance, "ExposurePart") then
			if exposureOn then
				exposureOn = false
				jan:Cleanup()
			end
			return
		end

		-- print(rcr.Instance)
		if exposureOn then
			return
		end

		exposureOn = true
		jan:Cleanup()
		fadeIn()
	end)
end

function ExposureController:GameStart()
	--Start Code
	checkPart()
end

return ExposureController
