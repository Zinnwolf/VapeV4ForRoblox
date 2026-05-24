local players = game:GetService('Players')

local ownerUserIds = {
	[9404340455] = true
}

local privateUserIds = {
}

local tagSettings = {
	owner = {
		name = 'VapeOwnerTag',
		text = 'VAPE OWNER',
		color = Color3.fromRGB(120, 0, 0),
		stroke = Color3.fromRGB(0, 0, 0)
	},
	private = {
		name = 'VapePrivateTag',
		text = 'VAPE PRIVATE',
		color = Color3.fromRGB(150, 35, 255),
		stroke = Color3.fromRGB(45, 0, 75)
	}
}

local started = false

local function getRole(player)
	if not player then
		return nil
	end

	if ownerUserIds[player.UserId] then
		return 'owner'
	end

	if privateUserIds[player.UserId] then
		return 'private'
	end

	return nil
end

local function removeOldTags(character)
	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA('BillboardGui') and (object.Name == tagSettings.owner.name or object.Name == tagSettings.private.name) then
			object:Destroy()
		end
	end
end

local function createTag(player, character)
	if not player or not character then
		return
	end

	local role = getRole(player)
	removeOldTags(character)

	if not role then
		return
	end

	local head = character:FindFirstChild('Head')
	if not head then
		head = character:WaitForChild('Head', 10)
	end

	if not head then
		return
	end

	local setting = tagSettings[role]

	local billboard = Instance.new('BillboardGui')
	billboard.Name = setting.name
	billboard.Size = UDim2.fromOffset(112, 19)
	billboard.StudsOffset = Vector3.new(0, 2.35, 0)
	billboard.AlwaysOnTop = true
	billboard.Adornee = head
	billboard.Parent = head

	local text = Instance.new('TextLabel')
	text.Name = 'Text'
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = setting.text
	text.TextColor3 = setting.color
	text.TextStrokeColor3 = setting.stroke
	text.TextStrokeTransparency = 0.25
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.Parent = billboard
end

local function hookPlayer(player)
	if not player then
		return
	end

	player.CharacterAdded:Connect(function(character)
		task.wait(0.35)
		createTag(player, character)
	end)

	if player.Character then
		task.spawn(function()
			createTag(player, player.Character)
		end)
	end
end

local function start()
	if started then
		return
	end

	started = true

	for _, player in ipairs(players:GetPlayers()) do
		hookPlayer(player)
	end

	players.PlayerAdded:Connect(hookPlayer)
end

start()

return {
	Start = start,
	OwnerUserIds = ownerUserIds,
	PrivateUserIds = privateUserIds
}
