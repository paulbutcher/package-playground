namespace Compiler {
    import java.net.{URL, URLClassLoader};
    import java.lang.{Class, Object, ClassLoader};
    import java.lang.reflect.Method;

    pub def run(flixJar: String, sourceFiles: List[String], classpath: List[String]): Unit \ IO =
        import new java.net.URL(String): URL \ IO as newURL;
        import new java.net.URLClassLoader(Array[URL, Static], ClassLoader): URLClassLoader \ IO as newClassLoader;
        import java.net.URLClassLoader.loadClass(String): Class \ IO;
        import java.lang.Class.getMethod(String, Array[Class, Static]): Method \ {};
        import static java.lang.Class.forName(String): Class \ {} as getClass;
        import java.lang.reflect.Method.invoke(Object, Array[Object, Static]): Object \ IO;
 
        let loader = newClassLoader([newURL("file://${flixJar}")], null as ClassLoader);
        let clazz = loadClass(loader, "ca.uwaterloo.flix.Main");
        let main = getMethod(clazz, "mainX", [getClass("[Ljava.lang.Object;")]);
        let args = flixJar :: sourceFiles ++ classpath;
        discard invoke(main, null as Object, [List.toArray(Static, args) as Object])
}