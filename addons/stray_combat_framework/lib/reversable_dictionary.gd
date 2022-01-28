extends Reference

var _main_dict: Dictionary
var _reverse_dict: Dictionary


func add(key, value) -> void:
    _main_dict[key] = value
    _reverse_dict[value] = key

    
func clear() -> void:
    _main_dict.clear()
    _reverse_dict.clear()


func empty() -> bool:
    return _main_dict.empty()


func erase_key(key) -> bool:
    if _main_dict.has(key):
        var dict_item = _main_dict[key]
        _main_dict.erase(key)
        _reverse_dict.erase(dict_item)
        return true
    return false


func erase_value(value) -> bool:
    if _reverse_dict.has(value):
        var dict_item = _reverse_dict[value]
        _reverse_dict.erase(value)
        _main_dict.erase(dict_item)
        return true
    return false

    
func get_value(key, default = null):
    if _main_dict.has(key):
        return _main_dict[key]
    return default


func get_key(value, default = null):
    if _reverse_dict.has(value):
        return _reverse_dict[value]
    return default


func has_key(key) -> bool:
    return _main_dict.has(key)


func has_value(value) -> bool:
    return _reverse_dict.has(value)


func has_all_keys(keys: Array) -> bool:
    if _main_dict.empty():
        return false
    
    for key in keys:
        if not _main_dict.has(key):
            return false
    
    return true


func has_all_values(values: Array) -> bool:
    if _reverse_dict.empty():
        return false
    
    for value in values:
        if not _reverse_dict.has(value):
            return false
    
    return true


func hash_main() -> int:
    return _main_dict.hash()


func hash_reverse() -> int:
    return _reverse_dict.hash()


func size() -> int:
    return _main_dict.size()


func keys() -> Array:
    return _main_dict.keys()


func values() -> Array:
    return _main_dict.values()