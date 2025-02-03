extends Node

var call_history_array : Array[Call] = []

var skip_mode : bool = false:
	set(value):
		skip_mode = value
		emit_signal("reset_skipmode", value)

var is_calling : bool = false

var reject_boss : int = 0

signal call_start
signal call_ended
signal reset_skipmode


func add_dialogue_label():
	var dialogue_label = DialogueLabel.new()
	dialogue_label.seconds_per_step = 0.04
	add_child(dialogue_label)
	return dialogue_label


func add_new_call(ContactNumber : int, dialogue_name, title: String = "call_start", is_text : bool = false):
	var new_call : Call = Call.new()
	new_call.contact_number = ContactNumber
	new_call.is_text = is_text
	new_call.dialogue_label = add_dialogue_label()
	new_call.dialogue_label.name = str(dialogue_name)
	new_call.title = title
	new_call.call_time = DateTime.date_time
	
	if dialogue_name is String:
		new_call.dialogue_resource = dialogue_name_to_resource(dialogue_name)
	elif dialogue_name is DialogueResource:
		new_call.dialogue_resource = dialogue_name
	
	return new_call


func open_phone_call_view(new_call : Call):
	var phone_call_view = Game.get_gui_view_manager().open_view("PhoneCall")
	phone_call_view.phone_call = new_call
	phone_call_view.update_information()
	emit_signal("call_start")


func receive_text(ContactNumber : int, dialogue_name, title: String = "call_start") -> Call:
	var new_call : Call = add_new_call(ContactNumber, dialogue_name, title, true)
	var call_contact = Game.get_contact_list().phoneNumberMap[ContactNumber]
	
	call_contact.add_new_call(new_call)
	new_call.contact_name = call_contact.id
	call_contact.emit_signal("text_start")
	new_call.start()
	return new_call


func receive_call(ContactNumber : int, dialogue_name, title: String = "call_start") -> Call:
	#use while loop to prevent when you constantly call someone in contacts
	var i = Game.playthrough_count
	while true:
		if i != Game.playthrough_count:
			return
		
		if is_calling == false:
			break
		else:
			await call_ended
			await get_tree().create_timer(2).timeout
	
	var new_call : Call = add_new_call(ContactNumber, dialogue_name, title)
	var call_contact = Game.get_contact_list().phoneNumberMap[ContactNumber]
	new_call.contact_name = call_contact.id
	new_call.call_state = "in"
	
	open_phone_call_view(new_call)
	return new_call


func dial_out(ContactNumber : int) -> Call:
	var new_call : Call = add_new_call(ContactNumber, null)
	new_call.call_state = "out"
	
	if ContactNumber in Game.get_contact_list().phoneNumberMap:
		var call_contact : Contact = Game.get_contact_list().phoneNumberMap[ContactNumber]
		new_call.contact_name = call_contact.id
		new_call.dialogue_resource = call_contact.call_dialogue_resource
	else:
		new_call.contact_name = str(ContactNumber)
	
	open_phone_call_view(new_call)
	return new_call


func new_call_history(new_call : Call):
	call_history_array.append(new_call)
	
	#if you dare to reject your boss.
	if new_call.contact_number == 6665:
		if new_call.call_state == "rejected" || new_call.call_state == "missed":
			reject_boss += 1
			var i : int = Game.playthrough_count
			
			if reject_boss > 1:
				await get_tree().create_timer(3).timeout
				if i == Game.playthrough_count:
					var reject_call = receive_text(6665, "boss", "reject_boss")
					await reject_call.call_ended
					if reject_boss == 4:
						await get_tree().create_timer(1).timeout
						Global.ending2()
						return
			
			await get_tree().create_timer(3).timeout
			if i == Game.playthrough_count:
				receive_call(6665, new_call.dialogue_resource, new_call.title)


func dialogue_name_to_resource(dialogue_name : String) -> DialogueResource:
	var resource_path : String = "res://Assets/Dialogues/" + dialogue_name + ".dialogue"
	return load(resource_path)


func reset_script():
	skip_mode = false
	is_calling = false
	reject_boss = 0
	call_history_array = []


