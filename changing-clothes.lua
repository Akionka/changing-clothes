script_name('Changing Clothes')
script_author('akionka')
script_version('1.2')
script_version_number(3)
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
    invex = true
  },
}, "akionka")

function sampev.onShowDialog(id, style, cap, b1, b2, text)
	if id == 1000 and unwear == 1 then
		local i = 0
		for item in text:gmatch("[^\r\n]+") do
			i = i + 1
			if item:find(u8:decode("Костюм #%d+ .+")) ~= nil or item:find(u8:decode("Семейный костюм #%d+ .+")) ~= nil
				then sampSendDialogResponse(id, 1, i-1, "")
				unwear = 2 return false
			end
		end
	end
  if close and id == 1000 then
		sampSendDialogResponse(id, 0, 0, "")
		sampAddChatMessage(u8:decode("[MED]: {FF0000}Error!{FFFFFF} Подойдите ближе к месту для переодевания."), -1)
    close = false
    return false
  end
	if id == 998 and (unwear ~= 0 or wear == true) then
		sampSendDialogResponse(id, 1, 0, "")
    close = true
    wear = false
    unwear = 0
		return false
	end
	if id == 1000 and unwear == 2 then
		sampSendDialogResponse(id, 0, 0, "")
		unwear = 0
		return false
	end
	if id == 1000 and wear then
		local i = 0
		for item in text:gmatch("[^\r\n]+") do
			i = i + 1
			if lastskin ~= nil then
				if item:find(u8:decode("Костюм #"..lastskin)) ~= nil or item:find(u8:decode("Семейный костюм #"..lastskin)) ~= nil
					then sampSendDialogResponse(id, 1, i-1, "") return false
				end
			else
				if item:find(u8:decode("Костюм #%d+")) ~= nil or item:find(u8:decode("Семейный костюм #%d+")) ~= nil
					then sampSendDialogResponse(id, 1, i-1, "") return false
				end
			end
		end
		local i = 0
		for item in text:gmatch("[^\r\n]+") do
			i = i + 1
			if item:find(u8:decode("Костюм #%d+")) ~= nil or item:find(u8:decode("Семейный костюм #%d+")) ~= nil
				then sampSendDialogResponse(id, 1, i-1, "") return false
			end
		end
	end
	if id == 1001 and wear then
		sampSendDialogResponse(id, 1, 5, "")
		wear = false
		lastskin = nil
		return false
	end
	return true
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(0) end
	update()
	while updateinprogess ~= false do wait(0) end
	sampRegisterChatCommand("unwear", function() lastskin = getCharModel(PLAYER_PED) sampSendChat(ini.settings.invex and "/invex" or "/inv")  unwear = 1 end)
	sampRegisterChatCommand("wear", function () sampSendChat(ini.settings.invex and "/invex" or "/inv") wear = true end)
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
