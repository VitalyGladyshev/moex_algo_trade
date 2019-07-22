is_run = true

function OnStop()
	is_run = false
end

function main()
	while is_run do
		PrintDbgStr("QLua: " .. os.date())
		sleep(5000)
	end
end
