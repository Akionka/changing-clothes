script_name('Changing Clothes')
script_author('akionka')
script_version('1.7')
script_version_number(8)

local sampev   = require 'lib.samp.events'
local encoding = require 'encoding'
local inicfg   = require 'inicfg'
local dlstatus = require('moonloader').download_status
encoding.default = 'cp1251'
u8 = encoding.UTF8
local updatesavaliable = false
local wear   = false
local unwear = 0
local close  = false
local ini = inicfg.load({
  settings =
  {
    invex   = true,
    last_skin = nil
  },
}, "akionka")

local states = {
  NONE          = 0,
  SEARCH_SKIN   = 1,
  CHOOSE_ACTION = 2,
  CLOSE_INV     = 3
}
local state = {
  unwear = states.NONE,
  wear   = states.NONE,
}
local ids = {
  error_too_far_away = 998,
  main_inv           = 1000,
  choose_action      = 1001
}
local skin = nil

function sampev.onShowDialog(id, _, _, _, _, text)
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
      state.wear   = states.NONE
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
    if state.unwear == states.SEARCH_SKIN or state.wear == states.CHOOSE_ACTION then
      sampAddChatMessage(u8:decode("[CC]: {FF0000}Error!{FFFFFF} Подойдите ближе к месту для переодевания."), -1)
      state.wear   = states.CLOSE_INV
      state.unwear = states.CLOSE_INV
      return false
    end
  end
end

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(0) end

  sampRegisterChatCommand("unwear", function()
    ini.settings.last_skin = getCharModel(PLAYER_PED)
    inicfg.save(ini, "akionka")
    state.unwear = states.SEARCH_SKIN sampSendChat(ini.settings.invex and "/invex" or "/inv")
  end)


  sampRegisterChatCommand("wear", function (params)
    if tonumber(params) ~= nil then
      skin = tonumber(params)
    else
      skin = nil
    end
    state.wear = states.SEARCH_SKIN
    sampSendChat(ini.settings.invex and "/invex" or "/inv")
  end)

  sampRegisterChatCommand("wearinv", function ()
     ini.settings.invex = not ini.settings.invex
     sampAddChatMessage(u8:decode(ini.settings.invex and "[CC]: Теперь для вызова инвентаря используется команда {2980b9}/invex{FFFFFF}." or "[CC]: Теперь для вызова инвентаря используется команда {2980b9}/inv{FFFFFF}."), -1)
     inicfg.save(ini, "akionka")
  end)

  sampRegisterChatCommand('cccheck', function()
    checkupdates('https://raw.githubusercontent.com/Akionka/changing-clothes/master/version.json')
  end)

  sampRegisterChatCommand('ccupdate', function()
    if updatesavaliable then
      update('https://raw.githubusercontent.com/Akionka/changing-clothes/master/changing-clothes.lua')
    end
  end)
end

function checkupdates(json)
  local fpath = os.getenv('TEMP')..'\\'..thisScript().name..'-version.json'
  if doesFileExist(fpath) then os.remove(fpath) end
  downloadUrlToFile(json, fpath, function(_, status, _, _)
    if status == dlstatus.STATUSEX_ENDDOWNLOAD then
      if doesFileExist(fpath) then
        local f = io.open(fpath, 'r')
        if f then
          local info = decodeJson(f:read('*a'))
          local updateversion = info.version_num
          f:close()
          os.remove(fpath)
          if updateversion > thisScript().version_num then
            updatesavaliable = true
            sampAddChatMessage(u8:decode("[CC]: Найдено объявление. Текущая версия: {2980b9}"..thisScript().version.."{FFFFFF}, новая версия: {2980b9}"..updateversion.."{FFFFFF}."), -1)
            return true
          else
            updatesavaliable = false
            sampAddChatMessage(u8:decode("[CC]: У вас установлена самая свежая версия скрипта."), -1)
          end
        else
          updatesavaliable = false
          sampAddChatMessage(u8:decode("[CC]: Что-то пошло не так, упс. Попробуйте позже."), -1)
        end
      end
    end
  end)
end

function update(url)
  downloadUrlToFile(url, thisScript().path, function(_, status1, _, _)
    if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
      sampAddChatMessage(u8:decode('[CC]: Новая версия установлена! Чтобы скрипт обновился нужно либо перезайти в игру, либо ...'), -1)
      sampAddChatMessage(u8:decode('[CC]: ... если у вас есть автоперезагрузка скриптов, то новая версия уже готова и снизу вы увидите приветственное сообщение.'), -1)
      sampAddChatMessage(u8:decode('[CC]: Если что-то пошло не так, то сообщите мне об этом в VK или Telegram > {2980b0}vk.com/akionka teleg.run/akionka{FFFFFF}.'), -1)
      thisScript():reload()
    end
  end)
end
