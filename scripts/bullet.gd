extends CharacterBody2D

@onready var cam:Camera2D = get_node("../Camera2D")

const SPEED: float = 200.0
const ZOOM:float = 4.0
const BUFFERED_PIXELS:int = 30
const Z_INDEX:int=1

func _ready() -> void:
	z_index=Z_INDEX
	
func _physics_process(delta: float) -> void:
	# Move the bullet upward using physics
	var collision = move_and_collide(Vector2(0, -SPEED * delta))
	
	# Optional: handle collision

	# Remove bullet if off-screen
	remove_offscreen()

func remove_offscreen():
	# Get viewport size
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	# Half of visible world size considering zoom
	var half_screen: Vector2 = (viewport_size * 0.5) * 1/ZOOM
	
	# Camera target position
	var cam_pos: Vector2 = cam.get_target_position()
	
	# Top-left and bottom-right world coordinates
	var top_left: Vector2 = cam_pos - half_screen
	if position.y < top_left.y-BUFFERED_PIXELS:  # above the top of the screen
		queue_free()
