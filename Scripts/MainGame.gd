extends Node2D

export (PackedScene) var Player
export (PackedScene) var Enemy_Basic
export (PackedScene) var LetterBox
export (PackedScene) var BG_Cloud

var pc
var dictionaryPath = "res://scrabbleDict.txt"
var letterSpawns = []
var oldLetterSpawn = -1
var score = 0
var gameover = false

# bg vars
var cloudRate = [ 8, 16 ]
var cloudTimer = 0

func _init():
	GlobalConstants.populate_letterPool()
	load_dict(dictionaryPath)

func load_dict(file):
	var f = File.new()
	f.open(file, File.READ)
	var index = 1
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		GlobalConstants.dict[line.to_lower()] = 0
	f.close()

func _ready():
	pc = $PlayerCharacter
	$EnemyTimer.connect("timeout", self, "spawn_enemy")
	letterSpawns = $LetterSpawns.get_children()
	spawn_letterBox()
	update_score_display()	

func _process(delta):
	update_bg(delta)

func _unhandled_key_input(event):
	if !event.echo:
		if event.pressed:
			if event.scancode == KEY_R:
				if gameover:
					reload_game()					
			if event.scancode == KEY_ESCAPE:
				if GlobalConstants.highscore < score:
					GlobalConstants.highscore = score
				get_tree().change_scene("res://Scenes/MainMenu.tscn")
			if event.scancode == KEY_SPACE:
				$UI/Instruct_0.visible = false	
			
			return # deactivates debug	
			if event.scancode == KEY_T:
				debug_spawn_player()
			if event.scancode == KEY_E:
				spawn_enemy()
			if event.scancode == KEY_S:
				for i in 6:
					# layered sfx
					yield(get_tree().create_timer(0.125), "timeout")
					GlobalConstants.emit_signal("play_sfx", "pew")
				#$MainCamera.trigger_shake_cam(0.25)

func reload_game():
	get_tree().reload_current_scene()

func debug_spawn_player():
	var newPlayer = Player.instance()
	newPlayer.position = $Spawner.position
	add_child(newPlayer, true)
	
func spawn_enemy():
	var newEnemy = Enemy_Basic.instance()
	newEnemy.position = $Spawner.position
	newEnemy.connect("respawn", self, "respawn_enemy")	
	newEnemy.connect("got_hit", self, "trigger_cam_shake")
	add_child(newEnemy, true)
	$SoundEffects.play_sound("enemySpawn")
	if $EnemyTimer.wait_time > 2.5:
		$EnemyTimer.wait_time -= 0.25

func trigger_cam_shake():
	$MainCamera.trigger_shake_cam(0.25)

func respawn_enemy(obj):
	obj.position = $Spawner.position
	obj.set_buff()
	$SoundEffects.play_sound("enemyRespawn")
	
func spawn_letterBox():
	var spawnIdx = 0
	while true:
		spawnIdx = randi() % letterSpawns.size()
		if spawnIdx != oldLetterSpawn:
			oldLetterSpawn = spawnIdx
			break
	var newBox = LetterBox.instance()
	newBox.position = letterSpawns[spawnIdx].position
	newBox.connect("collected", self, "spawn_letterBox")
	newBox.connect("collected", self, "add_score")
	call_deferred("add_child", newBox)

func add_score():
	score += 1
	update_score_display()
	
func update_score_display():
	$ScoreDisplay.text = String(score)

func update_bg(delta):
	cloudTimer -= delta
	if cloudTimer <= 0:
		spawn_cloud()
		cloudTimer = cloudRate[0] + randi() % (cloudRate[1] - cloudRate[0])

func spawn_cloud():
	var newCloud = BG_Cloud.instance()
	newCloud.position = Vector2(-55, 50 + randi() % 200)
	add_child(newCloud) 

func _on_PlayerCharacter_player_die():
	gameover = true
	$UI/Restart.visible = true
	saveData()
	
func saveData():
	if GlobalConstants.highscore < score:
		var saveData = File.new()
		saveData.open("user://data.save", File.WRITE)
		var savedScore = { "highscore": score }
		saveData.store_line(to_json(savedScore))
		saveData.close()
		
