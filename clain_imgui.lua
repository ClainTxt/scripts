script_name('SIXTEEN') 
script_author('clain.txt') 

require 'lib.moonloader'
local dlstatus = require('moonloader').download_status
-- Основные переменные
nv = '{ffbf00}[.nv]{ffffff} '
sampev = require "samp.events"
inicfg = require 'inicfg'
encoding = require "encoding"
keys = require 'vkeys'
ffi = require 'ffi'
imgui = require "imgui"
str = ffi.string
fa = require "fAwesome5"
--
-- К основным+
local bNotf, notf = pcall(import, "imgui_notf.lua")
local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
--
-- Булевые переменные
status = false
--
-- Конфиг переменные
directIni = 'nvsettings'
config = inicfg.load(nil, directIni)
-- Update system
update_state = false

local script_vers = 1
local script_vers_text = "1.05"

local update_url = "https://raw.githubusercontent.com/ClainTxt/scripts/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "" -- тут свою ссылку
local script_path = thisScript().path

--
-- Имгуи переменные
nvstatus = imgui.ImBool(config.settings.nvstatus)
adsstatus = imgui.ImBool(config.settings.adsstatus)
askstatus = imgui.ImBool(config.settings.askstatus)
text_buffer = imgui.ImBuffer(config.hide.nick, 256)
gchatstatus = imgui.ImBool(config.settings.gchatstatus)
themeselected = imgui.ImInt(config.settings.themeselected)
checkanim = config.settings.checkanim
main_window_state = imgui.ImBool(false)
local combo_dada = imgui.ImInt(0)
--
local themes = import "resource/imgui_themes.lua"
-- 
-- Функции необходимые, для меня
function msgChat(msg) 
	sampAddChatMessage(nv..' '..msg, 0xFFFFFF)
end
function sampGetPlayerIdByNickname(nick)
	nick = tostring(nick)
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if nick == sampGetPlayerNickname(myid) then return myid end
	for i = 0, 1003 do
	  if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
		return i
	  end
	end
end
--
encoding.default = 'CP1251' -- Изменяем кодировку по дефолту
u8 = encoding.UTF8 -- Будем менять кодировку в коде
function main() -- Главная функция сампа
	repeat wait(0) until isSampAvailable()	
	-- Выполняется раз когда самп запущен
	msgChat("Используй /thelp")
	sampRegisterChatCommand('thelp', function() 
		msgChat("1. /imenu - Настройки скрипта")
		msgChat("2. /checkanim - Вкл/Выкл просмотр анимок")
		msgChat("3. /laa - Вкл/Выкл кликер (Y)")
		msgChat("Открыть меню скрипта на F4")
		msgChat("Сбив анимаций на X")
	end)
	sampRegisterChatCommand('imenu', function()
		main_window_state.v = not main_window_state.v
		imgui.Process = main_window_state.v
	end)
	sampRegisterChatCommand('laa', laa)
	sampRegisterChatCommand('checkanim', checkanim)
	imgui.SwitchContext()
	themes.SwitchColorTheme(config.settings.themeselected)
	downloadUrlToFile(update_url, update_path,function(id, status) 
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updateIni = inicfg.load(nil,update_path)
			if tonumber(updateIni.info.vers) > script_vers then
					msgChat("Есть обновление! Версия: " .. updateIni.info.vers_text)
					update_state = true
			end
			os.remove(update_path)
		end
	end)
	while true do
		-- Выполняется бесконечно пока самп активен
		wait(0)
		-- auto update 
		if update_state then
			downloadUrlToFile(update_url, update_path,function(id, status) 
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					msgChat("Скрипт успешно обновлен")
					thisScript():reload()
				end
			end)
			break 
		end
		--
		if testCheat('REL') then -- Если нажать кнопки по очереди как HESOYAM перезагрузим скрипт
			scriptReload()
		end
		if testCheat('ADM') then
			sampSendChat("/admins")
		end
		if isKeyJustPressed(VK_F4) then -- Вызываем меню скрипта на Ф4
			main_window_state.v = not main_window_state.v
			imgui.Process = main_window_state.v
		end
		if isKeyJustPressed(VK_X) then -- Сбив на Х
			clearCharTasksImmediately(PLAYER_PED) 
			setPlayerControl(playerHandle, 1) 
			freezeCharPosition(PLAYER_PED, false) 
			--restoreCameraJumpcut() -- Это положение камеры сбрасывает
		end
		if status then
			if isKeyDown(VK_Y) then -- Это для кликеров где на У /laa
				setGameKeyState(14, 64) -- (11,64) Y (21) alt
				wait(50)
				setGameKeyState(14, 0)
			end
		end
	end
end
function imgui.BeforeDrawFrame() -- Подключаем иконки
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/lib/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
    end
end
function imgui.OnDrawFrame() -- Когда имгуи запущен
    local sw, sy = getScreenResolution() -- Позиция экрана
    if not main_window_state.v then imgui.Process = false end
	if main_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.FirstUseEver) 
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8" .SIXTEEN Настройки скрипта", main_window_state, imgui.WindowFlags.NoResize+imgui.WindowFlags.NoCollapse )
			imgui.PushItemWidth(60)
			imgui.InputText(u8'Ник кого скрыть', text_buffer)
			imgui.SameLine()
			if imgui.Button(''..fa.ICON_FA_USER_PLUS, imgui.ImVec2(40, 20)) then
				if config.hide.nick ~= text_buffer.v then 
					config.hide.nick = text_buffer.v
					if inicfg.save(config, directIni) then msgChat("Ник сохранен") end
				else msgChat("Этот ник и так в базе") end
			end
			imgui.Separator()
			imgui.Checkbox(fa.ICON_FA_COMMENT .. u8' Прием сообщений', nvstatus)
			if nvstatus then 
				imgui.Checkbox(fa.ICON_FA_ANGLE_DOUBLE_RIGHT ..u8' Реакция на /ads', adsstatus)
				imgui.Checkbox(fa.ICON_FA_ANGLE_DOUBLE_RIGHT ..u8' Реакция на /ask', askstatus)
				imgui.Checkbox(fa.ICON_FA_ANGLE_DOUBLE_RIGHT ..u8' Реакция на !', gchatstatus)	
			end
			if imgui.Button(fa.ICON_FA_CLOUD_DOWNLOAD_ALT .. u8' Сохранить настройки', imgui.ImVec2(155, 30)) then
				config.settings.nvstatus = nvstatus.v
				config.settings.adsstatus = adsstatus.v
				config.settings.askstatus = askstatus.v
				config.settings.gchatstatus = gchatstatus.v
				if inicfg.save(config, directIni) then msgChat("Настройки успешно сохранены") end
			end
			imgui.SetCursorPos(imgui.ImVec2(290, 60))
			imgui.BeginChild(u8'Auto-Отправка', imgui.ImVec2(200, 123), true)
				local x,y,z = getCharCoordinates(PLAYER_PED)
				imgui.SetCursorPosX(5)
				imgui.Text(u8"Координаты: " .. math.floor(x) .. " " .. math.floor(y) .. " " .. math.floor(z))
				imgui.Combo(u8'Темы', combo_dada, themes.colorThemes, #themes.colorThemes) 
				if imgui.Button(fa.ICON_FA_PLAY .. "", imgui.ImVec2(50, 20)) then
					themes.SwitchColorTheme(combo_dada.v +1)
					config.settings.themeselected = combo_dada.v+1
					if inicfg.save(config, directIni) then 
						if bNotf then
							notf.addNotification("Тема изменена! ", 3, 1)
						end 
					end
				end
			imgui.EndChild()
		imgui.End()	
	end
end
function checkanim()
	checkanim = not checkanim
	if checkanim then
		sampAddChatMessage(nv.."че за анимка {33EA0D}ON", -1)
	else
		sampAddChatMessage(nv.."че за анимка {F51111}OFF", -1)
	end
	config.settings.checkanim = checkanim
	inicfg.save(config, directIni)
end
function sampev.onApplyPlayerAnimation(playerId, animLib, animName, loop, lockX, lockY, freeze, time)
	if checkanim then
		msgChat("Библиотека: "..animLib)
		msgChat("Название: "..animName)
		msgChat("Фриз: "..tostring(freeze))
		msgChat("Цикл: "..tostring(loop))
	end
end
function sampev.onServerMessage(color, text)
	if text:find(config.hide.nick) then 
		msgChat("Чмошник замечен, я скрыл его сообщения.")
		return false
	end
	if text:find("YNTAX]:%{......%}.*%/style") then return false end
	--[[ 
	
	GLOBAL CHAT --

	if text:find("^.*%(%d+%)%:.*") then -- hunk(19): Text
		local n, i, m = text:match("^(.*)%((%d+)%)%:(.*)")
		msgChat(n .. " " .. i .. " " .. m)
	end

	-- GLOBAL CHAT
	
	
	]]
	if nvstatus.v then 
		if text:find("(.*) говорит: =(.*)") then
			local name, msg = text:match("(.*) говорит: =(.*)")
			if msg:find("!") and gchatstatus.v then
				sampSendChat(msg)
				return true
			elseif msg:find("/ads") and adsstatus.v then
				sampSendChat(msg)
				return true
			elseif msg:find("/ask") and askstatus.v then
				sampSendChat(msg)
				return true
			else
				if msg:find("!") and not gchatstatus.v then return true
				elseif msg:find("/ads") and not adsstatus.v then return true
				elseif msg:find("/ask") and not askstatus.v then return true 
				else msgChat(name .. " говорит: " .. msg) sampSendChat(msg) end
			end
		end 
	end
end
function laa()
	status = not status
	if status then
		sampAddChatMessage(nv.."авто нажатие {33EA0D}ON", -1)
	else
		sampAddChatMessage(nv.."авто нажатие {F51111}OFF", -1)
	end
end
function scriptReload()
    thisScript():reload()
    sampAddChatMessage(nv..'Скрипт перезагружен.', -1)
end
