extends Node2D

export (PackedScene) var gameScn

var clearButton : Button
var loadedScore = 0
var highScoreExist = false

func _ready():
	clearButton = $Control/ClearButton
	loadData()
	if loadedScore > GlobalConstants.highscore:
		GlobalConstants.highscore = loadedScore
	set_score(GlobalConstants.highscore)

func loadData():
	loadedScore = 0
	var saveData = File.new()
	if saveData.file_exists("user://data.save"):
		saveData.open("user://data.save", File.READ)
		var data = parse_json(saveData.get_line())
		loadedScore = data["highscore"]
		clearButton.visible = true
		saveData.close()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		start_game()

func start_game():
	#GlobalConstants.emit_signal("play_sfx", "wm_appear")
	$Control/StartInstruction.visible = false
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().change_scene_to(gameScn)	

func set_score(score):
	$Control/HighscoreText.text = "Highscore: " + String(score)

func _on_ClearButton_button_up():
	var saveData = File.new()
	saveData.open("user://data.save", File.WRITE)
	var savedScore = { "highscore": 0 }
	saveData.store_line(to_json(savedScore))
	saveData.close()
	clearButton.visible = false
	GlobalConstants.highscore = 0
	set_score(0)
