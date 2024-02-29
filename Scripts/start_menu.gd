extends CenterContainer

@onready var start_game_button = %StartGameButton
@onready var quit_game_button = %QuitGameButton
@onready var timer = $Timer

func _ready():
	LevelTransition.fade_from_black()
	RenderingServer.set_default_clear_color(Color.BLACK)
	start_game_button.grab_focus()
	

func _on_start_game_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Levels/LevelOne/Zone1-1.tscn")
	LevelTransition.fade_from_black()

func _on_quit_game_button_pressed():
	get_tree().quit()

