require("table")

function OnInit()	-- событие - инициализация QUIK
	file_log = io.open("tr_02_" .. os.date("%Y%m%d_%H%M%S") .. ".log", "w")
	PrintDbgStr("tr_02: Событие - инициализация QUIK")
	file_log:write(os.date() .. " tr_02 запущен (инициализация)\n")
	load_error = false
	file_ini = io.open(getScriptPath() .. "\\tr_02.ini", "r")
	if file_ini ~= nil then
		account = file_ini:read("*l")
		PrintDbgStr("tr_02: Чтение tr_02.ini. Номер счёта: " .. account)
		file_log:write(os.date() .. " Чтение tr_02.ini. Номер счёта: " .. account .. " \n")
		client = file_ini:read("*l")
		PrintDbgStr("tr_02: Чтение tr_02.ini. Код клиента: " .. client)
		file_log:write(os.date() .. " Чтение tr_02.ini. Код клиента: " .. client .. " \n")		
		instr_name = file_ini:read("*l")
		PrintDbgStr("tr_02: Чтение tr_02.ini. Инструмент: " .. instr_name)
		file_log:write(os.date() .. " Чтение tr_02.ini. Инструмент: " .. instr_name .. " \n")
		instr_class = file_ini:read("*l")
		PrintDbgStr("tr_02: Чтение tr_02.ini. Класс инструмента: " .. instr_class)
		file_log:write(os.date() .. " Чтение tr_02.ini. Класс инструмента: " .. instr_class .. " \n")		
		oder_interval = file_ini:read("*l")
		PrintDbgStr("tr_02: Чтение tr_02.ini. Шаг заявок: " .. oder_interval)
		file_log:write(os.date() .. " Чтение tr_02.ini. Шаг заявок: " .. oder_interval .. " \n")
		file_ini:close()
	else
		load_error = true
		message("tr_02: Ошибка загрузки tr_02.ini")
		PrintDbgStr("tr_02: Ошибка загрузки tr_02.ini")
		file_log:write(os.date() .. "tr_02: Ошибка загрузки tr_02.ini\n")		
		--instr_name = "BRQ9"; instr_class = "SPBFUT";	oder_interval = 5		
		return false
	end
	
	free_TRANS_ID = os.time()	--для поддержания уникальности free_TRANS_ID задаем первый номер транзакции текущим временем системы
	transaction_ID = {[0] = nil}	--таблица отправленных заявок
	transaction_current = -1	--текущая позиция в таблице транзакций
	MAIN_QUEUE_TRADES = {}
	
	local request_result_depo_buy = ParamRequest(instr_class, instr_name, "LAST")
	if request_result_depo_buy then
		PrintDbgStr("tr_02: По инструменту " .. instr_name .. " успешно заказан параметр LAST")
		file_log:write(os.date() .. " По инструменту " .. instr_name .. " успешно заказан параметр LAST\n")
	else
		PrintDbgStr("tr_02: Ошибка призаказе параметра LAST по инструменту " .. instr_name)
		file_log:write(os.date() .. " Ошибка призаказе параметра LAST по инструменту " .. instr_name .. "\n")
		return false
	end
	order_requests = {}
	order_numbers = {}
	start_deploing = true
end

function exit_mess()
	CancelParamRequest(instr_class, instr_name, "LAST")
	file_log:write(os.date() .. " tr_02 завершён\n")
	file_log:close()
end

--[[function OnOrder(order)	-- событие - QUIK получил новую заявку
	PrintDbgStr("tr_02: событие - QUIK получил новую заявку")
	file_log:write(os.date() .. " событие - QUIK получил новую заявку\n") end
function OnTrade(trade)	-- событие - QUIK получил сделку
	PrintDbgStr("tr_02: событие - QUIK получил сделку")
	file_log:write(os.date() .. " событие - QUIK получил сделку\n") end ]]


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
	price = price - 5 -- чтобы не срабатывали заявки
	start_deploing = false
	--for cnt = 1, counter + 1 do
	--	SendTransBuySell(price + 0.05 * cnt, 1, 'Покупка')
	--end
end

function OnClose()	-- событие - закрытие терминала QUIK
	file_log:write(os.date() .. " Событие - закрытие терминала QUIK\n")
	exit_mess()
	return 0
end

function OnStop(flag)	-- событие - остановка скрипта
	file_log:write(os.date() .. " Событие - остановка скрипта\n")
	exit_mess()
	for _, val in ipairs(order_requests) do
		PrintDbgStr(string.format("tr_02: Значение: %s", tostring(val))
	end	
	for key, val in ipairs(order_numbers) do
		PrintDbgStr(string.format("tr_02: Ключ: %s Значение: %s", tostring(key), tostring(val))
	end
	return 0
end

function SendTransBuySell(price, number, operation)	-- Отправка заявки на покупку/продажу
	local transaction = {}
		transaction['TRANS_ID'] = tostring(free_TRANS_ID)
		transaction['CLASSCODE'] = instr_class
		transaction['ACTION'] = 'NEW_ORDER'
		transaction['ACCOUNT'] = account
		transaction['CLIENT_CODE'] = client
		if operation == 'Покупка' then
			transaction['OPERATION'] = 'B'
		elseif operation == 'Продажа' then
			transaction['OPERATION'] = 'S'
		else
			PrintDbgStr("tr_02: Неверный тип заявки (не покупка, не продажа)")
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
		PrintDbgStr(string.format("tr_02: Транзакция %s не прошла проверку на стороне терминала QUIK [%s]", transaction.TRANS_ID, result))
		file_log:write(string.format("%s Транзакция %s не прошла проверку на стороне терминала QUIK [%s]\n", os.date(), transaction.TRANS_ID, result))
	else
		PrintDbgStr(string.format("tr_02: Транзакция %s отправлена. Операция: %s цена: %s количество: %s ", transaction.TRANS_ID, operation, price, number))
		file_log:write(string.format("%s Транзакция %s отправлена. Операция: %s цена: %s количество: %s\n", os.date(), transaction.TRANS_ID, operation, price, number))
	end
	table.insert(order_requests, tostring(free_TRANS_ID))
	transaction_current = transaction_current + 1
	transaction_ID[transaction_current] = free_TRANS_ID
	free_TRANS_ID = free_TRANS_ID + 1	--увеличиваем free_TRANS_ID
end

function SendTransClose(close_ID)		-- Снятие заявки 
	local transaction = {}
		transaction['TRANS_ID'] = tostring(free_TRANS_ID)
		transaction['CLASSCODE'] = instr_class
		transaction['ACTION'] = 'Снятие заявки по номеру'
		transaction['Заявка'] = tostring(close_ID)
	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("tr_02: Транзакция %s не прошла проверку на стороне терминала QUIK [%s]", free_TRANS_ID, result))
		file_log:write(string.format("%s Транзакция %s не прошла проверку на стороне терминала QUIK [%s]\n", os.date(), free_TRANS_ID, result))
	else
		PrintDbgStr(string.format("tr_02: Транзакция %s отправлена. Снятие заявки: %s", free_TRANS_ID, close_ID))
		file_log:write(string.format("%s Транзакция %s отправлена. Снятие заявки: %s\n", os.date(), free_TRANS_ID, close_ID))
	end
	transaction_current = transaction_current + 1
	transaction_ID[transaction_current] = free_TRANS_ID
	free_TRANS_ID = free_TRANS_ID + 1	-- увеличиваем free_TRANS_ID
end

function OnTransReply(trans_reply)	-- Подтверждение выполнения заявки
	if trans_reply.trans_id == transaction_ID[transaction_current] then
		PrintDbgStr(string.format("tr_02: Получен ответ на транзакцию %i. Статус - %i order_num - %s msg:[%s]", 
										trans_reply.trans_id, 
										trans_reply.status, 
										tostring(trans_reply.order_num), 
										trans_reply.result_msg))
		file_log:write(string.format("%s Получен ответ на транзакцию %i. Статус - %i order_num - %s msg:[%s]\n", 
										os.date(), 
										trans_reply.trans_id, 
										trans_reply.status, 
										tostring(trans_reply.order_num),
										trans_reply.result_msg))
		if trans_reply.status >=2 then	-- если статус транзакции 2 или больше считаем транзакцию обработанной и сохраняем результат ее обработки
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
		PrintDbgStr("tr_02: QUIK подключен к серверу")
		file_log:write(os.date() .. " QUIK подключен к серверу\n")
	else
		PrintDbgStr("tr_02: QUIK отключен от сервера")
		exit_mess()
		return false
	end
	
	SendTransBuySell(60, 1, 'Покупка')
	time_counter = 0
	trans_send_flag = false
	while true do
		-- result = getParamEx (class_code, sec_code, param_name_buy)
		while #MAIN_QUEUE_TRADES > 0 do	-- # оператор длины массива возвращает наибольший индекс элементов массива
			-- Разобрать очередь и сохранить в файл и в лог
			-- MAIN_QUEUE_TRADES[1].trans_id
			PrintDbgStr(string.format("tr_02: Обработка в main order_num: %s", tostring(MAIN_QUEUE_TRADES[1])))
			file_log:write(string.format("%s Обработка в main order_num: %s\n", os.date(), tostring(MAIN_QUEUE_TRADES[1])))		
			trans_send_flag = true
			close_id = MAIN_QUEUE_TRADES[1]
			PrintDbgStr(string.format("tr_02: close_id: %s", tostring(close_id)))
			table.sremove(MAIN_QUEUE_TRADES, 1)
		end
		if (time_counter >= 6000) and (trans_send_flag) then
			PrintDbgStr(string.format("tr_02: Снятие транзакции %s", tostring(close_id)))
			SendTransClose(close_id)
			time_counter = 0
			trans_send_flag = false
		end			
		sleep(10)
		time_counter = time_counter + 1
	end
	exit_mess()
end
