extends Resource
class_name Weapon

@export_subgroup("Model")
@export var model:PackedScene
@export var position:Vector3
@export var rotation:Vector3

@export_subgroup("Properties")
@export_range(0.1, 1) var cooldown: float = 0.1
@export_range(1, 20) var max_distance: int = 10
@export_range(0, 100) var damage: float = 25
@export_range(0, 5) var spread: float = 0
@export_range(1, 5) var shot_count: int = 1

@export_subgroup("Sounds")
@export var sound_shoot: String

@export_subgroup("Crosshair")
@export var crosshair: Texture2D
