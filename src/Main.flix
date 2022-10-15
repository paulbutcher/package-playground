def main(): Unit \ IO =
    let mavenSession = Maven.init();

    let classpath = Dependencies.getMavenDependencies() |>
        Maven.resolveTransitiveDependencies(mavenSession);
    println(classpath)