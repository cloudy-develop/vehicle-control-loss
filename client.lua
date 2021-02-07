local playerPed = 0
local playerVehicle = 0
local vehicleAllowed = false
local vehControlEnabled = false
local isPadShaking = false

Citizen.CreateThread(function()
    while (true) do

        if (vehicleAllowed) then

            if not (vehControlEnabled) then

                if (GetEntitySpeed(playerVehicle) > 30.0) and (GetVehicleSteeringAngle(playerVehicle) > 30.0) then

                    if (math.random(0, config.steeringChance) == 0) then
                        TriggerEvent('VehicleControlLoss', playerVehicle)
                    end

                end

            else

                if (IsControlPressed(0, 72)) or (IsControlPressed(0, 76)) then
                    ShakePad()
                end

            end

            

        end

        Citizen.Wait(0)

    end

end)

Citizen.CreateThread(function()

    while (true) do

        playerPed = PlayerPedId()
        playerVehicle = GetVehiclePedIsIn(playerPed, false)

        if (IsWeatherAccurate(GetNextWeatherTypeHashName())) then

            if (playerVehicle ~= 0) and (GetPedInVehicleSeat(playerVehicle, -1) == playerPed) then

                if not (IsClassDisabled(playerVehicle)) and not (IsVehicleDisabled(playerVehicle)) then

                    if not (vehicleAllowed) then
                        vehicleAllowed = true
                    end

                    if not (vehControlEnabled) then

                        if (GetEntitySpeed(playerVehicle) > 20.0) then

                            if (math.random(0, config.randomChance) == 0) then
                                TriggerEvent('VehicleControlLoss', playerVehicle)
                            end
            
                        end

                    end

                else

                    if (vehicleAllowed) then
                        vehicleAllowed = false
                    end

                end

            else

                if (vehicleAllowed) then
                    vehicleAllowed = false
                end

            end

        else

            if (vehicleAllowed) then
                vehicleAllowed = false
            end

        end

        Citizen.Wait(1000)

    end

end)

function IsWeatherAccurate(weather)

    local accurateWeather = {
        1840358669, -- Clearing
        1420204096, -- Rain
        -1233681761, -- Thunder
        -1429616491, -- Xmas
        603685163, -- Light Snow
        -273223690, -- Snow
        669657108 -- Blizzard
    }

    for i,var in pairs(accurateWeather) do

        if (var == weather) then
            return true
        end

    end

    return false

end

function IsClassDisabled(vehicle)

    local vehClass = GetVehicleClass(vehicle)
    local disabledClasses = {
        10, -- Industrial
        13, -- Cycles
        14, -- Boats
        15, -- Helicopters
        16, -- Planes
        19, -- Military
        21 -- Trains
    }

    for i,var in pairs(disabledClasses) do

        if (var == vehClass) then
            return true
        end

    end

    return false

end

function IsVehicleDisabled(vehicle)

    for i,var in pairs(config.disabledVehicles) do

        if (GetHashKey(var) == GetEntityModel(vehicle)) then
            return true
        end

    end

    return false

end

function ShakePad()

    if not (isPadShaking) then

        isPadShaking = true

        local shakeDuration = math.random(1, 2) * 100

        StopPadShake(0)
        SetPadShake(0, shakeDuration, 255)

        Wait(shakeDuration + 100)

        isPadShaking = false

    end

end

RegisterNetEvent('VehicleControlLoss')
AddEventHandler('VehicleControlLoss', function(vehicle)

    vehControlEnabled = true
    SetVehicleReduceGrip(vehicle, true)

    Wait(math.random(1, 8) * 1000)

    SetVehicleReduceGrip(vehicle, false)
    vehControlEnabled = false

end)