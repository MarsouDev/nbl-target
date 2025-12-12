local QBCore = {}

local Core = nil
local PlayerData = {}
local Ready = false

local function GetCore()
    if Core then return Core end
    local ok, result = pcall(exports['qb-core'].GetCoreObject, exports['qb-core'])
    if ok and result then
        Core = result
        return Core
    end
    return nil
end

local function ParseGrade(gradeData)
    if not gradeData then return 0 end
    if type(gradeData) == 'number' then return gradeData end
    if type(gradeData) == 'table' then return gradeData.level or 0 end
    return 0
end

function QBCore.Init()
    local core = GetCore()
    if not core then return false end

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = core.Functions.GetPlayerData() or {}
        Ready = true
        if Config and Config.Debug and Config.Debug.enabled then
            print('^2[nbl-target] QBCore player loaded: ' .. (PlayerData.job and PlayerData.job.name or 'unknown') .. '^7')
        end
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        PlayerData = {}
        Ready = false
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
        PlayerData.job = JobInfo
        if Config and Config.Debug and Config.Debug.enabled then
            print('^2[nbl-target] QBCore job updated: ' .. (JobInfo and JobInfo.name or 'none') .. '^7')
        end
    end)

    RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
        PlayerData.gang = GangInfo
        if Config and Config.Debug and Config.Debug.enabled then
            print('^2[nbl-target] QBCore gang updated: ' .. (GangInfo and GangInfo.name or 'none') .. '^7')
        end
    end)

    RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
        PlayerData = val or {}
    end)

    local data = core.Functions.GetPlayerData()
    if data and next(data) then
        PlayerData = data
        Ready = true
    end

    return true
end

function QBCore.IsReady()
    return Ready
end

function QBCore.GetJob()
    local job = PlayerData.job
    if not job then return nil, 0 end
    return job.name, ParseGrade(job.grade)
end

function QBCore.GetGang()
    local gang = PlayerData.gang
    if not gang then return nil, 0 end
    return gang.name, ParseGrade(gang.grade)
end

function QBCore.GetGroups()
    local groups = {}
    local jobName = QBCore.GetJob()
    if jobName then groups[jobName] = true end
    local gangName = QBCore.GetGang()
    if gangName then groups[gangName] = true end
    return groups
end

function QBCore.HasItem(itemName, amount)
    amount = amount or 1
    local core = GetCore()
    if not core then return false end
    local fn = core.Functions.HasItem
    if not fn then return false end
    local ok, result = pcall(fn, itemName, amount)
    return ok and result == true
end

return QBCore
