local Framework = {
    name = nil,
    ready = false
}

local Provider = nil
local WarnedOptions = {}

local function WarnOnce(optionName, field, message)
    local key = tostring(optionName or 'unknown') .. '_' .. tostring(field)
    if WarnedOptions[key] then return end
    WarnedOptions[key] = true
    local label = optionName and ('"' .. tostring(optionName) .. '"') or '(unnamed)'
    print('^3[nbl-target] Option ' .. label .. ': "' .. field .. '" ' .. message .. '^7')
end

local function LoadModule(path)
    local content = LoadResourceFile(GetCurrentResourceName(), path .. '.lua')
    if not content then return nil end
    local chunk, err = load(content, path)
    if not chunk then
        if Config and Config.Debug and Config.Debug.enabled then
            print('^1[nbl-target] Failed to load module ' .. path .. ': ' .. tostring(err) .. '^7')
        end
        return nil
    end
    local ok, result = pcall(chunk)
    if not ok then
        if Config and Config.Debug and Config.Debug.enabled then
            print('^1[nbl-target] Failed to execute module ' .. path .. ': ' .. tostring(result) .. '^7')
        end
        return nil
    end
    return result
end

local function Init()
    if GetResourceState('es_extended') == 'started' then
        Provider = LoadModule('client/framework/esx')
        if Provider and Provider.Init() then
            Framework.name = 'esx'
            Framework.ready = true
            print('^2[nbl-target] Framework: ESX^7')
        else
            print('^1[nbl-target] Framework: ESX detected but failed to initialize^7')
        end
    elseif GetResourceState('qb-core') == 'started' then
        Provider = LoadModule('client/framework/qbcore')
        if Provider and Provider.Init() then
            Framework.name = 'qbcore'
            Framework.ready = true
            print('^2[nbl-target] Framework: QBCore^7')
        else
            print('^1[nbl-target] Framework: QBCore detected but failed to initialize^7')
        end
    else
        print('^3[nbl-target] Framework: Standalone (no ESX/QBCore detected)^7')
    end
end

function Framework.GetName()
    return Framework.name
end

function Framework.IsReady()
    return Framework.ready
end

function Framework.GetJob()
    if Provider and Provider.GetJob then
        return Provider.GetJob()
    end
    return nil, 0
end

function Framework.GetGang()
    if Provider and Provider.GetGang then
        return Provider.GetGang()
    end
    return nil, 0
end

function Framework.GetGroups()
    if Provider and Provider.GetGroups then
        return Provider.GetGroups()
    end
    return {}
end

function Framework.HasItem(itemName, amount)
    if Provider and Provider.HasItem then
        return Provider.HasItem(itemName, amount or 1)
    end
    return false
end

function Framework.CanCheckJob()
    return Framework.ready
end

function Framework.CanCheckGang()
    return Framework.name == 'qbcore'
end

function Framework.CanCheckGroups()
    return Framework.ready
end

function Framework.CanCheckItems()
    return Framework.ready
end

local function CheckJob(filter)
    if not filter then return true end
    local job, grade = Framework.GetJob()
    if not job then return false end

    if type(filter) == 'string' then
        return job == filter
    end

    if type(filter) == 'table' then
        if filter[1] then
            for i = 1, #filter do
                if job == filter[i] then return true end
            end
            return false
        end
        for name, req in pairs(filter) do
            if job == name then
                if type(req) == 'number' then
                    return grade >= req
                end
                return true
            end
        end
        return false
    end

    return false
end

local function CheckGang(filter)
    if not filter then return true end
    local gang, grade = Framework.GetGang()
    if not gang then return false end

    if type(filter) == 'string' then
        return gang == filter
    end

    if type(filter) == 'table' then
        if filter[1] then
            for i = 1, #filter do
                if gang == filter[i] then return true end
            end
            return false
        end
        for name, req in pairs(filter) do
            if gang == name then
                if type(req) == 'number' then
                    return grade >= req
                end
                return true
            end
        end
        return false
    end

    return false
end

local function CheckGroups(filter)
    if not filter then return true end
    local groups = Framework.GetGroups()

    if type(filter) == 'string' then
        return groups[filter] == true
    end

    if type(filter) == 'table' then
        if filter[1] then
            for i = 1, #filter do
                if groups[filter[i]] then return true end
            end
            return false
        end
        for name in pairs(filter) do
            if groups[name] then return true end
        end
        return false
    end

    return false
end

local function CheckItems(filter)
    if not filter then return true end

    if type(filter) == 'string' then
        return Framework.HasItem(filter, 1)
    end

    if type(filter) == 'table' then
        if filter[1] then
            for i = 1, #filter do
                local item = filter[i]
                if type(item) == 'string' then
                    if not Framework.HasItem(item, 1) then return false end
                elseif type(item) == 'table' then
                    local itemName = item.name or item[1]
                    local itemCount = item.count or item[2] or 1
                    if not Framework.HasItem(itemName, itemCount) then return false end
                end
            end
            return true
        end
        for name, amt in pairs(filter) do
            if type(name) == 'string' then
                local count = type(amt) == 'number' and amt or 1
                if not Framework.HasItem(name, count) then return false end
            end
        end
        return true
    end

    return false
end

function Framework.CreateConditionWrapper(opt)
    local name = opt.name or opt.label
    local hasJob = opt.job ~= nil
    local hasGang = opt.gang ~= nil
    local hasGroups = opt.groups ~= nil
    local hasItems = opt.items ~= nil or opt.item ~= nil

    if not hasJob and not hasGang and not hasGroups and not hasItems then
        return nil
    end

    local checks = {}

    if hasJob then
        if Framework.CanCheckJob() then
            checks.job = opt.job
        else
            WarnOnce(name, 'job', '-> no framework detected, move to canInteract')
        end
    end

    if hasGang then
        if Framework.CanCheckGang() then
            checks.gang = opt.gang
        else
            WarnOnce(name, 'gang', '-> gang requires QBCore, move to canInteract')
        end
    end

    if hasGroups then
        if Framework.CanCheckGroups() then
            checks.groups = opt.groups
        else
            WarnOnce(name, 'groups', '-> no framework detected, move to canInteract')
        end
    end

    if hasItems then
        local filter = opt.items or opt.item
        if Framework.CanCheckItems() then
            checks.items = filter
        else
            WarnOnce(name, 'items', '-> no framework detected for item checks, move to canInteract')
        end
    end

    if not next(checks) then
        return nil
    end

    return function()
        if checks.job and not CheckJob(checks.job) then return false end
        if checks.gang and not CheckGang(checks.gang) then return false end
        if checks.groups and not CheckGroups(checks.groups) then return false end
        if checks.items and not CheckItems(checks.items) then return false end
        return true
    end
end

function Framework.WrapCanInteract(original, wrapper)
    if not wrapper and not original then
        return nil
    end

    if not wrapper then
        return original
    end

    if not original then
        return function()
            return wrapper()
        end
    end

    return function(entity, distance, coords, name, bone)
        if not wrapper() then
            return false
        end
        local ok, result = pcall(original, entity, distance, coords, name, bone)
        if ok then
            return result == true or result == nil
        end
        if Config and Config.Debug and Config.Debug.enabled then
            print('^1[nbl-target] canInteract callback error^7')
        end
        return false
    end
end

CreateThread(function()
    Wait(0)
    Init()
end)

_G.TargetFramework = Framework
return Framework
