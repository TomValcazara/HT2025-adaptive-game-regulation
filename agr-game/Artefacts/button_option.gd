extends TextureButton

var textures := {
	"purple": preload("res://Assets/Images/BubblePurple.png"),
	"green": preload("res://Assets/Images/BubbleGreen.png"),
	"yellow": preload("res://Assets/Images/BubbleYellow.png"),
	"orange": preload("res://Assets/Images/BubbleOrange.png"),
	"pink": preload("res://Assets/Images/BubblePink.png"),
	"blue": preload("res://Assets/Images/BubbleBlue.png"),
	"red": preload("res://Assets/Images/BubbleRed.png"),
	"poped": preload("res://Assets/Images/BubblePoped.png"),
}
func funcChangeColor(_color) -> void:
	$".".texture_normal = textures[_color]

func bubble_movement_speed(intensity: int):
	
	intensity = clamp(intensity, 1, 9)

	var offset := 6.0 * intensity
	var time := 2.5 / (0.5 + intensity * 0.15)

	var dir := Vector2(
	randf_range(-1.0, 1.0),
	randf_range(-1.0, 1.0)
	).normalized()

	var base_pos = $".".position
	var target = base_pos + dir * offset

	var tween := $".".create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property($".", "position", target, time)
	tween.tween_property($".", "position", base_pos, time)
