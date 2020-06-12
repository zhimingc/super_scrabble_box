extends Node2D

export (PackedScene) var Player
export (PackedScene) var Enemy_Basic

func _ready():
	$EnemyTimer.connect("timeout", self, "spawn_enemy")

func _unhandled_key_input(event):
	if !event.echo:
		if event.pressed:
			if event.scancode == KEY_SPACE:
				debug_spawn_player()
			if event.scancode == KEY_E:
				spawn_enemy()

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