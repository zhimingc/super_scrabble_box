extends Area2D

var letter = "A"

signal collected

func _ready():
	randomize()
	var conv = PoolByteArray()
	conv.append(65 + randi() % 26)
	letter = conv.get_string_from_ascii()

func _on_LetterBox_body_entered(body):
	if body.name == "PlayerCharacter":
		body.add_letter(letter)
		queue_free()
		emit_signal("collected")
		
