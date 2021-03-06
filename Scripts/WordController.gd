extends Node2D

export (PackedScene) var LetterAttack

var lettersHeldUI = []
var lettersUsedUI = []
var overlay : Node2D
var validUI : TextureRect

var player
var isPaused = false
var oldPause = false
var wordIsValid = false
var currentIdx = -1
var currentLettersIdx = []
var heldLetters = []
var enemies = []

signal word_attack(word)

func _ready():
	currentLettersIdx.resize(6)	
	player = get_parent().get_node("PlayerCharacter")
	for x in get_children():
		if x.name == "WordValid":
			validUI = x
			validUI.visible = false
		if x.name == "OverlayNode":
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
	#if Input.is_action_just_pressed("ui_select"):
	#	toggle_pause()

	if Input.is_action_just_pressed("ui_accept") and is_instance_valid(player):
		if isPaused:
			if wordIsValid:
				toggle_pause()
				#emit_signal("wordAttack", get_current_word())
				word_attack(get_current_word())
				# delete letters used
				for i in currentLettersIdx:
					if i != null:
						heldLetters[i].inUse = false
				player.update_letters()
				update_lettersHeld(player.get_letters())
			else:
				toggle_pause()
		else:
			toggle_pause()
	
	# update ui one frame slower to avoid pause stopping behaviour
	if oldPause != isPaused:
		oldPause = isPaused
		if (isPaused):
			update_lettersHeld(player.get_letters())
			player.hide_letters()
			init_wordMode()
		else:
			player.update_letters()
			hide_letters()

func get_current_word():
	var currentWord = ""
	for i in currentLettersIdx:
		if i != null:
			currentWord += heldLetters[i].letter
	return currentWord

func check_word():
	var currentWord = get_current_word()
	if currentWord != "" and GlobalConstants.dict.has(currentWord.to_lower()):
		return true
	return false

func _unhandled_key_input(event):
	# typing letters
	if event.is_pressed() and !event.echo and isPaused: 
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
	var word = get_current_word()
	wordIsValid = check_word()
	if wordIsValid:
		validUI.visible = true
		$Instruct_0.visible = true
		for i in enemies.size():
			if i < word.length():
				enemies[i].set_targeted(true)
			else:
				enemies[i].set_targeted(false)
	else:
		$Instruct_0.visible = false		
		validUI.visible = false
		for i in enemies:
			i.set_targeted(false)
			
	GlobalConstants.emit_signal("play_sfx_pitch", "type", 1 + word.length() * .1)

func toggle_pause():
	isPaused = !isPaused
	overlay.visible = isPaused
	get_tree().paused = isPaused	
	if isPaused:
		enemies = player.get_closest_enemies()	
		GlobalConstants.emit_signal("play_sfx", "wm_appear")
	else:
		GlobalConstants.emit_signal("play_sfx", "wm_disappear")		

func init_wordMode():
	for i in currentLettersIdx.size():
		currentLettersIdx[i] = null

func hide_letters():
	currentIdx = -1
	validUI.visible = false
	$Instruct_1.visible = false
	$Instruct_0.visible = false	
	for i in lettersHeldUI:
		i.visible = false
	for i in lettersUsedUI:
		i.visible = false

func update_lettersHeld(letters):
	hide_letters()
	heldLetters = letters.duplicate()
	$Instruct_1.visible = letters.size() == 0
		
	for i in letters.size():
		heldLetters[i].inTyping = false
		lettersHeldUI[i].visible = true
		lettersHeldUI[i].get_node("Label").text = letters[i].letter
		
func word_attack(word):
	for i in word.length():
		if i >= enemies.size():
			break
		var newAttack = LetterAttack.instance()
		newAttack.position = player.position
		newAttack.init(enemies[i], word[i])
		add_child(newAttack)
		enemies[i].isTargeted = true
		
		# layered sfx
		yield(get_tree().create_timer(0.125), "timeout")
		GlobalConstants.emit_signal("play_sfx", "pew")
