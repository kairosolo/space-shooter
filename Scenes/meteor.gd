extends Area2D

@export var textureList: Array[Texture2D] = []
@export var minSpeed: int = 400
@export var maxSpeed: int = 900
@export var value: int = 50
@export var speed_multiplier: float = 1.0

var speed: float
var rotationSpeed: float
var directionX: float

signal collision(meteor_pos: Vector2)
signal destroyed(value: int)

var is_destroyed := false
var canCollide := true

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	$MeteorImage.texture = textureList.pick_random()

	var viewport_size := get_viewport_rect().size
	position = Vector2(
		rng.randf_range(0, viewport_size.x),
		rng.randf_range(-150, -50)
	)

	speed = rng.randi_range(minSpeed, maxSpeed) * speed_multiplier
	rotationSpeed = rng.randi_range(-100, 100) * speed_multiplier
	directionX = rng.randi_range(-1, 1)

	$MeteorImage.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property($MeteorImage, "scale", Vector2.ONE, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	if is_destroyed:
		return

	position += Vector2(directionX, 1.0) * speed * delta
	rotation_degrees += rotationSpeed * delta

func _on_body_entered(_body: Node2D) -> void:
	if is_destroyed or not canCollide:
		return
	collision.emit(global_position)
	explode(false)

func _on_area_entered(area: Area2D) -> void:
	if is_destroyed:
		return
	if is_instance_valid(area):
		area.queue_free()
	explode(true)

func explode(award_points: bool = true) -> void:
	if is_destroyed:
		return

	is_destroyed = true
	canCollide = false

	if award_points:
		destroyed.emit(value)

	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	$ExplosionSound.play()

	var tween = create_tween().set_parallel(true)
	tween.tween_property($MeteorImage, "scale", Vector2(1.3, 1.3), 0.08)
	tween.tween_property($MeteorImage, "modulate:a", 0.0, 0.08)
	await tween.finished
	$MeteorImage.hide()

	await $ExplosionSound.finished
	queue_free()
