namespace Maven {
    import org.apache.maven.repository.internal.MavenRepositorySystemUtils;
    import org.eclipse.aether.{RepositorySystem, DefaultRepositorySystemSession, RepositorySystemSession};
    import org.eclipse.aether.artifact.{Artifact, DefaultArtifact};
    import org.eclipse.aether.collection.CollectRequest;
    import org.eclipse.aether.graph.{Dependency, DependencyFilter};
    import org.eclipse.aether.impl.{DefaultServiceLocator, DefaultServiceLocator$ErrorHandler => ErrorHandler};
    import org.eclipse.aether.repository.{LocalRepository, LocalRepositoryManager, RemoteRepository, RemoteRepository$Builder => RepoBuilder};
    import org.eclipse.aether.resolution.{VersionRangeRequest, VersionRangeResult, DependencyRequest, DependencyResult};
    import org.eclipse.aether.version.Version;
    import java.lang.{Class, Object, Throwable};
    import java.util.{Collections, List => JList};

    type alias Session = {system = RepositorySystem, session = RepositorySystemSession}

    pub def init(): Session \ IO =
        let system = newRepositorySystem();
        let session = newRepositorySystemSession(system);
        {system = system, session = session}

    pub def findAvailableVersions(coord: String, session: Session): List[String] \ IO =
        import new org.eclipse.aether.resolution.VersionRangeRequest(): VersionRangeRequest as newVersionRangeRequest;
        import org.eclipse.aether.resolution.VersionRangeRequest.setArtifact(Artifact): VersionRangeRequest;
        import org.eclipse.aether.resolution.VersionRangeRequest.setRepositories(JList): VersionRangeRequest;
        import org.eclipse.aether.RepositorySystem.resolveVersionRange(RepositorySystemSession, VersionRangeRequest): VersionRangeResult;
        import org.eclipse.aether.resolution.VersionRangeResult.getVersions(): JList;
        import org.eclipse.aether.version.Version.toString(): String \ {};

        let artifact = mkArtifact(coord);
        let request = newVersionRangeRequest();
        discard setArtifact(request, artifact);
        discard setRepositories(request, newRepositoryList());
        resolveVersionRange(session.system, session.session, request) |>
            getVersions |> 
            JavaUtils.fromJavaList |> 
            List.map(v -> toString(v))

    pub def resolveTransitiveDependencies(coord: String, session: Session): Unit \ IO =
        import static org.eclipse.aether.util.filter.DependencyFilterUtils.classpathFilter(Array[String, false]): DependencyFilter \ IO;
        import new org.eclipse.aether.collection.CollectRequest(): CollectRequest \ IO as newCollectRequest;
        import org.eclipse.aether.collection.CollectRequest.setRoot(Dependency): CollectRequest \ IO;
        import new org.eclipse.aether.graph.Dependency(Artifact, String): Dependency \ IO as newDependency;
        import org.eclipse.aether.collection.CollectRequest.setRepositories(JList): CollectRequest \ IO;
        import new org.eclipse.aether.resolution.DependencyRequest(CollectRequest, DependencyFilter): DependencyRequest \ IO as newDependencyRequest;
        import org.eclipse.aether.RepositorySystem.resolveDependencies(RepositorySystemSession, DependencyRequest): DependencyResult \ IO;
        import org.eclipse.aether.resolution.DependencyResult.getArtifactResults(): JList \ IO;

        let artifact = mkArtifact(coord);
        let filter = classpathFilter(["compile"]);
        let collectRequest = newCollectRequest();
        discard setRoot(collectRequest, newDependency(artifact, "compile"));
        discard setRepositories(collectRequest, newRepositoryList());
        let request = newDependencyRequest(collectRequest, filter);
        let results = resolveDependencies(session.system, session.session, request) |>
            getArtifactResults;
        JavaUtils.printObject(results)

    def newRepositorySystem(): RepositorySystem \ IO =
        import static org.apache.maven.repository.internal.MavenRepositorySystemUtils.newServiceLocator(): DefaultServiceLocator;
        import org.eclipse.aether.impl.DefaultServiceLocator.getService(Class): Object;
        import org.eclipse.aether.impl.DefaultServiceLocator.addService(Class, Class): DefaultServiceLocator;
        import org.eclipse.aether.impl.DefaultServiceLocator.setErrorHandler(ErrorHandler): Unit;
        import static java.lang.Class.forName(String): Class as getClass;

        let locator = newServiceLocator();
        discard addService(locator,
            getClass("org.eclipse.aether.spi.connector.RepositoryConnectorFactory"),
            getClass("org.eclipse.aether.connector.basic.BasicRepositoryConnectorFactory"));
        discard addService(locator,
            getClass("org.eclipse.aether.spi.connector.transport.TransporterFactory"),
            getClass("org.eclipse.aether.transport.file.FileTransporterFactory"));
        discard addService(locator,
            getClass("org.eclipse.aether.spi.connector.transport.TransporterFactory"),
            getClass("org.eclipse.aether.transport.http.HttpTransporterFactory"));
        setErrorHandler(locator, new ErrorHandler {
            def serviceCreationFailed(_this: ErrorHandler, _tpe: Class, _impl: Class, ex: Throwable) : Unit =
                bug!(JavaUtils.objToString(ex))
        });
        getService(locator, getClass("org.eclipse.aether.RepositorySystem")) as RepositorySystem

    def newRepositorySystemSession(system: RepositorySystem): RepositorySystemSession \ IO =
        import static org.apache.maven.repository.internal.MavenRepositorySystemUtils.newSession(): DefaultRepositorySystemSession;
        import new org.eclipse.aether.repository.LocalRepository(String): LocalRepository as newLocalRepository;
        import org.eclipse.aether.RepositorySystem.newLocalRepositoryManager(RepositorySystemSession, LocalRepository): LocalRepositoryManager;
        import org.eclipse.aether.DefaultRepositorySystemSession.setLocalRepositoryManager(LocalRepositoryManager): DefaultRepositorySystemSession;

        let session = newSession();
        let localRepo = newLocalRepository("build/local-repo");
        discard setLocalRepositoryManager(session, newLocalRepositoryManager(system, session as RepositorySystemSession, localRepo));
        session as RepositorySystemSession

    def newRepositoryList(): JList \ IO =
        import new org.eclipse.aether.repository.RemoteRepository$Builder(String, String, String): RepoBuilder as newRepoBuilder;
        import org.eclipse.aether.repository.RemoteRepository$Builder.build(): RemoteRepository;
        import static java.util.Collections.singletonList(Object): JList;

        let builder = newRepoBuilder("central", "default", "https://repo.maven.apache.org/maven2/");
        let defaultRepo = build(builder);
        singletonList(defaultRepo as Object)

    def mkArtifact(coord: String): Artifact \ IO =
        import new org.eclipse.aether.artifact.DefaultArtifact(String): DefaultArtifact as newArtifact;
        newArtifact(coord) as Artifact
}
