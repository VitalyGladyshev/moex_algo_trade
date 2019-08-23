require("table")

function OnInit()	-- ������� - ������������� QUIK
	file_log = io.open("vrfma_" .. os.date("%Y%m%d_%H%M%S") .. ".log", "w")
	PrintDbgStr("vrfma: ������� - ������������� QUIK")
	file_log:write(os.date() .. " vrfma ������� (�������������)\n")
	load_error = false
	file_ini = io.open(getScriptPath() .. "\\vrfma.ini", "r")
	if file_ini ~= nil then
		account = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ����� �����: " .. account)
		file_log:write(os.date() .. " ������ vrfma.ini. ����� �����: " .. account .. " \n")
		client = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ��� �������: " .. client)
		file_log:write(os.date() .. " ������ vrfma.ini. ��� �������: " .. client .. " \n")		
		instr_name = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ����������: " .. instr_name)
		file_log:write(os.date() .. " ������ vrfma.ini. ����������: " .. instr_name .. " \n")
		instr_class = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ����� �����������: " .. instr_class)
		file_log:write(os.date() .. " ������ vrfma.ini. ����� �����������: " .. instr_class .. " \n")		
		oder_interval = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ��� ������: " .. oder_interval)
		file_log:write(os.date() .. " ������ vrfma.ini. ��� ������: " .. oder_interval .. " \n")
		file_ini:close()
	else
		load_error = true
		message("vrfma: ������ �������� vrfma.ini")
		PrintDbgStr("vrfma: ������ �������� vrfma.ini")
		file_log:write(os.date() .. "vrfma: ������ �������� vrfma.ini\n")		--instr_name = "BRQ9"; instr_class = "SPBFUT";	oder_interval = 5	
		return false
	end
	
	free_TRANS_ID = os.time()	--��� ����������� ������������ free_TRANS_ID ������ ������ ����� ���������� ������� �������� �������
	MAIN_QUEUE_TRADES = {}
	order_requests_buy = {}
	order_requests_sell = {}
	order_numbers_buy = {}
	order_numbers_sell = {}
	KillAllOrders(instr_class, instr_name, client)
	start_deploing = true	
	
	local request_result_depo_buy = ParamRequest(instr_class, instr_name, "LAST")
	if request_result_depo_buy then
		PrintDbgStr("vrfma: �� ����������� " .. instr_name .. " ������� ������� �������� LAST")
		file_log:write(os.date() .. " �� ����������� " .. instr_name .. " ������� ������� �������� LAST\n")
	else
		PrintDbgStr("vrfma: ������ ��������� ��������� LAST �� ����������� " .. instr_name)
		file_log:write(os.date() .. " ������ ��������� ��������� LAST �� ����������� " .. instr_name .. "\n")
		return false
	end
end

function KillAllOrders(classCode, secCode, brokerref)	-- ����� �� ������ QUIK � �����������
	PrintDbgStr(string.format("vrfma: �������� ���� ������ ������"))
	file_log:write(string.format("%s �������� ���� ������ ������\n", os.date()))
	function myFind(C,S,F, BR)
		return (C == classCode) and (S == secCode) and (bit.band(F, 0x1) ~= 0) and (BR == brokerref)
	end
	local res = 1
	local errNotExist = true
	local ord = "orders"
	local orders = SearchItems(ord, 0, getNumberOf(ord)-1, myFind, "class_code,sec_code,flags,brokerref")
	if (orders ~= nil) and (#orders > 0) then
		for i=1, #orders do
			local transaction={
				["TRANS_ID"]=tostring(free_TRANS_ID),	--1000*os.clock()),
				["ACTION"]="KILL_ORDER",
				["CLASSCODE"]=classCode,
				["SECCODE"]=secCode,
				["ORDER_KEY"]=tostring(getItem(ord,orders[i]).order_num)
			}
			local res=sendTransaction(transaction)
			if res ~= "" then
				PrintDbgStr(string.format("vrfma: ���������� %s �� ������ ������ %s �� ������ �������� �� ������� ��������� QUIK [%s]", free_TRANS_ID, tostring(getItem(ord,orders[i]).order_num, result)))
				file_log:write(string.format("	���������� %s �� ������ ������ %s �� ������ �������� �� ������� ��������� QUIK [%s]\n", free_TRANS_ID, tostring(getItem(ord,orders[i]).order_num, result)))
			else
				PrintDbgStr(string.format("vrfma: ���������� %s ����������. ������ ������: %s", free_TRANS_ID, tostring(getItem(ord,orders[i]).order_num)))
				file_log:write(string.format("	���������� %s ����������. ������ ������: %s\n", free_TRANS_ID, tostring(getItem(ord,orders[i]).order_num)))
			end
			free_TRANS_ID = free_TRANS_ID + 1	-- ����������� free_TRANS_ID
		end
	end
	PrintDbgStr(string.format("vrfma: �������� ���� ������ ���������"))
	file_log:write(string.format("%s �������� ���� ������ ���������\n", os.date()))
	return errNotExist 
end

function OnParam(class, sec)
	if class == instr_class and sec == instr_name then
		res = getParamEx(class, sec, "LAST")
		if res ~= 0 then
			PrintDbgStr(string.format("vrfma: %s: %.2f", instr_name, res.param_value))	--("vrfma: BRQ9: " .. tostring(res.param_value))
			file_log:write(string.format("%s %s: %.2f\n", os.date(), instr_name, res.param_value))	--(os.date() .. " BRQ9: " .. tostring(res.param_value) .. "\n")
			if start_deploing then
				Deploying(10, res.param_value)	--PrintDbgStr(string.format("vrfma: type(res.param_value): %s", type(res.param_value))) -- res.param_value: %.2f", type(tmp), tonumber(tmp)))
			end
		end
	end
end

function Deploying(counter, price)
	price = price - 5		-- ����� �� ����������� ������
	start_deploing = false
	for cnt = 1, counter do		--PrintDbgStr(string.format("vrfma: price in Deploying: %s", tostring(price)))
		SendTransBuySell(price + 0.05 * cnt, 1, '�������')
		sleep(5)
	end
	price = price + 10		-- ����� �� ����������� ������
	for cnt = 1, counter do
		SendTransBuySell(price + 0.05 * cnt, 1, '�������')
		sleep(5)
	end	
end

function exit_mess()
	CancelParamRequest(instr_class, instr_name, "LAST")
	PrintDbgStr("vrfma: ������: ")
	file_log:write(string.format("%s ������ �� �������:\n", os.date()))
	for ind, val in ipairs(order_requests_buy) do
		PrintDbgStr(string.format("vrfma: ������: %i ��������: %s", ind, tostring(val)))
		file_log:write(string.format("	������: %i ��������: %s\n", ind, tostring(val)))
	end	
	for key, val in pairs(order_numbers_buy) do
		PrintDbgStr(string.format("vrfma: ����: %s ��������: %s", tostring(key), tostring(val)))
		file_log:write(string.format("	����: %s ��������: %s\n", tostring(key), tostring(val)))
	end
	file_log:write(string.format("%s ������ �� �������:\n", os.date()))
	for ind, val in ipairs(order_requests_sell) do
		PrintDbgStr(string.format("vrfma: ������: %i ��������: %s", ind, tostring(val)))
		file_log:write(string.format("	������: %i ��������: %s\n", ind, tostring(val)))
	end	
	for key, val in pairs(order_numbers_sell) do
		PrintDbgStr(string.format("vrfma: ����: %s ��������: %s", tostring(key), tostring(val)))
		file_log:write(string.format("	����: %s ��������: %s\n", tostring(key), tostring(val)))
	end
	PrintDbgStr("vrfma: vrfma ��������")
	file_log:write(os.date() .. " vrfma ��������\n")
	file_log:close()
end

function OnClose()	-- ������� - �������� ��������� QUIK
	file_log:write(os.date() .. " ������� - �������� ��������� QUIK\n")
	KillAllOrders(instr_class, instr_name, client)
	exit_mess()
	return 0
end

function OnStop(flag)	-- ������� - ��������� �������
	file_log:write(os.date() .. " ������� - ��������� �������\n")
	KillAllOrders(instr_class, instr_name, client)
	exit_mess()
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
			PrintDbgStr("vrfma: �������� ��� ������ (�� �������, �� �������)")
			return false
		end
		transaction['TYPE'] = 'L'
		transaction['SECCODE'] = instr_name
		transaction['PRICE'] = tostring(price)
		transaction['QUANTITY'] = tostring(number)
		--[[PrintDbgStr(string.format("vrfma: TRANS_ID: %s", transaction['TRANS_ID'])) PrintDbgStr(string.format("vrfma: CLASSCODE: %s", transaction['CLASSCODE']))]]
	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("vrfma: ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]", transaction.TRANS_ID, result))
		file_log:write(string.format("%s ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]\n", os.date(), transaction.TRANS_ID, result))
	else
		PrintDbgStr(string.format("vrfma: ���������� %s ����������. ��������: %s; ����: %s; ����������: %s ", transaction.TRANS_ID, operation, price, number))
		file_log:write(string.format("%s ���������� %s ����������. ��������: %s; ����: %s; ����������: %s\n", os.date(), transaction.TRANS_ID, operation, price, number))
	end
	if operation == '�������' then
		order_requests_buy[#order_requests_buy + 1] = free_TRANS_ID	--table.insert(order_requests, tostring(free_TRANS_ID))
	elseif operation == '�������' then
		order_requests_sell[#order_requests_sell + 1] = free_TRANS_ID	--table.insert(order_requests, tostring(free_TRANS_ID))
	else
		PrintDbgStr("vrfma: �������� ��� ������ (�� �������, �� �������)")
		return false
	end
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
		PrintDbgStr(string.format("vrfma: ���������� %s �� ������ ������ %s �� ������ �������� �� ������� ��������� QUIK [%s]", free_TRANS_ID, close_ID, result))
		file_log:write(string.format("%s ���������� %s �� ������ ������ %s �� ������ �������� �� ������� ��������� QUIK [%s]\n", os.date(), free_TRANS_ID, close_ID, result))
	else
		PrintDbgStr(string.format("vrfma: ���������� %s ����������. ������ ������: %s", free_TRANS_ID, close_ID))
		file_log:write(string.format("%s ���������� %s ����������. ������ ������: %s\n", os.date(), free_TRANS_ID, close_ID))
	end
	free_TRANS_ID = free_TRANS_ID + 1	-- ����������� free_TRANS_ID
end

function OnTransReply(trans_reply)	-- ������������� ���������� ������
	for ind, ord_rec in ipairs(order_requests_buy) do
		if trans_reply.trans_id == ord_rec then
			if trans_reply.status >= 2 then	-- ���� ������ ���������� 2 ��� ������ ������� ���������� ������������ � ��������� ��������� �� ���������
				table.remove(order_requests_buy, ind)
				if trans_reply.status == 3 then
					table.sinsert(MAIN_QUEUE_TRADES, {	trans_id = trans_reply.trans_id, 
														status = trans_reply.status,
														order_num = trans_reply.order_num,
														result_msg = trans_reply.result_msg})
					order_numbers_buy[trans_reply.trans_id] = trans_reply.order_num -- table.insert(order_numbers_buy, {tostring(trans_reply.trans_id) = tostring(trans_reply.order_num)})
				end
			end
			break
		end
	end
	for ind, ord_rec in ipairs(order_requests_sell) do
		if trans_reply.trans_id == ord_rec then
			if trans_reply.status >= 2 then	-- ���� ������ ���������� 2 ��� ������ ������� ���������� ������������ � ��������� ��������� �� ���������
				table.remove(order_requests_sell, ind)
				if trans_reply.status == 3 then
					table.sinsert(MAIN_QUEUE_TRADES, {	trans_id = trans_reply.trans_id, 
														status = trans_reply.status,
														order_num = trans_reply.order_num,
														result_msg = trans_reply.result_msg})
					order_numbers_sell[trans_reply.trans_id] = trans_reply.order_num -- table.insert(order_numbers_sell, {tostring(trans_reply.trans_id) = tostring(trans_reply.order_num)})
				end
			end
			break
		end
	end
end

function OnTrade(trade)	-- ������� - QUIK ������� ������
	for _, ord in pairs(order_numbers_buy) do
		if ord == trade.order_num then
			PrintDbgStr(string.format("vrfma: ������� - QUIK ������� ������ order_num - %s", trade.order_num))
			file_log:write(string.format("%s ������� - QUIK ������� ������ order_num - %s\n", os.date(), trade.order_num))
		end
	end
	for _, ord in pairs(order_numbers_sell) do
		if ord == trade.order_num then
			PrintDbgStr(string.format("vrfma: ������� - QUIK ������� ������ order_num - %s", trade.order_num))
			file_log:write(string.format("%s ������� - QUIK ������� ������ order_num - %s\n", os.date(), trade.order_num))
		end
	end
end

function main()
	if load_error then
		return false
	end	
	if isConnected() then
		PrintDbgStr("vrfma: QUIK ��������� � �������")
		file_log:write(os.date() .. " QUIK ��������� � �������\n")
	else
		PrintDbgStr("vrfma: QUIK �������� �� �������")
		exit_mess()
		return false
	end
	
	time_counter = 0	--SendTransBuySell(60, 1, '�������')
	trans_send_flag = false
	while true do
		while #MAIN_QUEUE_TRADES > 0 do	-- # �������� ����� ������� ���������� ���������� ������ ��������� �������
			-- ��������� ������� � ��������� � ���� � � ���
			PrintDbgStr(string.format("vrfma: ������� ����� �� ���������� %i. ������ - %i order_num - %s msg:[%s]", 
											MAIN_QUEUE_TRADES[1].trans_id, 
											MAIN_QUEUE_TRADES[1].status, 
											tostring(MAIN_QUEUE_TRADES[1].order_num), 
											MAIN_QUEUE_TRADES[1].result_msg))
			file_log:write(string.format("%s ������� ����� �� ���������� %i. ������ - %i order_num - %s msg:[%s]\n", 
											os.date(), 
											MAIN_QUEUE_TRADES[1].trans_id, 
											MAIN_QUEUE_TRADES[1].status, 
											tostring(MAIN_QUEUE_TRADES[1].order_num),
											MAIN_QUEUE_TRADES[1].result_msg))
			trans_send_flag = true
			table.sremove(MAIN_QUEUE_TRADES, 1)
		end
--[=[		if (time_counter >= 6000) and (trans_send_flag) then
			for key, ord in pairs(order_numbers_buy) do
				SendTransClose(ord)
			end
			for key, ord in pairs(order_numbers_sell) do
				SendTransClose(ord)
			end
			time_counter = 0
			trans_send_flag = false
		end	]=]
		sleep(10)
		time_counter = time_counter + 1
	end
	exit_mess()
end
