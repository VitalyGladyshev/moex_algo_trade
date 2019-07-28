-- отображение котировок фьючерса на нефть: BRQ9, задание и снятие заявки
function OnInit()	-- событие - инициализация QUIK
	file_log = io.open("tr_02_" .. os.date("%Y%m%d_%H%M%S") .. ".log", "w")
	PrintDbgStr("tr_02: событие - инициализация QUIK")
	file_log:write(os.date() .. " tr_02 запущен (инициализация)\n")
	load_error = false
	file_ini = io.open(getScriptPath() .. "\\tr_02.ini", "r")
	if ~= nil then
		account = file_ini:read(«*l»)
		PrintDbgStr("tr_02: Чтение tr_02.ini. Номер счёта: " .. account)
		file_log:write(os.date() .. " Чтение tr_02.ini. Номер счёта: " .. account .. " \n")
		instr_name = file_ini:read(«*l»)
		PrintDbgStr("tr_02: Чтение tr_02.ini. Инструмент: " .. instr_name)
		file_log:write(os.date() .. " Чтение tr_02.ini. Инструмент: " .. instr_name .. " \n")
		instr_class = file_ini:read(«*l»)
		PrintDbgStr("tr_02: Чтение tr_02.ini. Класс инструмента: " .. instr_class)
		file_log:write(os.date() .. " Чтение tr_02.ini. Класс инструмента: " .. instr_class .. " \n")		
		oder_interval = file_ini:read(«*l»)
		PrintDbgStr("tr_02: Чтение tr_02.ini. Шаг заявок: " .. oder_interval)
		file_log:write(os.date() .. " Чтение tr_02.ini. Шаг заявок: " .. oder_interval .. " \n")
		file_ini:close()
	else
		load_error = true
		message("tr_02: ошибка загрузки tr_02.ini")
		PrintDbgStr("tr_02: ошибка загрузки tr_02.ini")
		file_log:write(os.date() .. "tr_02: ошибка загрузки tr_02.ini\n")		
		--instr_name = "BRQ9"; instr_class = "SPBFUT";	oder_interval = 5		
		return false
	end
	
	free_TRANS_ID = os.time()	--для поддержания уникальности free_TRANS_ID задаем первый номер транзакции текущим временем системы
	transaction_ID = {[0] = nil}	--таблица отправленных заявок
	transaction_current = -1	--текущая позиция в таблице транзакций
	MAIN_QUEUE_TRADES = {}
	
	local request_result_depo_buy = ParamRequest(instr_class, instr_name, "LAST")
	if request_result_depo_buy then
		PrintDbgStr("tr_02: по инструменту " .. instr_name .. " успешно заказан параметр LAST")
		file_log:write(os.date() .. " по инструменту " .. instr_name .. " успешно заказан параметр LAST\n")
	else
		PrintDbgStr("tr_02: ошибка призаказе параметра LAST по инструменту " .. instr_name)
		file_log:write(os.date() .. " ошибка призаказе параметра LAST по инструменту " .. instr_name .. "\n")
		return false
	end
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
end

function OnClose()	-- событие - закрытие терминала QUIK
	file_log:write(os.date() .. " событие - закрытие терминала QUIK\n")
	exit_mess()
	return 0
end

function OnStop(flag)	-- событие - остановка скрипта
	file_log:write(os.date() .. " событие - остановка скрипта\n")
	exit_mess()
	return 0
end

function SendTransBuySell(price, number, operation)	-- Отправка заявки на покупку/продажу
	local transaction = {}
		transaction['TRANS_ID'] = tostring(free_TRANS_ID)
		transaction['CLASSCODE'] = instr_class
		transaction['ACTION'] = 'Ввод заявки'
		transaction['Торговый счет'] = account
		if operation == 'Покупка' then
			transaction['К/П'] = 'Покупка'
		elseif operation == 'Продажа' then
			transaction['К/П'] = 'Продажа'
		else
			PrintDbgStr("tr_02: Неверный тип заявки (не покупка, не продажа)")
			return false
		end
		transaction['Тип'] = 'Лимитированная'
		transaction['Инструмент'] = instr_name
		transaction['Цена'] = tostring(price)
		transaction['Количество'] = tostring(number)		
	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("tr_02: Транзакция %s не прошла проверку на стороне терминала QUIK [%s]", transaction.TRANS_ID, result))
	else
		PrintDbgStr(string.format("tr_02: Транзакция %s отправлена", transaction.TRANS_ID))
	end
	transaction_current = transaction_current + 1
	transaction_ID[transaction_current] = free_TRANS_ID
	free_TRANS_ID = free_TRANS_ID + 1	--увеличиваем free_TRANS_ID
end

function SendTransClose(close_TRANS_ID)		-- Снятие заявки 
	local transaction = {}
		transaction['TRANS_ID'] = tostring(close_TRANS_ID)

	local result = sendTransaction(transaction)
	if result ~= "" then
		PrintDbgStr(string.format("tr_02: Транзакция %s не прошла проверку на стороне терминала QUIK [%s]", close_TRANS_ID, result))
	else
		PrintDbgStr(string.format("tr_02: Транзакция %s отправлена", close_TRANS_ID))
	end	
	PrintDbgStr(string.format("tr_02: Транзакция - снятие заявки %s", close_TRANS_ID))
end

function OnTransReply(trans_reply)	-- Подтверждение выполнения заявки
	table.sinsert(MAIN_QUEUE_TRADES, trans_reply)
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
	
	SendTransBuySell(100, 1, 'Покупка')
	time_counter = 0
	trans_send_flag = false
	while true do
		-- result = getParamEx (class_code, sec_code, param_name_buy)
		-- PrintDbgStr("tr_02: " .. " " .. i .. "\n")
		-- file_log:write(os.date() .. " " .. i .. "\n")
		while #MAIN_QUEUE_TRADES > 0 do	-- # оператор длины массива возвращает наибольший индекс элементов массива
			-- Разобрать очередь и сохранить в файл и в лог
			-- MAIN_QUEUE_TRADES[1].trans_id
			-- trans_send_flag = true
			PrintDbgStr(string.format("tr_02: Транзакция %s подтверждена", MAIN_QUEUE_TRADES[1].trans_id))
			file_log:write(string.format("%s Транзакция %s подтверждена\n", os.date(), MAIN_QUEUE_TRADES[1].trans_id))		
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
