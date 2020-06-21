extends KinematicBody2D

export var speed = 75
export var mass = 1
export var deathForce = 250
var moveDir = 1
var velocity = Vector2()
var accelScale = 100
var bounce = 5
var wallBounce = 0
var isDead = false
var isTargeted = false
var isBuff = false

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
	elif !isDead:
		velocity.y = 0
	if is_on_wall():
		moveDir = -moveDir
		wallBounce = bounce	
		
	velocity.x = (speed + wallBounce) * moveDir * accelScale
	velocity.y += acceleration.y * accelScale
	move_and_slide(velocity * delta, Vector2.UP)

func _process(delta):
	if position.y > get_viewport_rect().size.y + 25:
		if isDead:
			die()
		else:
			emit_signal("respawn", self)
	
	# debug
	#if Input.is_action_just_pressed("ui_accept"):
	#	set_dead()
		
func set_dead():
	isDead = true
	moveDir = -1 if position.x < 1080 / 2.0 else 1
	speed *= 2
	$CollisionShape2D.queue_free()
	$AnimatedSprite.flip_v = true
	velocity.y -= deathForce * accelScale
	
func die():
	queue_free()

func set_buff():
	if isBuff: 
		return
	speed *= 2.0
	$AnimatedSprite.set_modulate(Color.coral)
	isBuff = true
