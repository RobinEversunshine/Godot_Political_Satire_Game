extends Sprite2D

var available : bool = true

#func _ready():
	#pass # Replace with function body.




func _process(delta):
	position = get_global_mouse_position()



#func _input(event):
	#if available:
		#if event is InputEventMouseMotion:
			#add_ghost()
			#available = false
			#await get_tree().process_frame
			#available = true

#func _unhandled_input(event):
	#if event is InputEventMouseMotion:
		##print(event.relative)
		##position = event.relative * 2 + get_global_mouse_position()
		#position = get_global_mouse_position()



func add_ghost():
	var ghost = duplicate(0)
	get_parent().add_child(ghost)
