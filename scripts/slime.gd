extends Node2D

# Movement configuration
@export var speed: float = 60.0
var direction: int = 1 # 1 = right, -1 = left

# Node References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

func _process(delta: float) -> void:
	# Detect walls or ledges to turn around
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

	# Move using simple position offset
	position.x += direction * speed * delta

# Connect the body_entered signal from your internal Killzone Area2D to this function
func _on_killzone_body_entered(body: Node2D) -> void:
	if body.name == "Bubbles" or body.is_in_group("player"):
		if body.has_method("die"):
			body.die()
