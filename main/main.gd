extends Control

## Main scene -
## 
## Shows which version of the game is running.
## In dev the version show is: dev.

## Release informations file (absent in dev).
const RELEASE_PATH := "res://release.cfg"

## Version displayed when no release informations is available.
const DEV_VERSION := "dev"

#region ────────────────────────────────── USER ARGS ───────────────────────────────────

## User argument that starts the server
const SERVER_OPTION := "--server"

## User argument that joins the server
const JOIN_OPTION := "--join"

#endregion


# $ is a shortcut for get_node("...").
@onready var version_label: Label = $VersionLabel
@onready var network: Network = $Network


## The engine call this function when all nodes of the game are ready.
func _ready() -> void:

	# Display in the interface the game version.
	var version := _read_version()
	var version_text := "Version : %s" % version
	version_label.text = version_text
	print(version_text)

	# Start the server with user args.
	network.game_version = version
	_start_network_from_args()
	

#region ──────────────────────────────────── VERSION ───────────────────────────────────

## Return the version written in RELEASE_PATH or DEV_VERSION.
func _read_version() -> String:
	var config := ConfigFile.new()
	var err := config.load(RELEASE_PATH)

	# No release file in dev: not an error.
	if err == ERR_FILE_NOT_FOUND:
		return DEV_VERSION
	elif err != OK:
		push_error("Cannot read %s: %s." % [RELEASE_PATH, error_string(err)])
		return DEV_VERSION

	var version: Variant = config.get_value("release", "version", "")
	if version is String and version != "":
		return version

	push_error(
			"%s: [release] version must be a non-empty quoted string." % RELEASE_PATH
	)
	return DEV_VERSION

#endregion


#region ─────────────────────────────────── NETWORK ────────────────────────────────────

## Starts the server (SERVER_OPTION) or joins it (JOIN_OPTION).
func _start_network_from_args() -> void:
	var user_args: PackedStringArray = OS.get_cmdline_user_args()
	var err: Error = OK

	if SERVER_OPTION in user_args:
		err = network.start_server()
	elif JOIN_OPTION in user_args:
		err = network.join_server()

	# Quits with exit code 1 if the network can't start.
	if err != OK:
		get_tree().quit(1)

		#endregion
