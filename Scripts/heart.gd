extends Area2D

func _on_body_entered(_body):
	queue_free()
	var rifts = get_tree().get_nodes_in_group("TimeRift")
	if rifts.size() == 1:
		Events.zone_completed.emit()
