-- отображение котировок фьючерса на нефть: BRQ9
function OnInit()	-- событие - инициализаци€ QUIK
	close_flag = false
	file_log = io.open("tr_l_01_" .. os.date("%Y%m%d_%H%M%S") .. ".log", "w")
	PrintDbgStr("tr_l_01: событие - инициализаци€ QUIK")
	file_log:write(os.date() .. " tr_l_01 запущен (инициализаци€)\n")
	-- „тение tr_l_01.ini
	file_ini = io.open(getScriptPath() .. "\\tr_l01.ini", "r")
	if file_ini ~= nil then
		type_of_inst = file_ini:read("*l")
		period = file_ini:read("*l")
		file_ini:close()	
		PrintDbgStr("tr_l_01: type_of_inst " .. type_of_inst)
		PrintDbgStr("tr_l_01: period " .. period)
	else
		PrintDbgStr("tr_l_01: неудалось открыть ini файл")
		close_flag = true
		return false
	end
	-- «апрос потока котировок
	local request_result_depo_buy = ParamRequest("SPBFUT", "BRQ9", "LAST")
	if request_result_depo_buy then
		PrintDbgStr("tr_l_01: по инструменту BRQ9 успешно заказан параметр LAST")
		file_log:write(os.date() .. " по инструменту BRQ9 успешно заказан параметр LAST\n")
	else
		PrintDbgStr("tr_l_01: ошибка призаказе параметра LAST по инструменту BRQ9")
		file_log:write(os.date() .. " ошибка призаказе параметра LAST по инструменту BRQ9\n")
		close_flag = true
		return false
	end --[[ ]]
end

function exit_mess()
	CancelParamRequest("SPBFUT", "BRQ9", "LAST")
	file_log:write(os.date() .. " tr_l_01 завершЄн\n")
	file_log:close()
end

function OnOrder(order)	-- событие - QUIK получил новую за€вку
	PrintDbgStr("tr_l_01: событие - QUIK получил новую за€вку")
	file_log:write(os.date() .. " событие - QUIK получил новую за€вку\n")
end

function OnTrade(trade)	-- событие - QUIK получил сделку
	PrintDbgStr("tr_l_01: событие - QUIK получил сделку")
	file_log:write(os.date() .. " событие - QUIK получил сделку\n")
end

function OnParam(class, sec)
	if class =="SPBFUT" and sec == "BRQ9" then
		result = getParamEx(class, sec, "LAST")
		PrintDbgStr(string.format("tr_l_01: BRQ9: %.2f", result.param_value))	--("tr_l_01: BRQ9: " .. tostring(result.param_value))
		file_log:write(string.format("%s BRQ9: %.2f\n", os.date(), result.param_value))	--(os.date() .. " BRQ9: " .. tostring(result.param_value) .. "\n")
	end
end

function OnClose()	-- событие - закрытие терминала QUIK
	file_log:write(os.date() .. " событие - закрытие терминала QUIK\n")
	exit_mess()
	return 0
end

function OnStop()	-- событие - остановка скрипта
	file_log:write(os.date() .. " событие - остановка скрипта\n")
	exit_mess()
	return 0
end

function main()
	if close_flag then
		return false
	end
	if isConnected() then
		PrintDbgStr("tr_l_01: QUIK подключен к серверу")
		file_log:write(os.date() .. " QUIK подключен к серверу\n")
	else
		PrintDbgStr("tr_l_01: QUIK отключен от сервера")
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
