--[[
1 V ��������� ������ � ��� ���� �� ������������ � main
2 V ����� ������� ��������� ����� ���������� ���������
3 V ������� ������ ������ � ������� � ������ �������� ����� 10:01
4 _��������� ��������� ��� quantity ������ �������
5 ��������� �������� �� ������������ �������� ������� ���� � OnParam
6 v ������� ���������� ����������� ��� ���� ������ � ������������ ����
7 ! �� ������� ���������� ������� � ������� � �������� !
8 ��� �������������� twin'�� ������� �������� �� ������� ����
9 info ���������� � ������� ������ �� �������� 1
10 info ���� �������� ������� �� ���� ������ ��� ������������� ������������ ������ ������ - ������ ������ ������
11 v �������� ���� ������� ������ � �� ������� ������ ��� ���������, � �� ������� ��. 
	 ������� ������������ �/�� ������ "������ ����������" �������������� ��� ������ �� "�������� ���������" (������� � ������ ������� � ini)
12 V ��� ����� � ������������ (�������������� ��������� � ini � ����������� � ������� SendTransBuySell ���� ����� ��������� ��-���������)
13 V �� ���� ���� �� ������ ������ ���������� �� ����� ������ ��������� ������������� ������. ��� ����� ������ �������� 
	������ � ����� � ������� � �������������� � trades_tbl.dat
14 info �� ������� ������ ������ �������������� �� ���� �� ��������� � ������ (� ����� ������ ������� ��������)
15 info � 9.50 ���� �� MTLR 11/15/19 09:50:11 MTLR: 0.00		11/15/19 09:50:12 MTLR: 0.00
16 �������� ������� �������� 2� ������ �� ����� �� ����! info ������������ ���� � ������� ������ ������������ � ������ "������ ����������" ��. ���
17 �������� �������� � ���������. �������� ���� ������� ������������ �������� �� ������� ������
18 v �������� ��������� ��������. ������ �������� ��� �� ���������. ������ ��������� ��������, �� ���������� � ������� ���������
19 ����������� �� ���������� � ������� ��� ����������� twin-��
20 ����� ������������ OrdVer �� twin �������� ��� �������...
]]
function OnInit()	-- ������� - ������������� QUIK
	file_log = io.open(getScriptPath() .. "\\logs\\" .. os.date("%Y%m%d_%H%M%S") .. "_vrfma.log", "w")
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
		account_alt = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. ����� ��������������� �����: " .. account_alt)
		file_log:write(os.date() .. " ������ vrfma.ini. ����� ��������������� �����: " .. account_alt .. " \n")
		client_alt = file_ini:read("*l")
		PrintDbgStr("vrfma: ������ vrfma.ini. �������������� ��� �������: " .. client_alt)
		file_log:write(os.date() .. " ������ vrfma.ini. �������������� ��� �������: " .. client_alt .. " \n")
		file_ini:close()
		order_interval = tonumber(order_interval)
		profit = tonumber(profit)
		quantity = tonumber(quantity)
		above_border = tonumber(above_border)
		below_border = tonumber(below_border)
		prev_instr_name = nil
		prev_instr_class = nil
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
		if ban_new_ord then
			auto_border_check = false
		else
			auto_border_check = true
		end
	end
	alt_client_use = false
	if client ~= client_alt then
		alt_client_use = true
	end
	prev_client_main = false
	file_name_for_load = getScriptPath() .. "\\trades_tbl.dat"
	trade_period = false
	CheckTradePeriod()
	start_deploying = true
	cold_start = true
	t0950ko = true
	t2350ko = true
	timer_done = false
	timer_start = false
-- min_precision ������ ������!!!!!
	min_precision = 0.01
	clearing_test_count = 6000
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
	if not cold_start and trades_tbl[1]["instr_name"] ~= instr_name then
		prev_instr_name = trades_tbl[1]["instr_name"]
		prev_instr_class = trades_tbl[1]["instr_class"]
		PrintDbgStr(string.format("vrfma: ����� ���������� instr_name: %s ���������� ���������� prev_instr_name: %s", instr_name, prev_instr_name))
		file_log:write(string.format("%s ����� ���������� instr_name: %s ���������� ���������� prev_instr_name: %s\n", os.date(), instr_name, prev_instr_name))
	end
	
	free_TRANS_ID = os.time()	--��� ����������� ������������ free_TRANS_ID ������ ������ ����� ���������� ������� �������� �������
	QUEUE_SENDTRANSBUYSELL = {}
	QUEUE_SENDTRANSCLOSE = {}
	QUEUE_ONTRANSREPLY = {}
	QUEUE_ONTRADE = {}
	current_price = 0
	base_price = 0

	KillAllOrdersAdapter(client, client_alt, alt_client_use, instr_class, instr_name, prev_instr_name, prev_instr_class)

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
	local now_dt = os.date("*t", os.time())	-- PrintDbgStr(string.format("vrfma: CheckTradePeriod ����� - ���: %i ������: %i", now_dt.hour, now_dt.min))
	if (tonumber(now_dt.hour) > 10 and tonumber(now_dt.hour) < 23) or (tonumber(now_dt.hour) == 10 and tonumber(now_dt.min) > 0) or (tonumber(now_dt.hour) == 23 and tonumber(now_dt.min) < 50) then
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
			KillAllOrdersAdapter(client, client_alt, alt_client_use, instr_class, instr_name, prev_instr_name, prev_instr_class)
			PrintDbgStr(string.format("vrfma: ���������� ����� FORTS �� ���� ������� ������. �����: %s", tostring(os.date())))
			file_log:write(os.date() .. " ���������� ����� FORTS �� ���� ������� ������.")
		end
	end
	if tonumber(now_dt.hour) == 9 and tonumber(now_dt.min) > 49 and t0950ko then
		t0950ko = false
		PrintDbgStr(string.format("vrfma: ������ ������ ����� �������� �������. �����: %s", tostring(os.date())))
		file_log:write(os.date() .. " ������ ������ ����� �������� �������.")
		KillAllOrdersAdapter(client, client_alt, alt_client_use, instr_class, instr_name, prev_instr_name, prev_instr_class)
	end
	if tonumber(now_dt.hour) == 23 and tonumber(now_dt.min) > 49 and t2350ko then
		t2350ko = false
		PrintDbgStr(string.format("vrfma: ������ ������ ����� �������� ������. �����: %s", tostring(os.date())))
		file_log:write(os.date() .. " ������ ������ ����� �������� ������.")
		KillAllOrdersAdapter(client, client_alt, alt_client_use, instr_class, instr_name, prev_instr_name, prev_instr_class)
	end
end

function KillAllOrdersAdapter(client_in, client_alt_in, alt_client_use_in, instr_class_in, instr_name_in, prev_instr_name_in, prev_instr_class_in)
	KillAllOrders(instr_class_in, instr_name_in, client_in)
	if prev_instr_name_in ~= nil then
		KillAllOrders(prev_instr_class_in, prev_instr_name_in, client_in)
	end
	if alt_client_use_in then
		KillAllOrders(instr_class_in, instr_name_in, client_alt_in)
		if prev_instr_name_in ~= nil then
			KillAllOrders(prev_instr_class_in, prev_instr_name_in, client_alt_in)
		end
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

function ClearingTest()
	PrintDbgStr(string.format("vrfma: �������� �� �������"))
	file_log:write(string.format("%s �������� �� �������\n", os.date()))
	print_table = false
	number_sys_forsearch = 0

	function myFindClearing(ON, F)
		return (ON == number_sys_forsearch) and (bit.band(F, 0x1) ~= 0)
	end

	for _, tab in pairs(trades_tbl) do
		if tostring(tab["status"]) == "2" then	
			number_sys_forsearch = tab["number_sys"]
			local ord = "orders"
			local orders = SearchItems(ord, 0, getNumberOf(ord)-1, myFindClearing, "order_num,flags")
			if (orders == nil) or (#orders == 0) then
				PrintDbgStr(string.format("vrfma: ������ %s �� ������� trades_tbl �� ������� � ������� (orders)", tostring(number_sys_forsearch)))
				file_log:write(string.format("%s ������ %s �� ������� trades_tbl �� ������� � ������� (orders)\n", os.date(), tostring(number_sys_forsearch)))			
				print_table = true
			end
		end
	end
	if print_table then
		for _, tab_n in pairs(trades_tbl) do
			PrintDbgStr(string.format("vrfma: ������������� trades_tbl ����� ���: %s ����� �������: %s ������: %s ��������: %s ����: %s twin: %s ���-��: %s account: %s client: %s instr_name: %s instr_class: %s", 
												tostring(tab_n["number_my"]), 
												tostring(tab_n["number_sys"]), 
												tostring(tab_n["status"]), 
												tostring(tab_n["operation"]), 
												tostring(tab_n["price"]), 
												tostring(tab_n["twin"]),
												tostring(tab_n["quantity_current"]),
												tostring(tab_n["account"]),
												tostring(tab_n["client"]),
												tostring(tab_n["instr_name"]),
												tostring(tab_n["instr_class"]),
												tostring(tab_n["profit"])))
		end
	end
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
			PrintDbgStr(string.format("vrfma: %s %s: %.2f", os.date(), instr_name, res.param_value))
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
					if ban_new_ord and current_price < (above_border * 0.988) and current_price > (below_border * 1.015) then	-- 0.998) and current_price > (below_border * 1.003) then
						ban_new_ord = false
						PrintDbgStr(string.format("vrfma: ��������� � ������� �������� current_price: %.2f base_price: %.2f", current_price, base_price))
						file_log:write(string.format("%s ��������� � ������� �������� current_price: %.2f base_price: %.2f\n", os.date(), current_price, base_price))
						base_price = NewBasePrice(base_price, current_price)
						OrdersVerification(base_price)
					end
					if not ban_new_ord and (current_price > above_border or current_price < below_border) then
				-- ����� �� ������� ���������. ��������� ������ ������ ������������
						ban_new_ord = true
						PrintDbgStr(string.format("vrfma: ����� �� ������� �������� ��������� current_price: %.2f", current_price))
						file_log:write(string.format("%s ����� �� ������� �������� ��������� current_price: %.2f\n", os.date(), current_price))
					--������� ������ ������
						for k, tab in pairs(trades_tbl) do
							if tostring(tab["status"]) == "2" and tostring(tab["twin"]) == "0" then
								SendTransClose(tab["number_sys"])
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
						if prev_instr_name == nil then
							base_price = NewBasePrice(tonumber(trades_tbl[1]["price"]), current_price)	--trades_tbl ��������� �������� �.�. ������ ������� ������ ����
							PrintDbgStr(string.format("vrfma: ����������� base_price: %.2f", base_price))
							file_log:write(string.format("%s ����������� base_price: %.2f\n", os.date(), base_price))
						else
							base_price = current_price
							PrintDbgStr(string.format("vrfma: ����� ���������� base_price = current_price: %.2f", base_price))
							file_log:write(string.format("%s ����� ���������� base_price = current_price: %.2f\n", os.date(), base_price))
						end
						WarmStart(base_price, current_price)
						return
					end
				end
			-- ��� ��������� ���� ����� ��� �� order_interval * 1.6 ��������� ������ (��� ��������� �� order_interval ������ ����������� ������), ���� 	������ �� �������� base_price ��������� ��� ������
				if math.abs(current_price - base_price) > (order_interval * 1.6) and not ban_new_ord then
					if timer_done then
						PrintDbgStr(string.format("vrfma: ���� current_price: %.2f ����������� �� base_price: %.2f", current_price, base_price))
						base_price = NewBasePrice(base_price, current_price)
						OrdersVerification(base_price)
					else
						timer_start = true
					end
				end
				timer_done = false
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
	GapFilling(c_price)
	for _, tab in pairs(start_trades_tbl) do		--������ twin-��
		if tab["operation"] == 'B' then
			if tab["instr_name"] == instr_name and tonumber(c_price) > tonumber(tab["price"]) + profit then
				PrintDbgStr(string.format("vrfma: WarmStart. S. c_price(min_precision)+: %s (tab[price] + profit): %s status: %s account: %s client: %s instr_name: %s instr_class: %s ������� instr_name: %s profit: %s", 
									tostring(c_price - tonumber(min_precision)), 
									tostring(tab["price"] + profit), 
									tostring(tab["status"]),
									tostring(tab["account"]),
									tostring(tab["client"]),
									tab["instr_name"],
									tostring(tab["instr_class"]),
									instr_name,
									tostring(tab["profit"])))
				SendTransBuySell(c_price - tonumber(min_precision), quantity, 'S', tab["number_sys"], tab["account"], tab["client"], tab["instr_name"], tab["instr_class"], tab["profit"])
			else
				PrintDbgStr(string.format("vrfma: WarmStart. S. c_price-: %s (tab[price] + profit): %s status: %s account: %s client: %s instr_name: %s instr_class: %s ������� instr_name: %s profit: %s", 
									tostring(c_price), 
									tostring(tab["price"] + profit), 
									tostring(tab["status"]),
									tostring(tab["account"]),
									tostring(tab["client"]),
									tab["instr_name"],
									tostring(tab["instr_class"]),
									instr_name,
									tostring(tab["profit"])))
				SendTransBuySell(tab["price"] + profit, quantity, 'S', tab["number_sys"], tab["account"], tab["client"], tab["instr_name"], tab["instr_class"], tab["profit"])
			end
		else
			if tab["instr_name"] == instr_name and tonumber(c_price) < tonumber(tab["price"]) - profit then
				PrintDbgStr(string.format("vrfma: WarmStart. B. c_price(min_precision)+: %s (tab[price] - profit): %s status: %s account: %s client: %s instr_name: %s instr_class: %s ������� instr_name: %s profit: %s", 
									tostring(c_price + tonumber(min_precision)), 
									tostring(tab["price"] - profit), 
									tostring(tab["status"]),
									tostring(tab["account"]),
									tostring(tab["client"]),
									tab["instr_name"],
									tostring(tab["instr_class"]),
									instr_name,
									tostring(tab["profit"])))
				SendTransBuySell(c_price + tonumber(min_precision), quantity, 'B', tab["number_sys"], tab["account"], tab["client"], tab["instr_name"], tab["instr_class"], tab["profit"])
			else
				PrintDbgStr(string.format("vrfma: WarmStart. B. c_price-: %s (tab[price] - profit): %s status: %s account: %s client: %s instr_name: %s instr_class: %s ������� instr_name: %s profit: %s", 
									tostring(c_price), 
									tostring(tab["price"] - profit), 
									tostring(tab["status"]),
									tostring(tab["account"]),
									tostring(tab["client"]),
									tab["instr_name"],
									tostring(tab["instr_class"]),
									instr_name,
									tostring(tab["profit"])))
				SendTransBuySell(tab["price"] - profit, quantity, 'B', tab["number_sys"], tab["account"], tab["client"], tab["instr_name"], tab["instr_class"], tab["profit"])
			end
		end
		sleep(110)
	end
	if not ban_new_ord then
		OrdersVerification(b_price)
	end
end

function GapFilling(c_price_in)
	s_greater = 0
	b_minor = 1000000
	for _, tab in pairs(start_trades_tbl) do
		if tab["operation"] == 'S' then
			if tab["instr_name"] == instr_name and tonumber(tab["price"]) > s_greater then
				s_greater = tonumber(tab["price"])
				s_account = tab["account"]
				s_client = tab["client"]
			end
		else
			if tab["instr_name"] == instr_name and tonumber(tab["price"]) < b_minor then
				b_minor = tonumber(tab["price"])
				b_account = tab["account"]
				b_client = tab["client"]
			end
		end
	end
	PrintDbgStr(string.format("vrfma: ����� ���� c_price_in: %s s_greater: %s b_minor: %s", tostring(c_price_in), tostring(s_greater), tostring(b_minor)))
	file_log:write(string.format("%s ����� ���� c_price_in: %s s_greater: %s b_minor: %s\n", os.date(), tostring(c_price_in), tostring(s_greater), tostring(b_minor)))
-- ���� � ������������ ���
	if tonumber(s_greater) ~= 0 and tonumber(c_price_in) > tonumber(s_greater) + order_interval and tonumber(b_minor) == 1000000 then
		hole_part, fractional_part = math.modf((tonumber(c_price_in) - tonumber(s_greater))/order_interval)
		PrintDbgStr(string.format("vrfma: ��������� ���. S. c_price_in: %s s_greater: %s ����� ������� �����: %s ", 
									tostring(c_price_in), 
									tostring(s_greater), 
									tostring(hole_part)))
		file_log:write(string.format("%s ��������� ���. S. c_price_in: %s s_greater: %s ����� ������� �����: %s \n", 
									os.date(),
									tostring(c_price_in), 
									tostring(s_greater), 
									tostring(hole_part)))
		if tonumber(hole_part) > 12 then
			hole_part = 12
			PrintDbgStr(string.format("vrfma: ����������� ����. S. hole_part: %s ������������ �� 12", tostring(hole_part)))
			file_log:write(string.format("%s ����������� ����. S. hole_part: %s ������������ �� 12\n", os.date(), tostring(hole_part)))
		end
		SendTransBuySell(c_price_in - tonumber(min_precision), hole_part * quantity, 'S', "0", s_account, s_client, instr_name, instr_class, profit, false)
		for cnt = 1, hole_part do
			table.sinsert(trades_tbl, {	["number_my"] = free_TRANS_ID, 
										["number_sys"] = 0, 
										["price"] = tonumber(s_greater) + order_interval * cnt, 
										["operation"] = 'S', 
										["status"] = "3", 
										["twin"] = "0",
										["quantity_current"] = quantity,
										["account"] = s_account,
										["client"] = s_client,
										["instr_name"] = instr_name,
										["instr_class"] = instr_class,
										["profit"] = profit})
			table.sinsert(start_trades_tbl, {	["number_my"] = free_TRANS_ID, 
												["number_sys"] = 0, 
												["price"] = tonumber(s_greater) + order_interval * cnt, 
												["operation"] = 'S', 
												["status"] = "3", 
												["twin"] = "0",
												["quantity_current"] = quantity,
												["account"] = s_account,
												["client"] = s_client,
												["instr_name"] = instr_name,
												["instr_class"] = instr_class,
												["profit"] = profit})
			PrintDbgStr(string.format("vrfma: ������� ������: ���������� %s ����: %s ��������: S ����������: %s ������: 3 twin: 0 account: %s client: %s instr_name: %s instr_class: %s profit: %s", 
											tostring(free_TRANS_ID),
											tostring(tonumber(s_greater) + order_interval * cnt),
											tostring(quantity),
											tostring(s_account),
											tostring(s_client),
											tostring(instr_name),
											tostring(instr_class),
											tostring(profit)))
			file_log:write(string.format("%s ������� ������: ���������� %s ����: %s ��������: S ����������: %s ������: 3 twin: 0 account: %s client: %s instr_name: %s instr_class: %s profit: %s\n", 
											os.date(), 
											tostring(free_TRANS_ID),
											tostring(tonumber(s_greater) + order_interval * cnt),
											tostring(quantity),
											tostring(s_account),
											tostring(s_client),
											tostring(instr_name),
											tostring(instr_class),
											tostring(profit)))
			free_TRANS_ID = free_TRANS_ID + 1	-- ����������� free_TRANS_ID
		end
	end
	if tonumber(b_minor) ~= 1000000 and tonumber(c_price_in) < tonumber(b_minor) - order_interval and tonumber(s_greater) == 0 then
		hole_part, fractional_part = math.modf((tonumber(b_minor) - tonumber(c_price_in))/order_interval)
		PrintDbgStr(string.format("vrfma: ��������� ���. B. c_price_in: %s b_minor: %s ����� ����������� �����: %s ", 
									tostring(c_price_in), 
									tostring(b_minor), 
									tostring(hole_part)))
		file_log:write(string.format("%s ��������� ���. B. c_price_in: %s b_minor: %s ����� ����������� �����: %s \n", 
									os.date(),
									tostring(c_price_in), 
									tostring(b_minor), 
									tostring(hole_part)))
		if tonumber(hole_part) > 12 then
			hole_part = 12
			PrintDbgStr(string.format("vrfma: ����������� ����. B. hole_part: %s ������������ �� 12", tostring(hole_part)))
			file_log:write(string.format("%s ����������� ����. B. hole_part: %s ������������ �� 12\n", os.date(), tostring(hole_part)))
		end
		SendTransBuySell(c_price_in + tonumber(min_precision), hole_part * quantity, 'B', "0", s_account, s_client, instr_name, instr_class, profit, false)
		for cnt = 1, hole_part do
			table.sinsert(trades_tbl, {	["number_my"] = free_TRANS_ID, 
										["number_sys"] = 0, 
										["price"] = tonumber(b_minor) - order_interval * cnt, 
										["operation"] = 'B', 
										["status"] = "3", 
										["twin"] = "0",
										["quantity_current"] = quantity,
										["account"] = s_account,
										["client"] = s_client,
										["instr_name"] = instr_name,
										["instr_class"] = instr_class,
										["profit"] = profit})
			table.sinsert(start_trades_tbl, {	["number_my"] = free_TRANS_ID, 
												["number_sys"] = 0, 
												["price"] = tonumber(b_minor) - order_interval * cnt, 
												["operation"] = 'B', 
												["status"] = "3", 
												["twin"] = "0",
												["quantity_current"] = quantity,
												["account"] = s_account,
												["client"] = s_client,
												["instr_name"] = instr_name,
												["instr_class"] = instr_class,
												["profit"] = profit})
			PrintDbgStr(string.format("vrfma: ������� ������: ���������� %s ����: %i ��������: B ����������: %s ������: 3 twin: 0 account: %s client: %s instr_name: %s instr_class: %s profit: %s", 
											tostring(free_TRANS_ID),
											tonumber(b_minor) - order_interval * cnt,
											tostring(quantity),
											tostring(s_account),
											tostring(s_client),
											tostring(instr_name),
											tostring(instr_class),
											tostring(profit)))
			file_log:write(string.format("%s ������� ������: ���������� %s ����: %i ��������: B ����������: %s ������: 3 twin: 0 account: %s client: %s instr_name: %s instr_class: %s profit: %s\n", 
											os.date(), 
											tostring(free_TRANS_ID),
											tonumber(b_minor) - order_interval * cnt,
											tostring(quantity),
											tostring(s_account),
											tostring(s_client),
											tostring(instr_name),
											tostring(instr_class),
											tostring(profit)))
			free_TRANS_ID = free_TRANS_ID + 1	-- ����������� free_TRANS_ID
		end
	end
end

function ReadTradesTbl(tbl)
	table.sinsert(trades_tbl, {	["number_my"] = tbl["number_my"], 
								["number_sys"] = tbl["number_sys"], 
								["price"] = tbl["price"], 
								["operation"] = tbl["operation"], 
								["status"] = tbl["status"], 
								["twin"] = tbl["twin"],
								["quantity_current"] = tbl["quantity_current"],
								["account"] = tbl["account"],
								["client"] = tbl["client"],
								["instr_name"] = tbl["instr_name"],
								["instr_class"] = tbl["instr_class"],
								["profit"] = tbl["profit"]})
	table.sinsert(start_trades_tbl, {	["number_my"] = tbl["number_my"], 
										["number_sys"] = tbl["number_sys"], 
										["price"] = tbl["price"], 
										["operation"] = tbl["operation"], 
										["status"] = tbl["status"], 
										["twin"] = tbl["twin"],
										["quantity_current"] = tbl["quantity_current"],
										["account"] = tbl["account"],
										["client"] = tbl["client"],
										["instr_name"] = tbl["instr_name"],
										["instr_class"] = tbl["instr_class"],
										["profit"] = tbl["profit"]})
	PrintDbgStr(string.format("vrfma: �������� ������: ���������� %s ����: %s ��������: %s ����������: %s ������: %s twin: %s account: %s client: %s instr_name: %s instr_class: %s profit: %s", 
									tostring(tbl["number_sys"]),
									tostring(tbl["price"]),
									tostring(tbl["operation"]),
									tostring(tbl["quantity_current"]),
									tostring(tbl["status"]),
									tostring(tbl["twin"]),
									tostring(tbl["account"]),
									tostring(tbl["client"]),
									tostring(tbl["instr_name"]),
									tostring(tbl["instr_class"]),
									tostring(tbl["profit"])))
	file_log:write(string.format("%s �������� ������: ���������� %s ����: %s ��������: %s ����������: %s ������: %s twin: %s account: %s client: %s instr_name: %s instr_class: %s profit: %s\n", 
									os.date(), 
									tostring(tbl["number_sys"]),
									tostring(tbl["price"]),
									tostring(tbl["operation"]),
									tostring(tbl["quantity_current"]),
									tostring(tbl["status"]),
									tostring(tbl["twin"]),
									tostring(tbl["account"]),
									tostring(tbl["client"]),
									tostring(tbl["instr_name"]),
									tostring(tbl["instr_class"]),
									tostring(tbl["profit"])))
end
 
function SaveTradesTbl()
	file_save_table = io.open(getScriptPath() .. "\\trades_tbl.dat", "w+")
	if file_save_table ~= nil then
		for _, tab in pairs(trades_tbl) do
			if tostring(tab["status"]) == "3" then
				PrintDbgStr(string.format("vrfma: trades_tbl ������������� ��, ��� ��������� � ����. �����: %s ������: %s ��������: %s ����: %s twin: %s account: %s client: %s instr_name: %s instr_class: %s profit: %s", 
									tostring(tab["number_sys"]), 
									tostring(tab["status"]), 
									tostring(tab["operation"]), 
									tostring(tab["price"]), 
									tostring(tab["twin"]),
									tostring(tab["account"]),
									tostring(tab["client"]),
									tostring(tab["instr_name"]),
									tostring(tab["instr_class"]),
									tostring(tab["profit"])))
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
		PrintDbgStr(string.format("vrfma: �����: %s ������: %s ��������: %s ����: %s account: %s client: %s instr_name: %s instr_class: %s profit: %s", 
									tostring(tab["number_sys"]), 
									tostring(tab["status"]), 
									tostring(tab["operation"]), 
									tostring(tab["price"]), 
									tostring(tab["account"]), 
									tostring(tab["client"]),
									tostring(tab["instr_name"]),
									tostring(tab["instr_class"]),
									tostring(tab["profit"])))
		file_log:write(string.format("	�����: %s ������: %s ��������: %s ����: %s account: %s client: %s instr_name: %s instr_class: %s profit: %s\n", 
									tostring(tab["number_sys"]), 
									tostring(tab["status"]), 
									tostring(tab["operation"]), 
									tostring(tab["price"]),
									tostring(tab["account"]), 
									tostring(tab["client"]),
									tostring(tab["instr_name"]),
									tostring(tab["instr_class"]),
									tostring(tab["profit"])))
	end	
	KillAllOrdersAdapter(client, client_alt, alt_client_use, instr_class, instr_name, prev_instr_name, prev_instr_class)
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

function SendTransBuySell(price, quant, operation, twin_num, account_in, client_in, instr_name_in, instr_class_in, profit_in, write_to_table)	-- �������� ������ �� �������/�������
	if alt_client_use and client_in == nil then
		if prev_client_main then -- PrintDbgStr(string.format("vrfma: client_in %s", tostring(client_in)))	
			client_in = client_alt
			prev_client_main = false
		else
			client_in = client
			prev_client_main = true
		end
	else
		client_in = client_in or client
	end
	account_in = account_in or account
	instr_name_in = instr_name_in or instr_name
	instr_class_in = instr_class_in or instr_class
	twin_num = twin_num or "0"
	profit_in = profit_in or profit
	write_to_table = write_to_table or true
	
	local transaction = {}
	transaction['TRANS_ID'] = tostring(free_TRANS_ID)
	transaction['ACCOUNT'] = account_in
	transaction['CLIENT_CODE'] = client_in
	transaction['SECCODE'] = instr_name_in
	transaction['CLASSCODE'] = instr_class_in
	transaction['PRICE'] = tostring(price)
	transaction['QUANTITY'] = tostring(quant)
	transaction['OPERATION'] = operation
	transaction['ACTION'] = 'NEW_ORDER'
	transaction['TYPE'] = 'L'

	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("vrfma: ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]", transaction.TRANS_ID, result))
		file_log:write(string.format("%s ���������� %s �� ������ �������� �� ������� ��������� QUIK [%s]\n", os.date(), transaction.TRANS_ID, result))
	else
		if write_to_table then
			table.sinsert(trades_tbl, {	["number_my"] = free_TRANS_ID, 
										["number_sys"] = 0, 
										["price"] = price, 
										["operation"] = operation, 
										["status"] = "1", 
										["twin"] = twin_num,
										["quantity_current"] = quant,
										["account"] = account_in,
										["client"] = client_in,
										["instr_name"] = instr_name_in,
										["instr_class"] = instr_class_in,
										["profit"] = profit_in}) --order_requests_buy[#order_requests_buy + 1] = free_TRANS_ID
		end
		table.sinsert(QUEUE_SENDTRANSBUYSELL, {	trans_id = transaction.TRANS_ID,	--PrintDbgStr(string.format("vrfma: ���������� %s ����������. ��������: %s; ����: %s; ����������: %s ", transaction.TRANS_ID, operation, price, quant))
												price = price,
												operation = operation,
												quantity = quant,
												twin = twin_num,
												account = account_in,
												client = client_in,
												instr_name = instr_name_in,
												instr_class = instr_class_in,
												profit = profit_in,
												write_to_table = write_to_table})		
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
													quantity_current = trans_reply.quantity,
													account = tab["account"],
													client = tab["client"],
													instr_name = tab["instr_name"],
													instr_class = tab["instr_class"] })
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
											twin = tab["twin"],
											account = tab["account"],
											client = tab["client"],
											instr_name = tab["instr_name"],
											instr_class = tab["instr_class"],
											profit = tab["profit"] })
			if tostring(tab["twin"]) == "0" then
			-- � twin ��� ��������� ����������� ����� ���� ���� �� �� �����. �������� base_price ���� ���� �� twin
				base_price = tab["price"]	-- !!! ������ ���, � �� trade.price. �� ������� ������ ������ �������������� �� ���� �� ��������� � ������!!!
				tab["status"] = "3"
				if tab["operation"] == 'B' then
					SendTransBuySell(tab["price"] + profit, quantity, 'S', tab["number_sys"], tab["account"], tab["client"])
				else
					SendTransBuySell(tab["price"] - profit, quantity, 'B', tab["number_sys"], tab["account"], tab["client"])
				end
			-- �������� ������������ ������ ���� �� twin
				if not ban_new_ord then
					OrdersVerification(base_price)
				end
			else	--�������� twin. ������� ������ � twin
--[[for ind_n, tab_n in pairs(trades_tbl) do
	PrintDbgStr(string.format("vrfma: trades_tbl ������������� �� �������� ����� ���: %s ����� �������: %s ������: %s ��������: %s ����: %s twin: %s ���-��: %s account: %s client: %s instr_name: %s instr_class: %s", 
										tostring(tab_n["number_my"]), 
										tostring(tab_n["number_sys"]), 
										tostring(tab_n["status"]), 
										tostring(tab_n["operation"]), 
										tostring(tab_n["price"]), 
										tostring(tab_n["twin"]),
										tostring(tab_n["quantity_current"]),
										tostring(tab_n["account"]),
										tostring(tab_n["client"]),
										tostring(tab_n["instr_name"]),
										tostring(tab_n["instr_class"]),
										tostring(tab_n["profit"])))
end ]]
				for ind_2, tab_2 in pairs(trades_tbl) do
					if tostring(tab["twin"]) == tostring(tab_2["number_sys"]) then
						PrintDbgStr(string.format("vrfma: �������� twin. ������� ������ tab[number_sys]: %s � twin tab[twin]: %s tab_2[number_sys]: %s", tostring(tab["number_sys"]), tostring(tab["twin"]), tostring(tab_2["number_sys"])))
						trades_tbl[ind_2] = nil
						break
					end
				end
				trades_tbl[ind_1] = nil
--[[for ind_n, tab_n in pairs(trades_tbl) do
	PrintDbgStr(string.format("vrfma: trades_tbl ������������� ����� �������� ����� ���: %s ����� �������: %s ������: %s ��������: %s ����: %s twin: %s ���-��: %s account: %s client: %s instr_name: %s instr_class: %s", 
										tostring(tab_n["number_my"]), 
										tostring(tab_n["number_sys"]), 
										tostring(tab_n["status"]), 
										tostring(tab_n["operation"]), 
										tostring(tab_n["price"]), 
										tostring(tab_n["twin"]),
										tostring(tab_n["quantity_current"]),
										tostring(tab_n["account"]),
										tostring(tab_n["client"]),
										tostring(tab_n["instr_name"]),
										tostring(tab_n["instr_class"]),
										tostring(tab_n["profit"])))
end ]]
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
					SendTransBuySell(b_price + profit, quantity, 'S', tab["number_sys"], tab["account"], tab["client"], tab["instr_name"], tab["instr_class"], tab["profit"])
				else
					SendTransBuySell(b_price - profit, quantity, 'B', tab["number_sys"], tab["account"], tab["client"], tab["instr_name"], tab["instr_class"], tab["profit"])
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
			PrintDbgStr(string.format("vrfma: ������ ������ �� ������ SendTransBuySell: ���������� %s ����: %s ��������: %s ����������: %s twin: %s account: %s client: %s instr_name: %s instr_class: %s profit: %s write_to_table: %s", 
											tostring(QUEUE_SENDTRANSBUYSELL[1].trans_id),
											tostring(QUEUE_SENDTRANSBUYSELL[1].price),
											tostring(QUEUE_SENDTRANSBUYSELL[1].operation),
											tostring(QUEUE_SENDTRANSBUYSELL[1].quantity),
											tostring(QUEUE_SENDTRANSBUYSELL[1].twin),
											tostring(QUEUE_SENDTRANSBUYSELL[1].account),
											tostring(QUEUE_SENDTRANSBUYSELL[1].client),
											tostring(QUEUE_SENDTRANSBUYSELL[1].instr_name),
											tostring(QUEUE_SENDTRANSBUYSELL[1].instr_class),
											tostring(QUEUE_SENDTRANSBUYSELL[1].profit),
											tostring(QUEUE_SENDTRANSBUYSELL[1].write_to_table)))
			file_log:write(string.format("%s ������ ������ �� ������ SendTransBuySell: ���������� %s ����: %s ��������: %s ����������: %s twin: %s account: %s client: %s instr_name: %s instr_class: %s profit: %s write_to_table: %s\n", 
											os.date(), 
											tostring(QUEUE_SENDTRANSBUYSELL[1].trans_id),
											tostring(QUEUE_SENDTRANSBUYSELL[1].price),
											tostring(QUEUE_SENDTRANSBUYSELL[1].operation),
											tostring(QUEUE_SENDTRANSBUYSELL[1].quantity),
											tostring(QUEUE_SENDTRANSBUYSELL[1].twin),
											tostring(QUEUE_SENDTRANSBUYSELL[1].account),
											tostring(QUEUE_SENDTRANSBUYSELL[1].client),
											tostring(QUEUE_SENDTRANSBUYSELL[1].instr_name),
											tostring(QUEUE_SENDTRANSBUYSELL[1].instr_class),
											tostring(QUEUE_SENDTRANSBUYSELL[1].profit),
											tostring(QUEUE_SENDTRANSBUYSELL[1].write_to_table)))
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
			PrintDbgStr(string.format("vrfma: ������� ����� OnTransReply �� ���������� %s ������ - %i order_num - %s ���������� - %i  account: %s client: %s instr_name: %s instr_class: %s msg:[%s]", 
											tostring(QUEUE_ONTRANSREPLY[1].trans_id), 
											QUEUE_ONTRANSREPLY[1].status, 
											tostring(QUEUE_ONTRANSREPLY[1].order_num),
											QUEUE_ONTRANSREPLY[1].quantity_current,
											QUEUE_ONTRANSREPLY[1].account,
											QUEUE_ONTRANSREPLY[1].client,
											QUEUE_ONTRANSREPLY[1].instr_name,
											QUEUE_ONTRANSREPLY[1].instr_class,
											QUEUE_ONTRANSREPLY[1].result_msg))
			file_log:write(string.format("%s ������� ����� OnTransReply �� ���������� %s ������ - %i order_num - %s ���������� - %i  account: %s client: %s instr_name: %s instr_class: %s msg:[%s]\n", 
											os.date(), 
											tostring(QUEUE_ONTRANSREPLY[1].trans_id), 
											QUEUE_ONTRANSREPLY[1].status, 
											tostring(QUEUE_ONTRANSREPLY[1].order_num),
											QUEUE_ONTRANSREPLY[1].quantity_current,
											QUEUE_ONTRANSREPLY[1].account,
											QUEUE_ONTRANSREPLY[1].client,
											QUEUE_ONTRANSREPLY[1].instr_name,
											QUEUE_ONTRANSREPLY[1].instr_class,
											QUEUE_ONTRANSREPLY[1].result_msg))
			trans_send_flag = true
			table.sremove(QUEUE_ONTRANSREPLY, 1)
		end
		while #QUEUE_ONTRADE > 0 do
			PrintDbgStr(string.format("vrfma: ������ OnTrade order_num: %s ����: %s ��������: %s ���������� - %s twin: %s account: %s client: %s instr_name: %s instr_class: %s profit: %s", 
											tostring(QUEUE_ONTRADE[1].order_num),
											tostring(QUEUE_ONTRADE[1].price),
											tostring(QUEUE_ONTRADE[1].operation),
											tostring(QUEUE_ONTRADE[1].quantity_current),
											tostring(QUEUE_ONTRADE[1].twin),
											tostring(QUEUE_ONTRADE[1].account),
											tostring(QUEUE_ONTRADE[1].client),
											tostring(QUEUE_ONTRADE[1].instr_name),
											tostring(QUEUE_ONTRADE[1].instr_class),
											tostring(QUEUE_ONTRADE[1].profit)))
			file_log:write(string.format("%s ������ OnTrade order_num: %s ����: %s ��������: %s ���������� - %s twin: %s account: %s client: %s instr_name: %s instr_class: %s profit: %s\n", 
											os.date(), 
											tostring(QUEUE_ONTRADE[1].order_num),
											tostring(QUEUE_ONTRADE[1].price),
											tostring(QUEUE_ONTRADE[1].operation),
											tostring(QUEUE_ONTRADE[1].quantity_current),
											tostring(QUEUE_ONTRADE[1].twin),
											tostring(QUEUE_ONTRADE[1].account),
											tostring(QUEUE_ONTRADE[1].client),
											tostring(QUEUE_ONTRADE[1].instr_name),
											tostring(QUEUE_ONTRADE[1].instr_class),
											tostring(QUEUE_ONTRADE[1].profit)))
			SaveTradesTbl()	-- ��������� trades_tbl � ����
			table.sremove(QUEUE_ONTRADE, 1)
		end
		CheckTradePeriod()
		if tonumber(clearing_test_count) <= 0 then
			clearing_test_count = 6000
			ClearingTest()
		else
			clearing_test_count = clearing_test_count - 1
		end
		if timer_start then
			timer_start = false
			sleep(2000)
			timer_done = true
		else
			sleep(50)
		end
	end
	ExitMess()
end
