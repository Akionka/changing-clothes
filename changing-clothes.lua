script_name('Changing Clothes')
script_author('akionka')
script_version('1.0')
script_version_number(1)
script_description([[{FFFFFF}Данный скрипт разработан Akionka с использованием идей коммьюнити Trinity GTA.
Скрипт умеет:
 - Снимать ваш текущий скин, а после надевать его.

Кстати, список команд:
/wear | /unwear | /wearinv ]])
script_properties("forced-reloading-only")

local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local inicfg = require 'inicfg'
encoding.default = 'cp1251'
u8 = encoding.UTF8
local wear = false
local unwear = 0
local ini = inicfg.load({
  settings =
  {
    command = "/invex"
  },
}, "changing-clothes")

function sampev.onShowDialog(id, style, cap, b1, b2, text)
	if id == 1000 and unwear == 1 then
		local i = 0
		for item in text:gmatch("[^\r\n]+") do
			i = i + 1
			if item:find(u8:decode("Костюм #%d+ .+")) ~= nil
				then sampSendDialogResponse(id, 1, i-1, "")
				unwear = 2 return false
			end
		end
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
				if item:find(u8:decode("Костюм #"..lastskin)) ~= nil
					then sampSendDialogResponse(id, 1, i-1, "") return false
				end
			else
				if item:find(u8:decode("Костюм #%d+")) ~= nil
					then sampSendDialogResponse(id, 1, i-1, "") return false
				end
			end
		end 
		local i = 0
		for item in text:gmatch("[^\r\n]+") do
			i = i + 1
			if item:find(u8:decode("Костюм #%d+")) ~= nil
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
	sampRegisterChatCommand("unwear", function() lastskin = getCharModel(PLAYER_PED) sampSendChat(ini.settings.command)  unwear = 1 end)
	sampRegisterChatCommand("wear", function () sampSendChat(ini.settings.command) wear = true end)
	sampRegisterChatCommand("wearinv", function () if ini.settings.command == "/invex" then ini.settings.command = "/inv"
	else ini.settings.command = "/invex"  end sampAddChatMessage(u8:decode("[CS]: Теперь для вызова инвентаря используется команда {2980b9}"..ini.settings.command.."{FFFFFF}."), -1) end)
end
