extends TextureRect

signal resume_pressed
signal menu_pressed


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		visible=!visible
		get_tree().paused=visible
		if visible:$HBoxContainer/Resume.grab_focus()



func resume():
	get_tree().paused=false
	visible=false
	resume_pressed.emit()
	

func menu():
	get_tree().paused=false
	visible=false
	menu_pressed.emit()
