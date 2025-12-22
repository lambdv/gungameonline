extends Control

@onready var resume_button: Button = $CenterContainer/PanelContainer/VBoxContainer/ResumeButton
@onready var leave_button: Button = $CenterContainer/PanelContainer/VBoxContainer/LeaveButton

func _ready() -> void:
	# Connect button signals
	resume_button.connect("pressed", Callable(self, "_on_resume_pressed"))
	leave_button.connect("pressed", Callable(self, "_on_leave_pressed"))

	# Initially hide the pause menu
	visible = false

	# Set process mode to always so we can handle input during pause
	process_mode = PROCESS_MODE_ALWAYS

	# Connect to game state changes
	if GameStateManager:
		GameStateManager.paused.connect(_on_game_paused)
		GameStateManager.resumed.connect(_on_game_resumed)

func _on_resume_pressed() -> void:
	if GameStateManager:
		GameStateManager.resume()

func _on_leave_pressed() -> void:
	# Gracefully leave the game
	_leave_game()

func _on_game_paused() -> void:
	visible = true
	# Ensure mouse is visible for UI interaction
	if InputManager:
		InputManager.release_mouse()

func _on_game_resumed() -> void:
	visible = false
	# Recapture mouse for gameplay
	if InputManager:
		InputManager.capture_mouse()

func _input(event: InputEvent) -> void:
	# Only handle escape key when pause menu is visible
	if visible and event.is_action_pressed("escape"):
		_on_resume_pressed()
		# Consume the event so InputManager doesn't also process it
		get_viewport().set_input_as_handled()

func _leave_game() -> void:
	# Only leave the current lobby (disconnect UDP game connection)
	# Keep HTTP connection alive so user can create/join lobbies from menu
	if NetworkingManager:
		NetworkingManager.leave_current_lobby()

	# Disconnect from multiplayer
	if MultiplayerManager and MultiplayerManager.is_connected:
		MultiplayerManager.disconnect_from_server()

	# Resume game state before changing scenes
	if GameStateManager:
		GameStateManager.resume()

	# Change to main menu scene
	get_tree().change_scene_to_file("res://ui/menus/main/main.tscn")
