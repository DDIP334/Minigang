extends CharacterBody2D

const SPEED := 460.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var footsteps: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var camera: Camera2D = $Camera2D

enum Role {
	CREWMATE,
	IMPOSTOR
}

var role : Role = Role.CREWMATE
var is_dead := false
func _ready():
	camera.enabled = is_multiplayer_authority()

func _physics_process(_delta):
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

		sprite.flip_h = direction.x < 0

		if !footsteps.playing:
			footsteps.play()
	else:
		sprite.stop()
		footsteps.stop()

	velocity = direction * SPEED
	move_and_slide()
