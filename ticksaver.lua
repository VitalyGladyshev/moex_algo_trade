-- ticksaver
version = 1.22

-- �������������� ���������
script_name = "ticksaver"
log_file_name = "ticksaver.log"
ini_file_name = "ticksaver.ini"

function OnInit()	-- ������� - ������������� QUIK
	PrintDbgStr(string.format("%s ������ %5.2f: ������� - ������������� QUIK", script_name, version))
	scr_path = getScriptPath()
	log_dir_path = scr_path .. "\\logs\\"
	data_dir_path = scr_path .. "\\data\\"
	local ok, err, code = os.rename(log_dir_path, log_dir_path)
	if not ok then
		os.execute("mkdir logs")
		PrintDbgStr(string.format("%s ������ ���������� logs", script_name))
	end
	ok, err, code = os.rename(data_dir_path, data_dir_path)
	if not ok then
		os.execute("mkdir data")
		PrintDbgStr(string.format("%s ������ ���������� data", script_name))
	end
	file_log = io.open(log_dir_path .. os.date("%Y%m%d_%H%M%S") .. "_" .. log_file_name, "w")
	file_log:write(string.format("%s %s ������ %05.3f ������� (�������������)\n", os.date(), script_name, version))

	load_error = false
	instrname = {}
	instrfile = {}
	instrclass = {}
	f_last_price = 0
	s_last_price = 0
	local cnt = 0
	file_ini = io.open(scr_path .. "\\" .. ini_file_name, "r")
	if file_ini ~= nil then
		diff = file_ini:read("*l")
		PrintDbgStr(script_name .. ": ������ " .. ini_file_name .. ". ���������� ��������: " .. diff)
		file_log:write(os.date() .. " ������ " .. ini_file_name .. ". ���������� ��������: " .. diff .. " \n")
		if tostring(diff) == "false" then
			diff = false
		else
			diff = true
		end
		for instr_name, instr_class in string.gmatch(file_ini:read("*a"), "(%w+) (%w+)") do
			instrname[#instrname + 1] = instr_name
			instrfile[#instrfile + 1] = io.open(string.format("%s%s_%s.csv", data_dir_path, instr_name, os.date("%Y%m%d_%H%M%S")), "w")
			instrclass[#instrclass + 1]  = instr_class
			PrintDbgStr(string.format("%s: ������ %s. ����������: %s �����: %s", script_name, ini_file_name, instr_name, instr_class))
			file_log:write(string.format("%s ������ %s. ����������: %s �����: %s\n", os.date(), ini_file_name, instr_name, instr_class))		
			local request_result = ParamRequest(instr_class, instr_name, "LAST")
			if request_result then
				PrintDbgStr(script_name .. ": �� ����������� " .. instr_name .. " ������� ������� �������� LAST")
				file_log:write(os.date() .. " �� ����������� " .. instr_name .. " ������� ������� �������� LAST\n")
			else
				PrintDbgStr(script_name .. ": ������ ��� ������ ��������� LAST �� ����������� " .. instr_name)
				file_log:write(os.date() .. " ������ ��� ������ ��������� LAST �� ����������� " .. instr_name .. "\n")
			end
			cnt = cnt + 1
		end
		file_ini:close()
	else
		load_error = true
		message(string.format("%s: ������ �������� %s", script_name, ini_file_name))
		PrintDbgStr(string.format("%s: ������ �������� %s", script_name, ini_file_name))
		file_log:write(os.date() .. script_name .. ": ������ �������� " .. ini_file_name .. "\n")
		return false
	end
	if cnt < 2 then
		diff = false
	end
	if diff then
		diff_file = io.open(string.format("%sdiff_%s.csv", data_dir_path, os.date("%Y%m%d_%H%M%S")), "w")
	end
end

function OnParam(class, sec)
	for ind = 1, #instrname do
		if class == instrclass[ind] and sec == instrname[ind] then
			res = getParamEx(class, sec, "LAST")
			if res ~= 0 then
				PrintDbgStr(string.format("%s: %s %s %s: %.2f", script_name, os.date("%d.%m.%Y"), os.date("%H:%M:%S"), sec, res.param_value))
				if instrfile[ind] ~= nil then
					instrfile[ind]:write(string.format("%s,%s,%s,%.2f\n", os.date("%d.%m.%Y"), os.date("%H:%M:%S"), sec, res.param_value))		--os.date("%X",os.time())
				else
					file_log:write(string.format("%s %s: %.2f\n", os.date(), sec, res.param_value))
				end
				if ind == 1 then
					f_last_price = res.param_value
				elseif ind == 2 then
					s_last_price = res.param_value
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
	PrintDbgStr(string.format("%s ��������", script_name))
	file_log:write(os.date() .. " " .. script_name .. " ��������\n")
	file_log:close()
end

function main()
	if load_error then
		return false
	end	
	if isConnected() then
		PrintDbgStr(string.format("%s: QUIK ��������� � �������", script_name))
		file_log:write(os.date() .. " QUIK ��������� � �������\n")
	else
		PrintDbgStr(string.format("%s: QUIK �������� �� �������", script_name))
		exit_mess()
		return false
	end
	
	while true do
		sleep(60000)
		if diff then
			if tonumber(f_last_price) > 0 and tonumber(s_last_price) > 0 then
				diff_file:write(string.format("%s,%s,%s,%s,%.2f\n", os.date("%d.%m.%Y"), os.date("%H:%M:%S"), instrname[1], instrname[2], tonumber(f_last_price)-tonumber(s_last_price)))
				PrintDbgStr(string.format("%s: %s %s diff %s-%s: %.2f", script_name, os.date("%d.%m.%Y"), os.date("%H:%M:%S"), instrname[1], instrname[2], tonumber(f_last_price)-tonumber(s_last_price)))
			end
			f_last_price = 0
			s_last_price = 0
		end
	end
	exit_mess()
end
