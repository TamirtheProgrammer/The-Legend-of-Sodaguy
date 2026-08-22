extends Control

@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound

# Prevents multiple inputs while the screen is fading or audio is playing
var is_transitioning: bool = false


func _unhandled_input(event: InputEvent) -> void:
	# Ignore all inputs if we are already loading a scene or quitting
	if is_transitioning:
		return

	if event.is_action_pressed("confirm"):
		# Consumes the input so it doesn't propagate further
		get_viewport().set_input_as_handled() 
		_on_start_game_pressed()
		
	elif event.is_action_pressed("previous"):
		get_viewport().set_input_as_handled()
		_on_exit_pressed()


func _play_confirm() -> void:
	confirm_sound.play()
	await confirm_sound.finished


func _fade_out(duration: float = 0.5) -> void:
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_rect)

	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration)
	await tween.finished


func _on_start_game_pressed() -> void:
	if is_transitioning: 
		return
	is_transitioning = true
	
	# We don't necessarily need to await the sound if we are also awaiting a 0.5s fade,
	# but awaiting both ensures the scene doesn't change before the sound finishes.
	_play_confirm() 
	await _fade_out(0.5)
	get_tree().change_scene_to_file("res://scenes/level_splash_screen.tscn")


func _on_options_pressed() -> void:
	if is_transitioning: 
		return
		
	await _play_confirm()
	print("Settings Pressed!")


func _on_exit_pressed() -> void:
	if is_transitioning: 
		return
	is_transitioning = true
	
	await _play_confirm()
	get_tree().quit()
