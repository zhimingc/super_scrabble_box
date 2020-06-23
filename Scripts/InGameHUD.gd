extends Control

export (PackedScene) var LetterElement

var LetterList = []

func _unhandled_key_input(event):
	if event.pressed and not event.echo and event.scancode == KEY_SPACE:
		add_letter("A")

func add_letter(letter):
	var new_letter = LetterElement.instance()
	add_child(new_letter, true)
	new_letter.margin_left = 25 + LetterList.size() * 75	
	new_letter.margin_top = 25
	LetterList.append(new_letter)
	
