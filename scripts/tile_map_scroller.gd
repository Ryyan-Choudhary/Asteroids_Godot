extends Node2D

const ZOOM: float = 4.0
const BUFFERED_PIXELS: int = 0
const SOURCE_ID=0
const TILE_COUNT=1
const scroll_interval:float = 0.1
var scroll_timer:float=0
const ATLAS_LIM_END:int=3
const ATLAS_LIM_START:int=0
const FRAMEWISE:bool=true
const frame_interval:int=5
var frame_timer:int=0

@export var cam: Camera2D
@export var tilemap:TileMapLayer

func _ready():
	randomize()

func _process(delta):
	var ret:Dictionary=get_limits()
	var top_left:Vector2i = tilemap.local_to_map(ret["top_left"])
	var bottom_right:Vector2i = tilemap.local_to_map(ret["bottom_right"])
	
	if !FRAMEWISE:
		scroll_timer += delta
		if scroll_timer < scroll_interval:
			return
		scroll_timer = 0
	
	if FRAMEWISE:
		frame_timer+=1
		if frame_timer < frame_interval:
			return
		frame_timer=0
	
	spawn_row(top_left.y-TILE_COUNT,top_left.x-TILE_COUNT,bottom_right.x+TILE_COUNT)
	move_rows_down()
	delete_rows_below()
	
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

func spawn_row(y: int, x_start: int, x_end: int):
	for x in range(x_start, x_end + 1):
		tilemap.set_cell(
			Vector2i(x, y),
			SOURCE_ID,
			Vector2i(randi_range(ATLAS_LIM_START,ATLAS_LIM_END),randi_range(ATLAS_LIM_START,ATLAS_LIM_END))
		)

func move_rows_down():
	var used_cells := tilemap.get_used_cells()

	# Sort bottom → top (VERY important)
	used_cells.sort_custom(func(a, b): return a.y > b.y)

	for cell in used_cells:
		var source_id := tilemap.get_cell_source_id(cell)
		var atlas_coords := tilemap.get_cell_atlas_coords(cell)

		tilemap.erase_cell(cell)
		tilemap.set_cell(
			cell + Vector2i(0, 1),
			source_id,
			atlas_coords
		)

func delete_rows_below():
	var ret := get_limits()
	var bottom_map: Vector2i = tilemap.local_to_map(ret["bottom_right"])

	var cutoff_y := bottom_map.y + 2 # small buffer

	for cell in tilemap.get_used_cells():
		if cell.y > cutoff_y:
			tilemap.erase_cell(cell)
