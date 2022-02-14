extends Object

var _function_references: Array

func _init(node: Node) -> void:
    if not is_instance_valid(node):
        push_warning("Given node instance is invalid. A null reference was likely passed. Freeing OnreadyCaller")
        free()
        return
    
    if node.is_inside_tree():
        push_warning("Given node already exist in tree and may have already been readied. Freeing OnreadyCaller")
        free()
        return

    node.connect("ready", self, "_on_Node_ready")
    node.connect("tree_exiting", self, "_on_Node_tree_exiting")


func add_call(obj: Object, function: String, args: Array) -> void:
    _function_references.append(FunctionReference.new(obj, function, args))


func _on_Node_ready() -> void:
    for function_reference in _function_references:
        function_reference.call_func()

    free()


func _on_Node_tree_exiting() -> void:
    # Free on exit as a precaution to avoid memory leaks
    free()


class FunctionReference:
    var _func_ref := FuncRef.new()
    var _args: Array
    var _obj: WeakRef
    var _obj_name: String

    func _init(obj: Object, function: String, args: Array = []) -> void:
        if not is_instance_valid(obj):
            push_error("Given call object is invalid. A null reference was likely passed. Freeing OnReadyCaller")
            free()
            return

        _func_ref.function = function
        _obj = obj
        _args = args
        _obj_name = "%s:%s" % [obj.get_class(), obj.get_instance_id()]
        _func_ref.set_instance(obj)


    func call_func() -> void:
        if not _func_ref.is_valid():
            if not is_instance_valid(_obj.get_ref()):
                push_warning("Failed to call method '%s' on object %s. Given instance is no longer valid. Freeing OnReadyCaller" % [_func_ref.function, _obj_name])
            elif not _obj.has_method(_func_ref.function):
                push_warning("Failed to call method '%s' on object %s. Function does not exist on given object. Freeing OnReadyCaller" % [_func_ref.function, _obj_name])
            else:
                push_warning("Failed to call method '%s' on object %s. Unknown error. Freeing OnReadyCaller" % [_func_ref.function, _obj_name])
            
            free()
            return
        
        if _args.empty():
            _func_ref.call_func()
        else:
            _func_ref.call_funcv(_args)