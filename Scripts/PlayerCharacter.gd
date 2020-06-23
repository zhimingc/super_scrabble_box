extends KinematicBody2D

class_name PlayerCharacter

export var runSpeed = 2.5
export var jumpForce = 100.0
export var mass = 10.0
export var drag = Vector2(0.875,0.925)

signal player_die

var maxLetter = 6
var acceleration = Vector2()
var velocity = Vector2()
var grav_suppress = 0.0
var letterHud = []
var letterSlot = []
var hudIdx = 0

class LetterSlot:
	var inUse : bool
	var inTyping : bool
	var letter: String

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2.ZERO
	for x in get_children():
		if x.name.find("TextureRect") != -1:
			letterHud.push_back(x)
			var newSlot = LetterSlot.new()
			newSlot.inUse = false

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
	
#	# visual update
	if abs(velocity.x) > 0:
		$PC_Sprite.flip_h = velocity.x < 0

func update_jump_forces(delta):
	if is_on_ceiling():
		velocity.y *= 0.75

func update_internal_forces(delta):
	velocity *= drag
	
func jump():
	acceleration.y -= jumpForce
	
func die():
	queue_free()
	emit_signal("player_die")

func can_take_letter():
	#return get_valid_slot() != -1
	return letterSlot.size() < maxLetter;

func add_letter(letter):
	var idx = get_valid_slot()
	var newLetter = LetterSlot.new()
	newLetter.inUse = true
	newLetter.letter = letter
	letterSlot.push_back(newLetter)
	#letterSlot[idx].inUse = true
	#letterSlot[idx].letter = letter
	update_letters()
	
func get_valid_slot():
	for i in letterSlot.size():
		if letterSlot[i].inUse == false:
			return i
	return -1
	
func get_letters():
	var letters = []
	for i in letterSlot:
		if i.inUse:
			letters.push_back(i)
	return letters
	
func hide_letters():
	for i in letterHud:
		i.visible = false
	
func update_letters():
	hide_letters()
	letterSlot = get_letters()
	hudIdx = 0
	for i in letterSlot.size():
		if letterSlot[i].inUse:
			letterHud[hudIdx].visible = true
			letterHud[hudIdx].get_node("Label").text = letterSlot[i].letter
			hudIdx += 1
	
func get_closest_enemies():
	var enemies = []
	var closest = []
	enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if enemy.isDead or enemy.isTargeted:
			continue
		var dist = position.distance_to(enemy.position)
		if closest.size() == 0:
			closest.push_back(enemy)
		else:
			for i in closest.size():
				var unitDist = position.distance_to(closest[i].position)
				if dist < unitDist:
					closest.insert(i, enemy)
					break
				elif i == closest.size() - 1:
					closest.push_back(enemy)
	return closest


func _on_PlayerAreaCollision_body_entered(body):
	if body.is_in_group("enemy"):
		die()
