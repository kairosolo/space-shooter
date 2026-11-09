extends Control

@export var level_scene_path: String = "res://Scenes/level.tscn"
@export var hold_duration: float = 1.0 
@export var max_scale: float = 1.35

@onready var restart_label: Label = $MarginContainer/Label
@onready var score_label: Label = $CenterContainer/VBoxContainer/Label2

var hold_timer: float = 0.0
var is_restarting: bool = false

func _ready() -> void:
	score_label.text = "Score: " + str(Global.score)
	
	await get_tree().process_frame
	restart_label.pivot_offset = restart_label.size / 2.0
	restart_label.text = "HOLD [SPACE] TO RESTART"

func _process(delta: float) -> void:
	if not restart_label or is_restarting:
		return

	var is_holding = Input.is_action_pressed("laser") or Input.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE)

	if is_holding:
		hold_timer += delta
		var progress = clampf(hold_timer / hold_duration, 0.0, 1.0)
		
		var current_scale = lerpf(1.0, max_scale, progress)
		restart_label.scale = Vector2(current_scale, current_scale)
		
		restart_label.rotation_degrees = randf_range(-2.5, 2.5) * progress
		
		restart_label.modulate = Color.WHITE.lerp(Color(2.2, 1.5, 0.4, 1.0), progress)
		
		if progress >= 1.0:
			_trigger_restart()
	else:
		if hold_timer > 0.0:
			hold_timer = 0.0
			_release_cancel()

func _release_cancel() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(restart_label, "scale", Vector2.ONE, 0.25)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(restart_label, "rotation_degrees", 0.0, 0.1)
	tween.tween_property(restart_label, "modulate", Color.WHITE, 0.2)

func _trigger_restart() -> void:
	is_restarting = true
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(restart_label, "scale", Vector2(1.6, 1.6), 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(restart_label, "rotation_degrees", 0.0, 0.1)
	tween.tween_property(restart_label, "modulate", Color(3.0, 3.0, 3.0, 1.0), 0.15)
	
	await tween.finished
	
	Global.score = 0
	get_tree().change_scene_to_file(level_scene_path)
