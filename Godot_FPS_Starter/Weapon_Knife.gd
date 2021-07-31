extends Spatial

# variables same as other weapons 
const DAMAGE = 40

const IDLE_ANIM_NAME = "Knife_idle"
const FIRE_ANIM_NAME = "Knife_fire"

const CAN_RELOAD = false
const CAN_REFILL = false

const RELOADING_ANIM_NAME = ""

var is_weapon_enabled = false

var player_node = null

# because the knife does not consume ammo all ammo variables are 1
var ammo_in_weapon = 1
var spare_ammo = 1
const AMMO_IN_MAG = 1

func _ready():
	pass

func fire_weapon():
	var area = $Area # gets the area child node of the knife point
	var bodies = area.get_overlapping_bodies() # gets the collisions inside the body

	for body in bodies: # checks to see if the body is the player
		if body == player_node:
			continue # continues the code if the body is not the player

		if body.has_method("bullet_hit"): # if the knife hits it assigns damage
			body.bullet_hit(DAMAGE, area.global_transform)

func equip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		is_weapon_enabled = true
		return true

	if player_node.animation_manager.current_state == "Idle_unarmed":
		player_node.animation_manager.set_animation("Knife_equip")

	return false

func unequip_weapon():

	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		player_node.animation_manager.set_animation("Knife_unequip")

	if player_node.animation_manager.current_state == "Idle_unarmed":
		is_weapon_enabled = false
		return true

	return false

func reload_weapon():
	return false
