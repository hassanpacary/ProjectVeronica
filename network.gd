class_name Network
extends Node

## Starts the ENet server or client and logs the connection events.

## UDP port the server listen.
const PORT := 7000

## Default IPv4 localhost.
const DEFAULT_SERVER_IP := "127.0.0.1"

## Maximum number of clients connected at the same time.
const MAX_CONNECTIONS := 20


#region ─────────────────────────────────── NETWORK ────────────────────────────────────

## Connects the MultiplayerAPI signals before anyone can start the network.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


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
