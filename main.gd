extends Control

## Main scene
## 
## Shows witch version of the game is running
## In dev the version show is: dev

## Release informations file (absent in dev)
const RELEASE_PATH := "res://release.cfg"

## Version displayed when no release informations is available
const DEV_VERSION := "dev"

# $ is a shortcut for get_node("VersionLabel")
@onready var version_label: Label = $VersionLabel


#region ──────────────────────────────────── VERSION ───────────────────────────────────

## The engine call this function when all nodes of the game are ready
func _ready() -> void:

	# Display in the interface the game version
	var version_text := "Version : %s" % _read_version()
	version_label.text = version_text
	print(version_text)

	# Read user args for debug utilities
	_read_user_args()


## Return the version written in RELEASE_PATH or DEV_VERSION
func _read_version() -> String:
	var config := ConfigFile.new()
	var err := config.load(RELEASE_PATH)

	# No release file in dev: not an error
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


#region ──────────────────────────────────── DEBUG ─────────────────────────────────────

## Debug function for tests
## Prints the user arguments and tells whether "--my-option" was given.
func _read_user_args() -> void:
	var user_args: PackedStringArray = OS.get_cmdline_user_args()
	print("User args: ", user_args)

	var option := "--my-option"
	if option in user_args:
		print("Option %s received." % option)
	else:
		print("Option %s not received." % option)

#endregion
