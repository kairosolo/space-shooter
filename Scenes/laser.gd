extends Area2D

@export var speed: float = 400

func _ready() -> void:
	$Sprite2D.scale = Vector2(0.3, 1.8)
	var tween = create_tween()
	tween.tween_property($Sprite2D, 'scale', Vector2(1.0, 1.0), 0.12)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	position.y -= speed * delta
