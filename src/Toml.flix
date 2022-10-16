namespace Toml {
    import com.electronwill.nightconfig.core.file.FileConfig;
    import com.electronwill.nightconfig.core.Config;
    import com.electronwill.nightconfig.core.{Config$Entry => Entry}
    import java.lang.Object;

    use JavaUtils.fromJavaIter;

    pub def readConfigFile(filename: String): Config \ IO =
        import static com.electronwill.nightconfig.core.file.FileConfig.of(String): FileConfig \ IO as configOf;
        import com.electronwill.nightconfig.core.file.FileConfig.load(): Unit \ IO;
        let config = configOf(filename);
        load(config);
        config as Config

    pub def getSubConfig(path: String, config: Config): Config =
        import com.electronwill.nightconfig.core.Config.get(String): Object \ {};
        get(config, path) as Config

    def entryToPair(entry: Entry): (String, String) =
        import com.electronwill.nightconfig.core.Config$Entry.getKey(): String \ {};
        import com.electronwill.nightconfig.core.Config$Entry.getValue(): Object \ {};
        (getKey(entry), getValue(entry) as String)

    pub def getEntries(config: Config): Map[String, String] = region r {
        import com.electronwill.nightconfig.core.Config.entrySet(): ##java.util.Set \ {};
        import java.util.Set.iterator(): ##java.util.Iterator \ {Read(r), Write(r)};
        iterator(entrySet(config)) |>
            fromJavaIter(r) |>
            Iterator.mapL(entryToPair) |>
            Iterator.toMap
    }
}