extends Sprite2D

# Path to your main game scene
@export_file("*.tscn") var target_scene_path: String = "res://scenes/game.tscn"

# Display time in seconds
@export var display_time: float = 5.0

func _ready() -> void:
	# Wait for 5 seconds using a one-shot SceneTree timer
	await get_tree().create_timer(display_time).timeout
	
	_change_to_game_scene()

func _unhandled_input(event: InputEvent) -> void:
	# Optional: Allow players to skip the splash screen with any key press or click
	if event.is_pressed():
		_change_to_game_scene()

func _change_to_game_scene() -> void:
	if ResourceLoader.exists(target_scene_path):
		get_tree().change_scene_to_file(target_scene_path)
	else:
		push_error("Target scene path not found: " + target_scene_path)
