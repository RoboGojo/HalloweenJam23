return function(root)
	local open = {}

	local required = {}
	for _, child in ipairs(root:GetChildren()) do
		table.insert(open, { child, required })
	end

	while #open > 0 do
		local lastOpen = open
		open = {}

		for _, tuple in ipairs(lastOpen) do
			local descendant, parentTable = table.unpack(tuple)
			if descendant:IsA("ModuleScript") then
				parentTable[descendant.Name] = require(descendant)
			elseif descendant:IsA("Folder") then
				local newParentTable = {}
				parentTable[descendant.Name] = newParentTable
				for _, child in ipairs(descendant:GetChildren()) do
					table.insert(open, { child, newParentTable })
				end
			end
		end
	end

	return required
end
