extends Node2D

export (PackedScene) var gameScn

var loadedScore = 0

func _ready():
	loadData()
	if loadedScore > GlobalConstants.highscore:
		GlobalConstants.highscore = loadedScore
	$Control/HighscoreText.text = "Highscore: " + String(GlobalConstants.highscore)

func loadData():
	loadedScore = 0
	var saveData = File.new()
	if saveData.file_exists("user://data.save"):
		saveData.open("user://data.save", File.READ)
		var data = parse_json(saveData.get_line())
		loadedScore = data["highscore"]
		print(loadedScore)
		saveData.close()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		start_game()

func start_game():
	get_tree().change_scene_to(gameScn)	

func _on_StartButton_button_up():
	start_game()
