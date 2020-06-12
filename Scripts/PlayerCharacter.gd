extends KinematicBody2D

export var runSpeed = 2.5
export var jumpForce = 100.0
export var mass = 10.0
export var drag = Vector2(0.875,0.925)

signal hit

var acceleration = Vector2()
var velocity = Vector2()
var grav_suppress = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	acceleration = Vector2()
	if Input.is_action_pressed("ui_left"):
		acceleration.x -= runSpeed
	if Input.is_action_pressed("ui_right"):
		acceleration.x += runSpeed
	if is_on_floor():
		velocity.y = 0.0		
		if Input.is_action_pressed("ui_up"):
			jump()	
	else:
		acceleration.y += GlobalConstants.gravity * mass
	
	update_jump_forces(delta)
	update_internal_forces(delta)
	
	velocity += acceleration * 100;
	var collision_info = move_and_slide(velocity * delta, Vector2.UP)
	
	# collision detection
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var groups = collision.collider.get_groups()
		if collision and groups.has("enemy"):
			die()

func update_jump_forces(delta):
	if is_on_ceiling():
		velocity.y = 0.0

func update_internal_forces(delta):
	velocity *= drag
	
func jump():
	acceleration.y -= jumpForce
	
func die():
	queue_free()

