extends "res://overlap/Hitbox.gd"

export (float) var knockback_modifier: float = 0.1
export (bool) var is_knockback: bool = true

func _ready():
	pass
	$AnimatedSprite.play("default")


func _on_AnimatedSprite_animation_finished():
	match $AnimatedSprite.animation:
		"explode":
			queue_free()
		"default":
			$AnimatedSprite.play("default")
