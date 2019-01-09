local tasks = {}
local lake = {}

function task(config)
    local finalConfig = {}

    if config.name == nil then
        error("A task exists without a name.")
    elseif tasks[config.name] ~= nil then
        error("Task " .. config.name .. " has a duplicate name.")
    else
        finalConfig.name = config.name
    end

    if config.action == nil and config.actions == nil then
        error("Task " .. config.name .. " has no actions.")
    else
        local finalActions = {}

        if config.action ~= nil then
            table.insert(finalActions, config.action)
        end

        if config.actions ~= nil then
            for i, a in pairs(config.actions) do
                table.insert(finalActions, a)
            end
        end

        finalConfig.actions = finalActions
    end

    if config.dependency ~= nil or config.dependencies ~= nil then
        local finalDeps = {}

        if config.dependency ~= nil then
            table.insert(finalDeps, config.dependency)
        end

        if config.dependencies ~= nil then
            for i, d in pairs(config.dependencies) do
                table.insert(finalDeps, d)
            end
        end

        finalConfig.dependencies = finalDeps
        finalConfig.resolved = false
    else
        finalConfig.resolved = true
    end

    tasks[finalConfig.name] = finalConfig
end

function shell(cmd, ...)
    local command = cmd .. lake.concatArgs(table.pack(...))
    return function()
        io.write(command)
        io.write("\n")
        return os.execute(command)
    end
end

function path(...)
    local path = table.pack(...)
    local fullPath = path[1]
    
    for i = 2, path.n do
        if path[i] ~= nil then
            fullPath = fullPath .. "/" .. path[i]
        end
    end
    
    return fullPath
end

function lake.concatArgs(args)
    local fullString = ""
    for i = 1, args.n do
        if args[i] ~= nil then
            fullString = fullString .. " " .. args[i]
        end
    end
    return fullString
end

function lake.fileExists(filename)
    local file = io.open(filename, "r")
    local exists = false

    if file ~= nil then
        exists = true
        io.close()
    end

    return exists
end

function lake.executeTask(taskName)
    if not lake.fileExists(taskName) then
        if tasks[taskName].dependencies ~= nil then
            for i, v in pairs(tasks[taskName].dependencies) do
                lake.executeTask(v)
            end
        end

        for i, v in pairs(tasks[taskName].actions) do
            v()
        end
    end
end

function lake.resolveDependencyTree(taskName)
    local leaf = tasks[taskName]
    leaf.resolved = nil

    if leaf.dependencies ~= nil then
        for i, v in pairs(leaf.dependencies) do
            if tasks[v] ~= nil then
                if tasks[v].resolved ~= nil and not tasks[v].resolved then
                    lake.resolveDependencyTree(v)
                elseif tasks[v].resolved == nil then
                    error("Circular dependency detected on tasks " .. v .. " and " .. taskName .. ".")
                end
            elseif not lake.fileExists(v) then
                error("Missing file / task: " .. v .. ".")
            end
        end
    end

    leaf.resolved = true
end

if lake.fileExists("lakefile.lua") then
    dofile("lakefile.lua")
elseif lake.fileExists("lakefile") then
    dofile("lakefile")
else
    error("No lakefile found.")
end

if #arg == 0 then
    lake.resolveDependencyTree("build")
    lake.executeTask("build")
end

for i, v in ipairs(arg) do
    if tasks[v] == nil then
        error("No task found with name " .. v .. ".")
    elseif not tasks[v].resolved then
        lake.resolveDependencyTree(v)
    end
    lake.executeTask(v)
end