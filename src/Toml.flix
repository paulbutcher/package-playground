namespace Toml {
    import org.tomlj.{TomlParseResult, TomlArray, TomlTable};
    import java.nio.file.Path;

    pub def readConfigFile(filename: String): TomlParseResult \ IO =
        import static java.nio.file.Paths.get(String, Array[String, Static]): Path \ IO as getPath;
        import static org.tomlj.Toml.parse(Path): TomlParseResult \ IO;

        getPath(filename, []) |> parse

    pub def getString(path: String, config: TomlParseResult): String =
        import org.tomlj.TomlParseResult.getString(String): String \ {} as getTomlString;
        getTomlString(config, path)

    pub def getStringList(path: String, config: TomlParseResult): List[String] =
        import org.tomlj.TomlParseResult.getArray(String): TomlArray \ {};
        import org.tomlj.TomlArray.toList(): ##java.util.List \ {};
        getArray(config, path) |> toList |> JavaUtils.fromJavaList

    pub def getMap(path: String, config: TomlParseResult): Map[String, String] =
        import org.tomlj.TomlParseResult.getTableOrEmpty(String): TomlTable \ {};
        import org.tomlj.TomlTable.toMap(): ##java.util.Map \ {};
        getTableOrEmpty(config, path) |> toMap |> JavaUtils.fromJavaMap
}
