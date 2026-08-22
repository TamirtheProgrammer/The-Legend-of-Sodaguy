extends Node

@onready var score_label: Label = %ScoreLabel

# Reference your AudioStreamPlayer node from the scene tree
@onready var yay_sound: AudioStreamPlayer = %Yay



var score = 0

func add_point():
	score += 1
	print(score)
	score_label.text = "Cans Collected: " + str(score)
	
	if score == 60:
		show_completion_popup()

func show_completion_popup():
	var popup = AcceptDialog.new()
	popup.title = "Goal Reached!"
	popup.dialog_text = "You collected all 60 cans!"
	
	# Play the sound effect
	yay_sound.play()
	
	# Free the node from memory when the player closes the popup
	popup.confirmed.connect(popup.queue_free)
	
	add_child(popup)
	popup.popup_centered()
