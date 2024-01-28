extends TextureRect

func _ready():
	$Buttons/Start.grab_focus()


func start(endless:=false):
	var game=load("res://src/game.tscn").instantiate()
	add_sibling(game)
	game.endless=endless
	if endless:game.sequence_length_increment=3
	queue_free()


func show_about(do:=true):
	$AboutPage1.visible=do

