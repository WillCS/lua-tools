# lua-tools
I'm making some development tools in Lua. Currently all there is is Lake, but there's also going to be a unit testing framework, and possible some other stuff idk.

## Lake
Lake is Make but everything is Lua. It's pretty barebones right now but it does work. A task can be defined by calling `task` in your `lakefile.lua` as so:

```lua
task({
    name = "The name of your task. This is required",
    dependencies = {
        "list", "files", "and", "other", "tasks", "this",
        "task", "depends", "on", "here."
    },
    dependency = "If a task only has one dependency, it can be defined with this shorthand.",
    actions = {
        function()
            os.execute("echo A list of functions to be called, in order, to build this task.")
        end,
        function()
            os.execute("echo At least one action is required.")
        end,
        shell("echo", "you can also directly execute on the shell using the provided function.")
    },
    action = shell("echo", "This shorthand works similarly to dependency above.")
})
```

When Lake is executed, it will look first for `lakefile.lua` and if this file is not found, it will look for `lakefile`. If neither are found, Lake will fail. If no parameters are passed, Lake will attempt to run the "build" task. If this task is not found, Lake will fail. If any parameters are passed, Lake will attempt to run them as tasks, in the order they are provided.
