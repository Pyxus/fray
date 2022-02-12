extends Resource


var priority: int

class PrioritySorter:
    extends Reference

    static func sort_ascending(t1, t2) -> bool:
        if t1.priority > t2.priority:
            return true
        else: 
            return false