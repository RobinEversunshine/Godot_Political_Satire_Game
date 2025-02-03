extends OptionButton

var year_list : Array

func _ready():
	clear()
	year_list = range(2099, 1984, -1)
	for year in year_list:
		add_item(str(year))



