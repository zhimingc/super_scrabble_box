extends AudioStreamPlayer

export var playerJump : AudioStream
export var sfxLib : Dictionary

func _ready():
	GlobalConstants.connect("play_sfx", self, "play_sound")

func play_sound(sfx):
	if sfxLib.has(sfx):
		set_stream(sfxLib[sfx])
		play()
	else:
		print("No sound effect called: " + sfx)
