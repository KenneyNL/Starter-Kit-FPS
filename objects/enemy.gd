extends Node3D

@export var player:Node3D

@onready var raycast = $RayCast
@onready var burst_a = $BurstA
@onready var burst_b = $BurstB

var health := 100
var target_position:Vector3
var time := 0.0
var destroyed := false

func _ready():
	target_position = position

func _process(delta):
	self.look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)
	
	target_position.y += (cos(time * 5) * 1) * delta # Sine movement
	
	time += delta
	
	position = target_position

func damage(amount):
	health -= amount
	Audio.play("sounds/enemy_hurt.ogg")
	if health <= 0 and !destroyed:
		destroy()

func destroy():
	destroyed = true
	Audio.play("sounds/enemy_destroy.ogg")
	queue_free()


func _on_timer_timeout():
	shoot()
	
func shoot():
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		
		var collider = raycast.get_collider()
		
		if collider.has_method("get_hurt"):
		
			burst_a.frame = 0
			burst_a.play("default")
			burst_a.rotation_degrees.z = randf_range(-45, 45)
			
			burst_b.frame = 0
			burst_b.play("default")
			burst_b.rotation_degrees.z = randf_range(-45, 45)
			
			Audio.play("sounds/enemy_attack.ogg")
			
			collider.get_hurt()
