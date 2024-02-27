extends Node2D

@export var next_level = PackedScene

@onready var level_completed = $CanvasLayer/LevelCompleted

func _ready():
	#RenderingServer.set_default_clear_color(Color.BLACK)
	Events.zone_completed.connect(show_zone_completed)

func show_zone_completed():
	level_completed.show()
	#get_tree().paused = true
	if not next_level is PackedScene: 
		get_tree().paused = true
		return
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()
