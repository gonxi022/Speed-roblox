-- Spy con filtro de RemoteEvents y RemoteFunctions en consola (KRNL Android compatible)

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "FireServer" or method == "InvokeServer" then
        local fullname = "Unknown"
        pcall(function()
            fullname = self:GetFullName()
        end)

        -- Filtrar solo nombres que contengan estas palabras clave (ajustar si querés)
        local keywords = {"fish", "steal", "grab", "collect", "lock", "target", "spawn", "pick", "claim", "catch", "update", "request"}

        local matched = false
        for _, word in ipairs(keywords) do
            if fullname:lower():find(word) then
                matched = true
                break
            end
        end

        if matched then
            print("🕵️‍♂️ RemoteEvent/Function detectado:")
            print("  Nombre: ", fullname)
            print("  Método:", method)
            if #args > 0 then
                print("  Args: ", unpack(args))
            else
                print("  Args: ninguno")
            end
            print("----------------------------")
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)