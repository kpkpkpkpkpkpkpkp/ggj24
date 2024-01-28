extends AudioStreamPlayer


@export var music_first:AudioStream
@export var music_main_loop:AudioStream
@export var win_jingle:AudioStream

func _ready():
	start_music()
	
func start_music():
	stream=music_first
	play()
	await finished
	stream=music_main_loop
	play()

func win():
	stream=win_jingle
	play()
