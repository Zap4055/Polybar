function GetEssentialVariables()
	dir = tonumber(SKIN:GetVariable('Dir'))
	colGap = SKIN:ParseFormula(SKIN:GetVariable('Column_Gap'))
	rowGap = SKIN:ParseFormula(SKIN:GetVariable('Row_Gap'))
	firstDayOfWeek =tonumber(SKIN:GetVariable('Firt_Day_Of_Week'))
	edge_Gap = SKIN:ParseFormula(SKIN:GetVariable('Edge_Gap'))
	top_Gap = SKIN:ParseFormula(SKIN:GetVariable('Top_Gap'))
end

function GetDate(returnValue, year, month, day)
	if (returnValue == 't') then
		local date = os.date('*t')
		return date.year, date.month, date.day, (date.wday-1) --wday return from 1 to 7 so minus 1 to get it back to normal index 0 to 6
	else
		local value = os.date(returnValue, os.time{year = year, month = month, day = day})
		if tonumber(value) then
			return tonumber(value)
		else
			return value
		end
	end
end

function GetWeekDayLabel()
	firstDayOfMonth_Wday = GetDate('%w', cur_Year, cur_Month, 1)

	weekTable = {}
	for wDayLabel in string.gmatch(SKIN:GetVariable('Week_Day_Label'), '[^,]+') do
		weekTable[#weekTable+1] = wDayLabel
	end

	for i = 1, 7 do
		local label_Id = (i + firstDayOfWeek) % 7
		label_Id = label_Id ~= 0 and label_Id or 7
		SKIN:Bang('!SetOption', 'WeekDayName'..i, 'Text', weekTable[label_Id])
		SKIN:Bang('!SetOption', 'WeekDayName'..i, 'X', edge_Gap + (i-1)*colGap)
	end

	dayTable = {}
	for i=1,31 do
		dayTable[i] = SKIN:GetMeter('Day'..i)
	end
	
end

function drawDay(drawingYear, drawingMonth, reset)
	SetMonthAndYear()

	if reset then 
		resetShapeAndMeter()
	end
	
	local drawingDay = 1
	local drawingRow = 2
	shapeCount = 2

	while true do
		local drawingDay_wday = (GetDate('%w', drawingYear, drawingMonth, drawingDay) - firstDayOfWeek) % 7

		local xPos, yPos = (edge_Gap + drawingDay_wday * colGap), (top_Gap*(1-dir) + drawingRow * rowGap)

		SKIN:Bang('!ShowMeter', 'Day'..drawingDay)
		dayTable[drawingDay]:SetX(xPos)
		dayTable[drawingDay]:SetY(yPos)

		--Today shape
		local todayYear, todayMonth, todayDay = GetDate('t')
		if (
			todayYear == drawingYear and 
			todayMonth == drawingMonth and 
			todayDay == drawingDay 
		) then
			DrawingToday(xPos,yPos)
		end

		--Find matching schedule
		if scheduleAvailable then
			for k,v in pairs(scheduleTable) do
				if (k == drawingYear..drawingMonth..drawingDay) then
					
					DrawingScheduledDays(xPos,yPos, #scheduleTable[k])
					ClickAction(drawingDay, scheduleTable[k])
					

					--Show today event if there is one
					if k == todayYear..todayMonth..todayDay then ClickEvent('Day'..drawingDay) end

					break
				end
			end
		end

		local nextDay_day = GetDate('%d', drawingYear, drawingMonth, drawingDay+1)
		local nextDay_wday = GetDate('%w', drawingYear, drawingMonth, drawingDay+1)

		if (nextDay_wday == firstDayOfWeek) then 
			drawingRow = drawingRow + 1 
		end

		--When currently drawingDay is last day of current month, %d of (drawingDay+1) will be 1. So drawing job is done here.
		if nextDay_day == 1 then
			SKIN:Bang('!SetVariable', 'LastDay', drawingDay)
			break
		end

		drawingDay = nextDay_day
	end
end


function parseSchedule()
	local file = io.open(SKIN:ReplaceVariables('#ROOTCONFIGPATH#\\DownloadFile\\calendarSchedule.txt'),'r')
	
	if not file then return end

	local content = file:read('*a')
	scheduleTable = {}
	for event in string.gmatch(content,'BEGIN:VEVENT\n(.-)\nEND:VEVENT') do
		local eventStart = event:match('DTSTART(.-)\n')
		local eventDate = sepDate(eventStart)
		local eventId = eventDate.year..eventDate.month..eventDate.day
		scheduleTable[eventId] = scheduleTable[eventId] or {}
		table.insert(scheduleTable[eventId], {sum = event:match('SUMMARY:(.-)\n'), location = event:match('LOCATION:(.-)\n'), time = sepTime(eventStart)})
	end
	if moduleNotification then 
		SKIN:Bang('!HideMeter', notificationMeter)
		local year, month, day,_ = GetDate('t')
		for k,v in pairs(scheduleTable) do
			if (k == year..month..day) then 
				SKIN:Bang('!ShowMeter', notificationMeter)
				break
			end
		end
		return
	end
	scheduleAvailable = true
	drawDay(cur_Year,cur_Month, true)
end

function sepDate(date)
	date = date:match('(%d%d%d%d%d%d%d%d)')
	local year, month, day = string.match(date,'(%d%d%d%d)(%d%d)(%d%d)')
	return {['year'] = tonumber(year), ['month'] = tonumber(month), ['day'] = tonumber(day)}
end

function sepTime(date)
	local time = date:match('T(%d+)')
	if time then
		hour, minute = time:match('(%d%d)(%d%d)%d%d')	
	else
		hour, minute = 'null', 'null'
	end	
	return {['hour'] = hour, ['minute'] = minute}
end

function ClickAction(meter, eventTable)
	--Sort by time
	for i = 1, #eventTable do
		if #eventTable == 1 then break end
		for j = i, #eventTable do
			local iHour = eventTable[i].time.hour == 'null' and 0 or eventTable[i].time.hour
			local jHour = eventTable[j].time.hour == 'null' and 0 or eventTable[j].time.hour

			if iHour > jHour then
				eventTable[i], eventTable[j] = eventTable[j], eventTable[i]

			elseif iHour == jHour then
				if eventTable[i].time.minute > eventTable[j].time.minute then
					eventTable[i], eventTable[j] = eventTable[j], eventTable[i]
				end
			end
		end
	end
	
	local totalEvent = ''
	for i = 1, #eventTable do
		totalEvent = totalEvent .. EventTextFormat(eventTable[i], i == #eventTable)
	end

	SKIN:Bang('!SetOption', 'Day'..meter, 'LeftMouseUpAction', '!CommandMeasure CalendarViewScript "ClickEvent(\'#*CurrentSection*#\')"')
	SKIN:Bang('!SetOption', 'Day'..meter, 'EventText', totalEvent)
end

function ChangeMonth(dir)
	cur_Year, cur_Month = GetDate('%Y', cur_Year, cur_Month+dir, 1), GetDate('%m', cur_Year, cur_Month+dir, 1)
	drawDay(cur_Year,cur_Month, true)
end