extends CharacterBody2D

const SPEED = 460.0

@onready var sprite = $AnimatedSprite2D
@onready var footsteps = $AudioStreamPlayer2D

var current_room = ""


func _ready():
	$Camera2D.enabled = is_multiplayer_authority()


func _physics_process(delta):

	# Only the owner can control this player
	if !is_multiplayer_authority():
		return

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

		if !sprite.is_playing():
			sprite.play("default")

		if direction.x > 0:
			sprite.flip_h = false
		elif direction.x < 0:
			sprite.flip_h = true

		if !footsteps.playing:
			footsteps.play()

	else:

		sprite.stop()
		footsteps.stop()

	velocity = direction * SPEED
	move_and_slide()


func _on_communication_body_entered(body):
	pass


func _on_observation_body_entered(body):
	pass
