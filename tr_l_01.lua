-- ����������� ��������� �������� �� �����: BRQ9
function OnInit()	-- ������� - ������������� QUIK
	close_flag = false
	file_log = io.open("tr_l_01_" .. os.date("%Y%m%d_%H%M%S") .. ".log", "w")
	PrintDbgStr("tr_l_01: ������� - ������������� QUIK")
	file_log:write(os.date() .. " tr_l_01 ������� (�������������)\n")
	-- ������ tr_l_01.ini
	file_ini = io.open(getScriptPath() .. "\\tr_l01.ini", "r")
	if file_ini ~= nil then
		type_of_inst = file_ini:read("*l")
		period = file_ini:read("*l")
		file_ini:close()	
		PrintDbgStr("tr_l_01: type_of_inst " .. type_of_inst)
		PrintDbgStr("tr_l_01: period " .. period)
	else
		PrintDbgStr("tr_l_01: ��������� ������� ini ����")
		close_flag = true
		return false
	end
	-- ������ ������ ���������
	local request_result_depo_buy = ParamRequest("SPBFUT", "BRQ9", "LAST")
	if request_result_depo_buy then
		PrintDbgStr("tr_l_01: �� ����������� BRQ9 ������� ������� �������� LAST")
		file_log:write(os.date() .. " �� ����������� BRQ9 ������� ������� �������� LAST\n")
	else
		PrintDbgStr("tr_l_01: ������ ��������� ��������� LAST �� ����������� BRQ9")
		file_log:write(os.date() .. " ������ ��������� ��������� LAST �� ����������� BRQ9\n")
		close_flag = true
		return false
	end --[[ ]]
end

function exit_mess()
	CancelParamRequest("SPBFUT", "BRQ9", "LAST")
	file_log:write(os.date() .. " tr_l_01 ��������\n")
	file_log:close()
end

function OnOrder(order)	-- ������� - QUIK ������� ����� ������
	PrintDbgStr("tr_l_01: ������� - QUIK ������� ����� ������")
	file_log:write(os.date() .. " ������� - QUIK ������� ����� ������\n")
end

function OnTrade(trade)	-- ������� - QUIK ������� ������
	PrintDbgStr("tr_l_01: ������� - QUIK ������� ������")
	file_log:write(os.date() .. " ������� - QUIK ������� ������\n")
end

function OnParam(class, sec)
	if class =="SPBFUT" and sec == "BRQ9" then
		result = getParamEx(class, sec, "LAST")
		PrintDbgStr(string.format("tr_l_01: BRQ9: %.2f", result.param_value))	--("tr_l_01: BRQ9: " .. tostring(result.param_value))
		file_log:write(string.format("%s BRQ9: %.2f\n", os.date(), result.param_value))	--(os.date() .. " BRQ9: " .. tostring(result.param_value) .. "\n")
	end
end

function OnClose()	-- ������� - �������� ��������� QUIK
	file_log:write(os.date() .. " ������� - �������� ��������� QUIK\n")
	exit_mess()
	return 0
end

function OnStop()	-- ������� - ��������� �������
	file_log:write(os.date() .. " ������� - ��������� �������\n")
	exit_mess()
	return 0
end

function main()
	if close_flag then
		return false
	end
	if isConnected() then
		PrintDbgStr("tr_l_01: QUIK ��������� � �������")
		file_log:write(os.date() .. " QUIK ��������� � �������\n")
	else
		PrintDbgStr("tr_l_01: QUIK �������� �� �������")
		exit_mess()
		return false
	end
	
	while true do
		-- result = getParamEx (class_code, sec_code, param_name_buy)
		-- PrintDbgStr("tr_l_01: " .. " " .. i .. "\n")
		-- file_log:write(os.date() .. " " .. i .. "\n")
		sleep(500)
	end
	
	exit_mess()
end
