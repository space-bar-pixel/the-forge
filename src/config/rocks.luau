local RocksTable = {}

local function Init()
    for name in pairs(require(game:GetService("ReplicatedStorage").Shared.Data.Rock)) do
        table.insert(RocksTable, name)
    end
end

Init()
return RocksTable
