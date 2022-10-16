namespace FlixDependency {

    use Version.SemVer
    use Version.SemVer.SemVer

    def _mockRepository(): Map[String, Map[SemVer, Map[String, SemVer]]] = Map#{
        "Loggify" => Map#{SemVer(1, 0, 0) => Map#{},
                          SemVer(1, 1, 0) => Map#{},
                          SemVer(1, 1, 1) => Map#{},
                          SemVer(2, 0, 0) => Map#{}}, 
        "Frobnicate" => Map#{SemVer(0, 1, 0) => Map#{"Loggify" => SemVer(1, 0, 0)},
                             SemVer(0, 2, 0) => Map#{"Loggify" => SemVer(1, 0, 0)},
                             SemVer(1, 0, 0) => Map#{"Loggify" => SemVer(1, 0, 0)},
                             SemVer(1, 2, 0) => Map#{"Loggify" => SemVer(1, 0, 0)},
                             SemVer(1, 2, 1) => Map#{"Loggify" => SemVer(1, 0, 0)},
                             SemVer(2, 0, 0) => Map#{"Loggify" => SemVer(1, 0, 0)}},
        "Munge" => Map#{SemVer(0, 1, 0) => Map#{"Loggify" => SemVer(1, 0, 0)},
                        SemVer(0, 2, 0) => Map#{"Loggify" => SemVer(1, 1, 0)},
                        SemVer(1, 0, 0) => Map#{"Loggify" => SemVer(1, 1, 1)},
                        SemVer(1, 1, 0) => Map#{"Loggify" => SemVer(1, 1, 1)},
                        SemVer(1, 2, 0) => Map#{"Loggify" => SemVer(1, 1, 1)},
                        SemVer(1, 2, 1) => Map#{"Loggify" => SemVer(2, 0, 0)},
                        SemVer(2, 0, 0) => Map#{"Loggify" => SemVer(2, 0, 0)}}
    }

    def _dependencies(): Map[String, SemVer] = Map#{
        "Frobnicate" => SemVer(1, 2, 0),
        "Munge" => SemVer(1, 2, 0)
    }

    pub def resolve(): Unit \ IO = 
        let rules = #{
            Root("Frobnicate", SemVer(1, 2, 0)).
            Root("Munge", SemVer(1, 2, 0)).
            DependsOn("Frobnicate", SemVer(0, 1, 0), "Loggify", SemVer(1, 0, 0)).
            DependsOn("Frobnicate", SemVer(0, 2, 0), "Loggify", SemVer(1, 0, 0)).
            DependsOn("Frobnicate", SemVer(1, 2, 0), "Loggify", SemVer(1, 0, 0)).
            DependsOn("Frobnicate", SemVer(1, 2, 1), "Loggify", SemVer(1, 0, 0)).
            DependsOn("Frobnicate", SemVer(2, 0, 0), "Loggify", SemVer(1, 0, 0)).
            DependsOn("Munge", SemVer(0, 1, 0), "Loggify", SemVer(1, 0, 0)).
            DependsOn("Munge", SemVer(0, 2, 0), "Loggify", SemVer(1, 1, 0)).
            DependsOn("Munge", SemVer(1, 0, 0), "Loggify", SemVer(1, 1, 1)).
            DependsOn("Munge", SemVer(1, 1, 0), "Loggify", SemVer(1, 1, 1)).
            DependsOn("Munge", SemVer(1, 2, 0), "Loggify", SemVer(1, 1, 1)).
            DependsOn("Munge", SemVer(1, 2, 1), "Loggify", SemVer(2, 0, 0)).
            DependsOn("Munge", SemVer(2, 0, 0), "Loggify", SemVer(2, 0, 0)).

            Dependency(n, v) :- Root(n, v).
            Dependency(ns, vs) :- DependsOn(n, v, ns, vs), Dependency(n, v).
        };
        let candidates = solve rules project Dependency;
        let rules2 = #{
            Latest(n; v) :- fix Dependency(n, v).
        };
        query candidates, rules2 select (x, y) from Latest(x; y) |> println;
        ()
}