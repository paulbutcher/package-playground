namespace Source {

    use Config.Config

    def getFiles(path: String): List[String] \ IO =
        match File.walk(path) {
            case Ok(iter) => Iterator.toList(iter)
            case Err(reason) => bug!(reason)
        }

    pub def getSourceFiles(config: Config): List[String] \ IO =
        Config.getSourcePaths(config) |> List.flatMap(getFiles) |> List.filter(String.isMatch(regex = ".*\\.flix"))
}