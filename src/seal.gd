extends Node2D

var sequences:=[
		[0,1,2,3],
		[0,3,2,3],
		[0,2,2,0],
	]
	
signal success
signal failure

var input_buffer:=[]
var current_sequence:=[0,1,2,3]

var pressing:=false
var done:=false

var tricks:=[
	'loop',
	'spin',
	'flap'
]

@export var sequence_length:=3

func _ready():
	rng=RandomNumberGenerator.new()
	new_sequence()
	set_text_imgs()
	$AnimationPlayer.play('idle')


func _process(delta):
	pass
	
	
func _physics_process(delta):
	queue_redraw()
	pass


func _input(event):
	if !event is InputEventKey||!event.pressed:return
	if done:return
	
	if event.is_action_pressed("ui_up"):
		input_buffer.push_back(0)
	elif event.is_action_pressed("ui_down"):
		input_buffer.push_back(1)
	elif event.is_action_pressed("ui_left"):
		input_buffer.push_back(2)
	elif event.is_action_pressed("ui_right"):
		input_buffer.push_back(3)
	
	set_text_imgs()
	for ix in range(input_buffer.size()):
		if current_sequence[ix]!=input_buffer[ix]:
			done=true
			joke(false)
			await get_tree().create_timer(1.5).timeout
			new_sequence()
			failure.emit()
			reset()
			return
	if current_sequence.size()>input_buffer.size():return
	
	$RangeEffect.emitting=true
	done=true
	joke()
	success.emit()
	await get_tree().create_timer(1.0).timeout
	new_sequence()
	reset()


var rng:RandomNumberGenerator

func joke(_success:=true):
	if _success:
		$AnimationPlayer.play(tricks[rng.randi_range(0,2)])
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play('idle')
	else:
		$AnimationPlayer.play('bomb')
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play('idle')
		
		
func reset():
	input_buffer.clear()
	set_text_imgs()
	done=false
	
func set_text_imgs():
	$InputHint.text='[center]'
	for ix in range(current_sequence.size()):
		if input_buffer.size()>ix:
			if current_sequence[ix]!=input_buffer[ix]:
				$InputHint.text+=arrows_texture_wrong[current_sequence[ix]]
			else:
				$InputHint.text+=arrows_texture_complete[input_buffer[ix]]
		else:
			$InputHint.text+=arrows_texture[current_sequence[ix]]
			
	$InputHint.text+='[/center]'

func new_sequence():
	current_sequence.clear()
	for i in range(sequence_length):
		current_sequence.push_back(rng.randi_range(0,3))
	current_sequence.shuffle()
	set_text_imgs()


var arrows_texture:=[
	"[img]res://assets/sprites/menu/arrows/Up_Arrow.png[/img]",
	"[img]res://assets/sprites/menu/arrows/Down_Arrow.png[/img]",
	"[img]res://assets/sprites/menu/arrows/Left_Arrow.png[/img]",
	"[img]res://assets/sprites/menu/arrows/Right_Arrow.png[/img]"
	]

var arrows_texture_complete:=[
	"[img]res://assets/sprites/menu/arrows/Up_Arrow_Completed.png[/img]",
	"[img]res://assets/sprites/menu/arrows/Down_Arrow_Completed.png[/img]",
	"[img]res://assets/sprites/menu/arrows/Left_Arrow_Completed.png[/img]",
	"[img]res://assets/sprites/menu/arrows/Right_Arrow_Completed.png[/img]"
	]
	
var arrows_texture_wrong:=[
	"[img]res://assets/sprites/menu/arrows/Upbutton_wrong.png[/img]",
	"[img]res://assets/sprites/menu/arrows/downbutton_wrong.png[/img]",
	"[img]res://assets/sprites/menu/arrows/leftbutton_wrong.png[/img]",
	"[img]res://assets/sprites/menu/arrows/rightbutton_wrong.png[/img]"
	]

