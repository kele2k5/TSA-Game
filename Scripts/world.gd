extends Node2D

@export var next_level = PackedScene

@onready var zone_completed = $CanvasLayer/ZoneCompleted

func _ready():
	if not next_level is PackedScene:
		zone_completed.next_zone_button.text = "The End!"
		next_level = load("res://UI/stage_completed.tscn")
	Events.zone_completed.connect(show_zone_completed)

func go_to_next_zone():
	if not next_level is PackedScene: 
		return
	await LevelTransition.fade_to_black()
	LevelTransition.fade_from_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	
func show_zone_completed():
	zone_completed.show()
	zone_completed.next_zone_button.grab_focus()
	get_tree().paused = true

func _on_zone_completed_next_level():
	go_to_next_zone()
