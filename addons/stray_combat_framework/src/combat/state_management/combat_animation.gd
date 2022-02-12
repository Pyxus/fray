extends Resource

var default_animation: String
var conditional_animations: Array

class ConditionalAnimation:
    extends Reference

    const Condition = preload("conditions/condition.gd")

    var animation: String
    var condition: Condition