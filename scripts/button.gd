extends Button

@export var game_scene_path: String = "res://scenes/base.tscn"

func _ready() -> void:
	# Connect the pressed signal to this function
	# In Godot 4, you can also connect via code
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# 1️⃣ Delete the parent node (TitleScreen)
	var title_node = get_parent()
	title_node.queue_free()

	# 2️⃣ Load and instantiate the game scene
	var game_scene: PackedScene = load(game_scene_path)
	var game_instance = game_scene.instantiate()

	# 3️⃣ Add it to the root of the scene tree
	get_tree().root.add_child(game_instance)
