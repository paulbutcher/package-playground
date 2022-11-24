namespace Maven {
    import org.apache.maven.repository.internal.MavenRepositorySystemUtils;
    import org.eclipse.aether.{RepositorySystem, DefaultRepositorySystemSession, RepositorySystemSession,
                               AbstractRepositoryListener, RepositoryListener, RepositoryEvent};
    import org.eclipse.aether.artifact.{Artifact, DefaultArtifact};
    import org.eclipse.aether.collection.CollectRequest;
    import org.eclipse.aether.graph.{Dependency, DependencyFilter};
    import org.eclipse.aether.impl.{DefaultServiceLocator, DefaultServiceLocator$ErrorHandler => ErrorHandler};
    import org.eclipse.aether.repository.{LocalRepository, LocalRepositoryManager, RemoteRepository, RemoteRepository$Builder => RepoBuilder};
    import org.eclipse.aether.resolution.{VersionRangeRequest, VersionRangeResult, DependencyRequest,
                                          DependencyResult, ArtifactResult, ArtifactRequest};
    import org.eclipse.aether.version.Version;
    import java.io.File;
    import java.lang.{Class, Object, Throwable};
    import java.util.{Collections, List => JList};

    type alias Session = {system = RepositorySystem, session = RepositorySystemSession}

    pub def init(): Session \ IO =
        let system = newRepositorySystem();
        let session = newRepositorySystemSession(system);
        {system = system, session = session}

    pub def findAvailableVersions(coord: String, session: Session): List[String] \ IO =
        import new org.eclipse.aether.resolution.VersionRangeRequest(Artifact, JList, String): VersionRangeRequest as newVersionRangeRequest;
        import org.eclipse.aether.RepositorySystem.resolveVersionRange(RepositorySystemSession, VersionRangeRequest): VersionRangeResult;
        import org.eclipse.aether.resolution.VersionRangeResult.getVersions(): JList;
        import org.eclipse.aether.version.Version.toString(): String \ {};

        newVersionRangeRequest(mkArtifact(coord), Maven.newRepositoryList(), null as String) |>
            resolveVersionRange(session.system, session.session) |>
            getVersions |> 
            JavaUtils.fromJavaList |> 
            List.map(v -> toString(v))

    pub def resolveArtifact(session: Session, coord: String): Result[String, String] \ IO = try {
        import new org.eclipse.aether.resolution.ArtifactRequest(Artifact, JList, String): ArtifactRequest \ IO as newArtifactRequest;
        import org.eclipse.aether.RepositorySystem.resolveArtifact(RepositorySystemSession, ArtifactRequest): ArtifactResult;

        newArtifactRequest(mkArtifact(coord), Maven.newRepositoryList(), null as String) |>
            resolveArtifact(session.system, session.session) |>
            getArtifactPath |>
            Ok
    } catch {
        case e: ##org.eclipse.aether.RepositoryException => Err(JavaUtils.getExceptionMessage(e))
    }

    pub def resolveTransitiveDependencies(session: Session, coords: List[String]): Result[List[String], String] \ IO = try {
        import static org.eclipse.aether.util.filter.DependencyFilterUtils.classpathFilter(Array[String, false]): DependencyFilter \ IO;
        import new org.eclipse.aether.collection.CollectRequest(JList, JList, JList): CollectRequest \ IO as newCollectRequest;
        import new org.eclipse.aether.graph.Dependency(Artifact, String): Dependency \ IO as newDependency;
        import new org.eclipse.aether.resolution.DependencyRequest(CollectRequest, DependencyFilter): DependencyRequest \ IO as newDependencyRequest;
        import org.eclipse.aether.RepositorySystem.resolveDependencies(RepositorySystemSession, DependencyRequest): DependencyResult \ IO;
        import org.eclipse.aether.resolution.DependencyResult.getArtifactResults(): JList \ IO;

        let dependencies = coords |> List.map(coord -> newDependency(mkArtifact(coord), "compile"));
        let collectRequest = newCollectRequest(JavaUtils.toJavaList(dependencies), null as JList, newRepositoryList());
        let request = newDependencyRequest(collectRequest, classpathFilter(["compile"]));
        resolveDependencies(session.system, session.session, request) |>
            getArtifactResults |>
            JavaUtils.fromJavaList |>
            List.map(getArtifactPath) |>
            Ok
    } catch {
        case e: ##org.eclipse.aether.RepositoryException => Err(JavaUtils.getExceptionMessage(e))
    }

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
        import org.eclipse.aether.DefaultRepositorySystemSession.setRepositoryListener(RepositoryListener): DefaultRepositorySystemSession;
        import org.eclipse.aether.RepositoryEvent.getArtifact(): Artifact \ IO;

        let session = newSession();
        let localRepo = newLocalRepository("build/local-repo");
        discard setLocalRepositoryManager(session, newLocalRepositoryManager(system, session as RepositorySystemSession, localRepo));
        discard setRepositoryListener(session, new AbstractRepositoryListener {
            def artifactDownloaded(_this: AbstractRepositoryListener, e: RepositoryEvent): Unit =
                println("Downloaded: ${JavaUtils.objToString(getArtifact(e))}")
        } as RepositoryListener);
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

    def getArtifactPath(result: ArtifactResult): String =
        import org.eclipse.aether.resolution.ArtifactResult.getArtifact(): Artifact \ {};
        import org.eclipse.aether.artifact.Artifact.getFile(): File \ {};
        import java.io.File.getPath(): String \ {};
        getArtifact(result) |> getFile |> getPath
}
