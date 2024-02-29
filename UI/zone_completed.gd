extends ColorRect

signal next_level()

@onready var next_zone_button = $CenterContainer/VBoxContainer/NextZoneButton

func _on_next_zone_button_pressed():
	next_level.emit()
