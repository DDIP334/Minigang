extends CharacterBody2D

const SPEED = 460.0

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()

		# Play animation when moving
		if sprite.animation != "default" or !sprite.is_playing():
			sprite.play("default")

		# Face left/right
		if direction.x > 0:
			sprite.flip_h = false
		elif direction.x < 0:
			sprite.flip_h = true
	else:
		# Stop animation when idle
		sprite.stop()

	velocity = direction * SPEED
	move_and_slide()
