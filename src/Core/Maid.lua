--!strict

local Maid = {}
Maid.__index = Maid

export type Task = RBXScriptConnection | Instance | thread | (() -> ())

function Maid.new()
    return setmetatable({
        _tasks = {},
        _destroyed = false,
    }, Maid)
end

function Maid:Give(task: Task): Task
    assert(not self._destroyed, "Nebula Maid is already destroyed")
    table.insert(self._tasks, task)
    return task
end

function Maid:GiveConnection(connection: RBXScriptConnection): RBXScriptConnection
    return self:Give(connection)
end

local function cleanup(item: Task)
    local kind = typeof(item)
    if kind == "RBXScriptConnection" then
        (item :: RBXScriptConnection):Disconnect()
    elseif kind == "Instance" then
        (item :: Instance):Destroy()
    elseif kind == "thread" then
        task.cancel(item :: thread)
    elseif type(item) == "function" then
        (item :: () -> ())()
    elseif type(item) == "table" then
        local object = item :: any
        if type(object.Disconnect) == "function" then
            object:Disconnect()
        elseif type(object.Destroy) == "function" then
            object:Destroy()
        end
    end
end

function Maid:Cleanup()
    for index = #self._tasks, 1, -1 do
        local task = self._tasks[index]
        self._tasks[index] = nil
        cleanup(task)
    end
end

function Maid:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    self:Cleanup()
end

return Maid
