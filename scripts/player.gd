extends CharacterBody2D

# Speed constants
const X_SPEED:float = 200.0
const Y_SPEED:float = 100.0
const BUFFERED_PIXELS:int = 20
const ZOOM:float = 4.0
const Z_INDEX:int=2
const SHOT_COOLDOWN:float=0.25
var shot_timer:float=0.0

@onready var bullet_scene: PackedScene = load("res://scenes/bullet.tscn")
@onready var cam: Camera2D = $"../Camera2D"

func _ready() -> void:
	z_index=Z_INDEX
	
func _physics_process(delta: float) -> void:
	var movement:Vector2 = Vector2.ZERO

	# Horizontal movement
	if Input.is_action_pressed("move_right"):
		movement.x += 1
	if Input.is_action_pressed("move_left"):
		movement.x -= 1

	# Vertical movement
	if Input.is_action_pressed("move_down"):
		movement.y += 1
	if Input.is_action_pressed("move_up"):
		movement.y -= 1

	# Normalize to avoid faster diagonal movement
	movement = movement.normalized()
	
	# Apply speed
	movement.x *= X_SPEED
	movement.y *= Y_SPEED
	
	# Move the spaceship
	velocity = movement
	move_and_slide()
	check_collisions()
	limit_movement()
	# Shoot bullet when space is pressed
	if shot_timer > 0:
		shot_timer -= delta
	
	if Input.is_action_pressed("shoot") and shot_timer <= 0:
		shoot()
		shot_timer = SHOT_COOLDOWN
	
func limit_movement():


	# Get viewport size
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	# Half of visible world size considering zoom
	var half_screen: Vector2 = (viewport_size * 0.5) /ZOOM

	# Camera target position
	var cam_pos: Vector2 = cam.get_target_position()

	# Top-left and bottom-right world coordinates
	var top_left: Vector2 = cam_pos - half_screen + Vector2(BUFFERED_PIXELS,BUFFERED_PIXELS)
	var bottom_right: Vector2 = cam_pos + half_screen - Vector2(BUFFERED_PIXELS,BUFFERED_PIXELS)

	# Clamp spaceship position
	position.x = clamp(position.x, top_left.x, bottom_right.x)
	position.y = clamp(position.y, top_left.y, bottom_right.y)
	
func shoot():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()  # create a new bullet
		bullet.position = position  # spawn at player position
		get_parent().add_child(bullet)  # add to the scene

func check_collisions():
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var other := collision.get_collider()

		if other.is_in_group("asteroids"):
			other.queue_free()   # delete asteroid

			# Get parent node (e.g., gameplay node)
			var parent_node = get_parent()
			parent_node.queue_free()  # delete the parent safely

			# Load end scene
			var end_scene: PackedScene = load("res://scenes/end.tscn")
			var end_instance = end_scene.instantiate()

			# Add to root of scene tree
			get_tree().root.add_child(end_instance)

			return
