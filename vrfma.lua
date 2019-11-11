--[[
1 V ��������� ������ � ��� ���� �� ������������ � main
2 V ����� ������� ��������� ����� ���������� ���������
3 V ������� ������ ������ � ������� � ������ �������� ����� 10:01
4 ��������� ��������� ��� quantity ������ �������
5 ��������� �������� �� ������������ �������� ������� ���� � OnParam
6 ������� ���������� ����������� ��� ���� ������ � ������������ ����
7 ! �� ������� ���������� ������� � ������� � �������� !
8 ��� �������������� twin'�� ������� �������� �� ������� ����
9 ���������� � ������� ������ �� �������� 1
10 ���� �������� ������� �� ���� ������ ��� ������������� ������������ ������ ������ - ������ ������ ������
11 V ������� ������������ �/�� ������ "������ ����������" �������������� ��� ������ �� "�������� ���������" (������� � ������ ������� � ini)
12 ��� ����� � ������������ (�������������� ��������� � ini � ����������� � ������� SendTransBuySell ���� ����� ��������� ��-���������)
13 �� ���� ���� �� ������ ������ ���������� �� ����� ������ ��������� ������������� ������. ��� ����� ������ �������� 
	������ � ����� � ������� � �������������� � trades_tbl.dat
]]
function OnInit()	-- ������� - ������������� QUIK
	file_log = io.open(getScriptPath() .. "\\vrfma_" .. os.date("%Y%m%d_%H%M%S") .. ".log", "w")
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
		quantity = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ���������� ����� � ������: " .. quantity)
		file_log:write(os.date() .. " ������ vrfma.ini. ���������� ����� � ������: " .. quantity .. " \n")
		ban_new_ord = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ������ ����� ������: " .. ban_new_ord)
		file_log:write(os.date() .. " ������ vrfma.ini. ������ ����� ������: " .. ban_new_ord .. " \n")
		auto_border_check = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. �������������� �������� ������ �������� ������: " .. auto_border_check)
		file_log:write(os.date() .. " ������ vrfma.ini. �������������� �������� ������ �������� ������: " .. auto_border_check .. " \n")
		above_border = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ������� ������� �������� ���������: " .. above_border)
		file_log:write(os.date() .. " ������ vrfma.ini. ������� ������� �������� ���������: " .. above_border .. " \n")
		below_border = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ������ ������� �������� ���������: " .. below_border)
		file_log:write(os.date() .. " ������ vrfma.ini. ������ ������� �������� ���������: " .. below_border .. " \n")
		file_ini:close()
		order_interval = tonumber(order_interval)
		profit = tonumber(profit)
		quantity = tonumber(quantity)
		above_border = tonumber(above_border)
		below_border = tonumber(below_border)
	else
		load_error = true
		message("vrfma: ������ �������� vrfma.ini")
		PrintDbgStr("vrfma: ������ �������� vrfma.ini")
		file_log:write(os.date() .. "vrfma: ������ �������� vrfma.ini\n")
		return false
	end

	if tostring(ban_new_ord) == "false" then
		ban_new_ord = false
	else
		ban_new_ord = true
	end
	if tostring(auto_border_check) == "false" then
		auto_border_check = false
	else
		auto_border_check = true
	end
	file_name_for_load = getScriptPath() .. "\\trades_tbl.dat"
	trade_period = false
	CheckTradePeriod()
	start_deploying = true
	cold_start = true
	t0950ko = true
	t2350ko = true
	file_load_table = io.open(file_name_for_load, "r")
	if file_load_table ~= nil then
		PrintDbgStr(string.format("vrfma: �������� ������� �� trades_tbl.dat"))
		file_log:write(string.format("%s �������� ������� �� trades_tbl.dat\n", os.date()))
		local current_position = file_load_table:seek() 
		local size = file_load_table:seek("end")	-- file_load_table:seek("set",current_position)
		file_load_table:close()
		if tonumber(size) > 0 then
			cold_start = false
		end
	end
	trades_tbl = {}
	start_trades_tbl = {}
	if not cold_start then
		dofile(file_name_for_load)
	end
	
	free_TRANS_ID = os.time()	--��� ����������� ������������ free_TRANS_ID ������ ������ ����� ���������� ������� �������� �������
	QUEUE_SENDTRANSBUYSELL = {}
	QUEUE_SENDTRANSCLOSE = {}
	QUEUE_ONTRANSREPLY = {}
	QUEUE_ONTRADE = {}
	current_price = 0
	base_price = 0
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

function CheckTradePeriod()
	now_dt = os.date("*t", os.time())	-- PrintDbgStr(string.format("vrfma: CheckTradePeriod ����� - ���: %i ������: %i", now_dt.hour, now_dt.min))
	if (now_dt.hour > 10 and now_dt.hour < 23) or (now_dt.hour == 10 and now_dt.min > 0) or (now_dt.hour == 23 and now_dt.min < 50) then
		t0950ko = true
		t2350ko = true
		if not trade_period then
			trade_period = true
			PrintDbgStr(string.format("vrfma: �������� ������ FORTS �� ����. �����: %s", tostring(os.date())))
			file_log:write(os.date() .. " �������� ������ FORTS �� ����.")
		end
	else		
		if trade_period then
			trade_period = false
			KillAllOrders(instr_class, instr_name, client)
			PrintDbgStr(string.format("vrfma: ���������� ����� FORTS �� ���� ������� ������. �����: %s", tostring(os.date())))
			file_log:write(os.date() .. " ���������� ����� FORTS �� ���� ������� ������.")
		end
	end
	if now_dt.hour == 9 and now_dt.min > 49 and t0950ko then
		t0950ko = false
		PrintDbgStr(string.format("vrfma: ������ ������ ����� �������� �������. �����: %s", tostring(os.date())))
		file_log:write(os.date() .. " ������ ������ ����� �������� �������.")
		KillAllOrders(instr_class, instr_name, client)
	end
	if now_dt.hour == 23 and now_dt.min > 49 and t2350ko then
		t2350ko = false
		PrintDbgStr(string.format("vrfma: ������ ������ ����� �������� ������. �����: %s", tostring(os.date())))
		file_log:write(os.date() .. " ������ ������ ����� �������� ������.")
		KillAllOrders(instr_class, instr_name, client)
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

function NewBasePrice(test_price, curr_price)
	local delta = curr_price - test_price	--local delta = test_price - curr_price
	whole_part, fractional_part = math.modf(delta/order_interval)
	return test_price + order_interval * whole_part	--return curr_price + delta - order_interval * whole_part
end

function OnParam(class, sec)
	if class == instr_class and sec == instr_name then
		res = getParamEx(class, sec, "LAST")
		if res ~= 0 then
			PrintDbgStr(string.format("vrfma: %s: %.2f", instr_name, res.param_value))
			file_log:write(string.format("%s %s: %.2f\n", os.date(), instr_name, res.param_value))
			if tostring(current_price) == tostring(res.param_value) then
				return
--[[tostring(			elseif abs(current_price - res.param_value) > order_interval * 200 then
				PrintDbgStr(string.format("vrfma: ������! ������������ ����: %.2f", res.param_value))
				file_log:write(string.format("%s ������! ������������ ����: %.2f\n", os.date(), res.param_value))
				return	]]	--���� ������� ��������� ��������� ����, ����� ��� �������� ����� ����� ��������� ��� ������
			else
				current_price = tonumber(res.param_value)
			end
			if trade_period then
				if auto_border_check then
				-- ��������� �� ������������ �������� �������� ���������
					if current_price < above_border or current_price > below_border then
						if ban_new_ord and (current_price < (above_border * 0.985) or current_price > (below_border * 1.015)) then
							ban_new_ord = false
							PrintDbgStr(string.format("vrfma: ��������� � ������� �������� current_price: %.2f base_price: %.2f", current_price, base_price))
							file_log:write(string.format("%s ��������� � ������� �������� current_price: %.2f base_price: %.2f\n", os.date(), current_price, base_price))
							base_price = NewBasePrice(base_price, current_price)
							OrdersVerification(base_price)
						end
					else
				-- ����� �� ������� ���������. ��������� ������ ������ ������������
						if not ban_new_ord then
							ban_new_ord = true
							PrintDbgStr(string.format("vrfma: ����� �� ������� �������� ��������� current_price: %.2f", current_price))
							file_log:write(string.format("%s ����� �� ������� �������� ��������� current_price: %.2f\n", os.date(), current_price))
						--������� ������ ������ � ��������� twin'�
							for k, tab in pairs(trades_tbl) do
								if tostring(tab["status"]) == "2" and tostring(tab["twin"]) == "0" then
									SendTransClose(tab["number_sys"])
								end
							end
						end
					end
				end
			-- ������������� ��� ������
				if start_deploying then
					start_deploying = false
					if cold_start then
						base_price = res.param_value
						if not ban_new_ord then
							ColdStart(10, base_price)	--PrintDbgStr(string.format("vrfma: type(res.param_value): %s", type(res.param_value))) -- res.param_value: %.2f", type(tmp), tonumber(tmp)))
						end
						return
					else
						base_price = NewBasePrice(tonumber(trades_tbl[1]["price"]), current_price)	--trades_tbl ��������� �������� �.�. ������ ������� ������ ����
						PrintDbgStr(string.format("vrfma: ����������� base_price: %.2f", base_price))
						file_log:write(string.format("%s ����������� base_price: %.2f\n", os.date(), base_price))
						WarmStart(base_price, current_price)
						return
					end
				end

			-- ��� ��������� ���� ����� ��� �� order_interval * 1.6 ��������� ������ (��� ��������� �� order_interval ������ ����������� ������), ���� 	������ �� �������� base_price ��������� ��� ������
				if math.abs(current_price - base_price) > (order_interval * 1.6) and not ban_new_ord then
					PrintDbgStr(string.format("vrfma: ���� current_price: %.2f ����������� �� base_price: %.2f", current_price, base_price))
					base_price = NewBasePrice(base_price, current_price)
					OrdersVerification(base_price)
				end

			-- ���������� ������ base_price
	--[[tostring(			if (current_price > base_price and current_price < base_price + order_interval) or
					(current_price < base_price and current_price > base_price - order_interval) then
					local base_price_not_used = true
					for _, tab in pairs(trades_tbl) do
						if tab["price"] == base_price then
							base_price_not_used = false
							break
						end
					end
					if base_price_not_used and current_price > base_price then
						SendTransBuySell(base_price, quantity, 'B')
					elseif base_price_not_used and current_price < base_price then
						SendTransBuySell(base_price, quantity, 'S')
					end
				end	]]
			end
		end
	end
end

function ColdStart(counter, b_price)
	PrintDbgStr(string.format("vrfma: ColdStart"))
	file_log:write(string.format("%s ColdStart\n", os.date()))
	cold_start = false
	for cnt = 1, counter do
		SendTransBuySell(b_price - order_interval * cnt, quantity, 'B')
		sleep(110)
	end
	for cnt = 1, counter do
		SendTransBuySell(b_price + order_interval * cnt, quantity, 'S')
		sleep(110)
	end	
end

function WarmStart(b_price, c_price)
	PrintDbgStr(string.format("vrfma: WarmStart"))
	file_log:write(string.format("%s WarmStart\n", os.date()))
	for _, tab in pairs(start_trades_tbl) do		--������ twin-��
		if tab["operation"] == 'B' then
			if tonumber(c_price) > tonumber(tab["price"]) + profit then
				PrintDbgStr(string.format("vrfma: WarmStart. S. c_price+: %s (tab[price] + profit): %s status: %s", tostring(c_price), tostring((tab["price"] + profit)), tostring(tab["status"])))
				SendTransBuySell(c_price, quantity, 'S', tab["number_sys"])
			else
				PrintDbgStr(string.format("vrfma: WarmStart. S. c_price-: %s (tab[price] + profit): %s status: %s", tostring(c_price), tostring((tab["price"] + profit)), tostring(tab["status"])))
				SendTransBuySell(tab["price"] + profit, quantity, 'S', tab["number_sys"])
			end
		else
			if tonumber(c_price) < tonumber(tab["price"]) - profit then
				PrintDbgStr(string.format("vrfma: WarmStart. B. c_price+: %s (tab[price] - profit): %s status: %s", tostring(c_price), tostring((tab["price"] - profit)), tostring(tab["status"])))
				SendTransBuySell(c_price, quantity, 'B', tab["number_sys"])
			else
				PrintDbgStr(string.format("vrfma: WarmStart. B. c_price-: %s (tab[price] - profit): %s status: %s", tostring(c_price), tostring((tab["price"] - profit)), tostring(tab["status"])))
				SendTransBuySell(tab["price"] - profit, quantity, 'B', tab["number_sys"])
			end
		end
		sleep(110)
	end
	if not ban_new_ord then
		OrdersVerification(b_price)
	end
end

function ReadTradesTbl(tbl)
	table.sinsert(trades_tbl, {	["number_my"] = tbl["number_my"], 
								["number_sys"] = tbl["number_sys"], 
								["price"] = tbl["price"], 
								["operation"] = tbl["operation"], 
								["status"] = tbl["status"], 
								["twin"] = tbl["twin"],
								["quantity_current"] = tbl["quantity_current"]})
	table.sinsert(start_trades_tbl, {	["number_my"] = tbl["number_my"], 
										["number_sys"] = tbl["number_sys"], 
										["price"] = tbl["price"], 
										["operation"] = tbl["operation"], 
										["status"] = tbl["status"], 
										["twin"] = tbl["twin"],
										["quantity_current"] = tbl["quantity_current"]})
	PrintDbgStr(string.format("vrfma: �������� ������: ���������� %s ����: %s ��������: %s ����������: %s ������: %s twin: %s", 
									tostring(tbl["number_sys"]),
									tostring(tbl["price"]),
									tostring(tbl["operation"]),
									tostring(tbl["quantity_current"]),
									tostring(tbl["status"]),
									tostring(tbl["twin"])))
	file_log:write(string.format("%s �������� ������: ���������� %s ����: %s ��������: %s ����������: %s ������: %s twin: %s\n", 
									os.date(), 
									tostring(tbl["number_sys"]),
									tostring(tbl["price"]),
									tostring(tbl["operation"]),
									tostring(tbl["quantity_current"]),
									tostring(tbl["status"]),
									tostring(tbl["twin"])))
end
 
function SaveTradesTbl()
	file_save_table = io.open(getScriptPath() .. "\\trades_tbl.dat", "w+")
	if file_save_table ~= nil then
		for _, tab in pairs(trades_tbl) do
			if tostring(tab["status"]) == "3" then
				PrintDbgStr(string.format("vrfma: trades_tbl ������������� ��, ��� ��������� � ����. �����: %s ������: %s ��������: %s ����: %s twin: %s", tostring(tab["number_sys"]), tostring(tab["status"]), tostring(tab["operation"]), tostring(tab["price"]), tostring(tab["twin"])))
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
	for _, tab in pairs(trades_tbl) do
		PrintDbgStr(string.format("vrfma: �����: %s ������: %s ��������: %s ����: %s", tostring(tab["number_sys"]), tostring(tab["status"]), tostring(tab["operation"]), tostring(tab["price"])))
		file_log:write(string.format("	�����: %s ������: %s ��������: %s ����: %s\n", tostring(tab["number_sys"]), tostring(tab["status"]), tostring(tab["operation"]), tostring(tab["price"])))
	end	
	KillAllOrders(instr_class, instr_name, client)
	PrintDbgStr("vrfma: vrfma ��������")
	file_log:write(os.date() .. " vrfma ��������\n")
	file_log:close()
end

function OnClose()	-- ������� - �������� ��������� QUIK
	file_log:write(os.date() .. " ������� - �������� ��������� QUIK\n")
	-- ExitMess()
	return 0
end

function OnStop(flag)	-- ������� - ��������� �������
	file_log:write(os.date() .. " ������� - ��������� �������\n")
	ExitMess()
	return 0
end

function SendTransBuySell(price, quant, operation, twin_num)	-- �������� ������ �� �������/�������
	twin_num = twin_num or "0"
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
		transaction['QUANTITY'] = tostring(quant)
	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("vrfma: ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]", transaction.TRANS_ID, result))
		file_log:write(string.format("%s ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]\n", os.date(), transaction.TRANS_ID, result))
	else
		table.sinsert(trades_tbl, {	["number_my"] = free_TRANS_ID, 
									["number_sys"] = 0, 
									["price"] = price, 
									["operation"] = operation, 
									["status"] = "1", 
									["twin"] = twin_num,
									["quantity_current"] = quant}) --order_requests_buy[#order_requests_buy + 1] = free_TRANS_ID
		table.sinsert(QUEUE_SENDTRANSBUYSELL, {	trans_id = transaction.TRANS_ID,	--PrintDbgStr(string.format("vrfma: ���������� %s ����������. ��������: %s; ����: %s; ����������: %s ", transaction.TRANS_ID, operation, price, quant))
												price = price,
												operation = operation,
												quantity = quant,
												twin = twin_num})
	end
	free_TRANS_ID = free_TRANS_ID + 1	--����������� free_TRANS_ID
end

function SendTransClose(close_ID)		-- ������ ������ 
	local transaction = {}
		transaction['TRANS_ID'] = tostring(free_TRANS_ID)
		transaction['CLASSCODE'] = instr_class
		transaction['SECCODE'] = instr_name
		transaction['ACTION'] = 'KILL_ORDER'
		transaction['ORDER_KEY'] = tostring(close_ID)		--['������'] = tostring(close_ID)		["ORDER_KEY"]=tostring(getItem(ord,orders[i]).order_num)
	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("vrfma: ���������� %s �� ������ ������ %s �� ������ �������� �� ������� ��������� QUIK [%s]", free_TRANS_ID, close_ID, result))
		file_log:write(string.format("%s ���������� %s �� ������ ������ %s �� ������ �������� �� ������� ��������� QUIK [%s]\n", os.date(), free_TRANS_ID, close_ID, result))
	else
		price = 0
		for ind, tab in pairs(trades_tbl) do
			if tostring(tab["number_sys"]) == tostring(close_ID) then
				price = tab["price"]
				trades_tbl[ind] = nil
			end
		end
		table.sinsert(QUEUE_SENDTRANSCLOSE, {trans_id = transaction.TRANS_ID, close_id = close_ID, price_snd = price})		--PrintDbgStr(string.format("vrfma: ���������� %s ����������. ������ ������: %s", free_TRANS_ID, close_ID))
	end
	free_TRANS_ID = free_TRANS_ID + 1	-- ����������� free_TRANS_ID
end

function OnTransReply(trans_reply)	-- ������������� ������
	--PrintDbgStr(string.format("vrfma: OnTransReply trans_reply.trans_id: %s", tostring(trans_reply.trans_id)))
	for _, tab in pairs(trades_tbl) do
		--PrintDbgStr(string.format("vrfma: 'for' trans_reply.trans_id: %s tab[number_my]: %s trans_reply.status: %s tab[quantity_current]: %s", tostring(trans_reply.trans_id), tostring(tab["number_my"]), tostring(trans_reply.status), tostring(tab["quantity_current"])))
		if tostring(trans_reply.trans_id) == tostring(tab["number_my"]) then
			if tostring(trans_reply.status) == "3" then
				tab["number_sys"] = trans_reply.order_num
				tab["status"] = "2"				
				table.sinsert(QUEUE_ONTRANSREPLY, {	trans_id = trans_reply.trans_id, 
													status = trans_reply.status,
													order_num = trans_reply.order_num,
													result_msg = trans_reply.result_msg,
													quantity_current = trans_reply.quantity})
			end
			break
		end
	end
end

function OnTrade(trade)	-- ������� - QUIK ������� ������
	PrintDbgStr(string.format("vrfma: OnTrade trade.order_num: %s price: %s", tostring(trade.order_num), trade.price))
	for ind_1, tab in pairs(trades_tbl) do
		-- PrintDbgStr(string.format("vrfma: 'for' trade.order_num: %s tab[number_sys]: %s tab[status]: %s tab[quantity_current]: %s", tostring(trade.order_num), tostring(tab["number_sys"]), tostring(tab["status"]), tostring(tab["quantity_current"])))
		if tostring(tab["number_sys"]) == tostring(trade.order_num) and tostring(tab["status"]) ~= "3" then
			table.sinsert(QUEUE_ONTRADE, {	order_num = trade.order_num,
											price = trade.price,
											operation = tab["operation"],
											quantity_current = trade.qty,
											twin = tab["twin"]}) 
			base_price = tab["price"]
			if tostring(tab["twin"]) == "0" then
				tab["status"] = "3"
				if tab["operation"] == 'B' then
					SendTransBuySell(tab["price"] + profit, quantity, 'S', tab["number_sys"])
				else
					SendTransBuySell(tab["price"] - profit, quantity, 'B', tab["number_sys"])
				end
			else	--�������� twin. ������� ������ � twin
for ind_n, tab_n in pairs(trades_tbl) do
	PrintDbgStr(string.format("vrfma: trades_tbl ������������� �� �������� ����� ���: %s ����� �������: %s ������: %s ��������: %s ����: %s twin: %s ���-��: %s", 
										tostring(tab_n["number_my"]), 
										tostring(tab_n["number_sys"]), 
										tostring(tab_n["status"]), 
										tostring(tab_n["operation"]), 
										tostring(tab_n["price"]), 
										tostring(tab_n["twin"]),
										tostring(tab_n["quantity_current"])))
end
				for ind_2, tab_2 in pairs(trades_tbl) do
					if tostring(tab["twin"]) == tostring(tab_2["number_sys"]) then
						PrintDbgStr(string.format("vrfma: �������� twin. ������� ������ tab[number_sys]: %s � twin tab[twin]: %s tab_2[number_sys]: %s", tostring(tab_n["number_sys"]), tostring(tab["number_sys"]), tostring(tab["twin"]), tostring(tab_2["number_sys"])))
						trades_tbl[ind_2] = nil
						break
					end
				end
				trades_tbl[ind_1] = nil
for ind_n, tab_n in pairs(trades_tbl) do
	PrintDbgStr(string.format("vrfma: trades_tbl ������������� ����� �������� ����� ���: %s ����� �������: %s ������: %s ��������: %s ����: %s twin: %s ���-��: %s", 
										tostring(tab_n["number_my"]), 
										tostring(tab_n["number_sys"]), 
										tostring(tab_n["status"]), 
										tostring(tab_n["operation"]), 
										tostring(tab_n["price"]), 
										tostring(tab_n["twin"]),
										tostring(tab_n["quantity_current"])))
end
			end
			if not ban_new_ord then
				OrdersVerification(base_price)
			end
			break
		end
	end
end

function OrdersVerification(b_price)
	PrintDbgStr(string.format("vrfma: OrdersVerification. ����: %s", tostring(b_price)))
--������� ������ ������ � ��������� twin'�
	for k1, tab in pairs(trades_tbl) do
		if tostring(tab["status"]) == "2" and tostring(tab["twin"]) == "0" then
			if (tonumber(tab["price"]) > tonumber(b_price) and tostring(tab["operation"]) == 'B') 
					or (tonumber(tab["price"]) < tonumber(b_price) and tostring(tab["operation"]) == 'S') then
				SendTransClose(tab["number_sys"])
			end
			if tonumber(tab["price"]) > tonumber(b_price) + order_interval * 10
					or tonumber(tab["price"]) < tonumber(b_price) - order_interval * 10 then
				SendTransClose(tab["number_sys"])
			end
		end
		if tostring(tab["status"]) == "3" and tostring(tab["twin"]) == "0" then
			istwin = false
			for k4, tab2 in pairs(trades_tbl) do
				if tostring(tab["number_sys"]) == tostring(tab2["twin"]) then
					istwin = true
				end
			end
			if not istwin then
				PrintDbgStr(string.format("vrfma: ���������� ������ twin'�. ��� twin'� � ������ number_sys: %s", tostring(tab["number_sys"])))
				if tab["operation"] == 'B' then
					SendTransBuySell(b_price + profit, quantity, 'S', tab["number_sys"])
				else
					SendTransBuySell(b_price - profit, quantity, 'B', tab["number_sys"])
				end
			end
		end
	end
--������ ����� ������			
	local pos_not_used
	for cnt = 1, 10 do
		pos_not_used = true
		for k2, tab in pairs(trades_tbl) do
			-- PrintDbgStr(string.format("vrfma: OrdersVerification. B. tab[price]: %s (b_price - order_interval * cnt): %s res: %s", tostring(tab["price"]), tostring(b_price - order_interval * cnt), tostring(tostring(tab["price"]) == tostring(b_price - order_interval * cnt))))			
			if tostring(tab["price"]) == tostring(b_price - order_interval * cnt) and tostring(tab["twin"]) == "0" then
				pos_not_used = false
				PrintDbgStr(string.format("vrfma: OrdersVerification. B. pos_not_used = false ����: %s", tostring(b_price - order_interval * cnt)))
				break
			end
		end
		if pos_not_used then
			SendTransBuySell(b_price - order_interval * cnt, quantity, 'B')
		end
		pos_not_used = true
		for k3, tab in pairs(trades_tbl) do
			-- PrintDbgStr(string.format("vrfma: OrdersVerification. S. tab[price]: %s (b_price + order_interval * cnt): %s res: %s", tostring(tab["price"]), tostring(b_price + order_interval * cnt), tostring(tostring(tab["price"]) == tostring(b_price + order_interval * cnt))))
			if tostring(tab["price"]) == tostring(b_price + order_interval * cnt) and tostring(tab["twin"]) == "0" then
				pos_not_used = false
				PrintDbgStr(string.format("vrfma: OrdersVerification. S. pos_not_used = false ����: %s", tostring(b_price + order_interval * cnt)))
				break
			end
		end
		if pos_not_used then
			SendTransBuySell(b_price + order_interval * cnt, quantity, 'S')
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
		while #QUEUE_SENDTRANSBUYSELL > 0 do
			PrintDbgStr(string.format("vrfma: ������ ������ �� ������ SendTransBuySell: ���������� %s ����: %s ��������: %s ����������: %s twin: %s", 
											tostring(QUEUE_SENDTRANSBUYSELL[1].trans_id),
											tostring(QUEUE_SENDTRANSBUYSELL[1].price),
											tostring(QUEUE_SENDTRANSBUYSELL[1].operation),
											tostring(QUEUE_SENDTRANSBUYSELL[1].quantity),
											tostring(QUEUE_SENDTRANSBUYSELL[1].twin)))
			file_log:write(string.format("%s ������ ������ �� ������ SendTransBuySell: ���������� %s ����: %s ��������: %s ����������: %s twin: %s\n", 
											os.date(), 
											tostring(QUEUE_SENDTRANSBUYSELL[1].trans_id),
											tostring(QUEUE_SENDTRANSBUYSELL[1].price),
											tostring(QUEUE_SENDTRANSBUYSELL[1].operation),
											tostring(QUEUE_SENDTRANSBUYSELL[1].quantity),
											tostring(QUEUE_SENDTRANSBUYSELL[1].twin)))
			table.sremove(QUEUE_SENDTRANSBUYSELL, 1)
		end
		while #QUEUE_SENDTRANSCLOSE > 0 do
			PrintDbgStr(string.format("vrfma: ������� ������ SendTransClose: ���������� %s ������ ������: %s ����: %s", 
											tostring(QUEUE_SENDTRANSCLOSE[1].trans_id),
											tostring(QUEUE_SENDTRANSCLOSE[1].close_id),
											tostring(QUEUE_SENDTRANSCLOSE[1].price_snd)))
			file_log:write(string.format("%s ������� ������ SendTransClose: ���������� %s ������ ������: %s ����: %s\n", 
											os.date(), 
											tostring(QUEUE_SENDTRANSCLOSE[1].trans_id),
											tostring(QUEUE_SENDTRANSCLOSE[1].close_id),
											tostring(QUEUE_SENDTRANSCLOSE[1].price_snd)))
			table.sremove(QUEUE_SENDTRANSCLOSE, 1)
		end
		while #QUEUE_ONTRANSREPLY > 0 do	-- # �������� ����� ������� ���������� ���������� ������ ��������� �������
			PrintDbgStr(string.format("vrfma: ������� ����� OnTransReply �� ���������� %s ������ - %i order_num - %s ���������� - %i msg:[%s]", 
											tostring(QUEUE_ONTRANSREPLY[1].trans_id), 
											QUEUE_ONTRANSREPLY[1].status, 
											tostring(QUEUE_ONTRANSREPLY[1].order_num),
											QUEUE_ONTRANSREPLY[1].quantity_current,
											QUEUE_ONTRANSREPLY[1].result_msg))
			file_log:write(string.format("%s ������� ����� OnTransReply �� ���������� %s ������ - %i order_num - %s ���������� - %i msg:[%s]\n", 
											os.date(), 
											tostring(QUEUE_ONTRANSREPLY[1].trans_id), 
											QUEUE_ONTRANSREPLY[1].status, 
											tostring(QUEUE_ONTRANSREPLY[1].order_num),
											QUEUE_ONTRANSREPLY[1].quantity_current,
											QUEUE_ONTRANSREPLY[1].result_msg))
			trans_send_flag = true
			table.sremove(QUEUE_ONTRANSREPLY, 1)
		end
		while #QUEUE_ONTRADE > 0 do
			PrintDbgStr(string.format("vrfma: ������ OnTrade order_num: %s ����: %s ��������: %s ���������� - %s twin: %s", 
											tostring(QUEUE_ONTRADE[1].order_num),
											tostring(QUEUE_ONTRADE[1].price),
											tostring(QUEUE_ONTRADE[1].operation),
											tostring(QUEUE_ONTRADE[1].quantity_current),
											tostring(QUEUE_ONTRADE[1].twin)))
			file_log:write(string.format("%s ������ OnTrade order_num: %s ����: %s ��������: %s ���������� - %s twin: %s\n", 
											os.date(), 
											tostring(QUEUE_ONTRADE[1].order_num),
											tostring(QUEUE_ONTRADE[1].price),
											tostring(QUEUE_ONTRADE[1].operation),
											tostring(QUEUE_ONTRADE[1].quantity_current),
											tostring(QUEUE_ONTRADE[1].twin)))
			SaveTradesTbl()	-- ��������� trades_tbl � ����
			table.sremove(QUEUE_ONTRADE, 1)
		end
		CheckTradePeriod()
		sleep(10)
	end
	ExitMess()
end
