extends Node2D

var lettersHeldUI = []
var lettersUsedUI = []
var overlay : TextureRect
var validUI : TextureRect

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
		if x.name == "WordValid":
			validUI = x
			validUI.visible = false
		if x.name == "Overlay":
			overlay = x
			overlay.visible = false
		if x.name == "Held":
			for y in x.get_children():
				lettersHeldUI.push_back(y)
		if x.name == "Used":
			for y in x.get_children():
				lettersUsedUI.push_back(y)
	
	hide_letters()	

func _process(delta):
	if Input.is_action_just_pressed("ui_select"):
		toggle_pause()
		if (isPaused):
			update_lettersHeld(pc.get_letters())
			pc.hide_letters()
			init_wordMode()
		else:
			pc.update_letters()
			hide_letters()
	if Input.is_action_just_pressed("ui_accept") and isPaused:
		var currentWord = ""
		for i in currentLettersIdx:
			if i != null:
				currentWord += heldLetters[i].letter
		if currentWord != "" and GlobalConstants.dict.has(currentWord.to_lower()):
			print(true)

func check_word():
	var currentWord = ""
	for i in currentLettersIdx:
		if i != null:
			currentWord += heldLetters[i].letter
	if currentWord != "" and GlobalConstants.dict.has(currentWord.to_lower()):
		return true
	return false

func _unhandled_key_input(event):
	# typing letters
	if event.is_pressed() and !event.echo: 
		if event.scancode >= 65 and event.scancode <= 90:
			var newLetter = false
			var conv = PoolByteArray()
			conv.append(event.scancode)
			var keyString = conv.get_string_from_ascii()
			for i in heldLetters.size():
				var currentHeld = heldLetters[i]
				if !currentHeld.inTyping and currentHeld.letter == keyString:
					currentIdx += 1
					newLetter = true
					# update used UI
					lettersUsedUI[currentIdx].visible = true
					lettersUsedUI[currentIdx].get_node("Label").text = keyString
					currentLettersIdx[currentIdx] = i
					# update held UI
					lettersHeldUI[i].visible = false
					currentHeld.inTyping = true
					break
			if newLetter:
				update_valid()
	
		# backspace
		if event.scancode == KEY_BACKSPACE and currentIdx != -1:
			var heldIdx = currentLettersIdx[currentIdx]
			lettersUsedUI[currentIdx].visible = false
			# update held UI			
			heldLetters[heldIdx].inTyping = false
			lettersHeldUI[heldIdx].visible = true
			currentLettersIdx[currentIdx] = null
			currentIdx -= 1
			update_valid()

func update_valid():
	if check_word():
		validUI.visible = true
	else:
		validUI.visible = false

func toggle_pause():
	isPaused = !isPaused
	overlay.visible = isPaused
	get_tree().paused = isPaused	

func init_wordMode():
	for i in currentLettersIdx:
		i = -1

func hide_letters():
	currentIdx = -1
	validUI.visible = false
	for i in lettersHeldUI:
		i.visible = false
	for i in lettersUsedUI:
		i.visible = false

func update_lettersHeld(letters):
	hide_letters()
	heldLetters = letters.duplicate()
	for i in letters.size():
		heldLetters[i].inTyping = false
		lettersHeldUI[i].visible = true
		lettersHeldUI[i].get_node("Label").text = letters[i].letter