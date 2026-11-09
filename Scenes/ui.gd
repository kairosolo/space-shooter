extends CanvasLayer

static var image = load("res://Kenney Space Shooter/PNG/UI/playerLife1_orange.png")

@onready var score_label: Label = $MarginContainer/VBoxContainer/Label
@onready var combo_label: Label = $MarginContainer/VBoxContainer/Label2

var score: int = 0

func _ready() -> void:
	await get_tree().process_frame
	score_label.pivot_offset = score_label.size / 2.0
	combo_label.pivot_offset = combo_label.size / 2.0
	combo_label.modulate.a = 0.0
	combo_label.text = ""

func update_combo(combo: int) -> void:
	if combo < 2:
		return
		
	combo_label.text = "%dx COMBO!" % combo
	combo_label.pivot_offset = combo_label.size / 2.0
	
	var hue = clampf(0.14 - (combo * 0.008), 0.0, 0.14)
	combo_label.modulate = Color.from_hsv(hue, 0.85, 1.2, 1.0)
	
	var punch_scale = clampf(1.2 + (combo * 0.04), 1.2, 1.7)
	combo_label.scale = Vector2(punch_scale, punch_scale)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(combo_label, "scale", Vector2.ONE, 0.22)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(combo_label, "modulate:a", 1.0, 0.1)

func reset_combo() -> void:
	if combo_label.text == "" or combo_label.modulate.a <= 0.01:
		return
	
	combo_label.text = "COMBO LOST"
	combo_label.modulate = Color(1.0, 0.2, 0.2, 1.0)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(combo_label, "scale", Vector2(0.6, 0.6), 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	tween.tween_property(combo_label, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(func(): combo_label.text = "")

func set_health(amount: int) -> void:
	var container = $MarginContainer2/HBoxContainer
	var current_hearts = container.get_children().filter(func(child): return !child.is_queued_for_deletion())
	var current_count = current_hearts.size()
	
	if current_count == 0:
		for i in amount:
			_create_heart(i * 0.05)
		return

	if amount < current_count:
		var lost_count = current_count - amount
		for i in range(lost_count):
			var heart = current_hearts[current_count - 1 - i]
			_animate_heart_lost(heart)
	elif amount > current_count:
		for i in range(amount - current_count):
			_create_heart(0.0)

func _create_heart(delay: float) -> void:
	var container = $MarginContainer2/HBoxContainer
	var text_rect = TextureRect.new()
	text_rect.texture = image
	text_rect.stretch_mode = TextureRect.STRETCH_KEEP
	container.add_child(text_rect)
	
	var img_size = image.get_size()
	text_rect.pivot_offset = img_size / 2.0
	text_rect.scale = Vector2.ZERO
	
	var tween = create_tween()
	if delay > 0:
		tween.tween_interval(delay)
	tween.tween_property(text_rect, "scale", Vector2.ONE, 0.25)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _animate_heart_lost(heart: TextureRect) -> void:
	var tween = create_tween().set_parallel(true)
	var random_rotation = deg_to_rad(randf_range(-30, 30))
	
	tween.tween_property(heart, "scale", Vector2(1.5, 1.5), 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(heart, "rotation", random_rotation, 0.25)
	tween.tween_property(heart, "modulate", Color(1.0, 0.1, 0.1, 0.0), 0.25)
	
	tween.chain().tween_callback(heart.queue_free)

func _on_spawn_timer_timeout() -> void:
	score += 1
	Global.score += score
	score_label.text = str(Global.score)
	_pop_score_label(1.15)

func add_score(amount: int) -> void:
	Global.score += amount
	score_label.text = str(Global.score)
	_pop_score_label(1.35)

func _pop_score_label(peak_scale: float) -> void:
	score_label.pivot_offset = score_label.size / 2.0
	
	var tween = create_tween().set_parallel(true)
	score_label.scale = Vector2(peak_scale, peak_scale)
	score_label.modulate = Color(1.4, 1.3, 0.5, 1.0)
	
	tween.tween_property(score_label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(score_label, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
