--!strict

local Signal = require(script.Parent.Parent.Core.Signal)

local Value = {}
Value.__index = Value

function Value.new(initial: any)
    return setmetatable({
        _value = initial,
        _changed = Signal.new(),
        _destroyed = false,
    }, Value)
end

function Value:Get(): any
    return self._value
end

function Value:Set(nextValue: any)
    assert(not self._destroyed, "Cannot set a destroyed Nebula value")
    if self._value == nextValue then
        return
    end
    self._value = nextValue
    self._changed:Fire(nextValue)
end

function Value:Subscribe(callback: (any) -> ()): RBXScriptConnection
    assert(not self._destroyed, "Cannot subscribe to a destroyed Nebula value")
    return self._changed:Connect(callback)
end

function Value:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    self._changed:Destroy()
end

return Value
