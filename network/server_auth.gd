class_name ServerAuth
extends Node

## server_auth - ServerAuth node
##
## Server side of the authentication.
## Answers each client, and admits it only if both versions match.

var game_version := ""

@onready var scene_multiplayer: SceneMultiplayer = multiplayer


## Turns the authentication on as soon as the node enters the tree.
func _ready() -> void:
	
	## Execute when receiving authentication data,  
	## and admits it only if both versions match.
	scene_multiplayer.auth_callback = func(id: int, payload: PackedByteArray):
		var auth_data := AuthProtocol.decode_client_payload(payload)
		var accepted := auth_data != "" and auth_data == game_version

		var err := scene_multiplayer.send_auth(
				id,
				AuthProtocol.encode_server_payload(accepted, game_version)
		)

		if err != OK:
			push_error("Cannot answer peer %d: %s." % [id, error_string(err)])
			return

		if not accepted:
			push_warning(
					'Peer %d refused: version "%s", server version "%s".'
							% [id, auth_data, game_version]
			)
			return

		print("Peer %d accepted with version %s." % [id, auth_data])
		scene_multiplayer.complete_auth(id)

	## Listen when a client starts its authentication.
	scene_multiplayer.peer_authenticating.connect(func(id: int):
		print("Peer %d is authenticating." % id)
	)
