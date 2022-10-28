extends Reference

const TransitionConfig = preload("../transition/transition_config.gd")
const ConditionParam = preload("../transition/condition/condition_param.gd")

var t_advance_conditions: Array
var t_prerequisites: Array
var t_auto_advance: bool
var t_priority: int
var t_switch_mode: int

## Type: (Condition) -> Condition
var _func_cache_condition: FuncRef

## Sets the condition caching function used by this config builder.
## Will be set automatically if passed into state machine builder.
func set_confition_caching_func(func_cache_condition: FuncRef) -> void:
    _func_cache_condition = func_cache_condition

## Sets the advance conditions of this transition
##
## Returns a reference to this builder
func advance_conditions(transition_advance_conditions: Array) -> Reference:
    var conditions: Array
    for condition in transition_advance_conditions:
        conditions.append(_cache_condition(condition))
    t_advance_conditions = conditions
    return self

## Sets the prerequisites of this transition
##
## Returns a reference to this builder
func prerequisites(transition_prereqs: Array) -> Reference:
    var conditions: Array
    for condition in transition_prereqs:
        conditions.append(_cache_condition(condition))
    t_prerequisites = conditions
    return self

## Enables auto advancing on this transition
##
## Returns a reference to this builder
func auto_advance() -> Reference:
    t_auto_advance = true
    return self

## Sets the priority of this transition
##
## Returns a reference to this builder
func priority(transition_priority: int) -> Reference:
    t_priority = transition_priority
    return self

## Sets the switch mode of this transition to 'immediate'
##
## Returns a reference to this builder
func switch_immediate() -> Reference:
    t_switch_mode = TransitionConfig.SwitchMode.IMMEDIATE
    return self

## Sets the switch mode of this transtion to 'at end'
##
## Returns a reference to this builder
func switch_at_end() -> Reference:
    t_switch_mode = TransitionConfig.SwitchMode.AT_END
    return self

## Builds transition config based on this builder's configurations.
## If this config builder is being used in a state machine builder there is no reason to manually call this.
func build() -> TransitionConfig:
    var tc := TransitionConfig.new()
    tc.advance_conditions = t_advance_conditions
    tc.prerequisites = t_prerequisites
    tc.auto_advance = t_auto_advance
    tc.priority = t_priority
    tc.switch_mode = t_switch_mode
    return tc


func _cache_condition(condition):
    if _func_cache_condition.is_valid():
        return _func_cache_condition.call_func(condition)
    return condition
