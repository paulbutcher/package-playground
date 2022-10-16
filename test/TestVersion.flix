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
}