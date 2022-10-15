namespace Dependencies {

    use Toml.{readConfigFile, getSubConfig, getEntries}

    def toMavenCoord(kv: (String, String)): String =
        let (k, v) = kv;
        "${k}:${v}"

    pub def getMavenDependencies(): List[String] \ IO =
        readConfigFile("FlixProject.toml") |>
            getSubConfig("dependencies") |>
            getEntries |>
            Map.toList |>
            List.map(toMavenCoord)
}
