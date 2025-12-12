local function loadModule(path)
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/" .. path))()
end

-- Load configuration
loadModule("src/config/settings.luau")
loadModule("src/config/rocks.luau")

-- Load UI
loadModule("src/ui/menu.luau")
