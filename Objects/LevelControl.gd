extends Node2D

export (PackedScene) var letterObj
export var letterSpawns = []

func pick_spawn():
	return randi() % letterSpawns.size()

func spawn_letter():
	var newLetter = letterObj.instance()
	
