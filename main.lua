repeat task.wait() until game:IsLoaded()
if shared.vape then
	pcall(function()
		shared.vape:Uninject()
	end)
	shared.vape = nil
end

-- why do exploits fail to implement anything correctly? Is it really that hard?
if identifyexecutor then
	if table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local vape
local oldloadstring = loadstring
local loadstring = function(...)
	local res, err = oldloadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local silentUniversalPlaceIds = {
	[11156779721] = true,
	[11630038968] = true,
	[12011959048] = true,
	[123804558118054] = true,
	[131465939650733] = true,
	[13246639586] = true,
	[14191889582] = true,
	[14662411059] = true,
	[18935841239] = true,
	[18972674759] = true,
	[5938036553] = true,
	[6872265039] = true,
	[6872274481] = true,
	[79695841807485] = true,
	[8444591321] = true,
	[8542259458] = true,
	[8542275097] = true,
	[8560631822] = true,
	[8592115909] = true,
	[8768229691] = true,
	[8951451142] = true
}

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/Zinnwolf/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function fetchGameFile(path)
	if isfile(path) then
		return true
	end

	if shared.VapeDeveloper then
		return false
	end

	local suc, res = pcall(function()
		return game:HttpGet('https://raw.githubusercontent.com/Zinnwolf/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
	end)

	if suc and res ~= '404: Not Found' then
		res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		writefile(path, res)
		return true
	end

	return false
end

local function createBlankOption(default)
	local option = {
		Enabled = default == true,
		Value = default,
		ListEnabled = {},
		Object = {Visible = false}
	}

	function option:Toggle()
		self.Enabled = not self.Enabled
	end

	function option:SetValue(value)
		self.Value = value
	end

	function option:Save() end
	function option:Load() end
	function option:Color() end
	function option:Clean() end

	return option
end

local function createBlankModule(name)
	local module = {
		Name = name or 'UniversalDummy',
		Enabled = false,
		Options = {},
		ListEnabled = {},
		Object = {Visible = false}
	}

	function module:Toggle()
		self.Enabled = not self.Enabled
	end

	function module:Clean() end

	function module:CreateToggle(settings)
		local option = createBlankOption(settings and settings.Default or false)
		self.Options[(settings and settings.Name) or 'Toggle'] = option
		return option
	end

	function module:CreateSlider(settings)
		local option = createBlankOption(settings and (settings.Default or settings.Min) or 0)
		self.Options[(settings and settings.Name) or 'Slider'] = option
		return option
	end

	function module:CreateTwoSlider(settings)
		local option = createBlankOption(settings and (settings.Default or settings.DefaultMin) or 0)
		function option:GetRandomValue()
			return self.Value or 1
		end
		self.Options[(settings and settings.Name) or 'TwoSlider'] = option
		return option
	end

	function module:CreateDropdown(settings)
		local list = settings and settings.List or {}
		local option = createBlankOption(list[1] or 'None')
		self.Options[(settings and settings.Name) or 'Dropdown'] = option
		return option
	end

	function module:CreateColorSlider(settings)
		local option = createBlankOption(0)
		option.Hue = settings and settings.DefaultHue or 0.44
		option.Sat = settings and settings.DefaultSat or 1
		option.Value = settings and settings.DefaultValue or 1
		option.Opacity = settings and settings.DefaultOpacity or 1
		self.Options[(settings and settings.Name) or 'Color'] = option
		return option
	end

	function module:CreateTextbox(settings)
		local option = createBlankOption(settings and settings.Default or '')
		self.Options[(settings and settings.Name) or 'Textbox'] = option
		return option
	end

	function module:CreateTextBox(settings)
		return self:CreateTextbox(settings)
	end

	function module:CreateButton(settings)
		local option = createBlankOption(false)
		self.Options[(settings and settings.Name) or 'Button'] = option
		return option
	end

	function module:CreateTargets(settings)
		local option = createBlankOption(false)
		option.Players = createBlankOption(settings and settings.Players)
		option.NPCs = createBlankOption(settings and settings.NPCs)
		option.Walls = createBlankOption(settings and settings.Walls)
		option.Invisible = createBlankOption(settings and settings.Invisible)
		self.Options.Targets = option
		return option
	end

	return module
end

local function silenceUniversalModules(callback)
	local originals = {}

	if not (vape and vape.Categories) then
		return callback()
	end

	for _, category in vape.Categories do
		if type(category) == 'table' and type(category.CreateModule) == 'function' then
			originals[category] = category.CreateModule
			category.CreateModule = function(_, settings)
				return createBlankModule(settings and settings.Name)
			end
		end
	end

	local suc, err = pcall(callback)

	for category, original in originals do
		category.CreateModule = original
	end

	if not suc then
		error(err)
	end
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				if shared.VapeDeveloper then
					loadstring(readfile('newvape/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/Zinnwolf/VapeV4ForRoblox/'..readfile('newvape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('newvape/profiles/gui.txt') then
	writefile('newvape/profiles/gui.txt', 'new')
end
local gui = readfile('newvape/profiles/gui.txt')

if not isfolder('newvape/assets/'..gui) then
	makefolder('newvape/assets/'..gui)
end
vape = loadstring(downloadFile('newvape/guis/'..gui..'.lua'), 'gui')()
shared.vape = vape

if not shared.VapeIndependent then
	local gameFile = 'newvape/games/'..game.PlaceId..'.lua'
	local hasGameFile = fetchGameFile(gameFile)
	local silentUniversal = silentUniversalPlaceIds[game.PlaceId] == true

	if silentUniversal then
		silenceUniversalModules(function()
			loadstring(downloadFile('newvape/games/universal.lua'), 'universal')()
		end)
	else
		loadstring(downloadFile('newvape/games/universal.lua'), 'universal')()
	end

	if hasGameFile then
		loadstring(readfile(gameFile), tostring(game.PlaceId))(...)
	end

	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
