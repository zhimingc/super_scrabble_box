extends AudioStreamPlayer

export var sfxLib : Dictionary

var streams = []

func _ready():
	GlobalConstants.connect("play_sfx", self, "play_sound")
	GlobalConstants.connect("play_sfx_pitch", self, "play_sound_pitch")
	add_stream()

func add_stream():
	var newStream = AudioStreamPlayer.new()
	add_child(newStream)
	streams.append(newStream)
	return streams.back()
	
func get_free_stream():
	for s in streams:
		if s.playing == false:
			return s
	return add_stream()
	
func play_sound(sfx):
	var stream = get_free_stream()
	if sfxLib.has(sfx):
		stream.set_stream(sfxLib[sfx])
		stream.set_volume_db(get_volume_db())
		stream.play()
	else:
		print("No sound effect called: " + sfx)

func play_sound_pitch(sfx, pitch):
	if sfxLib.has(sfx):
		set_stream(sfxLib[sfx])
		set_pitch_scale(pitch)
		play()
