class_name Network
extends Node

## Starts the ENet server or client and logs the connection events.

## UDP port the server listen.
const PORT := 7000

## Default IPv4 localhost.
const DEFAULT_SERVER_IP := "127.0.0.1"

## Maximum number of clients connected at the same time.
const MAX_CONNECTIONS := 20

## Version of the game sent to the server
var game_version := ""

# Node.multiplayer is typed MultiplayerAPI
@onready var scene_multiplayer: SceneMultiplayer = multiplayer


#region ─────────────────────────────────── NETWORK ────────────────────────────────────

## Connects the MultiplayerAPI signals before anyone can start the network.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	# A valid callback turns the authentication on, on both sides.
	# without it, peer_authenticating is never emitted and peers are accepted at once.
	scene_multiplayer.auth_callback = _receive_auth_data
	scene_multiplayer.peer_authenticating.connect(_on_peer_authenticating)
	scene_multiplayer.peer_authentication_failed.connect(
			_on_peer_authentication_failed
	)


## Starts connecting to the server at address. OK only means the attempt has started.
func join_server(address: String=DEFAULT_SERVER_IP) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, PORT)
	if err:
		push_error(
				"Cannot connect to %s:%d: %s." % [address, PORT, error_string(err)]
		)
		return err

	multiplayer.multiplayer_peer = peer
	print("Connecting to %s:%d..." % [address, PORT])
	return OK


## Listen for clients on PORT. Returns OK, or the error if the port can't be used.
func start_server() -> Error:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT, MAX_CONNECTIONS)

	if err:
		push_error(
				"Cannot start the server on port %d: %s." % [PORT, error_string(err)]
		)
		return err

	multiplayer.multiplayer_peer = peer
	print("Server listening on port %d." % PORT)
	return OK

#endregion


#region ─────────────────────────────── AUTHENTICATION ─────────────────────────────────

## Called by SceneMultiplayer with the authentication data sent by a peer.
func _receive_auth_data(id: int, data: PackedByteArray) -> void:
	print("Authentication data from peer %d: %s" % [id, data.get_string_from_utf8()])
	
	
## Listen when a peer starts its authentication (both sides).
## The client sends its version; the server waits for it.
func _on_peer_authenticating(id: int) -> void:
	if multiplayer.is_server():
		print("Peer %d is authenticating." % id)
		return

	# On a client, the only peer is the server: id is always 1.
	var payload := JSON.stringify({"version": game_version}).to_utf8_buffer()
	var err := scene_multiplayer.send_auth(id, payload)
	if err != OK:
		push_error("Cannot send the version to the server: %s." % error_string(err))
		return

	print("Version %s sent to the server." % game_version)


## Listen when a peer leaves before the end of its authentication (both sides).
func _on_peer_authentication_failed(id: int) -> void:
	push_warning("Authentication with peer %d failed." % id)

#endregion


#region ─────────────────────────────── PEER CONNECTIONS ───────────────────────────────

## Remove/disconnect multiplayer peer object
func remove_multiplayer_peer() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


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
