function Initialize()
	filePath = SELF:GetOption('JSONFile')
	setMeter = SELF:GetOption('SetMeter','false'):lower() == 'true' and true or false
	getKeybind = SELF:GetOption('GetKeybind','false'):lower() == 'true' and true or false
	avaDownload = SELF:GetOption('AvatarDownload','false'):lower() == 'true' and true or false
	--You can set higher if you want but also set same value for same name variable in DiscordForRainmeter.plugin.js
	--And make sure you have enough meters that display these value.
	MaximumDmUserReturn = 2
end

tempPic = {'',''}
varTable = {}
function Update()
	local file = io.open(filePath,'r')
	local content = file:read('*a')
	file:close()
	content = string.gsub(content,"    ","")
	
	for k,v in content:gmatch('"(.-)": (.-),?\n') do
		SKIN:Bang('[!SetVariable Discord_'..k..' '..v..']')
		varTable[k] = v
	end
	if setMeter then
		SetMeter()
	end
end

function SetMeter()
	local currVar = ''

	for i = 0, MaximumDmUserReturn-1 do
		currVar = varTable['User_'..i..'_DMCount']
		SKIN:Bang('[!HideMeterGroup User'..i..']')
		if currVar then
			currVar = tonumber(currVar)
			if currVar > 0 then
				SKIN:Bang('[!ShowMeterGroup User'..i..']'
						..'[!SetOption DiscordStatus_User_'..i..'_DMCount Text "'..currVar..'"]'
						..'[!SetOption DiscordStatus_User_'..i..'_Name Text '..varTable['User_'..i..'_Name']..']')
				if avaDownload then
					if varTable['User_'..i..'_AvatarLink'] ~= tempPic[i] then
						--Force Webparser to download user pic 
						SKIN:Bang('[!UpdateMeasure DiscordUser'..i..'PicDownload][!CommandMeasure DiscordUser'..i..'PicDownload "Update"]')
						tempPic[i] = varTable['User_'..i..'_AvatarLink']
					end
				end
			end
		end
	end

	currVar = tonumber(varTable['Total_GuildUnread'])
	if currVar > 0 then
		SKIN:Bang('[!ShowMeter DiscordStatus_Total_GuildUnread][!SetOption DiscordStatus_Total_GuildUnread Text "'..currVar..' guild'..(currVar > 1 and 's ' or ' ')..'unread"]')
	else
		SKIN:Bang('[!HideMeter DiscordStatus_Total_GuildUnread]')
	end

	currVar = tonumber(varTable['Friend_Online'])
	if currVar > 0 then
		SKIN:Bang('[!ShowMeter DiscordStatus_FriendOnline][!SetOption DiscordStatus_FriendOnline Text "'..currVar..' friend'..(currVar > 1 and 's ' or ' ')..'online"]')
	else
		SKIN:Bang('!HideMeter DiscordStatus_FriendOnline')
	end

	currVar = string.gsub(varTable['Microphone']:lower(),'"','')
	SKIN:Bang('[!SetOption DiscordStatus_Microphone ImageName "#ROOTCONFIGPATH#Themes\\#Theme#\\Additional_Comps_And_Scripts\\mic'..currVar..'.png"]'
			..'[!SetOption DiscordStatus_MicHead_Shape ColorMic "Fill Color '..(currVar == 'muted' and 'f04747' or '43b581')..'"]')

	currVar = string.gsub(varTable['Headphone']:lower(),'"','')
	SKIN:Bang('[!SetOption DiscordStatus_Headphone ImageName "#ROOTCONFIGPATH#Themes\\#Theme#\\Additional_Comps_And_Scripts\\head'..currVar..'.png"]'
			..'[!SetOption DiscordStatus_MicHead_Shape ColorHead "Fill Color '..(currVar == 'deafed' and 'f04747' or '43b581')..'"]')

	currVar = varTable['Voice_Status']
	if currVar ~= '' then
		SKIN:Bang('[!ShowMeterGroup Voice][!SetOption DiscordStatus_VoiceConnect Text '..string.sub(currVar, 2, 2):upper()..string.sub(currVar, 3)..']')

		currVar = varTable['Voice_Quality']
		SKIN:Bang('!SetOption DiscordStatus_VoiceConnect FontColor "'..(currVar == '"bad"' and 'f04747' or (currVar == '"average"' and 'faa61a' or '43b581'))..'"')
		SKIN:Bang('!SetOption DiscordStatus_VoiceConnect ToolTipText '..string.sub(currVar, 2, 2):upper()..string.sub(currVar, 3)..'')
	
		SKIN:Bang('!SetOption DiscordStatus_VoiceChannel Text '..varTable['Voice_Channel']..'')
	else
		SKIN:Bang('!HideMeterGroup Voice')
	end

	if getKeybind then
		SKIN:Bang('!SetVariable Discord_Toggle_Mute_AHK "'..KeyBindTranslator(varTable['Toggle_Mute_Keybind'])..'"')
		SKIN:Bang('!SetVariable Discord_Toggle_Deaf_AHK "'..KeyBindTranslator(varTable['Toggle_Deaf_Keybind'])..'"')
	end
end

weirdkeyModifier={	["(numpad) (%d)"]	="{Numpad%2}",
					["numpad  %+"]		="{NumpadAdd}",
					["numpad %-"]		="{NumpadSub}",
					["numpad %*"]		="{NumpadMult}",
					["numpad %."]		="{NumpadDot}",
					["numpad /"]		="{NumpadDiv}",
					["numpad clear"]	="{NumLock}",
					["right shift"]		="{RShift}",
					["right alt"]		="{RAlt}",
					["right ctrl"]		="{RCtrl}",
					["right meta"]		="{AppsKey}",
					["capslock"]		="{CapsLock}",
					["scroll lock"]		="{ScrollLock}",
					["print screen"]	="{PrintScreen}",
					["(f)(%d)"]			="{F%2}",
					["pagedown"]		="{PgDn}",
					["pageup"]			="{PgUp}"}

titleCaseKeyModifier={"left","right","up","down","backspace","del","insert","home","end","tab","enter","esc"} 

convertTitleCase =	function(s)
						for _,v in pairs(titleCaseKeyModifier) do
							for f in s:gmatch(v) do
								s = string.gsub(s, f, function(d) return '{'..string.sub(d, 1, 1):upper()..string.sub(d, 2)..'}' end)
							end
						end
						return s
					end

keyModifier={	["alt"]="!",
				["ctrl"]="^",
				["meta"]="#"
			}
function KeyBindTranslator(keybind)
	local keyTable = {}
	keybind = keybind:lower()
	for k,v in pairs(weirdkeyModifier) do
		keybind = string.gsub(keybind,k,v)
	end

	keybind = convertTitleCase(keybind)
	
	local ahk =""
	for key in keybind:gmatch('[^ \+ ]+') do
		for k,v in pairs(keyModifier) do
			key = string.gsub(key,k,v)
		end
		ahk = ahk..key
	end
	ahk = string.gsub(string.gsub(ahk,"shift","+"),'"','') --Cause modifier of shift button is `+` , so let sub it outside just to be sure it doesnt mess up with our pattern inside loop
	return ahk
end
