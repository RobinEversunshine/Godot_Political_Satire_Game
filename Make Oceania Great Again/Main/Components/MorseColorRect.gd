extends ColorRect



func _ready():
	Key.connect("morse_short", short)
	Key.connect("morse_long", long)
	hide()


func short():
	show()
	await get_tree().create_timer(0.1).timeout
	hide()


func long():
	show()
	await get_tree().create_timer(0.8).timeout
	hide()
