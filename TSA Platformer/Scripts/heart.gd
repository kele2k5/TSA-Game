extends Area2D

func _on_body_entered(_body):
	queue_free()
	var hearts = get_tree().get_nodes_in_group("Hearts")
	print(hearts.size())
	if hearts.size() == 1:
		Events.zone_completed.emit()
