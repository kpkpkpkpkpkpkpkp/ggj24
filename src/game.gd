extends Node2D

var DEBUG = false

var rng:RandomNumberGenerator
var t:=0.0
var score:=0

@export var endless:=false
@export var waterline:=38
@export var spawn_pos_left:=0.0
@export var spawn_pos_right:=270.0
@export var fish_spawn_interval:=2.0 # have a change to spawn a new fish every x seconds
@export var boats_to_rescue:=1

var total_range:=[70,540]
var fish_type_dict:={
	"base" : {
			"scene_path" : "fish.tscn",
			"depth_limits" : [42,90],
			"speed_limits" : [],
			"weight" : 3
			},
			
	"greenland_halibut" : {
			"scene_path" : "greenland_halubut.tscn",
			"depth_limits" : [120,165],
			"weight" : 1
			},
							
	"haddock" : {
			"scene_path" : "haddock.tscn",
			"depth_limits" : [70,100],
			"weight" : 2
			},
				
	"pacific_herring" : {
			"scene_path" : "pacific_herring.tscn",
			"depth_limits" : [87,140],
			"weight" : 3
			},
						
	"saffron_cod" : {
			"scene_path" : "saffron_cod.tscn",
			"depth_limits" : [50,83],
			"weight" : 3
			},
					
	"bering_flounder" : {
			"scene_path" : "bering_flounder.tscn",
			"depth_limits" : [120,150],
			"weight" : 2
			},
}

var start_fish_ct:=4

@export var sequence_length_increment:=1
var current_sequence_clear_ct:=0

func _ready():
	$Waves/AnimationPlayer.play('wave')
	rng=RandomNumberGenerator.new()
	_new_boat()
	

func _make_initial_fish():
	for i in range(start_fish_ct):
		make_fish(FishSpawnSide.LEFT)


func _process(_delta):
	t+=_delta
	if t>fish_spawn_interval&&(rng.randf()>0.8):
		make_fish()
		t=0.0
	
	check_end_condition()
	if endless:
		$CanvasLayer/Score.text='Boats Rescued %d'%score
	elif boats_to_rescue>1:
		$CanvasLayer/Score.text='Boats Rescued %d/%d'%[score,boats_to_rescue]
		
	queue_redraw()
	
	
func check_end_condition():
	if current_boat!=null&&weakref(current_boat).get_ref()!=null:
		if current_boat.position.y>waterline&&!current_boat.sunk:
			current_boat.sink()
			$CanvasLayer/Menu.set_win(false)
			$CanvasLayer/Menu.popup()
			$Seal.sequence_length=3
			$Seal.new_sequence()
		elif current_boat.position.x>spawn_pos_right&&!current_boat.sunk:
			score+=1
			current_sequence_clear_ct+=1
			if current_sequence_clear_ct>=sequence_length_increment:
				current_sequence_clear_ct=0
				$Seal.sequence_length+=1
				#$Seal.new_sequence()
				
			if score<boats_to_rescue||endless:
				current_boat.queue_free()
				_new_boat()
			else:
				current_boat.escape()
				$Seal.sequence_length=3
				$CanvasLayer/Menu.set_win(true)
				$BGM.win()
				$CanvasLayer/Menu.popup()
			#You win!

		

var current_boat:Node2D
func _new_boat(scene_path:="res://src/boat.tscn"):
	if current_boat!=null:
		current_boat.queue_free()
	var boat_scn=load(scene_path)
	current_boat=boat_scn.instantiate()
	add_child(current_boat)
	current_boat.position=$BoatSpawn.position
	_make_initial_fish()
	#boat.sank.connect(Callable(on_boat_sunk).bind(boat),CONNECT_DEFERRED|CONNECT_ONE_SHOT)
	
	
#func on_boat_sunk(b):
	#await get_tree().create_timer(1.0).timeout
	
	
func _draw():
	if !DEBUG:return
	string_at('Boats Rescued %d'%[score],Vector2(4,8))
	draw_line(Vector2(0,waterline),Vector2(spawn_pos_right,waterline),Color.DARK_BLUE,2)
	string_at('waterline %d'%[waterline],Vector2(40,waterline-8))
	
	
func string_at(str,at:Vector2):
	draw_string(
			load("res://assets/DePixelBreit.ttf"),
			at,
			str,
			0,-1,8,Color.DARK_RED)

enum FishSpawnSide {
	RANDOM,
	LEFT,
	RIGHT,
}

func make_fish(side:=FishSpawnSide.RANDOM):
	var fish_types = []
	for fish_key in fish_type_dict.keys():
		for i in range(fish_type_dict[fish_key].weight):
			fish_types.append(fish_key)
	
	var fish_type = fish_types[rng.randi_range(0,fish_types.size()-1)]
	
	var fish_scn_path="res://src/fishes/" + fish_type_dict[fish_type]['scene_path']
	var fish=load(fish_scn_path).instantiate()
	add_child(fish)
	
	
	if side==FishSpawnSide.LEFT:
		fish.position.x=spawn_pos_left
		fish.accel=rng.randi_range(15,30)
	elif side==FishSpawnSide.RIGHT:
		fish.position.x=spawn_pos_right
		fish.accel=-rng.randi_range(15,30)
	else:
		if(rng.randf()>0.5):
			fish.position.x=spawn_pos_right
			fish.accel=-rng.randi_range(15,30)
		else:
			fish.position.x=spawn_pos_left
			fish.accel=rng.randi_range(15,30)

		
	fish.blew_bubble.connect(_on_fish_bubble)
	#print(fish_type)
	#print(fish_type_dict[fish_type]["depth_limits"])
	fish.position.y=rng.randi_range(
			max(fish_type_dict[fish_type]["depth_limits"][0],waterline+10),
			fish_type_dict[fish_type]["depth_limits"][1])


func _on_fish_bubble(_bubble_ref):
	if _bubble_ref==null:return
	if weakref(_bubble_ref).get_ref()==null:return
	_bubble_ref.waterline=waterline
	

func _on_seal_success():
	get_tree().call_group('audience','laugh')
	$SFX.laugh()


func _on_seal_failure():
	pass # Replace with function body.


func _on_continue_menu_pressed():
	var main_menu=load("res://src/ui/main_menu.tscn").instantiate()
	add_sibling(main_menu)
	queue_free()


func _on_continue_try_again_pressed():
	$Seal.sequence_length=3
	$Seal.new_sequence()
	$BGM.start_music()
	score=0
	_new_boat()
