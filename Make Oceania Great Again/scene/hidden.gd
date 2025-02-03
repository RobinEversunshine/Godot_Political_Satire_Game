extends BaseGUIView


func _ready():
	pass # Replace with function body.



func open():
	super.open()
	await get_tree().create_timer(3).timeout
	if !Global.Note["Note_page"]:
		Game.new_noti("Notepad", "Note_page")
		Global.Note["Note_page"] = true
	close_self()


