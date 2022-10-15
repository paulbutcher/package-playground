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
}
