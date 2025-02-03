extends Resource

class_name Contact

@export var id : StringName
@export var profile_photo_128 : Texture
@export var profile_photo_38 : Texture
@export var phone_number : int
@export var call_dialogue_resource : DialogueResource
@export var callable : bool = false
@export var call_default_bg_sfx : Array[AudioStream]
@export var history_call : Call

var text_call_list : Array[Call]

#used for chatbox order in chats.
var unix_time : int = 3597512400

signal text_start
signal new_noti


#used for contact notification in chats
var notification_count : int = 0:
	set(value):
		notification_count = value
		emit_signal("new_noti")


func add_new_call(new_call : Call):
	text_call_list.append(new_call)


#used for pre-game calls
func update_history_call():
	if history_call != null:
		history_call.is_history_call = true
		history_call.start()
		add_new_call(history_call)


#used to reset game
func reset_history_call():
	text_call_list = []
