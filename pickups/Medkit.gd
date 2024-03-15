extends Area2D

export (int) var health_value = 25

# check if the boy has method heal:
func _on_Medkit_body_entered(body):
	if body.has_method("heal"):
		body.heal(health_value)
		queue_free()
