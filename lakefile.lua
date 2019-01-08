task({
    name = "build",
    dependencies = {
        "bin", "src/lake.lua"
    },
    action = shell("luac", "-o", "bin/lake", "src/lake.lua")
})

task({
    name = "bin",
    action = shell("mkdir", "bin")
})

task({
    name = "clean",
    action = shell("rm", "-rf", "bin")
})