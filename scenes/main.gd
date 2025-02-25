extends Node

var nextPlayerLabel  

var grid_data: Array
var grid_pos: Vector2i
var board_size: int
var cell_size: int
var current_player: int
var cross_scene = preload("res://scenes/cross.tscn")
var circle_scene = preload("res://scenes/circle.tscn")
var temp_marker: Sprite2D
var player_panel_pos: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_size = $Board.texture.get_width()
	#divide board size by 3 to get individual cell
	cell_size = board_size / 3
	player_panel_pos = $PlayerPanel.get_position() + Vector2($PlayerPanel.size.x / 2, $PlayerPanel.size.y / 2)
	new_game()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if event.position.x < board_size:
				#convert mouse position to grid position
				grid_pos = Vector2i(event.position / cell_size)
				if (grid_data[grid_pos.y][grid_pos.x] == 0):
					grid_data[grid_pos.y][grid_pos.x] = current_player
					place_marker(grid_pos * cell_size + Vector2i(cell_size / 2.0, cell_size / 2.0))
					check_winner()
					switch_players()

func check_winner():
	var win = false
	#check rows
	for i in range(3):
		if grid_data[i][0] + grid_data[i][1] + grid_data[i][2] == 3 or grid_data[i][0] + grid_data[i][1] + grid_data[i][2] == -3:
			win = true
			break
	
	#check columns
	for i in range(3):
		if grid_data[0][i] + grid_data[1][i] + grid_data[2][i] == 3 or grid_data[0][i] + grid_data[1][i] + grid_data[2][i] == -3:
			win = true
			break

	#check diagonals
	if grid_data[0][0] + grid_data[1][1] + grid_data[2][2] == 3 or grid_data[0][0] + grid_data[1][1] + grid_data[2][2] == -3:
		win = true
	elif grid_data[0][2] + grid_data[1][1] + grid_data[2][0] == 3 or grid_data[0][2] + grid_data[1][1] + grid_data[2][0] == -3:
		win = true

	var val = "Player 1 wins" if current_player == 1 else "Player 2 wins"
	if win:
		get_tree().paused = true
		print(val)
		$GameOverMenu.show()
		$GameOverMenu.get_node("ResultLabel").text = val


func place_marker(pos: Vector2, temp: bool = false) -> void:
	if current_player == 1:
		var new_cross = cross_scene.instantiate()
		new_cross.position = pos
		add_child(new_cross)
		if temp: 
			temp_marker = new_cross
	else:
		var new_circle = circle_scene.instantiate()
		new_circle.position = pos
		add_child(new_circle)
		if temp: 
			temp_marker = new_circle

func new_game():
	$GameOverMenu.hide()
	grid_data = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
	current_player = 1
	#Clear markers
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	get_tree().paused = false
	place_marker(player_panel_pos, true)

func switch_players():
	if temp_marker:
		temp_marker.queue_free()
	if current_player == 1:
		current_player = -1
		place_marker(player_panel_pos , true)
	else:
		current_player = 1
		place_marker(player_panel_pos , true)

func _on_game_over_menu_restart() -> void:
	new_game()

