extends PanelContainer

@export var news_title : String
@export var news_photo : Texture2D
@export var likes : String = "likes"
@export var comments : String = "comments"
@export var reposts : String = "reposts"
@export var comments_below : Array[String]

@onready var news_title_label = $VBoxContainer/MarginContainer/NewsTitle
@onready var news_photo_text = $VBoxContainer/NewsPhoto
@onready var likes_label = $VBoxContainer/HBoxContainer/Likes/LikesLabel
@onready var comments_label = $VBoxContainer/HBoxContainer/Comments/CommentsLabel
@onready var reposts_label = $VBoxContainer/HBoxContainer/Reposts/RepostsLabel

@onready var label = $VBoxContainer/MarginContainer2/VBoxContainer/Label


func _ready():
	news_title_label.text = news_title
	news_photo_text.texture = news_photo
	likes_label.text = likes
	comments_label.text = comments
	reposts_label.text = reposts
	if likes == "likes":
		likes_label.get_parent().modulate.a = 0.5
	if comments == "comments":
		comments_label.get_parent().modulate.a = 0.5
	if reposts == "reposts":
		reposts_label.get_parent().modulate.a = 0.5


func new_comment(comment : String):
	var new_comment_label = label.duplicate()
	label.get_parent().add_child(new_comment_label)
	new_comment_label.text = comment
	new_comment_label.show()
