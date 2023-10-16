extends CanvasLayer


func _on_health_updated(health):
	$Health.text = str(health) + "%"
