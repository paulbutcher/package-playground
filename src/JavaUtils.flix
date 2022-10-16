namespace JavaUtils {

    pub def fromJavaIter(iter: ##java.util.Iterator): Iterator[a, Static] =
        import java.util.Iterator.hasNext(): Bool \ IO;
        import java.util.Iterator.next(): a \ IO as getNext;

        let done = () -> not hasNext(iter);
        let next = () -> {
            if(hasNext(iter)) {
                getNext(iter)
            } else {
                bug!("Empty iterator.")
            }
        };
        Iterator(done, next)

    pub def fromJavaList(l: ##java.util.List): List[a] \ IO =
        import java.util.List.iterator(): ##java.util.Iterator \ IO;
        iterator(l) |> fromJavaIter |> Iterator.toList

    pub def toJavaList(l: List[a]): ##java.util.List \ IO =
        import new java.util.ArrayList(): ##java.util.List \ IO as newList;
        import java.util.List.add(##java.lang.Object): Bool \ IO;
        List.foldLeft((jl, e) -> {discard add(jl, e as ##java.lang.Object); jl}, newList(), l)

    pub def objToString(o: a): String =
        import java.lang.Object.toString(): String \ {};
        toString(o as ##java.lang.Object)

    pub def printObject(o: a): Unit \ IO =
        println(objToString(o))

    pub def findMatches(regex: String, s: String): Option[List[String]] = region r {
        import static java.util.regex.Pattern.compile(String): ##java.util.regex.Pattern \ Write(r);
        import java.util.regex.Pattern.matcher(##java.lang.CharSequence): ##java.util.regex.Matcher \ Write(r);
        import java.util.regex.Matcher.find(): Bool \ Write(r);
        import java.util.regex.Matcher.groupCount(): Int32 \ Read(r);
        import java.util.regex.Matcher.group(Int32): String \ Read(r);

        let _ = r; // Defeat unused variable warning
        let pattern = compile(regex);
        let matches = matcher(pattern, s as ##java.lang.CharSequence);
        if (find(matches))
            Some(List.range(0, groupCount(matches)) |> List.map(i -> group(matches, i + 1)))
        else
            None
    }

}
