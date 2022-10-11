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

    pub def objToString(o: a): String =
        import java.lang.Object.toString(): String \ {};
        toString(o as ##java.lang.Object)

    pub def printObject(o: a): Unit \ IO =
        println(objToString(o))
}
