extends CanvasLayer

@onready var _health:Label = $Health

func _on_health_updated(health:int) -> void:
	_health.text = str(health) + "%"
