extends Reference

static func sort_ascending(t1, t2, property: String = "") -> bool:
	if property.is_empty():
		if t1[property] > t2[property]:
			return true
		else: 
			return false
	else:
		if t1 > t2:
			return true
		else: 
			return false
