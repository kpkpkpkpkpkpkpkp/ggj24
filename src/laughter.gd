extends AudioStreamPlayer

@export var audio_streams:=[
	preload("res://assets/audio/sfx/Laugh 1.wav"),
	preload("res://assets/audio/sfx/Laugh 2.wav"),
	preload("res://assets/audio/sfx/Laugh 3.wav"),
	preload("res://assets/audio/sfx/Laugh 4.wav"),
]
var rng:RandomNumberGenerator


func _ready():
	rng=RandomNumberGenerator.new()
	
	
func laugh():
	stream=audio_streams[rng.randi_range(0,audio_streams.size()-1)]
	play()
	
