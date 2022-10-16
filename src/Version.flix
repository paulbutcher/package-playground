namespace Version {

    pub enum SemVer(Int32, Int32, Int32) with Eq, ToString

    instance PartialOrder[SemVer] {
        pub def lessEqual(x: SemVer, y: SemVer): Bool = match (x, y) {
            case (SemVer(maj1, min1, p1), SemVer(maj2, min2, p2)) =>
                (maj1 == maj2) and ((min1 < min2) or (min1 == min2) and (p1 <= p2))
        }
    }

    def parse(s: String): Option[SemVer] =
        let components = JavaUtils.findMatches("^(\\d+)\\.(\\d+)\\.(\\d+)$$", s) |>
            Option.flatMap(List.map(Int32.fromString) >> Option.sequence);
        match components {
            case Some(maj :: min :: rev :: Nil) => Some(SemVer(maj, min, rev))
            case _ => None
        }
}