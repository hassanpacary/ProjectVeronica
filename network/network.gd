class_name Network
extends Node

## network - Network node
##
## Starts the ENet server or client and logs the connection events.

const PORT := 7000
const DEFAULT_SERVER_IP := "127.0.0.1"
const MAX_CONNECTIONS := 20

var game_version := ""
## Authentication node of the open connection (ServerAuth or ClientAuth).
var _auth: Node = null

@onready var scene_multiplayer: SceneMultiplayer = multiplayer


#region ─────────────────────────────────── NETWORK ────────────────────────────────────

## Connects the MultiplayerAPI signals before anyone can start the network.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	scene_multiplayer.peer_authentication_failed.connect(
			_on_peer_authentication_failed
	)


## Listen for clients on PORT.
func start_server() -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT, MAX_CONNECTIONS)

	if err:
		push_error(
				"Cannot start the server on port %d: %s." % [
					PORT, error_string(err)
				]
		)
		return err

	var auth := ServerAuth.new()
	auth.game_version = game_version
	_start_auth(auth)

	multiplayer.multiplayer_peer = peer
	print("Server listening on port %d." % PORT)
	return OK


## Starts connecting to the server at address.
func join_server(address: String=DEFAULT_SERVER_IP) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, PORT)
	if err:
		push_error(
				"Cannot connect to %s:%d: %s." % [address, PORT, error_string(err)]
		)
		return err

	var auth := ClientAuth.new()
	auth.game_version = game_version
	_start_auth(auth)

	multiplayer.multiplayer_peer = peer
	print("Connecting to %s:%d..." % [address, PORT])
	return OK

#endregion


#region ─────────────────────────────── AUTHENTICATION ─────────────────────────────────

## Adds the authentication node of a new connection, in place of the previous one.
func _start_auth(auth: Node) -> void:
	_stop_auth()
	_auth = auth
	add_child(_auth)


## Removes the authentication node of the closed connection.
func _stop_auth() -> void:
	if _auth == null:
		return

	_auth.queue_free()
	_auth = null


## Called by SceneMultiplayer with the authentication payload sent by a peer.
func _receive_auth_payload(payload: PackedByteArray) -> void:
	if multiplayer.is_server():
		AuthProtocol.decode_client_payload(payload)
		return

	AuthProtocol.decode_server_payload(payload)


## Listen when a peer leaves before the end of its authentication (both sides).
func _on_peer_authentication_failed(id: int) -> void:
	push_warning("Authentication with peer %d failed." % id)

#endregion


#region ─────────────────────────────── PEER CONNECTIONS ───────────────────────────────

## Remove/disconnect multiplayer peer object
func remove_multiplayer_peer() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	_stop_auth()


## Listen when player connected to the server (server side)
func _on_player_connected(id: int) -> void:
	print("Peer %d connected." % id)


## Listen when player disconnected from the server (server side)
func _on_player_disconnected(id: int) -> void:
	print("Peer %d disconnected." % id)


## Listen when client connected to the server (client side)
func _on_connected_ok() -> void:
	print("Connected to the server as peer %d." % multiplayer.get_unique_id())


## Listen if the client failed to connect to the server
func _on_connected_fail() -> void:
	push_warning("Connection to the server failed.")
	remove_multiplayer_peer()


## Listen when client disconnected from the server (client side)
func _on_server_disconnected() -> void:
	print("Disconnected from the server.")
	remove_multiplayer_peer()

	#endregion
