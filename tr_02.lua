require("table")

function OnInit()	-- ������� - ������������� QUIK
	file_log = io.open("tr_02_" .. os.date("%Y%m%d_%H%M%S") .. ".log", "w")
	PrintDbgStr("tr_02: ������� - ������������� QUIK")
	file_log:write(os.date() .. " tr_02 ������� (�������������)\n")
	load_error = false
	file_ini = io.open(getScriptPath() .. "\\tr_02.ini", "r")
	if file_ini ~= nil then
		account = file_ini:read("*l")
		PrintDbgStr("tr_02: ������ tr_02.ini. ����� �����: " .. account)
		file_log:write(os.date() .. " ������ tr_02.ini. ����� �����: " .. account .. " \n")
		client = file_ini:read("*l")
		PrintDbgStr("tr_02: ������ tr_02.ini. ��� �������: " .. client)
		file_log:write(os.date() .. " ������ tr_02.ini. ��� �������: " .. client .. " \n")		
		instr_name = file_ini:read("*l")
		PrintDbgStr("tr_02: ������ tr_02.ini. ����������: " .. instr_name)
		file_log:write(os.date() .. " ������ tr_02.ini. ����������: " .. instr_name .. " \n")
		instr_class = file_ini:read("*l")
		PrintDbgStr("tr_02: ������ tr_02.ini. ����� �����������: " .. instr_class)
		file_log:write(os.date() .. " ������ tr_02.ini. ����� �����������: " .. instr_class .. " \n")		
		oder_interval = file_ini:read("*l")
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
	order_requests = {}
	order_numbers = {}
	start_deploing = true
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
	if start_deploing then
		Deploying(10, 60) --, result.param_value)
	end
end

function Deploying(counter, price)
	price = price - 5 -- ����� �� ����������� ������
	start_deploing = false
	--for cnt = 1, counter + 1 do
	--	SendTransBuySell(price + 0.05 * cnt, 1, '�������')
	--end
end

function OnClose()	-- ������� - �������� ��������� QUIK
	file_log:write(os.date() .. " ������� - �������� ��������� QUIK\n")
	exit_mess()
	return 0
end

function OnStop(flag)	-- ������� - ��������� �������
	file_log:write(os.date() .. " ������� - ��������� �������\n")
	exit_mess()
	for _, val in ipairs(order_requests) do
		PrintDbgStr(string.format("tr_02: ��������: %s", tostring(val))
	end	
	for key, val in ipairs(order_numbers) do
		PrintDbgStr(string.format("tr_02: ����: %s ��������: %s", tostring(key), tostring(val))
	end
	return 0
end

function SendTransBuySell(price, number, operation)	-- �������� ������ �� �������/�������
	local transaction = {}
		transaction['TRANS_ID'] = tostring(free_TRANS_ID)
		transaction['CLASSCODE'] = instr_class
		transaction['ACTION'] = 'NEW_ORDER'
		transaction['ACCOUNT'] = account
		transaction['CLIENT_CODE'] = client
		if operation == '�������' then
			transaction['OPERATION'] = 'B'
		elseif operation == '�������' then
			transaction['OPERATION'] = 'S'
		else
			PrintDbgStr("tr_02: �������� ��� ������ (�� �������, �� �������)")
			return false
		end
		transaction['TYPE'] = 'L'
		transaction['SECCODE'] = instr_name
		transaction['PRICE'] = tostring(price)
		transaction['QUANTITY'] = tostring(number)
		--[[PrintDbgStr(string.format("tr_02: TRANS_ID: %s", transaction['TRANS_ID']))
		PrintDbgStr(string.format("tr_02: CLASSCODE: %s", transaction['CLASSCODE']))
		PrintDbgStr(string.format("tr_02: ACTION: %s", transaction['ACTION']))
		PrintDbgStr(string.format("tr_02: SECCODE: %s", transaction['SECCODE']))
		PrintDbgStr(string.format("tr_02: PRICE: %s", transaction['PRICE']))
		PrintDbgStr(string.format("tr_02: QUANTITY: %s", transaction['QUANTITY'])) ]]
	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("tr_02: ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]", transaction.TRANS_ID, result))
		file_log:write(string.format("%s ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]\n", os.date(), transaction.TRANS_ID, result))
	else
		PrintDbgStr(string.format("tr_02: ���������� %s ����������. ��������: %s ����: %s ����������: %s ", transaction.TRANS_ID, operation, price, number))
		file_log:write(string.format("%s ���������� %s ����������. ��������: %s ����: %s ����������: %s\n", os.date(), transaction.TRANS_ID, operation, price, number))
	end
	table.insert(order_requests, tostring(free_TRANS_ID))
	transaction_current = transaction_current + 1
	transaction_ID[transaction_current] = free_TRANS_ID
	free_TRANS_ID = free_TRANS_ID + 1	--����������� free_TRANS_ID
end

function SendTransClose(close_ID)		-- ������ ������ 
	local transaction = {}
		transaction['TRANS_ID'] = tostring(free_TRANS_ID)
		transaction['CLASSCODE'] = instr_class
		transaction['ACTION'] = '������ ������ �� ������'
		transaction['������'] = tostring(close_ID)
	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("tr_02: ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]", free_TRANS_ID, result))
		file_log:write(string.format("%s ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]\n", os.date(), free_TRANS_ID, result))
	else
		PrintDbgStr(string.format("tr_02: ���������� %s ����������. ������ ������: %s", free_TRANS_ID, close_ID))
		file_log:write(string.format("%s ���������� %s ����������. ������ ������: %s\n", os.date(), free_TRANS_ID, close_ID))
	end
	transaction_current = transaction_current + 1
	transaction_ID[transaction_current] = free_TRANS_ID
	free_TRANS_ID = free_TRANS_ID + 1	-- ����������� free_TRANS_ID
end

function OnTransReply(trans_reply)	-- ������������� ���������� ������
	if trans_reply.trans_id == transaction_ID[transaction_current] then
		PrintDbgStr(string.format("tr_02: ������� ����� �� ���������� %i. ������ - %i order_num - %s msg:[%s]", 
										trans_reply.trans_id, 
										trans_reply.status, 
										tostring(trans_reply.order_num), 
										trans_reply.result_msg))
		file_log:write(string.format("%s ������� ����� �� ���������� %i. ������ - %i order_num - %s msg:[%s]\n", 
										os.date(), 
										trans_reply.trans_id, 
										trans_reply.status, 
										tostring(trans_reply.order_num),
										trans_reply.result_msg))
		if trans_reply.status >=2 then	-- ���� ������ ���������� 2 ��� ������ ������� ���������� ������������ � ��������� ��������� �� ���������
			table.sinsert(MAIN_QUEUE_TRADES, trans_reply.order_num)
		end
		table.insert(order_numbers, {tostring(trans_reply.trans_id), tostring(trans_reply.order_num)})
	end
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
	
	SendTransBuySell(60, 1, '�������')
	time_counter = 0
	trans_send_flag = false
	while true do
		-- result = getParamEx (class_code, sec_code, param_name_buy)
		while #MAIN_QUEUE_TRADES > 0 do	-- # �������� ����� ������� ���������� ���������� ������ ��������� �������
			-- ��������� ������� � ��������� � ���� � � ���
			-- MAIN_QUEUE_TRADES[1].trans_id
			PrintDbgStr(string.format("tr_02: ��������� � main order_num: %s", tostring(MAIN_QUEUE_TRADES[1])))
			file_log:write(string.format("%s ��������� � main order_num: %s\n", os.date(), tostring(MAIN_QUEUE_TRADES[1])))		
			trans_send_flag = true
			close_id = MAIN_QUEUE_TRADES[1]
			PrintDbgStr(string.format("tr_02: close_id: %s", tostring(close_id)))
			table.sremove(MAIN_QUEUE_TRADES, 1)
		end
		if (time_counter >= 6000) and (trans_send_flag) then
			PrintDbgStr(string.format("tr_02: ������ ���������� %s", tostring(close_id)))
			SendTransClose(close_id)
			time_counter = 0
			trans_send_flag = false
		end			
		sleep(10)
		time_counter = time_counter + 1
	end
	exit_mess()
end
