extends Resource

class_name Call

@export var contact_name : String
var contact_number : int

@export var dialogue_resource: DialogueResource
@export var title: String = "call_start"

@export var call_time : Dictionary = {"year" : 2083, "month" : 12, "day" : 31, "hour": 0, "minute": 0}
@export var call_state : String
@export var talk_time : String

var call_contact : Contact
var is_text : bool
var is_history_call : bool
var call_end : bool = false
var text_message_list : Array[DialogueLine]
var dialogue_label : DialogueLabel
var i : int

signal dialogue_changed
signal new_dialogue_start
signal call_ended
signal skip_show

var dialogue_line : DialogueLine:
	set(next_dialogue_line):
		#dialogue ends
		if not next_dialogue_line:
			call_end = true
			free_dialogue_label()
			emit_signal("call_ended")
			emit_signal("skip_show")
			return
		
		if i != Game.playthrough_count:
			return
		
		dialogue_line = next_dialogue_line
		text_message_list.append(dialogue_line)
		emit_signal("dialogue_changed", dialogue_line)
		
		
		if is_text:
			update_message_time()
			var latest_view : BaseGUIView = Game.get_gui_view_manager().active_view_path[-1]
			#not at chat app
			if latest_view.config.id != "Chats":
				if dialogue_line.character != "System" && dialogue_line.character != "Player":
					#show message on top, add notification to chat contactor
					Game.new_noti("Chats", contact_name, dialogue_line.text)
					var contact : Contact = Game.get_contact_list().phoneNumberMap[contact_number]
					contact.notification_count += 1
				
				#won't skip the line if it's shown atop of the screen
				await line_typing()
				
			#at the chat app
			else:
				if !PhoneText.skip_mode:
					await line_typing()
				else:
					await PhoneText.get_tree().process_frame
		
		else:
			if !PhoneText.skip_mode && !is_history_call:
				await line_typing()
			else:
				await PhoneText.get_tree().process_frame
		
		
		if dialogue_line.responses.size() == 0:
			next(dialogue_line.next_id)
		else:
			emit_signal("skip_show")
		
		if !PhoneText.skip_mode:
			emit_signal("skip_show")


func _init():
	i = Game.playthrough_count


func start() -> void:
	if is_text:
		call_contact = Game.get_contact_list().phoneNumberMap[contact_number]
	self.dialogue_line = await dialogue_resource.get_next_dialogue_line(title)
	emit_signal("new_dialogue_start")


func next(next_id: String) -> void:
	self.dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id)


#used for typing one dialogue, show next when the typing is done
func line_typing():
	if dialogue_label:
		dialogue_label.dialogue_line = dialogue_line
		dialogue_label.type_out()
		await dialogue_label.finished_typing
		await PhoneText.get_tree().create_timer(1.2).timeout
	else:
		var await_time : float = 0.04 * dialogue_line.text.length() + 2
		await PhoneText.get_tree().create_timer(await_time).timeout


#used for chatbox order in chats.
func update_message_time():
	if call_contact:
		call_contact.unix_time = DateTime.unix_time


func free_dialogue_label():
	if is_instance_valid(dialogue_label):
		dialogue_label.queue_free()

