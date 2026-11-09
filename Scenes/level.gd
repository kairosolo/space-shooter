extends Node2D

var meteorScene: PackedScene = load("res://Scenes/meteor.tscn")
var laserScene: PackedScene = load("res://Scenes/laser.tscn")

var health: int = 3
var combo: int = 0
var elapsed_time: float = 0.0

func _ready() -> void:
	get_tree().call_group('ui', 'set_health', health)
	
	var size := get_viewport().get_visible_rect().size
	var rng := RandomNumberGenerator.new()
	for star in $Stars.get_children():
		var randomX = rng.randi_range(0, int(size.x))
		var randomY = rng.randi_range(0, int(size.y))
		star.position = Vector2(randomX, randomY)
		
		var randomScale = rng.randf_range(0.4, 0.5)
		star.scale = Vector2(randomScale, randomScale)
		star.speed_scale = rng.randf_range(0.6, 1.4)

func _process(delta: float) -> void:
	elapsed_time += delta

func _on_meteor_timer_timeout() -> void:
	var meteor = meteorScene.instantiate()
	var speed_mult: float = clampf(1.0 + (elapsed_time * 0.007), 1.0, 2.5)
	meteor.speed_multiplier = speed_mult
	
	$Meteors.add_child(meteor)
	meteor.connect('collision', _on_meteor_collision)
	meteor.connect('destroyed', _on_meteor_destroyed)

func _on_meteor_collision(meteor_pos: Vector2 = Vector2.ZERO) -> void:
	# Ignore damage if player is currently in I-frames
	if has_node("Player") and $Player.is_invulnerable:
		return

	health -= 1
	$LoseHealthSFX.play()
	
	combo = 0
	$UI.reset_combo()
	get_tree().call_group('ui', 'set_health', health)
	
	if has_node("Player"):
		if $Player.has_method("play_hit_fx"):
			$Player.play_hit_fx()
		if $Player.has_method("apply_knockback"):
			$Player.apply_knockback(meteor_pos)
		if $Player.has_method("start_invulnerability"):
			$Player.start_invulnerability()
		
	screen_shake(9.0, 0.25)
	
	if health <= 0:
		get_tree().change_scene_to_file("res://Scenes/game_over.tscn")

func screen_shake(strength: float, duration: float) -> void:
	var tween = create_tween()
	var steps = int(duration / 0.04)
	for i in steps:
		var offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		tween.tween_property(self, "position", offset, 0.04)
	tween.tween_property(self, "position", Vector2.ZERO, 0.04)

func _on_meteor_destroyed(value: int) -> void:
	combo += 1
	var score_to_add = value * combo
	$UI.update_combo(combo)
	$UI.add_score(score_to_add)

func _on_player_laser(pos: Vector2) -> void:
	var laser = laserScene.instantiate()
	laser.position = pos
	$Lasers.add_child(laser)
