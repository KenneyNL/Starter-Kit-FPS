extends Resource
class_name Weapon

@export_subgroup("Model")
@export var model: PackedScene  # Model of the weapon
@export var position: Vector3  # On-screen position
@export var rotation: Vector3  # On-screen rotation
@export var muzzle_position: Vector3  # On-screen position of muzzle flash

@export_subgroup("Properties")
@export_range(0.1, 1) var cooldown: float = 0.1  # Firerate
@export_range(1, 20) var max_distance: int = 10  # Fire distance
@export_range(0, 100) var damage: float = 25  # Damage per hit
@export_range(0, 5) var spread: float = 0  # Spread of each shot
@export_range(1, 5) var shot_count: int = 1  # Amount of shots
@export_range(0, 50) var knockback: int = 20  # Amount of knockback
@export_range(1, 300) var magazine_size: int = 20  # amount of bullets in the magazine
@export_range(1, 300) var max_magazine_size: int = 20  # size of an magazine
@export_range(1, 900) var ammo: int = 20 * 3  # Amount of bulllets the player still carries
@export_range(1, 900) var max_ammo: int = 20 * 3  # total amount of bullets

@export_subgroup("Sounds")
@export var sound_shoot: String  # Sound path

@export_subgroup("Crosshair")
@export var crosshair: Texture2D  # Image of crosshair on-screen

func reload():
	if ammo > 0:
		var restBullets = magazine_size
		if ammo > max_magazine_size:
			ammo = ammo - max_magazine_size + restBullets
			magazine_size = max_magazine_size
		else:
			magazine_size = ammo
			ammo = 0

func reset():
	ammo = max_ammo
	magazine_size = max_magazine_size
