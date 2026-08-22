extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# Check if the node entering is named "Bubbles" or belongs to the "player" group
	if body.name == "Bubbles" or body.is_in_group("player"):
		print("You Died!!!!")
		if body.has_method("die"):
			body.die()
