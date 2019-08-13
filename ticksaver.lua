require("table")

function OnInit()	-- ������� - ������������� QUIK
	file_log = io.open("ticksaver_" .. os.date("%Y%m%d_%H%M%S") .. ".log", "w")
	PrintDbgStr("ticksaver: ������� - ������������� QUIK")
	file_log:write(os.date() .. " ticksaver ������� (�������������)\n")
	load_error = false
	instrname = {}
	instrfile = {}
	instrclass = {}
	file_ini = io.open(getScriptPath() .. "\\ticksaver.ini", "r")
	if file_ini ~= nil then
		for instr_name, instr_class in string.gmatch(file_ini:read("*a"), "(%w+) (%w+)") do
			instrname[#instrname + 1] = instr_name
			instrfile[#instrfile + 1] = io.open(string.format("%s_%s.csv", instr_name, os.date("%Y%m%d_%H%M%S")), "w")
			instrclass[#instrclass + 1]  = instr_class
			PrintDbgStr(string.format("ticksaver: ������ ticksaver.ini. ����������: %s �����: %s", instr_name, instr_class))
			file_log:write(string.format("%s ������ ticksaver.ini. ����������: %s �����: %s\n", os.date(), instr_name, instr_class))		
			local request_result = ParamRequest(instr_class, instr_name, "LAST")
			if request_result then
				PrintDbgStr("ticksaver: �� ����������� " .. instr_name .. " ������� ������� �������� LAST")
				file_log:write(os.date() .. " �� ����������� " .. instr_name .. " ������� ������� �������� LAST\n")
			else
				PrintDbgStr("ticksaver: ������ ��������� ��������� LAST �� ����������� " .. instr_name)
				file_log:write(os.date() .. " ������ ��������� ��������� LAST �� ����������� " .. instr_name .. "\n")
			end
		end
		file_ini:close()
	else
		load_error = true
		message("ticksaver: ������ �������� ticksaver.ini")
		PrintDbgStr("ticksaver: ������ �������� ticksaver.ini")
		file_log:write(os.date() .. "ticksaver: ������ �������� ticksaver.ini\n")		--instr_name = "BRQ9"; instr_class = "SPBFUT";	oder_interval = 5	
		return false
	end
end

function OnParam(class, sec)
	for ind = 1, #instrname do
		if class == instrclass[ind] and sec == instrname[ind] then
			res = getParamEx(class, sec, "LAST")
			if res ~= 0 then
				PrintDbgStr(string.format("ticksaver: %s: %.2f", sec, res.param_value))
				if instrfile[ind] ~= nil then
					instrfile[ind]:write(string.format("%s,%.2f\n", os.date("%X",os.time()), res.param_value))
				else
					file_log:write(string.format("%s %s: %.2f\n", os.date(), sec, res.param_value))
				end
			end
			break
		end
	end
end

function OnClose()	-- ������� - �������� ��������� QUIK
	file_log:write(os.date() .. " ������� - �������� ��������� QUIK\n")
	exit_mess()
	return 0
end

function OnStop(flag)	-- ������� - ��������� �������
	file_log:write(os.date() .. " ������� - ��������� �������\n")
	exit_mess()
	return 0
end

function exit_mess()
	for ind, inst_name in pairs(instrname) do
		CancelParamRequest(instrclass[ind], inst_name, "LAST")
		instrfile[ind]:close()
	end
	PrintDbgStr("ticksaver: ticksaver ��������")
	file_log:write(os.date() .. " ticksaver ��������\n")
	file_log:close()
end

function main()
	if load_error then
		return false
	end	
	if isConnected() then
		PrintDbgStr("ticksaver: QUIK ��������� � �������")
		file_log:write(os.date() .. " QUIK ��������� � �������\n")
	else
		PrintDbgStr("ticksaver: QUIK �������� �� �������")
		exit_mess()
		return false
	end
	
	while true do
		sleep(1000)
	end
	exit_mess()
end
