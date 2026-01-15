extends RigidBody2D

const min_speed: int = 100
const max_speed:int = 400
const max_angular_speed:float=15.0
const ZOOM:float=4.0

func _ready():
	contact_monitor = true          # Enable collision detection for signals
	max_contacts_reported = 10
	self.body_entered.connect(_on_body_entered)
	angular_velocity = randf_range(-max_angular_speed, max_angular_speed)
	# Random rotation
	rotation = randf_range(-PI, PI)

	# Move straight down
	linear_velocity = Vector2(0, randi_range(min_speed,max_speed))

func _process(_delta):
	# Destroy if below screen
	var viewport_height = get_viewport().get_visible_rect().size.y/ZOOM
	if global_position.y > viewport_height + 50: # 50 pixels buffer
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("bullets"):
		body.queue_free()      # Destroy the bullet
	# Add score
		var game_manager = get_parent().get_parent().get_node("GameManager")
		game_manager.add_score(10)  # Add 10 points per asteroid
		queue_free()           # Destroy this asteroid
