extends Area2D

var DEBUG:=false

@export var speed:=55.0
@export var lifetime:=10.0
@export var fnt=preload("res://assets/DePixelBreit.ttf")

var floating:=false
var timer
var waterline:=0.0


func _ready():
	$GlubGlub.play()


func pop():
	$Pop.play()
	await $Pop.finished
	queue_free()
	


func _physics_process(_delta):
	queue_redraw()
	if floating:
		_process_float(_delta)
	

func boat_collide():
	timer=get_tree().create_timer(lifetime)
	timer.timeout.connect(pop)

"""
Called in physics process. 
Can be overridden to create bubbles that move in different ways
"""
func _process_float(_delta):
	position.y-=_delta*speed
	if position.y<waterline:
		pop()


func move(x_vel,y_vel):
	position.x += x_vel
	position.y += y_vel


func start():
	floating=true
	$GlubGlub.playing=true
	#Fade out


func _draw():
	if !DEBUG:return
	if timer!=null: draw_string(fnt,Vector2(4,0),'lt%.2f'%timer.time_left,0,-1,8)
