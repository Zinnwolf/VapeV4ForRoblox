local oldloadstring = loadstring
local vape

local loadstring = function(...)
	local res, err = oldloadstring(...)
	if err and vape and vape.CreateNotification then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/Trxiste/VapeV4ForRoblox/main/'..select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function run(func)
	local suc, err = pcall(func)
	if not suc then
		warn('[universal.lua] '..tostring(err))
		if vape and vape.CreateNotification then
			vape:CreateNotification('Vape', tostring(err), 8, 'alert')
		end
	end
end

local queue_on_teleport = queue_on_teleport or function() end
local cloneref = cloneref or function(obj)
	return obj
end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local runService = cloneref(game:GetService('RunService'))
local inputService = cloneref(game:GetService('UserInputService'))
local tweenService = cloneref(game:GetService('TweenService'))
local lightingService = cloneref(game:GetService('Lighting'))
local marketplaceService = cloneref(game:GetService('MarketplaceService'))
local teleportService = cloneref(game:GetService('TeleportService'))
local httpService = cloneref(game:GetService('HttpService'))
local guiService = cloneref(game:GetService('GuiService'))
local groupService = cloneref(game:GetService('GroupService'))
local textChatService = cloneref(game:GetService('TextChatService'))
local contextService = cloneref(game:GetService('ContextActionService'))
local collectionService = cloneref(game:GetService('CollectionService'))
local debrisService = cloneref(game:GetService('Debris'))
local starterGui = cloneref(game:GetService('StarterGui'))
local coreGui = cloneref(game:GetService('CoreGui'))

local gameCamera = workspace.CurrentCamera or workspace:FindFirstChildWhichIsA('Camera')
local lplr = playersService.LocalPlayer
local assetfunction = getcustomasset

vape = shared.vape

if not vape then
	error('shared.vape is nil. Load new.lua / main UI before universal.lua.')
end

vape.Libraries = vape.Libraries or {}
vape.Categories = vape.Categories or {}

local universal = vape.Libraries.universal or {}
vape.Libraries.universal = universal

universal.Version = 'pieced-football-1.0.0'
universal.Started = universal.Started or os.clock()
universal.Ready = false
universal.Services = universal.Services or {}
universal.Modules = universal.Modules or {}
universal.Cache = universal.Cache or {}

universal.Services.Players = playersService
universal.Services.ReplicatedStorage = replicatedStorage
universal.Services.RunService = runService
universal.Services.UserInputService = inputService
universal.Services.TweenService = tweenService
universal.Services.Lighting = lightingService
universal.Services.MarketplaceService = marketplaceService
universal.Services.TeleportService = teleportService
universal.Services.HttpService = httpService
universal.Services.GuiService = guiService
universal.Services.GroupService = groupService
universal.Services.TextChatService = textChatService
universal.Services.ContextActionService = contextService
universal.Services.CollectionService = collectionService
universal.Services.Debris = debrisService
universal.Services.CoreGui = coreGui
universal.Services.Workspace = workspace

local function notify(title, text, duration, icon)
	if vape and vape.CreateNotification then
		vape:CreateNotification(title or 'Pieced', tostring(text or ''), duration or 3, icon)
	end
end

local function removeTags(str)
	str = tostring(str or '')
	str = str:gsub('<br%s*/>', '\n')
	return str:gsub('<[^<>]->', '')
end

local function safeCategory(name)
	return vape.Categories[name] or vape.Categories.Utility or vape.Categories.Render or vape.Categories.Blatant or vape.Categories.Combat or vape.Categories.World
end

universal.Notify = notify
universal.RemoveTags = removeTags

local maid = {}
maid.__index = maid

function maid.new()
	return setmetatable({
		Tasks = {},
		Alive = true
	}, maid)
end

function maid:Give(task)
	if not task then return task end
	if not self.Alive then
		pcall(function()
			if typeof(task) == 'RBXScriptConnection' then
				task:Disconnect()
			elseif typeof(task) == 'Instance' then
				task:Destroy()
			elseif type(task) == 'function' then
				task()
			elseif type(task) == 'table' then
				if type(task.Disconnect) == 'function' then
					task:Disconnect()
				elseif type(task.Destroy) == 'function' then
					task:Destroy()
				elseif type(task.Clean) == 'function' then
					task:Clean()
				end
			end
		end)
		return task
	end
	table.insert(self.Tasks, task)
	return task
end

function maid:Clean()
	for i = #self.Tasks, 1, -1 do
		local task = self.Tasks[i]
		self.Tasks[i] = nil
		pcall(function()
			if typeof(task) == 'RBXScriptConnection' then
				task:Disconnect()
			elseif typeof(task) == 'Instance' then
				task:Destroy()
			elseif type(task) == 'function' then
				task()
			elseif type(task) == 'table' then
				if type(task.Disconnect) == 'function' then
					task:Disconnect()
				elseif type(task.Destroy) == 'function' then
					task:Destroy()
				elseif type(task.Clean) == 'function' then
					task:Clean()
				end
			end
		end)
	end
end

function maid:Destroy()
	self:Clean()
	self.Alive = false
end

universal.Maid = maid

local function selftoggle(module)
	task.delay(0.05, function()
		if module and module.Enabled then
			module:Toggle()
		end
	end)
end

run(function()
	local cons = {}
	local drawings = {}
	local saved = {}

	local backpack = lplr:WaitForChild('Backpack')
	local playergui = lplr:WaitForChild('PlayerGui')
	local fe = workspace:FindFirstChild('FE') or replicatedStorage:FindFirstChild('FE')
	local rfe = replicatedStorage:FindFirstChild('FE') or workspace:FindFirstChild('FE')

	local settings = {
		range = 7,
		delay = 0.08,
		power = 85,
		curve = 0,
		angle = Vector3.new(4000000, 700, 4000000),
		method = 'Shoot'
	}

	local function cat(name)
		local category = safeCategory(name)
		if not category then
			error('missing vape category '..tostring(name))
		end
		return category
	end

	local function disconnect(name)
		if cons[name] then
			cons[name]:Disconnect()
			cons[name] = nil
		end
	end

	local function removedraw(name)
		if drawings[name] then
			pcall(function()
				drawings[name]:Remove()
			end)
			drawings[name] = nil
		end
	end

	local function char()
		local c = lplr.Character
		return c, c and c:FindFirstChildOfClass('Humanoid'), c and (c:FindFirstChild('HumanoidRootPart') or c:FindFirstChild('Torso'))
	end

	local function path(root, ...)
		local obj = root
		local args = {...}
		for _, name in ipairs(args) do
			obj = obj and obj:FindFirstChild(name)
		end
		return obj
	end

	local function fire(obj, ...)
		if obj and obj.FireServer then
			pcall(function()
				obj:FireServer(...)
			end)
		end
	end

	local function saveprop(obj, props)
		if not obj then return end
		saved[obj] = saved[obj] or {}
		for _, prop in ipairs(props) do
			if saved[obj][prop] == nil then
				pcall(function()
					saved[obj][prop] = obj[prop]
				end)
			end
		end
	end

	local function restoreobj(obj)
		local data = saved[obj]
		if not data or not obj or not obj.Parent then return end
		for prop, value in pairs(data) do
			pcall(function()
				obj[prop] = value
			end)
		end
	end

	local function restoreall()
		for obj in pairs(saved) do
			restoreobj(obj)
		end
	end

	local function isball(obj)
		if not obj or not obj:IsA('BasePart') then return false end
		local n = obj.Name
		return n == 'TPS' or n == 'PSoccerBall' or n == 'Ball' or n == 'Football' or n:lower():find('ball') ~= nil
	end

	local function balls()
		local found = {}
		local function scan(root)
			if root then
				for _, obj in ipairs(root:GetDescendants()) do
					if isball(obj) then
						table.insert(found, obj)
					end
				end
			end
		end

		scan(workspace:FindFirstChild('TPSSystem'))
		scan(workspace:FindFirstChild('Temp'))

		for _, obj in ipairs(workspace:GetChildren()) do
			if isball(obj) then
				table.insert(found, obj)
			end
		end

		return found
	end

	local function nearest(pos, maxrange)
		local best, dist
		for _, b in ipairs(balls()) do
			local mag = (b.Position - pos).Magnitude
			if mag <= maxrange and (not dist or mag < dist) then
				best = b
				dist = mag
			end
		end
		return best, dist
	end

	local function scorer(b)
		fire(path(fe, 'Scorer', 'RemoteEvent'), b)
		fire(path(fe, 'Scorer', 'RemoteEvent1'), b)
	end

	local function worn()
		fire(path(fe, 'Worn', 'Sweat'))
		fire(path(fe, 'Worn', 'WornPlayer'))
		fire(path(fe, 'Worn', 'WornFall'))
	end

	local function sprint(state)
		local c = lplr.Character
		local sc = c and c:FindFirstChild('StaminaClient')
		if sc and sc:FindFirstChild('RunActive') then
			sc.RunActive.Value = state == 'Began'
		end
		fire(path(rfe, 'Sprint'), state)
	end

	local function touch(b, method)
		local c, hum, root = char()
		if not c or not root or not b then return end

		local rl = c:FindFirstChild('Right Leg') or c:FindFirstChild('RightFoot') or root
		local ll = c:FindFirstChild('Left Leg') or c:FindFirstChild('LeftFoot') or root
		local head = c:FindFirstChild('Head') or root
		local torso = c:FindFirstChild('Torso') or c:FindFirstChild('UpperTorso') or root

		if method == 'Shoot' then
			scorer(b)
			sprint('Ended')
			fire(path(fe, 'Shoot', 'Shoot'), b, rl, root, settings.curve, settings.power, settings.angle, CFrame.new(), CFrame.new(), 3)
		elseif method == 'ShootL' then
			scorer(b)
			sprint('Ended')
			fire(path(fe, 'Shoot', 'ShootL'), b, ll, root, settings.curve, settings.power, settings.angle, CFrame.new(), CFrame.new(), 3)
		elseif method == 'Dribble' then
			scorer(b)
			fire(path(fe, 'Dribble', 'Dribble'), b, rl)
		elseif method == 'FastDribble' then
			scorer(b)
			fire(path(fe, 'Dribble', 'FastDribble'), b, rl)
		elseif method == 'Tackle' then
			scorer(b)
			fire(path(fe, 'Tackle', 'Tackle'), b, rl)
		elseif method == 'TackleL' then
			scorer(b)
			fire(path(fe, 'Tackle', 'TackleL'), b, ll)
		elseif method == 'Chest' then
			worn()
			scorer(b)
			fire(path(fe, 'Dribble', 'ChestControl'), b, torso)
		elseif method == 'Header' then
			scorer(b)
			fire(path(fe, 'Shoot', 'Header'), b, head)
		elseif method == 'GK' then
			scorer(b)
			fire(path(fe, 'GK', 'Punch'), b, root.CFrame.LookVector)
			fire(path(fe, 'GK', 'Save1'), b, root.CFrame.LookVector)
		elseif method == 'Clear' then
			scorer(b)
			fire(path(fe, 'GK', 'Clear'), b, rl, root.CFrame.LookVector, settings.power, settings.angle)
		end
	end

	local function startreact(name, method, range, delay)
		disconnect(name)
		local last = 0
		cons[name] = runService.Heartbeat:Connect(function()
			if os.clock() - last < delay then return end
			local _, _, root = char()
			if not root then return end
			local b = nearest(root.Position, range)
			if b then
				last = os.clock()
				touch(b, method)
			end
		end)
	end

	local function makereact(name, method, range, delay)
		cat('Utility'):CreateModule({
			Name = name,
			Function = function(callback)
				if callback then
					startreact(name, method, range or settings.range, delay or settings.delay)
					notify(name, 'Enabled.', 2)
				else
					disconnect(name)
					notify(name, 'Disabled.', 2)
				end
			end,
			Tooltip = 'Automatic ball reaction module.'
		})
	end

	local function scaled(size, scale)
		return Vector3.new(size.X * scale.X, size.Y * scale.Y, size.Z * scale.Z)
	end

	local function setbody(scale, arms, legs)
		local c = lplr.Character
		if not c then return end

		local list = {}
		if arms then
			table.insert(list, 'Left Arm')
			table.insert(list, 'Right Arm')
		end
		if legs then
			table.insert(list, 'Left Leg')
			table.insert(list, 'Right Leg')
		end

		for _, name in ipairs(list) do
			local part = c:FindFirstChild(name)
			if part and part:IsA('BasePart') then
				saveprop(part, {'Size', 'Transparency'})
				part.Size = scaled(saved[part].Size, scale)
				part.Transparency = 0
			end
		end
	end

	makereact('FireTouch', 'Shoot', 7, 0.08)
	makereact('FireTouch GK', 'GK', 9, 0.08)
	makereact('FireTouch Chest', 'Chest', 7, 0.08)
	makereact('Comp Reach', 'Shoot', 10, 0.06)
	makereact('Shoot Q Reach', 'Shoot', 12, 0.08)
	makereact('Dribble X Reach', 'Dribble', 10, 0.08)
	makereact('Tackle X Reach', 'Tackle', 11, 0.08)
	makereact('The Main React', 'Shoot', 9, 0.055)
	makereact('React Kill', 'Shoot', 13, 0.045)
	makereact('Strelinho React', 'FastDribble', 8, 0.05)
	makereact('No React Decline', 'Shoot', 8, 0.04)
	makereact('EmreMorTPS React', 'Dribble', 9, 0.055)
	makereact('Prztxl React', 'ShootL', 9, 0.055)
	makereact('Mars React', 'Header', 8, 0.06)
	makereact('Sourenos React', 'Tackle', 8, 0.055)
	makereact('Ionma React', 'Chest', 8, 0.055)
	makereact('Universal Methods #1', 'Shoot', 8, 0.075)
	makereact('Universal Methods #2', 'Dribble', 8, 0.075)
	makereact('Universal Methods #3', 'Tackle', 8, 0.075)
	makereact('Defence React', 'Tackle', 12, 0.05)
	makereact('Dribble React', 'Dribble', 10, 0.05)

	cat('Render'):CreateModule({
		Name = 'Touch Count',
		Function = function(callback)
			disconnect('Touch Count')
			if callback then
				local count = 0
				cons['Touch Count'] = runService.Heartbeat:Connect(function()
					local _, _, root = char()
					if not root then return end
					local b = nearest(root.Position, 5)
					if b and not b:GetAttribute('TouchCounted') then
						b:SetAttribute('TouchCounted', true)
						count = count + 1
						notify('Touch Count', tostring(count), 2)
						task.delay(0.35, function()
							if b then
								b:SetAttribute('TouchCounted', nil)
							end
						end)
					end
				end)
			end
		end,
		Tooltip = 'Counts nearby ball contacts.'
	})

	local skillsettings
	skillsettings = cat('Utility'):CreateModule({
		Name = 'Skill Settings',
		Function = function(callback)
			if callback then
				notify('Skill Settings', 'Applied.', 2)
				selftoggle(skillsettings)
			end
		end,
		Tooltip = 'Global settings for react modules.'
	})

	skillsettings:CreateDropdown({
		Name = 'Method',
		List = {'Shoot', 'ShootL', 'Dribble', 'FastDribble', 'Tackle', 'TackleL', 'Chest', 'Header', 'GK', 'Clear'},
		Default = 'Shoot',
		Function = function(v)
			settings.method = v
		end
	})

	skillsettings:CreateSlider({
		Name = 'Range',
		Min = 3,
		Max = 25,
		Default = 7,
		Function = function(v)
			settings.range = v
		end
	})

	skillsettings:CreateSlider({
		Name = 'Delay',
		Min = 0,
		Max = 300,
		Default = 80,
		Function = function(v)
			settings.delay = v / 1000
		end
	})

	skillsettings:CreateSlider({
		Name = 'Power',
		Min = 20,
		Max = 180,
		Default = 85,
		Function = function(v)
			settings.power = v
		end
	})

	cat('Utility'):CreateModule({
		Name = 'FireTouch Modules',
		Function = function(callback)
			disconnect('FireTouch Modules')
			if callback then
				startreact('FireTouch Modules', settings.method, settings.range, settings.delay)
				notify('FireTouch Modules', 'Enabled.', 2)
			else
				notify('FireTouch Modules', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Uses selected Skill Settings method.'
	})

	local delaypresets, delaypreset
	delaypresets = cat('Utility'):CreateModule({
		Name = 'Delay Presets',
		Function = function(callback)
			if callback then
				local preset = delaypreset and delaypreset.Value or 'Balanced'
				if preset == 'Legit' then
					settings.delay = 0.16
					settings.range = 6
				elseif preset == 'Balanced' then
					settings.delay = 0.08
					settings.range = 8
				elseif preset == 'Fast' then
					settings.delay = 0.035
					settings.range = 12
				else
					settings.delay = 0.015
					settings.range = 15
				end
				notify('Delay Presets', preset, 2)
				selftoggle(delaypresets)
			end
		end,
		Tooltip = 'Applies react delay presets.'
	})

	delaypreset = delaypresets:CreateDropdown({
		Name = 'Preset',
		List = {'Legit', 'Balanced', 'Fast', 'Extreme'},
		Default = 'Balanced',
		Function = function() end
	})

	cat('Utility'):CreateModule({
		Name = 'Delay Reducer',
		Function = function(callback)
			for _, v in ipairs(backpack:GetDescendants()) do
				if v:IsA('NumberValue') and (v.Name:lower():find('delay') or v.Name:lower():find('cooldown') or v.Name:lower():find('wait')) then
					if callback then
						saveprop(v, {'Value'})
						v.Value = 0
					else
						restoreobj(v)
					end
				elseif v:IsA('BoolValue') and (v.Name:lower():find('wait') or v.Name:lower():find('cooldown')) then
					if callback then
						saveprop(v, {'Value'})
						v.Value = false
					else
						restoreobj(v)
					end
				end
			end
		end,
		Tooltip = 'Reduces local tool delays.'
	})

	cat('Utility'):CreateModule({
		Name = 'No Tool Cooldown',
		Function = function(callback)
			disconnect('No Tool Cooldown')
			if callback then
				cons['No Tool Cooldown'] = runService.Heartbeat:Connect(function()
					if playergui:FindFirstChild('Activate') then
						playergui.Activate.Value = true
					end
					if playergui:FindFirstChild('ToolSelect') then
						playergui.ToolSelect.Value = true
					end
					for _, v in ipairs(backpack:GetDescendants()) do
						if v:IsA('BoolValue') and (v.Name == 'Wait' or v.Name == 'TackleWait' or v.Name:lower():find('cooldown')) then
							v.Value = false
						end
					end
				end)
			end
		end,
		Tooltip = 'Keeps local tools available.'
	})

	cat('Utility'):CreateModule({
		Name = 'No Shot Charge',
		Function = function(callback)
			disconnect('No Shot Charge')
			if callback then
				cons['No Shot Charge'] = runService.Heartbeat:Connect(function()
					for _, obj in ipairs(backpack:GetDescendants()) do
						if obj:IsA('NumberValue') then
							if obj.Name == 'Speed' then
								obj.Value = settings.power
							elseif obj.Name == 'Curve' then
								obj.Value = settings.curve
							end
						elseif obj:IsA('Vector3Value') and obj.Name == 'Angle' then
							obj.Value = settings.angle
						end
					end
				end)
			end
		end,
		Tooltip = 'Keeps shot values charged.'
	})

	cat('Utility'):CreateModule({
		Name = 'Shoot/Power Boosts',
		Function = function(callback)
			if callback then
				settings.power = 130
				settings.angle = Vector3.new(4000000, 1200, 4000000)
				notify('Shoot/Power Boosts', 'Boosted.', 2)
			else
				settings.power = 85
				settings.angle = Vector3.new(4000000, 700, 4000000)
			end
		end,
		Tooltip = 'Boosts shot power values.'
	})

	cat('Utility'):CreateModule({
		Name = 'Unlimited Stamina',
		Function = function(callback)
			disconnect('Unlimited Stamina')
			if callback then
				cons['Unlimited Stamina'] = runService.Heartbeat:Connect(function()
					local c = lplr.Character
					if lplr:FindFirstChild('Stamina') then
						lplr.Stamina.Value = 9700
					end
					if c and c:FindFirstChild('Stamina') then
						c.Stamina.Value = 9700
					end
					local sc = c and c:FindFirstChild('StaminaClient')
					if sc and sc:FindFirstChild('Stamina') then
						sc.Stamina.Value = 9700
					end
				end)
			end
		end,
		Tooltip = 'Keeps local stamina full.'
	})

	cat('Utility'):CreateModule({
		Name = 'Auto Defence',
		Function = function(callback)
			disconnect('Auto Defence')
			if callback then
				local last = 0
				cons['Auto Defence'] = runService.Heartbeat:Connect(function()
					if os.clock() - last < 0.12 then return end
					local _, _, root = char()
					if not root then return end
					local b = nearest(root.Position, 14)
					if b then
						last = os.clock()
						touch(b, 'Tackle')
					end
				end)
			end
		end,
		Tooltip = 'Auto tackles nearby ball.'
	})

	local unreach
	unreach = cat('Utility'):CreateModule({
		Name = 'Unreach',
		Function = function(callback)
			if callback then
				for name, con in pairs(cons) do
					if name:find('React') or name:find('Reach') or name:find('FireTouch') then
						con:Disconnect()
						cons[name] = nil
					end
				end
				for _, b in ipairs(balls()) do
					restoreobj(b)
				end
				notify('Unreach', 'Reach cleared.', 2)
				selftoggle(unreach)
			end
		end,
		Tooltip = 'Turns off reach/react modules.'
	})

	local ballsizevalue
	local ballsize = cat('World'):CreateModule({
		Name = 'Ball Size',
		Function = function(callback)
			disconnect('Ball Size')
			if callback then
				cons['Ball Size'] = runService.Heartbeat:Connect(function()
					for _, b in ipairs(balls()) do
						saveprop(b, {'Size'})
						b.Size = Vector3.new(ballsizevalue.Value, ballsizevalue.Value, ballsizevalue.Value)
					end
				end)
			else
				for _, b in ipairs(balls()) do
					restoreobj(b)
				end
			end
		end,
		Tooltip = 'Changes local ball size.'
	})

	ballsizevalue = ballsize:CreateSlider({
		Name = 'Size',
		Min = 1,
		Max = 15,
		Default = 5,
		Function = function() end
	})

	local ballvisiblevalue
	local ballvisibility = cat('Render'):CreateModule({
		Name = 'Ball Visibility',
		Function = function(callback)
			disconnect('Ball Visibility')
			if callback then
				cons['Ball Visibility'] = runService.RenderStepped:Connect(function()
					for _, b in ipairs(balls()) do
						b.LocalTransparencyModifier = 1 - (ballvisiblevalue.Value / 100)
					end
				end)
			else
				for _, b in ipairs(balls()) do
					b.LocalTransparencyModifier = 0
				end
			end
		end,
		Tooltip = 'Changes ball transparency.'
	})

	ballvisiblevalue = ballvisibility:CreateSlider({
		Name = 'Visible',
		Min = 0,
		Max = 100,
		Default = 100,
		Function = function() end
	})

	local balltexturemode
	local balltextures = cat('Render'):CreateModule({
		Name = 'Ball Textures',
		Function = function(callback)
			disconnect('Ball Textures')
			if callback then
				cons['Ball Textures'] = runService.RenderStepped:Connect(function()
					for _, b in ipairs(balls()) do
						saveprop(b, {'Color', 'Material'})
						local mode = balltexturemode.Value
						if mode == 'Neon' then
							b.Material = Enum.Material.Neon
							b.Color = Color3.fromRGB(255, 255, 255)
						elseif mode == 'Black' then
							b.Material = Enum.Material.SmoothPlastic
							b.Color = Color3.fromRGB(0, 0, 0)
						elseif mode == 'Red' then
							b.Material = Enum.Material.Neon
							b.Color = Color3.fromRGB(255, 50, 50)
						elseif mode == 'Blue' then
							b.Material = Enum.Material.Neon
							b.Color = Color3.fromRGB(50, 120, 255)
						end
					end
				end)
			else
				for _, b in ipairs(balls()) do
					restoreobj(b)
				end
			end
		end,
		Tooltip = 'Changes local ball texture.'
	})

	balltexturemode = balltextures:CreateDropdown({
		Name = 'Texture',
		List = {'Neon', 'Black', 'Red', 'Blue'},
		Default = 'Neon',
		Function = function() end
	})

	cat('Render'):CreateModule({
		Name = 'Range Visualizer',
		Function = function(callback)
			disconnect('Range Visualizer')
			removedraw('Range Visualizer')
			if callback and Drawing then
				drawings['Range Visualizer'] = Drawing.new('Circle')
				drawings['Range Visualizer'].Thickness = 1
				drawings['Range Visualizer'].NumSides = 96
				drawings['Range Visualizer'].Filled = false
				drawings['Range Visualizer'].Transparency = 0.85
				cons['Range Visualizer'] = runService.RenderStepped:Connect(function()
					local cam = workspace.CurrentCamera
					local _, _, root = char()
					if not cam or not root then return end
					local pos, on = cam:WorldToViewportPoint(root.Position)
					drawings['Range Visualizer'].Visible = on
					if on then
						drawings['Range Visualizer'].Position = Vector2.new(pos.X, pos.Y)
						drawings['Range Visualizer'].Radius = settings.range * 7
					end
				end)
			end
		end,
		Tooltip = 'Draws current react range.'
	})

	local fovvalue
	local fov = cat('Render'):CreateModule({
		Name = 'Field of View',
		Function = function(callback)
			disconnect('Field of View')
			local cam = workspace.CurrentCamera
			if callback then
				if cam then
					saveprop(cam, {'FieldOfView'})
				end
				cons['Field of View'] = runService.RenderStepped:Connect(function()
					if workspace.CurrentCamera then
						workspace.CurrentCamera.FieldOfView = fovvalue.Value
					end
				end)
			else
				if cam then
					restoreobj(cam)
				end
			end
		end,
		Tooltip = 'Custom camera FOV.'
	})

	fovvalue = fov:CreateSlider({
		Name = 'FOV',
		Min = 40,
		Max = 120,
		Default = 80,
		Function = function() end
	})

	cat('Render'):CreateModule({
		Name = 'Mute Crowd',
		Function = function(callback)
			for _, s in ipairs(workspace:GetDescendants()) do
				if s:IsA('Sound') and (s.Name:lower():find('crowd') or (s.Parent and s.Parent.Name:lower():find('crowd'))) then
					if callback then
						saveprop(s, {'Volume'})
						s.Volume = 0
					else
						restoreobj(s)
					end
				end
			end
		end,
		Tooltip = 'Mutes crowd sounds.'
	})

	cat('Render'):CreateModule({
		Name = 'Goal Music',
		Function = function(callback)
			for _, s in ipairs(workspace:GetDescendants()) do
				if s:IsA('Sound') and s.Name:lower():find('goal') then
					if callback then
						saveprop(s, {'Volume'})
						s.Volume = 5
					else
						restoreobj(s)
					end
				end
			end
		end,
		Tooltip = 'Boosts goal music.'
	})

	cat('Render'):CreateModule({
		Name = 'Transparent Goal Nets',
		Function = function(callback)
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA('BasePart') and v.Name:lower():find('net') then
					if callback then
						saveprop(v, {'Transparency'})
						v.Transparency = 0.8
					else
						restoreobj(v)
					end
				end
			end
		end,
		Tooltip = 'Makes goal nets transparent.'
	})

	local skyboxmode
	local skyboxchanger = cat('Render'):CreateModule({
		Name = 'Skybox Changer',
		Function = function(callback)
			local sky = lightingService:FindFirstChildOfClass('Sky') or Instance.new('Sky')
			sky.Parent = lightingService
			if callback then
				saveprop(sky, {'SkyboxBk', 'SkyboxDn', 'SkyboxFt', 'SkyboxLf', 'SkyboxRt', 'SkyboxUp'})
				local id = skyboxmode.Value == 'Space' and 'rbxassetid://159454299' or 'rbxassetid://150182466'
				sky.SkyboxBk = id
				sky.SkyboxDn = id
				sky.SkyboxFt = id
				sky.SkyboxLf = id
				sky.SkyboxRt = id
				sky.SkyboxUp = id
			else
				restoreobj(sky)
			end
		end,
		Tooltip = 'Changes local skybox.'
	})

	skyboxmode = skyboxchanger:CreateDropdown({
		Name = 'Skybox',
		List = {'Space', 'Blue'},
		Default = 'Space',
		Function = function() end
	})

	cat('Utility'):CreateModule({
		Name = 'Console Hider',
		Function = function(callback)
			local dev = playergui:FindFirstChild('DevConsoleMaster')
			if dev then
				dev.Enabled = not callback
			end
			pcall(function()
				starterGui:SetCore('DevConsoleVisible', not callback)
			end)
		end,
		Tooltip = 'Hides visible console UI.'
	})

	local rejoin
	rejoin = cat('Utility'):CreateModule({
		Name = 'Rejoin Game',
		Function = function(callback)
			if callback then
				teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lplr)
				selftoggle(rejoin)
			end
		end,
		Tooltip = 'Rejoins current server.'
	})

	cat('Utility'):CreateModule({
		Name = 'Replace Both Arms',
		Function = function(callback)
			if callback then
				setbody(Vector3.new(1.15, 1.15, 1.15), true, false)
			else
				restoreall()
			end
		end,
		Tooltip = 'Locally enlarges both arms.'
	})

	cat('Utility'):CreateModule({
		Name = 'Replace Both Legs',
		Function = function(callback)
			if callback then
				setbody(Vector3.new(1, 1.2, 1), false, true)
			else
				restoreall()
			end
		end,
		Tooltip = 'Locally enlarges both legs.'
	})

	cat('Utility'):CreateModule({
		Name = 'Blocky Body',
		Function = function(callback)
			if callback then
				setbody(Vector3.new(1.25, 1.05, 1.25), true, true)
			else
				restoreall()
			end
		end,
		Tooltip = 'Makes body locally blockier.'
	})

	local revertbody
	revertbody = cat('Utility'):CreateModule({
		Name = 'Revert to Original Body',
		Function = function(callback)
			if callback then
				restoreall()
				selftoggle(revertbody)
			end
		end,
		Tooltip = 'Restores saved body sizes.'
	})

	cat('Render'):CreateModule({
		Name = 'Stretched Resolution',
		Function = function(callback)
			disconnect('Stretched Resolution')
			if callback then
				cons['Stretched Resolution'] = runService.RenderStepped:Connect(function()
					if workspace.CurrentCamera then
						workspace.CurrentCamera.FieldOfView = 95
					end
				end)
			end
		end,
		Tooltip = 'Simulates stretched resolution.'
	})

	cat('Utility'):CreateModule({
		Name = 'Clumsy',
		Function = function(callback)
			disconnect('Clumsy')
			if callback then
				cons.Clumsy = runService.Heartbeat:Connect(function()
					local _, hum, root = char()
					if hum and root then
						hum.PlatformStand = math.random(1, 80) == 1
						root.AssemblyAngularVelocity = root.AssemblyAngularVelocity + Vector3.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
					end
				end)
			else
				local _, hum = char()
				if hum then
					hum.PlatformStand = false
				end
			end
		end,
		Tooltip = 'Adds random clumsy movement.'
	})

	cat('Render'):CreateModule({
		Name = 'Disguise',
		Function = function(callback)
			local c = lplr.Character
			if not c then return end
			for _, v in ipairs(c:GetDescendants()) do
				if v:IsA('BasePart') then
					if callback then
						saveprop(v, {'Color'})
						v.Color = Color3.fromRGB(80, 80, 80)
					else
						restoreobj(v)
					end
				elseif v:IsA('Decal') then
					if callback then
						saveprop(v, {'Transparency'})
						v.Transparency = 1
					else
						restoreobj(v)
					end
				end
			end
		end,
		Tooltip = 'Applies a simple local disguise.'
	})

	cat('Render'):CreateModule({
		Name = 'Ball ESP',
		Function = function(callback)
			disconnect('Ball ESP')
			removedraw('BallESPLine')
			removedraw('BallESPCircle')
			if callback and Drawing then
				drawings.BallESPLine = Drawing.new('Line')
				drawings.BallESPLine.Thickness = 1
				drawings.BallESPLine.Transparency = 0.85

				drawings.BallESPCircle = Drawing.new('Circle')
				drawings.BallESPCircle.Thickness = 1
				drawings.BallESPCircle.NumSides = 48
				drawings.BallESPCircle.Filled = false
				drawings.BallESPCircle.Transparency = 0.85

				cons['Ball ESP'] = runService.RenderStepped:Connect(function()
					local cam = workspace.CurrentCamera
					local _, _, root = char()
					if not cam or not root then return end
					local b = nearest(root.Position, 1500)
					if not b then
						drawings.BallESPLine.Visible = false
						drawings.BallESPCircle.Visible = false
						return
					end
					local pos, on = cam:WorldToViewportPoint(b.Position)
					if not on then
						drawings.BallESPLine.Visible = false
						drawings.BallESPCircle.Visible = false
						return
					end
					local center = cam.ViewportSize * 0.5
					local screen = Vector2.new(pos.X, pos.Y)
					drawings.BallESPLine.From = Vector2.new(center.X, center.Y)
					drawings.BallESPLine.To = screen
					drawings.BallESPLine.Visible = true
					drawings.BallESPCircle.Position = screen
					drawings.BallESPCircle.Radius = math.clamp(1800 / math.max(pos.Z, 1), 5, 35)
					drawings.BallESPCircle.Visible = true
				end)
			end
		end,
		Tooltip = 'Draws line and circle on ball.'
	})

	if vape.Clean then
		vape:Clean(function()
			for _, con in pairs(cons) do
				pcall(function()
					con:Disconnect()
				end)
			end
			for _, obj in pairs(drawings) do
				pcall(function()
					obj:Remove()
				end)
			end
			restoreall()
		end)
	end

	notify('Pieced', 'Custom football modules loaded.', 5, 'warning')
end)

universal.Ready = true

if vape and vape.CreateNotification then
	vape:CreateNotification('Welcome Pieced', 'VAPE PRIVATE Loaded!', 9, 'warning')
end
