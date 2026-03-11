extends Node3D

@export var player: Node3D

@onready var muzzle_a:AnimatedSprite3D = $MuzzleA
@onready var muzzle_b:AnimatedSprite3D = $MuzzleB
@onready var raycast:RayCast3D = $RayCast

var destroyed := false
var health := 100
var target_position: Vector3
var time := 0.0

# When ready, save the initial position

func _ready() -> void:
    target_position = position


func _process(delta:float) -> void:
    self.look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)  # Look at player
    target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)

    time += delta

    position = target_position

# Take damage from player

func damage(amount:int) -> void:
    Audio.play("sounds/enemy_hurt.ogg")

    health -= amount

    if health <= 0 and !destroyed:
        destroy()

# Destroy the enemy when out of health

func destroy() -> void:
    Audio.play("sounds/enemy_destroy.ogg")

    destroyed = true
    queue_free()

# Shoot when timer hits 0

func _on_timer_timeout() -> void:
    raycast.force_raycast_update()

    if raycast.is_colliding():
        var collider := raycast.get_collider()

        if collider.has_method("damage"):  # Raycast collides with player
            
            # Play muzzle flash animation(s)

            muzzle_a.frame = 0
            muzzle_a.play("default")
            muzzle_a.rotation_degrees.z = randf_range(-45, 45)

            muzzle_b.frame = 0
            muzzle_b.play("default")
            muzzle_b.rotation_degrees.z = randf_range(-45, 45)

            Audio.play("sounds/enemy_attack.ogg")

            # This is another edge case where static typing works oddly in Godot.
            # We don't have Interfaces and because the "Player" Type is not actually
            # in scope, we can't simply check: `collider is Player`.
            # As a work around, we can see if the collider object has the "damage"
            # method, and if it does we can call it indirectly.
            collider.call("damage", 5);