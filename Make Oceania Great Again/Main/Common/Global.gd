extends Node

signal mission_active


const NoteName : Array[String] = [
	"Note_fascism",
	"Note_vaccines",
	"Note_2plus2",
	"Note_page",
	"Note_color",
	"Note_president",
]

const MissionList : Dictionary = {
	"BASE" : ["ON", "OPN", "TFN", "TLN", "TO"],
	"ALBUM" : ["FP", "ISA"],
	"MOM" : ["FMN", "CH"],
	"FCS" : []
}

var Note : Dictionary
var MissionName : Dictionary
var VariantDict : Dictionary



#test variaties
var has_met : bool = false
var iii : int = 0


var unlock_in_advance : bool = true
var base_completed : bool = false
var about_candleheart : bool = false
var secret_album_lock : bool = true
var investigate_tailor : bool = false
var locked_album_found : bool = false
var into_veritas : bool = false


var boss_report_while : Array = [0, 0, 0]
var mom_while : Array = [0, 0, 0, 0, 0]
var candleheart_while : Array = [0, 0, 0, 0]
var trust : int = 100
var phone_power : int = 15




#callable variaties
var boss_callable : bool = false:
	set(value):
		boss_callable = value
		Game.get_contact_list().phoneNumberMap[6665].callable = value

var candleheart_callable : bool = true:
	set(value):
		candleheart_callable = value
		Game.get_contact_list().phoneNumberMap[4885].callable = value

var mom_callable : bool = false:
	set(value):
		mom_callable = value
		Game.get_contact_list().phoneNumberMap[2330].callable = value

var tailor_callable : bool = false:
	set(value):
		tailor_callable = value
		Game.get_contact_list().phoneNumberMap[1984].callable = value



#the phone's at lock page
var is_on_lock : bool = true:
	set(value):
		is_on_lock = value
		if value == false:
			if await wait_judgment(10) && !Game.edit_mode:
				PhoneText.receive_call(6665, "boss")


#already called or pretend that you called mom
var mom_called : bool = false:
	set(value):
		if value && !mom_called:
			mom_called = true
			await PhoneText.call_ended
			if await wait_judgment(30):
				PhoneText.receive_text(4885, "candleheart1", "called_mother")
		else:
			mom_called = value


#called mom's number and met Lautrec
var known_Lautrec : bool = false:
	set(value):
		known_Lautrec = value
		if value:
			await PhoneText.call_ended
			if await wait_judgment(1):
				Game.new_noti("Contacts", "Lautrec")
				Game.get_contact_list().phoneNumberMap[2330].id = "Lautrec"
		else:
			Game.get_contact_list().phoneNumberMap[2330].id = "2330"




##Main methods
func _ready():
	var variant_list = get_script().get_script_property_list()
	for variant in variant_list:
		var variant_name = variant["name"]
		if variant_name != "VariantDict":
			VariantDict[variant_name] = get(variant_name)
	reset_mission_note()
	
	#for variant in variant_list:
		#var variant_name = variant["name"]
		#if variant_name != "VariantDict":
			#VariantDict[variant_name] = get(variant_name)
	#print(VariantDict)


func reset_script():
	for variant_name in VariantDict:
		if variant_name != "VariantDict":
			set(variant_name, VariantDict[variant_name])
	reset_mission_note()


func reset_mission_note():
	for mission_list_name in MissionList:
		for mission_name in MissionList[mission_list_name]:
			MissionName[mission_name] = "disabled"
	
	for note_name in NoteName:
		Note[note_name] = false




##common methods
func get_view_manager():
	return Game.get_gui_view_manager()


func wait(wait_time : float):
	if PhoneText.skip_mode:
		await get_tree().process_frame
	else:
		await get_tree().create_timer(wait_time).timeout


#interrupt when resetting the game.
func wait_judgment(wait_time : float):
	var i = Game.playthrough_count
	await get_tree().create_timer(wait_time).timeout
	if i == Game.playthrough_count:
		return true
	else:
		return false


#activate missions in a mission list
func mission_activate(mission_id : String):
	for mission_name in MissionList[mission_id]:
		MissionName[mission_name] = "not completed"
	Game.new_noti("Missions", mission_id, "activate")
	emit_signal("mission_active", mission_id)


#detect if missions in a mission list are all completed
func mission_list_complete(mission_name : String):
	var mission_list_name : String = find_mission_list(mission_name)
	var completed : bool = true
	for mission in MissionList[mission_list_name]:
		if MissionName[mission] != "completed":
			completed = false
			break
	
	if completed && has_method(mission_list_name + "Complete"):
		call(mission_list_name + "Complete")


#complete a mission
func mission_complete(mission_name : String):
	if mission_name in MissionName:
		if MissionName[mission_name] == "not completed":
			MissionName[mission_name] = "completed"
			Game.new_noti("Missions", mission_name, "complete")
			mission_list_complete(mission_name)
			return true
			
		elif MissionName[mission_name] == "possible":
			Game.new_noti("Missions", mission_name, "possible")
			return true
		
		elif MissionName[mission_name] == "completed":
			return true
		else:
			return false
	else:
		return false


#mission is failed and can't be completed again
func mission_fail(mission_name : String):
	if mission_name in MissionName:
		if MissionName[mission_name] == "not completed":
			MissionName[mission_name] = "failed"


func mission_possible(mission_name : String):
	if mission_name in MissionName:
		if MissionName[mission_name] == "not completed":
			Game.new_noti("Missions", mission_name, "complete")


#find mission list's name based on mission name
func find_mission_list(mission_name : String):
	for list_name in MissionList:
		if mission_name in MissionList[list_name]:
			return list_name


#used for judgement of while loop in dialogues
func while_judgement(target_array : Array):
	for target in target_array:
		if target == 0:
			return false
	return true




##custom methods
func BASEComplete():
	if !base_completed:
		base_completed = true
		if await wait_judgment(3):
			PhoneText.receive_call(6665, "call_boss", "base_information_complete")


func ALBUMComplete():
	if await wait_judgment(5):
		PhoneText.receive_call(6665, "call_boss", "past_with_candleheart")


func activate_base_information():
	await PhoneText.call_ended
	if await wait_judgment(1):
		mission_activate("BASE")
		if await wait_judgment(5):
			PhoneText.receive_text(6665, "boss", "record")


func tailor():
	await PhoneText.call_ended
	if await wait_judgment(5):
		PhoneText.receive_text(6665, "call_boss", "tailor")
		investigate_tailor = true


func found_locked_album():
	if investigate_tailor && !locked_album_found:
		locked_album_found = true
		mission_activate("ALBUM")
		
		await get_tree().process_frame
		if !secret_album_lock:
			unlock_locked_album()
		
		if await wait_judgment(5):
			PhoneText.receive_text(6665, "call_boss", "album")


func unlock_locked_album():
	mission_complete("FP")


func candleheart_start():
	PhoneText.receive_text(4885, "candleheart1")


func candleheart_call():
	PhoneText.receive_call(4885, "call_candleheart", "call_in")
	await PhoneText.call_ended
	candleheart_callable = false
	await get_tree().create_timer(5).timeout


func boss_hack():
	await get_tree().create_timer(5).timeout
	PhoneText.receive_call(6665, "call_candleheart", "hacked")


func boss_first_report():
	mom_callable = true
	mission_activate("MOM")
	MissionName["FMN"] = "possible"
	about_candleheart = true
	
	if await wait_judgment(30):
		if PhoneText.is_calling:
			await PhoneText.call_ended
		if about_candleheart:
			PhoneText.receive_call(6665, "call_boss")


func note_vaccine():
	if Note["Note_vaccines"] == false:
		Note["Note_vaccines"] = true
		Key.emit_morse("vaccines")
		await PhoneText.call_ended
		if await wait_judgment(1):
			Game.new_noti("Notepad", "Note_vaccines")


func note_president():
	if Note["Note_president"] == false:
		Note["Note_president"] = true
		if await wait_judgment(3):
			Key.emit_morse("lier")
			Game.new_noti("Notepad", "Note_president")


func robin_call():
	await get_tree().create_timer(8).timeout
	PhoneText.receive_call(2592, "misc", "thanks_for_playing")


func ending1():
	await get_tree().create_timer(1).timeout
	await LevelTransition.fade_in_slowly()
	await get_tree().create_timer(5).timeout
	Game.reset()


func ending2():
	await get_tree().create_timer(2).timeout
	SoundPlayer.play_sound(SoundPlayer.FBI)
	Game.camera_shake()
	await get_tree().create_timer(2).timeout
	await LevelTransition.fade_in_slowly()
	await get_tree().create_timer(3).timeout
	Game.reset()



