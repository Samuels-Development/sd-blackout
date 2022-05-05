local QBCore = exports['qb-core']:GetCoreObject()

blackout = false

local CurrentCops = 0

-- Cop Minimum Amount

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)


-- Blackout Start

RegisterNetEvent('sd-blackout:client:startblackout', function ()
	QBCore.Functions.TriggerCallback("sd-blackout:server:getCops", function(enoughCops)
    if enoughCops >= Config.MinimumPolice then
        QBCore.Functions.TriggerCallback("sd-blackout:server:coolc",function(isCooldown)
            if not isCooldown then
                QBCore.Functions.Progressbar("search_register", "Preparing Explosive", 3000, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
					animDict = 'mp_arresting',
					anim = 'a_uncuff',
					flags = 16,
                }, {}, {}, function() -- Done
					TriggerServerEvent('sd-blackout:server:startr')
                    blackout = true
                    TriggerEvent('sd-bombplant')
                end, function() -- Cancel
                    QBCore.Functions.Notify("Cancelled", 'error')
                end)
            else
                QBCore.Functions.Notify("Someone Recently did this.", 'error')
            end
        end)
    else
        QBCore.Functions.Notify("Cannot do this right now.", 'error')
	end
end)
end)

-- Planting Bomb

RegisterNetEvent('sd-bombplant')
AddEventHandler('sd-bombplant', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
        if hasItem then
            bombanime()
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["c4_bomb"], "remove")
            TriggerServerEvent("QBCore:Server:RemoveItem", "c4_bomb", 1) 
            QBCore.Functions.Notify("Explosive has been planted! Get to safe a distance!", 'success')
            Citizen.Wait(13000)
            TriggerEvent("sd-blackout")
        else
            QBCore.Functions.Notify("You dont have C4!", 'error')
        end
    end, "c4_bomb")
end)


-- Explosion

RegisterNetEvent('sd-blackout')
AddEventHandler('sd-blackout', function()
	Citizen.Wait(7500)
    AddExplosion(651.39, 100.92, 80.74, 2, 100000.0, true, false, 4.0)
	Citizen.Wait(1000)
	AddExplosion(695.380, 148.735, 84.2194, 29, 6000000000000000000000000000000000000000000.0, true, false, 2.5)
        Citizen.Wait(800)
        AddExplosion(677.273, 118.022, 84.2194, 29, 600000000000000000000000.0, true, false, 2.5)
        Citizen.Wait(800)
        AddExplosion(661.905, 123.143, 84.2194, 29, 600000000000000000000000.0, true, false, 2.5)
        Citizen.Wait(800)
        AddExplosion(703.672, 108.393, 84.2194, 29, 600000000000000000000000.0, true, false, 2.5)
        Citizen.Wait(800)
		TriggerEvent("chat:addMessage", {
			color = {255, 255, 255},
			-- multiline = true,
			template = '<div style="padding: 15px; margin: 15px; background-color: rgba(180, 117, 22, 0.9); border-radius: 15px;"><i class="far fa-building"style="font-size:15px"></i> | {0} </font></i></b></div>',
			args = {"City Power is currently out, we're working on restoring it!"}
		})
	Citizen.Wait(500)
	TriggerServerEvent("qb-weathersync:server:toggleBlackout")
end)

RegisterCommand('blackout2', function(source, args, rawCommand)
	TriggerEvent('sd-blackout')
	end)


-- Blackout Restoration

RegisterNetEvent('sd-blackoutfix')
AddEventHandler('sd-blackoutfix', function()
	TriggerEvent("chat:addMessage", {
        color = {255, 255, 255},
        -- multiline = true,
        template = '<div style="padding: 15px; margin: 15px; background-color: rgba(180, 117, 22, 0.9); border-radius: 15px;"><i class="far fa-building"style="font-size:15px"></i> | {0} </font></i></b></div>',
        args = {"Power has been restored!"}
	})
	TriggerServerEvent("qb-weathersync:server:toggleBlackout")
end)
	
-- Explosive Plant Animation

function bombanime()
    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    RequestModel("hei_p_m_bag_var22_arm_s")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(50)
    end
    local ped = PlayerPedId()

    SetEntityHeading(ped, 162.54)
    Citizen.Wait(100)
    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(PlayerPedId())))
    local bagscene = NetworkCreateSynchronisedScene(651.39, 100.92, 80.84, rotx, roty, rotz + 1.1, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), 651.99, 100.92, 80.84,  true,  true, false)

    SetEntityCollision(bag, false, true)
    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.2, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    NetworkStartSynchronisedScene(bagscene)
    Citizen.Wait(1500)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local bomba = CreateObject(GetHashKey("hei_prop_heist_thermite"), x, y, z + 0.3,  true,  true, true)

    SetEntityCollision(bomba, false, true)
    AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
    Citizen.Wait(2000)
    DeleteObject(bag)
    SetPedComponentVariation(ped, 5, 45, 0, 0)
    DetachEntity(bomba, 1, 1)
    FreezeEntityPosition(bomba, true)

    NetworkStopSynchronisedScene(bagscene)
    Citizen.Wait(2000)
    ClearPedTasks(ped)
    DeleteObject(bomba)
    StopParticleFxLooped(effect, 0)
end

-- Target Exports

exports["qb-target"]:AddCircleZone("Bomb", vector3(651.99, 101.11, 81.16), 2.0, {
    name = "Bomb",
    useZ = true,
    --debugPoly=true
    }, {
        options = {
            {
                type = "client",
                event = "sd-blackout:client:startblackout",
                icon = "fas fa-bomb",
                label = "Plant Explosive"
            },
            { 	
                type = "client",
                event = "sd-blackoutfix",
                icon = "fas fa-user-secret",
                label = "Restore Power",
                job = "police",
		
		            canInteract = function()
                            if blackout then return true else return false end 
                        end

            },
        },
        distance = 2.0
    })
