extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var cg = $CG
@onready var audio_stream_player = $CG/AudioStreamPlayer
@onready var skip_label = $CG/MarginContainer/SkipLabel
@onready var dialogue_label = $CG/CenterContainer/MarginContainer/DialogueLabel

@onready var ending_scene = $EndingScene

@onready var animation_player = $AnimationPlayer

signal cg_finished


var dialogue_resource: DialogueResource = preload("res://Assets/Dialogues/misc.dialogue")
var title: String = "opening"
var subtitle_ends : bool = false
var subtitle_showing : bool = false


var dialogue_line : DialogueLine:
	set(next_dialogue_line):
		#dialogue ends
		if not next_dialogue_line:
			subtitle_ends = true
			return
		
		dialogue_line = next_dialogue_line


func _ready():
	animation_player.play("RESET")
	ending_scene.hide()
	cg.hide()
	dialogue_label.hide()


func _process(delta):
	if cg.is_playing() && !subtitle_ends:
		if !subtitle_showing:
			if cg.stream_position > float(dialogue_line.get_tag_value("start")):
				dialogue_label.show()
				subtitle_showing = true
		else:
			if cg.stream_position > float(dialogue_line.get_tag_value("end")):
				dialogue_label.hide()
				subtitle_showing = false
				next(dialogue_line.next_id)



#subtitle
func start() -> void:
	self.dialogue_line = await dialogue_resource.get_next_dialogue_line(title)
	dialogue_line.text = "[center]" + dialogue_line.text
	dialogue_label.dialogue_line = dialogue_line


func next(next_id: String) -> void:
	self.dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id)
	dialogue_line.text = "[center]" + dialogue_line.text
	dialogue_label.dialogue_line = dialogue_line



#cg methods
func play_cg():
	black()
	cg.show()
	cg.play()
	audio_stream_player.play()
	subtitle_ends = false
	start()
	
	skip_label.modulate = Color.TRANSPARENT
	get_tree().create_tween().tween_property(skip_label, "modulate", Color.WHITE, 1).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(2).timeout
	get_tree().create_tween().tween_property(skip_label, "modulate", Color.TRANSPARENT, 1).set_trans(Tween.TRANS_CUBIC)
	
	await cg.finished
	cg_fade_out()


func cg_fade_out(tween_time : float = 1):
	get_tree().create_tween().tween_property(audio_stream_player, "volume_db", -20, tween_time).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_tween().tween_property(cg, "modulate", Color.TRANSPARENT, tween_time).set_trans(Tween.TRANS_CUBIC).finished
	cg.stop()
	audio_stream_player.stop()
	cg.hide()
	await get_tree().create_timer(0.5).timeout
	emit_signal("cg_finished")
	fade_out()


func _input(event):
	if event.is_action_pressed("ui_cancel") && cg.is_playing():
		cg_fade_out()



#fade in & out
func fade_in():
	if !color_rect.visible:
		animation_player.play("fade_in")
		await animation_player.animation_finished

func fade_out():
	if color_rect.visible:
		animation_player.play("fade_out")
		await animation_player.animation_finished

func black():
	animation_player.play("black")

func fade_in_slowly():
	if !color_rect.visible:
		animation_player.play("fade_in_slowly")
		await animation_player.animation_finished


