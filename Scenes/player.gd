extends CharacterBody2D

@export var speed: int = 500
@export var knockback_strength: float = 750.0
@export var invulnerability_duration: float = 1.0

var canShoot: bool = true
var is_invulnerable: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var invuln_tween: Tween

signal laser(pos)

func _process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = (direction * speed) + knockback_velocity
	move_and_slide()
	
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 2800.0 * delta)
	
	var viewport_size = get_viewport_rect().size
	global_position = global_position.clamp(Vector2.ZERO, viewport_size)
	
	if Input.is_action_pressed("laser") and canShoot:
		laser.emit($FirePoint.global_position)
		$LaserSFX.play()
		canShoot = false
		play_shoot_recoil()
		if has_node("Timer"):
			$Timer.start()

func _on_timer_timeout() -> void:
	canShoot = true

func apply_knockback(from_position: Vector2) -> void:
	var knock_dir = (global_position - from_position).normalized()
	if knock_dir == Vector2.ZERO:
		knock_dir = Vector2.DOWN
	knockback_velocity = knock_dir * knockback_strength

func start_invulnerability() -> void:
	is_invulnerable = true
	
	if invuln_tween and invuln_tween.is_valid():
		invuln_tween.kill()
		
	invuln_tween = create_tween()
	
	modulate = Color(2.5, 0.3, 0.3, 1.0)
	invuln_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.25), 0.15)
	
	var remaining_time = maxf(0.1, invulnerability_duration - 0.15)
	var blinks = int(remaining_time / 0.1)
	for i in range(blinks):
		invuln_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.25), 0.05)
		invuln_tween.tween_property(self, "modulate", Color.WHITE, 0.05)
		
	invuln_tween.tween_callback(func():
		is_invulnerable = false
		modulate = Color.WHITE
	)

func play_shoot_recoil() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.88, 1.15), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func play_hit_fx() -> void:
	var tween = create_tween()
	scale = Vector2(1.35, 0.7)
	tween.tween_property(self, "scale", Vector2.ONE, 0.35)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
