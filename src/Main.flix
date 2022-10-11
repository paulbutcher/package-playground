use Toml.{readConfigFile, getSubConfig, getEntries}

def main(): Unit \ IO =
    println(readConfigFile("FlixProject.toml") |>
        getSubConfig("dependencies") |>
        getEntries)
