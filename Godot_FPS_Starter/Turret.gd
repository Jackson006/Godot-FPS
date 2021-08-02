extends Spatial

export (bool) var use_raycast = false # An exported boolean so we can change whether the turret uses objects or raycasting for bullets

const TURRET_DAMAGE_BULLET = 20 # The amount of damage a single bullet scene does
const TURRET_DAMAGE_RAYCAST = 5 # The amount of damage a single Raycast bullet does

const FLASH_TIME = 0.1 # The amount of time (in seconds) the muzzle flash meshes are visible
var flash_timer = 0 # A variable for tracking how long the muzzle flash meshes have been visible

const FIRE_TIME = 0.8 # The amount of time (in seconds) needed to fire a bullet
var fire_timer = 0 # A variable for tracking how much time has passed since the turret last fired

var node_turret_head = null # A variable to hold the Head node
var node_raycast = null # A variable to hold the Raycast node attached to the turret's head
var node_flash_one = null # A variable to hold the first muzzle flash MeshInstance
var node_flash_two = null # A variable to hold the second muzzle flash MeshInstance

var ammo_in_turret = 20 # The amount of ammo currently in the turret
const AMMO_IN_FULL_TURRET = 20 # The amount of ammo in a full turret
const AMMO_RELOAD_TIME = 4 # The amount of time it takes the turret to reload
var ammo_reload_timer = 0 # A variable for tracking how long the turret has been reloading

var current_target = null # The turret's current target

var is_active = false # A variable for tracking whether the turret is able to fire at the target

const PLAYER_HEIGHT = 3 # The amount of height we're adding to the target so we're not shooting at its feet

var smoke_particles # A variable to hold the smoke particles node

var turret_health = 60 # The amount of health the turret currently has
const MAX_TURRET_HEALTH = 60 # The amount of health a fully healed turret has

const DESTROYED_TIME = 20 # The amount of time (in seconds) it takes for a destroyed turret to repair itself
var destroyed_timer = 0 # A variable for tracking the amount of time a turret has been destroyed

var bullet_scene = preload("Bullet_Scene.tscn") # The bullet scene the turret fires (same scene as the player's pistol)

func _ready():

	$Vision_Area.connect("body_entered", self, "body_entered_vision") # gets the vision area and connect the body_entered
	$Vision_Area.connect("body_exited", self, "body_exited_vision") # get the body_exited signals to body_entered_vision and body_exited_vision

# We then get all the nodes and assign them
	node_turret_head = $Head 
	node_raycast = $Head/Ray_Cast
	node_flash_one = $Head/Flash
	node_flash_two = $Head/Flash_2

	node_raycast.add_exception(self)
	node_raycast.add_exception($Base/Static_Body)
	node_raycast.add_exception($Head/Static_Body)
	node_raycast.add_exception($Vision_Area)

	node_flash_one.visible = false
	node_flash_two.visible = false

	smoke_particles = $Smoke
	smoke_particles.emitting = false

	turret_health = MAX_TURRET_HEALTH # assigns the turret's health


func _physics_process(delta):
	if is_active == true: # Checks whether the turret is active

		if flash_timer > 0: # Checks if the flash timer is greater than 0
			flash_timer -= delta # Minus's the flash timer by delta

			if flash_timer <= 0: # If flash timer is less than or equal to 0
				node_flash_one.visible = false # makes node flash one invisible
				node_flash_two.visible = false # makes node flash two invisible

		if current_target != null: # Checks if the current target is null

			node_turret_head.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0, 1, 0)) # makes the turret look towards it's target

			if turret_health > 0: # checks if the turret's health is greater than 0

				if ammo_in_turret > 0: # checks if the ammo in the turret is greater than 0
					if fire_timer > 0: # Checks if the fire timer is greater than 0
						fire_timer -= delta # reduces the fire timer by delta
					else:
						fire_bullet() # Fires the bullet
				else:
					if ammo_reload_timer > 0: # Checks if the ammo is greater than 0
						ammo_reload_timer -= delta # Reduces the ammo reload timer by delta
					else:
						ammo_in_turret = AMMO_IN_FULL_TURRET # Refills the turret

	if turret_health <= 0: # Check if the turret health is equal to or less than 0
		if destroyed_timer > 0: # Checks if the destroyed timer is greater than 0
			destroyed_timer -= delta # reduces the destroyed timer by delta
		else:
			turret_health = MAX_TURRET_HEALTH # refills the turret's health
			smoke_particles.emitting = false # Makes the smoke particles invisible


func fire_bullet():

	if use_raycast == true: # Checks if the turret is using a raycast
		node_raycast.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0, 1, 0)) # Makes the turret look at the target

		node_raycast.force_raycast_update() # Forces the raycast to upgrade

		if node_raycast.is_colliding(): # Checks if the raycast is collding 
			var body = node_raycast.get_collider() # gets the node of the body the raycast has collided with
			if body.has_method("bullet_hit"): # Checks if a body has been hit by the raycast
				body.bullet_hit(TURRET_DAMAGE_RAYCAST, node_raycast.get_collision_point()) # Applies the bullet damage to the hit body

		ammo_in_turret -= 1 # reduces the ammo in the turret by 1

	else:
		var clone = bullet_scene.instance() # Clones the bullet
		var scene_root = get_tree().root.get_children()[0] # gets the root of the children
		scene_root.add_child(clone) # clones the scene root

		clone.global_transform = $Head/Barrel_End.global_transform # Transforms the barrel of the turret
		clone.scale = Vector3(8, 8, 8) # Scales the clone 
		clone.BULLET_DAMAGE = TURRET_DAMAGE_BULLET # The damage if the clone bullets
		clone.BULLET_SPEED = 60 # The speed of the clone bullets

		ammo_in_turret -= 1 # reduces the ammo in the turret by 1

	node_flash_one.visible = true # Makes node flash one visible
	node_flash_two.visible = true # Makes node flash two visible

	flash_timer = FLASH_TIME # Makes flash timer equal to flash timer
	fire_timer = FIRE_TIME # Makes fire timer equal to fire time

	if ammo_in_turret <= 0: # Checks if the ammo in the turret is less than or equal to 0
		ammo_reload_timer = AMMO_RELOAD_TIME # makes the ammo reload timer equal to the ammo reload time


func body_entered_vision(body):
	if current_target == null: # Checks if the current target is null
		if body is KinematicBody: # Checks if the current body is a KinematicBody
			current_target = body # makes the current target equal body
			is_active = true # Makes is_active true


func body_exited_vision(body):
	if current_target != null: # Checks if curernt target is null
		if body == current_target: # Checks if body is the current target
			current_target = null # makes the current target equal null
			is_active = false # Makes is_active false

			flash_timer = 0 # Makes flash timer equal to 0
			fire_timer = 0 # Makes fire timer equal to 0
			node_flash_one.visible = false # Makes node flash one invisisble
			node_flash_two.visible = false # Makes node flash two invisisble


func bullet_hit(damage, bullet_hit_pos):
	turret_health -= damage # Turret health reduces by the damage dealt to it

	if turret_health <= 0: # Checks if the turret has health less than or equal to 0
		smoke_particles.emitting = true # makes the turret emmit smoke particles
		destroyed_timer = DESTROYED_TIME # Makes the destroyed timer equal destroyed time
