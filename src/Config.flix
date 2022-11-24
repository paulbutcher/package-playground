namespace Config {

    pub type alias Config = ##org.tomlj.TomlParseResult

    def toMavenCoord(kv: (String, String)): String =
        let (k, v) = kv;
        "${k}:${v}"

    pub def init(): Result[Config, String] \ IO =
        Toml.readConfigFile("flix.toml")

    pub def getMavenDependencies(config: Config): List[String] =
        config |> 
            Toml.getMap("dependencies.mvn") |> 
            Map.toList |> 
            List.map(toMavenCoord)

    pub def getFlixVersion(config: Config): Result[String, String] =
        config |> Toml.getString("project.flix")

    pub def getSourcePaths(config: Config): List[String] = 
        config |> Toml.getStringList("project.paths")
}
