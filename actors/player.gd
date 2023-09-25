extends CharacterBody3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7

@export_subgroup("Weapons")
@export var weapons: Array[Weapon] = []

var weapon: Weapon
var weapon_index := 0

var mouse_sensitivity = 700
var mouse_captured := true

var movement_velocity: Vector3
var rotation_target: Vector3

var input: Vector3
var input_mouse: Vector2

var gravity := 0.0

var previously_floored := false

var jump_single := true
var jump_double := true

var container_offset = Vector3(1.2, -1.1, -2.75)

var tween:Tween

@onready var sound_footsteps = $SoundFootsteps
@onready var item_container = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Container
@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/ShootCast
@onready var blaster_cooldown = $BlasterCooldown
@onready var burst = $Head/Camera/SubViewportContainer/SubViewport/CameraItem/Burst

@export var crosshair:TextureRect

# Functions

func _ready():
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	change_weapon(weapon_index)

func _process(delta):
	
	# Handle functions
	
	handle_controls(delta)
	handle_gravity(delta)
	
	# Movement

	var applied_velocity: Vector3
	
	movement_velocity = transform.basis * movement_velocity # Move forward
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	
	camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 1.25, delta * 5)	
	
	camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
	
	item_container.rotation.y = lerp_angle(item_container.rotation.y, -input_mouse.x * 4, delta * 5)
	#item_container.rotation.x = lerp_angle(item_container.rotation.x, -rotation_target.x / 3, delta * 10)
	
	item_container.position = lerp(item_container.position, container_offset - (applied_velocity / 30), delta * 10)
	
	# Movement sound
	
	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			sound_footsteps.stream_paused = false
	
	# Landing after jump or falling
	
	camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
	
	if is_on_floor() and gravity > 1 and !previously_floored: # Landed
		Audio.play("sounds/land.ogg")
		camera.position.y = -0.1
	
	previously_floored = is_on_floor()
	
	input_mouse = Vector2.ZERO

# Mouse movement

func _input(event):
	if event is InputEventMouseMotion and mouse_captured:
		
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity
		rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))

func handle_controls(delta):
	
	# Mouse capture
	
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
	
	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
	
	# Movement
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	movement_velocity = input.normalized() * movement_speed * delta
	
	# Shooting
	
	if Input.is_action_pressed("shoot"):
		shoot()
	
	# Jumping
	
	if Input.is_action_just_pressed("jump"):
		
		if jump_single or jump_double:
			Audio.play_random("sounds/jump_a.ogg, sounds/jump_b.ogg, sounds/jump_c.ogg")
		
		if jump_double:
			
			gravity = -jump_strength
			
			jump_double = false
			
		if(jump_single): jump()
		
	# Weapon switching
	
	if Input.is_action_just_pressed("weapon_next"):
		next_weapon()

# Handle gravity

func handle_gravity(delta):
	
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# Jumping

func jump():
	
	gravity = -jump_strength
	
	jump_single = false;
	jump_double = true;

# Shooting

func shoot():
	
	if !blaster_cooldown.is_stopped(): return
	
	Audio.play_random(weapon.sound_shoot)
	item_container.position.z += 0.25
	
	burst.play("default")
	burst.rotation_degrees.z = randf_range(-45, 45)
	burst.scale = Vector3.ONE * randf_range(0.40, 0.75)
	
	burst.position = item_container.position - Vector3(0.1, -0.4, 1.5)
	
	blaster_cooldown.start(weapon.cooldown)
	
	# What or where the blaster hit
	
	for n in weapon.shot_count:
	
		raycast.target_position.x = randf_range(-weapon.spread, weapon.spread)
		raycast.target_position.y = randf_range(-weapon.spread, weapon.spread)
		
		raycast.force_raycast_update()
		
		if !raycast.is_colliding():
			return
			
		var collider = raycast.get_collider()
		
		if collider.has_method("damage"):
			collider.damage(weapon.damage)
		
		var impact = preload("res://objects/impact.tscn")
		var impact_instance = impact.instantiate()
		
		impact_instance.play("shot")
		
		get_tree().root.add_child(impact_instance)
		
		impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
		impact_instance.look_at(position, Vector3.UP, true)
		#impact_instance.rotation_degrees.z = randf_range(-45, 45)
# Weapons

func next_weapon():
	
	Audio.play("sounds/blaster_change.ogg")
	
	if weapon_index < weapons.size() - 1:
		weapon_index += 1
	else:
		weapon_index = 0
		
	change_weapon(weapon_index)

func change_weapon_apply():
	
	weapon = weapons[weapon_index]

	# Step 1. Remove all children in (weapon) container
	
	for n in item_container.get_children():
		item_container.remove_child(n)
	
	# Step 2. Load new model into container
	
	var weapon_model = weapon.model.instantiate()
	item_container.add_child(weapon_model)
	
	weapon_model.position = weapon.position
	weapon_model.rotation_degrees = weapon.rotation
	
	# Step 3. Set model to only render on layer 2
	
	for child in weapon_model.find_children("*", "MeshInstance3D"):
		child.layers = 2
		
	# Set weapon data
	
	raycast.target_position = Vector3(0, 0, -1) * weapon.max_distance
	crosshair.texture = weapon.crosshair

func change_weapon(index):
	
	weapon_index = index
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(item_container, "position", container_offset - Vector3(0, 1, 0), 0.1)
	tween.tween_callback(change_weapon_apply)

func get_hurt():
	pass
