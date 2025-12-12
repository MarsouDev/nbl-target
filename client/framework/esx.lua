local ESX = {}

local Core = nil
local PlayerData = {}
local Ready = false

local function GetCore()
    if Core then return Core end
    local ok, result = pcall(exports['es_extended'].getSharedObject, exports['es_extended'])
    if ok and result then
        Core = result
        return Core
    end
    return nil
end

function ESX.Init()
    local core = GetCore()
    if not core then return false end

    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer or {}
        Ready = true
        if Config and Config.Debug and Config.Debug.enabled then
            print('^2[nbl-target] ESX player loaded: ' .. (PlayerData.job and PlayerData.job.name or 'unknown') .. '^7')
        end
    end)

    RegisterNetEvent('esx:setJob', function(job)
        PlayerData.job = job
        if Config and Config.Debug and Config.Debug.enabled then
            print('^2[nbl-target] ESX job updated: ' .. (job and job.name or 'none') .. '^7')
        end
    end)

    local data = core.GetPlayerData()
    if data and next(data) then
        PlayerData = data
        Ready = true
    end

    return true
end

function ESX.IsReady()
    return Ready
end

function ESX.GetJob()
    local job = PlayerData.job
    if not job then return nil, 0 end
    return job.name, job.grade or 0
end

function ESX.GetGang()
    return nil, 0
end

function ESX.GetGroups()
    local groups = {}
    local jobName = ESX.GetJob()
    if jobName then
        groups[jobName] = true
    end
    return groups
end

function ESX.HasItem(itemName, amount)
    amount = amount or 1
    local inv = PlayerData.inventory
    if not inv then return false end
    for i = 1, #inv do
        local item = inv[i]
        if item and item.name == itemName then
            return (item.count or 0) >= amount
        end
    end
    return false
end

return ESX
