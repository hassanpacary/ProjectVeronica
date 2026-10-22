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
	
	#
	print(version_text)
