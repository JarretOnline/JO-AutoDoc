local QBCore = exports['qb-core']:GetCoreObject()

local Active = false
local test = nil
local test1 = nil
local spam = true


RegisterCommand("help", function(source, args, raw)
	--if (QBCore.Functions.GetPlayerData().metadata["isdead"]) or (QBCore.Functions.GetPlayerData().metadata["inlaststand"]) and spam then

	exports['okokNotify']:Alert("SUCCESS", "EMS NOTIFIED", 2000, 'success')
	Wait(math.random(6000,8000))
	exports['okokNotify']:Alert("SUCCESS", "MEDIC AVAILABLE", 2000, 'success')
	Wait(math.random(12000,20000))
		QBCore.Functions.TriggerCallback('hhfw:docOnline', function(EMSOnline, hasEnoughMoney)
			if hasEnoughMoney and spam then
				exports['okokNotify']:Alert("SUCCESS", "EMS DISPATCHED", 2000, 'success')
				SpawnVehicle(GetEntityCoords(PlayerPedId()))
				--Notify("EMS NOTIFIED")
				spam = true
			else
				if not hasEnoughMoney then
					--Notify("NEED MONEYS", "error")
					exports['okokNotify']:Alert("ERROR", "NEED MONEYS", 2000, 'error')
				else
					--Notify("EMS NOTIFIED", "primary")
					exports['okokNotify']:Alert("SUCCESS", "EMS RETURNED", 2000, 'success')
				end	
			end 
		end)
end)


RegisterCommand("nohelp", function(source, args, raw)
	ClearPedTasks(test1)
	RemovePedElegantly(test1)
	DeleteEntity(test)
	RemoveBlip(mechBlip)
	RemoveBlip(mechVeh)
	exports['okokNotify']:Alert("NOTICE", "CLEARED EMS", 1000, 'warning')
	spam = true
end)

function SpawnVehicle(x, y, z)  
	spam = false
	local vehhash = GetHashKey("manchez")                                                     
	local loc = GetEntityCoords(PlayerPedId())
	RequestModel(vehhash)
	while not HasModelLoaded(vehhash) do
		Wait(1)
	end
	RequestModel('s_m_y_autopsy_01')
	while not HasModelLoaded('s_m_y_autopsy_01') do
		Wait(1)
	end
	local spawnRadius = 60                                                    
    local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(loc.x + math.random(-spawnRadius, spawnRadius), loc.y + math.random(-spawnRadius, spawnRadius), loc.z, 0, 1, 0)

	if not DoesEntityExist(vehhash) then
        mechVeh = CreateVehicle(vehhash, spawnPos, spawnHeading, true, false)                        
        ClearAreaOfVehicles(GetEntityCoords(mechVeh), 5000, false, false, false, false, false);  
        SetVehicleOnGroundProperly(mechVeh)
		SetVehicleNumberPlateText(mechVeh, "HELP")
		SetEntityAsMissionEntity(mechVeh, true, true)
		SetVehicleEngineOn(mechVeh, true, true, false)
        
        mechPed = CreatePedInsideVehicle(mechVeh, 26, GetHashKey('s_m_y_autopsy_01'), -1, true, false)              	
        
        mechBlip = AddBlipForEntity(mechVeh)                                                        	
        SetBlipFlashes(mechBlip, true)  
        SetBlipColour(mechBlip, 5)


		PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", 1)
		Wait(2000)
		TaskVehicleDriveToCoord(mechPed, mechVeh, loc.x, loc.y, loc.z, 10.0, 0, GetEntityModel(mechVeh), 524863, 1.0)
		test = mechVeh
		test1 = mechPed
		Active = true
    end
end

Citizen.CreateThread(function()
    while true do
      Citizen.Wait(200)
        if Active then
            local loc = GetEntityCoords(GetPlayerPed(-1))
			local lc = GetEntityCoords(test)
			local ld = GetEntityCoords(test1)
            local dist = Vdist(loc.x, loc.y, loc.z, lc.x, lc.y, lc.z)
			local dist1 = Vdist(loc.x, loc.y, loc.z, ld.x, ld.y, ld.z)
            if dist <= 20 then
				if Active then
					TaskGoToCoordAnyMeans(test1, loc.x, loc.y, loc.z, 2.0, 0, 0, 786603, 0xbf800000)
				end
				if dist1 <= 4 then 
					Active = false
					ClearPedTasksImmediately(test1)
					DoctorNPC()
				end
            end
        end
    end
end)


function DoctorNPC()
	RequestAnimDict("cellphone@female")
	while not HasAnimDictLoaded("cellphone@female") do
		Citizen.Wait(1000)
	end

	TaskPlayAnim(test1, "cellphone@female","cellphone_text_read_base",1.0, 1.0, -1, 9, 1.0, 0, 0, 0)
	QBCore.Functions.Progressbar("revive_doc", "FIXING WOUNDS", 8000, false, false, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = true,
		disableCombat = true,
	}, {}, {}, {}, function() -- Done
		ClearPedTasks(test1)
		Citizen.Wait(500)
        	TriggerEvent("hospital:client:Revive")
		TriggerServerEvent('hhfw:charge')
		StopScreenEffect('DeathFailOut')	
		Notify("HEALED: $"..Config.Price, "success")
		RemovePedElegantly(test1)
		DeleteEntity(test)
		RemovePedElegantly(test1)
		DeleteEntity(test)
		spam = true
	end)
end


function Notify(msg, state)
    QBCore.Functions.Notify(msg, state)
end
