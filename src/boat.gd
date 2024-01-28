extends Area2D

var DEBUG:=false

# Called when the node enters the scene tree for the first time.
var rng;
# initial horizontal speed, px/s
var initial_x_vel;
# number of bubbles currently under the boat
var n_bubbles:=0
"""
slowness_per_depth is the proportionality constant on how depth impacts
x-velocity. higher value -> deeper depths will slow =down the boat more. "viscosity"
might be a better name
"""
@export var slowness_per_depth=0.08

@export var weight = 80
@export var speedscale = 2.0
# when n_bubbles * bubbles_per_weight == weight, boat will not sink or rise
@export var bubbles_per_weight = 9
var bouyancy = 1
var sunk:=false
signal sank

@export var boat_sheets:=[
	preload("res://assets/sprites/boats/boat_sheet.png"),
	preload("res://assets/sprites/boats/boat_sheet_four.png"),
	preload("res://assets/sprites/boats/boat_sheet_three.png"),
	preload("res://assets/sprites/boats/boat_sheet_two.png")
]

# references to bubbles supporting the boat:
var bubbles = []
func _ready():
	rng = RandomNumberGenerator.new()
	$BoatSprite.texture=boat_sheets[rng.randi_range(0,boat_sheets.size()-1)]
	initial_x_vel = 10#rng.randf_range(7,10) # boat always moves to the right because Em said so
	$AnimationPlayer.play('float')
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var y_vel = delta * (weight - (n_bubbles * bubbles_per_weight)) * bouyancy 
	position.y+=y_vel*delta
	var _depth = max(1,position.y)
	var x_vel = (initial_x_vel / (_depth * slowness_per_depth) )* speedscale
	position.x += x_vel * delta
	
	get_tree().call_group('collected_bubbles','move',x_vel*delta,y_vel*delta)

func _physics_process(delta):
	queue_redraw()
func _draw():
	if !DEBUG:return
	string_at('depth %.2f'%[position.y],-10)
	string_at('bubbles %d'%[n_bubbles],-2)


func string_at(str,at):
	draw_string(
			load("res://assets/DePixelBreit.ttf"),
			Vector2(40,at),
			str,
			0,-1,8,Color.DARK_RED)
	

func collect_bubble(bubble):
	n_bubbles+=1
	bubble.floating=false
	#Make the bubble stop and disable it?
	bubble.add_to_group('collected_bubbles')
	bubble.tree_exiting.connect(Callable(_on_bubble_popped).bind(bubble))
	bubble.boat_collide()
	bubbles.append(bubble)

func _on_bubble_popped(bubble):
	bubbles.erase(bubble)
	n_bubbles-=1

func sink():
	sunk=true
	$AnimationPlayer.play('sink')
	for b in bubbles:
		b.queue_free()
	weight=460
	$CollisionPolygon2D.disabled=true
	
	sank.emit()


func escape():
	for b in bubbles:
		b.queue_free()
	queue_free()
