extends Spatial

# All variables are the same as the pistol
const DAMAGE = 4

const IDLE_ANIM_NAME = "Rifle_idle"
const FIRE_ANIM_NAME = "Rifle_fire"

const CAN_RELOAD = true
const CAN_REFILL = true

const RELOADING_ANIM_NAME = "Rifle_reload"

var is_weapon_enabled = false

var player_node = null

var ammo_in_weapon = 50 
var spare_ammo = 100
const AMMO_IN_MAG = 50

func _ready():
	pass

func fire_weapon():
	var ray = $Ray_Cast # is a child of the rifle point
	ray.force_raycast_update() #forces the raycast to detect collisions
	ammo_in_weapon -= 1 #reduces the ammo of the gun after firing

	if ray.is_colliding():
		var body = ray.get_collider() # assign damage
		player_node.create_sound("Rifle_shot", ray.global_transform.origin) # Plays the sound of the rifle firing

		if body == player_node: # if the body hit is the player node pass
			pass
		elif body.has_method("bullet_hit"): # if bullet hits assign damage
			body.bullet_hit(DAMAGE, ray.global_transform) 


func equip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		is_weapon_enabled = true
		return true

	if player_node.animation_manager.current_state == "Idle_unarmed":
		player_node.animation_manager.set_animation("Rifle_equip")

	return false

func unequip_weapon():

	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		if player_node.animation_manager.current_state != "Rifle_unequip":
			player_node.animation_manager.set_animation("Rifle_unequip")

	if player_node.animation_manager.current_state == "Idle_unarmed":
		is_weapon_enabled = false
		return true

	return false

func reload_weapon():
	var can_reload = false

	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		can_reload = true

	if spare_ammo <= 0 or ammo_in_weapon == AMMO_IN_MAG:
		can_reload = false

	if can_reload == true:
		var ammo_needed = AMMO_IN_MAG - ammo_in_weapon

		if spare_ammo >= ammo_needed:
			spare_ammo -= ammo_needed
			ammo_in_weapon = AMMO_IN_MAG
		else:
			ammo_in_weapon += spare_ammo
			spare_ammo = 0

		player_node.animation_manager.set_animation(RELOADING_ANIM_NAME)
		player_node.create_sound("Gun_cock", player_node.camera.global_transform.origin)

		return true

	return false
