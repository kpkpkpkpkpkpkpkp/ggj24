extends TextureRect

@export var tex_win:Texture2D
@export var tex_lose:Texture2D

signal try_again_pressed
signal menu_pressed


func popup():
	visible=true
	$HBoxContainer/TryAgain.grab_focus()

func set_win(do:=true):
	if do:texture=tex_win
	else:texture=tex_lose


func start():
	get_tree().paused=false
	visible=false
	try_again_pressed.emit()
	

func menu():
	get_tree().paused=false
	visible=false
	menu_pressed.emit()
