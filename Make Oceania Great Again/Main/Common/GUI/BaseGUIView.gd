extends Control

class_name BaseGUIView

var config : GUIViewConfig
var viewInstanceID : int = -1

func open():
	pivot_offset = size / 2
	modulate.a = 0
	scale = Vector2(0, 0)
	get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_CUBIC)
	get_tree().create_tween().tween_property(self, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_CUBIC)


func close():
	get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.4).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_tween().tween_property(self, "scale", Vector2(0, 0), 0.4).set_trans(Tween.TRANS_CUBIC).finished


func close_self():
	Game.get_gui_view_manager().close_view(viewInstanceID)


func back():
	close_self()
