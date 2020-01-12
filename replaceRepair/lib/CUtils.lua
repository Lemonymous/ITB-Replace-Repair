
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath .."replaceRepair/lib/utils.dll"

local old = test
assert(package.loadlib(path, "luaopen_utils"), "cannot find C-Utils dll")()
local ret = test
test = old

return ret
