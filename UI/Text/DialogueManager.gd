extends Node

@onready var text_box_scene = preload("res://UI/Text/text_box.tscn")

var dialogue_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialogue_active = false
var can_advance_line = false

func start_dialogue(position: Vector2, lines: Array[String]):
	if is_dialogue_active:
		return
		
	dialogue_lines = lines
	text_box_position = position
	show_text_box()
	
	is_dialogue_active = true

func show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(on_text_box_finished_displaying)
	text_box.global_position = text_box_position
	text_box.display_text(dialogue_lines[current_line_index])
	can_advance_line = false
	
func on_text_box_finished_displaying():
	can_advance_line = true
	

func _unhandled_input(event):
	if(
		event.is_action_pressed("dash") && is_dialogue_active && can_advance_line
	):
		text_box.queue_free()
		
		current_line_index += 1
		if current_line_index >= dialogue_lines.size():
			is_dialogue_active = false
			current_line_index = 0
			return
			
		show_text_box()
