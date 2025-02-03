extends Node

class_name GUIViewManager

@export var ViewConfigList : Array[GUIViewConfig] = []
@export var guiRoot : Node
@export var guiRoot_phone_call : Node

var viewConfigMap : Dictionary = {}
var viewInstanceCount = 0
var viewInstanceMap : Dictionary = {}
var active_view_path : Array[BaseGUIView] = []

func _ready():
	_build_view_config_map()


func _build_view_config_map():
	for config in ViewConfigList:
		if config == null or config.id.is_empty():
			continue
		viewConfigMap[config.id] = config

func _get_view_config(viewId : StringName) -> GUIViewConfig:
	return viewConfigMap[viewId]

func _gen_new_view_instance_id() -> int:
	var t = viewInstanceCount
	viewInstanceCount += 1
	return t

func _get_view_instance(viewInstanceId : int) -> BaseGUIView:
	return viewInstanceMap[viewInstanceId]


func open_view(viewId : StringName) -> BaseGUIView:
	if viewId in viewConfigMap:
		var config = _get_view_config(viewId)
		config.notification_count = 0
		
		var viewInstanceId = _gen_new_view_instance_id()
		var prefab : PackedScene = config.prefab
		var v = prefab.instantiate() as BaseGUIView
		
		v.config = config
		v.viewInstanceID = viewInstanceId
		viewInstanceMap[viewInstanceId] = v
		
		if viewId != "PhoneCall":
			guiRoot.add_child(v)
		else:
			guiRoot_phone_call.add_child(v)
		#v.owner = get_tree().current_scene
		active_view_path.append(v)
		v.open()
		return v
	else:
		return null


func close_view(viewInstanceId : int):
	if active_view_path.size() != 1:
		var v = _get_view_instance(viewInstanceId)
		active_view_path.erase(v)
		await v.close()
		viewInstanceMap.erase(viewInstanceId)
		v.queue_free()


func find_view(config_id : String):
	var found = false
	for gui_view in active_view_path:
		if gui_view.config.id == config_id:
			found = gui_view
			break
	return found


func reset_noti():
	for view_config in ViewConfigList:
		view_config.notification_count = 0


func get_current_view():
	return active_view_path[-1]





