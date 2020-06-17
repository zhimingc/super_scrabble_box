extends Area2D

var letter = "A"

signal collected

func _ready():
	randomize()
	var poolSize = GlobalConstants.letterPool.size()
	var retIdx = randi() % poolSize
	letter = GlobalConstants.letterPool[retIdx]
	GlobalConstants.letterPool.remove(retIdx)
	if GlobalConstants.letterPool.size() == 0:
		GlobalConstants.populate_letterPool()

func _on_LetterBox_body_entered(body):
	if body.name == "PlayerCharacter":
		if body.get_valid_slot() == -1:
			return
		body.add_letter(letter)
		queue_free()
		emit_signal("collected")
		
