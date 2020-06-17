extends Node2D

export (PackedScene) var Player
export (PackedScene) var Enemy_Basic
export (PackedScene) var LetterBox

var dictionaryPath = "res://scrabbleDict.txt"
var letterSpawns = []
var oldLetterSpawn = -1

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
	$EnemyTimer.connect("timeout", self, "spawn_enemy")
	letterSpawns = $LetterSpawns.get_children()
	spawn_letterBox()

func _unhandled_key_input(event):
	if !event.echo:
		if event.pressed:
			if event.scancode == KEY_T:
				debug_spawn_player()
			if event.scancode == KEY_E:
				spawn_enemy()
			if event.scancode == KEY_Q:
				if $PlayerCharacter.can_take_letter():
					$PlayerCharacter.add_letter("A")
			if event.scancode == KEY_R:
				spawn_letterBox()

func debug_spawn_player():
	var newPlayer = Player.instance()
	newPlayer.position = $Spawner.position
	add_child(newPlayer, true)
	
func spawn_enemy():
	var newEnemy = Enemy_Basic.instance()
	newEnemy.position = $Spawner.position
	newEnemy.connect("respawn", self, "respawn_enemy")	
	add_child(newEnemy, true)
	
func respawn_enemy(obj):
	obj.position = $Spawner.position
	
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
	add_child(newBox)
			