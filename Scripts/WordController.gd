extends Node2D

var lettersHeldUI = []
var lettersUsedUI = []

class_name PlayerCharacter

var pc : PlayerCharacter
var isPaused = false
var currentIdx = -1
var currentLettersIdx = []
var heldLetters = []

func _ready():
	currentLettersIdx.resize(6)	
	pc = get_parent().get_node("PlayerCharacter")
	for x in get_children():
		if x.name == "Held":
			for y in x.get_children():
				lettersHeldUI.push_back(y)
		if x.name == "Used":
			for y in x.get_children():
				lettersUsedUI.push_back(y)
	
	hide_letters()	

func _process(delta):
	if Input.is_action_just_pressed("ui_select"):
		isPaused = !isPaused
		get_tree().paused = isPaused
		if (isPaused):
			update_lettersHeld(pc.get_letters())
			pc.hide_letters()
		else:
			pc.update_letters()
			hide_letters()

func _unhandled_key_input(event):
	# typing letters
	if event.is_pressed() and !event.echo: 
		if event.scancode >= 65 and event.scancode <= 90:
			var conv = PoolByteArray()
			conv.append(event.scancode)
			var keyString = conv.get_string_from_ascii()
			for i in heldLetters.size():
				var currentHeld = heldLetters[i]
				if !currentHeld.inTyping and currentHeld.letter == keyString:
					currentIdx += 1
					# update used UI
					lettersUsedUI[currentIdx].visible = true
					lettersUsedUI[currentIdx].get_node("Label").text = keyString
					currentLettersIdx[currentIdx] = i
					# update held UI
					lettersHeldUI[i].visible = false
					currentHeld.inTyping = true
					break
	
		# backspace
		if event.scancode == KEY_BACKSPACE and currentIdx != -1:
			var heldIdx = currentLettersIdx[currentIdx]
			lettersUsedUI[currentIdx].visible = false
			# update held UI			
			heldLetters[heldIdx].inTyping = false
			lettersHeldUI[heldIdx].visible = true
			currentLettersIdx[currentIdx] = -1
			currentIdx -= 1

func init_wordMode():
	for i in currentLettersIdx:
		i = -1

func hide_letters():
	for i in lettersHeldUI:
		i.visible = false
	for i in lettersUsedUI:
		i.visible = false

func update_lettersHeld(letters):
	hide_letters()
	heldLetters = letters.duplicate(true)
	for i in letters.size():
		heldLetters[i].inTyping = false
		lettersHeldUI[i].visible = true
		lettersHeldUI[i].get_node("Label").text = letters[i].letter