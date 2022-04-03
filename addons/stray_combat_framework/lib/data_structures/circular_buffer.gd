extends Reference
## docstring

#signals

#enums

#constants

#preloaded scripts and scenes

#exported variables

var capacity: int = 1 setget set_capacity

var _read_index: int
var _write_index: int
var _buffer: Array
var _is_full: bool

#onready variables


func _init(buffer_capacity: int = 1) -> void:
    set_capacity(buffer_capacity)

#built-in virtual _ready method

#remaining built-in virtual methods

func set_capacity(value: int) -> void:
    if value <= 0:
        push_error("Circular buffer capacity can not be smaller than 1")

    capacity = max(1, value)
    _buffer.resize(capacity)
    _read_index = 0
    _write_index = 0


func add(item) -> bool:
    if not _is_full:
        _buffer[_write_index] = item
        _write_index = wrapi(_write_index + 1, 0, capacity)
        _is_full = _write_index == _read_index
        return true
    return false


func insert(position: int, item):
    _buffer[position] = item


func peek():
    return _buffer[_read_index]


func peek_at(position: int):
    return _buffer[position]


func read():
    if not empty():
        _read_index = wrapi(_read_index + 1, 0, capacity)
        _is_full = false
        return peek()
    return null


func full() -> bool:
    return _is_full


func empty() -> bool:
    return _write_index == _read_index and not _is_full


func get_count() -> int:
    return _write_index - _read_index


func get_read_index() -> int:
    return _read_index


func get_write_index() -> int:
    return _write_index

    
func _iter_init(arg):
    return not empty()


func _iter_next(arg):
    return not empty()


func _iter_get(arg):
    return read()

#signal methods

#inner class
