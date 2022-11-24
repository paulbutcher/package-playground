def runCompiler(): Result[Unit, String] \ IO =
    use Result.flatMap;

    let mavenSession = Maven.init();
    let* config = Config.init();

    let* classpath = Config.getMavenDependencies(config) |>
        Maven.resolveTransitiveDependencies(mavenSession);

    let sourceFiles = Source.getSourceFiles(config);

    let* flixVersion = Config.getFlixVersion(config);
    let* flixJar = Maven.resolveArtifact(mavenSession, "com.paulbutcher:flix:${flixVersion}");

    Ok(Compiler.run(flixJar, sourceFiles, classpath))

def main(): Unit \ IO =
    match runCompiler() {
        case Err(msg) => println("Error: ${msg}")
        case _ => ()
    }
