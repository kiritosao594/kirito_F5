ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('kF5:server:getGroup', function(source, cb)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local plyGroup = xPlayer.getGroup()
	cb(plyGroup)
end)


ESX.RegisterServerCallback('kF5:Bill_getBills', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		local bills = {}

		for i = 1, #result do
			bills[#bills + 1] = {
				id = result[i].id,
				label = result[i].label,
				amount = result[i].amount
			}
		end

		cb(bills)
	end)
end)

ESX.RegisterServerCallback("kF5:server:getInventory", function(source, cb)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local plyInventory = xPlayer.getInventory()
	cb(plyInventory)
end)


ESX.RegisterServerCallback('kF5:Bill_getBills', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		local bills = {}

		for i = 1, #result do
			bills[#bills + 1] = {
				id = result[i].id,
				label = result[i].label,
				amount = result[i].amount
			}
		end

		cb(bills)
	end)
end)


--- Menu Gestion organisation/Entreprise

local function makeTargetedEventFunction(fn)
	return function(target, ...)
		if tonumber(target) == -1 then return end
		fn(target, ...)
	end
end

function getMaximumGrade(jobName)
	local p = promise.new()

	MySQL.Async.fetchScalar('SELECT grade FROM job_grades WHERE job_name = @job_name ORDER BY `grade` DESC', { ['@job_name'] = jobName }, function(result)
		p:resolve(result)
	end)

	local queryResult = Citizen.Await(p)

	return tonumber(queryResult)
end


RegisterServerEvent('kF5:Boss_promouvoirplayer')
AddEventHandler('kF5:Boss_promouvoirplayer', makeTargetedEventFunction(function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local sourceJob = sourceXPlayer.getJob()

	if sourceJob.grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)
		local targetJob = targetXPlayer.getJob()

		if sourceJob.name == targetJob.name then
			local newGrade = tonumber(targetJob.grade) + 1

			if newGrade ~= getMaximumGrade(targetJob.name) then
				targetXPlayer.setJob(targetJob.name, newGrade)

				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, ('Vous avez ~g~promu %s~w~.'):format(targetXPlayer.name))
				TriggerClientEvent('esx:showNotification', target, ('Vous avez été ~g~promu par %s~w~.'):format(sourceXPlayer.name))
			else
				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous devez demander une autorisation ~r~Gouvernementale~w~.')
			end
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Le joueur n\'es pas dans votre entreprise.')
		end
	else
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end))

RegisterServerEvent('kF5:Boss_destituerplayer')
AddEventHandler('kF5:Boss_destituerplayer', makeTargetedEventFunction(function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local sourceJob = sourceXPlayer.getJob()

	if sourceJob.grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)
		local targetJob = targetXPlayer.getJob()

		if sourceJob.name == targetJob.name then
			local newGrade = tonumber(targetJob.grade) - 1

			if newGrade >= 0 then
				targetXPlayer.setJob(targetJob.name, newGrade)

				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, ('Vous avez ~r~rétrogradé %s~w~.'):format(targetXPlayer.name))
				TriggerClientEvent('esx:showNotification', target, ('Vous avez été ~r~rétrogradé par %s~w~.'):format(sourceXPlayer.name))
			else
				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous ne pouvez pas ~r~rétrograder~w~ d\'avantage.')
			end
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Le joueur n\'es pas dans votre organisation.')
		end
	else
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end))

RegisterServerEvent('kF5:Boss_recruterplayer')
AddEventHandler('kF5:Boss_recruterplayer', makeTargetedEventFunction(function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local sourceJob = sourceXPlayer.getJob()

	if sourceJob.grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)

		targetXPlayer.setJob(sourceJob.name, 0)
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, ('Vous avez ~g~recruté %s~w~.'):format(targetXPlayer.name))
		TriggerClientEvent('esx:showNotification', target, ('Vous avez été ~g~embauché par %s~w~.'):format(sourceXPlayer.name))
	end
end))

RegisterServerEvent('kF5:Boss_virerplayer')
AddEventHandler('kF5:Boss_virerplayer', makeTargetedEventFunction(function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local sourceJob = sourceXPlayer.getJob()

	if sourceJob.grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)
		local targetJob = targetXPlayer.getJob()

		if sourceJob.name == targetJob.name then
			targetXPlayer.setJob('unemployed', 0)
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, ('Vous avez ~r~viré %s~w~.'):format(targetXPlayer.name))
			TriggerClientEvent('esx:showNotification', target, ('Vous avez été ~g~viré par %s~w~.'):format(sourceXPlayer.name))
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Le joueur n\'es pas dans votre entreprise.')
		end
	else
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end))

RegisterServerEvent('kF5:Boss_promouvoirplayer2')
AddEventHandler('kF5:Boss_promouvoirplayer2', makeTargetedEventFunction(function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local sourceorga = sourceXPlayer.getorga()

	if sourceorga.grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)
		local targetorga = targetXPlayer.getorga()

		if sourceorga.name == targetorga.name then
			local newGrade = tonumber(targetorga.grade) + 1

			if newGrade ~= getMaximumGrade(targetorga.name) then
				targetXPlayer.setorga(targetorga.name, newGrade)

				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, ('Vous avez ~g~promu %s~w~.'):format(targetXPlayer.name))
				TriggerClientEvent('esx:showNotification', target, ('Vous avez été ~g~promu par %s~w~.'):format(sourceXPlayer.name))
			else
				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous devez demander une autorisation ~r~Gouvernementale~w~.')
			end
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Le joueur n\'es pas dans votre organisation.')
		end
	else
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end))

RegisterServerEvent('kF5:Boss_destituerplayer2')
AddEventHandler('kF5:Boss_destituerplayer2', makeTargetedEventFunction(function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local sourceorga = sourceXPlayer.getorga()

	if sourceorga.grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)
		local targetorga = targetXPlayer.getorga()

		if sourceorga.name == targetorga.name then
			local newGrade = tonumber(targetorga.grade) - 1

			if newGrade >= 0 then
				targetXPlayer.setorga(targetorga.name, newGrade)

				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, ('Vous avez ~r~rétrogradé %s~w~.'):format(targetXPlayer.name))
				TriggerClientEvent('esx:showNotification', target, ('Vous avez été ~r~rétrogradé par %s~w~.'):format(sourceXPlayer.name))
			else
				TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous ne pouvez pas ~r~rétrograder~w~ d\'avantage.')
			end
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Le joueur n\'es pas dans votre organisation.')
		end
	else
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end))

RegisterServerEvent('kF5:Boss_recruterplayer2')
AddEventHandler('kF5:Boss_recruterplayer2', makeTargetedEventFunction(function(target, grade2)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local sourceorga = sourceXPlayer.getorga()

	if sourceorga.grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)

		targetXPlayer.setorga(sourceorga.name, 0)
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, ('Vous avez ~g~recruté %s~w~.'):format(targetXPlayer.name))
		TriggerClientEvent('esx:showNotification', target, ('Vous avez été ~g~embauché par %s~w~.'):format(sourceXPlayer.name))
	end
end))

RegisterServerEvent('kF5:Boss_virerplayer2')
AddEventHandler('kF5:Boss_virerplayer2', makeTargetedEventFunction(function(target)
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local sourceorga = sourceXPlayer.getorga()

	if sourceorga.grade_name == 'boss' then
		local targetXPlayer = ESX.GetPlayerFromId(target)
		local targetorga = targetXPlayer.getorga()

		if sourceorga.name == targetorga.name then
			targetXPlayer.setorga('unemployed2', 0)
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, ('Vous avez ~r~viré %s~w~.'):format(targetXPlayer.name))
			TriggerClientEvent('esx:showNotification', target, ('Vous avez été ~g~viré par %s~w~.'):format(sourceXPlayer.name))
		else
			TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Le joueur n\'es pas dans votre organisation.')
		end
	else
		TriggerClientEvent('esx:showNotification', sourceXPlayer.source, 'Vous n\'avez pas ~r~l\'autorisation~w~.')
	end
end))
ESX.RegisterServerCallback('kirito:getWeight', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	playerWeight = xPlayer.getWeight()
	cb(playerWeight)
end)

---- Twt 

RegisterNetEvent("twt:send")
AddEventHandler("twt:send",function(TweetText, SenderTweet)
    local name = GetPlayerName(source)
    local xPlayers    = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        TriggerClientEvent('tweet:sendtweet', xPlayers[i], SenderTweet, TweetText, name) 
        TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Twitter', 'Notiffication ['..SenderTweet..']','Contenue : '..TweetText, 'CHAR_STRETCH', 0)
         
    end
end)