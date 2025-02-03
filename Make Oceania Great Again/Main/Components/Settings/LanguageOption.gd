extends OptionButton

var language_list : Array

func _ready():
	for item in get_item_count():
		language_list.append(get_item_text(item))
		set_item_text(item, TranslationServer.get_language_name(get_item_text(item)))

	var current_language : String = TranslationServer.get_locale()
	select(language_list.find(current_language))


func _on_item_selected(index):
	TranslationServer.set_locale(language_list[index])
