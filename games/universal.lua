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
			return game:HttpGet('https://raw.githubusercontent.com/SOILXP/VapeV4ForRoblox/main/'..select(1, path:gsub('newvape/', '')), true)
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
local virtualInputManager = cloneref(game:GetService('VirtualInputManager'))
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

universal.Version = 'pieced-football-separated-1.0.0'
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
universal.Services.StarterGui = starterGui
universal.Services.VirtualInputManager = virtualInputManager
universal.Services.CoreGui = coreGui
universal.Services.Workspace = workspace

local pieced = universal.PiecedFootball or {}
universal.PiecedFootball = pieced

pieced.ReactModules = pieced.ReactModules or {}
pieced.Modules = pieced.Modules or {}
pieced.Settings = pieced.Settings or {
	Range = 7,
	Delay = 0.08,
	Power = 85,
	Curve = 0,
	Angle = Vector3.new(4000000, 700, 4000000),
	Method = 'Shoot'
}

local savedProps = {}

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

local function cat(name)
	return vape.Categories[name] or vape.Categories.Utility or vape.Categories.Render or vape.Categories.Blatant or vape.Categories.Combat or vape.Categories.World
end

local function reg(name, module, react)
	pieced.Modules[name] = module
	if react then
		pieced.ReactModules[name] = module
	end
	return module
end

local function cleanConnection(conn)
	if conn then
		pcall(function()
			conn:Disconnect()
		end)
	end
end

local function selftoggle(module)
	task.delay(0.05, function()
		if module and module.Enabled then
			module:Toggle()
		end
	end)
end

local function saveprop(obj, props)
	if not obj then return end
	savedProps[obj] = savedProps[obj] or {}
	for _, prop in ipairs(props) do
		if savedProps[obj][prop] == nil then
			pcall(function()
				savedProps[obj][prop] = obj[prop]
			end)
		end
	end
end

local function restoreobj(obj)
	local data = savedProps[obj]
	if not data or not obj or not obj.Parent then return end
	for prop, value in pairs(data) do
		pcall(function()
			obj[prop] = value
		end)
	end
end

local function restoreall()
	for obj in pairs(savedProps) do
		restoreobj(obj)
	end
end

local function char()
	local c = lplr.Character
	return c, c and c:FindFirstChildOfClass('Humanoid'), c and (c:FindFirstChild('HumanoidRootPart') or c:FindFirstChild('Torso') or c.PrimaryPart)
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

local function getFE()
	return workspace:FindFirstChild('FE') or replicatedStorage:FindFirstChild('FE')
end

local function getRFE()
	return replicatedStorage:FindFirstChild('FE') or workspace:FindFirstChild('FE')
end

local function isball(obj)
	if not obj or not obj:IsA('BasePart') then return false end
	local name = obj.Name
	local lower = name:lower()
	return name == 'TPS' or name == 'PSoccerBall' or name == 'Ball' or name == 'Football' or lower:find('ball') ~= nil
end

local function balls()
	local found = {}

	local function scan(root)
		if not root then return end
		for _, obj in ipairs(root:GetDescendants()) do
			if isball(obj) then
				table.insert(found, obj)
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

local function nearestball(pos, maxrange)
	local best, dist
	for _, ball in ipairs(balls()) do
		local mag = (ball.Position - pos).Magnitude
		if mag <= maxrange and (not dist or mag < dist) then
			best = ball
			dist = mag
		end
	end
	return best, dist
end

local function scorer(ball)
	local fe = getFE()
	fire(path(fe, 'Scorer', 'RemoteEvent'), ball)
	fire(path(fe, 'Scorer', 'RemoteEvent1'), ball)
end

local function worn()
	local fe = getFE()
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

	fire(path(getRFE(), 'Sprint'), state)
end

local function touch(ball, method)
	local c, hum, root = char()
	local fe = getFE()
	if not c or not root or not ball or not fe then return end

	local rl = c:FindFirstChild('Right Leg') or c:FindFirstChild('RightFoot') or root
	local ll = c:FindFirstChild('Left Leg') or c:FindFirstChild('LeftFoot') or root
	local head = c:FindFirstChild('Head') or root
	local torso = c:FindFirstChild('Torso') or c:FindFirstChild('UpperTorso') or root

	if method == 'Shoot' then
		scorer(ball)
		sprint('Ended')
		fire(path(fe, 'Shoot', 'Shoot'), ball, rl, root, pieced.Settings.Curve, pieced.Settings.Power, pieced.Settings.Angle, CFrame.new(), CFrame.new(), 3)
	elseif method == 'ShootL' then
		scorer(ball)
		sprint('Ended')
		fire(path(fe, 'Shoot', 'ShootL'), ball, ll, root, pieced.Settings.Curve, pieced.Settings.Power, pieced.Settings.Angle, CFrame.new(), CFrame.new(), 3)
	elseif method == 'Dribble' then
		scorer(ball)
		fire(path(fe, 'Dribble', 'Dribble'), ball, rl)
	elseif method == 'FastDribble' then
		scorer(ball)
		fire(path(fe, 'Dribble', 'FastDribble'), ball, rl)
	elseif method == 'Tackle' then
		scorer(ball)
		fire(path(fe, 'Tackle', 'Tackle'), ball, rl)
	elseif method == 'TackleL' then
		scorer(ball)
		fire(path(fe, 'Tackle', 'TackleL'), ball, ll)
	elseif method == 'Chest' then
		worn()
		scorer(ball)
		fire(path(fe, 'Dribble', 'ChestControl'), ball, torso)
	elseif method == 'Header' then
		scorer(ball)
		fire(path(fe, 'Shoot', 'Header'), ball, head)
	elseif method == 'GK' then
		scorer(ball)
		fire(path(fe, 'GK', 'Punch'), ball, root.CFrame.LookVector)
		fire(path(fe, 'GK', 'Save1'), ball, root.CFrame.LookVector)
	elseif method == 'Clear' then
		scorer(ball)
		fire(path(fe, 'GK', 'Clear'), ball, rl, root.CFrame.LookVector, pieced.Settings.Power, pieced.Settings.Angle)
	end
end

local function startreact(method, range, delay)
	local last = 0
	return runService.Heartbeat:Connect(function()
		if os.clock() - last < delay then return end
		local _, _, root = char()
		if not root then return end

		local ball = nearestball(root.Position, range)
		if ball then
			last = os.clock()
			touch(ball, method)
		end
	end)
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
			part.Size = scaled(savedProps[part].Size, scale)
			part.Transparency = 0
		end
	end
end

universal.Notify = notify
universal.RemoveTags = removeTags
universal.PiecedFootball.GetBalls = balls
universal.PiecedFootball.NearestBall = nearestball
universal.PiecedFootball.Touch = touch

if vape.Clean then
	vape:Clean(function()
		restoreall()
	end)
end

run(function()
	local FireTouch
	local Connection

	FireTouch = cat('Utility'):CreateModule({
		Name = 'FireTouch',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Shoot', 7, 0.08)
				notify('FireTouch', 'Enabled.', 2)
			else
				notify('FireTouch', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Automatic shoot touch.'
	})

	FireTouch:Clean(function()
		cleanConnection(Connection)
	end)

	reg('FireTouch', FireTouch, true)
end)

run(function()
	local FireTouchGK
	local Connection

	FireTouchGK = cat('Utility'):CreateModule({
		Name = 'FireTouch GK',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('GK', 9, 0.08)
				notify('FireTouch GK', 'Enabled.', 2)
			else
				notify('FireTouch GK', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Automatic goalkeeper touch.'
	})

	FireTouchGK:Clean(function()
		cleanConnection(Connection)
	end)

	reg('FireTouch GK', FireTouchGK, true)
end)

run(function()
	local FireTouchChest
	local Connection

	FireTouchChest = cat('Utility'):CreateModule({
		Name = 'FireTouch Chest',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Chest', 7, 0.08)
				notify('FireTouch Chest', 'Enabled.', 2)
			else
				notify('FireTouch Chest', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Automatic chest control touch.'
	})

	FireTouchChest:Clean(function()
		cleanConnection(Connection)
	end)

	reg('FireTouch Chest', FireTouchChest, true)
end)

run(function()
	local CompReach
	local Connection

	CompReach = cat('Utility'):CreateModule({
		Name = 'Comp Reach',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Shoot', 10, 0.06)
				notify('Comp Reach', 'Enabled.', 2)
			else
				notify('Comp Reach', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Competitive shoot reach.'
	})

	CompReach:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Comp Reach', CompReach, true)
end)

run(function()
	local ShootQReach
	local Connection

	ShootQReach = cat('Utility'):CreateModule({
		Name = 'Shoot Q Reach',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Shoot', 12, 0.08)
				notify('Shoot Q Reach', 'Enabled.', 2)
			else
				notify('Shoot Q Reach', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Shoot reach preset.'
	})

	ShootQReach:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Shoot Q Reach', ShootQReach, true)
end)

run(function()
	local DribbleXReach
	local Connection

	DribbleXReach = cat('Utility'):CreateModule({
		Name = 'Dribble X Reach',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Dribble', 10, 0.08)
				notify('Dribble X Reach', 'Enabled.', 2)
			else
				notify('Dribble X Reach', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Dribble reach preset.'
	})

	DribbleXReach:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Dribble X Reach', DribbleXReach, true)
end)

run(function()
	local TackleXReach
	local Connection

	TackleXReach = cat('Utility'):CreateModule({
		Name = 'Tackle X Reach',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Tackle', 11, 0.08)
				notify('Tackle X Reach', 'Enabled.', 2)
			else
				notify('Tackle X Reach', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Tackle reach preset.'
	})

	TackleXReach:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Tackle X Reach', TackleXReach, true)
end)

run(function()
	local TheMainReact
	local Connection

	TheMainReact = cat('Utility'):CreateModule({
		Name = 'The Main React',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Shoot', 9, 0.055)
				notify('The Main React', 'Enabled.', 2)
			else
				notify('The Main React', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Main reaction preset.'
	})

	TheMainReact:Clean(function()
		cleanConnection(Connection)
	end)

	reg('The Main React', TheMainReact, true)
end)

run(function()
	local ReactKill
	local Connection

	ReactKill = cat('Utility'):CreateModule({
		Name = 'React Kill',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Shoot', 13, 0.045)
				notify('React Kill', 'Enabled.', 2)
			else
				notify('React Kill', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Aggressive reaction preset.'
	})

	ReactKill:Clean(function()
		cleanConnection(Connection)
	end)

	reg('React Kill', ReactKill, true)
end)

run(function()
	local StrelinhoReact
	local Connection

	StrelinhoReact = cat('Utility'):CreateModule({
		Name = 'Strelinho React',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('FastDribble', 8, 0.05)
				notify('Strelinho React', 'Enabled.', 2)
			else
				notify('Strelinho React', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Fast dribble reaction preset.'
	})

	StrelinhoReact:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Strelinho React', StrelinhoReact, true)
end)

run(function()
	local NoReactDecline
	local Connection

	NoReactDecline = cat('Utility'):CreateModule({
		Name = 'No React Decline',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Shoot', 8, 0.04)
				notify('No React Decline', 'Enabled.', 2)
			else
				notify('No React Decline', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Low delay reaction preset.'
	})

	NoReactDecline:Clean(function()
		cleanConnection(Connection)
	end)

	reg('No React Decline', NoReactDecline, true)
end)

run(function()
	local EmreMorTPSReact
	local Connection

	EmreMorTPSReact = cat('Utility'):CreateModule({
		Name = 'EmreMorTPS React',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Dribble', 9, 0.055)
				notify('EmreMorTPS React', 'Enabled.', 2)
			else
				notify('EmreMorTPS React', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Dribble reaction preset.'
	})

	EmreMorTPSReact:Clean(function()
		cleanConnection(Connection)
	end)

	reg('EmreMorTPS React', EmreMorTPSReact, true)
end)

run(function()
	local PrztxlReact
	local Connection

	PrztxlReact = cat('Utility'):CreateModule({
		Name = 'Prztxl React',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('ShootL', 9, 0.055)
				notify('Prztxl React', 'Enabled.', 2)
			else
				notify('Prztxl React', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Left foot shot reaction.'
	})

	PrztxlReact:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Prztxl React', PrztxlReact, true)
end)

run(function()
	local MarsReact
	local Connection

	MarsReact = cat('Utility'):CreateModule({
		Name = 'Mars React',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Header', 8, 0.06)
				notify('Mars React', 'Enabled.', 2)
			else
				notify('Mars React', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Header reaction preset.'
	})

	MarsReact:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Mars React', MarsReact, true)
end)

run(function()
	local SourenosReact
	local Connection

	SourenosReact = cat('Utility'):CreateModule({
		Name = 'Sourenos React',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Tackle', 8, 0.055)
				notify('Sourenos React', 'Enabled.', 2)
			else
				notify('Sourenos React', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Tackle reaction preset.'
	})

	SourenosReact:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Sourenos React', SourenosReact, true)
end)

run(function()
	local IonmaReact
	local Connection

	IonmaReact = cat('Utility'):CreateModule({
		Name = 'Ionma React',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Chest', 8, 0.055)
				notify('Ionma React', 'Enabled.', 2)
			else
				notify('Ionma React', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Chest reaction preset.'
	})

	IonmaReact:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Ionma React', IonmaReact, true)
end)

run(function()
	local UniversalMethods1
	local Connection

	UniversalMethods1 = cat('Utility'):CreateModule({
		Name = 'Universal Methods #1',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Shoot', 8, 0.075)
				notify('Universal Methods #1', 'Enabled.', 2)
			else
				notify('Universal Methods #1', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Universal shoot method.'
	})

	UniversalMethods1:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Universal Methods #1', UniversalMethods1, true)
end)

run(function()
	local UniversalMethods2
	local Connection

	UniversalMethods2 = cat('Utility'):CreateModule({
		Name = 'Universal Methods #2',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Dribble', 8, 0.075)
				notify('Universal Methods #2', 'Enabled.', 2)
			else
				notify('Universal Methods #2', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Universal dribble method.'
	})

	UniversalMethods2:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Universal Methods #2', UniversalMethods2, true)
end)

run(function()
	local UniversalMethods3
	local Connection

	UniversalMethods3 = cat('Utility'):CreateModule({
		Name = 'Universal Methods #3',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Tackle', 8, 0.075)
				notify('Universal Methods #3', 'Enabled.', 2)
			else
				notify('Universal Methods #3', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Universal tackle method.'
	})

	UniversalMethods3:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Universal Methods #3', UniversalMethods3, true)
end)

run(function()
	local DefenceReact
	local Connection

	DefenceReact = cat('Utility'):CreateModule({
		Name = 'Defence React',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Tackle', 12, 0.05)
				notify('Defence React', 'Enabled.', 2)
			else
				notify('Defence React', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Automatic defence reaction.'
	})

	DefenceReact:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Defence React', DefenceReact, true)
end)

run(function()
	local DribbleReact
	local Connection

	DribbleReact = cat('Utility'):CreateModule({
		Name = 'Dribble React',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact('Dribble', 10, 0.05)
				notify('Dribble React', 'Enabled.', 2)
			else
				notify('Dribble React', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Automatic dribble reaction.'
	})

	DribbleReact:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Dribble React', DribbleReact, true)
end)

run(function()
	local SkillSettings
	local Method
	local Range
	local Delay
	local Power

	SkillSettings = cat('Utility'):CreateModule({
		Name = 'Skill Settings',
		Function = function(callback)
			if callback then
				notify('Skill Settings', 'Applied.', 2)
				selftoggle(SkillSettings)
			end
		end,
		Tooltip = 'Global settings for custom reactions.'
	})

	Method = SkillSettings:CreateDropdown({
		Name = 'Method',
		List = {'Shoot', 'ShootL', 'Dribble', 'FastDribble', 'Tackle', 'TackleL', 'Chest', 'Header', 'GK', 'Clear'},
		Default = 'Shoot',
		Function = function(value)
			pieced.Settings.Method = value
		end
	})

	Range = SkillSettings:CreateSlider({
		Name = 'Range',
		Min = 3,
		Max = 25,
		Default = 7,
		Function = function(value)
			pieced.Settings.Range = value
		end
	})

	Delay = SkillSettings:CreateSlider({
		Name = 'Delay',
		Min = 0,
		Max = 300,
		Default = 80,
		Function = function(value)
			pieced.Settings.Delay = value / 1000
		end
	})

	Power = SkillSettings:CreateSlider({
		Name = 'Power',
		Min = 20,
		Max = 180,
		Default = 85,
		Function = function(value)
			pieced.Settings.Power = value
		end
	})

	reg('Skill Settings', SkillSettings)
end)

run(function()
	local FireTouchModules
	local Connection

	FireTouchModules = cat('Utility'):CreateModule({
		Name = 'FireTouch Modules',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = startreact(pieced.Settings.Method, pieced.Settings.Range, pieced.Settings.Delay)
				notify('FireTouch Modules', 'Enabled.', 2)
			else
				notify('FireTouch Modules', 'Disabled.', 2)
			end
		end,
		Tooltip = 'Uses selected Skill Settings method.'
	})

	FireTouchModules:Clean(function()
		cleanConnection(Connection)
	end)

	reg('FireTouch Modules', FireTouchModules, true)
end)

run(function()
	local TouchCount
	local Connection

	TouchCount = cat('Render'):CreateModule({
		Name = 'Touch Count',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				local count = 0
				Connection = runService.Heartbeat:Connect(function()
					local _, _, root = char()
					if not root then return end

					local ball = nearestball(root.Position, 5)
					if ball and not ball:GetAttribute('TouchCounted') then
						ball:SetAttribute('TouchCounted', true)
						count = count + 1
						notify('Touch Count', tostring(count), 2)

						task.delay(0.35, function()
							if ball then
								ball:SetAttribute('TouchCounted', nil)
							end
						end)
					end
				end)
			end
		end,
		Tooltip = 'Counts nearby ball contacts.'
	})

	TouchCount:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Touch Count', TouchCount)
end)

run(function()
	local DelayReducer

	DelayReducer = cat('Utility'):CreateModule({
		Name = 'Delay Reducer',
		Function = function(callback)
			for _, value in ipairs(lplr.Backpack:GetDescendants()) do
				if value:IsA('NumberValue') and (value.Name:lower():find('delay') or value.Name:lower():find('cooldown') or value.Name:lower():find('wait')) then
					if callback then
						saveprop(value, {'Value'})
						value.Value = 0
					else
						restoreobj(value)
					end
				elseif value:IsA('BoolValue') and (value.Name:lower():find('wait') or value.Name:lower():find('cooldown')) then
					if callback then
						saveprop(value, {'Value'})
						value.Value = false
					else
						restoreobj(value)
					end
				end
			end
		end,
		Tooltip = 'Reduces local tool delays.'
	})

	reg('Delay Reducer', DelayReducer)
end)

run(function()
	local NoToolCooldown
	local Connection

	NoToolCooldown = cat('Utility'):CreateModule({
		Name = 'No Tool Cooldown',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = runService.Heartbeat:Connect(function()
					if lplr.PlayerGui:FindFirstChild('Activate') then
						lplr.PlayerGui.Activate.Value = true
					end

					if lplr.PlayerGui:FindFirstChild('ToolSelect') then
						lplr.PlayerGui.ToolSelect.Value = true
					end

					for _, value in ipairs(lplr.Backpack:GetDescendants()) do
						if value:IsA('BoolValue') and (value.Name == 'Wait' or value.Name == 'TackleWait' or value.Name:lower():find('cooldown')) then
							value.Value = false
						end
					end
				end)
			end
		end,
		Tooltip = 'Keeps local tools available.'
	})

	NoToolCooldown:Clean(function()
		cleanConnection(Connection)
	end)

	reg('No Tool Cooldown', NoToolCooldown)
end)

run(function()
	local NoShotCharge
	local Connection

	NoShotCharge = cat('Utility'):CreateModule({
		Name = 'No Shot Charge',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = runService.Heartbeat:Connect(function()
					for _, obj in ipairs(lplr.Backpack:GetDescendants()) do
						if obj:IsA('NumberValue') then
							if obj.Name == 'Speed' then
								obj.Value = pieced.Settings.Power
							elseif obj.Name == 'Curve' then
								obj.Value = pieced.Settings.Curve
							end
						elseif obj:IsA('Vector3Value') and obj.Name == 'Angle' then
							obj.Value = pieced.Settings.Angle
						end
					end
				end)
			end
		end,
		Tooltip = 'Keeps shot values charged.'
	})

	NoShotCharge:Clean(function()
		cleanConnection(Connection)
	end)

	reg('No Shot Charge', NoShotCharge)
end)

run(function()
	local ShootPowerBoosts

	ShootPowerBoosts = cat('Utility'):CreateModule({
		Name = 'Shoot/Power Boosts',
		Function = function(callback)
			if callback then
				pieced.Settings.Power = 130
				pieced.Settings.Angle = Vector3.new(4000000, 1200, 4000000)
				notify('Shoot/Power Boosts', 'Boosted.', 2)
			else
				pieced.Settings.Power = 85
				pieced.Settings.Angle = Vector3.new(4000000, 700, 4000000)
			end
		end,
		Tooltip = 'Boosts shot power values.'
	})

	reg('Shoot/Power Boosts', ShootPowerBoosts)
end)

run(function()
	local UnlimitedStamina
	local Connection

	UnlimitedStamina = cat('Utility'):CreateModule({
		Name = 'Unlimited Stamina',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = runService.Heartbeat:Connect(function()
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

					local container = workspace:FindFirstChild('CharacterContainer')
					local folder = container and container:FindFirstChild(lplr.Name)
					local stats = folder and folder:FindFirstChild('Stats')
					local stamina = stats and stats:FindFirstChild('Stamina')
					local maxstamina = stats and stats:FindFirstChild('MaxStamina')

					if stamina and stamina:IsA('NumberValue') then
						stamina.Value = maxstamina and maxstamina.Value or 100
					end
				end)
			end
		end,
		Tooltip = 'Keeps local stamina full.'
	})

	UnlimitedStamina:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Unlimited Stamina', UnlimitedStamina)
end)

run(function()
	local AutoDefence
	local Connection

	AutoDefence = cat('Utility'):CreateModule({
		Name = 'Auto Defence',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				local last = 0
				Connection = runService.Heartbeat:Connect(function()
					if os.clock() - last < 0.12 then return end
					local _, _, root = char()
					if not root then return end

					local ball = nearestball(root.Position, 14)
					if ball then
						last = os.clock()
						touch(ball, 'Tackle')
					end
				end)
			end
		end,
		Tooltip = 'Auto tackles nearby ball.'
	})

	AutoDefence:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Auto Defence', AutoDefence, true)
end)

run(function()
	local Unreach

	Unreach = cat('Utility'):CreateModule({
		Name = 'Unreach',
		Function = function(callback)
			if callback then
				for _, module in pairs(pieced.ReactModules) do
					if module and module.Enabled then
						module:Toggle()
					end
				end

				for _, ball in ipairs(balls()) do
					restoreobj(ball)
				end

				notify('Unreach', 'React modules disabled.', 2)
				selftoggle(Unreach)
			end
		end,
		Tooltip = 'Turns off reach/react modules.'
	})

	reg('Unreach', Unreach)
end)

run(function()
	local BallSize
	local Size

	BallSize = cat('World'):CreateModule({
		Name = 'Ball Size',
		Function = function(callback)
			if callback then
				for _, ball in ipairs(balls()) do
					saveprop(ball, {'Size'})
					ball.Size = Vector3.new(Size.Value, Size.Value, Size.Value)
				end
			else
				for _, ball in ipairs(balls()) do
					restoreobj(ball)
				end
			end
		end,
		Tooltip = 'Changes local ball size.'
	})

	Size = BallSize:CreateSlider({
		Name = 'Size',
		Min = 1,
		Max = 15,
		Default = 5,
		Function = function()
			if BallSize.Enabled then
				for _, ball in ipairs(balls()) do
					saveprop(ball, {'Size'})
					ball.Size = Vector3.new(Size.Value, Size.Value, Size.Value)
				end
			end
		end
	})

	reg('Ball Size', BallSize)
end)

run(function()
	local BallVisibility
	local Visible
	local Connection

	BallVisibility = cat('Render'):CreateModule({
		Name = 'Ball Visibility',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = runService.RenderStepped:Connect(function()
					for _, ball in ipairs(balls()) do
						ball.LocalTransparencyModifier = 1 - (Visible.Value / 100)
					end
				end)
			else
				for _, ball in ipairs(balls()) do
					ball.LocalTransparencyModifier = 0
				end
			end
		end,
		Tooltip = 'Changes ball transparency.'
	})

	Visible = BallVisibility:CreateSlider({
		Name = 'Visible',
		Min = 0,
		Max = 100,
		Default = 100,
		Function = function() end
	})

	BallVisibility:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Ball Visibility', BallVisibility)
end)

run(function()
	local BallTextures
	local Texture
	local Connection

	BallTextures = cat('Render'):CreateModule({
		Name = 'Ball Textures',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = runService.RenderStepped:Connect(function()
					for _, ball in ipairs(balls()) do
						saveprop(ball, {'Color', 'Material'})
						if Texture.Value == 'Neon' then
							ball.Material = Enum.Material.Neon
							ball.Color = Color3.fromRGB(255, 255, 255)
						elseif Texture.Value == 'Black' then
							ball.Material = Enum.Material.SmoothPlastic
							ball.Color = Color3.fromRGB(0, 0, 0)
						elseif Texture.Value == 'Red' then
							ball.Material = Enum.Material.Neon
							ball.Color = Color3.fromRGB(255, 50, 50)
						elseif Texture.Value == 'Blue' then
							ball.Material = Enum.Material.Neon
							ball.Color = Color3.fromRGB(50, 120, 255)
						end
					end
				end)
			else
				for _, ball in ipairs(balls()) do
					restoreobj(ball)
				end
			end
		end,
		Tooltip = 'Changes local ball texture.'
	})

	Texture = BallTextures:CreateDropdown({
		Name = 'Texture',
		List = {'Neon', 'Black', 'Red', 'Blue'},
		Default = 'Neon',
		Function = function() end
	})

	BallTextures:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Ball Textures', BallTextures)
end)

run(function()
	local RangeVisualizer
	local Circle
	local Connection

	RangeVisualizer = cat('Render'):CreateModule({
		Name = 'Range Visualizer',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if Circle then
				pcall(function()
					Circle:Remove()
				end)
				Circle = nil
			end

			if callback and Drawing then
				Circle = Drawing.new('Circle')
				Circle.Thickness = 1
				Circle.NumSides = 96
				Circle.Filled = false
				Circle.Transparency = 0.85

				Connection = runService.RenderStepped:Connect(function()
					local cam = workspace.CurrentCamera
					local _, _, root = char()
					if not cam or not root then return end

					local pos, on = cam:WorldToViewportPoint(root.Position)
					Circle.Visible = on

					if on then
						Circle.Position = Vector2.new(pos.X, pos.Y)
						Circle.Radius = pieced.Settings.Range * 7
					end
				end)
			end
		end,
		Tooltip = 'Draws current react range.'
	})

	RangeVisualizer:Clean(function()
		cleanConnection(Connection)
		if Circle then
			pcall(function()
				Circle:Remove()
			end)
		end
	end)

	reg('Range Visualizer', RangeVisualizer)
end)

run(function()
	local FieldOfView
	local FOV
	local Connection

	FieldOfView = cat('Render'):CreateModule({
		Name = 'Field of View',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			local cam = workspace.CurrentCamera
			if callback then
				if cam then
					saveprop(cam, {'FieldOfView'})
				end

				Connection = runService.RenderStepped:Connect(function()
					if workspace.CurrentCamera then
						workspace.CurrentCamera.FieldOfView = FOV.Value
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

	FOV = FieldOfView:CreateSlider({
		Name = 'FOV',
		Min = 40,
		Max = 120,
		Default = 80,
		Function = function() end
	})

	FieldOfView:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Field of View', FieldOfView)
end)

run(function()
	local MuteCrowd

	MuteCrowd = cat('Render'):CreateModule({
		Name = 'Mute Crowd',
		Function = function(callback)
			for _, sound in ipairs(workspace:GetDescendants()) do
				if sound:IsA('Sound') and (sound.Name:lower():find('crowd') or (sound.Parent and sound.Parent.Name:lower():find('crowd'))) then
					if callback then
						saveprop(sound, {'Volume'})
						sound.Volume = 0
					else
						restoreobj(sound)
					end
				end
			end
		end,
		Tooltip = 'Mutes crowd sounds.'
	})

	reg('Mute Crowd', MuteCrowd)
end)

run(function()
	local GoalMusic

	GoalMusic = cat('Render'):CreateModule({
		Name = 'Goal Music',
		Function = function(callback)
			for _, sound in ipairs(workspace:GetDescendants()) do
				if sound:IsA('Sound') and sound.Name:lower():find('goal') then
					if callback then
						saveprop(sound, {'Volume'})
						sound.Volume = 5
					else
						restoreobj(sound)
					end
				end
			end
		end,
		Tooltip = 'Boosts goal music.'
	})

	reg('Goal Music', GoalMusic)
end)

run(function()
	local TransparentGoalNets

	TransparentGoalNets = cat('Render'):CreateModule({
		Name = 'Transparent Goal Nets',
		Function = function(callback)
			for _, part in ipairs(workspace:GetDescendants()) do
				if part:IsA('BasePart') and part.Name:lower():find('net') then
					if callback then
						saveprop(part, {'Transparency'})
						part.Transparency = 0.8
					else
						restoreobj(part)
					end
				end
			end
		end,
		Tooltip = 'Makes goal nets transparent.'
	})

	reg('Transparent Goal Nets', TransparentGoalNets)
end)

run(function()
	local SkyboxChanger
	local Skybox

	SkyboxChanger = cat('Render'):CreateModule({
		Name = 'Skybox Changer',
		Function = function(callback)
			local sky = lightingService:FindFirstChildOfClass('Sky') or Instance.new('Sky')
			sky.Parent = lightingService

			if callback then
				saveprop(sky, {'SkyboxBk', 'SkyboxDn', 'SkyboxFt', 'SkyboxLf', 'SkyboxRt', 'SkyboxUp'})
				local id = Skybox.Value == 'Space' and 'rbxassetid://159454299' or 'rbxassetid://150182466'
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

	Skybox = SkyboxChanger:CreateDropdown({
		Name = 'Skybox',
		List = {'Space', 'Blue'},
		Default = 'Space',
		Function = function() end
	})

	reg('Skybox Changer', SkyboxChanger)
end)

run(function()
	local ConsoleHider

	ConsoleHider = cat('Utility'):CreateModule({
		Name = 'Console Hider',
		Function = function(callback)
			local dev = lplr.PlayerGui:FindFirstChild('DevConsoleMaster')
			if dev then
				dev.Enabled = not callback
			end

			pcall(function()
				starterGui:SetCore('DevConsoleVisible', not callback)
			end)
		end,
		Tooltip = 'Hides visible console UI.'
	})

	reg('Console Hider', ConsoleHider)
end)

run(function()
	local RejoinGame

	RejoinGame = cat('Utility'):CreateModule({
		Name = 'Rejoin Game',
		Function = function(callback)
			if callback then
				teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lplr)
				selftoggle(RejoinGame)
			end
		end,
		Tooltip = 'Rejoins current server.'
	})

	reg('Rejoin Game', RejoinGame)
end)

run(function()
	local ReplaceBothArms

	ReplaceBothArms = cat('Utility'):CreateModule({
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

	reg('Replace Both Arms', ReplaceBothArms)
end)

run(function()
	local ReplaceBothLegs

	ReplaceBothLegs = cat('Utility'):CreateModule({
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

	reg('Replace Both Legs', ReplaceBothLegs)
end)

run(function()
	local BlockyBody

	BlockyBody = cat('Utility'):CreateModule({
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

	reg('Blocky Body', BlockyBody)
end)

run(function()
	local RevertToOriginalBody

	RevertToOriginalBody = cat('Utility'):CreateModule({
		Name = 'Revert to Original Body',
		Function = function(callback)
			if callback then
				restoreall()
				selftoggle(RevertToOriginalBody)
			end
		end,
		Tooltip = 'Restores saved body sizes.'
	})

	reg('Revert to Original Body', RevertToOriginalBody)
end)

run(function()
	local StretchedResolution
	local Connection

	StretchedResolution = cat('Render'):CreateModule({
		Name = 'Stretched Resolution',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = runService.RenderStepped:Connect(function()
					if workspace.CurrentCamera then
						workspace.CurrentCamera.FieldOfView = 95
					end
				end)
			end
		end,
		Tooltip = 'Simulates stretched resolution.'
	})

	StretchedResolution:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Stretched Resolution', StretchedResolution)
end)

run(function()
	local Clumsy
	local Connection

	Clumsy = cat('Utility'):CreateModule({
		Name = 'Clumsy',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				Connection = runService.Heartbeat:Connect(function()
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

	Clumsy:Clean(function()
		cleanConnection(Connection)
	end)

	reg('Clumsy', Clumsy)
end)

run(function()
	local Disguise

	Disguise = cat('Render'):CreateModule({
		Name = 'Disguise',
		Function = function(callback)
			local c = lplr.Character
			if not c then return end

			for _, obj in ipairs(c:GetDescendants()) do
				if obj:IsA('BasePart') then
					if callback then
						saveprop(obj, {'Color'})
						obj.Color = Color3.fromRGB(80, 80, 80)
					else
						restoreobj(obj)
					end
				elseif obj:IsA('Decal') then
					if callback then
						saveprop(obj, {'Transparency'})
						obj.Transparency = 1
					else
						restoreobj(obj)
					end
				end
			end
		end,
		Tooltip = 'Applies a simple local disguise.'
	})

	reg('Disguise', Disguise)
end)

run(function()
	local BallESP
	local Line
	local Circle
	local Connection

	BallESP = cat('Render'):CreateModule({
		Name = 'Ball ESP',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if Line then
				pcall(function()
					Line:Remove()
				end)
				Line = nil
			end

			if Circle then
				pcall(function()
					Circle:Remove()
				end)
				Circle = nil
			end

			if callback and Drawing then
				Line = Drawing.new('Line')
				Line.Thickness = 1
				Line.Transparency = 0.85

				Circle = Drawing.new('Circle')
				Circle.Thickness = 1
				Circle.NumSides = 48
				Circle.Filled = false
				Circle.Transparency = 0.85

				Connection = runService.RenderStepped:Connect(function()
					local cam = workspace.CurrentCamera
					local _, _, root = char()
					if not cam or not root then return end

					local ball = nearestball(root.Position, 1500)
					if not ball then
						Line.Visible = false
						Circle.Visible = false
						return
					end

					local pos, on = cam:WorldToViewportPoint(ball.Position)
					if not on then
						Line.Visible = false
						Circle.Visible = false
						return
					end

					local center = cam.ViewportSize * 0.5
					local screen = Vector2.new(pos.X, pos.Y)

					Line.From = Vector2.new(center.X, center.Y)
					Line.To = screen
					Line.Visible = true

					Circle.Position = screen
					Circle.Radius = math.clamp(1800 / math.max(pos.Z, 1), 5, 35)
					Circle.Visible = true
				end)
			end
		end,
		Tooltip = 'Draws line and circle on ball.'
	})

	BallESP:Clean(function()
		cleanConnection(Connection)
		if Line then
			pcall(function()
				Line:Remove()
			end)
		end
		if Circle then
			pcall(function()
				Circle:Remove()
			end)
		end
	end)

	reg('Ball ESP', BallESP)
end)

run(function()
	local AutoDive
	local Connection
	local VisualFolder
	local DiveCooldown = false
	local MinBallVelocity = 10
	local DelayMidDive = 0.02
	local DelayHighDive = 0.13
	local TimeThresholdFar = 0.32
	local TimeThresholdMidFar = 0.23
	local TimeThresholdMid = 0.2
	local LowMidHeight = -1
	local MidHighHeight = 3
	local ReachX = 40
	local ReachY = 25
	local BallRadius = 1
	local BounceElasticity = 0.7
	local ShowVisuals = false

	local function clearVisuals()
		if VisualFolder then
			VisualFolder:Destroy()
			VisualFolder = nil
		end
	end

	local function visualFolder()
		if not VisualFolder then
			VisualFolder = Instance.new('Folder')
			VisualFolder.Name = 'GK_AutoDive_Visuals'
			VisualFolder.Parent = workspace
		end
		return VisualFolder
	end

	local function drawPoint(pos, color, size)
		if not ShowVisuals then return end
		local part = Instance.new('Part')
		part.Anchored = true
		part.CanCollide = false
		part.CastShadow = false
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.Neon
		part.Size = Vector3.new(size, size, size)
		part.Position = pos
		part.Color = color
		part.Parent = visualFolder()
		debrisService:AddItem(part, 0.12)
	end

	local function performDive(direction, mode)
		if DiveCooldown then return end
		DiveCooldown = true

		task.spawn(function()
			local holdKey
			if direction == 'Right' then
				holdKey = Enum.KeyCode.D
			elseif direction == 'Left' then
				holdKey = Enum.KeyCode.A
			end

			if holdKey then
				virtualInputManager:SendKeyEvent(true, holdKey, false, game)
			end

			if mode == 'High' then
				virtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
				task.wait(DelayHighDive)
				virtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 1)
			elseif mode == 'Mid' then
				virtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
				task.wait(DelayMidDive)
				virtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 1)
			else
				virtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 1)
			end

			task.wait(0.1)
			virtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 1)

			if mode == 'High' or mode == 'Mid' then
				virtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
			end

			if holdKey then
				virtualInputManager:SendKeyEvent(false, holdKey, false, game)
			end

			task.wait(0.8)
			DiveCooldown = false
		end)
	end

	local function reactionThreshold(sideways)
		local center = 4
		local far = 16
		if sideways >= far then return TimeThresholdFar end
		if sideways <= center then return TimeThresholdMid end
		local alpha = (sideways - center) / (far - center)
		return TimeThresholdMidFar + (TimeThresholdFar - TimeThresholdMidFar) * alpha
	end

	local function update()
		local _, _, root = char()
		if not root then return end

		local ball = (workspace:FindFirstChild('Temp') and workspace.Temp:FindFirstChild('Ball')) or workspace:FindFirstChild('Ball') or nearestball(root.Position, 1000)
		if not ball or ball.AssemblyLinearVelocity.Magnitude < MinBallVelocity then return end

		local externalAcc = Vector3.zero
		local force = ball:FindFirstChildWhichIsA('VectorForce', true)

		if force and force.Enabled and ball.AssemblyMass > 0 then
			local raw = force.Force
			if force.RelativeTo == Enum.ActuatorRelativeTo.Attachment0 and force.Attachment0 then
				raw = force.Attachment0.WorldCFrame:VectorToWorldSpace(raw)
			elseif force.RelativeTo == Enum.ActuatorRelativeTo.Attachment1 and force.Attachment1 then
				raw = force.Attachment1.WorldCFrame:VectorToWorldSpace(raw)
			end
			externalAcc = raw / ball.AssemblyMass
		end

		local simPos = ball.Position
		local simVel = ball.AssemblyLinearVelocity
		local step = 0.015
		local rootCF = root.CFrame
		local lastRelZ = rootCF:PointToObjectSpace(simPos).Z

		for i = 1, 100 do
			local oldPos = simPos
			local oldRelZ = lastRelZ

			simVel = simVel + ((Vector3.new(0, -workspace.Gravity, 0) + externalAcc) * step)
			simPos = simPos + (simVel * step)

			if simPos.Y < BallRadius then
				simPos = Vector3.new(simPos.X, BallRadius, simPos.Z)
				simVel = Vector3.new(simVel.X, -simVel.Y * BounceElasticity, simVel.Z)
			end

			if ShowVisuals and i % 3 == 0 then
				drawPoint(simPos, Color3.new(1, 0, 0), 0.2)
			end

			local rel = rootCF:PointToObjectSpace(simPos)
			if oldRelZ * rel.Z <= 0 then
				local total = math.abs(oldRelZ - rel.Z)
				local alpha = total > 0.0001 and math.abs(oldRelZ) / total or 0
				local impact = oldPos:Lerp(simPos, alpha)
				local impactRel = rootCF:PointToObjectSpace(impact)
				local impactTime = (i - 1 + alpha) * step

				if impactRel.Y > -5 and impactRel.Y < ReachY and math.abs(impactRel.X) < ReachX and impactTime <= reactionThreshold(math.abs(impactRel.X)) then
					local mode = 'Low'
					local color = Color3.new(0, 1, 0)

					if impactRel.Y < LowMidHeight then
						mode = 'Low'
						color = Color3.new(0, 1, 0)
					elseif impactRel.Y <= MidHighHeight then
						mode = 'Mid'
						color = Color3.new(1, 0.5, 0)
					else
						mode = 'High'
						color = Color3.new(1, 0, 1)
					end

					local dir = 'Center'
					if impactRel.X > 2.5 then
						dir = 'Right'
					elseif impactRel.X < -2.5 then
						dir = 'Left'
					end

					drawPoint(impact, color, 1)
					performDive(dir, mode)
				end
				break
			end

			lastRelZ = rel.Z
		end
	end

	AutoDive = cat('Utility'):CreateModule({
		Name = 'AutoDive',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil
			clearVisuals()
			DiveCooldown = false

			if callback then
				Connection = runService.RenderStepped:Connect(update)
			end
		end,
		Tooltip = 'Automatically dives to save shots as goalkeeper.'
	})

	AutoDive:CreateSlider({
		Name = 'Min ball velocity',
		Min = 5,
		Max = 30,
		Default = 10,
		Function = function(value) MinBallVelocity = value end,
		Tooltip = 'Ignore balls slower than this.'
	})

	AutoDive:CreateSlider({
		Name = 'Mid dive delay',
		Min = 0,
		Max = 0.2,
		Default = 0.02,
		Decimal = 100,
		Function = function(value) DelayMidDive = value end,
		Tooltip = 'Delay before mid dives.'
	})

	AutoDive:CreateSlider({
		Name = 'High dive delay',
		Min = 0,
		Max = 0.3,
		Default = 0.13,
		Decimal = 100,
		Function = function(value) DelayHighDive = value end,
		Tooltip = 'Delay before high dives.'
	})

	AutoDive:CreateSlider({
		Name = 'Reach X',
		Min = 20,
		Max = 60,
		Default = 40,
		Function = function(value) ReachX = value end,
		Tooltip = 'Maximum sideways reach.'
	})

	AutoDive:CreateSlider({
		Name = 'Reach Y',
		Min = 15,
		Max = 40,
		Default = 25,
		Function = function(value) ReachY = value end,
		Tooltip = 'Maximum vertical reach.'
	})

	AutoDive:CreateToggle({
		Name = 'Show visuals',
		Default = false,
		Function = function(value) ShowVisuals = value end,
		Tooltip = 'Show prediction dots.'
	})

	AutoDive:Clean(function()
		cleanConnection(Connection)
		clearVisuals()
	end)

	reg('AutoDive', AutoDive)
end)

run(function()
	local AutoTrap
	local Connection
	local StopGround
	local AnimationTrack
	local AnimationPlayed = false

	local function setupAnimation()
		local c = lplr.Character
		local hum = c and c:FindFirstChildOfClass('Humanoid')
		if not hum then return end
		local animator = hum:FindFirstChildOfClass('Animator') or hum:FindFirstChild('Animator')
		if not animator then return end
		local animation = Instance.new('Animation')
		animation.AnimationId = 'rbxassetid://15365316903'
		AnimationTrack = animator:LoadAnimation(animation)
	end

	local function getStopRemote()
		if StopGround then return StopGround end
		local key = path(replicatedStorage, 'Packages', 'Knit', 'Services', 'KeyHandlerService', 'RF', 'GetKey')
		if not key then return end

		local suc, res = pcall(function()
			return key:InvokeServer('StopBall_GroundBackup')
		end)

		if suc then
			StopGround = res
		end

		return StopGround
	end

	local function update()
		local ball = workspace:FindFirstChild('Temp') and workspace.Temp:FindFirstChild('Ball')
		if not ball then return end
		if ball:FindFirstChild('PossessionHighlight') then
			AnimationPlayed = false
			return
		end

		local c, hum, root = char()
		if not c or not hum or not root then return end

		local velocity = ball.AssemblyLinearVelocity
		local speed = velocity.Magnitude
		if speed <= 1 then return end

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {ball}
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local result = workspace:Raycast(ball.Position, Vector3.new(0, -1, 0), rayParams)
		if not result or result.Material == Enum.Material.Air then return end

		local ballDirection = velocity.Unit
		local playerToBall = root.Position - ball.Position
		local projection = ballDirection * playerToBall:Dot(ballDirection)
		local closestPoint = ball.Position + projection
		local distanceToLine = (root.Position - closestPoint).Magnitude
		local trapDistance = math.max(7, math.floor(speed / 9.2))

		if velocity:Dot(playerToBall) > 0 and distanceToLine <= 5 then
			local predicted = ball.Position + velocity.Unit * trapDistance
			if (root.Position - predicted).Magnitude <= trapDistance then
				local remote = getStopRemote()
				if remote and remote.FireServer then
					remote:FireServer(ball, Vector3.new(0, 0, 0), 'Right')
					if not AnimationPlayed and AnimationTrack and not AnimationTrack.IsPlaying then
						AnimationTrack:Play()
						AnimationPlayed = true
					end
				end
			end
		end
	end

	AutoTrap = cat('Utility'):CreateModule({
		Name = 'AutoTrap',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil
			AnimationPlayed = false

			if callback then
				setupAnimation()
				Connection = runService.Heartbeat:Connect(update)
			end
		end,
		Tooltip = 'Automatically traps ground balls.'
	})

	AutoTrap:Clean(function()
		cleanConnection(Connection)
	end)

	reg('AutoTrap', AutoTrap)
end)

run(function()
	local StaminaMultiplier
	local Multiplier
	local Connection

	StaminaMultiplier = cat('Utility'):CreateModule({
		Name = 'StaminaMultiplier',
		Function = function(callback)
			cleanConnection(Connection)
			Connection = nil

			if callback then
				local last = {}
				Connection = runService.Heartbeat:Connect(function()
					local c = lplr.Character
					local stats = c and c:FindFirstChild('Stats')
					local stamina = stats and stats:FindFirstChild('Stamina')
					if not stamina or not stamina:IsA('NumberValue') then return end

					local old = last[stamina] or stamina.Value
					if stamina.Value < old then
						stamina.Value = old - ((old - stamina.Value) / math.max(Multiplier.Value, 1))
					end
					last[stamina] = stamina.Value
				end)
			end
		end,
		Tooltip = 'Makes stamina drain slower.'
	})

	Multiplier = StaminaMultiplier:CreateSlider({
		Name = 'Multiplier',
		Min = 1,
		Max = 10,
		Default = 1,
		Decimal = 10,
		Suffix = function()
			return 'x'
		end,
		Function = function() end,
		Tooltip = 'Higher means less stamina drain.'
	})

	StaminaMultiplier:Clean(function()
		cleanConnection(Connection)
	end)

	reg('StaminaMultiplier', StaminaMultiplier)
end)

universal.Ready = true

if vape and vape.CreateNotification then
	vape:CreateNotification('Welcome Pieced', 'VAPE PRIVATE Loaded!', 9, 'warning')
end
