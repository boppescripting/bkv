local localCache = {}
local updateCache = {}
local Colors = {
    W  = '^7',  -- white (normal)
    R  = '^8', -- red
    G  = '^2', -- green
    O  = '^1', -- orange
    B  = '^4', -- blue
    P  = '^6', -- purple
}

-- Convars
local CON_UpdateInterval = GetConvarInt('bkv:UpdateInterval', 5)
local CON_Debug = GetConvarInt('bkv:Debug', 0) == 1

-- Functions
local function DebugLog(msg, ...)
    if CON_Debug then
        print(msg, ...)
    end
end

function SplitStr(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        result[#result + 1] = string.sub(str, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    result[#result + 1] = string.sub(str, from)
    return result
end

local function RaiseError(func, attributes)
    local str = Colors.R .. '[' .. Colors.O .. 'bkv' .. Colors.R .. '] An unexpected error has occurred during the execution of the following request: [function] ' .. func .. ' '
    for k,v in pairs(attributes) do str = str .. '[' .. k .. '] ' .. v .. ' / ' end
    str = str:sub(1, -4)
    str = str .. Colors.W
    print(str)
end

local function PreloadKVPs()
    local kvpHandle = StartFindKvp('bkv:')
    local key = nil

    repeat
        key = FindKvp(kvpHandle)
        if key then
            local jsonData = GetResourceKvpString(key)
            local readableData = json.decode(jsonData)
            local newKey = SplitStr(key, 'bkv:')[2]
            localCache[newKey] = readableData
        end
    until not key

    EndFindKvp(kvpHandle)
    DebugLog(Colors.G .. '[' .. Colors.O .. 'bkv' .. Colors.G ..'] KVPs preloaded.')
end

local function UnloadKVPs()
    for k,v in pairs(localCache) do
        SetResourceKvp('bkv:' .. k, json.encode(v))
    end
    DebugLog(Colors.G .. '[' .. Colors.O .. 'bkv' .. Colors.G ..'] KVPs unloaded.')
end

local function UpdateKVPs()
    for k,v in pairs(updateCache) do
        local tmp_tableName = 'bkv:' .. k
        if localCache[k] ~= nil then
            local tmp_tableData = {}
            for l, h in pairs(localCache[k]) do
                if h ~= nil then
                    tmp_tableData[l] = h
                end
            end
            SetResourceKvp(tmp_tableName, json.encode(tmp_tableData))
        else
            SetResourceKvp(tmp_tableName, json.encode({}))
        end
    end
    updateCache = {}
    DebugLog(Colors.G .. '[' .. Colors.O .. 'bkv' .. Colors.G ..'] KVPs updated.')
end

local function UpdateCache(dbTable)
    updateCache[dbTable] = true
    DebugLog(Colors.G .. '[' .. Colors.O .. 'bkv' .. Colors.G ..'] updateCache updated.')
end

-- Export Functions
local function Create(dbTable, key, attributes)
    if not localCache[dbTable] then localCache[dbTable] = {} end
    localCache[dbTable][key] = attributes
    UpdateCache(dbTable)
    return true
end

local function Read(dbTable, key)
    if not localCache[dbTable] or not localCache[dbTable][key] then
        RaiseError('Read', {
            dbTable = dbTable,
            findBy = key
        })
        return nil
    end
    return localCache[dbTable][key]
end

local function ReadTable(dbTable)
    if not localCache[dbTable] then
        RaiseError('Read', {
            dbTable = dbTable
        })
        return nil
    end
    return localCache[dbTable]
end

local function Update(dbTable, key, attributes)
    if not localCache[dbTable] or not localCache[dbTable][key] then
        attributes[dbTable] = dbTable
        attributes[findBy] = key
        attributes[message] = 'That index does not exist.'
        RaiseError('Update', attributes)
        return nil
    end

    local tmp_data = localCache[dbTable][key]
    for k,v in pairs(attributes) do tmp_data[k] = v end
    UpdateCache(dbTable)
    return true
end

local function Delete(dbTable, key)
    if not localCache[dbTable] or not localCache[dbTable][key] then
        RaiseError('Delete', {
            dbTable = dbTable,
            findBy = key,
            message = 'That index does not exist.'
        })
        return nil
    end
    localCache[dbTable][key] = nil
    UpdateCache(dbTable)
    return true
end

local function FindOne(dbTable, attributes)
    if not localCache[dbTable] then
        attributes[dbTable] = dbTable
        attributes[message] = 'That database table does not exist.'
        RaiseError('FindOne', attributes)
        return nil
    end

    for k,v in pairs(localCache[dbTable]) do
        local foundData = true
        for l, h in pairs(attributes) do
            if localCache[dbTable][k][l] ~= h then
                foundData = false
            end
        end

        if foundData then
            localCache[dbTable][k]['key'] = k
            return localCache[dbTable][k]['key']
        end
    end

    return nil
end

local function FindMany(dbTable, attributes)
    if not localCache[dbTable] then
        attributes[dbTable] = dbTable
        attributes[message] = 'That database table does not exist.'
        RaiseError('FindMany', attributes)
        return nil
    end

    local relevantDataTable = {}
    for k,v in pairs(localCache[dbTable]) do
        local foundData = true
        for l, h in pairs(attributes) do
            if localCache[dbTable][k][l] ~= h then
                foundData = false
            end
        end

        if foundData then
            relevantDataTable[k] = localCache[dbTable][k]
        end
    end

    return relevantDataTable
end

local function SaveAll()
    UpdateKVPs()
end

local function Save(dbTable)
    local tmp_tableName = 'bkv:' .. dbTable
    if localCache[dbTable] ~= nil then
        local tmp_tableData = {}
        for l, h in pairs(localCache[dbTable]) do
            if h ~= nil then
                tmp_tableData[l] = h
            end
        end
        SetResourceKvp(tmp_tableName, json.encode(tmp_tableData))
    else
        SetResourceKvp(tmp_tableName, json.encode({}))
    end
    updateCache = {}
    DebugLog(Colors.G .. '[' .. Colors.O .. 'bkv' .. Colors.G ..'] KVP `' .. dbTable .. '` updated.')
end

local function Empty(dbTable)
    if not localCache[dbTable] then
        RaiseError('Empty', {
            dbTable = dbTable,
            message = 'That database table does not exist.'
        })
        return nil
    end
    localCache[dbTable] = nil
end

exports('Create', Create)
exports('Read', Read)
exports('ReadTable', ReadTable)
exports('Update', Update)
exports('Delete', Delete)
exports('FindOne', FindOne)
exports('FindMany', FindMany)
exports('SaveAll', SaveAll)
exports('Save', Save)
exports('Empty', Empty)

-- Event Handlers
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    PreloadKVPs()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    UnloadKVPs()
end)

-- Threads
CreateThread(function()
    while true do
        Wait(UpdateInterval * 60000)
        UpdateKVPs()
    end
end)