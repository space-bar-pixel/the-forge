--# selene: allow(undefined_global)
print("PIZZAHUB LOADING...")

local function loadModule(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/" .. path))()
    end)
    if success then
        return result
    else
        warn("Failed to load " .. path .. ": " .. result)
        return nil
    end
end

-- Load configuration
loadModule("src/config/settings.luau")
loadModule("src/config/rocks.luau")

-- Load UI
loadModule("src/ui/menu.luau")

print("PIZZAHUB LOADED...")
