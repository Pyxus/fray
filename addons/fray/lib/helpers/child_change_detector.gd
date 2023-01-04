extends RefCounted

signal child_changed(node, change)

enum Change{
	ADDED,
	REMOVED,
	RENAMED,
	SCRIPT_CHANGED,
}

const SignalUtils = preload("utils/signal_utils.gd")

var _parent: Node

func _init(parent: Node) -> void:
	if not parent.is_inside_tree():
		push_error("Failed to initialize. Given node parent is not inside of tree.")
		return

	var scene_tree = parent.get_tree()
	_parent = parent
	SignalUtils.safe_connect(scene_tree, "node_added", self, "_on_SceneTree_node_added")
	SignalUtils.safe_connect(scene_tree, "node_removed", self, "_on_SceneTree_node_removed")


func _on_SceneTree_node_added(node: Node) -> void:
	if node.get_parent() == _parent:
		emit_signal("child_changed", node, Change.ADDED)
		SignalUtils.safe_connect(node, "script_changed", self, "_on_ChildNode_script_changed", [node])
		SignalUtils.safe_connect(node, "renamed", self, "_on_ChildNode_renamed", [node])

		
func _on_SceneTree_node_removed(node: Node) -> void:
	if node.get_parent() == _parent:
		emit_signal("child_changed", node, Change.REMOVED)
		SignalUtils.safe_disconnect(node, "script_changed", self, "_on_ChildNode_script_changed")
		SignalUtils.safe_disconnect(node, "renamed", self, "_on_ChildNode_renamed")


func _on_ChildNode_script_changed(node: Node) -> void:
	emit_signal("child_changed", node, Change.SCRIPT_CHANGED)


func _on_ChildNode_renamed(node: Node) -> void:
	emit_signal("child_changed", node, Change.REMOVED)
