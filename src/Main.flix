def main(): Unit \ IO =
    let mavenSession = Maven.init();
    let config = Config.init();

    let flixVersion = Config.getFlixVersion(config);
    let _flixJar = Maven.resolveTransitiveDependencies(mavenSession,
        "com.paulbutcher:flix:${flixVersion}" :: Nil);

    let classpath = Config.getDependencies(config) |>
        Config.getMavenDependencies |>
        Maven.resolveTransitiveDependencies(mavenSession);
    println(classpath)