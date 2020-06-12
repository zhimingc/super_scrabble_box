extends KinematicBody2D

export var speed = 75
export var mass = 1
var moveDir = 1
var velocity = Vector2()
var accelScale = 100
var bounce = 5
var wallBounce = 0

signal respawn(obj)

# Called when the node enters the scene tree for the first time.
func _ready():
	moveDir = 1 if randi() % 2 == 1 else -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var acceleration = Vector2()
	wallBounce = 0
	
	if !is_on_floor():
		acceleration.y += GlobalConstants.gravity * mass
	else:
		velocity.y = 0
	if is_on_wall():
		moveDir = -moveDir
		wallBounce = bounce	
		
	velocity.x = (speed + wallBounce) * moveDir * accelScale
	velocity.y += acceleration.y * accelScale
	move_and_slide(velocity * delta, Vector2.UP)

func _process(delta):
	if position.y > get_viewport_rect().size.y + 25:
		emit_signal("respawn", self)
