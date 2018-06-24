extends Area2D

func _ready():
	connect("body_entered", self, "checkCollected")
	$Tween.connect("tween_completed", self, "die")
	$Tween.interpolate_property($Sprite, "modulate", Color(1.0, 1.0, 1.0), Color(0.0, 0.0, 0.0), 6.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Sprite, "scale", Vector2(1.0, 1.0), Vector2(0.5, 0.5), 6.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Sprite, "rotation", 0.0, randf() - 0.5, 6.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$FallTween.interpolate_property($Sprite, "position", Vector2(6.0, -16.0), Vector2(6.0, -2.0), 0.25, Tween.TRANS_EXPO, Tween.EASE_IN)
	$FallTween.start()

func die(obj, key):
	queue_free()

func checkCollected(body):
	if body == get_parent().get_parent().player:
		if body.collect(self):
			queue_free()