extends Node2D

var target : KinematicBody2D
var speed = 750

func init(newTarget, letter):
	target = newTarget
	$TextureRect/Label.text = letter
	
func _physics_process(delta):
	var dir = target.position - position
	position += dir.normalized() * speed * delta

func _on_LetterAttack_body_entered(body):
	if body == target:
		body.set_dead()
		queue_free()
