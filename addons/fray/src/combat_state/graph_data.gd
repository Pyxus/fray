extends Resource

const CombatSituation = preload("combat_situation.gd")

# Type: Dictionary<String, CombatSituation>
var _situation_by_name: Dictionary

func create_situation(name: String) -> CombatSituation:
	var situation := CombatSituation.new()
	
	if not has_situation(name):
		push_warning("Combat situation named '%s' already exists. Previous instance will be overwritten.")

	_situation_by_name[name] = situation

	return situation


func get_situation(name: String) -> CombatSituation:
	if has_situation(name):
		return _situation_by_name[name]
	return null


func has_situation(name: String) -> bool:
	return _situation_by_name.has(name)