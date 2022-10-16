namespace Config {

    use Toml.{readConfigFile, getSubConfig, getEntries}

    type alias Config = {config = ##com.electronwill.nightconfig.core.Config}

    def toMavenCoord(kv: (String, String)): String =
        let (k, v) = kv;
        "${k}:${v}"

    pub def init(): Config \ IO =
        {config = readConfigFile("FlixProject.toml")}

    pub def getMavenDependencies(config: Config): List[String] =
        config.config |>
            getSubConfig("dependencies") |>
            getEntries |>
            Map.toList |>
            List.map(toMavenCoord)
}
