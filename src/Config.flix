namespace Config {

    use Toml.{readConfigFile, getSubConfig, getEntries, configToMap, getString}

    type alias Config = {config = ##com.electronwill.nightconfig.core.Config}

    def toMavenCoord(kv: (String, String)): String =
        let (k, v) = kv;
        "${k}:${v}"

    pub def init(): Config \ IO =
        {config = readConfigFile("FlixProject.toml")}

    pub def getDependencies(config: Config): Map[String, Map[String, String]] =
        config.config |>
            getSubConfig("dependencies") |>
            getEntries |>
            Map.map(configToMap)

    pub def getMavenDependencies(deps: Map[String, Map[String, String]]): List[String] =
        deps |> 
            Map.filterMap(v -> Map.get("mvn", v)) |> 
            Map.toList |>
            List.map(toMavenCoord)

    pub def getFlixVersion(config: Config): String =
        config.config |> getString("project.flix")
}
