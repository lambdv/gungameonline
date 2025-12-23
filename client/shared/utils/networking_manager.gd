extends Node
## NetworkingManager - Facade for networking system
##
## Provides backward-compatible API by delegating to ServerRepository.
## All signals are forwarded from ServerCallbacks.
## This maintains the existing public interface while using the new architecture.

var repository: Node  # ServerRepository instance
var callbacks: Node  # ServerCallbacks instance

# Connection state enum (for backward compatibility)
enum ConnectionState {
	DISCONNECTED,
	CONNECTED_HTTP,
	CONNECTED_LOBBY,
	RECONNECTING
}

# Forward all signals from ServerCallbacks
signal lobby_created(lobby_data: Dictionary)
signal lobby_joined(lobby_data: Dictionary)
signal lobby_join_failed(error: String, lobby_code: String)
signal lobby_left()
signal lobby_list_received(lobby_list: Array)
signal player_joined(player_data: Dictionary)
signal player_left(player_id: int)
signal position_update_received(player_id: int, position: Vector3, rotation: Vector3)
signal server_dummy_updated(position: Vector3)
signal connection_confirmed()
signal connection_state_changed(new_state: ConnectionState)
signal reconnection_attempt(attempt: int, max_attempts: int)
signal state_sync_received(player_states: Array)
signal weapon_switched(player_id: int, weapon_id: int)
signal player_damaged(player_id: int, damage: int, attacker_id: int)

func _ready() -> void:
	_setup_dependencies()
	_forward_signals()

func _setup_dependencies() -> void:
	repository = get_node_or_null("/root/ServerRepository")
	if not repository:
		push_error("ServerRepository not found! Make sure it's added as an autoload.")
	
	callbacks = get_node_or_null("/root/ServerCallbacks")
	if not callbacks:
		push_error("ServerCallbacks not found! Make sure it's added as an autoload.")

func _forward_signals() -> void:
	if not callbacks:
		return
	
	# Forward all signals from ServerCallbacks
	callbacks.lobby_created.connect(_on_lobby_created)
	callbacks.lobby_joined.connect(_on_lobby_joined)
	callbacks.lobby_join_failed.connect(_on_lobby_join_failed)
	callbacks.lobby_left.connect(_on_lobby_left)
	callbacks.lobby_list_received.connect(_on_lobby_list_received)
	callbacks.player_joined.connect(_on_player_joined)
	callbacks.player_left.connect(_on_player_left)
	callbacks.position_update_received.connect(_on_position_update_received)
	callbacks.server_dummy_updated.connect(_on_server_dummy_updated)
	callbacks.connection_confirmed.connect(_on_connection_confirmed)
	callbacks.connection_state_changed.connect(_on_connection_state_changed)
	callbacks.reconnection_attempt.connect(_on_reconnection_attempt)
	callbacks.state_sync_received.connect(_on_state_sync_received)
	callbacks.weapon_switched.connect(_on_weapon_switched)
	callbacks.player_damaged.connect(_on_player_damaged)

# Signal forwarding methods
func _on_lobby_created(lobby_data: Dictionary) -> void:
	lobby_created.emit(lobby_data)

func _on_lobby_joined(lobby_data: Dictionary) -> void:
	lobby_joined.emit(lobby_data)

func _on_lobby_join_failed(error: String, lobby_code: String) -> void:
	lobby_join_failed.emit(error, lobby_code)

func _on_lobby_left() -> void:
	lobby_left.emit()

func _on_lobby_list_received(lobby_list: Array) -> void:
	lobby_list_received.emit(lobby_list)

func _on_player_joined(player_data: Dictionary) -> void:
	player_joined.emit(player_data)

func _on_player_left(player_id: int) -> void:
	player_left.emit(player_id)

func _on_position_update_received(player_id: int, position: Vector3, rotation: Vector3) -> void:
	position_update_received.emit(player_id, position, rotation)

func _on_server_dummy_updated(position: Vector3) -> void:
	server_dummy_updated.emit(position)

func _on_connection_confirmed() -> void:
	connection_confirmed.emit()

func _on_connection_state_changed(new_state: int) -> void:
	# Convert ServerCallbacks.ConnectionState to NetworkingManager.ConnectionState
	var converted_state = new_state as ConnectionState
	connection_state_changed.emit(converted_state)

func _on_reconnection_attempt(attempt: int, max_attempts: int) -> void:
	reconnection_attempt.emit(attempt, max_attempts)

func _on_state_sync_received(player_states: Array) -> void:
	state_sync_received.emit(player_states)

func _on_weapon_switched(player_id: int, weapon_id: int) -> void:
	weapon_switched.emit(player_id, weapon_id)

func _on_player_damaged(player_id: int, damage: int, attacker_id: int) -> void:
	player_damaged.emit(player_id, damage, attacker_id)

# Public API - delegate to repository

func create_lobby(code: String, scene: String = "world", max_players: int = 4) -> void:
	if repository:
		repository.create_lobby(code, scene, max_players)

func join_lobby(code: String) -> void:
	if repository:
		repository.join_lobby(code)

func get_lobby_info(code: String) -> void:
	if repository:
		repository.get_lobby_info(code)

func get_lobby_list() -> void:
	if repository:
		repository.get_lobby_list()

func connect_udp_server(ip: String, port: int) -> void:
	if repository:
		repository.connect_udp_server(ip, port)

func send_join_packet() -> void:
	if repository:
		repository.send_join_packet()

func send_position_update(position: Vector3, rotation: Vector3) -> void:
	if repository:
		repository.send_position_update(position, rotation)

func send_weapon_switch(weapon_id: int) -> void:
	if repository:
		repository.send_weapon_switch(weapon_id)

func connect_to_test_lobby() -> void:
	if repository:
		repository.connect_to_test_lobby()

func is_connected_to_lobby() -> bool:
	if repository:
		return repository.is_connected_to_lobby()
	return false

func get_current_lobby_code() -> String:
	if repository:
		return repository.get_current_lobby_code()
	return ""

func get_connected_player_ids() -> Array:
	if repository:
		return repository.get_connected_player_ids()
	return []

func leave_current_lobby() -> void:
	if repository:
		repository.leave_current_lobby()

func return_to_lobby_browser() -> void:
	if repository:
		repository.return_to_lobby_browser()

func disconnect_from_network() -> void:
	if repository:
		repository.disconnect_from_network()

func attempt_reconnection() -> void:
	if repository:
		repository.attempt_reconnection()

func reset_reconnection_state() -> void:
	if repository:
		repository.reset_reconnection_state()
