extends Node2D

export (Array, Texture) var cloudSprites = []
export var speed = [ 15, 30 ]

var moveSpeed = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	var idx = randi() % 2
	$Sprite.texture = cloudSprites[idx]
	moveSpeed = speed[0] + randi() % (speed[1] - speed[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += moveSpeed * delta
	pass
