extends Node2D

func _process(delta):
	Events.reset_zone.connect(show_reset_zone)
	print("huh")

func show_reset_zone():
	await LevelTransition.fade_to_black()
	get_tree().reload_current_scene()
	LevelTransition.fade_from_black()
