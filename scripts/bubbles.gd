extends CharacterBody2D

# Movement properties
const WALK_SPEED = 200.0
const RUN_SPEED = 400.0
const JUMP_VELOCITY = -400.0

# Reference to your animation node
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# SFX Node References (AudioStreamPlayer nodes with matching node names)
@onready var run: AudioStreamPlayer = $Run
@onready var jump: AudioStreamPlayer = $Jump
@onready var hurt: AudioStreamPlayer = $Hurt
@onready var death: AudioStreamPlayer = $Death
@onready var attack: AudioStreamPlayer = $Attack

# State trackers
var is_attacking := false
var is_hurt := false
var is_dead := false
var has_played_run_sfx := false

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pause movement input while recovering from damage
	if is_hurt:
		move_and_slide()
		return

	# Handle attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		perform_attack()

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_play_sfx(jump)

	# Determine movement speed
	var current_speed = RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED
	var direction := Input.get_axis("move_left", "move_right")
	
	if is_attacking and is_on_floor():
		direction = 0.0

	# Apply movement and direction
	if direction:
		velocity.x = direction * current_speed
		anim.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()
	
	# Keep run audio synced with character movement state
	_handle_run_sfx(direction)
	update_animations(direction)

func perform_attack() -> void:
	is_attacking = true
	anim.play("attack")
	_play_sfx(attack)
	await anim.animation_finished
	is_attacking = false

# Call this method when taking damage from a hazard or enemy
func take_damage() -> void:
	if is_dead or is_hurt:
		return
	is_hurt = true
	anim.play("hurt")
	_play_sfx(hurt)
	await anim.animation_finished
	is_hurt = false

# Call this method when health reaches 0
func die() -> void:
	if is_dead:
		return
	is_dead = true
	
	# Stop horizontal movement immediately when dying
	velocity.x = 0
	
	_stop_all_sfx()
	anim.play("death")
	_play_sfx(death)
	
	# Wait for the death animation to complete, then reload scene
	await anim.animation_finished
	get_tree().reload_current_scene()

func update_animations(direction: float) -> void:
	if is_attacking or is_hurt or is_dead:
		return
		
	if not is_on_floor():
		anim.play("jump")
	elif direction != 0:
		if Input.is_action_pressed("run"):
			anim.play("run")
		else:
			anim.play("walk")
	else:
		anim.play("idle")

# Plays the run SFX once per run-button press while moving on ground
func _handle_run_sfx(direction: float) -> void:
	var is_running_on_ground = (
		is_on_floor()
		and direction != 0
		and Input.is_action_pressed("run")
		and not is_attacking
		and not is_hurt
		and not is_dead
	)
	
	# Reset state when run button is released
	if not Input.is_action_pressed("run"):
		has_played_run_sfx = false

	# Play SFX only once when starting to run
	if is_running_on_ground:
		if not has_played_run_sfx:
			run.play()
			has_played_run_sfx = true

# Helper function to play a one-shot SFX while killing looping footstep audio
func _play_sfx(sfx: AudioStreamPlayer) -> void:
	if run.playing:
		run.stop()
	sfx.play()

func _stop_all_sfx() -> void:
	run.stop()
	jump.stop()
	attack.stop()
	hurt.stop()
	death.stop()

# Killzone signal callback
func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body == self:
		die()
