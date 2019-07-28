-- ����������� ��������� �������� �� �����: BRQ9, ������� � ������ ������
function OnInit()	-- ������� - ������������� QUIK
	file_log = io.open("tr_02_" .. os.date("%Y%m%d_%H%M%S") .. ".log", "w")
	PrintDbgStr("tr_02: ������� - ������������� QUIK")
	file_log:write(os.date() .. " tr_02 ������� (�������������)\n")
	load_error = false
	file_ini = io.open(getScriptPath() .. "\\tr_02.ini", "r")
	if ~= nil then
		account = file_ini:read(�*l�)
		PrintDbgStr("tr_02: ������ tr_02.ini. ����� �����: " .. account)
		file_log:write(os.date() .. " ������ tr_02.ini. ����� �����: " .. account .. " \n")
		instr_name = file_ini:read(�*l�)
		PrintDbgStr("tr_02: ������ tr_02.ini. ����������: " .. instr_name)
		file_log:write(os.date() .. " ������ tr_02.ini. ����������: " .. instr_name .. " \n")
		instr_class = file_ini:read(�*l�)
		PrintDbgStr("tr_02: ������ tr_02.ini. ����� �����������: " .. instr_class)
		file_log:write(os.date() .. " ������ tr_02.ini. ����� �����������: " .. instr_class .. " \n")		
		oder_interval = file_ini:read(�*l�)
		PrintDbgStr("tr_02: ������ tr_02.ini. ��� ������: " .. oder_interval)
		file_log:write(os.date() .. " ������ tr_02.ini. ��� ������: " .. oder_interval .. " \n")
		file_ini:close()
	else
		load_error = true
		message("tr_02: ������ �������� tr_02.ini")
		PrintDbgStr("tr_02: ������ �������� tr_02.ini")
		file_log:write(os.date() .. "tr_02: ������ �������� tr_02.ini\n")		
		--instr_name = "BRQ9"; instr_class = "SPBFUT";	oder_interval = 5		
		return false
	end
	
	free_TRANS_ID = os.time()	--��� ����������� ������������ free_TRANS_ID ������ ������ ����� ���������� ������� �������� �������
	transaction_ID = {[0] = nil}	--������� ������������ ������
	transaction_current = -1	--������� ������� � ������� ����������
	MAIN_QUEUE_TRADES = {}
	
	local request_result_depo_buy = ParamRequest(instr_class, instr_name, "LAST")
	if request_result_depo_buy then
		PrintDbgStr("tr_02: �� ����������� " .. instr_name .. " ������� ������� �������� LAST")
		file_log:write(os.date() .. " �� ����������� " .. instr_name .. " ������� ������� �������� LAST\n")
	else
		PrintDbgStr("tr_02: ������ ��������� ��������� LAST �� ����������� " .. instr_name)
		file_log:write(os.date() .. " ������ ��������� ��������� LAST �� ����������� " .. instr_name .. "\n")
		return false
	end
end

function exit_mess()
	CancelParamRequest(instr_class, instr_name, "LAST")
	file_log:write(os.date() .. " tr_02 ��������\n")
	file_log:close()
end

--[[function OnOrder(order)	-- ������� - QUIK ������� ����� ������
	PrintDbgStr("tr_02: ������� - QUIK ������� ����� ������")
	file_log:write(os.date() .. " ������� - QUIK ������� ����� ������\n") end
function OnTrade(trade)	-- ������� - QUIK ������� ������
	PrintDbgStr("tr_02: ������� - QUIK ������� ������")
	file_log:write(os.date() .. " ������� - QUIK ������� ������\n") end ]]

function OnParam(class, sec)
	if class == instr_class and sec == instr_name then
		result = getParamEx(class, sec, "LAST")
		PrintDbgStr(string.format("tr_02: %s: %.2f", instr_name, result.param_value))	--("tr_02: BRQ9: " .. tostring(result.param_value))
		file_log:write(string.format("%s %s: %.2f\n", os.date(), instr_name, result.param_value))	--(os.date() .. " BRQ9: " .. tostring(result.param_value) .. "\n")
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

function SendTransBuySell(price, number, operation)	-- �������� ������ �� �������/�������
	local transaction = {}
		transaction['TRANS_ID'] = tostring(free_TRANS_ID)
		transaction['CLASSCODE'] = instr_class
		transaction['ACTION'] = '���� ������'
		transaction['�������� ����'] = account
		if operation == '�������' then
			transaction['�/�'] = '�������'
		elseif operation == '�������' then
			transaction['�/�'] = '�������'
		else
			PrintDbgStr("tr_02: �������� ��� ������ (�� �������, �� �������)")
			return false
		end
		transaction['���'] = '��������������'
		transaction['����������'] = instr_name
		transaction['����'] = tostring(price)
		transaction['����������'] = tostring(number)		
	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("tr_02: ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]", transaction.TRANS_ID, result))
	else
		PrintDbgStr(string.format("tr_02: ���������� %s ����������", transaction.TRANS_ID))
	end
	transaction_current = transaction_current + 1
	transaction_ID[transaction_current] = free_TRANS_ID
	free_TRANS_ID = free_TRANS_ID + 1	--����������� free_TRANS_ID
end

function SendTransClose(close_TRANS_ID)		-- ������ ������ 
	local transaction = {}
		transaction['TRANS_ID'] = tostring(close_TRANS_ID)

	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("tr_02: ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]", close_TRANS_ID, result))
	else
		PrintDbgStr(string.format("tr_02: ���������� %s ����������", close_TRANS_ID))
	end	
	PrintDbgStr(string.format("tr_02: ���������� - ������ ������ %s", close_TRANS_ID))
end

function OnTransReply(trans_reply)	-- ������������� ���������� ������
	table.sinsert(MAIN_QUEUE_TRADES, trans_reply)
end

function main()
	if load_error then
		return false
	end	
	if isConnected() then
		PrintDbgStr("tr_02: QUIK ��������� � �������")
		file_log:write(os.date() .. " QUIK ��������� � �������\n")
	else
		PrintDbgStr("tr_02: QUIK �������� �� �������")
		exit_mess()
		return false
	end
	
	SendTransBuySell(100, 1, '�������')
	time_counter = 0
	trans_send_flag = false
	while true do
		-- result = getParamEx (class_code, sec_code, param_name_buy)
		-- PrintDbgStr("tr_02: " .. " " .. i .. "\n")
		-- file_log:write(os.date() .. " " .. i .. "\n")
		while #MAIN_QUEUE_TRADES > 0 do	-- # �������� ����� ������� ���������� ���������� ������ ��������� �������
			-- ��������� ������� � ��������� � ���� � � ���
			-- MAIN_QUEUE_TRADES[1].trans_id
			-- trans_send_flag = true
			PrintDbgStr(string.format("tr_02: ���������� %s ������������", MAIN_QUEUE_TRADES[1].trans_id))
			file_log:write(string.format("%s ���������� %s ������������\n", os.date(), MAIN_QUEUE_TRADES[1].trans_id))		
			if (time_counter >= 240) and (trans_send_flag) then
				SendTransClose(MAIN_QUEUE_TRADES[1].trans_id)
				trans_send_flag = false
			end			
			table.sremove(MAIN_QUEUE_TRADES, 1)
		end
		sleep(500)
		time_counter = time_counter + 1
	end
	exit_mess()
end
