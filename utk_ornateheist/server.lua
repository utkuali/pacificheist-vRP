local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","utk_ornateheist")

local lastrobbed = 0 -- don't change this
local info = {stage = 0, style = nil, locked = false}
local totalcash = 0
local PoliceDoors = {
    {loc = vector3(257.10, 220.30, 106.28), txtloc = vector3(257.10, 220.30, 106.28), model = "hei_v_ilev_bk_gate_pris", model2 = "hei_v_ilev_bk_gate_molten", obj = nil, obj2 = nil, locked = true},
    {loc = vector3(236.91, 227.50, 106.29), txtloc = vector3(236.91, 227.50, 106.29), model = "v_ilev_bk_door", model2 = "v_ilev_bk_door", obj = nil, obj2 = nil, locked = true},
    {loc = vector3(262.35, 223.00, 107.05), txtloc = vector3(262.35, 223.00, 107.05), model = "hei_v_ilev_bk_gate2_pris", model2 = "hei_v_ilev_bk_gate2_pris", obj = nil, obj2 = nil, locked = true},
    {loc = vector3(252.72, 220.95, 101.68), txtloc = vector3(252.72, 220.95, 101.68), model = "hei_v_ilev_bk_safegate_pris", model2 = "hei_v_ilev_bk_safegate_molten", obj = nil, obj2 = nil, locked = true},
    {loc = vector3(261.01, 215.01, 101.68), txtloc = vector3(261.01, 215.01, 101.68), model = "hei_v_ilev_bk_safegate_pris", model2 = "hei_v_ilev_bk_safegate_molten", obj = nil, obj2 = nil, locked = true},
    {loc = vector3(253.92, 224.56, 101.88), txtloc = vector3(253.92, 224.56, 101.88), model = "v_ilev_bk_vaultdoor", model2 = "v_ilev_bk_vaultdoor", obj = nil, obj2 = nil, locked = true}
}
RegisterServerEvent('utk_oh:GetData')
AddEventHandler('utk_oh:GetData', function()
    TriggerClientEvent('utk_oh:GetData', source, info)
end)
RegisterServerEvent('utk_oh:GetDoors')
AddEventHandler('utk_oh:GetDoors', function()
    TriggerClientEvent('utk_oh:GetDoors', source, PoliceDoors)
end)

RegisterServerEvent('utk_oh:startevent')
AddEventHandler('utk_oh:startevent', function(method)
    local copcount = 0
	local user_id = vRP.getUserId({source})

    if not info.locked then
        if (os.time() - Config.cooldown) > lastrobbed then
            local cops = vRP.getUsersByPermission({Config.PermCops})
			copcount = #cops
            if copcount >= Config.MinCops then
                if method == 1 then
					if vRP.tryGetInventoryItem({user_id,Config.items.thermal,1,true}) then
                        TriggerClientEvent('utk_oh:startevent', source, true)
                        info.stage = 1
                        info.style = 1
                        info.locked = true
                    else
                        TriggerClientEvent('utk_oh:startevent', source, Config.text.nothermal)
                    end
                elseif method == 2 then
                    if vRP.tryGetInventoryItem({user_id,Config.items.lockpick,1,true}) then
                        info.stage = 1
                        info.style = 2
                        info.locked = true
                        TriggerClientEvent('utk_oh:startevent', source, true)
                    else
                        TriggerClientEvent('utk_oh:startevent', source, Config.text.nolockpick)
                    end
                end
            else
                TriggerClientEvent('utk_oh:startevent', source, Config.text.mincops)
            end
        else
            TriggerClientEvent('utk_oh:startevent', source, math.floor((Config.cooldown - (os.time() - lastrobbed)) / 60)..":"..math.fmod((Config.cooldown - (os.time() - lastrobbed)), 60).." "..Config.text.timeleft)
        end
    else
        TriggerClientEvent('utk_oh:startevent', source, Config.text.alreadyrobbed)
    end
end)

RegisterServerEvent('utk_oh:checkItem')
AddEventHandler('utk_oh:checkItem', function(itemname)
	local user_id = vRP.getUserId({source})
    if vRP.tryGetInventoryItem({user_id,itemname,1,false}) then
        TriggerClientEvent('utk_oh:checkItem', source, true)
    else
        TriggerClientEvent('utk_oh:checkItem', source, false)
    end
end)

RegisterServerEvent('utk_oh:gettotalcash')
AddEventHandler('utk_oh:gettotalcash', function()
    TriggerClientEvent('utk_oh:gettotalcash', source, totalcash)
end)

RegisterServerEvent("utk_oh:updatecheck")
AddEventHandler("utk_oh:updatecheck", function(var, status)
    TriggerClientEvent("utk_oh:updatecheck_c", -1, var, status)
end)
RegisterServerEvent("utk_oh:policeDoor")
AddEventHandler("utk_oh:policeDoor", function(doornum, status)
    PoliceDoors[doornum].locked = status
    TriggerClientEvent("utk_oh:policeDoor_c", -1, doornum, status)
end)
RegisterServerEvent("utk_oh:moltgate")
AddEventHandler("utk_oh:moltgate", function(x, y, z, oldmodel, newmodel, method)
    TriggerClientEvent("utk_oh:moltgate_c", -1, x, y, z, oldmodel, newmodel, method)
end)
RegisterServerEvent("utk_oh:fixdoor")
AddEventHandler("utk_oh:fixdoor", function(hash, coords, heading)
    TriggerClientEvent("utk_oh:fixdoor_c", -1, hash, coords, heading)
end)
RegisterServerEvent("utk_oh:openvault")
AddEventHandler("utk_oh:openvault", function(method)
    TriggerClientEvent("utk_oh:openvault_c", -1, method)
end)
RegisterServerEvent("utk_oh:startloot")
AddEventHandler("utk_oh:startloot", function()
    TriggerClientEvent("utk_oh:startloot_c", -1)
end)
RegisterServerEvent("utk_oh:rewardCash")
AddEventHandler("utk_oh:rewardCash", function()
	local user_id = vRP.getUserId({source})
    local reward = math.random(Config.mincash, Config.maxcash)

    if Config.black then
		vRP.giveInventoryItem({user_id, Config.items.dirty_money, reward, true})
        totalcash = totalcash + reward
    else
        vRP.giveMoney({user_id,reward})
        totalcash = totalcash + reward
    end
end)
RegisterServerEvent("utk_oh:rewardGold")
AddEventHandler("utk_oh:rewardGold", function()
    local user_id = vRP.getUserId({source})

	vRP.giveInventoryItem({user_id, Config.items.gold, 1, true})
end)
RegisterServerEvent("utk_oh:rewardDia")
AddEventHandler("utk_oh:rewardDia", function()
	local user_id = vRP.getUserId({source})

	vRP.giveInventoryItem({user_id, Config.items.diamond, 1, true})
end)
RegisterServerEvent("utk_oh:giveidcard")
AddEventHandler("utk_oh:giveidcard", function()
    local src = source
    local user_id = vRP.getUserId({src})

	vRP.giveInventoryItem({user_id, Config.items.id_card, 2, true})
end)
RegisterServerEvent("utk_oh:ostimer")
AddEventHandler("utk_oh:ostimer", function()
    lastrobbed = os.time()
    info.stage, info.style, info.locked = 0, nil, false
    Citizen.Wait(300000)
    for i = 1, #PoliceDoors, 1 do
        PoliceDoors[i].locked = true
        TriggerClientEvent("utk_oh:policeDoor_c", -1, i, true)
    end
    totalcash = 0
    TriggerClientEvent("utk_oh:reset", -1)
end)
RegisterServerEvent("utk_oh:gas")
AddEventHandler("utk_oh:gas", function()
    TriggerClientEvent("utk_oh:gas_c", -1)
end)
RegisterServerEvent("utk_oh:ptfx")
AddEventHandler("utk_oh:ptfx", function(method)
   TriggerClientEvent("utk_oh:ptfx_c", -1, method)
end)
RegisterServerEvent("utk_oh:alarm_s")
AddEventHandler("utk_oh:alarm_s", function(toggle)
    if Config.enablesound then
        TriggerClientEvent("utk_oh:alarm", -1, toggle)
    end
    TriggerClientEvent("utk_oh:policenotify", -1, toggle)
end)
RegisterServerEvent('utk_oh:CheckCop')
AddEventHandler('utk_oh:CheckCop', function()
	local user_id = vRP.getUserId({source})
	local player = vRP.getUserSource({user_id})
	if vRP.hasPermission({user_id,"police.service"}) then
		TriggerClientEvent('utk_oh:IsCop',user_id)
	else
		TriggerClientEvent('utk_oh:IsNOTCop',user_id)
	end
end)
