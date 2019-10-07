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
		order_interval = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ��� ������: " .. order_interval)
		file_log:write(os.date() .. " ������ vrfma.ini. ��� ������: " .. order_interval .. " \n")
		profit = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ����� �������: " .. profit)
		file_log:write(os.date() .. " ������ vrfma.ini. ����� �������: " .. profit .. " \n")
		file_ini:close()
		order_interval = tonumber(order_interval)
		profit = tonumber(profit)
	else
		load_error = true
		message("vrfma: ������ �������� vrfma.ini")
		PrintDbgStr("vrfma: ������ �������� vrfma.ini")
		file_log:write(os.date() .. "vrfma: ������ �������� vrfma.ini\n")
		return false
	end
	
	file_name_for_load = getScriptPath() .. "\\trades_tbl.dat"
	start_deploying = true
	cold_start = true
	file_load_table = io.open(file_name_for_load, "r")
	if file_load_table ~= nil then
		local current_position = file_load_table:seek() 
		local size = file_load_table:seek("end")	-- file_load_table:seek("set",current_position)
		file_load_table:close()
		if size > 0 then
			cold_start = false
		end
	end
	trades_tbl = {}
	start_trades_tbl = {}
	if not cold_start then
		dofile(file_name_for_load)
	end
	
	free_TRANS_ID = os.time()	--��� ����������� ������������ free_TRANS_ID ������ ������ ����� ���������� ������� �������� �������
	MAIN_QUEUE_TRADES = {}
	QUEUE_SAVE_TRADES = {}
	current_price = 0
	KillAllOrders(instr_class, instr_name, client)
	
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
			PrintDbgStr(string.format("vrfma: %s: %.2f", instr_name, res.param_value))
			file_log:write(string.format("%s %s: %.2f\n", os.date(), instr_name, res.param_value))
			if current_price == res.param_value then
				return
--[[			elseif abs(current_price - res.param_value) > order_interval * 200 then
				PrintDbgStr(string.format("vrfma: ������! ������������ ����: %.2f", res.param_value))
				file_log:write(string.format("%s ������! ������������ ����: %.2f\n", os.date(), res.param_value))
				return	]]	--���� ������� ��������� ��������� ����, ����� ��� �������� ����� ����� ��������� ��� ������
			else
				current_price = res.param_value
			end
		--������������� ��� ������
			if start_deploying then
				start_deploying = false
				if cold_start then
					base_price = res.param_value
					ColdStart(10, base_price)	--PrintDbgStr(string.format("vrfma: type(res.param_value): %s", type(res.param_value))) -- res.param_value: %.2f", type(tmp), tonumber(tmp)))
					return
				else
					local delta = trades_tbl[1]["price"] - current_price	--trades_tbl ��������� �������� �.�. ������ ������� ������ ����
					whole_part, fractional_part = math.modf(delta/order_interval)
					base_price = res.param_value + delta - order_interval * whole_part
					PrintDbgStr(string.format("vrfma: ����������� base_price: %.2f", base_price))
					file_log:write(string.format("%s ����������� base_price: %.2f\n", os.date(), base_price))
					WarmStart(base_price, current_price)
					return
				end
			end
		-- ���������� ������ base_price
--[[			if (current_price > base_price and current_price < base_price + order_interval) or
				(current_price < base_price and current_price > base_price - order_interval) then
				local base_price_not_used = true
				for _, tab in ipairs(trades_tbl) do
					if tab["price"] == base_price then
						base_price_not_used = false
						break
					end
				end
				if base_price_not_used and current_price > base_price then
					SendTransBuySell(base_price, 1, 'B')
				elseif base_price_not_used and current_price < base_price then
					SendTransBuySell(base_price, 1, 'S')
				end
			end	]]
		end
	end
end

function ColdStart(counter, b_price)
PrintDbgStr(string.format("vrfma: ColdStart"))
	cold_start = false
	for cnt = 1, counter do
		SendTransBuySell(b_price - order_interval * cnt, 1, 'B')
		sleep(110)
	end
	for cnt = 1, counter do
		SendTransBuySell(b_price + order_interval * cnt, 1, 'S')
		sleep(110)
	end	
end

function WarmStart(b_price, c_price)
PrintDbgStr(string.format("vrfma: WarmStart"))
	for _, tab in pairs(start_trades_tbl) do		--������ twin-��
		if tab["operation"] == 'B' then
			if b_price > (tab["price"] + profit) then
				PrintDbgStr(string.format("vrfma: WarmStart. S. b_price+: %s (tab[price] + profit): %s status: %s", tostring(b_price), tostring((tab["price"] + profit)), tostring(tab["status"])))
				SendTransBuySell(b_price, 1, 'S', tab["number_sys"])
			else
				PrintDbgStr(string.format("vrfma: WarmStart. S. b_price-: %s (tab[price] + profit): %s status: %s", tostring(b_price), tostring((tab["price"] + profit)), tostring(tab["status"])))
				SendTransBuySell(tab["price"] + profit, 1, 'S', tab["number_sys"])
			end
		else
			if b_price < (tab["price"] - profit) then
				PrintDbgStr(string.format("vrfma: WarmStart. B. b_price+: %s (tab[price] - profit): %s status: %s", tostring(b_price), tostring((tab["price"] - profit)), tostring(tab["status"])))
				SendTransBuySell(b_price, 1, 'B', tab["number_sys"])
			else
				PrintDbgStr(string.format("vrfma: WarmStart. B. b_price-: %s (tab[price] - profit): %s status: %s", tostring(b_price), tostring((tab["price"] - profit)), tostring(tab["status"])))
				SendTransBuySell(tab["price"] - profit, 1, 'B', tab["number_sys"])
			end
		end
		sleep(110)
	end
	OrdersVerification(b_price)
end

function ReadTradesTbl(tbl)
	table.sinsert(trades_tbl, {	["number_my"] = tbl["number_my"], 
								["number_sys"] = tbl["number_sys"], 
								["price"] = tbl["price"], 
								["operation"] = tbl["operation"], 
								["status"] = tbl["status"], 
								["twin"] = tbl["twin"]})
	table.sinsert(start_trades_tbl, {	["number_my"] = tbl["number_my"], 
										["number_sys"] = tbl["number_sys"], 
										["price"] = tbl["price"], 
										["operation"] = tbl["operation"], 
										["status"] = tbl["status"], 
										["twin"] = tbl["twin"]})
end
 
function SaveTradesTbl()
	file_save_table = io.open(getScriptPath() .. "\\trades_tbl.dat", "w+")
	if file_save_table ~= nil then
		for _, tab in ipairs(trades_tbl) do
			if tostring(tab["status"]) == tostring(3) then
				file_save_table:write("ReadTradesTbl{\n")
				for key, val in pairs(tab) do
					file_save_table:write(" ", key, " = ")
					if type(val) == "number" then
						file_save_table:write(val)
					elseif type(val) == "string" then
						file_save_table:write(string.format("%q", val))
					end
					file_save_table:write(",\n")
				end
				file_save_table:write("}\n")
			end
		end
		file_save_table:flush()
		file_save_table:close()
		return true
	else
		message("vrfma: ������ ���������� trades_tbl.dat")
		PrintDbgStr("vrfma: ������ ���������� trades_tbl.dat")
		file_log:write(os.date() .. "vrfma: ������ ���������� trades_tbl.dat\n")
		return false
	end
end

function ExitMess()
	CancelParamRequest(instr_class, instr_name, "LAST")
	SaveTradesTbl()	-- ��������� trades_tbl � ����
	PrintDbgStr("vrfma: ������: ")
	file_log:write(string.format("%s ������� ������ � ������:\n", os.date()))
	for _, tab in ipairs(trades_tbl) do
		PrintDbgStr(string.format("vrfma: �����: %s ������: %i ��������: %s ����: %s", tostring(tab["number_sys"]), tab["status"], tostring(tab["operation"]), tostring(tab["price"])))
		file_log:write(string.format("	�����: %s ������: %i ��������: %s ����: %s\n", tostring(tab["number_sys"]), tab["status"], tostring(tab["operation"]), tostring(tab["price"])))
	end	
	KillAllOrders(instr_class, instr_name, client)
	PrintDbgStr("vrfma: vrfma ��������")
	file_log:write(os.date() .. " vrfma ��������\n")
	file_log:close()
end

function OnClose()	-- ������� - �������� ��������� QUIK
	file_log:write(os.date() .. " ������� - �������� ��������� QUIK\n")
	ExitMess()
	return 0
end

function OnStop(flag)	-- ������� - ��������� �������
	file_log:write(os.date() .. " ������� - ��������� �������\n")
	ExitMess()
	return 0
end

function SendTransBuySell(price, quantity, operation, twin_num)	-- �������� ������ �� �������/�������
	twin_num = twin_num or 0
	local transaction = {}
		transaction['TRANS_ID'] = tostring(free_TRANS_ID)
		transaction['CLASSCODE'] = instr_class
		transaction['ACTION'] = 'NEW_ORDER'
		transaction['ACCOUNT'] = account
		transaction['CLIENT_CODE'] = client
		transaction['OPERATION'] = operation
		transaction['TYPE'] = 'L'
		transaction['SECCODE'] = instr_name
		transaction['PRICE'] = tostring(price)
		transaction['QUANTITY'] = tostring(quantity)
		--[[PrintDbgStr(string.format("vrfma: TRANS_ID: %s", transaction['TRANS_ID'])) PrintDbgStr(string.format("vrfma: CLASSCODE: %s", transaction['CLASSCODE']))]]
	local result = sendTransaction(transaction)
-- ������ � log ��������� � main
	if result ~= "" then
		PrintDbgStr(string.format("vrfma: ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]", transaction.TRANS_ID, result))
		file_log:write(string.format("%s ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]\n", os.date(), transaction.TRANS_ID, result))
	else
		PrintDbgStr(string.format("vrfma: ���������� %s ����������. ��������: %s; ����: %s; ����������: %s ", transaction.TRANS_ID, operation, price, quantity))
		file_log:write(string.format("%s ���������� %s ����������. ��������: %s; ����: %s; ����������: %s\n", os.date(), transaction.TRANS_ID, operation, price, quantity))
	end
	table.sinsert(trades_tbl, {	["number_my"] = free_TRANS_ID, 
								["number_sys"] = 0, 
								["price"] = price, 
								["operation"] = operation, 
								["status"] = 1, 
								["twin"] = twin_num}) --order_requests_buy[#order_requests_buy + 1] = free_TRANS_ID
	free_TRANS_ID = free_TRANS_ID + 1	--����������� free_TRANS_ID
end

function SendTransClose(close_ID)		-- ������ ������ 
	local transaction = {}
		transaction['TRANS_ID'] = tostring(free_TRANS_ID)
		transaction['CLASSCODE'] = instr_class
		transaction['ACTION'] = '������ ������ �� ������'
		transaction['������'] = tostring(close_ID)
	local result = sendTransaction(transaction)
-- ������ � log ��������� � main
	if result ~= "" then
		PrintDbgStr(string.format("vrfma: ���������� %s �� ������ ������ %s �� ������ �������� �� ������� ��������� QUIK [%s]", free_TRANS_ID, close_ID, result))
		file_log:write(string.format("%s ���������� %s �� ������ ������ %s �� ������ �������� �� ������� ��������� QUIK [%s]\n", os.date(), free_TRANS_ID, close_ID, result))
	else
		PrintDbgStr(string.format("vrfma: ���������� %s ����������. ������ ������: %s", free_TRANS_ID, close_ID))
		file_log:write(string.format("%s ���������� %s ����������. ������ ������: %s\n", os.date(), free_TRANS_ID, close_ID))
	end
	free_TRANS_ID = free_TRANS_ID + 1	-- ����������� free_TRANS_ID
	for ind, tab in ipairs(trades_tbl) do
		if tab["number_sys"] == close_ID then
			trades_tbl[ind] = nil
		end
	end
end

function OnTransReply(trans_reply)	-- ������������� ���������� ������
	for _, tab in ipairs(trades_tbl) do
		if trans_reply.trans_id == tab["number_my"] then
			if trans_reply.status == 3 then
				tab["number_sys"] = trans_reply.order_num
				tab["status"] = 2				
				table.sinsert(MAIN_QUEUE_TRADES, {	trans_id = trans_reply.trans_id, 
													status = trans_reply.status,
													order_num = trans_reply.order_num,
													result_msg = trans_reply.result_msg})
			end
			break
		end
	end
end

function OnTrade(trade)	-- ������� - QUIK ������� ������
PrintDbgStr(string.format("vrfma: OnTrade"))
	for ind_1, tab in pairs(trades_tbl) do
		if tab["number_sys"] == trade.order_num and tab["status"] ~= 3 then
			table.sinsert(QUEUE_SAVE_TRADES, {	order_num = trade.order_num,
												price = trade.price,
												operation = tab["operation"],
												twin = tab["twin"]}) 
			base_price = tab["price"]
			if tab["twin"] == 0 then
				tab["status"] = 3
				if tab["operation"] == 'B' then
					SendTransBuySell(tab["price"] + profit, 1, 'S', tab["number_sys"])
				else
					SendTransBuySell(tab["price"] - profit, 1, 'B', tab["number_sys"])
				end
			else	--�������� twin. ������� ������ � twin
				for ind_2, tab_2 in pairs(trades_tbl) do
					if tostring(tab["twin"]) == tostring(tab_2["number_sys"]) then
						trades_tbl[ind_2] = nil
						PrintDbgStr(string.format("vrfma: �������� twin. ������� ������ � twin tab[twin]: %s tab_2[number_sys]: %s, trades_tbl[ind_2]: %s trades_tbl[ind_1]: %s", tostring(tab["twin"]), tostring(tab_2["number_sys"]), tostring(trades_tbl[ind_2]), tostring(trades_tbl[ind_1])))
						break
					end
				end
				trades_tbl[ind_1] = nil
			end
			OrdersVerification(base_price)
			break
		end
	end
end

function OrdersVerification(b_price)
PrintDbgStr(string.format("vrfma: OrdersVerification. ����: %s", tostring(b_price)))
--������� ������ ������
	for k1, tab in pairs(trades_tbl) do
		if tab["status"] == 2 and tab["twin"] == 0 then
			if (tab["price"] > b_price and tab["operation"] == 'B') 
					or (tab["price"] < b_price and tab["operation"] == 'S') then
				SendTransClose(tab["number_sys"])
			end
			if tab["price"] > (b_price + order_interval * 10)
					or tab["price"] < (b_price - order_interval * 10) then
				SendTransClose(tab["number_sys"])
			end
		end
	end
--������ ����� ������			
	local pos_not_used
	for cnt = 1, 10 do
		pos_not_used = true
		for k2, tab in pairs(trades_tbl) do
--PrintDbgStr(string.format("vrfma: OrdersVerification. B. tab[price]: %s (b_price - order_interval * cnt): %s res: %s", tostring(tab["price"]), tostring(b_price - order_interval * cnt), tostring(tostring(tab["price"]) == tostring(b_price - order_interval * cnt))))			
			if tostring(tab["price"]) == tostring(b_price - order_interval * cnt) then
				pos_not_used = false
--PrintDbgStr(string.format("vrfma: OrdersVerification. B. pos_not_used = false ����: %s", tostring(b_price - order_interval * cnt)))
				break
			end
		end
		if pos_not_used then
			SendTransBuySell(b_price - order_interval * cnt, 1, 'B')
		end
		pos_not_used = true
		for k3, tab in pairs(trades_tbl) do
--PrintDbgStr(string.format("vrfma: OrdersVerification. S. tab[price]: %s (b_price + order_interval * cnt): %s res: %s", tostring(tab["price"]), tostring(b_price + order_interval * cnt), tostring(tostring(tab["price"]) == tostring(b_price + order_interval * cnt))))
			if tostring(tab["price"]) == tostring(b_price + order_interval * cnt) then
				pos_not_used = false
--PrintDbgStr(string.format("vrfma: OrdersVerification. S. pos_not_used = false ����: %s", tostring(b_price + order_interval * cnt)))
				break
			end
		end
		if pos_not_used then
			SendTransBuySell(b_price + order_interval * cnt, 1, 'S')
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
		ExitMess()
		return false
	end
	
	trans_send_flag = false
	while true do
		while #MAIN_QUEUE_TRADES > 0 do	-- # �������� ����� ������� ���������� ���������� ������ ��������� �������
			-- ��������� ������� � ��������� � ���� � � ���
			PrintDbgStr(string.format("vrfma: ������� ����� �� ���������� %i ������ - %i order_num - %s msg:[%s]", 
											MAIN_QUEUE_TRADES[1].trans_id, 
											MAIN_QUEUE_TRADES[1].status, 
											tostring(MAIN_QUEUE_TRADES[1].order_num), 
											MAIN_QUEUE_TRADES[1].result_msg))
			file_log:write(string.format("%s ������� ����� �� ���������� %i ������ - %i order_num - %s msg:[%s]\n", 
											os.date(), 
											MAIN_QUEUE_TRADES[1].trans_id, 
											MAIN_QUEUE_TRADES[1].status, 
											tostring(MAIN_QUEUE_TRADES[1].order_num),
											MAIN_QUEUE_TRADES[1].result_msg))
			trans_send_flag = true
			table.sremove(MAIN_QUEUE_TRADES, 1)
		end
		while #QUEUE_SAVE_TRADES > 0 do
			PrintDbgStr(string.format("vrfma: ������� - ������ order_num: %s ����: %s ��������: %s twin: %s", 
											tostring(QUEUE_SAVE_TRADES[1].order_num),
											tostring(QUEUE_SAVE_TRADES[1].price),
											tostring(QUEUE_SAVE_TRADES[1].operation),
											tostring(QUEUE_SAVE_TRADES[1].twin)))
			file_log:write(string.format("%s ������� - ������ order_num: %s ����: %s ��������: %s twin: %s\n", 
											os.date(), 
											tostring(QUEUE_SAVE_TRADES[1].order_num),
											tostring(QUEUE_SAVE_TRADES[1].price),
											tostring(QUEUE_SAVE_TRADES[1].operation),
											tostring(QUEUE_SAVE_TRADES[1].twin)))
			SaveTradesTbl()	-- ��������� trades_tbl � ����
			table.sremove(QUEUE_SAVE_TRADES, 1)
		end
		sleep(10)
	end
	ExitMess()
end
