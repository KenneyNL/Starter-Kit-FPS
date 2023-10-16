extends AnimatedSprite3D

# Remove this impact effect after the animation has completed


func _on_animation_finished():
	queue_free()
