script_name('Changing Clothes')
script_author('akionka')
script_version('1.5')
script_version_number(6)
script_description([[{FFFFFF}Данный скрипт разработан Akionka с использованием идей коммьюнити Trinity GTA.
Скрипт умеет:
 - Снимать ваш текущий скин, а после надевать его.

Кстати, список команд:
/wear | /unwear | /wearinv ]])

local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local inicfg = require 'inicfg'
local dlstatus = require('moonloader').download_status
encoding.default = 'cp1251'
u8 = encoding.UTF8
local wear = false
local unwear = 0
local close = false
local ini = inicfg.load({
  settings =
  {
    invex = true,
		last_skin = nil
  },
}, "akionka")

local states = {
	NONE = 0,
	SEARCH_SKIN = 1,
	CHOOSE_ACTION = 2,
	CLOSE_INV = 3
}
local state = {
	unwear = states.NONE,
	wear = states.NONE,
}
local ids = {
	error_too_far_away = 998,
	main_inv = 1000,
	choose_action = 1001
}
local skin = nil

function sampev.onShowDialog(id, style, cap, b1, b2, text)
	if id == ids.main_inv then
		if skin ~= nil and state.wear == states.SEARCH_SKIN then
			local i = 0
			for item in text:gmatch("[^\r\n]+") do
				i = i + 1
				if item:find(u8:decode("Костюм #"..skin)) ~= nil or item:find(u8:decode("Семейный костюм #"..skin)) ~= nil then
					sampSendDialogResponse(id, 1, i-1, "")
					state.wear = states.CHOOSE_ACTION
					skin = nil
					return false
				end
			end
		end
		if state.wear == states.SEARCH_SKIN and ini.settings.last_skin ~= nil then
			local i = 0
			for item in text:gmatch("[^\r\n]+") do
				i = i + 1
				if item:find(u8:decode("Костюм #"..ini.settings.last_skin)) ~= nil or item:find(u8:decode("Семейный костюм #"..ini.settings.last_skin)) ~= nil then
					sampSendDialogResponse(id, 1, i-1, "")
					state.wear = states.CHOOSE_ACTION
					return false
				end
			end
		end
		if state.wear == states.SEARCH_SKIN then
			local i = 0
			for item in text:gmatch("[^\r\n]+") do
				i = i + 1
				if item:find(u8:decode("Костюм #%d+")) ~= nil or item:find(u8:decode("Семейный костюм #%d+")) ~= nil then
					sampSendDialogResponse(id, 1, i-1, "")
					state.wear = states.CHOOSE_ACTION
					return false
				end
			end
		end
		if state.unwear == states.SEARCH_SKIN then
			local i = 0
			for item in text:gmatch("[^\r\n]+") do
				i = i + 1
				if item:find(u8:decode("Костюм #%d+ .+")) ~= nil or item:find(u8:decode("Семейный костюм #%d+ .+")) ~= nil then
					sampSendDialogResponse(id, 1, i-1, "")
					state.unwear = states.CLOSE_INV
					return false
				end
			end
		end
		if state.unwear == states.CLOSE_INV or state.unwear == states.CLOSE_INV then
			sampSendDialogResponse(id, 0, 0, "")
			state.wear = states.NONE
			state.unwear = states.NONE
			return false
		end
	elseif id == ids.choose_action then
		if state.wear == states.CHOOSE_ACTION then
			sampSendDialogResponse(id, 1, 5, "")
			state.wear = states.CLOSE_INV
			skin = nil
			return false
		end
	elseif id == ids.error_too_far_away then
		sampAddChatMessage(u8:decode("[CC]: {FF0000}Error!{FFFFFF} Подойдите ближе к месту для переодевания."), -1)
		state.wear = states.CLOSE_INV
		return false
	end
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(0) end
	update()
	while updateinprogess ~= false do wait(0) end
	sampRegisterChatCommand("unwear", function() ini.settings.last_skin = getCharModel(PLAYER_PED) inicfg.save(ini, "akionka") state.unwear = states.SEARCH_SKIN sampSendChat(ini.settings.invex and "/invex" or "/inv") end)
	sampRegisterChatCommand("wear", function (params)
		if tonumber(params) ~= nil then skin = tonumber(params) else skin = nil end
		state.wear = states.SEARCH_SKIN
		sampSendChat(ini.settings.invex and "/invex" or "/inv")
	end)
	sampRegisterChatCommand("wearinv", function ()
		 ini.settings.invex = not ini.settings.invex
		 sampAddChatMessage(u8:decode(ini.settings.invex and "[CC]: Теперь для вызова инвентаря используется команда {2980b9}/invex{FFFFFF}." or "[CC]: Теперь для вызова инвентаря используется команда {2980b9}/inv{FFFFFF}."), -1)
		 inicfg.save(ini, "akionka")
	  end)
end

function update()
	local fpath = os.getenv('TEMP') .. '\\CC-version.json'
	downloadUrlToFile('https://raw.githubusercontent.com/Akionka/changing-clothes/master/version.json', fpath, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local f = io.open(fpath, 'r')
			if f then
				local info = decodeJson(f:read('*a'))
				if info and info.version then
					version = info.version
					version_num = info.version_num
					if version_num > thisScript().version_num then
						sampAddChatMessage(u8:decode("[CC]: Найдено объявление. Текущая версия: {2980b9}"..thisScript().version.."{FFFFFF}, новая версия: {2980b9}"..version.."{FFFFFF}. Начинаю закачку."), -1)
						lua_thread.create(goupdate)
					else
						updateinprogess = false
					end
				end
			end
		end
	end)
end

function goupdate()
	wait(300)
	downloadUrlToFile("https://raw.githubusercontent.com/Akionka/changing-clothes/master/changing-clothes.lua", thisScript().path, function(id3, status1, p13, p23)
		if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage((u8:decode('[CC]: Новая версия установлена! Чтобы скрипт обновился нужно либо перезайти в игру, либо ...')), -1)
			sampAddChatMessage((u8:decode('[CC]: ... если у вас есть автоперезагрузка скриптов, то новая версия уже готова и снизу вы увидите приветственное сообщение.')), -1)
			sampAddChatMessage((u8:decode('[CC]: Если что-то пошло не так, то сообщите мне об этом в VK или Telegram > {2980b0}vk.com/akionka tele.run/akionka{FFFFFF}.')), -1)
		end
	end)
end
