extends BaseGUIView

@onready var contact_lautrec = $ScrollContainer/MarginContainer/VBoxContainer/ContactBox3


func _ready():
	if !Global.known_Lautrec:
		contact_lautrec.hide()

