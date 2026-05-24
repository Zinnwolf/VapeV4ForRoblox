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

local function snapshotModules()
	local modules = {}
	if vape and vape.Modules then
		for name, module in vape.Modules do
			modules[name] = module
		end
	end
	return modules
end

local function getNewModules(before)
	local names = {}
	if vape and vape.Modules then
		for name in vape.Modules do
			if before[name] == nil then
				table.insert(names, name)
			end
		end
	end
	return names
end

local function removeModules(names)
	for _, name in names do
		pcall(function()
			if vape and vape.Remove then
				vape:Remove(name)
			elseif vape and vape.Modules and vape.Modules[name] then
				local module = vape.Modules[name]
				if module.Toggle and module.Enabled then
					module:Toggle()
				end
				if module.Clean then
					module:Clean()
				end
				vape.Modules[name] = nil
			end
		end)
	end
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

	local beforeUniversal = snapshotModules()
	loadstring(downloadFile('newvape/games/universal.lua'), 'universal')()
	local universalModules = getNewModules(beforeUniversal)

	if hasGameFile then
		removeModules(universalModules)
		loadstring(readfile(gameFile), tostring(game.PlaceId))(...)
	end

	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
