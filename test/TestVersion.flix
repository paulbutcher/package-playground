namespace Version {

    @test
    def testParse01(): Bool =
        Assert.eq(parse("1.2.3"), Some(Components(1, 2, 3)))

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
        PartialOrder.lessEqual(Components(1, 2, 3), Components(1, 2, 3))

    @test
    def testPartialOrder02(): Bool =
        PartialOrder.lessEqual(Components(1, 2, 3), Components(1, 3, 0))

    @test
    def testPartialOrder03(): Bool =
        PartialOrder.lessEqual(Components(1, 2, 3), Components(1, 2, 4))

    @test
    def testPartialOrder04(): Bool =
        not PartialOrder.lessEqual(Components(1, 2, 3), Components(1, 1, 3))

    @test
    def testPartialOrder05(): Bool =
        not PartialOrder.lessEqual(Components(1, 2, 3), Components(1, 2, 2))

    @test
    def testPartialOrder06(): Bool =
        not PartialOrder.lessEqual(Components(0, 2, 3), Components(1, 2, 3))

    @test
    def testPartialOrder07(): Bool =
        not PartialOrder.lessEqual(Components(1, 2, 3), Components(0, 2, 3))
}