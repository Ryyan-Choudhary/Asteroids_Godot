extends Node2D

@export var asteroid_scene: PackedScene       # Assign your Asteroid.tscn here
var spawn_rate: float = 1.0                   # Seconds between spawns
const x_padding: float = 25
@export var cam: Camera2D                     # Reference to your camera
const ZOOM: float = 4.0
const BUFFERED_PIXELS: int = 32

# Difficulty parameters
const difficulty_interval: float = 30.0       # Every 30 seconds
const spawn_increase: float = 0.1             # Decrease spawn_rate by 0.1
var difficulty_timer: float = difficulty_interval

var timer: float = 0.0

func _process(delta: float) -> void:
	# Countdown to next asteroid spawn
	timer -= delta
	if timer <= 0:
		spawn_asteroid()
		timer = spawn_rate

	# Countdown to difficulty increase
	difficulty_timer -= delta
	if difficulty_timer <= 0:
		# Make spawning faster (reduce spawn_rate)
		spawn_rate = max(0.1, spawn_rate - spawn_increase)  # don't go below 0.1 sec
		difficulty_timer = difficulty_interval  # reset difficulty timer
		print("Spawn rate increased! New spawn rate: ", spawn_rate)

func spawn_asteroid():
	if not asteroid_scene:
		return

	var asteroid = asteroid_scene.instantiate()

	var limits = get_limits()
	var top_left = limits["top_left"]
	var bottom_right = limits["bottom_right"]

	# Random x within camera bounds with padding
	var x_pos = randf_range(top_left.x + x_padding, bottom_right.x - x_padding)
	
	# y stays above the top of the screen
	var y_pos = top_left.y - 150  # spawn 50 pixels above camera

	asteroid.global_position = Vector2(x_pos, y_pos)
	add_child(asteroid)

func get_limits() -> Dictionary:
	# Get viewport size
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	# Half of visible world size considering zoom
	var half_screen: Vector2 = (viewport_size * 0.5) / ZOOM

	# Camera target position
	var cam_pos: Vector2 = cam.get_target_position()

	# Top-left and bottom-right world coordinates
	var top_left: Vector2 = cam_pos - half_screen + Vector2(BUFFERED_PIXELS, BUFFERED_PIXELS)
	var bottom_right: Vector2 = cam_pos + half_screen - Vector2(BUFFERED_PIXELS, BUFFERED_PIXELS)

	return {
		"top_left": top_left,
		"bottom_right": bottom_right
	}
