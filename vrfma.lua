--[[
1 Продумать обработку при quantity больше единицы
2 V Перенести записи в лог файл из обработчиков в main
3 Исправить ошибку с пропуском заявок (Илья присылал логи)
4 После отладки уменьшить вывод отладочных сообщений
5 V Сделать снятие заявок в полночь и запуск торговли после 10:01
6 Исправить проверку на некорректное значение текущей цены в OnParam
]]
function OnInit()	-- событие - инициализация QUIK
	file_log = io.open("vrfma_" .. os.date("%Y%m%d_%H%M%S") .. ".log", "w")
	PrintDbgStr("vrfma: Событие - инициализация QUIK")
	file_log:write(os.date() .. " vrfma запущен (инициализация)\n")
	load_error = false
	file_ini = io.open(getScriptPath() .. "\\vrfma.ini", "r")
	if file_ini ~= nil then
		account = file_ini:read("*l")
		PrintDbgStr("vrfma: Чтение vrfma.ini. Номер счёта: " .. account)
		file_log:write(os.date() .. " Чтение vrfma.ini. Номер счёта: " .. account .. " \n")
		client = file_ini:read("*l")
		PrintDbgStr("vrfma: Чтение vrfma.ini. Код клиента: " .. client)
		file_log:write(os.date() .. " Чтение vrfma.ini. Код клиента: " .. client .. " \n")		
		instr_name = file_ini:read("*l")
		PrintDbgStr("vrfma: Чтение vrfma.ini. Инструмент: " .. instr_name)
		file_log:write(os.date() .. " Чтение vrfma.ini. Инструмент: " .. instr_name .. " \n")
		instr_class = file_ini:read("*l")
		PrintDbgStr("vrfma: Чтение vrfma.ini. Класс инструмента: " .. instr_class)
		file_log:write(os.date() .. " Чтение vrfma.ini. Класс инструмента: " .. instr_class .. " \n")		
		order_interval = file_ini:read("*l")
		PrintDbgStr("vrfma: Чтение vrfma.ini. Шаг заявок: " .. order_interval)
		file_log:write(os.date() .. " Чтение vrfma.ini. Шаг заявок: " .. order_interval .. " \n")
		profit = file_ini:read("*l")
		PrintDbgStr("vrfma: Чтение vrfma.ini. Норма прибыли: " .. profit)
		file_log:write(os.date() .. " Чтение vrfma.ini. Норма прибыли: " .. profit .. " \n")
		quantity = file_ini:read("*l")
		PrintDbgStr("vrfma: Чтение vrfma.ini. Количество бумаг в заявке: " .. quantity)
		file_log:write(os.date() .. " Чтение vrfma.ini. Количество бумаг в заявке: " .. quantity .. " \n")
		file_ini:close()
		order_interval = tonumber(order_interval)
		profit = tonumber(profit)
		quantity = tonumber(quantity)
	else
		load_error = true
		message("vrfma: Ошибка загрузки vrfma.ini")
		PrintDbgStr("vrfma: Ошибка загрузки vrfma.ini")
		file_log:write(os.date() .. "vrfma: Ошибка загрузки vrfma.ini\n")
		return false
	end
	
	file_name_for_load = getScriptPath() .. "\\trades_tbl.dat"
	trade_period = false
	CheckTradePeriod()
	start_deploying = true
	cold_start = true
	file_load_table = io.open(file_name_for_load, "r")
	if file_load_table ~= nil then
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
	
	free_TRANS_ID = os.time()	--для поддержания уникальности free_TRANS_ID задаем первый номер транзакции текущим временем системы
	QUEUE_SENDTRANSBUYSELL = {}
	QUEUE_SENDTRANSCLOSE = {}
	QUEUE_ONTRANSREPLY = {}
	QUEUE_ONTRADE = {}
	current_price = 0
	base_price = 0
	KillAllOrders(instr_class, instr_name, client)
	
	local request_result_depo_buy = ParamRequest(instr_class, instr_name, "LAST")
	if request_result_depo_buy then
		PrintDbgStr("vrfma: По инструменту " .. instr_name .. " успешно заказан параметр LAST")
		file_log:write(os.date() .. " По инструменту " .. instr_name .. " успешно заказан параметр LAST\n")
	else
		PrintDbgStr("vrfma: Ошибка призаказе параметра LAST по инструменту " .. instr_name)
		file_log:write(os.date() .. " Ошибка призаказе параметра LAST по инструменту " .. instr_name .. "\n")
		return false
	end
end

function CheckTradePeriod()
	now_dt = os.date("*t", os.time())	--PrintDbgStr(string.format("vrfma: CheckTradePeriod Сейчас - час: %s минута: %s", tostring(now_dt.hour), tostring(now_dt.min)))
	if now_dt.hour < 10 then
		if trade_period then
			trade_period = false
			KillAllOrders(instr_class, instr_name, client)
			PrintDbgStr(string.format("vrfma: Неторговое время FORTS на ММВБ снимаем заявки. Сейчас: %s", tostring(os.date())))
			file_log:write(os.date() .. " Неторговое время FORTS на ММВБ снимаем заявки.")
		end
	else
		if now_dt.hour > 10 or now_dt.min > 0 then
			if not trade_period then
				trade_period = true
				PrintDbgStr(string.format("vrfma: Торговый период FORTS на ММВБ. Сейчас: %s", tostring(os.date())))
				file_log:write(os.date() .. " Торговый период FORTS на ММВБ.")
			end
		end
	end
end

function KillAllOrders(classCode, secCode, brokerref)	-- Нашёл на форуме QUIK и адаптировал
	PrintDbgStr(string.format("vrfma: Удаление всех заявок начато"))
	file_log:write(string.format("%s Удаление всех заявок начато\n", os.date()))
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
				PrintDbgStr(string.format("vrfma: Транзакция %s на снятие заявки %s не прошла проверку на стороне терминала QUIK [%s]", free_TRANS_ID, tostring(getItem(ord,orders[i]).order_num, result)))
				file_log:write(string.format("	Транзакция %s на снятие заявки %s не прошла проверку на стороне терминала QUIK [%s]\n", free_TRANS_ID, tostring(getItem(ord,orders[i]).order_num, result)))
			else
				PrintDbgStr(string.format("vrfma: Транзакция %s отправлена. Снятие заявки: %s", free_TRANS_ID, tostring(getItem(ord,orders[i]).order_num)))
				file_log:write(string.format("	Транзакция %s отправлена. Снятие заявки: %s\n", free_TRANS_ID, tostring(getItem(ord,orders[i]).order_num)))
			end
			free_TRANS_ID = free_TRANS_ID + 1	-- увеличиваем free_TRANS_ID
		end
	end
	PrintDbgStr(string.format("vrfma: Удаление всех заявок завершено"))
	file_log:write(string.format("%s Удаление всех заявок завершено\n", os.date()))
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
				PrintDbgStr(string.format("vrfma: Ошибка! Некорректная цена: %.2f", res.param_value))
				file_log:write(string.format("%s Ошибка! Некорректная цена: %.2f\n", os.date(), res.param_value))
				return	]]	--Надо задавть ненулевую стартовую цену, иначе эта проверка может ложно сработать при старте
			else
				current_price = tonumber(res.param_value)
			end
			if trade_period then
			-- инициализация при старте
				if start_deploying then
					start_deploying = false
					if cold_start then
						base_price = res.param_value
						ColdStart(10, base_price)	--PrintDbgStr(string.format("vrfma: type(res.param_value): %s", type(res.param_value))) -- res.param_value: %.2f", type(tmp), tonumber(tmp)))
						return
					else
						base_price = NewBasePrice(tonumber(trades_tbl[1]["price"]), current_price)	--trades_tbl толькочто запонена т.е. первый элемент должен быть
						PrintDbgStr(string.format("vrfma: Определение base_price: %.2f", base_price))
						file_log:write(string.format("%s Определение base_price: %.2f\n", os.date(), base_price))
						WarmStart(base_price, current_price)
						return
					end
				end
			-- при изменении цены более чем на order_interval обновляем заявки (при изменении на order_interval должна срабатывать заявка), если заявка не обновила base_price сработает эта защита
				if math.abs(current_price - base_price) > order_interval then
					PrintDbgStr(string.format("vrfma: Цена current_price: %.2f отклонилась от base_price: %.2f", current_price, base_price))
					base_price = NewBasePrice(base_price, current_price)
					OrdersVerification(base_price)
				end
			-- используем ячейку base_price
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
	for _, tab in pairs(start_trades_tbl) do		--ставим twin-ов
		if tab["operation"] == 'B' then
			if tonumber(b_price) > tonumber(tab["price"]) + profit then
				PrintDbgStr(string.format("vrfma: WarmStart. S. b_price+: %s (tab[price] + profit): %s status: %s", tostring(b_price), tostring((tab["price"] + profit)), tostring(tab["status"])))
				SendTransBuySell(b_price, quantity, 'S', tab["number_sys"])
			else
				PrintDbgStr(string.format("vrfma: WarmStart. S. b_price-: %s (tab[price] + profit): %s status: %s", tostring(b_price), tostring((tab["price"] + profit)), tostring(tab["status"])))
				SendTransBuySell(tab["price"] + profit, quantity, 'S', tab["number_sys"])
			end
		else
			if tonumber(b_price) < tonumber(tab["price"]) - profit then
				PrintDbgStr(string.format("vrfma: WarmStart. B. b_price+: %s (tab[price] - profit): %s status: %s", tostring(b_price), tostring((tab["price"] - profit)), tostring(tab["status"])))
				SendTransBuySell(b_price, quantity, 'B', tab["number_sys"])
			else
				PrintDbgStr(string.format("vrfma: WarmStart. B. b_price-: %s (tab[price] - profit): %s status: %s", tostring(b_price), tostring((tab["price"] - profit)), tostring(tab["status"])))
				SendTransBuySell(tab["price"] - profit, quantity, 'B', tab["number_sys"])
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
		for _, tab in pairs(trades_tbl) do
			if tostring(tab["status"]) == "3" then
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
		message("vrfma: Ошибка сохранения trades_tbl.dat")
		PrintDbgStr("vrfma: Ошибка сохранения trades_tbl.dat")
		file_log:write(os.date() .. "vrfma: Ошибка сохранения trades_tbl.dat\n")
		return false
	end
end

function ExitMess()
	CancelParamRequest(instr_class, instr_name, "LAST")
	SaveTradesTbl()	-- сохраняем trades_tbl в файл
	PrintDbgStr("vrfma: Заявки: ")
	file_log:write(string.format("%s Таблица заявок и сделок:\n", os.date()))
	for _, tab in pairs(trades_tbl) do
		PrintDbgStr(string.format("vrfma: Номер: %s Статус: %i Операция: %s Цена: %s", tostring(tab["number_sys"]), tab["status"], tostring(tab["operation"]), tostring(tab["price"])))
		file_log:write(string.format("	Номер: %s Статус: %i Операция: %s Цена: %s\n", tostring(tab["number_sys"]), tab["status"], tostring(tab["operation"]), tostring(tab["price"])))
	end	
	KillAllOrders(instr_class, instr_name, client)
	PrintDbgStr("vrfma: vrfma завершён")
	file_log:write(os.date() .. " vrfma завершён\n")
	file_log:close()
end

function OnClose()	-- событие - закрытие терминала QUIK
	file_log:write(os.date() .. " Событие - закрытие терминала QUIK\n")
	ExitMess()
	return 0
end

function OnStop(flag)	-- событие - остановка скрипта
	file_log:write(os.date() .. " Событие - остановка скрипта\n")
	ExitMess()
	return 0
end

function SendTransBuySell(price, quant, operation, twin_num)	-- Отправка заявки на покупку/продажу
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
		transaction['QUANTITY'] = tostring(quant)
	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("vrfma: Транзакция %s не прошла проверку на стороне терминала QUIK [%s]", transaction.TRANS_ID, result))
		file_log:write(string.format("%s Транзакция %s не прошла проверку на стороне терминала QUIK [%s]\n", os.date(), transaction.TRANS_ID, result))
	else
		table.sinsert(trades_tbl, {	["number_my"] = free_TRANS_ID, 
									["number_sys"] = 0, 
									["price"] = price, 
									["operation"] = operation, 
									["status"] = "1", 
									["twin"] = twin_num,
									["quantity_current"] = quant}) --order_requests_buy[#order_requests_buy + 1] = free_TRANS_ID
		table.sinsert(QUEUE_SENDTRANSBUYSELL, {	trans_id = transaction.TRANS_ID,	--PrintDbgStr(string.format("vrfma: Транзакция %s отправлена. Операция: %s; цена: %s; количество: %s ", transaction.TRANS_ID, operation, price, quant))
												price = price,
												operation = operation,
												quantity = quant})
	end
	free_TRANS_ID = free_TRANS_ID + 1	--увеличиваем free_TRANS_ID
end

function SendTransClose(close_ID)		-- Снятие заявки 
	local transaction = {}
		transaction['TRANS_ID'] = tostring(free_TRANS_ID)
		transaction['CLASSCODE'] = instr_class
		transaction['SECCODE'] = instr_name
		transaction['ACTION'] = 'KILL_ORDER'
		transaction['ORDER_KEY'] = tostring(close_ID)		--['Заявка'] = tostring(close_ID)		["ORDER_KEY"]=tostring(getItem(ord,orders[i]).order_num)
	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("vrfma: Транзакция %s на снятие заявки %s не прошла проверку на стороне терминала QUIK [%s]", free_TRANS_ID, close_ID, result))
		file_log:write(string.format("%s Транзакция %s на снятие заявки %s не прошла проверку на стороне терминала QUIK [%s]\n", os.date(), free_TRANS_ID, close_ID, result))
	else
		table.sinsert(QUEUE_SENDTRANSCLOSE, {trans_id = transaction.TRANS_ID, close_id = close_ID})		--PrintDbgStr(string.format("vrfma: Транзакция %s отправлена. Снятие заявки: %s", free_TRANS_ID, close_ID))
		for ind, tab in pairs(trades_tbl) do
			if tostring(tab["number_sys"]) == tostring(close_ID) then
				trades_tbl[ind] = nil
			end
		end
	end
	free_TRANS_ID = free_TRANS_ID + 1	-- увеличиваем free_TRANS_ID
end

function OnTransReply(trans_reply)	-- Подтверждение заявки
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

function OnTrade(trade)	-- событие - QUIK получил сделку
	PrintDbgStr(string.format("vrfma: OnTrade trade.order_num: %s", tostring(trade.order_num)))
	for ind_1, tab in pairs(trades_tbl) do
		PrintDbgStr(string.format("vrfma: 'for' trade.order_num: %s tab[number_sys]: %s tab[status]: %s tab[quantity_current]: %s", tostring(trade.order_num), tostring(tab["number_sys"]), tostring(tab["status"]), tostring(tab["quantity_current"])))
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
			else	--сработал twin. Удаляем заявку и twin
				for ind_2, tab_2 in pairs(trades_tbl) do
					if tostring(tab["twin"]) == tostring(tab_2["number_sys"]) then
						PrintDbgStr(string.format("vrfma: Сработал twin. Удаляем заявку и twin tab[twin]: %s tab_2[number_sys]: %s, trades_tbl[ind_2]: %s trades_tbl[ind_1]: %s", tostring(tab["twin"]), tostring(tab_2["number_sys"]), tostring(trades_tbl[ind_2]), tostring(trades_tbl[ind_1])))
						trades_tbl[ind_2] = nil
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
	PrintDbgStr(string.format("vrfma: OrdersVerification. Цена: %s", tostring(b_price)))
--Снимаем лишние заявки и проверяем twin'ы
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
				PrintDbgStr(string.format("vrfma: Обнаружена потеря twin'а. Нет twin'а у номера number_sys: %s", tostring(tab["number_sys"])))
				if tab["operation"] == 'B' then
					SendTransBuySell(b_price + profit, quantity, 'S', tab["number_sys"])
				else
					SendTransBuySell(b_price - profit, quantity, 'B', tab["number_sys"])
				end
			end
		end
	end
--Ставим новые заявки			
	local pos_not_used
	for cnt = 1, 10 do
		pos_not_used = true
		for k2, tab in pairs(trades_tbl) do
			PrintDbgStr(string.format("vrfma: OrdersVerification. B. tab[price]: %s (b_price - order_interval * cnt): %s res: %s", tostring(tab["price"]), tostring(b_price - order_interval * cnt), tostring(tostring(tab["price"]) == tostring(b_price - order_interval * cnt))))			
			if tostring(tab["price"]) == tostring(b_price - order_interval * cnt) and tostring(tab["twin"]) == "0" then
				pos_not_used = false
				PrintDbgStr(string.format("vrfma: OrdersVerification. B. pos_not_used = false цена: %s", tostring(b_price - order_interval * cnt)))
				break
			end
		end
		if pos_not_used then
			SendTransBuySell(b_price - order_interval * cnt, quantity, 'B')
		end
		pos_not_used = true
		for k3, tab in pairs(trades_tbl) do
			PrintDbgStr(string.format("vrfma: OrdersVerification. S. tab[price]: %s (b_price + order_interval * cnt): %s res: %s", tostring(tab["price"]), tostring(b_price + order_interval * cnt), tostring(tostring(tab["price"]) == tostring(b_price + order_interval * cnt))))
			if tostring(tab["price"]) == tostring(b_price + order_interval * cnt) and tostring(tab["twin"]) == "0" then
				pos_not_used = false
				PrintDbgStr(string.format("vrfma: OrdersVerification. S. pos_not_used = false цена: %s", tostring(b_price + order_interval * cnt)))
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
		PrintDbgStr("vrfma: QUIK подключен к серверу")
		file_log:write(os.date() .. " QUIK подключен к серверу\n")
	else
		PrintDbgStr("vrfma: QUIK отключен от сервера")
		ExitMess()
		return false
	end
	
	trans_send_flag = false
	while true do
		while #QUEUE_SENDTRANSBUYSELL > 0 do
			PrintDbgStr(string.format("vrfma: Создаём заявку на сделку SendTransBuySell: транзакция %i цена: %s операция: %s количество: %s", 
											QUEUE_SENDTRANSBUYSELL[1].trans_id,
											tostring(QUEUE_SENDTRANSBUYSELL[1].price),
											tostring(QUEUE_SENDTRANSBUYSELL[1].operation),
											tostring(QUEUE_SENDTRANSBUYSELL[1].quantity)))
			file_log:write(string.format("%s Создаём заявку на сделку SendTransBuySell: транзакция %i цена: %s операция: %s количество: %s\n", 
											os.date(), 
											QUEUE_SENDTRANSBUYSELL[1].trans_id,
											tostring(QUEUE_SENDTRANSBUYSELL[1].price),
											tostring(QUEUE_SENDTRANSBUYSELL[1].operation),
											tostring(QUEUE_SENDTRANSBUYSELL[1].quantity)))
			table.sremove(QUEUE_SENDTRANSBUYSELL, 1)
		end
		while #QUEUE_SENDTRANSCLOSE > 0 do
			PrintDbgStr(string.format("vrfma: Удаляем заявку SendTransClose: транзакция %i Снятие заявки: %i", 
											QUEUE_SENDTRANSCLOSE[1].trans_id,
											QUEUE_SENDTRANSCLOSE[1].close_id))
			file_log:write(string.format("%s Удаляем заявку SendTransClose: транзакция %i Снятие заявки: %i\n", 
											os.date(), 
											QUEUE_SENDTRANSCLOSE[1].trans_id,
											QUEUE_SENDTRANSCLOSE[1].close_id))
			table.sremove(QUEUE_SENDTRANSCLOSE, 1)
		end
		while #QUEUE_ONTRANSREPLY > 0 do	-- # оператор длины массива возвращает наибольший индекс элементов массива
			PrintDbgStr(string.format("vrfma: Получен ответ OnTransReply на транзакцию %i Статус - %i order_num - %s количество - %i msg:[%s]", 
											QUEUE_ONTRANSREPLY[1].trans_id, 
											QUEUE_ONTRANSREPLY[1].status, 
											tostring(QUEUE_ONTRANSREPLY[1].order_num),
											QUEUE_ONTRANSREPLY[1].quantity_current,
											QUEUE_ONTRANSREPLY[1].result_msg))
			file_log:write(string.format("%s Получен ответ OnTransReply на транзакцию %i Статус - %i order_num - %s количество - %i msg:[%s]\n", 
											os.date(), 
											QUEUE_ONTRANSREPLY[1].trans_id, 
											QUEUE_ONTRANSREPLY[1].status, 
											tostring(QUEUE_ONTRANSREPLY[1].order_num),
											QUEUE_ONTRANSREPLY[1].quantity_current,
											QUEUE_ONTRANSREPLY[1].result_msg))
			trans_send_flag = true
			table.sremove(QUEUE_ONTRANSREPLY, 1)
		end
		while #QUEUE_ONTRADE > 0 do
			PrintDbgStr(string.format("vrfma: Сделка OnTrade order_num: %s цена: %s операция: %s количество - %s twin: %s", 
											tostring(QUEUE_ONTRADE[1].order_num),
											tostring(QUEUE_ONTRADE[1].price),
											tostring(QUEUE_ONTRADE[1].operation),
											tostring(QUEUE_ONTRADE[1].quantity_current),
											tostring(QUEUE_ONTRADE[1].twin)))
			file_log:write(string.format("%s Сделка OnTrade order_num: %s цена: %s операция: %s количество - %s twin: %s\n", 
											os.date(), 
											tostring(QUEUE_ONTRADE[1].order_num),
											tostring(QUEUE_ONTRADE[1].price),
											tostring(QUEUE_ONTRADE[1].operation),
											tostring(QUEUE_ONTRADE[1].quantity_current),
											tostring(QUEUE_ONTRADE[1].twin)))
			SaveTradesTbl()	-- сохраняем trades_tbl в файл
			table.sremove(QUEUE_ONTRADE, 1)
		end
		CheckTradePeriod()
		sleep(10)
	end
	ExitMess()
end
