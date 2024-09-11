extends Node3D

@export_subgroup("Shield")
@export var shield : Area3D
@export var shield_generator_particles : GPUParticles3D

var isShieldOn : bool = false
var battery: int = 0 #out of 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shield.isVisible = isShieldOn
	shield_generator_particles.emitting = isShieldOn

func toggle_shield() -> void:
	isShieldOn = !isShieldOn
	shield.isVisible = isShieldOn
	shield_generator_particles.emitting = isShieldOn

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
