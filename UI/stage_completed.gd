extends CenterContainer

@onready var menu_button = $VBoxContainer/MenuButton
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	menu_button.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_menu_button_pressed():
	LevelTransition.fade_from_black()
	get_tree().change_scene_to_file("res://UI/start_menu.tscn")
