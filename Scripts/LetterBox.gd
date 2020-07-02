extends Area2D

var letter = "A"
var retIdx = 0

signal collected

func _ready():
	randomize()
	var poolSize = GlobalConstants.letterPool.size()
	while true:
		get_letter_from_pool()
		remove_letter_from_pool()
		if valid_letter():
			break

func _unhandled_key_input(event):
	#debug
	if !event.echo:
		if event.pressed:
			if event.scancode == KEY_C:
				for i in 50:
					get_letter_from_pool()
					remove_letter_from_pool()

func _on_LetterBox_body_entered(body):
	if body.name == "PlayerCharacter":
		if !body.can_take_letter():
			return
		body.add_letter(letter)
		queue_free()
		emit_signal("collected")
		GlobalConstants.emit_signal("play_sfx", "pickup")
		

func get_letter_from_pool():
	var poolSize = GlobalConstants.letterPool.size()
	retIdx = randi() % poolSize
	letter = GlobalConstants.letterPool[retIdx]
	
func remove_letter_from_pool():
	GlobalConstants.letterPool.remove(retIdx)
	if GlobalConstants.letterPool.size() == 0:
		GlobalConstants.populate_letterPool()

func is_vowel():
	for v in GlobalConstants.vowels:
		if v == letter:
			return true
	return false
	
func valid_letter():
	var pastLetters = GlobalConstants.isVowelWindow
	var curVowel = is_vowel()
	if pastLetters[0] == false and pastLetters[1] == false and !curVowel:
		return false
	if pastLetters[0] == true and pastLetters[1] == true and curVowel:
		return false
	pastLetters[0] = pastLetters[1]
	pastLetters[1] = curVowel
	return true
