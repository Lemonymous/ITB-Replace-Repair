
return function(name)
    local f = io.open(name, "r")
    if f then io.close(f) return true else return false end
end