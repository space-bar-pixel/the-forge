--# selene: allow(undefined_global)
print("PIZZAHUB LOADING...")

local function loadModule(path)
    local url = "https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/" .. path
    print("Loading: " .. url)
    local success, result = pcall(function()
        local code = game:HttpGet(url)
        print("Fetched code for " .. path .. ", length: " .. #code)
        return loadstring(code)()
    end)
    if success then
        print("Successfully loaded: " .. path)
        return result
    else
        warn("Failed to load " .. path .. ": " .. tostring(result))
        return nil
    end
end

-- Load configuration
loadModule("src/config/settings.luau")
loadModule("src/config/rocks.luau")

-- Load UI
loadModule("src/ui/menu.luau")

print("PIZZAHUB LOADED...")
