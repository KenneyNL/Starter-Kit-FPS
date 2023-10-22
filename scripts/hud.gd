extends CanvasLayer


func _on_health_updated(health):
	$Health.text = str(health) + "%"

func _on_player_ammo_updated(bullets_in_mag, total_ammo):
	$Ammo.text = str(bullets_in_mag) + " / " + str(total_ammo)
