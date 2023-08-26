# bkv API Documentation
### Create
Inserts a new collection into the database.
```lua
local created = exports['bkv']:Create('players', 'DMY12345', {
    name = 'Example Player',
    license = '123456789',
    metadata = {
        money = {
            bank = 50000,
            cash = 25000
        }
    }
})

-- this will return true if properly created or nil if not. If it returns nil, there will be a stacktrace in your server console.
print(created)
```
### Read
Returns data related to the provided key.
```lua
local data = exports['bkv']:Read('players', 'DMY12345')

-- This will return a table if the data is found or nil if not. If it returns nil, there will be a stacktrace in your server console.
print(data)
```
### Update
Updates data for the provided key in the provided table.
```lua
local updated = exports['bkv']:Update('players', 'DMY12345', {
    name = 'Updated Player Name'
})

-- This will return true if the data is updated or nil if not. If it returns nil, there will be a stacktrace in your server console.
print(updated)
```
### Delete
Delete data in the provided table where the provided key is.
```lua
local deleted = exports['bkv']:Delete('players', 'DMY12345')

-- This will return true if the data is deleted or nil if not. If it returns nil, there will be a stacktrace in your server console.
print(deleted)
```
### FindOne
Find data in a table where you are unsure of the key. This function only returns the first located table where the attributes provided match.
```lua
local data = exports['bkv']:FindOne('players', {
    name = 'Updated Player Name'
})

-- This will return a table if the data is found or nil if not. If it returns nil, there will be a stacktrace in your server console.
print(data)
```
### FindMany
Find data in a table where you are unsure of the key. This function will return a table of every instance where the attributes provided match. If there are no matches, you will receive an empty table.
```lua
local data = exports['bkv']:FindMany('players', {
    name = 'Updated Player Name'
})

-- This will return a table if the data is found or nil if not. If it returns nil, there will be a stacktrace in your server console.
print(data)
```