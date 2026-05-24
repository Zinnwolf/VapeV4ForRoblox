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

local supportedPlaceIds = {
	[123804558118054] = true,
	[131465939650733] = true,
	[13246639586] = true,
	[139566161526375] = true,
	[16483433878] = true,
	[18935841239] = true,
	[18972674759] = true,
	[5938036553] = true,
	[606849621] = true,
	[6872265039] = true,
	[6872274481] = true,
	[77790193039862] = true,
	[80041634734121] = true,
	[83413351472244] = true,
	[8444591321] = true,
	[8542259458] = true,
	[8542275097] = true,
	[8560631822] = true,
	[8592115909] = true,
	[8768229691] = true,
	[893973440] = true,
	[8951451142] = true,

	-- ids from your screenshot
	[11156779721] = true,
	[11630038968] = true,
	[12011959048] = true,
	[14191889582] = true,
	[14662411059] = true,
	[79695841807485] = true
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

local function snapshotModules()
	local modules = {}

	if vape and vape.Modules then
		for name, module in vape.Modules do
			modules[name] = module
		end
	end

	return modules
end

local function getCreatedModules(before)
	local modules = {}

	if vape and vape.Modules then
		for name, module in vape.Modules do
			if before[name] == nil then
				modules[name] = module
			end
		end
	end

	return modules
end

local function removeUniversalModules(modules)
	if not (vape and vape.Modules) then
		return
	end

	for name, module in modules do
		pcall(function()
			if vape.Modules[name] == module then
				if module.Toggle and module.Enabled then
					module:Toggle()
				end

				if module.Clean then
					module:Clean()
				end

				if vape.Remove then
					vape:Remove(name)
				else
					vape.Modules[name] = nil
				end
			end
		end)
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
	local supportedGame = supportedPlaceIds[game.PlaceId] == true
	local hasGameFile = supportedGame and fetchGameFile(gameFile)

	local beforeUniversal = snapshotModules()
	loadstring(downloadFile('newvape/games/universal.lua'), 'universal')()
	local universalModules = getCreatedModules(beforeUniversal)

	if supportedGame and hasGameFile then
		loadstring(readfile(gameFile), tostring(game.PlaceId))(...)
		removeUniversalModules(universalModules)
	end

	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
