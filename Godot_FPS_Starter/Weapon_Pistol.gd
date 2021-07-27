extends Spatial

const DAMAGE = 15 # The amount of damage a single bullet does 

const IDLE_ANIM_NAME = "Pistol_idle" # the name of the pistols idle animation
const FIRE_ANIM_NAME = "Pistol_fire" # the name of the pistols fire animation

const CAN_RELOAD = true
const CAN_REFILL = true

const RELOADING_ANIM_NAME = "Pistol_reload"

var is_weapon_enabled = false # A variable for checking whether this weapon is enabled

var bullet_scene = preload("Bullet_Scene.tscn") # The bulet scene the pistol spawns

var ammo_in_weapon = 10
var spare_ammo = 20
const AMMO_IN_MAG = 10

var player_node = null # a variable to hold the player script

func _ready():
	pass

func fire_weapon():
	var clone = bullet_scene.instance() # add an instance of a bullet
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone) # clone the child node of the scene we're in

	clone.global_transform = self.global_transform # the global transform of the pistol's point
	clone.scale = Vector3(4, 4, 4) # scale to a better size
	clone.BULLET_DAMAGE = DAMAGE # set the bullet's damage to pistol damage
	ammo_in_weapon -= 1 # reduces the ammo in the pistol
	player_node.create_sound("Pistol_shot", self.global_transform.origin) # the sound of the pistol firing

func equip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME: # checks whether the pistol is or isn't equipped
		is_weapon_enabled = true
		return true

	if player_node.animation_manager.current_state == "Idle_unarmed": # checks to see if the player is unarmed
		player_node.animation_manager.set_animation("Pistol_equip") # equip pistol animation

	return false

func unequip_weapon(): #checks things in reverse to equip function
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		if player_node.animation_manager.current_state != "Pistol_unequip":
			player_node.animation_manager.set_animation("Pistol_unequip")

	if player_node.animation_manager.current_state == "Idle_unarmed":
		is_weapon_enabled = false
		return true
	else:
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
