script_name('SIXTEEN') 
script_author('clain.txt') 

require 'lib.moonloader'
local dlstatus = require('moonloader').download_status
-- �������� ����������
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
-- � ��������+
local bNotf, notf = pcall(import, "imgui_notf.lua")
local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
--
-- ������� ����������
status = false
--
-- ������ ����������
directIni = 'nvsettings'
config = inicfg.load(nil, directIni)
-- Update system
update_state = false

local script_vers = 1
local script_vers_text = "1.05"

local update_url = "https://raw.githubusercontent.com/ClainTxt/scripts/main/update.ini" -- ��� ���� ���� ������
local update_path = getWorkingDirectory() .. "/update.ini" -- � ��� ���� ������

local script_url = "" -- ��� ���� ������
local script_path = thisScript().path

--
-- ����� ����������
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
-- ������� �����������, ��� ����
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
encoding.default = 'CP1251' -- �������� ��������� �� �������
u8 = encoding.UTF8 -- ����� ������ ��������� � ����
function main() -- ������� ������� �����
	repeat wait(0) until isSampAvailable()	
	-- ����������� ��� ����� ���� �������
	msgChat("��������� /thelp")
	sampRegisterChatCommand('thelp', function() 
		msgChat("1. /imenu - ��������� �������")
		msgChat("2. /checkanim - ���/���� �������� ������")
		msgChat("3. /laa - ���/���� ������ (Y)")
		msgChat("������� ���� ������� �� F4")
		msgChat("���� �������� �� X")
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
					msgChat("���� ����������! ������: " .. updateIni.info.vers_text)
					update_state = true
			end
			os.remove(update_path)
		end
	end)
	while true do
		-- ����������� ���������� ���� ���� �������
		wait(0)
		-- auto update 
		if update_state then
			downloadUrlToFile(update_url, update_path,function(id, status) 
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					msgChat("������ ������� ��������")
					thisScript():reload()
				end
			end)
			break 
		end
		--
		if testCheat('REL') then -- ���� ������ ������ �� ������� ��� HESOYAM ������������ ������
			scriptReload()
		end
		if testCheat('ADM') then
			sampSendChat("/admins")
		end
		if isKeyJustPressed(VK_F4) then -- �������� ���� ������� �� �4
			main_window_state.v = not main_window_state.v
			imgui.Process = main_window_state.v
		end
		if isKeyJustPressed(VK_X) then -- ���� �� �
			clearCharTasksImmediately(PLAYER_PED) 
			setPlayerControl(playerHandle, 1) 
			freezeCharPosition(PLAYER_PED, false) 
			--restoreCameraJumpcut() -- ��� ��������� ������ ����������
		end
		if status then
			if isKeyDown(VK_Y) then -- ��� ��� �������� ��� �� � /laa
				setGameKeyState(14, 64) -- (11,64) Y (21) alt
				wait(50)
				setGameKeyState(14, 0)
			end
		end
	end
end
function imgui.BeforeDrawFrame() -- ���������� ������
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/lib/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
    end
end
function imgui.OnDrawFrame() -- ����� ����� �������
    local sw, sy = getScreenResolution() -- ������� ������
    if not main_window_state.v then imgui.Process = false end
	if main_window_state.v then
		imgui.SetNextWindowSize(imgui.ImVec2(500, 300), imgui.Cond.FirstUseEver) 
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8" .SIXTEEN ��������� �������", main_window_state, imgui.WindowFlags.NoResize+imgui.WindowFlags.NoCollapse )
			imgui.PushItemWidth(60)
			imgui.InputText(u8'��� ���� ������', text_buffer)
			imgui.SameLine()
			if imgui.Button(''..fa.ICON_FA_USER_PLUS, imgui.ImVec2(40, 20)) then
				if config.hide.nick ~= text_buffer.v then 
					config.hide.nick = text_buffer.v
					if inicfg.save(config, directIni) then msgChat("��� ��������") end
				else msgChat("���� ��� � ��� � ����") end
			end
			imgui.Separator()
			imgui.Checkbox(fa.ICON_FA_COMMENT .. u8' ����� ���������', nvstatus)
			if nvstatus then 
				imgui.Checkbox(fa.ICON_FA_ANGLE_DOUBLE_RIGHT ..u8' ������� �� /ads', adsstatus)
				imgui.Checkbox(fa.ICON_FA_ANGLE_DOUBLE_RIGHT ..u8' ������� �� /ask', askstatus)
				imgui.Checkbox(fa.ICON_FA_ANGLE_DOUBLE_RIGHT ..u8' ������� �� !', gchatstatus)	
			end
			if imgui.Button(fa.ICON_FA_CLOUD_DOWNLOAD_ALT .. u8' ��������� ���������', imgui.ImVec2(155, 30)) then
				config.settings.nvstatus = nvstatus.v
				config.settings.adsstatus = adsstatus.v
				config.settings.askstatus = askstatus.v
				config.settings.gchatstatus = gchatstatus.v
				if inicfg.save(config, directIni) then msgChat("��������� ������� ���������") end
			end
			imgui.SetCursorPos(imgui.ImVec2(290, 60))
			imgui.BeginChild(u8'Auto-��������', imgui.ImVec2(200, 123), true)
				local x,y,z = getCharCoordinates(PLAYER_PED)
				imgui.SetCursorPosX(5)
				imgui.Text(u8"����������: " .. math.floor(x) .. " " .. math.floor(y) .. " " .. math.floor(z))
				imgui.Combo(u8'����', combo_dada, themes.colorThemes, #themes.colorThemes) 
				if imgui.Button(fa.ICON_FA_PLAY .. "", imgui.ImVec2(50, 20)) then
					themes.SwitchColorTheme(combo_dada.v +1)
					config.settings.themeselected = combo_dada.v+1
					if inicfg.save(config, directIni) then 
						if bNotf then
							notf.addNotification("���� ��������! ", 3, 1)
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
		sampAddChatMessage(nv.."�� �� ������ {33EA0D}ON", -1)
	else
		sampAddChatMessage(nv.."�� �� ������ {F51111}OFF", -1)
	end
	config.settings.checkanim = checkanim
	inicfg.save(config, directIni)
end
function sampev.onApplyPlayerAnimation(playerId, animLib, animName, loop, lockX, lockY, freeze, time)
	if checkanim then
		msgChat("����������: "..animLib)
		msgChat("��������: "..animName)
		msgChat("����: "..tostring(freeze))
		msgChat("����: "..tostring(loop))
	end
end
function sampev.onServerMessage(color, text)
	if text:find(config.hide.nick) then 
		msgChat("������� �������, � ����� ��� ���������.")
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
		if text:find("(.*) �������: =(.*)") then
			local name, msg = text:match("(.*) �������: =(.*)")
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
				else msgChat(name .. " �������: " .. msg) sampSendChat(msg) end
			end
		end 
	end
end
function laa()
	status = not status
	if status then
		sampAddChatMessage(nv.."���� ������� {33EA0D}ON", -1)
	else
		sampAddChatMessage(nv.."���� ������� {F51111}OFF", -1)
	end
end
function scriptReload()
    thisScript():reload()
    sampAddChatMessage(nv..'������ ������������.', -1)
end
