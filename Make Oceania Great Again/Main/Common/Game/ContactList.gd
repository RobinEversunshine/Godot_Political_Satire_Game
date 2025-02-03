extends Node

@export var contactList : Array[Contact] = []

var phoneNumberMap : Dictionary = {}


func _enter_tree():
	_build_phone_number_map()


func _ready():
	for contact in contactList:
		if contact == null:
			continue
		contact.update_history_call()


func _build_phone_number_map():
	for contact in contactList:
		if contact == null:
			continue
		phoneNumberMap[contact.phone_number] = contact


func reset_history_call():
	for contact in contactList:
		if contact == null:
			continue
		contact.reset_history_call()
