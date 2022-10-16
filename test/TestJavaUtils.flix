namespace JavaUtils {

    @test
    def testFindMatches01(): Bool =
        Assert.eq(findMatches("(\\d+)\\.(\\d+)\\.(\\d+)", "0.10.42"),
            Some("0" :: "10" :: "42" :: Nil))
}