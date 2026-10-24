class_name ClientAuth
extends Node

## client_auth - ClientAuth node
##
## Client side of the authentication.
## Sends the game version to the server, then completes the authentication
## only if the server accepts it.

var game_version := ""

@onready var scene_multiplayer: SceneMultiplayer = multiplayer


## Turns the authentication on as soon as the node enters the tree.
func _ready() -> void:

	## Execute when receiving authentication data, 
	## and admits it only if the server accepted the version.
	scene_multiplayer.auth_callback = func(id: int, payload: PackedByteArray):
		var answer := AuthProtocol.decode_server_payload(payload)
		
		if answer.is_empty():
			push_error(
					"Invalid answer from the server: %s" % payload.get_string_from_utf8()
			)
			return
	
		var accepted: bool = answer["accepted"]
		var server_version: String = answer["version"]
		
		if not accepted:
			push_warning('Version refused, server version "%s".' % server_version)
			return
	
		var err := scene_multiplayer.complete_auth(id)
		
		if err != OK:
			push_error(
					"Cannot complete the authentication: %s." % error_string(err)
			)
			return
	
		print("Version accepted by the server.")

	## Listen when a client starts its authentication.
	scene_multiplayer.peer_authenticating.connect(func(id: int):
		var err := scene_multiplayer.send_auth(
				id, 
				AuthProtocol.encode_client_payload(game_version)
		)
		if err != OK:
			push_error(
					"Cannot send the version to the server: %s." % error_string(err)
			)
			return

		print("Version %s sent to the server." % game_version)
	)
	