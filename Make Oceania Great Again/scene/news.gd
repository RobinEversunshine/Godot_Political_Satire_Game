extends BaseGUIView

@onready var v_box_container = $ScrollContainer/MarginContainer/VBoxContainer


const first_name_list : Array[String] = [
	"Alex",
	"Alan",
	"Bill",
	"Bruce",
	"Carl",
	"Chris",
	"Colin",
	"Donald",
	"Denny",
	"David",
	"Evan",
	"Eric",
	"Frank",
	"Fred",
	"Gary",
	"George",
	"Hank",
	"Henry",
	"Jack",
	"Kyle",
	"Larry",
	"Marcus",
	"Nick",
	"Owen",
	"Peter",
	"Robin",
	"Sam",
	"Thomas",
	"Victor",
	"William",
	"Zack",
	"Abigail",
	"Bella",
	"Carol",
	"Daisy",
	"Frieda",
	"Grace",
	"Hellen",
	"Jessie",
	"Kate",
	"Laura",
	"Maggie",
	"Nancy",
	"Rose",
	"Sonia",
	"Tina",
	"Zelda",
]


const last_name_list : Array[String] = [
	"Smith",
	"Jones",
	"Williams",
	"Brown",
	"Taylor",
	"Davis",
	"Johnson",
	"Wilson",
	"Thomas",
	"Adams",
	"Baker",
	"Green",
	"Roberts",
	"Campbell",
	"Turner",
	"Evans",
	"Carter",
	"Hill",
	"Allen",
	"Scott",
	"King",
	"Lee",
	"Moore",
	"Walker",
	"Lewis",
	"Clark",
	"White",
	"Thompson",
	"Martin",
]


func _ready():
	#TranslationServer.set_locale("zh")
	for news in v_box_container.get_children():
		var news_index : int = v_box_container.get_children().find(news)
		var rng = new_rand(news_index)
		for comment in news.comments_below:
			if !": " in tr(comment):
				var comment_content : String = rand_name(rng) + ": " + tr(comment)
				news.new_comment(comment_content)
			else:
				news.new_comment(comment)

func new_rand(new_seed : int):
	var rng = RandomNumberGenerator.new()
	rng.seed = new_seed
	return rng


func rand_name(rng : RandomNumberGenerator):
	var first_name_index = rng.randi_range(0, first_name_list.size() - 1)
	var last_name_index = rng.randi_range(0, last_name_list.size() - 1)
	return first_name_list[first_name_index] + " " + last_name_list[last_name_index]



