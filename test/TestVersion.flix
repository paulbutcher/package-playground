namespace Version {

    @test
    def testParse01(): Bool =
        Assert.eq(parse("1.2.3"), Some(SemVer(1, 2, 3)))

    @test
    def testParse02(): Bool = 
        Assert.eq(parse(".2.3"), None)

    @test
    def testParse03(): Bool = 
        Assert.eq(parse("x.2.3"), None)

    @test
    def testParse04(): Bool = 
        Assert.eq(parse("xx1.2.3"), None)

    @test
    def testParse05(): Bool = 
        Assert.eq(parse("1.2.3xx"), None)

    @test
    def testPartialOrder01(): Bool =
        PartialOrder.lessEqual(SemVer(1, 2, 3), SemVer(1, 2, 3))

    @test
    def testPartialOrder02(): Bool =
        PartialOrder.lessEqual(SemVer(1, 2, 3), SemVer(1, 3, 0))

    @test
    def testPartialOrder03(): Bool =
        PartialOrder.lessEqual(SemVer(1, 2, 3), SemVer(1, 2, 4))

    @test
    def testPartialOrder04(): Bool =
        not PartialOrder.lessEqual(SemVer(1, 2, 3), SemVer(1, 1, 3))

    @test
    def testPartialOrder05(): Bool =
        not PartialOrder.lessEqual(SemVer(1, 2, 3), SemVer(1, 2, 2))

    @test
    def testPartialOrder06(): Bool =
        not PartialOrder.lessEqual(SemVer(0, 2, 3), SemVer(1, 2, 3))

    @test
    def testPartialOrder07(): Bool =
        not PartialOrder.lessEqual(SemVer(1, 2, 3), SemVer(0, 2, 3))

    @test
    def testJoinLattice01(): Bool =
        Assert.eq(JoinLattice.leastUpperBound(SemVer(1, 1, 0), SemVer(1, 1, 0)), SemVer(1, 1, 0))

    @test
    def testJoinLattice02(): Bool =
        Assert.eq(JoinLattice.leastUpperBound(SemVer(1, 1, 0), SemVer(1, 1, 1)), SemVer(1, 1, 1))

    @test
    def testJoinLattice03(): Bool =
        Assert.eq(JoinLattice.leastUpperBound(SemVer(2, 1, 0), SemVer(1, 1, 0)), Top)

    @test 
    def testMeetLattice01(): Bool =
        Assert.eq(MeetLattice.greatestLowerBound(SemVer(1, 1, 0), SemVer(1, 1, 0)), SemVer(1, 1, 0))

    @test 
    def testMeetLattice02(): Bool =
        Assert.eq(MeetLattice.greatestLowerBound(SemVer(1, 1, 0), SemVer(1, 1, 1)), SemVer(1, 1, 0))

    @test 
    def testMeetLattice03(): Bool =
        Assert.eq(MeetLattice.greatestLowerBound(SemVer(2, 1, 0), SemVer(1, 1, 0)), Bot)

    @test
    def testPatchCompatible01(): Bool =
        Version.isPatchCompatible(SemVer(1, 2, 3), SemVer(1, 2, 3))

    @test
    def testPatchCompatible02(): Bool =
        Version.isPatchCompatible(SemVer(1, 2, 3), SemVer(1, 2, 4))

    @test
    def testPatchCompatible03(): Bool =
        not Version.isPatchCompatible(SemVer(1, 2, 3), SemVer(1, 3, 3))
}