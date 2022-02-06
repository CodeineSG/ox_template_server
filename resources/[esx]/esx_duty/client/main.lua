local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}


--- action functions
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil


--- esx
local GUI = {}
ESX                           = nil
GUI.Time                      = 0
local PlayerData              = {}

Citizen.CreateThread(function ()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
 	PlayerData = ESX.GetPlayerData()
  end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

----markers
AddEventHandler('esx_duty:hasEnteredMarker', function (zone)
  if zone == 'AmbulanceDuty' then
    CurrentAction     = 'ambulance_duty'
    CurrentActionMsg  = _U('duty')
    CurrentActionData = {}
  end
  if zone == 'PoliceDuty' then
    CurrentAction     = 'police_duty'
    CurrentActionMsg  = _U('duty')
    CurrentActionData = {}
  end
end)

AddEventHandler('esx_duty:hasExitedMarker', function (zone)
  CurrentAction = nil
end)


--keycontrols
--[[Citizen.CreateThread(function ()
  while true do
    Citizen.Wait(0)

      local playerPed = GetPlayerPed(-1)

    if CurrentAction ~= nil then
      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlPressed(0, Keys['E']) then
        if CurrentAction == 'ambulance_duty' then
          if PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'offambulance' then
            TriggerServerEvent('duty:ambulance')
          if PlayerData.job.name == 'ambulance' then
            sendNotification(_U('offduty'), 'success', 2500)
            Wait(1000)
          else
            sendNotification(_U('onduty'), 'success', 2500)
            Wait(1000)
          end
        else
          sendNotification(_U('notamb'), 'error', 5000)
          Wait(1000)
        end
      end

        if CurrentAction == 'police_duty' then
          if PlayerData.job.name == 'police' or PlayerData.job.name == 'offpolice' then
            TriggerServerEvent('duty:police')
          if PlayerData.job.name == 'police' then
            sendNotification(_U('offduty'), 'success', 2500)
            Wait(1000)
          else
            sendNotification(_U('onduty'), 'success', 2500)
            Wait(1000)
          end
        else
          sendNotification(_U('notpol'), 'error', 5000)
          Wait(1000)
          end
        end
      end
    end
  end
end)]]--

-- Display markers
--[[Citizen.CreateThread(function ()
  while true do
    Wait(0)

    local coords = GetEntityCoords(GetPlayerPed(-1))

    for k,v in pairs(Config.Zones) do
      if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
        DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
      end
    end
  end
end)]]--

-- Enter / Exit marker events
--[[Citizen.CreateThread(function ()
  while true do
    Wait(0)

    local coords      = GetEntityCoords(GetPlayerPed(-1))
    local isInMarker  = false
    local currentZone = nil

    for k,v in pairs(Config.Zones) do
      if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
        isInMarker  = true
        currentZone = k
      end
    end

    if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
      HasAlreadyEnteredMarker = true
      LastZone                = currentZone
      TriggerEvent('esx_duty:hasEnteredMarker', currentZone)
    end

    if not isInMarker and HasAlreadyEnteredMarker then
      HasAlreadyEnteredMarker = false
      TriggerEvent('esx_duty:hasExitedMarker', LastZone)
    end
  end
end)]]--

--notification
function sendNotification(message, messageType, messageTimeout)
	TriggerEvent("pNotify:SendNotification", {
		text = message,
		type = messageType,
		queue = "duty",
		timeout = messageTimeout,
		layout = "bottomCenter"
	})
end
--end)



RegisterNetEvent('esx_duty:duty')
AddEventHandler('esx_duty:duty', function()
    local ped = PlayerPedId()

    RequestAnimDict("anim@heists@keycard@")
--loadAnimDict("anim@heists@keycard@")
        TaskPlayAnim( GetPlayerPed(-1), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(600)
    ClearPedTasks(GetPlayerPed(-1))
    TriggerServerEvent('duty:police')
    --exports["mythic_notify"]:SendAlert("inform", "Toggled Duty")
    exports['notify1']:Alert("Information", "Toggled Duty.", 2500, 'info')
end)

RegisterNetEvent('esx_duty:aduty')
AddEventHandler('esx_duty:aduty', function()
    local ped = PlayerPedId()

    RequestAnimDict("anim@heists@keycard@")
--loadAnimDict("anim@heists@keycard@")
        TaskPlayAnim( GetPlayerPed(-1), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(600)
    ClearPedTasks(GetPlayerPed(-1))
    TriggerServerEvent('duty:ambulance')
    --exports["mythic_notify"]:SendAlert("inform", "Toggled Duty")
      exports['notify1']:Alert("Information", "Toggled Duty.", 2500, 'info')
end)

RegisterNetEvent('esx_duty:dutyb')
AddEventHandler('esx_duty:dutyb', function()
    local ped = PlayerPedId()

    RequestAnimDict("anim@heists@keycard@")
--loadAnimDict("anim@heists@keycard@")
        TaskPlayAnim( GetPlayerPed(-1), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(600)
    ClearPedTasks(GetPlayerPed(-1))
    TriggerServerEvent('duty:police')
    --exports["mythic_notify"]:SendAlert("inform", "Toggled Duty")
    exports['notify1']:Alert("Information", "Toggled Duty.", 2500, 'info')
end)



-- Put these in the qtarget client.lua
	exports['qtarget']:AddBoxZone("MissionRowDutyClipboard", vector3(441.7989, -982.0529, 30.67834), 0.45, 0.35, {
		name="MissionRowDutyClipboard",
		heading=11.0,
		debugPoly=true,
		minZ=30.77834,
		maxZ=30.87834,
		}, {
			options = {
				{
					event = "esx_duty:duty",
					icon = "fas fa-sign-in-alt",
					label = "Sign In",
					job = "offpolice",
				},
				{
					event = "esx_duty:duty",
					icon = "fas fa-sign-out-alt",
					label = "Sign Out",
					job = "police",
				},
			},
			distance = 3.5
	})

	exports['qtarget']:AddBoxZone("aduty", vector3(307.50, -595.35, 43.10), 0.30, 0.50, {
		name="aduty",
		heading=91.0,
		debugPoly=true,
		minZ=43.10,
		maxZ=43.20,
		}, {
			options = {
				{
					event = "esx_duty:aduty",
					icon = "fas fa-sign-in-alt",
					label = "Sign In",
					job = "offambulance",
				},
				{
					event = "esx_duty:aduty",
					icon = "fas fa-sign-out-alt",
					label = "Sign Out",
					job = "ambulance",
				},
			},
			distance = 3.5
	})