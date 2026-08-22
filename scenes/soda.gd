extends Area2D

@onready var pickup: AudioStreamPlayer = $Pickup
@onready var game_manager: Node = %"Game Manager"


func _on_body_entered(body: Node2D) -> void:
	game_manager.add_point()
	print("+1 Soda!")
	
	# Detach audio node so it survives queue_free()
	remove_child(pickup)
	get_tree().root.add_child(pickup)
	pickup.play()
	
	# Clean up the audio node automatically when finished
	pickup.finished.connect(pickup.queue_free)
	
	queue_free()
