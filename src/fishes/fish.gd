extends Sprite2D

signal blew_bubble(_bubble_ref)

@export var bubble_scene=preload("res://src/bubble.tscn")
@export var speedscale:=1.0
var laughing:=false
var accel:=0


func _ready():
	$AnimationPlayer.play('swimmin')
	add_to_group('audience')


func _physics_process(delta):
	if laughing:return
	flip_h=accel<0
	position.x+=(accel*delta*speedscale)
	$AnimationPlayer.speed_scale=speedscale
	
@export var num_bubbles:=1

func laugh():
	laughing=true
	for ix in range(num_bubbles):
		var bubble=bubble_scene.instantiate()
		add_sibling(bubble)
		bubble.global_position=global_position
		bubble.floating=true
		await get_tree().create_timer(0.5).timeout
		laughing=false
		blew_bubble.emit(bubble)
	

