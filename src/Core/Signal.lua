--!strict

local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({
        _listeners = {},
        _destroyed = false,
    }, Signal)
end

function Signal:Connect(callback: (...any) -> ()): RBXScriptConnection
    assert(not self._destroyed, "Cannot connect to a destroyed Nebula Signal")
    local listeners = self._listeners
    local active = true
    local connection = {
        Disconnect = function()
            active = false
            listeners[callback] = nil
        end,
    }
    listeners[callback] = function(...)
        if active then
            callback(...)
        end
    end
    return connection :: any
end

function Signal:Fire(...)
    if self._destroyed then
        return
    end
    for _, callback in pairs(self._listeners) do
        task.spawn(callback, ...)
    end
end

function Signal:Destroy()
    self._destroyed = true
    table.clear(self._listeners)
end

return Signal
