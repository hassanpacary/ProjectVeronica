extends Control

## Main scene
## 
## Shows wich version of the game is running

## ─────────────────────────────────── MAIN ────────────────────────────────────

## Version displayed when no release info is available
const DEV_VERSION := "dev"

## $ is a shortcut for get_node("VersionLabel")
@onready var version_label: Label = $VersionLabel

## Call this function when all nodes are ready
func _ready() -> void:
	var version_text := "Version : %s" % DEV_VERSION
	version_label.text = version_text
	print(version_text)
	
	_read_user_args()

## Prints the user arguments and tells whether --my-option was given.
func _read_user_args() -> void:
	var user_args: PackedStringArray = OS.get_cmdline_user_args()
	print("User args: ", user_args)
	
	## Debug: Check if the reception of specific option is OK
	if "--my-option" in user_args:
		print("Option %s received." % "--my-option")
	else:
		print("Option %s not received." % "--my-option")
	
