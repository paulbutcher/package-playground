namespace Toml {
    import org.tomlj.{TomlParseResult, TomlArray, TomlTable};
    import java.nio.file.Path;

    pub def readConfigFile(filename: String): Result[TomlParseResult, String] \ IO = try {
        import static java.nio.file.Paths.get(String, Array[String, Static]): Path \ IO as getPath;
        import static org.tomlj.Toml.parse(Path): TomlParseResult \ {};
        import org.tomlj.TomlParseResult.errors(): ##java.util.List \ {};
        import java.lang.Object.toString(): String \ {};

        let result = getPath(filename, []) |> parse;
        match errors(result) |> JavaUtils.fromJavaList {
            case Nil => Ok(result)
            case errs => errs |> List.map(toString) |> List.join(", ") |> Err
        }
    } catch {
        case _: ##java.io.IOException => Err("Unable to open file ${filename}")
    }

    pub def getString(path: String, config: TomlParseResult): Result[String, String] =
        import org.tomlj.TomlParseResult.getString(String): String \ {} as getTomlString;

        getTomlString(config, path) |> 
            Object.toOption |> 
            Option.toOk("unable to read ${path} from configuration")

    pub def getStringList(path: String, config: TomlParseResult): List[String] =
        import org.tomlj.TomlParseResult.getArray(String): TomlArray \ {};
        import org.tomlj.TomlArray.toList(): ##java.util.List \ {};

        getArray(config, path) |> toList |> JavaUtils.fromJavaList

    pub def getMap(path: String, config: TomlParseResult): Map[String, String] =
        import org.tomlj.TomlParseResult.getTableOrEmpty(String): TomlTable \ {};
        import org.tomlj.TomlTable.toMap(): ##java.util.Map \ {};
        getTableOrEmpty(config, path) |> toMap |> JavaUtils.fromJavaMap
}
